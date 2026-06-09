// =============================================================================
// obj_time_manager — Step Event
// =============================================================================
// The clock is advanced by scr_time_step (scr_time_system) — NOT here. This manager
// only watches for the day to turn over (natural midnight rollover, or a sleep/prayer
// jump that crosses midnight) and fires the daily corruption cascade once per new day,
// keeping the legacy global.day_count in step with the canonical global.game_day.
// =============================================================================
if (!variable_global_exists("game_day")) exit;

while (last_seen_day < global.game_day) {
    last_seen_day++;
    global.day_count++;
    scr_new_day_corruption_update();    // daily corruption cascade + persist (was wired to the old >=24 rollover)
    scr_corruption_spread();            // bleed corruption across circle boundaries once per new day
    scr_generate_journal_entry(true);   // Benedetto's daily diary entry — MOCK pool only, no API call yet
}

// ── Black-market gate — re-evaluated on every game-hour turnover ────────────────
// scr_time_black_market() = night (22-04) AND Limbo corruption >= 50. No vendor
// object exists yet: global.black_market_active is the live enable/disable hook the
// future vendor reads (spawn/interact only while true). State changes are logged.
if (last_seen_hour != global.game_hour) {
    last_seen_hour = global.game_hour;
    var _open = scr_time_black_market();
    if (_open != global.black_market_active) {
        global.black_market_active = _open;
        scr_world_event_log(_open
            ? "Whispers in the alleys — the black market stirs."
            : "The black market melts away with the dark.");
    }
}
