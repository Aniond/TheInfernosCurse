/// @description Called every in-game day rollover. Advances corruption and
/// triggers cascade effects between circles.
///
/// Corruption scale used here is 0-200 (not the standard 0-100):
///   0-100  = standard corruption range
///   100+   = hyper-corruption; the circle has fully merged with Hell.
///            Hyper-corruption in one circle begins bleeding into neighbours.
///
/// Cascade thresholds (Limbo, index 0):
///   >= 100  Gluttony (index 2) begins spreading — consumed souls feed excess
///   >= 110  Lust (index 1) begins spreading — desire fills the void of grief
///
/// NOTE: This function writes directly to the global corruption arrays.
/// Do NOT use scr_corruption_modify() here — that function caps at 100.

// DESIGN: Limbo is the root corruption.
// Solving Limbo stops all downstream bleed.
// Each circle only bleeds when its upstream trigger threshold is met.
function scr_new_day_corruption_update() {

    // ── Primary corruption advance ────────────────────────────────────────────
    // Limbo's corruption deepens by 8 each day regardless of player actions.
    // This is the ticking clock of the game's world state.
    global.circle_corruption[CIRCLE_LIMBO] += 8;

    // ── Cascade: Gluttony (index 2) ───────────────────────────────────────────
    // When Limbo's grief fully consumes its inhabitants (>= 100), the emptiness
    // creates a vacuum that Gluttony fills. The void demands to be fed.
    if (global.circle_corruption[CIRCLE_LIMBO] >= 100) {
        global.circle_corruption[CIRCLE_GLUTTONY] += 5;
    }

    // ── Cascade: Lust (index 1) ───────────────────────────────────────────────
    // At 110 — beyond full corruption — the hyper-grief of Limbo overflows
    // into desperate seeking. Lost souls grasp at pleasure as the last sensation.
    if (global.circle_corruption[CIRCLE_LIMBO] >= 110) {
        global.circle_corruption[CIRCLE_LUST] += 3;
    }

    // ── Clamp all circles 0-200 ───────────────────────────────────────────────
    // Standard ceiling is 200. Values above 100 are hyper-corruption —
    // the circle has crossed the point of no return.
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        global.circle_corruption[_i] = clamp(global.circle_corruption[_i], 0, 200);
    }

    // ── World event log ───────────────────────────────────────────────────────
    // Record the day transition so the Claude API has narrative context.
    scr_world_event_log(
        "Day " + string(global.day_count) + " dawns. " +
        "Limbo corruption: " + string(global.circle_corruption[CIRCLE_LIMBO]) + ". " +
        "Gluttony: " + string(global.circle_corruption[CIRCLE_GLUTTONY]) + ". " +
        "Lust: "     + string(global.circle_corruption[CIRCLE_LUST]) + "."
    );

    // ── City state update ─────────────────────────────────────────────────────
    // Propagate new corruption levels to NPC behaviours, world events, etc.
    scr_update_city_state();

    // ── Persist world state to disk ───────────────────────────────────────────
    // world_state.json lives in the game's working directory. It is a
    // snapshot used for debugging and, eventually, cross-session persistence.
    var _state = {
        day:                 global.day_count,
        time_of_day:         round(global.time_of_day * 100) / 100,
        current_circle:      global.current_circle,
        circle_corruption:   global.circle_corruption,
        player_sin_affinity: global.player_sin_affinity,
        is_night:            global.is_night,
        sanity:              global.sanity,
        vision_intensity:    global.vision_intensity
    };

    var _file = file_text_open_write("world_state.json");
    file_text_write_string(_file, json_stringify(_state, true));
    file_text_close(_file);

    show_debug_message(
        "[Day " + string(global.day_count) + "] Corruption — " +
        "Limbo:" + string(global.circle_corruption[CIRCLE_LIMBO]) +
        " Gluttony:" + string(global.circle_corruption[CIRCLE_GLUTTONY]) +
        " Lust:" + string(global.circle_corruption[CIRCLE_LUST])
    );
}
