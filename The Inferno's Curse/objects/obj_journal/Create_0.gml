journal_entries = ds_list_create();
is_open = false;
current_page = 0;
total_pages = 0;
dot_timer = 0;
dot_string = ".";
generating = false;
last_entry_day = 0;
codex_cover_alpha = 0;

// ── TEST ENTRY — remove once real journal generation is working ───────────────
var _test = {
    day:              1,
    city:             "Florence",
    text:             "The wall moved today. I told myself it was exhaustion. I am not exhausted.",
    sanity_at_entry:  95,
    dominant_sin:     "Limbo",
    dominant_level:   8
};
ds_list_add(journal_entries, json_stringify(_test));
// ─────────────────────────────────────────────────────────────────────────────
