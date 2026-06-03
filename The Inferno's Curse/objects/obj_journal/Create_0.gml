journal_entries = ds_list_create();
is_open = false;
current_page = 0;
total_pages = 0;
dot_timer = 0;
dot_string = ".";
generating = false;
last_entry_day = 0;
codex_cover_alpha = 0;

// ── Populate from saved codex entries ─────────────────────────────────────────
// obj_game_manager is first in the room creation order and runs scr_load_world_state()
// before this Create fires, so global.codex_entries already holds any saved entries.
// We own list population here to avoid a cross-instance ordering dependency.
if (variable_global_exists("codex_entries") && array_length(global.codex_entries) > 0) {
    for (var _i = 0; _i < array_length(global.codex_entries); _i++) {
        ds_list_add(journal_entries, global.codex_entries[_i]);
    }
} else {
    // ── TEST ENTRY — dev placeholder when no save exists. Remove once journal gen works.
    var _test = {
        day:              1,
        city:             "Florence",
        text:             "The wall moved today. I told myself it was exhaustion. I am not exhausted.",
        sanity_at_entry:  95,
        dominant_sin:     "Limbo",
        dominant_level:   8
    };
    ds_list_add(journal_entries, json_stringify(_test));
}

total_pages = ds_list_size(journal_entries);
