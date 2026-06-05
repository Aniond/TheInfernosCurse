/// @description AI integration layer (real Claude API only — no mock fallback)
///
/// All NPC dialogue and journal text comes from live Claude calls.
///   global.claude_api_key is loaded by scr_config_load() from config.ini ([API] key=...).
///   scr_ai_call() fires an async http_request; the response is parsed in
///   obj_npc_base's Async-HTTP event (Async_62.gml) and written to
///   npc_data.last_response, then handed to scr_open_dialogue().
///
/// REQUIREMENT: a valid API key MUST be present at runtime, which means
///   config.ini must be delivered to the runtime working directory (Included Files).
///   With no key, scr_ai_call() returns -1 and callers surface a visible error
///   rather than inventing dialogue.

// ── Real API ─────────────────────────────────────────────────────────────────
//
// MODEL STRATEGY:
//   Haiku — NPC dialogue (fast, frequent, cheap — best for real-time interaction)
//   Sonnet — Journal entries, lore summaries, world state (richer, less frequent)
//   Opus — Architecture & design decisions only (not called at runtime)
//
// This script uses Haiku for scr_ai_call() — NPC responses must be quick
// to keep dialogue flowing. Other scripts reserve Sonnet/Opus for
// async generation tasks outside the play loop.

/// Fires an async POST to the Claude API.
/// Returns the request ID so the Async-HTTP event can match responses.
/// Returns -1 if no API key is set (caller surfaces a visible error).
///
/// @param {string} prompt          User-turn text
/// @param {string} system_prompt   NPC system prompt
/// @returns {real}                 Async request ID, or -1 if no key set
function scr_ai_call(prompt, system_prompt) {
    if (global.claude_api_key == "") {
        show_debug_message(
            "[scr_ai_call] No API key — cannot reach Claude. " +
            "Ensure config.ini ([API] key=...) is an Included File so it reaches " +
            "the runtime working directory."
        );
        return -1;
    }

    var _headers = ds_map_create();
    ds_map_add(_headers, "Content-Type",      "application/json");
    ds_map_add(_headers, "x-api-key",         global.claude_api_key);
    ds_map_add(_headers, "anthropic-version", "2023-06-01");

    // The Anthropic API rejects an empty user message ("messages.0: user
    // messages must have non-empty content"). For a greeting (no player input
    // yet) send a neutral stage-direction so the NPC opens in character — all
    // the personality/context lives in the system prompt.
    var _user = (string_trim(prompt) == "") ? "*Benedetto approaches you.*" : prompt;

    // Build the body manually so max_tokens is a true JSON integer. GML has no
    // integer type — json_stringify() would emit 150.0, which the Anthropic API
    // rejects ("max_tokens: Input should be a valid integer"). json_stringify()
    // is still used on the string fields to get correct JSON escaping.
    var _body = "{"
        + "\"model\":\"claude-haiku-4-5-20251001\","
        + "\"max_tokens\":150,"
        + "\"system\":"   + json_stringify(system_prompt) + ","
        + "\"messages\":[{\"role\":\"user\",\"content\":" + json_stringify(_user) + "}]"
        + "}";

    var _req_id = http_request(
        "https://api.anthropic.com/v1/messages", "POST", _headers, _body
    );

    ds_map_destroy(_headers);
    return _req_id;
}

// ── Prompt builder ────────────────────────────────────────────────────────────

/// Assembles a system prompt for a generic NPC from their data struct.
/// Call immediately before scr_ai_call() so all context values are current.
/// @param {struct} npc_data   NPC data struct (see scr_npc_framework)
/// @returns {string}
function scr_build_npc_system_prompt(npc_data) {
    var _circle  = npc_data.circle;
    var _corrupt = scr_corruption_get(_circle);

    // Tone instruction shifts automatically with corruption so the AI's voice
    // grows more fragmented as the circle is consumed.
    var _tone;
    if (_corrupt >= 75) {
        _tone = "Be fragmented, unnerving, barely coherent.";
    } else if (_corrupt >= 50) {
        _tone = "Be haunted and fearful, on the edge of breaking.";
    } else if (_corrupt >= 25) {
        _tone = "Be uneasy but coherent — show the cracks.";
    } else {
        _tone = "Be wary but grounded. The world is wrong but you still know yourself.";
    }

    return
        "You are " + npc_data.name + ", a " + npc_data.role +
        " living in " + npc_data.location + ".\n" +
        "The world around you is corrupted by the sin of " +
        global.sin_names[_circle] + " (Circle of " +
        global.circle_names[_circle] + "). Corruption level: " +
        string(_corrupt) + "/100.\n" +
        "Your personality: " + npc_data.personality + ".\n" +
        "Your memory of the player: " + scr_npc_memory_to_string(npc_data) + ".\n" +
        "Recent world events: " + scr_world_events_to_string(3) + ".\n" +
        "Player sin profile: " + scr_sin_profile_to_string() + ".\n" +
        "Rules: stay in character always. Max 2-3 sentences. " +
        "Reference the corruption naturally. " + _tone;
}


