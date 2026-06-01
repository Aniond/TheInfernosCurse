/// @description AI integration layer
///
/// MOCK MODE (default — no API key needed):
///   global.claude_api_key == "" → scr_mock_api_response() returns instant hardcoded dialogue.
///   All NPC dialogue runs locally with no network calls.
///
/// REAL MODE (once Console is back and key is set):
///   Populate claude_config.ini with your key (see obj_game_manager Create).
///   scr_ai_call() fires an async http_request; parse the response in
///   obj_game_manager's "Async - HTTP" event (add it in the IDE when ready)
///   and write the text to npc_data.last_response.
///
/// SWAP POINT: In scr_npc_get_dialogue() in scr_npc_framework.gml,
///   the mock/real branch is clearly marked. Only that one function changes.

// ── Mock ─────────────────────────────────────────────────────────────────────

/// Returns hardcoded dialogue appropriate to the current corruption level.
/// Designed to exercise all UI paths without needing a live API key.
///
/// @param {string} npc_name      NPC's name (reserved for future personalisation)
/// @param {real}   corruption    Circle corruption level 0-100
/// @param {string} player_input  What the player said (unused in mock)
/// @returns {string}             One line of NPC dialogue
function scr_mock_api_response(npc_name, corruption, player_input) {
    var _pool;

    if (corruption < 25) {
        // Tier 1 — world still remembers normality, just barely
        _pool = [
            "The shadows grow longer each day. Something stirs beneath the world.",
            "I remember when the sky was still blue. That was before... before all this.",
            "Tread carefully. The corruption takes those who linger too long.",
            "You have the look of someone still searching for something. Most stop searching.",
            "The Wardens haven't reached here yet. Hasn't stopped the dread, though."
        ];
    } else if (corruption < 50) {
        // Tier 2 — cracks showing, people fraying at the edges
        _pool = [
            "You feel it too, don't you? The pull. It whispers when it's quiet.",
            "Half my neighbours are... changed. I don't sleep anymore.",
            "If you're hunting the Wardens — pray you're faster than the last one.",
            "The dreams are getting worse. They're not my dreams.",
            "Every morning I check the mirror. Still me. For now."
        ];
    } else if (corruption < 75) {
        // Tier 3 — the corruption is winning, people are breaking
        _pool = [
            "Why do you still resist? It would be so much easier to let go.",
            "The Warden's voice is in my head. I can't — I can't make it stop.",
            "Run. Before the corruption decides it wants you too.",
            "I used to have a name. I think. Did you need something?",
            "There are things behind my eyes that are not mine."
        ];
    } else {
        // Tier 4 — full corruption, barely coherent
        _pool = [
            "...",
            "It sees you.",
            "There is no after. Only the Curse.",
            "Yesss. You are here at last.",
            "Join usss."
        ];
    }

    return _pool[irandom(array_length(_pool) - 1)];
}

// ── Real API ─────────────────────────────────────────────────────────────────

/// Fires an async POST to the Claude API.
/// Returns the request ID so obj_game_manager can match responses.
/// Returns -1 if no API key is set (caller should fall back to mock).
///
/// @param {string} prompt          User-turn text
/// @param {string} system_prompt   NPC system prompt
/// @returns {real}                 Async request ID, or -1 if no key set
function scr_ai_call(prompt, system_prompt) {
    if (global.claude_api_key == "") return -1;

    var _headers = ds_map_create();
    ds_map_add(_headers, "Content-Type",      "application/json");
    ds_map_add(_headers, "x-api-key",         global.claude_api_key);
    ds_map_add(_headers, "anthropic-version", "2023-06-01");

    var _body = json_stringify({
        model:      "claude-sonnet-4-6",
        max_tokens: 150,
        system:     system_prompt,
        messages:   [{ role: "user", content: prompt }]
    });

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
    var _tone =
        (_corrupt >= 75) ? "Be fragmented, unnerving, barely coherent." :
        (_corrupt >= 50) ? "Be haunted and fearful, on the edge of breaking." :
        (_corrupt >= 25) ? "Be uneasy but coherent — show the cracks." :
                           "Be wary but grounded. The world is wrong but you still know yourself.";

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
