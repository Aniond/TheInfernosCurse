/// Generates a journal entry struct for Father Benedetto.
/// Pass to scr_ai_call() with the returned system prompt to get a Sonnet response,
/// then ds_list_add(obj_journal.journal_entries, json_stringify(entry)).
///
/// @returns {struct}   Entry struct with day, city, sanity_at_entry, dominant_sin,
///                     dominant_level, and a placeholder text field for the AI response.
function scr_generate_journal_entry() {
    // Find dominant sin for context
    var _dom_idx   = 0;
    var _dom_level = global.circle_corruption[0];
    for (var _i = 1; _i < 7; _i++) {
        if (global.circle_corruption[_i] > _dom_level) {
            _dom_level = global.circle_corruption[_i];
            _dom_idx   = _i;
        }
    }

    var _city = (array_length(global.city_names) > global.current_circle)
        ? global.city_names[global.current_circle]
        : "Florence";

    var _entry = {
        day:             global.day_count,
        city:            _city,
        text:            "",   // filled by API response or caller
        sanity_at_entry: global.sanity,
        dominant_sin:    global.circle_names[_dom_idx],
        dominant_level:  _dom_level
    };

    // System prompt for Sonnet — richer generation, called async outside the play loop
    var _system =
        "You are Father Benedetto, a Florentine Catholic priest in Florence, Italy, 1300 AD.\n" +
        "You know the streets of Florence intimately.\n" +
        "You have walked past the Baptistery a thousand times.\n" +
        "You have preached in the shadow of the Duomo under construction.\n" +
        "You know of Dante Alighieri — a poet and political exile you have complicated feelings about.\n" +
        "You never believed your own sermons.\n" +
        "Now the city you have served for decades is forgetting itself.\n" +
        "The walls of the Baptistery breathed this morning. You did not tell anyone.\n\n" +
        "Current day: " + string(_entry.day) + ".\n" +
        "City: " + _city + ".\n" +
        "Your sanity: " + string(round(_entry.sanity_at_entry)) + "/100.\n" +
        "Dominant corruption: " + _entry.dominant_sin + " at " + string(round(_dom_level)) + "%.\n\n" +
        "Write one short journal entry (2-4 sentences) in first person, past tense.\n" +
        "Be specific. Reference a real Florence landmark or a real person you saw today.\n" +
        "Do not explain the corruption. Just describe what you noticed and what it cost you.";

    if (global.claude_api_key != "") {
        scr_ai_call("Write today's journal entry.", _system);
        // Response is routed through Async_62.gml — caller sets obj_journal.generating = true
    } else {
        // Mock entry for development
        _entry.text =
            "The wall moved today. I told myself it was exhaustion. " +
            "I am not exhausted. Brother Anselmo did not remember my name at Vespers. " +
            "He has known me for eleven years.";
    }

    // Auto-save after codex entry so journal progress survives a crash
    scr_save_world_state();

    return _entry;
}

function scr_journal_open() {
    with (obj_journal) {
        is_open     = true;
        total_pages = ds_list_size(journal_entries);
        if (total_pages > 0) {
            current_page = total_pages - 1;
        }
    }
    global.input_locked = true;
}

function scr_journal_close() {
    with (obj_journal) {
        is_open = false;
    }
    global.input_locked = false;
}
