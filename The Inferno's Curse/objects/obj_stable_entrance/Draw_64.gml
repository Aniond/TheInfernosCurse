// =============================================================================
// obj_stable_entrance — Draw GUI
// =============================================================================
// Bottom-centre prompt while the player is near the stable doors.
if (!player_near) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _tx = _gw * 0.5;
var _ty = _gh - 70;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_tx + 1, _ty + 1, "[E] Enter the Fiorentine Stable");
draw_set_color(make_color_rgb(238, 228, 205));
draw_text(_tx, _ty, "[E] Enter the Fiorentine Stable");
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
