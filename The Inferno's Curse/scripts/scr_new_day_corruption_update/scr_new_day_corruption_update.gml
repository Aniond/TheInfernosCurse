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

    // ── Primary corruption advance (enabled circles only) ─────────────────────
    // Limbo's corruption deepens by 8 each day — the ticking clock of the world.
    if (global.circle_enabled[CIRCLE_LIMBO]) {
        global.circle_corruption[CIRCLE_LIMBO] += 8;
    }

    // ── Cascade bleed: only lands on ENABLED circles ──────────────────────────
    // While a target circle is disabled (locked until its city), no bleed reaches
    // it, so its sin effects never fire. Re-enables automatically via circle_enabled
    // once the player reaches that city (scr_solve_circle unlocks the next).
    // During Circle 1 development only Limbo is enabled, so these are inert.
    // TODO: tune thresholds when those circles are sealed and tested.
    if (global.circle_enabled[CIRCLE_GLUTTONY] && global.circle_corruption[CIRCLE_LIMBO] >= 100) {
        global.circle_corruption[CIRCLE_GLUTTONY] += 5;   // Gluttony cascade
    }
    if (global.circle_enabled[CIRCLE_LUST] && global.circle_corruption[CIRCLE_LIMBO] >= 110) {
        global.circle_corruption[CIRCLE_LUST] += 3;       // Lust cascade
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

    // ── Auto-save full world state at day end ─────────────────────────────────
    scr_save_world_state();

    show_debug_message(
        "[Day " + string(global.day_count) + "] Corruption — " +
        "Limbo:" + string(global.circle_corruption[CIRCLE_LIMBO]) +
        " Gluttony:" + string(global.circle_corruption[CIRCLE_GLUTTONY]) +
        " Lust:" + string(global.circle_corruption[CIRCLE_LUST])
    );
}
