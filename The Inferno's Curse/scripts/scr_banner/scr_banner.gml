// =============================================================================
// scr_banner — FF6-style location banner (gold plaque, fades after 3 seconds)
// =============================================================================
// Standardised entry banner shown when Benedetto enters a named room. A room's
// scene Create calls scr_banner_show("..."); the timer counts down in
// obj_game_manager Step (persistent); scr_banner_draw() renders it from obj_player's
// Draw GUI. Gold text on a dark double-bordered plaque, fades in then out.
//
//   scr_banner_show(text)  — start a 3s banner
//   scr_banner_step()      — decrement the timer (call each step)
//   scr_banner_draw()      — render it (call from a Draw GUI event)
// =============================================================================

#macro BANNER_FRAMES 180   // 3 seconds @ 60 fps

function scr_banner_show(_text) {
    global.banner_text  = _text;
    global.banner_timer = BANNER_FRAMES;
}

function scr_banner_step() {
    if (variable_global_exists("banner_timer") && global.banner_timer > 0) global.banner_timer -= 1;
}

function scr_banner_draw() {
    if (!variable_global_exists("banner_timer") || global.banner_timer <= 0) return;
    if (!variable_global_exists("banner_text")  || global.banner_text == "") return;

    var _t = global.banner_timer;
    // fade IN over the first 15 frames, hold, fade OUT over the last 40
    var _a = 1;
    if (_t > BANNER_FRAMES - 15) _a = (BANNER_FRAMES - _t) / 15;
    else if (_t < 40)            _a = _t / 40;
    _a = clamp(_a, 0, 1);

    var _gw  = display_get_gui_width();
    var _txt = global.banner_text;
    var _sc  = 2;                                   // text scale (pixel font)
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _tw = string_width(_txt) * _sc + 96;
    var _bh = 56;
    var _cx = _gw * 0.5;
    var _cy = 70;

    // dark plaque
    draw_set_alpha(_a * 0.82);
    draw_set_color(make_color_rgb(18, 14, 10));
    draw_roundrect_ext(_cx - _tw * 0.5, _cy - _bh * 0.5, _cx + _tw * 0.5, _cy + _bh * 0.5, 10, 10, false);
    // gold double border
    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(206, 172, 84));
    draw_roundrect_ext(_cx - _tw * 0.5,     _cy - _bh * 0.5,     _cx + _tw * 0.5,     _cy + _bh * 0.5,     10, 10, true);
    draw_roundrect_ext(_cx - _tw * 0.5 + 4, _cy - _bh * 0.5 + 4, _cx + _tw * 0.5 - 4, _cy + _bh * 0.5 - 4, 8,  8,  true);
    // gold text (shadow + main)
    draw_set_color(make_color_rgb(20, 14, 8));
    draw_text_transformed(_cx + 2, _cy + 2, _txt, _sc, _sc, 0);
    draw_set_color(make_color_rgb(236, 204, 116));
    draw_text_transformed(_cx, _cy, _txt, _sc, _sc, 0);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
