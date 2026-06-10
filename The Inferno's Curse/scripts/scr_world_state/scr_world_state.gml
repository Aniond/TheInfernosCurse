// =============================================================================
// scr_world_state — World State Persistence
// =============================================================================
// Full save/load of all persistent game state to save/world_state.json.
//
// Save path: working_directory + "save/world_state.json"
// Auto-save fires on: day advance, door enter, codex write, Marco arc change.
// Manual: F5 = save, F9 = load.
// =============================================================================


// =============================================================================
// scr_save_world_state
// =============================================================================
function scr_save_world_state() {

    // ── Build save struct ─────────────────────────────────────────────────────
    var _data        = {};
    _data.version    = 1;

    // Time
    _data.day_count   = global.day_count;
    _data.time_of_day = round(global.time_of_day * 100) / 100;
    _data.is_night    = global.is_night;
    _data.game_hour   = global.game_hour;
    _data.game_minute = global.game_minute;
    _data.game_day    = global.game_day;

    // Corruption & affinity
    _data.circle_corruption   = global.circle_corruption;
    _data.player_sin_affinity = global.player_sin_affinity;

    // Benedetto
    if (instance_exists(obj_player)) {
        _data.player_x = obj_player.x;
        _data.player_y = obj_player.y;
    } else {
        _data.player_x = global.save_player_x;
        _data.player_y = global.save_player_y;
    }
    _data.player_room = room_get_name(room);

    // Marco NPC — sync from instance if alive, else use globals
    if (instance_exists(obj_npc_marco)) {
        global.marco_met            = obj_npc_marco.marco_met;
        global.marco_recognition    = obj_npc_marco.marco_recognition;
        global.marco_corruption_arc = obj_npc_marco.marco_corruption_arc;
        global.marco_day_first_met  = obj_npc_marco.marco_day_first_met;
    }
    _data.marco_met            = global.marco_met;
    _data.marco_recognition    = global.marco_recognition;
    _data.marco_corruption_arc = global.marco_corruption_arc;
    _data.marco_day_first_met  = global.marco_day_first_met;

    // Codex / journal — read ds_list at save time
    var _entries = [];
    if (instance_exists(obj_journal)) {
        var _n = ds_list_size(obj_journal.journal_entries);
        for (var _i = 0; _i < _n; _i++) {
            array_push(_entries, ds_list_find_value(obj_journal.journal_entries, _i));
        }
    }
    _data.codex_entries     = _entries;
    _data.codex_entry_count = array_length(_entries);

    // Settings
    _data.debug_mode = global.debug_mode;

    // ── Write to disk ─────────────────────────────────────────────────────────
    var _save_dir = working_directory + "save/";
    if (!directory_exists(_save_dir)) {
        directory_create(_save_dir);
    }

    var _file = file_text_open_write(_save_dir + "world_state.json");
    file_text_write_string(_file, json_stringify(_data, true));
    file_text_close(_file);

    // ── Show save indicator ───────────────────────────────────────────────────
    global.save_indicator_text  = "SAVED";
    global.save_indicator_timer = 120; // 2 seconds at 60 fps

    // debug overlay: stamp last save + log it
    global.last_save_info = "D" + string(global.day_count) + " " + string(round(global.time_of_day * 100) / 100);
    if (variable_global_exists("world_event_log")) scr_world_event_log("Saved (Day " + string(global.day_count) + ")");

    show_debug_message("[Save] World state saved — Day " + string(global.day_count));
}


