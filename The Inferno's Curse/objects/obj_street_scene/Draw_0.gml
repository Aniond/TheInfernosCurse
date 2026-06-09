// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild. Layers (bottom to top):
//   1) GROUND  — seamless grass over the whole room.
//   1b) STREET — cobblestone road, 3 tiles tall (192px), CENTRED vertically
//                (y 928–1120). Replaces grass in that band only.
//   1c) PARK   — civic green between the street and the river: an open paved
//                piazza (the market square) framed by garden beds + stone benches,
//                with cypress trees (room-builder objects) standing over it.
//   2) ARNO    — seamless scrolling water tile (PixelLab Wang fill) BELOW the park,
//                stone banks on both edges, and bridges connecting north↔south.
//   3) WALLS   — SEAMLESS city wall ring (drawn procedurally so it connects on
//                all four sides), crenellated, with gate openings; the gate
//                sprite is dropped into the north & south openings.
//
// Depth 160: behind the player/characters (depth 100). Roads, buildings, props
// get layered on top of this from here. NOTHING else this step.
// =============================================================================
if (room != Room_florence) exit;

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

// ── MERCATO VECCHIO — cobblestone ground over the NORTH market zone (y 0..640) ─
// 16 cobble variations, deterministic per-cell pick (stable, no per-frame random).
var _cob = [spr_florence_plaza,     spr_florence_plaza_v2,  spr_florence_plaza_v3,  spr_florence_plaza_v4,
            spr_florence_plaza_v5,  spr_florence_plaza_v6,  spr_florence_plaza_v7,  spr_florence_plaza_v8,
            spr_florence_plaza_v9,  spr_florence_plaza_v10, spr_florence_plaza_v11, spr_florence_plaza_v12,
            spr_florence_plaza_v13, spr_florence_plaza_v14, spr_florence_plaza_v15, spr_florence_plaza_v16];
for (var _czy = 0; _czy < MERCATO_ZONE_Y1; _czy += 64) {
    for (var _czx = 0; _czx < _rw; _czx += 64) {
        var _ci = (((_czx div 64) * 7) + ((_czy div 64) * 13)) mod 16;
        draw_sprite(_cob[_ci], 0, _czx, _czy);
    }
}
// (Market items are draggable obj_mercato_prop objects placed by the room-builder.)

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

// ── 1b. MARKET STREET: cobblestone road — 3 tiles tall, CENTRED vertically ─────
// Shrunk 2048 world (centre y = 1024). Zones, top → bottom:
//   buildings + grass      y   56–928
//   cobblestone street     y  928–1120   (3 × 64px tiles, centred on the room)
//   park / piazza          y 1120–1514   (drawn in 1c, below)
//   river bank + Arno      y 1514–1728
//   south grass + approach y 1728–1992
var _st_y0 = 928;                                       // 1024 - 96  (3 tiles up)
var _st_y1 = 1120;                                      // 1024 + 96  (3 tiles total)
var _sw    = sprite_get_width(spr_florence_street);    // 64
var _sh    = sprite_get_height(spr_florence_street);   // 64
for (var _sy = _st_y0; _sy < _st_y1; _sy += _sh) {
    for (var _sx = _ix0; _sx < _ix1; _sx += _sw) {
        draw_sprite(spr_florence_street, 0, _sx, _sy);
    }
}

// ── 1c. PARK / PIAZZA — civic green between the street and the river ────────────
// Grass is already laid as the base; this overlays an open paved piazza (the
// market square), planted garden beds, and stone benches. Cypress trees are placed
// as room-builder OBJECTS (so they depth-sort with the player) — see the layout.
// Self-contained: reads global.river_y1 so the park always stops short of the bank.
var _pk_y0 = _st_y1 + 30;                               // 1150 — grass margin below the street
var _pk_y1 = global.river_y1 - 22 - 34;                 // ≈1480 — grass margin above the river bank

