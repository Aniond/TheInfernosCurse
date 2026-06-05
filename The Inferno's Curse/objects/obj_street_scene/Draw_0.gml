// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild. Layers (bottom to top):
//   1) GROUND  — seamless grass over the whole room.
//   2) ARNO    — river band across the lower third + banks (interior only).
//   3) WALLS   — SEAMLESS city wall ring (drawn procedurally so it connects on
//                all four sides), crenellated, with gate openings; the gate
//                sprite is dropped into the north & south openings.
//
// Depth 160: behind the player/characters (depth 100). Roads, buildings, props
// get layered on top of this from here. NOTHING else this step.
// =============================================================================
if (room != Room1) exit;

var _rw = room_width;
var _rh = room_height;

// ── 1. GROUND: seamless grass ─────────────────────────────────────────────────
draw_set_color(make_color_rgb(74, 138, 48));          // solid base (also no smear)
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);
var _gw = sprite_get_width(spr_florence_grass);       // 64
var _gh = sprite_get_height(spr_florence_grass);      // 64
for (var _gy = 0; _gy < _rh; _gy += _gh) {
    for (var _gx = 0; _gx < _rw; _gx += _gw) {
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}

// ── wall + interior metrics ───────────────────────────────────────────────────
var _wt   = 56;                 // wall thickness
var _ix0  = _wt;                // interior left edge
var _ix1  = _rw - _wt;          // interior right edge
var _cx   = _rw * 0.5;
var _cy   = _rh * 0.5;
var _gap  = 140;                // gate opening width
var _gx0  = _cx - _gap * 0.5;   // N/S gate gap (x range)
var _gx1  = _cx + _gap * 0.5;
var _gy0  = _cy - _gap * 0.5;   // W/E gate gap (y range)
var _gy1  = _cy + _gap * 0.5;

// ── 2. ARNO river across the lower third (interior only) ──────────────────────
var _ry1 = 2360;
var _ry2 = 2660;
// grassy banks
draw_set_color(make_color_rgb(120, 150, 70));
draw_rectangle(_ix0, _ry1 - 16, _ix1, _ry1,      false);
draw_rectangle(_ix0, _ry2,      _ix1, _ry2 + 16, false);
// water body
draw_set_color(make_color_rgb(38, 86, 128));
draw_rectangle(_ix0, _ry1, _ix1, _ry2, false);
// flowing shimmer (scrolls with time, no Step needed)
var _flow = (current_time / 1000 * 20) mod 48;
draw_set_color(make_color_rgb(72, 130, 172));
for (var _sx = _ix0 - 48 + _flow; _sx < _ix1; _sx += 48) {
    draw_rectangle(max(_ix0, _sx),      _ry1 + 28, min(_ix1, _sx + 22), _ry1 + 32, false);
    draw_rectangle(max(_ix0, _sx + 12), _ry2 - 44, min(_ix1, _sx + 34), _ry2 - 40, false);
}
draw_set_color(c_white);

// ── 3. CITY WALL ring (seamless, procedural) + gates ──────────────────────────
var _stone   = make_color_rgb(122, 118, 106);
var _stone_d = make_color_rgb(84, 80, 70);
var _stone_l = make_color_rgb(154, 150, 138);

// Stone bands — each side drawn as solid rectangles, split around its gate gap.
draw_set_color(_stone);
// north (top)
draw_rectangle(0,   0, _gx0, _wt, false);
draw_rectangle(_gx1, 0, _rw, _wt, false);
// south (bottom)
draw_rectangle(0,   _rh - _wt, _gx0, _rh, false);
draw_rectangle(_gx1, _rh - _wt, _rw, _rh, false);
// west (left)
draw_rectangle(0, 0,   _wt, _gy0, false);
draw_rectangle(0, _gy1, _wt, _rh, false);
// east (right)
draw_rectangle(_rw - _wt, 0,   _rw, _gy0, false);
draw_rectangle(_rw - _wt, _gy1, _rw, _rh, false);

// Outer highlight + inner shadow for a little depth.
draw_set_color(_stone_l);
draw_rectangle(0, 0, _rw, 5, false);                       // north outer
draw_rectangle(0, 0, 5, _rh, false);                       // west outer
draw_set_color(_stone_d);
draw_rectangle(0, _wt - 6, _rw, _wt, false);               // north inner
draw_rectangle(0, _rh - _wt, _rw, _rh - _wt + 6, false);   // south inner
draw_rectangle(_wt - 6, 0, _wt, _rh, false);               // west inner
draw_rectangle(_rw - _wt, 0, _rw - _wt + 6, _rh, false);   // east inner
draw_set_color(c_white);

// Crenellations (merlons) along the inner edge — stone teeth into the city.
draw_set_color(_stone);
var _ms = 48;     // merlon spacing
var _mw = 24;     // merlon width
var _md = 12;     // depth into city
// north & south
for (var _mx = 6; _mx < _rw - _mw; _mx += _ms) {
    if (_mx + _mw > _gx0 && _mx < _gx1) continue;          // skip gate gap
    draw_rectangle(_mx, _wt,        _mx + _mw, _wt + _md,        false);   // north
    draw_rectangle(_mx, _rh - _wt - _md, _mx + _mw, _rh - _wt,   false);   // south
}
// west & east
for (var _my = 6; _my < _rh - _mw; _my += _ms) {
    if (_my + _mw > _gy0 && _my < _gy1) continue;          // skip gate gap
    draw_rectangle(_wt,        _my, _wt + _md,        _my + _mw, false);   // west
    draw_rectangle(_rw - _wt - _md, _my, _rw - _wt,   _my + _mw, false);   // east
}
draw_set_color(c_white);

// Gate sprite (128x64) dropped into the north & south openings.
draw_sprite(spr_florence_gate, 0, _cx - 64, 0);            // north gate
draw_sprite(spr_florence_gate, 0, _cx - 64, _rh - 64);     // south gate