// =============================================================================
// scr_load_world_state
// =============================================================================
function scr_load_world_state() {

    var _path = working_directory + "save/world_state.json";

    if (!file_exists(_path)) {
        // ── No save file — set defaults ───────────────────────────────────────
        global.day_count            = 1;
        global.time_of_day          = 6;
        global.is_night             = false;
        global.circle_corruption    = array_create(7, 0);
        global.player_sin_affinity  = array_create(7, 0);
        global.save_player_x        = 1024;
        global.save_player_y        = 1024;
        global.save_player_room     = "Room_florence_v2";
        global.marco_met            = false;
        global.marco_recognition    = 100;
        global.marco_corruption_arc = 0;
        global.marco_day_first_met  = 0;
        global.codex_entries        = [];
        global.codex_entry_count    = 0;
        show_debug_message("[Load] No save file found — defaults initialized.");
        return;
    }

    // ── Read file ─────────────────────────────────────────────────────────────
    var _file = file_text_open_read(_path);
    var _raw  = "";
    while (!file_text_eof(_file)) {
        _raw += file_text_read_string(_file);
        file_text_readln(_file);
    }
    file_text_close(_file);

    var _d = json_parse(_raw);

    // ── Restore globals ───────────────────────────────────────────────────────

    // Time
    global.day_count   = _d[$ "day_count"]   ?? 1;
    global.time_of_day = _d[$ "time_of_day"] ?? 6;
    global.is_night    = _d[$ "is_night"]    ?? false;
    global.game_hour   = _d[$ "game_hour"]   ?? floor(global.time_of_day);
    global.game_minute = _d[$ "game_minute"] ?? round(frac(global.time_of_day) * 60);
    global.game_day    = _d[$ "game_day"]    ?? global.day_count;
    global.__time_accum = 0;

    // Corruption
    global.circle_corruption   = _d[$ "circle_corruption"]   ?? array_create(7, 0);
    global.player_sin_affinity = _d[$ "player_sin_affinity"] ?? array_create(7, 0);

    // Benedetto
    global.save_player_x   = _d[$ "player_x"]   ?? 1024;
    global.save_player_y   = _d[$ "player_y"]   ?? 1024;
    global.save_player_room = _d[$ "player_room"] ?? "Room_florence_v2";
    // Legacy saves remap: Room1 AND the wiped old Room_florence resolve to v2.
    if (global.save_player_room == "Room1" || global.save_player_room == "Room_florence") global.save_player_room = "Room_florence_v2";

    // Marco
    global.marco_met            = _d[$ "marco_met"]            ?? false;
    global.marco_recognition    = _d[$ "marco_recognition"]    ?? 100;
    global.marco_corruption_arc = _d[$ "marco_corruption_arc"] ?? 0;
    global.marco_day_first_met  = _d[$ "marco_day_first_met"]  ?? 0;

    // Codex
    global.codex_entries     = _d[$ "codex_entries"]     ?? [];
    global.codex_entry_count = _d[$ "codex_entry_count"] ?? 0;
    global.debug_mode        = _d[$ "debug_mode"]        ?? false;

    // ── Restore journal entries into obj_journal ds_list ──────────────────────
    // instance_exists() is true even before obj_journal's Create has run (instances
    // exist in creation order before their Create events fire), so its journal_entries
    // ds_list may not be created yet. On initial room load obj_game_manager (first in
    // creation order) runs this before obj_journal's Create — in that case we skip here
    // and obj_journal's Create populates itself from global.codex_entries instead.
    // This block only fires for a runtime reload (F9) when the journal is fully ready.
    if (instance_exists(obj_journal)
        && variable_instance_exists(obj_journal, "journal_entries")
        && array_length(global.codex_entries) > 0) {
        ds_list_clear(obj_journal.journal_entries);
        for (var _i = 0; _i < array_length(global.codex_entries); _i++) {
            ds_list_add(obj_journal.journal_entries, global.codex_entries[_i]);
        }
        obj_journal.total_pages = ds_list_size(obj_journal.journal_entries);
    }

    // ── Restore player position ───────────────────────────────────────────────
    if (instance_exists(obj_player)) {
        obj_player.x = global.save_player_x;
        obj_player.y = global.save_player_y;
    }

    // ── Show load indicator ───────────────────────────────────────────────────
    global.save_indicator_text  = "LOADED";
    global.save_indicator_timer = 120;

    show_debug_message("[Load] World state loaded — Day " + string(global.day_count));
}
