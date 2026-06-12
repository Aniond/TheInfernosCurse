/// Generates a journal entry struct for Father Benedetto.
/// Pass to scr_ai_call() with the returned system prompt to get a Sonnet response,
/// then ds_list_add(obj_journal.journal_entries, json_stringify(entry)).
///
/// @param {bool} _mock   true = NO API call: fill the text from the local mock pool
///                       (keyed to corruption tier, varied by day) and append the
///                       entry to obj_journal directly. The daily tick in
///                       obj_time_manager uses this until the live path is wired.
/// @returns {struct}   Entry struct with day, city, corruption_at_entry, dominant_sin,
///                     dominant_level, and a placeholder text field for the AI response.
function scr_generate_journal_entry(_mock = false) {
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
        corruption_at_entry: global.circle_corruption[CIRCLE_LIMBO],
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
        "The corruption upon you: " + string(round(_entry.corruption_at_entry)) + "/100.\n" +
        "Dominant corruption: " + _entry.dominant_sin + " at " + string(round(_dom_level)) + "%.\n\n" +
        "Write one short journal entry (2-4 sentences) in first person, past tense.\n" +
        "Be specific. Reference a real Florence landmark or a real person you saw today.\n" +
        "Do not explain the corruption. Just describe what you noticed and what it cost you.";

    if (_mock) {
        // ── MOCK path (daily tick) — no API call, ever. Diary line drawn from a
        // local pool by corruption tier, rotated by day so consecutive entries differ.
        var _c = _entry.corruption_at_entry;
        var _pool;
        if (_c >= 75) _pool = [
            "I could not find the Baptistery today. I stood where it has always stood and there was only the standing.",
            "Someone called my name in the Piazza della Signoria. There was no one in the square. There has been no one for days.",
            "I wrote a sermon I do not remember writing. The handwriting was mine. The words were not."
        ];
        else if (_c >= 50) _pool = [
            "The Arno ran the wrong way this morning. I watched it until a fishwife asked if I was unwell. I said yes. It was easier.",
            "Half the candles in the chapel went out at once. The sacristan blamed the draught. I did not correct him.",
            "Dante's exile was read aloud again by the gate. The crier's face was wrong — too smooth, like wax not yet set."
        ];
        else if (_c >= 25) _pool = [
            "The walls of the Baptistery breathed again at terce. A small motion, like a sleeping dog. I told no one.",
            "I passed the Duomo works and the scaffolding hummed. The masons heard nothing. My hands shook through vespers.",
            "A merchant on the Ponte greeted me by my childhood name. No one in Florence knows that name."
        ];
        else _pool = [
            "A quiet day, God be thanked. Bread from the market, a christening at noon. I almost believed my own blessing.",
            "I walked the walls at dawn and the city looked as it has always looked. I write this down so I can read it later and be sure.",
            "The bells of the Badia rang true today. Small mercies are still mercies."
        ];
        _entry.text = _pool[_entry.day mod array_length(_pool)];
        if (instance_exists(obj_journal)) {
            ds_list_add(obj_journal.journal_entries, json_stringify(_entry));
            obj_journal.last_entry_day = _entry.day;
        }
    } else if (global.gemini_api_key != "") {
        scr_ai_call("Write today's journal entry.", _system);
        // Response is routed through Async_62.gml — caller sets obj_journal.generating = true
    } else {
        // No key — cannot generate. Surface a clear error rather than fake text.
        show_debug_message(
            "[Journal] No API key — cannot generate entry. Check config.ini ([API] key=...)."
        );
        _entry.text = "[ The page stays blank — Gemini is unreachable. ]";
    }

    // Auto-save after codex entry so journal progress survives a crash
    scr_save_world_state();

    return _entry;
}

function scr_journal_open() {
    with (obj_journal) {
        is_open           = true;
        codex_cover_alpha = 1.0;
        total_pages       = ds_list_size(journal_entries);
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
