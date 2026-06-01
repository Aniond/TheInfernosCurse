/// @description Corruption system — utility functions for all seven circles
///
/// INDEXING: All circle arrays use 0-based indexing throughout the project.
///   0 = Limbo  |  1 = Lust  |  2 = Gluttony  |  3 = Greed
///   4 = Wrath  |  5 = Heresy  |  6 = Violence
///
/// INITIALISATION: Global arrays are declared in obj_game_manager Create_0.gml
///   and that object is first in Room1's creation order. Do NOT call
///   scr_corruption_init() — that function has been removed.

// ── Circle index constants (0-based) ─────────────────────────────────────────
// Use these macros everywhere instead of raw numbers so a rename is one change.
#macro CIRCLE_LIMBO    0
#macro CIRCLE_LUST     1
#macro CIRCLE_GLUTTONY 2
#macro CIRCLE_GREED    3
#macro CIRCLE_WRATH    4
#macro CIRCLE_HERESY   5
#macro CIRCLE_VIOLENCE 6
#macro CIRCLE_COUNT    7  // total number of circles; valid indices are 0..(CIRCLE_COUNT-1)


// =============================================================================
// Corruption read / write
// =============================================================================

/// Raises or lowers corruption for one circle and logs major shifts.
/// @param {real}   circle   Circle index 0-6 (use CIRCLE_* macros)
/// @param {real}   amount   Delta — positive corrupts, negative cleanses
function scr_corruption_modify(circle, amount) {
    if (circle < 0 || circle >= CIRCLE_COUNT) exit;

    global.circle_corruption[circle] = clamp(
        global.circle_corruption[circle] + amount, 0, 100
    );

    // Only log shifts large enough to matter as world-event context for the API.
    if (abs(amount) >= 10) {
        var _verb = (amount > 0) ? "deepens in" : "recedes from";
        scr_world_event_log(
            "The corruption " + _verb + " " + global.circle_names[circle] + "."
        );
    }
}

/// Returns the current corruption level of a circle (0-100).
/// Returns 0 for out-of-range indices rather than erroring.
/// @param {real} circle   Circle index 0-6
/// @returns {real}
function scr_corruption_get(circle) {
    if (circle < 0 || circle >= CIRCLE_COUNT) return 0;
    return global.circle_corruption[circle];
}

/// Returns the mean corruption across all seven circles (0-100).
/// @returns {real}
function scr_corruption_global_average() {
    var _total = 0;
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        _total += global.circle_corruption[_i];
    }
    return _total / CIRCLE_COUNT;
}


// =============================================================================
// Corruption spread
// =============================================================================

/// Bleeds corruption from each circle into its immediate neighbours.
/// Uses global.circle_bleed_rate and global.circle_bleed_threshold so
/// each circle can have different spread behaviour tuned in obj_game_manager.
///
/// Call after significant world events (boss defeats, rests, day transitions).
/// Limbo (0) and Violence (6) only have one neighbour each.
function scr_corruption_spread() {
    // Build new values in a scratch array so neighbour reads are from the
    // CURRENT state, not the partially-updated one.
    var _new_vals = array_create(CIRCLE_COUNT, 0);

    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        var _val   = global.circle_corruption[_i];
        var _bleed = 0;

        // Left neighbour — only exists for circles 1-6
        if (_i > 0) {
            var _left = global.circle_corruption[_i - 1];
            // Only bleeds if it has crossed its own threshold
            if (_left > global.circle_bleed_threshold[_i - 1]) {
                _bleed += _left * global.circle_bleed_rate[_i - 1];
            }
        }

        // Right neighbour — only exists for circles 0-5
        if (_i < CIRCLE_COUNT - 1) {
            var _right = global.circle_corruption[_i + 1];
            if (_right > global.circle_bleed_threshold[_i + 1]) {
                _bleed += _right * global.circle_bleed_rate[_i + 1];
            }
        }

        _new_vals[_i] = clamp(_val + _bleed, 0, 100);
    }

    global.circle_corruption = _new_vals;
    scr_world_event_log("The corruption shifts, bleeding across the circle boundaries.");
}


// =============================================================================
// World event log
// =============================================================================

/// Prepends a text entry to the world event log. Oldest entry is dropped
/// when the log exceeds 20 entries.
/// @param {string} text   Short description of what happened
function scr_world_event_log(text) {
    array_insert(global.world_event_log, 0, text);
    if (array_length(global.world_event_log) > 20) {
        array_delete(global.world_event_log, 20, 1);
    }
}

/// Returns the most recent world events concatenated into one string
/// for inclusion in Claude API system prompts.
/// @param {real}   count   How many recent entries to include (capped at log length)
/// @returns {string}
function scr_world_events_to_string(count) {
    var _max = min(count, array_length(global.world_event_log));
    if (_max == 0) return "Nothing notable has occurred yet.";
    var _out = "";
    for (var _i = 0; _i < _max; _i++) {
        _out += global.world_event_log[_i];
        if (_i < _max - 1) _out += " ";
    }
    return _out;
}


// =============================================================================
// Sin affinity
// =============================================================================

/// Adjusts the player's affinity with a particular circle's sin.
/// Stored in global.player_sin_affinity (0-indexed, matches circle arrays).
/// @param {real} circle   Circle index 0-6
/// @param {real} amount   Delta — positive builds affinity, negative reduces it
function scr_sin_affinity_modify(circle, amount) {
    if (circle < 0 || circle >= CIRCLE_COUNT) exit;
    global.player_sin_affinity[circle] = clamp(
        global.player_sin_affinity[circle] + amount, 0, 100
    );
}

/// Returns the player's sin profile as a compact string for API context.
/// Only includes circles where affinity is non-zero.
/// @returns {string}
function scr_sin_profile_to_string() {
    var _out = "";
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        if (global.player_sin_affinity[_i] > 0) {
            _out += global.sin_names[_i] + ":" +
                    string(global.player_sin_affinity[_i]) + " ";
        }
    }
    return (_out == "") ? "No notable sin affinity yet." : string_trim(_out);
}