// piazza paving — warm sandstone flagstones, centred between the two bridges so it
// feeds straight onto both crossings to the south.
var _pz_x0 = 600, _pz_x1 = 1448;
var _pz_y0 = _pk_y0, _pz_y1 = _pk_y1;
var _flag   = make_color_rgb(196, 180, 150);
var _flag_d = make_color_rgb(150, 134, 104);
var _flag_l = make_color_rgb(214, 200, 172);
draw_set_color(_flag);
draw_rectangle(_pz_x0, _pz_y0, _pz_x1, _pz_y1, false);
draw_set_color(_flag_d);                                                  // flagstone seams
for (var _fx = _pz_x0; _fx <= _pz_x1; _fx += 64) draw_line(_fx, _pz_y0, _fx, _pz_y1);
for (var _fy = _pz_y0; _fy <= _pz_y1; _fy += 64) draw_line(_pz_x0, _fy, _pz_x1, _fy);
draw_set_color(_flag_l);                                                  // raised kerb (light top/left)
draw_rectangle(_pz_x0, _pz_y0, _pz_x1, _pz_y0 + 5, false);
draw_rectangle(_pz_x0, _pz_y0, _pz_x0 + 5, _pz_y1, false);
draw_set_color(_flag_d);                                                  // kerb (dark bottom/right)
draw_rectangle(_pz_x0, _pz_y1 - 5, _pz_x1, _pz_y1, false);
draw_rectangle(_pz_x1 - 5, _pz_y0, _pz_x1, _pz_y1, false);
var _pcx = (_pz_x0 + _pz_x1) * 0.5;                                        // centre medallion
var _pcy = (_pz_y0 + _pz_y1) * 0.5;
draw_set_color(_flag_d);
draw_circle(_pcx, _pcy, 86, true);
draw_circle(_pcx, _pcy, 84, true);
draw_set_color(_flag_l);
draw_circle(_pcx, _pcy, 40, true);
draw_set_color(c_white);

// ── GRASS PATCH east of the Giardino delle Rose ───────────────────────────────
// Cleanup: convert the tan piazza flagstones immediately east of the rose garden
// back to grass (requested x:550–1100, y:1300–1600). Clipped to the piazza's own
// bounds AND kept off the garden — the left edge is pinned at x≥600 (the garden's
// east paving edge) so no garden tile is ever overdrawn. Painted here, after the
// piazza paving but before the garden / benches / river, so all of those redraw
// cleanly on top. Tiles are snapped to the 0,0 grass grid to seam-match the base
// ground laid in section 1.
var _gp_x0 = max(600, _pz_x0);          // x≥600 keeps the garden untouched
var _gp_x1 = min(1100, _pz_x1);
var _gp_y0 = max(1300, _pz_y0);
var _gp_y1 = min(1600, _pz_y1);         // piazza ends ~1480, so this clamps there
if (_gp_x1 > _gp_x0 && _gp_y1 > _gp_y0) {
    draw_set_color(c_white);
    var _gpw = sprite_get_width(spr_florence_grass);     // 64
    var _gph = sprite_get_height(spr_florence_grass);    // 64
    var _gcx = floor(_gp_x0 / _gpw) * _gpw;              // snap to the base-grass grid
    var _gcy = floor(_gp_y0 / _gph) * _gph;
    for (var _gty = _gcy; _gty < _gp_y1; _gty += _gph) {
        for (var _gtx = _gcx; _gtx < _gp_x1; _gtx += _gpw) {
            var _csx = max(_gtx, _gp_x0);                // clip each tile to the patch rect
            var _csy = max(_gty, _gp_y0);
            var _cex = min(_gtx + _gpw, _gp_x1);
            var _cey = min(_gty + _gph, _gp_y1);
            draw_sprite_part(spr_florence_grass, 0,
                _csx - _gtx, _csy - _gty,                // sub-image source offset
                _cex - _csx, _cey - _csy,                // clipped size
                _csx, _csy);
        }
    }
    draw_set_color(c_white);
}

// ── GIARDINO DELLE ROSE — formal box-hedge rose parterre (left park) ───────────
// Reference: refrences/rosegarden.png. A stone-paving ring frames four boxwood-
// hedged PINK-rose quadrants split by a gravel cross-path, with a circular stone
// court at the centre for the fountain (obj_garden_fountain, placed by the room
// builder at the garden centre). Round topiary balls + flower clusters dot the
// grass just outside. Drawn at depth 160 (under the player & the fountain). Visual
// only — no collision yet. Move/resize via _rg_cx/_rg_cy and the half-extents.
var _rg_cx = global.garden_cx, _rg_cy = global.garden_cy;   // geometry OWNED by obj_game_manager
var _rg_hw = global.garden_hw, _rg_hh = global.garden_hh;   // so the hedge collision matches exactly
var _rg_x0 = _rg_cx - _rg_hw, _rg_y0 = _rg_cy - _rg_hh;
var _rg_x1 = _rg_cx + _rg_hw, _rg_y1 = _rg_cy + _rg_hh;

