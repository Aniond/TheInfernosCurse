// ── Game Manager: Create ─────────────────────────────────────────────────────
// Initialises all global systems at game start.
// persistent = true so one instance survives every room transition.

global.claude_api_key = "";   // populated from config file below, if present
global.dialogue_npc   = noone; // instance ID of the currently-speaking NPC

// Load API key from an INI file outside the project so it is never committed.
// To enable live Claude mode, create claude_config.ini in the game's working
// directory (same folder as the .exe) with:
//   [API]
//   key=sk-ant-...
var _cfg = "claude_config.ini";
if (file_exists(_cfg)) {
    ini_open(_cfg);
    global.claude_api_key = ini_read_string("API", "key", "");
    ini_close();
}

if (global.claude_api_key != "") {
    show_debug_message("[AI] API key loaded — live Claude mode active.");
    // TODO: Add "Async - HTTP" event to this object in the IDE when Console
    //       is back. Parse async_load[? "result"] and write the text content
    //       to global.dialogue_npc.npc_data.last_response.
} else {
    show_debug_message("[AI] No key found — using scr_mock_api_response().");
}

// Boot all game systems
scr_corruption_init();

show_debug_message("[Systems] All systems online.");
