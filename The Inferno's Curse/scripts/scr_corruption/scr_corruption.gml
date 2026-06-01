/// @description Corruption system — global state for all seven circles

// Circle indices match Dante's structure (1-indexed, 0 is unused)
#macro CIRCLE_LIMBO    1
#macro CIRCLE_LUST     2
#macro CIRCLE_GLUTTONY 3
#macro CIRCLE_GREED    4
#macro CIRCLE_WRATH    5
#macro CIRCLE_HERESY   6
#macro CIRCLE_VIOLENCE 7
#macro CIRCLE_COUNT    7

/// Call once at game start from obj_game_manager Create.
function scr_corruption_init() {
    // Per-circle corruption 0-100. Index 0 unused (circles are 1-indexed).
    global.circle_corruption = array_create(CIRCLE_COUNT + 1, 0);

    // Per-sin affinity earned by player choices 0-100.
    global.sin_affinity = array_create(CIRCLE_COUNT + 1, 0);

    // Which circle the player is currently in.
    global.current_circle = CIRCLE_LIMBO;

    // Rolling world event log — newest at index 0, capped at 20 entries.
    global.world_event_log = [];

    // Human-readable names used in prompts and UI.
    global.circle_names = [
        "", "Limbo", "Lust", "Gluttony", "Greed", "Wrath", "Heresy", "Violence"
    ];
    global.sin_names = [
        "", "Grief", "Lust", "Gluttony", "Greed", "Wrath", "Heresy", "Violence"
    ];
}

/// Raises or lowers corruption for one circle.
/// Positive amount = more corrupted; negative = partial cleansing.
/// @param {real}   circle   Circle index 1-7
/// @param {real}   amount   Delta to apply (clamped to 0-100)
function scr_corruption_modify(circle, amount) {
    if (circle < 1 || circle > CIRCLE_COUNT) exit;
    global.circle_corruption[circle] = clamp(
        global.circle_corruption[circle] + amount, 0, 100
    );
    // Log meaningful shifts so the API has world-state context.
    if (abs(amount) >= 10) {
        var _verb = (amount > 0) ? "deepens in" : "recedes from";
        scr_world_event_log(
            "The corruption " + _verb + " " + global.circle_names[circle] + "."
        );
    }
}

/// @param {real} circle   Circle index 1-7
/// @returns {real}        Current corruption 0-100
function scr_corruption_get(circle) {
    if (circle < 1 || circle > CIRCLE_COUNT) return 0;
    return global.circle_corruption[circle];
}

/// @returns {real}   Average corruption across all seven circles (0-100)
function scr_corruption_global_average() {
    var _total = 0;
    for (var _i = 1; _i <= CIRCLE_COUNT; _i++) {
        _total += global.circle_corruption[_i];
    }
    return _total / CIRCLE_COUNT;
}

/// Spreads corruption from highly-infected circles to their neighbours.
/// Call after significant world events (boss defeat, long rest, etc.)
function scr_corruption_spread() {
    var _spread = array_create(CIRCLE_COUNT + 1, 0);
    for (var _i = 1; _i <= CIRCLE_COUNT; _i++) {
        var _prev = (_i > 1)            ? global.circle_corruption[_i - 1] : 0;
        var _next = (_i < CIRCLE_COUNT) ? global.circle_corruption[_i + 1] : 0;
        // Each neighbour bleeds 5% of its corruption into the current circle.
        _spread[_i] = clamp(global.circle_corruption[_i] + (_prev + _next) * 0.05, 0, 100);
    }
    global.circle_corruption = _spread;
    scr_world_event_log("The corruption shifts, bleeding across the circle boundaries.");
}

/// Appends an event description to the front of the world log.
/// Older entries beyond 20 are discarded automatically.
/// @param {string} text
function scr_world_event_log(text) {
    array_insert(global.world_event_log, 0, text);
    if (array_length(global.world_event_log) > 20) {
        array_delete(global.world_event_log, 20, 1);
    }
}

/// Returns the most recent world events as a single string for API context.
/// @param {real}   count   How many recent entries to include
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

/// Adjusts a sin affinity value. Positive builds affinity, negative reduces it.
/// @param {real} circle   Circle index 1-7
/// @param {real} amount   Delta to apply
function scr_sin_affinity_modify(circle, amount) {
    if (circle < 1 || circle > CIRCLE_COUNT) exit;
    global.sin_affinity[circle] = clamp(global.sin_affinity[circle] + amount, 0, 100);
}

/// Returns the player's full sin profile as readable text for API context.
/// Only includes sins with non-zero affinity.
/// @returns {string}
function scr_sin_profile_to_string() {
    var _out = "";
    for (var _i = 1; _i <= CIRCLE_COUNT; _i++) {
        if (global.sin_affinity[_i] > 0) {
            _out += global.sin_names[_i] + ":" + string(global.sin_affinity[_i]) + " ";
        }
    }
    return (_out == "") ? "No notable sin affinity yet." : string_trim(_out);
}
