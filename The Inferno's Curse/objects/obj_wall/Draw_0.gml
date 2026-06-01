// ── Wall: Draw ───────────────────────────────────────────────────────────────
// Dimensions come from wall_w / wall_h set in Create (or overridden per instance).

// Fill
draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(x, y, x + wall_w, y + wall_h, false);

// Subtle highlight border to give the wall some visual depth
draw_set_color(make_color_rgb(110, 110, 110));
draw_rectangle(x, y, x + wall_w, y + wall_h, true);

draw_set_color(c_white); // reset after custom colour
