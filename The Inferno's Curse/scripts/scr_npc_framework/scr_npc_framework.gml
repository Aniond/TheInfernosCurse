/// @description NPC data structures, memory system, and dialogue dispatch

/// Creates and returns a new NPC data struct with empty memory.
/// @param {string} id            Unique identifier, e.g. "elder_01"
/// @param {string} name          Display name shown in the dialogue box
/// @param {string} role          One-word role, e.g. "elder", "merchant"
/// @param {string} location      Location string fed into the system prompt
/// @param {real}   circle        Circle index 0-6 (use CIRCLE_* macros)
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
        last_response:   ""         // most recent dialogue line from Claude
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

// =============================================================================
// Instance-based wrappers
// (Bridge between direct instance-var access and the npc_data struct)
// =============================================================================

/// Returns the NPC's memory as a string for prompt injection.
/// Takes an instance ID rather than a npc_data struct.
/// @param {Id.Instance} npc_id   Instance of any obj_npc_base child
/// @returns {string}
function scr_npc_get_memory_string(npc_id) {
    if (!instance_exists(npc_id)) return "No prior interactions.";
    return scr_npc_memory_to_string(npc_id.npc_data);
}

/// Records an interaction in the NPC's memory.
/// Wraps scr_npc_add_memory() with a simplified signature for the async handler.
/// @param {Id.Instance} npc_id   Instance of any obj_npc_base child
/// @param {string}      event    Short event tag, e.g. "Benedetto spoke"
/// @param {string}      text     The dialogue or event description
function scr_npc_update_memory(npc_id, event, text) {
    if (!instance_exists(npc_id)) exit;
    scr_npc_add_memory(npc_id.npc_data, event, text, "neutral");
}

/// Handles the full flow of starting an NPC conversation:
/// locks the NPC, fires the Claude API call, and opens the box.
/// Called from obj_npc_base Step event and child objects.
/// @param {Id.Instance} npc_id   Instance of any obj_npc_base child
function scr_npc_interact(npc_id) {
    if (!instance_exists(npc_id)) exit;

    with (npc_id) {
        is_talking          = true;
        api_pending         = true;
        global.dialogue_npc = id;

        // Real API path — show loading state immediately; the response arrives
        // in Async_62.gml which then calls scr_open_dialogue(id, text).
        // If no key is set, scr_npc_call_api surfaces a visible error instead.
        scr_show_loading(npc_name);
        scr_npc_call_api(id, "");
    }
}

/// Opens or refreshes the dialogue box for the given NPC.
/// Creates obj_dialogue_box if it doesn't exist; writes the NPC's
/// last_response into it so the typewriter effect can begin.
/// @param {Id.Instance} npc_id   Instance of any obj_npc_base child
/// Opens the dialogue box with the given text for the given NPC.
/// Applies corruption fragmentation before handing text to the box.
/// Locks player input for the duration of the conversation.
///
/// @param {Id.Instance} npc_id   Source NPC instance
/// @param {string}      text     The raw dialogue text to display
function scr_open_dialogue(npc_id, text) {
    if (!instance_exists(npc_id)) exit;

    if (text == "") {
        show_debug_message("[scr_open_dialogue] Empty text for " + npc_id.npc_data.name);
        exit;
    }

    // Apply corruption-based fragmentation before any character is revealed.
    // The player reads a version of the truth that the NPC can still give them.
    var _filtered = scr_dialogue_get_text_display(text, npc_id.npc_memory_corruption);

    // Create the dialogue box if it isn't already on screen.
    if (!instance_exists(obj_dialogue_box)) {
        instance_create_layer(0, 0, "Instances", obj_dialogue_box);
    }

    // Write all context into the box — it begins typewriter reveal next step.
    with (obj_dialogue_box) {
        is_active        = true;
        is_loading       = false;
        is_complete      = false;
        dialogue_text    = _filtered;
        display_text     = "";
        npc_name_display = npc_id.npc_name;
        char_index       = 0;
        typewriter_timer = 0;
        source_npc_id    = npc_id;
        corruption_level = npc_id.npc_memory_corruption;
        dot_string       = ".";
        dot_timer        = 0;

        // Keep legacy aliases in sync.
        full_text   = _filtered;
        npc_name    = npc_id.npc_name;
        char_timer  = 0;
        finished    = false;
        text_loaded = true;
    }

    // Lock player movement while the conversation is open.
    global.input_locked = true;
}

/// Shows the "Benedetto listens..." loading state while awaiting an async response.
/// Called immediately when a real API request is fired so the player
/// sees feedback instead of a frozen screen.
///
/// @param {string} npc_name   Display name of the NPC whose response is pending
function scr_show_loading(npc_name) {
    // Create the box if needed.
    if (!instance_exists(obj_dialogue_box)) {
        instance_create_layer(0, 0, "Instances", obj_dialogue_box);
    }

    with (obj_dialogue_box) {
        is_active        = true;
        is_loading       = true;
        is_complete      = false;
        npc_name_display = npc_name;
        npc_name         = npc_name; // legacy alias
        display_text     = "";
        dialogue_text    = "";
        dot_string       = ".";
        dot_timer        = 0;
        loading_timer    = 0;
        // Remember the source NPC during loading so ESC-cancel / timeout can
        // release it cleanly (global.dialogue_npc was set by scr_npc_interact).
        source_npc_id    = global.dialogue_npc;
    }

    global.input_locked = true;
}

