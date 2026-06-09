// =============================================================================
// obj_npc_stableboy — Draw GUI  (the horse menu + transient result message)
// =============================================================================
// Transient confirmation / denial banner (after picking)
if (msg_timer > 0 && !menu_open) {
    var _gw0 = display_get_gui_width();
    var _by  = display_get_gui_height() - 90;
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(c_black);                       draw_text(_gw0 * 0.5 + 1, _by + 1, msg_text);
    draw_set_color(make_color_rgb(236, 220, 180)); draw_text(_gw0 * 0.5,     _by,     msg_text);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
}

if (!menu_open) exit;

var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _pw = 520, _ph = 244;
var _px = (_gw - _pw) * 0.5, _py = (_gh - _ph) * 0.5;

// panel + gold double border
draw_set_alpha(0.93);
draw_set_color(make_color_rgb(24, 18, 14));
draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 12, 12, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(206, 172, 84));
draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 12, 12, true);
draw_roundrect_ext(_px + 4, _py + 4, _px + _pw - 4, _py + _ph - 4, 10, 10, true);

// greeting — Pietro's demeanour tracks Limbo corruption
var _corr = global.circle_corruption[CIRCLE_LIMBO];
var _greet;
if      (_corr >= 100) _greet = "(Pietro presses against a stall door, white as chalk.)";
else if (_corr >= 75)  _greet = "\"P-please, signore. The horses... they won't settle.\"";
else if (_corr >= 50)  _greet = "\"...Something about you spooks the animals, signore.\"";
else                   _greet = "\"Buongiorno, signore! Finest stable in Florence.\"";

draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_set_color(make_color_rgb(236, 220, 180));
draw_text_transformed(_px + _pw * 0.5, _py + 18, "Fiorentine Stable", 1.2, 1.2, 0);
draw_set_color((_corr >= 75) ? make_color_rgb(196, 150, 150) : make_color_rgb(190, 176, 146));
draw_text(_px + _pw * 0.5, _py + 50, _greet);

var _o0y = _py + 102, _o1y = _py + 138, _o2y = _py + 174;
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(206, 172, 84));
draw_text(_px + 36, (menu_sel == 0) ? _o0y : ((menu_sel == 1) ? _o1y : _o2y), ">");
draw_set_color((menu_sel == 0) ? c_white : make_color_rgb(150, 140, 126));
draw_text(_px + 60, _o0y, "Stable my horse");
draw_set_color((menu_sel == 1) ? c_white : make_color_rgb(150, 140, 126));
draw_text(_px + 60, _o1y, "Claim my horse");
draw_set_color((menu_sel == 2) ? c_white : make_color_rgb(150, 140, 126));
draw_text(_px + 60, _o2y, "Never mind");

// footer — gold + controls
draw_set_color(make_color_rgb(206, 172, 84));
draw_text(_px + 24, _py + _ph - 28, "Gold: " + string(global.player_gold));
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(150, 140, 126));
draw_text(_px + _pw - 24, _py + _ph - 28, "Up/Down  -  Z select  -  Esc");
draw_set_halign(fa_left);
draw_set_color(c_white);
