// =============================================================================
// obj_npc_base — Async HTTP Event
// =============================================================================
// Fires (possibly multiple times) for every http_request() this instance makes.
// GameMaker semantics for an HTTP async event:
//   async_load[? "status"]  >  0  → still in progress (intermediate event)
//                           == 0  → completed; "http_status" + "result" valid
//                           <  0  → network-level failure (couldn't reach host)
// We only act on the matching request id, ignore in-progress ticks, and always
// leave the loading state via scr_open_dialogue so the box never hangs.
// =============================================================================

var _aid    = async_load[? "id"];
var _status = async_load[? "status"];

// Only handle responses that belong to THIS instance's pending request.
if (_aid != request_id) exit;

show_debug_message(
    "[NPC " + npc_data.name + "] async id=" + string(_aid) +
    " status=" + string(_status) +
    " http=" + string(async_load[? "http_status"])
);

// ── In progress — wait for the completion event ───────────────────────────────
if (_status > 0) exit;

// ── Network-level failure (no HTTP response at all) ───────────────────────────
if (_status < 0) {
    api_pending              = false;
    request_id               = -1;
    npc_data.pending_request = -1;
    api_response             = "[ Network error reaching Claude (status " + string(_status) + "). ]";
    npc_data.last_response   = api_response;
    scr_open_dialogue(id, api_response);
    exit;
}

// ── Completed (status == 0) — inspect the HTTP response ───────────────────────
var _http = async_load[? "http_status"];
var _raw  = async_load[? "result"];

show_debug_message(
    "[NPC " + npc_data.name + "] body: " + string_copy(string(_raw), 1, 400)
);

api_pending              = false;
request_id               = -1;
npc_data.pending_request = -1;

// Non-2xx — surface the code so it's visible on screen and in the log.
if (_http < 200 || _http >= 300) {
    api_response           = "[ Claude API error " + string(_http) + " — see Output log. ]";
    npc_data.last_response = api_response;
    scr_open_dialogue(id, api_response);
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
    show_debug_message("[NPC " + npc_data.name + "] parse error: " + string(_e));
}

if (_text == "") {
    _text = "[ Claude returned no readable text — see Output log. ]";
}

// ── Store + display ───────────────────────────────────────────────────────────
api_response           = _text;
npc_data.last_response = _text;
scr_npc_update_memory(id, "Benedetto spoke", _text);
scr_open_dialogue(id, _text);

show_debug_message(
    "[NPC " + npc_data.name + "] Response shown: " +
    string_copy(_text, 1, 60) + "..."
);