/// Closes the dialogue box cleanly: resets all state, releases player input,
/// and marks the source NPC as no longer talking so it can be spoken to again.
function scr_close_dialogue() {
    if (!instance_exists(obj_dialogue_box)) exit;

    // Remember the source NPC before clearing it.
    var _source = obj_dialogue_box.source_npc_id;

    with (obj_dialogue_box) {
        is_active        = false;
        is_loading       = false;
        is_complete      = false;
        dialogue_text    = "";
        display_text     = "";
        npc_name_display = "";
        source_npc_id    = noone;
        corruption_level = 0;
        char_index       = 0;

        // Legacy aliases.
        full_text   = "";
        npc_name    = "";
        finished    = false;
        text_loaded = false;
    }

    // Release the NPC so they can be spoken to again after a cooldown.
    if (instance_exists(_source)) {
        _source.is_talking        = false;
        _source.api_pending       = false;
        _source.interact_cooldown = 10; // blocks same-frame re-trigger
    }

    global.dialogue_npc  = noone;
    global.input_locked  = false;
}

/// Applies corruption-based text fragmentation to NPC dialogue.
/// The higher the corruption the more the NPC's words break down,
/// simulating a mind that can no longer hold its own thoughts.
///
/// The player reads a degraded truth — not lies, just loss.
///
/// @param {string} raw_text         The original dialogue string
/// @param {real}   corruption_lvl   NPC's npc_memory_corruption (0-200)
/// @returns {string}   Modified text appropriate to the corruption level
function scr_dialogue_get_text_display(raw_text, corruption_lvl) {
    // Scale to 0-1 for threshold checks.
    var _cf = clamp(corruption_lvl / 200, 0, 1);

    // ── 0-50%: return unchanged ───────────────────────────────────────────────
    // The NPC is present. Their words are theirs.
    if (_cf <= 0.5) return raw_text;

    // ── 50-100%: fragmentation pipeline ──────────────────────────────────────
    // Split into words, process each one, rejoin.
    var _words  = string_split(raw_text, " ");
    var _count  = array_length(_words);
    var _result = "";

    for (var _i = 0; _i < _count; _i++) {
        var _w = _words[_i];

        if (_cf <= 0.75) {
            // ── 50-75%: 1 in 8 words replaced with "..." ─────────────────────
            // Trailing off. The NPC loses the thread mid-sentence.
            if (irandom(7) == 0) {
                _w = "...";
            }

        } else if (_cf <= 0.90) {
            // ── 75-90%: 1 in 4 words replaced; occasional phrase echo ────────
            // The mind loops. Certain phrases repeat, others vanish entirely.
            if (irandom(3) == 0) {
                _w = "...";
            } else if (irandom(6) == 0 && _i > 0) {
                // Echo a prior word (the NPC is stuck on it).
                _w = _words[irandom(_i)];
            }

        } else {
            // ── 90-100%: heavy fragmentation — barely coherent ────────────────
            // Three out of five words are lost.
            // What remains may not be in the right order.
            var _r = irandom(4);
            if (_r == 0 || _r == 1 || _r == 2) {
                _w = "...";
            } else if (_r == 3 && _i > 0) {
                // Randomly substitute a word already seen (confusion, not lies).
                _w = _words[irandom(_i)];
            }
        }

        _result += _w;
        if (_i < _count - 1) _result += " ";
    }

    return _result;
}

/// Returns a string describing how all active sin effects are currently
/// behaving — used as the "ATMOSPHERE" block in NPC system prompts.
/// @returns {string}
function scr_get_sin_behavior_description() {
    var _out = "";
    var _active = 0;

    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        var _c = global.circle_corruption[_i];
        if (_c <= 30) continue;
        _active++;

        var _intensity = round((_c / 200) * 100); // percentage of max
        switch (_i) {
            case CIRCLE_LIMBO:
                _out += "The bells of Santa Maria del Fiore ring at the wrong hours (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_LUST:
                _out += "The Piazza shimmers like heat from the forge district (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_GLUTTONY:
                _out += "The market stalls overflow but nothing satisfies (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_GREED:
                _out += "The merchants count coins that no longer exist (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_WRATH:
                _out += "Another Guelph and Ghibelline skirmish in the streets (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_HERESY:
                _out += "The priests preach but their words mean nothing now (" + string(_intensity) + "%). ";
                break;
            case CIRCLE_VIOLENCE:
                _out += "The stones remember every battle fought here (" + string(_intensity) + "%). ";
                break;
        }
    }

    if (_active == 0) return "The corruption is dormant. The world feels almost normal.";
    return string_trim(_out);
}

/// Returns the player's sin affinity as a readable description for NPC prompts.
/// Wrapper around scr_sin_profile_to_string() with a more descriptive label.
/// @returns {string}
function scr_get_player_sin_profile() {
    return scr_sin_profile_to_string();
}

/// Triggers NPC dialogue via a real async Claude API call.
/// Sets npc_data.pending_request; the Async-HTTP event (Async_62.gml) writes
/// the parsed text to npc_data.last_response and opens the dialogue box.
/// pending_request is -1 when no key is set (caller should surface an error).
///
/// @param {struct} npc_data
/// @param {string} player_input   What the player said or contextual prompt
function scr_npc_get_dialogue(npc_data, player_input) {
    var _system = scr_build_npc_system_prompt(npc_data);
    npc_data.last_response   = ""; // cleared until response arrives
    npc_data.pending_request = scr_ai_call(player_input, _system);
}
