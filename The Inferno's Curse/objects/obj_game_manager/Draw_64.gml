// =============================================================================
// obj_game_manager — Draw GUI: GLOBAL DAY/NIGHT LIGHTING (David's spec)
// =============================================================================
// Works in EVERY room with zero room-specific code:
//   1. full-screen time-of-day tint (smooth 30-min eases, corruption-darkened)
//   2. street-light glows — every torch/lantern/candle/shrine instance gets a
//      warm circle at dusk/night, world→screen transformed; corruption snuffs
//      them out (15% at 50+, 50% at 75+, ~90% at 100 with GREEN remnant flames)
//   3. the moon — drifts across the top of the sky through the night; red-
//      tinted at corruption 75+, blood red at 100
//   4. stars — twinkling dots in the sky band; fewer at 75+, NONE at 100.
//      The city is swallowed.
// =============================================================================
if (!variable_global_exists("game_hour")) exit;

var _L  = scr_time_lighting();
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// ── 1. time-of-day tint ────────────────────────────────────────────────────────
if (_L.alpha > 0) {
    draw_set_alpha(_L.alpha);
    draw_set_color(_L.col);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// world-space effects stay out of the battle screen (own staging/UI)
if (room == room_battle) exit;

// ── 2. street-light glows (dusk in → night full → dawn out) ───────────────────
if (_L.glow > 0.01) {
    // world→GUI transform from the active camera
    var _cam = view_camera[0];
    var _cx  = camera_get_view_x(_cam),     _cy = camera_get_view_y(_cam);
    var _cw  = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);
    if (_cw > 0 && _ch > 0) {
        var _sx = _gw / _cw, _sy = _gh / _ch;
        // corruption snuffs torches: fraction of lights that stay DARK
        var _dark_frac = 0;
        if (_L.corr >= 1.0)       _dark_frac = 0.90;
        else if (_L.corr >= 0.75) _dark_frac = 0.50;
        else if (_L.corr >= 0.50) _dark_frac = 0.15;
        var _green = (_L.corr >= 1.0);     // the remnants burn wrong
        gpu_set_blendmode(bm_add);
        with (all) {
            if (sprite_index == -1 || !visible) continue;
            var _nm = sprite_get_name(sprite_index);
            var _r = 0;
            if (string_pos("torch", _nm) > 0)        _r = 96;
            else if (string_pos("lantern", _nm) > 0) _r = 64;
            else if (string_pos("candle", _nm) > 0)  _r = 32;
            else if (string_pos("shrine", _nm) > 0)  _r = 28;
            if (_r == 0) continue;
            if (string_pos("shrine", _nm) > 0 && _L.corr >= 1) continue;   // she is gone
            // deterministic per-light snuff (stable across frames)
            var _hash = (((x div 16) * 73 + (y div 16) * 151) mod 100) / 100;
            if (_hash < _dark_frac) continue;
            var _lx = ((bbox_left + bbox_right) * 0.5 - _cx) * _sx;
            var _ly = (bbox_top + (bbox_bottom - bbox_top) * 0.30 - _cy) * _sy;
            if (_lx < -120 || _ly < -120 || _lx > _gw + 120 || _ly > _gh + 120) continue;
            var _flick = 1 + 0.08 * sin(current_time * 0.004 + x * 0.13 + y * 0.07);
            draw_set_color(_green ? make_color_rgb(70, 235, 110)
                                  : make_color_rgb(255, 200, 100));
            draw_set_alpha(0.314 * _L.glow * _flick);                // rgba(...,80)
            draw_circle(_lx, _ly, _r * _sx * _flick, false);
            draw_set_alpha(0.12 * _L.glow);
            draw_circle(_lx, _ly, _r * _sx * 0.45, false);           // hot core
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}

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
