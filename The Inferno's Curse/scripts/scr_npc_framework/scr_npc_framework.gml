/// @description NPC data structures, memory system, and dialogue dispatch

/// Creates and returns a new NPC data struct with empty memory.
/// @param {string} id            Unique identifier, e.g. "elder_01"
/// @param {string} name          Display name shown in the dialogue box
/// @param {string} role          One-word role, e.g. "elder", "merchant"
/// @param {string} location      Location string fed into the system prompt
/// @param {real}   circle        Circle index 1-7 (sets corruption context)
/// @param {string} personality   Short descriptor fed into the system prompt
/// @returns {struct}
function scr_npc_create(id, name, role, location, circle, personality) {
    return {
        id:              id,
        name:            name,
        role:            role,
        location:        location,
        circle:          circle,
        personality:     personality,
        memory:          [],        // array of {event, detail, emotional_impact}
        disposition:     "neutral", // neutral | friendly | fearful | hostile
        knows_about:     [],        // array of rumour strings
        pending_request: -1,        // async HTTP request ID (-1 = none in flight)
        last_response:   ""         // most recent dialogue line (mock or live)
    };
}

/// Records a player interaction in the NPC's memory and shifts their disposition.
/// Newest entries are kept at the front; the list is capped at 10 entries.
/// @param {struct} npc_data
/// @param {string} event             Short event tag, e.g. "player_helped"
/// @param {string} detail            Human-readable description
/// @param {string} emotional_impact  e.g. "grateful" | "fearful" | "angry" | "neutral"
function scr_npc_add_memory(npc_data, event, detail, emotional_impact) {
    array_insert(npc_data.memory, 0, {
        event:            event,
        detail:           detail,
        emotional_impact: emotional_impact
    });
    if (array_length(npc_data.memory) > 10) {
        array_delete(npc_data.memory, 10, 1);
    }

    // Shift disposition based on the strongest emotional signal
    switch (emotional_impact) {
        case "grateful":
        case "relieved":
            if (npc_data.disposition == "neutral" || npc_data.disposition == "fearful") {
                npc_data.disposition = "friendly";
            }
            break;
        case "angry":
        case "betrayed":
            npc_data.disposition = "hostile";
            break;
        case "fearful":
            if (npc_data.disposition == "neutral") npc_data.disposition = "fearful";
            break;
    }
}

/// Converts the NPC's memory array into a compact string for API context.
/// Only the 3 most recent memories are included to keep prompts short.
/// @param {struct} npc_data
/// @returns {string}
function scr_npc_memory_to_string(npc_data) {
    var _len = array_length(npc_data.memory);
    if (_len == 0) return "No prior interactions.";
    var _out = "";
    var _max = min(3, _len);
    for (var _i = 0; _i < _max; _i++) {
        var _m = npc_data.memory[_i];
        _out += "[" + _m.event + ": " + _m.detail +
                " — felt " + _m.emotional_impact + "] ";
    }
    return string_trim(_out);
}

/// Triggers NPC dialogue — uses mock responses if no API key is set,
/// otherwise fires a real async Claude API call.
///
/// MOCK PATH:  sets npc_data.last_response immediately (no HTTP, no waiting).
/// REAL PATH:  sets npc_data.pending_request; the Async-HTTP event on
///             obj_game_manager must write the parsed text to npc_data.last_response.
///
/// SWAP POINT: Change the condition below when the API key is available.
///   Current:   if (global.claude_api_key == "") → always mock
///   Live mode: key is loaded from claude_config.ini, branch switches automatically.
///
/// @param {struct} npc_data
/// @param {string} player_input   What the player said or contextual prompt
function scr_npc_get_dialogue(npc_data, player_input) {
    if (global.claude_api_key == "") {
        // ── MOCK PATH — instant, no network ──────────────────────────────────
        var _corrupt = scr_corruption_get(npc_data.circle);
        npc_data.last_response   = scr_mock_api_response(npc_data.name, _corrupt, player_input);
        npc_data.pending_request = -1;
    } else {
        // ── REAL PATH — async HTTP, response handled in obj_game_manager ─────
        var _system = scr_build_npc_system_prompt(npc_data);
        npc_data.last_response   = ""; // cleared until response arrives
        npc_data.pending_request = scr_ai_call(player_input, _system);
    }
}
