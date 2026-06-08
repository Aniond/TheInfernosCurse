// =============================================================================
// obj_npc_innkeeper — Draw GUI  (the rest menu + transient result message)
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
var _pw = 500, _ph = 220;
var _px = (_gw - _pw) * 0.5, _py = (_gh - _ph) * 0.5;

// panel + gold double border
draw_set_alpha(0.93);
draw_set_color(make_color_rgb(24, 18, 14));
draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 12, 12, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(206, 172, 84));
draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 12, 12, true);
draw_roundrect_ext(_px + 4, _py + 4, _px + _pw - 4, _py + _ph - 4, 10, 10, true);

// greeting
draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_set_color(make_color_rgb(236, 220, 180));
draw_text_transformed(_px + _pw * 0.5, _py + 18, "Welcome traveler.",      1.4, 1.4, 0);
draw_text_transformed(_px + _pw * 0.5, _py + 46, "A room for the night?",  1.2, 1.2, 0);

// the room offered for the player's reputation tier
var _tier = scr_inn_rep_tier();
var _cost, _relief, _name;
if      (_tier == "high")   { _name = "The Merchant's Suite"; _cost = 20; _relief = 3;   }
else if (_tier == "medium") { _name = "Standard Room";        _cost = 10; _relief = 1.5; }
else                        { _name = "Common Cot";           _cost = 4;  _relief = 0;   }
var _reltxt = (_relief > 0) ? (", corruption -" + string(_relief) + "%") : "";

var _o0y = _py + 96, _o1y = _py + 134;
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(206, 172, 84));
draw_text(_px + 36, (menu_sel == 0) ? _o0y : _o1y, ">");
draw_set_color((menu_sel == 0) ? c_white : make_color_rgb(150, 140, 126));
draw_text(_px + 60, _o0y, _name + "  —  " + string(_cost) + " gold   (full rest" + _reltxt + ")");
draw_set_color((menu_sel == 1) ? c_white : make_color_rgb(150, 140, 126));
draw_text(_px + 60, _o1y, "Maybe later");

// footer — gold + standing + controls
draw_set_color(make_color_rgb(206, 172, 84));
draw_text(_px + 24, _py + _ph - 28, "Gold: " + string(global.player_gold) + "    [" + _tier + " standing]");
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(150, 140, 126));
draw_text(_px + _pw - 24, _py + _ph - 28, "Up/Down  -  Z select  -  Esc");
draw_set_halign(fa_left);
draw_set_color(c_white);
