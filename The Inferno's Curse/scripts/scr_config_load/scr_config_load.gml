// =============================================================================
// scr_config_load()
// =============================================================================
// Reads the Claude API key from config.ini and stores it in global.claude_api_key.
//
// config.ini must live in the game's working directory (same folder as the .exe
// when running from the IDE, or next to the compiled build).
//
// Expected file format:
//   [API]
//   key=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//
// If the file is missing or the key is empty the game cannot run —
// all NPC dialogue and world-event generation depend on the Claude API.
// A blocking message is shown and the game exits cleanly.
//
// NEVER put a real API key directly in this script or anywhere in the
// project directory. config.ini is listed in .gitignore.
// =============================================================================

function scr_config_load() {

    // Open the INI file. GameMaker looks for it relative to working_directory.
    ini_open("config.ini");

    // Read the key from the [API] section. The third argument is the default
    // value returned if the key or section doesn't exist — empty string here
    // so the missing-key check below catches both cases.
    global.claude_api_key = ini_read_string("API", "key", "");

    // Always close the INI handle, even if the read failed.
    ini_close();

    if (global.claude_api_key == "") {
        show_debug_message(
            "[Config] ERROR: No API key found in config.ini ([API] key=...). " +
            "NPC dialogue and journals require a live Claude key. " +
            "Confirm config.ini is delivered as an Included File to the runtime " +
            "working directory."
        );
    } else {
        show_debug_message(
            "[Config] API key loaded: " +
            string_copy(global.claude_api_key, 1, 12) + "..."
        );
    }
}
