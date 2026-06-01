// =============================================================================
// obj_time_manager — Step Event
// =============================================================================

// ── Advance time ──────────────────────────────────────────────────────────────
global.time_of_day += global.cycle_speed;

// ── Day rollover ──────────────────────────────────────────────────────────────
// When we pass midnight (24.0), reset the clock and start a new day.
// Subtracting 24 rather than hard-resetting to 0 preserves any fractional
// overshoot so fast time speeds don't skip a sliver of the new day.
if (global.time_of_day >= 24) {
    global.time_of_day -= 24;

    // Increment the global day counter (also tracked in obj_game_manager)
    global.day_count++;

    // Run the daily corruption cascade and persist world state to disk
    scr_new_day_corruption_update();
}

// ── Night flag ────────────────────────────────────────────────────────────────
// Night covers 19:00-24:00 and 00:00-06:00.
// Used by NPCs, enemy spawning, and visual systems.
global.is_night = (global.time_of_day > 18 || global.time_of_day < 6);
