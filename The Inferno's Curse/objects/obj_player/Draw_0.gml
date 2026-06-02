// ── Player: Draw ────────────────────────────────────────────────────────────
// Father Benedetto — drawn as a robed priest figure from primitives until a real
// sprite exists. Style matches obj_npc_base (body + head silhouette) but reads
// as clergy: dark cassock, pale face, white collar, small gold cross.
// The cassock bleeds toward sickly red as the player's own corruption rises.

var _cf = clamp(corruption / 100, 0, 1);

// ── Cassock (robe body) — taller than wide ────────────────────────────────────
var _robe = merge_color(
    make_color_rgb(35, 35, 45),   // near-black clergy robe
    make_color_rgb(70, 12, 12),   // corrupted blood-dark
    _cf
);
draw_set_color(_robe);
draw_rectangle(x - 12, y - 18, x + 12, y + 28, false);

// Mantle / shoulders — slightly darker band across the top of the robe
draw_set_color(merge_color(_robe, c_black, 0.35));
draw_rectangle(x - 16, y - 18, x + 16, y - 6, false);

// ── Head (pale face) ──────────────────────────────────────────────────────────
var _skin = merge_color(make_color_rgb(220, 200, 170),
                        make_color_rgb(120, 110, 110), _cf);
draw_set_color(_skin);
draw_circle(x, y - 26, 8, false);

// ── White clerical collar ─────────────────────────────────────────────────────
draw_set_color(c_white);
draw_rectangle(x - 6, y - 18, x + 6, y - 14, false);

// ── Small gold pectoral cross on the chest ────────────────────────────────────
draw_set_color(make_color_rgb(205, 180, 120));
draw_rectangle(x - 1, y - 10, x + 1, y + 6, false); // vertical bar
draw_rectangle(x - 4, y - 6, x + 4, y - 4, false);  // horizontal bar

// ── Reset ─────────────────────────────────────────────────────────────────────
draw_set_color(c_white);
