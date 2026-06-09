// =============================================================================
// obj_npc_rosa — Draw GUI  (the bar menu + transient result + her spoken line)
// =============================================================================
// Transient confirmation / denial banner (after buying)
if (msg_timer > 0 && !menu_open) {
    var _gw0 = display_get_gui_width();
    var _by0 = display_get_gui_height() - 90;
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(c_black);                       draw_text(_gw0 * 0.5 + 1, _by0 + 1, msg_text);
    draw_set_color(make_color_rgb(236, 220, 180)); draw_text(_gw0 * 0.5,     _by0,     msg_text);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
}

// Her spoken line ("Just talk"), bottom-centre
if (say_timer > 0 && say_text != "" && !menu_open) {
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
}

if (!menu_open) exit;

// ── The bar menu (drinks/food ONLY — rooms are Aldo's; division of roles) ───────
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _pw = 500, _ph = 264;
var _px = (_gw - _pw) * 0.5, _py = (_gh - _ph) * 0.5;

// panel + gold double border (matches the innkeeper's rest menu)
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
draw_text_transformed(_px + _pw * 0.5, _py + 18, "Rosa leans on the bar.", 1.2, 1.2, 0);
draw_text_transformed(_px + _pw * 0.5, _py + 44, "What can I get you?",    1.2, 1.2, 0);

// the four options
var _labels = [
    "Cup of wine  —  2 gold   (the whispers dull)",
    "Ribollita stew  —  4 gold   (restores half HP)",
    "Just talk",
    "Nothing, thanks"
];
draw_set_halign(fa_left);
for (var _i = 0; _i < 4; _i++) {
    var _oy = _py + 90 + _i * 32;
    if (menu_sel == _i) {
        draw_set_color(make_color_rgb(206, 172, 84));
        draw_text(_px + 36, _oy, ">");
    }
    draw_set_color((menu_sel == _i) ? c_white : make_color_rgb(150, 140, 126));
    draw_text(_px + 60, _oy, _labels[_i]);
}

// footer — gold + controls
draw_set_color(make_color_rgb(206, 172, 84));
draw_text(_px + 24, _py + _ph - 28, "Gold: " + string(global.player_gold));
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(150, 140, 126));
draw_text(_px + _pw - 24, _py + _ph - 28, "Up/Down  -  Z select  -  Esc");
draw_set_halign(fa_left);
draw_set_color(c_white);
