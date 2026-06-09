// =============================================================================
// scr_time_system — in-world clock, day/night phases, NPC schedules, lighting
// =============================================================================
// 1 real second = 5 game minutes (TIME_RATE, first pass — tune freely).
// At 60 fps the accumulator adds TIME_RATE/60 per frame so the rate is exact.
//
// Globals owned here:
//   global.game_hour   (0-23)
//   global.game_minute (0-59)
//   global.game_day    (1+)
//   global.__time_accum  (fractional carry, internal)
//
// Phases:  Dawn 05-07 · Day 08-17 · Dusk 18-20 · Night 21-04
// =============================================================================

#macro TIME_RATE  5.0   // game minutes per real second — first pass, tune after testing

// ── Step — advance the clock ──────────────────────────────────────────────────
function scr_time_step() {
    global.__time_accum += TIME_RATE / 60.0;
    var _mins = floor(global.__time_accum);
    if (_mins < 1) return;
    global.__time_accum -= _mins;

    global.game_minute += _mins;
    while (global.game_minute >= 60) {
        global.game_minute -= 60;
        global.game_hour   += 1;
        if (global.game_hour >= 24) {
            global.game_hour  = 0;
            global.game_day  += 1;
        }
    }
    // Sync legacy float so existing save / debug code keeps working
    global.time_of_day = global.game_hour + global.game_minute / 60.0;
    global.is_night    = (global.game_hour >= 21 || global.game_hour <= 4);
}

// ── Advance by N whole hours (sleep / prayer) ─────────────────────────────────
function scr_time_advance_hours(_hours) {
    global.game_hour += _hours;
    while (global.game_hour >= 24) {
        global.game_hour -= 24;
        global.game_day  += 1;
    }
    global.__time_accum = 0;
    global.time_of_day  = global.game_hour + global.game_minute / 60.0;
    global.is_night     = (global.game_hour >= 21 || global.game_hour <= 4);
}

// ── Skip to next 06:00 (inn / stable sleep) ──────────────────────────────────
function scr_time_sleep() {
    global.game_hour   = 6;
    global.game_minute = 0;
    global.game_day   += 1;
    global.__time_accum = 0;
    global.time_of_day  = 6;
    global.is_night     = false;
}

// ── Current phase string ──────────────────────────────────────────────────────
function scr_time_phase() {
    var _h = global.game_hour;
    if (_h >= 5  && _h <= 7)  return "dawn";
    if (_h >= 8  && _h <= 17) return "day";
    if (_h >= 18 && _h <= 20) return "dusk";
    return "night";
}

// ── Lighting overlay for current phase ───────────────────────────────────────
// Returns struct { col, alpha } — draw as a full-screen tinted rectangle.
function scr_time_lighting() {
    switch (scr_time_phase()) {
        case "dawn":  return { col: make_color_rgb(255, 150, 80),  alpha: 0.20 };
        case "day":   return { col: c_black,                        alpha: 0.00 };
        case "dusk":  return { col: make_color_rgb(255, 120, 30),   alpha: 0.25 };
        case "night": return { col: make_color_rgb(20,  30,  80),   alpha: 0.55 };
    }
    return { col: c_black, alpha: 0 };
}

// ── NPC schedule — returns true if NPC should be present at current hour ─────
// Wire to spawn/despawn logic per-object. Unknown IDs always return true.
function scr_time_npc_active(_id) {
    var _h = global.game_hour;
    switch (_id) {
        case "barmaid":    return (_h >= 14 && _h < 22);  // Rosa
        case "innkeeper":  return (_h >= 6  && _h < 23);
        case "stable_boy": return (_h >= 5  && _h < 12);
        case "priest":     return (_h >= 6  && _h < 20);
        case "market":     return (_h >= 8  && _h < 18);  // market NPCs
        case "vieri":      return (_h >= 6  && _h < 22);  // Vieri patrols
    }
    return true;
}

// ── Black market availability ─────────────────────────────────────────────────
// Night only (22-04) AND Limbo corruption >= 50%.
function scr_time_black_market() {
    var _h    = global.game_hour;
    var _night = (_h >= 22 || _h <= 4);
    var _corr  = variable_global_exists("circle_corruption")
                 && global.circle_corruption[CIRCLE_LIMBO] >= 50;
    return _night && _corr;
}

// ── HH:MM display string ──────────────────────────────────────────────────────
function scr_time_str() {
    var _h = global.game_hour,   _hs = string(_h);
    var _m = global.game_minute, _ms = string(_m);
    if (_h < 10) _hs = "0" + _hs;
    if (_m < 10) _ms = "0" + _ms;
    return _hs + ":" + _ms;
}
