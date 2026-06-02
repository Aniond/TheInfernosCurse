// ── Wall: Draw ───────────────────────────────────────────────────────────────
// Boundary wall placeholder — only visible in debug mode.
// Collision is always active regardless of draw state.
if (!global.debug_mode) exit;

draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(x, y, x + wall_w, y + wall_h, false);
draw_set_color(make_color_rgb(110, 110, 110));
draw_rectangle(x, y, x + wall_w, y + wall_h, true);
draw_set_color(c_white);
