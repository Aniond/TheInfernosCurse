// =============================================================================
// obj_game_manager — Async HTTP Event
// =============================================================================
// Authoritative handler for Gemini API responses. obj_game_manager is a single
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
    var _err = "[ Network error reaching Gemini (status " + string(_status) + "). ]";
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
    var _msg = "";
    if (_http == 429) {
        _msg = "The city is so loud today, I cannot hear myself think... give me a moment.";
    } else if (_http >= 500) {
        _msg = "The heavens are silent right now... I need a moment to collect myself.";
    } else {
        _msg = "[ Gemini API error " + string(_http) + " — see Output log. ]";
    }
    
    _npc.api_response           = _msg;
    _npc.npc_data.last_response = _msg;
    scr_open_dialogue(_npc, _msg);
    exit;
}

// ── Parse the success body defensively ────────────────────────────────────────
// Expected shape Gemini: { "candidates": [ { "content": { "parts": [ { "text": "..." } ] } } ] }
var _text = "";
try {
    var _parsed = json_parse(_raw);
    if (is_struct(_parsed) && variable_struct_exists(_parsed, "candidates")) {
        var _cands = _parsed.candidates;
        if (is_array(_cands) && array_length(_cands) > 0) {
            var _cand0 = _cands[0];
            if (is_struct(_cand0) && variable_struct_exists(_cand0, "content")) {
                var _content = _cand0.content;
                if (is_struct(_content) && variable_struct_exists(_content, "parts")) {
                    var _parts = _content.parts;
                    if (is_array(_parts) && array_length(_parts) > 0) {
                        var _part0 = _parts[0];
                        if (is_struct(_part0) && variable_struct_exists(_part0, "text")) {
                            _text = _part0.text;
                        }
                    }
                }
            }
        }
    }
} catch (_e) {
    show_debug_message("[GameMgr] parse error: " + string(_e));
}

var _dialogue_str = _text;
var _suggested = [];
var _delta = 0;

if (_text != "") {
    try {
        var _inner = json_parse(_text);
        if (is_struct(_inner)) {
            if (variable_struct_exists(_inner, "dialogue")) _dialogue_str = _inner.dialogue;
            if (variable_struct_exists(_inner, "suggested_prompts")) _suggested = _inner.suggested_prompts;
            if (variable_struct_exists(_inner, "relationship_delta")) _delta = _inner.relationship_delta;
        }
    } catch (_e) {
        show_debug_message("[GameMgr] inner JSON parse error: " + string(_e));
    }
}

if (_dialogue_str == "") {
    _dialogue_str = "[ Gemini returned no readable text — see Output log. ]";
}

// ── Apply relationship delta ──────────────────────────────────────────────────
if (!variable_struct_exists(_npc.npc_data, "relationship_score")) {
    _npc.npc_data.relationship_score = 50; // default middle
}
_npc.npc_data.relationship_score = clamp(_npc.npc_data.relationship_score + _delta, 0, 100);

// ── Store + display ───────────────────────────────────────────────────────────
_npc.api_response           = _dialogue_str;
_npc.npc_data.last_response = _dialogue_str;
// Log the interaction with the exact delta
var _behavior = (_delta > 0) ? "friendly" : (_delta < 0 ? "rude" : "neutral");
scr_npc_log_event(_npc.npc_id, _behavior, _dialogue_str, _delta);
scr_open_dialogue(_npc, _dialogue_str);

if (instance_exists(obj_dialogue_box)) {
    obj_dialogue_box.suggested_prompts = _suggested;
}

show_debug_message(
    "[GameMgr] Response shown for " + _npc.npc_name + " (Rel: " + string(_npc.npc_data.relationship_score) + "): " +
    string_copy(_dialogue_str, 1, 60) + "..."
);