// palette
var _rg_pave   = make_color_rgb(201, 184, 153);   // outer stone walkway
var _rg_pave_d = make_color_rgb(156, 139, 109);
var _rg_pave_l = make_color_rgb(219, 205, 176);
var _rg_grav   = make_color_rgb(210, 196, 167);   // gravel cross-paths / court
var _rg_grav_d = make_color_rgb(180, 164, 135);
var _rg_hed    = make_color_rgb(80, 122, 52);     // boxwood hedge
var _rg_hed_l  = make_color_rgb(120, 166, 86);
var _rg_hed_d  = make_color_rgb(52, 86, 38);
var _rg_soil   = make_color_rgb(88, 60, 40);

// metrics
var _rg_wt  = global.garden_wt;    // outer paving ring thickness (shared w/ collision)
var _rg_cph = global.garden_cph;   // cross-path half width        (shared w/ collision)
var _rg_qht = 16;    // per-quadrant hedge border thickness
var _rg_cr  = 54;    // central fountain court radius

// 1) outer stone walkway — fill the whole square; the inner field is overdrawn next
draw_set_color(_rg_pave);
draw_rectangle(_rg_x0, _rg_y0, _rg_x1, _rg_y1, false);
draw_set_color(_rg_pave_d);                                            // block seams
for (var _rgx = _rg_x0; _rgx <= _rg_x1; _rgx += 32) draw_line(_rgx, _rg_y0, _rgx, _rg_y1);
for (var _rgy = _rg_y0; _rgy <= _rg_y1; _rgy += 32) draw_line(_rg_x0, _rgy, _rg_x1, _rgy);
draw_set_color(_rg_pave_l);                                            // light top/left kerb
draw_rectangle(_rg_x0, _rg_y0, _rg_x1, _rg_y0 + 4, false);
draw_rectangle(_rg_x0, _rg_y0, _rg_x0 + 4, _rg_y1, false);
draw_set_color(_rg_pave_d);                                            // dark bottom/right kerb
draw_rectangle(_rg_x0, _rg_y1 - 4, _rg_x1, _rg_y1, false);
draw_rectangle(_rg_x1 - 4, _rg_y0, _rg_x1, _rg_y1, false);

// inner field (inside the paving ring) — gravel base; the cross-paths show through
var _rg_fx0 = _rg_x0 + _rg_wt, _rg_fy0 = _rg_y0 + _rg_wt;
var _rg_fx1 = _rg_x1 - _rg_wt, _rg_fy1 = _rg_y1 - _rg_wt;
draw_set_color(_rg_grav);
draw_rectangle(_rg_fx0, _rg_fy0, _rg_fx1, _rg_fy1, false);
draw_set_color(_rg_grav_d);                                            // gravel speckle
for (var _rg_sy = _rg_fy0 + 5; _rg_sy < _rg_fy1; _rg_sy += 10)
    for (var _rg_sx = _rg_fx0 + 5 + ((_rg_sy div 10) mod 2) * 6; _rg_sx < _rg_fx1; _rg_sx += 13)
        draw_rectangle(_rg_sx, _rg_sy, _rg_sx + 1, _rg_sy + 1, false);
draw_set_color(c_white);

// 2) four hedge-framed pink-rose quadrants (corners of the field; cross-path between)
var _rg_quads = [
    [_rg_fx0,           _rg_fy0,           _rg_cx - _rg_cph, _rg_cy - _rg_cph],   // NW
    [_rg_cx + _rg_cph,  _rg_fy0,           _rg_fx1,          _rg_cy - _rg_cph],   // NE
    [_rg_fx0,           _rg_cy + _rg_cph,  _rg_cx - _rg_cph, _rg_fy1],            // SW
    [_rg_cx + _rg_cph,  _rg_cy + _rg_cph,  _rg_fx1,          _rg_fy1],            // SE
];
var _rg_pinks = [spr_tile_rose_pink, spr_tile_rose_pink_v2, spr_tile_rose_pink_v3, spr_tile_rose_pink_v4];
for (var _rg_q = 0; _rg_q < 4; _rg_q++) {
    var _qx0 = _rg_quads[_rg_q][0], _qy0 = _rg_quads[_rg_q][1];
    var _qx1 = _rg_quads[_rg_q][2], _qy1 = _rg_quads[_rg_q][3];
    // boxwood border
    draw_set_color(_rg_hed);
    draw_rectangle(_qx0, _qy0, _qx1, _qy1, false);
    draw_set_color(_rg_hed_l);
    draw_rectangle(_qx0, _qy0, _qx1, _qy0 + 4, false);
    draw_rectangle(_qx0, _qy0, _qx0 + 4, _qy1, false);
    draw_set_color(_rg_hed_d);
    draw_rectangle(_qx0, _qy1 - 4, _qx1, _qy1, false);
    draw_rectangle(_qx1 - 4, _qy0, _qx1, _qy1, false);
    // soil bed inside the border
    var _bx0 = _qx0 + _rg_qht, _by0 = _qy0 + _rg_qht;
    var _bx1 = _qx1 - _rg_qht, _by1 = _qy1 - _rg_qht;
    draw_set_color(_rg_soil);
    draw_rectangle(_bx0, _by0, _bx1, _by1, false);
    draw_set_color(c_white);
    // pink roses on a jittered grid (deterministic — no per-frame random())
    var _rg_i = 0;
    for (var _ry = _by0 - 4; _ry < _by1 - 6; _ry += 28) {
        for (var _rx = _bx0 - 4; _rx < _bx1 - 6; _rx += 28) {
            var _jx = ((_rg_i * 7)  mod 9) - 4;
            var _jy = ((_rg_i * 11) mod 7) - 3;
            draw_sprite_ext(_rg_pinks[(_rg_i + _rg_q) mod 4], 0, _rx + _jx, _ry + _jy, 0.6, 0.6, 0, c_white, 1);
            _rg_i++;
        }
    }
}

