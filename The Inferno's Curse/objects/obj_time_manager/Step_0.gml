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
    scr_new_day_corruption_update();   // daily corruption cascade + persist (was wired to the old >=24 rollover)
    scr_corruption_spread();           // bleed corruption across circle boundaries once per new day
}