// =============================================================================
// Instance-based API interface
// (Takes instance IDs; bridges to the struct-based functions above)
// =============================================================================

/// Builds the full system prompt for an NPC instance using all available
/// world and sin context. Returns a richer prompt than scr_build_npc_system_prompt.
///
/// ATMOSPHERE uses scr_get_sin_behavior_description() — a plain-language
/// description of active sin effects that the AI can reference naturally.
/// BENEDETTO'S SIN PROFILE is fed in so the NPC reacts subtly to what he's done.
///
/// @param {Id.Instance} npc_id   Instance of any obj_npc_base child
/// @returns {string}   Complete system prompt
function scr_npc_build_system_prompt(npc_id) {
    if (!instance_exists(npc_id)) return "";

    var _bleed      = scr_get_bleed_context();
    var _sin_fx     = scr_get_sin_behavior_description();
    var _memories   = scr_npc_get_memory_string(npc_id);
    var _sin_prof   = scr_get_player_sin_profile();
    var _c          = npc_id.npc_memory_corruption;

    // ── Corruption behaviour string ───────────────────────────────────────────
    var _corruption_behavior;
    if (_c > 75) {
        _corruption_behavior =
            "You speak in fragments. You confuse this person for someone else. " +
            "You forget mid-sentence.";
    } else if (_c > 50) {
        _corruption_behavior =
            "You are confused about who this person is. " +
            "You trail off sometimes. You repeat yourself occasionally.";
    } else if (_c > 25) {
        _corruption_behavior =
            "You are slightly forgetful. You occasionally pause mid-thought.";
    } else {
        _corruption_behavior = "You are fully yourself.";
    }

    return
        "You are " + npc_id.npc_name +
        ", a " + npc_id.npc_role +
        " in " + npc_id.npc_location + "." +
        "\n\nPERSONALITY: " + npc_id.npc_personality +
        "\n\nWORLD STATE:\n" + _bleed +
        "\n\nATMOSPHERE:\n" + _sin_fx +
        "\n\nYOUR CURRENT STATE:\n" + _corruption_behavior +
        "\n\nYOUR MEMORIES OF THIS PERSON:\n" + _memories +
        "\n\nBENEDETTO'S SIN PROFILE:\n" + _sin_prof +
        "\n\nHISTORICAL SETTING:\n" +
        "Italy, 1300 AD. Medieval Catholic society.\n" +
        "Political tension between Guelphs and Ghibellines tears the city apart.\n" +
        "The Church is the center of all life.\n" +
        "Dante Alighieri is a living controversial figure — poet, politician, exile.\n" +
        "NPCs speak and behave as medieval Italians of this era.\n" +
        "Reference real landmarks naturally. Never use modern language or concepts." +
        "\n\nRULES:" +
        "\n- Stay in character always" +
        "\n- Never use the words corruption or sin" +
        "\n- Show your state through behavior not explanation" +
        "\n- Maximum 3 sentences" +
        "\n- React to Benedetto's sin profile subtly" +
        "\n- Your name means something to you. Use it rarely.";
}

/// Returns a string summarising the current historical context for API injection.
/// Combines static setting data with live game state (city, corruption level).
/// Append to any system prompt that needs grounding in 1300 AD Italy.
/// @returns {string}
function scr_get_historical_context() {
    var _city    = (array_length(global.city_names) > global.current_circle)
        ? global.city_names[global.current_circle]
        : "Florence";
    var _corrupt = string(round(global.circle_corruption[global.current_circle]));

    return
        "Italy, 1300 AD. The Catholic Church dominates all aspects of life. " +
        "Florence is torn between Guelph (papal) and Ghibelline (imperial) factions. " +
        "Dante Alighieri has just been exiled from Florence. " +
        "The Black Death has not yet arrived but disease and poverty are constant. " +
        "Life expectancy is short. Faith is everything — or was, until now. " +
        "Current city: " + _city + ". " +
        "Corruption level: " + _corrupt + "%.";
}

/// Fires an async Claude API call attributed to a specific NPC instance.
/// Stores the request ID on the instance so Async_62.gml can route the response.
/// If no API key is set, scr_ai_call returns -1 and the caller shows an error.
///
/// @param {Id.Instance} npc_id        Instance of any obj_npc_base child
/// @param {string}      player_input  What the player said (empty string for greeting)
function scr_npc_call_api(npc_id, player_input) {
    if (!instance_exists(npc_id)) exit;

    var _system = scr_npc_build_system_prompt(npc_id);
    var _req_id = scr_ai_call(player_input, _system);

    npc_id.request_id               = _req_id;
    npc_id.api_pending              = (_req_id != -1);
    npc_id.npc_data.pending_request = _req_id;

    // No key / call failed — surface a clear error instead of hanging in "loading".
    if (_req_id == -1) {
        scr_open_dialogue(npc_id, "[ No connection to Claude — check config.ini API key. ]");
    }
}
