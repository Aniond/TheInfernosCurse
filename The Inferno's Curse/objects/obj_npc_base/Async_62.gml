// =============================================================================
// obj_npc_base — Async HTTP Event
// =============================================================================
// Fires when any http_request() completes. Checks if the response belongs
// to this NPC instance by comparing async_load[?"id"] against request_id.
// If matched, parses the Claude API response and opens the dialogue box.
// =============================================================================

// Only handle responses that belong to this NPC instance.
if (async_load[? "id"] != request_id) exit;

// ── Error / network failure ───────────────────────────────────────────────────
if (async_load[? "status"] != 0) {
    show_debug_message(
        "[NPC " + npc_data.name + "] HTTP error: status=" +
        string(async_load[? "status"])
    );
    api_pending              = false;
    request_id               = -1;
    npc_data.pending_request = -1;
    // Fall back to mock response so the player isn't left hanging.
    api_response            = scr_mock_api_response(npc_data.name,
        scr_corruption_get(npc_data.circle), "");
    npc_data.last_response  = api_response;
    scr_open_dialogue(id, api_response);
    exit;
}

// ── Parse Claude response ─────────────────────────────────────────────────────
var _raw    = async_load[? "result"];
var _parsed = json_parse(_raw);

// Extract text from the first text-type content block.
var _text    = "";
var _content = _parsed.content;
for (var _i = 0; _i < array_length(_content); _i++) {
    if (_content[_i].type == "text") {
        _text = _content[_i].text;
        break;
    }
}

// ── Store response ────────────────────────────────────────────────────────────
api_response            = _text;
npc_data.last_response  = _text;
api_pending             = false;
request_id              = -1;
npc_data.pending_request = -1;

// ── Update memory ─────────────────────────────────────────────────────────────
scr_npc_update_memory(id, "Benedetto spoke", _text);

// ── Open dialogue box ─────────────────────────────────────────────────────────
// Pass the response text directly — scr_open_dialogue handles corruption
// fragmentation and wires everything into obj_dialogue_box.
scr_open_dialogue(id, api_response);

show_debug_message(
    "[NPC " + npc_data.name + "] Response received: " +
    string_copy(_text, 1, 60) + "..."
);
