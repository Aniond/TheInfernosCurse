// =============================================================================
// obj_wall_stone — Draw Event
// =============================================================================
// Renders one stone block. Colour, breathing motion and cracking veins all
// scale with Limbo corruption (wall_corruption, 0-100).
//
// Geometry convention matches obj_wall: (x, y) is the top-left corner and the
// block extends wall_w to the right and wall_h down.

// ── Corruption percentage (clamped 0-100) ─────────────────────────────────────
var _corrupt = clamp(wall_corruption, 0, 100);

// ── Base colour shifts darker as corruption rises ─────────────────────────────
var _col;
if (_corrupt < 25) {
    _col = make_color_rgb(80, 80, 90);   // cold pale stone — the city as it was
} else if (_corrupt < 50) {
    _col = make_color_rgb(60, 60, 70);   // dimming
} else if (_corrupt < 75) {
    _col = make_color_rgb(40, 40, 50);   // grey going to slate
} else {
    _col = make_color_rgb(20, 20, 30);   // near-black, the stone almost void
}

// ── Breathing offset (only past 50% corruption) ───────────────────────────────
// A subtle sine sway makes the walls look like they're inhaling. The amplitude
// grows with corruption but stays small — unsettling, not cartoonish.
var _breathe = 0;
if (_corrupt > 50) {
    _breathe = sin(breathe_offset) * (_corrupt / 100) * 2;
}

// ── Draw the block ────────────────────────────────────────────────────────────
var _x1 = x + _breathe;
var _y1 = y + _breathe;
var _x2 = x + wall_w + _breathe;
var _y2 = y + wall_h + _breathe;

// Solid fill
draw_set_color(_col);
draw_rectangle(_x1, _y1, _x2, _y2, false);

// Faint highlight border for depth (lighter than the fill)
draw_set_color(merge_color(_col, c_white, 0.25));
draw_rectangle(_x1, _y1, _x2, _y2, true);

// ── Dark veins past 75% corruption ────────────────────────────────────────────
// Thin near-black lines crawl across the surface like cracks bleeding shadow.
if (_corrupt > 75) {
    draw_set_color(make_color_rgb(10, 0, 20));

    // Spacing scales with block size so big walls get more veins than small ones.
    var _step = 48;

    // Diagonal veins running top-left to bottom-right across the block.
    var _vx = _x1 + _step;
    while (_vx < _x2) {
        draw_line(_vx, _y1, _vx - wall_h, _y2);
        _vx += _step;
    }
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_color(c_white);
