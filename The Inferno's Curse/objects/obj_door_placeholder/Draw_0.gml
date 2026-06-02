// =============================================================================
// obj_door_placeholder — Draw Event
// =============================================================================
// Brown rectangle visible in debug mode. Prompt always shows when near.

// ── Placeholder rect — debug only ────────────────────────────────────────────
if (global.debug_mode) {
    draw_set_color(make_color_rgb(120, 80, 40));
    draw_rectangle(x, y, x + door_w, y + door_h, false);
    draw_set_color(make_color_rgb(200, 140, 70));
    draw_rectangle(x, y, x + door_w, y + door_h, true);
}

// ── Interaction prompt ────────────────────────────────────────────────────────
if (near_player) {
    draw_set_color(make_color_rgb(255, 230, 150));
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(x + door_w * 0.5, y - 6, "[E] Enter");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

draw_set_color(c_white);
