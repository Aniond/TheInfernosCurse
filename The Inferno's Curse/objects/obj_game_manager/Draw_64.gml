// =============================================================================
// obj_game_manager — Draw GUI: GLOBAL DAY/NIGHT LIGHTING (David's spec)
// =============================================================================
// Works in EVERY room with zero room-specific code:
//   1+2. TRUE MULTIPLY LIGHT MAP (scr_lightmap, 2026-06-10) — ambient from the
//      time-of-day phase + soft radial pools at every torch/lantern/candle/
//      shrine, multiplied over the frame in one call; corruption snuffs lights
//      (15% at 50+, 50% at 75+, ~90% at 100 with GREEN remnant flames)
//   3. the moon — drifts across the top of the sky through the night; red-
//      tinted at corruption 75+, blood red at 100
//   4. stars — twinkling dots in the sky band; fewer at 75+, NONE at 100.
//      The city is swallowed.
// =============================================================================
if (!variable_global_exists("game_hour")) exit;

var _L  = scr_time_lighting();
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// ── 1 + 2. GLOBAL LIGHT MAP (upgraded 2026-06-10, see scr_lightmap) ───────────
// The old "darken tint + additive glow circles" became a true multiply light
// map: ambient + soft radial light pools rendered to a surface, multiplied
// over the frame in one call. Same staging (phases, snuff, flicker, green
// remnants, the shrine going dark) — but light now genuinely restores local
// colour out of the darkness. Battle gets ambient only.
scr_lightmap_draw();

// world-space effects stay out of the battle screen (own staging/UI)
if (room == room_battle) exit;

// ── 3 + 4. the moon and the stars ─────────────────────────────────────────────
if (_L.night > 0.05) {
    // moon drifts across the top band through the night (21:00 → 05:00)
    var _hf = global.game_hour + global.game_minute / 60;
    var _tn = ((_hf - 21) + 24) mod 24;            // hours since nightfall
    var _prog = clamp(_tn / 8, 0, 1);              // 8-hour crossing
    var _mx = _gw * (0.12 + 0.70 * _prog);
    var _my = _gh * (0.14 - 0.05 * sin(_prog * pi));
    var _mcol = c_white;
    if (_L.corr >= 1.0)       _mcol = make_color_rgb(190, 30, 24);   // blood moon
    else if (_L.corr >= 0.75) _mcol = make_color_rgb(235, 150, 140); // red-tinged
    gpu_set_blendmode(bm_add);
    draw_set_color(_mcol);
    draw_set_alpha(0.05 * _L.night);  draw_circle(_mx, _my, 58, false);
    draw_set_alpha(0.09 * _L.night);  draw_circle(_mx, _my, 34, false);
    draw_set_alpha(0.16 * _L.night);  draw_circle(_mx, _my, 20, false);
    // stars — deterministic field in the sky band, twinkling; corruption
    // empties the sky (75+: a handful, 100: none — the city is swallowed)
    var _n_stars = 40;
    if (_L.corr >= 1.0)       _n_stars = 0;
    else if (_L.corr >= 0.75) _n_stars = 14;
    for (var _s = 0; _s < _n_stars; _s++) {
        var _stx = ((_s * 97) mod 173) / 173 * _gw;
        var _sty = ((_s * 57) mod 89)  / 89  * _gh * 0.42;
        var _tw  = 0.5 + 0.5 * sin(current_time * 0.003 + _s * 2.7);
        draw_set_alpha((0.10 + 0.16 * _tw) * _L.night);
        draw_set_color(c_white);
        draw_circle(_stx, _sty, (_s mod 3 == 0) ? 1.6 : 1, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
