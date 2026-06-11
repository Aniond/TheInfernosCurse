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
    // Debug freeze (toggled with T) — clock holds; Ctrl+T can still step it manually.
    if (variable_global_exists("time_frozen") && global.time_frozen) return;
    // Character sheet open — GAME TIME pauses (corruption does not; the Curse
    // does not wait while Benedetto reads about himself).
    if (variable_global_exists("char_sheet_open") && global.char_sheet_open) return;
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
// GLOBAL DAY/NIGHT LIGHTING (David's spec, 2026-06-10): smooth 30-minute eases
// between phases (no hard cuts), corruption-aware. Returns struct:
//   col/alpha — the full-screen overlay tint
//   glow      — 0..1 street-light strength (dusk ramps in, night full, dawn fades)
//   night     — 0..1 depth into night (gates the moon + stars)
//   corr      — 0..1 Limbo corruption (cached for the light pass)
function scr_time_lighting() {
    var _h = global.game_hour
           + (variable_global_exists("game_minute") ? global.game_minute / 60 : 0);
    var _corr = (variable_global_exists("circle_corruption"))
        ? clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1) : 0;

    // night overlay deepens with corruption — at 100 the city is swallowed
    var _na = 0.706;                       // rgba alpha 180/255 per spec
    if (_corr >= 1.0)      _na = 0.86;
    else if (_corr >= 0.5) _na = 0.76;

    // phase table [startHour, r, g, b, alpha] — spec colors
    var _ph = [
        [5,  255, 180, 100, 0.157],        // dawn  05-07  rgba(255,180,100,40)
        [8,  0,   0,   0,   0.0  ],        // day   08-17  clear
        [18, 255, 140, 50,  0.235],        // dusk  18-20  rgba(255,140,50,60)
        [21, 20,  20,  60,  _na  ],        // night 21-04  rgba(20,20,60,180)
    ];
    var _i = 3;                                          // night wraps past midnight
    if (_h >= 5  && _h < 8)       _i = 0;
    else if (_h >= 8  && _h < 18) _i = 1;
    else if (_h >= 18 && _h < 21) _i = 2;
    var _cur  = _ph[_i];
    var _prev = _ph[(_i + 3) mod 4];
    var _since = _h - _cur[0]; if (_since < 0) _since += 24;
    var _t = clamp(_since / 0.5, 0, 1);                  // 30-minute ease-in
    var _col = make_color_rgb(
        lerp(_prev[1], _cur[1], _t),
        lerp(_prev[2], _cur[2], _t),
        lerp(_prev[3], _cur[3], _t));
    var _a = lerp(_prev[4], _cur[4], _t);

    // street-light strength: dusk ramps it in, night holds full, dawn fades it
    var _glow = 0;
    if (_i == 2)      _glow = clamp(_since / 3, 0, 1) * 0.7;       // dusk: appearing
    else if (_i == 3) _glow = min(1, 0.7 + _t * 0.3);              // night: full
    else if (_i == 0) _glow = clamp(1 - _since / 2.5, 0, 1);       // dawn: fading

    // depth into night (eases at both edges)
    var _night = 0;
    if (_i == 3)      _night = _t;
    else if (_i == 0) _night = clamp(1 - _since / 0.5, 0, 1);

    return { col: _col, alpha: _a, glow: _glow, night: _night, corr: _corr };
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
