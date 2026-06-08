// =============================================================================
// obj_npc_rosa — Draw GUI  (her spoken line, bottom-centre)
// =============================================================================
if (say_timer <= 0 || say_text == "") exit;

var _gw = display_get_gui_width();
var _by = display_get_gui_height() - 110;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _tw = string_width(say_text) + 64;

draw_set_alpha(0.88);
draw_set_color(make_color_rgb(26, 20, 14));
draw_roundrect_ext(_gw * 0.5 - _tw * 0.5, _by - 24, _gw * 0.5 + _tw * 0.5, _by + 24, 8, 8, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(206, 172, 84));
draw_roundrect_ext(_gw * 0.5 - _tw * 0.5, _by - 24, _gw * 0.5 + _tw * 0.5, _by + 24, 8, 8, true);

draw_set_color(make_color_rgb(236, 220, 180));
draw_text(_gw * 0.5, _by, say_text);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
