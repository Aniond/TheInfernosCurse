// =============================================================================
// obj_safe_house — Draw Event
// =============================================================================
// Draws the refuge: a 64x64 building with a door, and — while the player is
// inside — a soft blue glow and a "Safe" label above it.

// ── Placeholder rectangle — debug mode only ───────────────────────────────────
// Set global.debug_mode = false to hide all placeholder art in player builds.
if (global.debug_mode) {
    draw_set_color(make_color_rgb(40, 40, 60));
    draw_rectangle(x, y, x + 64, y + 64, false);
    draw_set_color(make_color_rgb(70, 70, 100));
    draw_rectangle(x, y, x + 64, y + 64, true);
    // Door indicator
    draw_set_color(make_color_rgb(20, 20, 30));
    draw_rectangle(x + 24, y + 40, x + 40, y + 64, false);
    draw_set_color(make_color_rgb(90, 90, 120));
    draw_rectangle(x + 24, y + 40, x + 40, y + 64, true);
}

// ── Gameplay feedback — always visible (not placeholder art) ──────────────────
if (player_inside) {
    // Soft blue glow
    draw_set_alpha(0.18);
    draw_set_color(make_color_rgb(80, 120, 220));
    draw_rectangle(x - 12, y - 12, x + 76, y + 76, false);
    draw_set_alpha(1);
    // "Safe" label
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(make_color_rgb(150, 190, 255));
    draw_text(x + 32, y - 6, "Safe");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_color(c_white);
draw_set_alpha(1);
