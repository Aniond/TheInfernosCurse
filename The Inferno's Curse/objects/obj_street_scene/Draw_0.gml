// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild. Layers (bottom to top):
//   1) GROUND  — seamless grass over the whole room.
//   1b) STREET — cobblestone market street band across the middle (E-W),
//                replaces grass in that zone only; buildings/props draw on top.
//   2) ARNO    — seamless scrolling water tile (PixelLab Wang fill) across the
//                lower third, stone banks on both edges, and bridges connecting.
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

// ── 1b. MARKET STREET: cobblestone piazza — middle half of room (E-W) ──────────
// Room layout: top quarter (y 0–800) = buildings + grass;
//              middle half (y 800–2400) = cobblestone piazza / market square;
//              bottom quarter (y 2400–3200) = river bank + Arno.
// 1600px = 25 × 64px tile rows, spans wall-to-wall inside the city.
var _st_y0 = 800;
var _st_y1 = 2400;
var _sw    = sprite_get_width(spr_florence_street);    // 64
var _sh    = sprite_get_height(spr_florence_street);   // 64
for (var _sy = _st_y0; _sy < _st_y1; _sy += _sh) {
    for (var _sx = _ix0; _sx < _ix1; _sx += _sw) {
        draw_sprite(spr_florence_street, 0, _sx, _sy);
    }
}

// ── 2. ARNO river (interior only) ─────────────────────────────────────────────
// Geometry is OWNED by the globals set in obj_game_manager — obj_player collision
// routes the player over the same bridge spans, so visuals MUST read these or the
// water and the walkable crossings drift apart.
var _ry1     = global.river_y1;        // 2704 — bottom quarter of room
var _ry2     = global.river_y2;        // 2896  (band = 192px = 3 water tiles)
var _bridges = global.river_bridges;   // [[x0,x1], ...] walkable crossings
var _bankh   = 22;                     // stone bank thickness

// water surface — seamless scrolling tile that DEGRADES with Limbo corruption,
// the single axis that drives everything. Same source the walls breathe on;
// staged, not a linear fade:
//   0-25%   murky grey-green, normal forward current — just a river
//   25-50%  silty brown — something upstream, maybe. probably fine
//   50-75%  darker and slower — wrong somehow, hard to say why
//   75-100% the current reverses — by 100% it runs backward at full flow
//   100%    red, and flowing the wrong way (animated, not still)
var _ww   = sprite_get_width(spr_florence_water);    // 64
var _wh   = sprite_get_height(spr_florence_water);   // 64
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);   // 0..1

// flow speed (px/sec; sign = direction). EVERY stage stays animated — the speed
// never reaches zero: forward & easing → slower but still moving → flips from
// +5 to -5 at 75% and reverses, building to full backward flow at 100%.
var _spd;
if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);  // forward, easing
else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);  // slower, floored at +5
else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);  // flips, reverses to -16

var _scroll = (current_time / 1000 * _spd) mod _ww;
for (var _wy = _ry1; _wy < _ry2; _wy += _wh) {
    for (var _wx = _ix0 - _ww + _scroll; _wx < _ix1; _wx += _ww) {
        draw_sprite(spr_florence_water, 0, _wx, _wy);
    }
}

// colour bleed — overlay grows with corruption: clean until 25%, then silty
// brown → darker murk → blood red, climbing to near-opaque red at 100%.
var _a;
if (_corr < 0.25)      _a = 0;
else if (_corr < 0.50) _a = lerp(0,    0.70, (_corr - 0.25) / 0.25);
else                   _a = lerp(0.70, 0.92, (_corr - 0.50) / 0.50);
if (_a > 0) {
    var _oc;
    if (_corr < 0.50)      _oc = make_color_rgb(150, 112, 62);                                                          // silty brown
    else if (_corr < 0.75) _oc = merge_color(make_color_rgb(150,112,62), make_color_rgb(84,60,42),  (_corr-0.50)/0.25); // darker
    else if (_corr < 0.85) _oc = make_color_rgb(84, 60, 42);                                                            // dark murk
    else                   _oc = merge_color(make_color_rgb(84,60,42),    make_color_rgb(150,30,26), (_corr-0.85)/0.15); // -> red
    draw_set_alpha(_a);
    draw_set_color(_oc);
    draw_rectangle(_ix0, _ry1, _ix1, _ry2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// stone banks on north & south edges (full width; bridge decks overlay them)
var _bank   = make_color_rgb(150, 140, 118);
var _bank_d = make_color_rgb(108, 98, 80);
draw_set_color(_bank);
draw_rectangle(_ix0, _ry1 - _bankh, _ix1, _ry1,          false);   // north bank
draw_rectangle(_ix0, _ry2,          _ix1, _ry2 + _bankh, false);   // south bank
draw_set_color(_bank_d);                                           // waterline shadow
draw_rectangle(_ix0, _ry1 - 4, _ix1, _ry1,     false);
draw_rectangle(_ix0, _ry2,     _ix1, _ry2 + 4, false);
draw_set_color(c_white);

// ── bridges: cobblestone-tiled stone deck + parapets ───────────────────────────
var _bdy0   = _ry1 - _bankh;       // deck top    (flush with north bank)
var _bdy1   = _ry2 + _bankh;       // deck bottom (flush with south bank)
var _rail   = make_color_rgb(120, 110, 92);
var _rail_l = make_color_rgb(170, 160, 140);
var _bsw    = sprite_get_width(spr_florence_street);    // 64
var _bsh    = sprite_get_height(spr_florence_street);   // 64
for (var _b = 0; _b < array_length(_bridges); _b++) {
    var _bx0 = _bridges[_b][0];
    var _bx1 = _bridges[_b][1];
    // stone deck — cobblestone tiles clipped to exact bridge bounds
    draw_set_color(c_white);
    for (var _btile_y = _bdy0; _btile_y < _bdy1; _btile_y += _bsh) {
        for (var _btile_x = _bx0; _btile_x < _bx1; _btile_x += _bsw) {
            draw_sprite_part(spr_florence_street, 0,
                0, 0,
                min(_bsw, _bx1 - _btile_x),
                min(_bsh, _bdy1 - _btile_y),
                _btile_x, _btile_y);
        }
    }
    // stone parapets along both long sides
    draw_set_color(_rail);
    draw_rectangle(_bx0,      _bdy0, _bx0 + 12, _bdy1, false);   // west parapet
    draw_rectangle(_bx1 - 12, _bdy0, _bx1,      _bdy1, false);   // east parapet
    draw_set_color(_rail_l);
    draw_rectangle(_bx0,     _bdy0, _bx0 + 4, _bdy1, false);     // parapet highlights
    draw_rectangle(_bx1 - 4, _bdy0, _bx1,     _bdy1, false);
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
