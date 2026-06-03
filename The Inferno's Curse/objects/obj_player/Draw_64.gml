// ── Player: Draw GUI — HUD ───────────────────────────────────────────────────
// Runs after the game world is drawn, in screen-space. Safe to use
// display_get_gui_width/height here.

var _bar_x = 16;
var _bar_y  = display_get_gui_height() - 40;
var _bar_w  = 200;
var _bar_h  = 16;
var _ratio  = corruption / 100;
var _fill   = _bar_w * _ratio;

// Track
draw_set_color(c_dkgray);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

// Fill — shifts from white → crimson as corruption climbs
if (_fill > 0) {
    draw_set_color(merge_color(c_white, make_color_rgb(180, 0, 0), _ratio));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _fill, _bar_y + _bar_h, false);
}

// Border
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

// HP bar label
draw_set_color(c_white);
draw_text(_bar_x, _bar_y - 22, "HP  " + string(hp) + " / " + string(max_hp));

// Debug overlay: sanity + corruption numbers
if (global.debug_mode) {
    draw_set_color(make_color_rgb(160, 220, 160));
    draw_text(_bar_x, _bar_y, "S:" + string(round(global.sanity)) + "  C:" + string(round(corruption)));
}

draw_set_color(c_white); // reset
