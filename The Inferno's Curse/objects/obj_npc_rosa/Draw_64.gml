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

// Removed old menu rendering - Rosa now uses the AI chatbox directly.
