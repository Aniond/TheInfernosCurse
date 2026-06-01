// ── Dialogue Box: Step ───────────────────────────────────────────────────────

// Wait for text to arrive from the active NPC.
// In mock mode this is populated immediately; in real API mode it arrives
// after the async HTTP response updates npc_data.last_response.
if (!text_loaded && instance_exists(global.dialogue_npc)) {
    var _response = global.dialogue_npc.npc_data.last_response;
    if (_response != "") {
        full_text    = _response;
        npc_name     = global.dialogue_npc.npc_data.name;
        text_loaded  = true;
        char_index   = 0;
        char_timer   = 0;
        display_text = "";
        finished     = false;
    }
}

// Typewriter — reveal one character every char_delay steps
if (text_loaded && !finished) {
    char_timer++;
    if (char_timer >= char_delay) {
        char_timer = 0;
        char_index = min(char_index + 1, string_length(full_text));
        display_text = string_copy(full_text, 1, char_index);
        finished = (char_index >= string_length(full_text));
    }
}

// E key handling
if (keyboard_check_pressed(ord("E"))) {
    if (!finished) {
        // Skip typewriter — show the full line instantly
        char_index   = string_length(full_text);
        display_text = full_text;
        finished     = true;
    } else {
        // Close dialogue and record the interaction in the NPC's memory
        if (instance_exists(global.dialogue_npc)) {
            var _npc = global.dialogue_npc;
            scr_npc_add_memory(
                _npc.npc_data,
                "player_spoke",
                "Player initiated conversation.",
                "neutral"
            );
            _npc.is_talking        = false;
            _npc.interact_cooldown = 10; // block same-frame re-trigger
        }
        global.dialogue_npc = noone;
        instance_destroy();
    }
}