// 3) central stone court for the fountain (the obj_garden_fountain sits on this)
draw_set_color(_rg_pave);
draw_circle(_rg_cx, _rg_cy, _rg_cr, false);
draw_set_color(_rg_pave_l);
draw_circle(_rg_cx, _rg_cy, _rg_cr, true);
draw_set_color(_rg_pave_d);
draw_circle(_rg_cx, _rg_cy, _rg_cr - 3, true);
draw_set_color(c_white);

// 4) round topiary balls on the grass at the four outer corners
var _rg_top = [
    [_rg_x0 - 6, _rg_y0 - 6], [_rg_x1 + 6, _rg_y0 - 6],
    [_rg_x0 - 6, _rg_y1 + 6], [_rg_x1 + 6, _rg_y1 + 6],
];
for (var _rg_t = 0; _rg_t < 4; _rg_t++) {
    var _tcx = _rg_top[_rg_t][0], _tcy = _rg_top[_rg_t][1];
    draw_set_color(_rg_hed_d);
    draw_circle(_tcx + 3, _tcy + 4, 24, false);     // shadow
    draw_set_color(_rg_hed);
    draw_circle(_tcx, _tcy, 24, false);
    draw_set_color(_rg_hed_l);
    draw_circle(_tcx - 6, _tcy - 7, 10, false);     // highlight
}
draw_set_color(c_white);

// 5) small flower clusters (blue / white) scattered on the grass along the sides
var _rg_acc = [
    [_rg_x0 - 22, _rg_cy - 60], [_rg_x0 - 22, _rg_cy + 60],   // west grass
    [_rg_x1 + 22, _rg_cy - 60], [_rg_x1 + 22, _rg_cy + 60],   // east grass
    [_rg_cx - 70, _rg_y0 - 20], [_rg_cx + 70, _rg_y0 - 20],   // north grass
];
for (var _rg_a = 0; _rg_a < array_length(_rg_acc); _rg_a++) {
    var _acx = _rg_acc[_rg_a][0], _acy = _rg_acc[_rg_a][1];
    draw_set_color((_rg_a mod 2 == 0) ? make_color_rgb(120, 130, 200) : make_color_rgb(238, 238, 244));
    draw_circle(_acx,     _acy,     3, false);
    draw_circle(_acx - 5, _acy + 4, 2, false);
    draw_circle(_acx + 5, _acy + 3, 2, false);
    draw_circle(_acx,     _acy + 6, 2, false);
}
draw_set_color(c_white);

// stone benches — REMOVED (piazza cleanup). The 6 procedurally-drawn grey stone
// benches that dressed the piazza edges/medallion were taken out per request; the
// piazza now reads cleaner and the new grass patch is unobstructed.

