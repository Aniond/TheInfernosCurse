// =============================================================================
// obj_time_manager — Create Event
// =============================================================================
// Manages the in-game 24-hour clock and triggers day-cycle events.
// PERSISTENT — one instance survives every room transition.
// Created SECOND in Room1 (after obj_game_manager) so globals are ready.
//
// Time scale:
//   global.time_of_day runs 0.0 – 23.999…  (one full day)
//   At 24.0 it resets to 0.0 and day_count increments.
//
//   With cycle_speed = 0.005 and a 60 fps game:
//   0.005 × 60 steps/sec × 60 sec/min = 18 in-game minutes per real minute
//   → one full day takes ~80 real seconds (good for testing; tune as needed)
// =============================================================================

// Start at dawn — time 6.0 on the 0-24 scale
global.time_of_day = 6;

// Night flag — true between 19:00 and 06:00 (drives NPC behaviour, lighting)
global.is_night = false;

// How many time units advance per game step.
// Raise to speed up the day, lower for a longer cycle.
global.cycle_speed = 0.005;
