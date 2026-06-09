// =============================================================================
// obj_stable_rest — Draw GUI  (rest prompt + transient result message)
// =============================================================================
if (msg_timer > 0) {
    var _gw0 = display_get_gui_width();
    var _by  = display_get_gui_height() - 90;
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(c_black);                       draw_text(_gw0 * 0.5 + 1, _by + 1, msg_text);
    draw_set_color(make_color_rgb(236, 220, 180)); draw_text(_gw0 * 0.5,     _by,     msg_text);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
}

if (!player_near || msg_timer > 0) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _tx = _gw * 0.5;
var _ty = _gh - 70;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_tx + 1, _ty + 1, "[E] Rest in the straw");
draw_set_color(make_color_rgb(238, 228, 205));
draw_text(_tx, _ty, "[E] Rest in the straw");
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
