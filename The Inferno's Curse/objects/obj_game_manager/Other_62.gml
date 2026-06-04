// =============================================================================
// obj_game_manager — Async HTTP Event
// =============================================================================
// Authoritative handler for Claude API responses. obj_game_manager is a single
// persistent instance, so (unlike a per-NPC *inherited* async event) it is
// guaranteed to be alive and to receive this event when any http_request
// completes. It finds the NPC whose request_id matches and routes the response.
// =============================================================================

var _aid    = async_load[? "id"];
var _status = async_load[? "status"];

show_debug_message(
    "[GameMgr] async id=" + string(_aid) +
    " status=" + string(_status) +
    " http=" + string(async_load[? "http_status"])
);

// ── Find the NPC instance whose pending request this response belongs to ──────
var _npc = noone;
with (obj_npc_base) {
    if (request_id == _aid) {
        _npc = id;
        break;
    }
}
if (_npc == noone) exit;   // not one of ours (or already handled)

// ── In progress — wait for completion ─────────────────────────────────────────
if (_status > 0) exit;

// ── Network-level failure (no HTTP response at all) ───────────────────────────
if (_status < 0) {
    _npc.api_pending              = false;
    _npc.request_id               = -1;
    _npc.npc_data.pending_request = -1;
    var _err = "[ Network error reaching Claude (status " + string(_status) + "). ]";
    _npc.api_response           = _err;
    _npc.npc_data.last_response = _err;
    scr_open_dialogue(_npc, _err);
    exit;
}

// ── Completed (status == 0) — inspect the HTTP response ───────────────────────
var _http = async_load[? "http_status"];
var _raw  = async_load[? "result"];

show_debug_message(
    "[GameMgr] body: " + string_copy(string(_raw), 1, 400)
);

_npc.api_pending              = false;
_npc.request_id               = -1;
_npc.npc_data.pending_request = -1;

// Non-2xx — surface the code so it's visible on screen and in the log.
if (_http < 200 || _http >= 300) {
    var _msg = "[ Claude API error " + string(_http) + " — see Output log. ]";
    _npc.api_response           = _msg;
    _npc.npc_data.last_response = _msg;
    scr_open_dialogue(_npc, _msg);
    exit;
}

// ── Parse the success body defensively ────────────────────────────────────────
// Expected shape: { "content": [ { "type": "text", "text": "..." }, ... ] }
var _text = "";
try {
    var _parsed = json_parse(_raw);
    if (is_struct(_parsed) && variable_struct_exists(_parsed, "content")) {
        var _content = _parsed.content;
        if (is_array(_content)) {
            for (var _i = 0; _i < array_length(_content); _i++) {
                var _block = _content[_i];
                if (is_struct(_block)
                 && variable_struct_exists(_block, "type")
                 && _block.type == "text") {
                    _text = _block.text;
                    break;
                }
            }
        }
    }
} catch (_e) {
    show_debug_message("[GameMgr] parse error: " + string(_e));
}

if (_text == "") {
    _text = "[ Claude returned no readable text — see Output log. ]";
}

// ── Store + display ───────────────────────────────────────────────────────────
_npc.api_response           = _text;
_npc.npc_data.last_response = _text;
scr_npc_update_memory(_npc, "Benedetto spoke", _text);
scr_open_dialogue(_npc, _text);

show_debug_message(
    "[GameMgr] Response shown for " + _npc.npc_name + ": " +
    string_copy(_text, 1, 60) + "..."
);
