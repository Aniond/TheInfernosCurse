// =============================================================================
// obj_time_manager — Create Event
// =============================================================================
// LEGACY clock RETIRED. The single source of truth for the day/night clock is now
// scr_time_system (driven from obj_game_manager Step -> scr_time_step), which owns
// global.game_hour / game_minute / game_day and keeps global.time_of_day +
// global.is_night in sync for backwards compatibility.
//
// This manager NO LONGER advances time and NO LONGER initialises the clock (doing so
// would clobber a save just restored by scr_load_world_state in obj_game_manager's
// Create, which runs first). It survives only to:
//   (a) fire the daily corruption cascade once per new day (scr_new_day_corruption_update)
//   (b) draw the corruption-tinted sky HUD (see Draw GUI)
// PERSISTENT — one instance survives every room transition.
// =============================================================================

// Watch the canonical day counter so the daily cascade fires exactly once per new day —
// this covers natural midnight rollover AND sleep/prayer jumps that skip across midnight.
last_seen_day = variable_global_exists("game_day") ? global.game_day : global.day_count;

// Watch the hour for the black-market gate (Step). Init the flag here — this manager
// owns it; -1 forces one evaluation on the first Step so a mid-window load opens it.
last_seen_hour = -1;
if (!variable_global_exists("black_market_active")) global.black_market_active = false;
