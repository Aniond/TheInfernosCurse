// ── Player: Draw ────────────────────────────────────────────────────────────
// Placeholder rectangle until a sprite is assigned.

draw_set_color(c_white);
draw_rectangle(x - 16, y - 16, x + 16, y + 16, false);

// Tint placeholder darker as corruption rises
var _corrupt_tint = make_color_rgb(255, round(255 * (1 - corruption / 100)), round(255 * (1 - corruption / 100)));
draw_set_color(_corrupt_tint);
draw_rectangle(x - 14, y - 14, x + 14, y + 14, false);

draw_set_color(c_white); // always reset after custom colour