// ── 2. ARNO river (interior only) ─────────────────────────────────────────────
// Geometry is OWNED by the globals set in obj_game_manager — obj_player collision
// routes the player over the same bridge spans, so visuals MUST read these or the
// water and the walkable crossings drift apart.
var _ry1     = global.river_y1;        // 1536 — below the park
var _ry2     = global.river_y2;        // 1728  (band = 192px = 3 water tiles)
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

    // WEST crossing (below the market) = the PONTE VECCHIO — one sprite stretched to
    // the deck bounds. This is the walkable ENTRANCE to Room_ponte_vecchio (the
    // transition trigger sits on this deck, obj_game_manager). The old EAST "brick
    // bridge" was removed (river_bridges holds only this crossing now), so it no
    // longer draws here and that span is plain river — water + bank rocks — again.
    if (_bx0 < 1000) {
        draw_sprite_ext(spr_ponte_vecchio, 0, _bx0, _bdy0,
            (_bx1 - _bx0) / sprite_get_width(spr_ponte_vecchio),
            (_bdy1 - _bdy0) / sprite_get_height(spr_ponte_vecchio),
            0, c_white, 1);
        continue;
    }

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
    // Stone railings along both long sides — dark gothic balustrade ROTATED 90°
    // so it runs NORTH–SOUTH along the crossing, tiled down each edge over a thin
    // shadow base. Leaves an open central channel. (Visual only — the river band
    // handles blocking; rails now also carry matching obj_wall collision (obj_game_manager).
    draw_set_color(_rail);
    draw_rectangle(_bx0,     _bdy0, _bx0 + 6,  _bdy1, false);    // west shadow base
    draw_rectangle(_bx1 - 6, _bdy0, _bx1,      _bdy1, false);    // east shadow base
    draw_set_color(c_white);
    // Origin is top-left, so a 90°-CCW tile pinned at (px, py+seg) fills the
    // screen cell (px..px+64) x (py..py+seg).
    var _rsz   = sprite_get_width(spr_bridge_railing);   // 64 (square)
    var _ryt   = 0.5;                                     // rail thickness scale - 50% (thinner balustrade)
    var _rspan = _bdy1 - _bdy0;                           // deck length (N–S)
    var _rn    = max(1, round(_rspan / _rsz));            // tiles down each side
    var _rseg  = _rspan / _rn;                            // exact segment length
    var _rxs   = _rseg / _rsz;                            // x-scale -> exact N–S fit
    for (var _ri = 0; _ri < _rn; _ri++) {
        var _rty = _bdy0 + _ri * _rseg;
        draw_sprite_ext(spr_bridge_railing, 0, _bx0,             _rty + _rseg, _rxs, _ryt, 90, c_white, 1);  // west rail (flush left)
        draw_sprite_ext(spr_bridge_railing, 0, _bx1 - _rsz*_ryt, _rty + _rseg, _rxs, _ryt, 90, c_white, 1);  // east rail (flush right)
    }
}
draw_set_color(c_white);

// ── stony water-bed shingle lining both banks ──────────────────────────────────
// Not one tidy row but a dense BAND of small pebbles, like a shallow river shingle:
// packed on the bank, thickest at the waterline, thinning into the clear shallows.
// Several overlapping rows per bank with a per-column stagger so it never reads as
// a grid; the inner rows dip into the water at reduced alpha (half-submerged look).
// Gapless except at the two bridges; bank bands only — no mid-river stones. The
// invisible obj_wall band (obj_game_manager) sits directly behind this shingle.
// ONE row of small wet stones per bank, flush at the water edge and sitting just
// inside the waterline (in the water, not on the dry bank). Dense horizontal
// overlap = a continuous boundary line; gap only at the bridges. The invisible
// obj_wall band (obj_game_manager) covers the water between these two rows, so
// the rows read as the impassable edge.
var _stone_s    = 0.42;                                            // small pebbles (~27px)
var _stone_h0   = sprite_get_height(spr_river_stone);             // 64
var _sdraw      = sprite_get_width(spr_river_stone) * _stone_s;    // ~27 px drawn width
var _stone_step = 16;                                             // heavy overlap = no seams/stripes
var _bridge_pad = -16;                                            // rocks run right up to (and just under) the deck edge
var _subcol     = make_color_rgb(96, 120, 112);                  // murky shallow-water tint
var _col_stone  = merge_color(c_white, _subcol, 0.10);           // faintly wet
var _north_y    = _ry1 + 6 - (_stone_h0 * _stone_s) * 0.5;        // just inside the north waterline
var _south_y    = _ry2 - 6 - (_stone_h0 * _stone_s) * 0.5;        // just inside the south waterline

for (var _stx = _ix0; _stx <= _ix1 - _sdraw; _stx += _stone_step) {
    // skip pebbles that would land on (or right at) a bridge deck — gap only there
    var _on_bridge = false;
    for (var _bi = 0; _bi < array_length(_bridges); _bi++) {
        if (_stx + _sdraw + _bridge_pad > _bridges[_bi][0] && _stx - _bridge_pad < _bridges[_bi][1]) { _on_bridge = true; break; }
    }
    if (_on_bridge) continue;
    draw_sprite_ext(spr_river_stone, 0, _stx, _north_y, _stone_s, _stone_s, 0, _col_stone, 1);   // north row
    draw_sprite_ext(spr_river_stone, 0, _stx, _south_y, _stone_s, _stone_s, 0, _col_stone, 1);   // south row
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
