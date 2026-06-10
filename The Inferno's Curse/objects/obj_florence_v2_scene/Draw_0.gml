// =============================================================================
// obj_florence_v2_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Layer 1  grass base over the whole 48x32 world.
// Layer 2  THE ROAD NETWORK (scr_fv2_roads — roads before buildings, the city
//          skeleton): authentic cobble (spr_florence_road_cobble, falls back to
//          spr_florence_street until imported), plaza fields from the 16 plaza
//          variations, intersection tiles wherever two roads cross, and INNER
//          CITY WALLS — continuous void+art subwalls (spr_florence_thin_wall
//          at half scale over a black band) dividing the quarters along every
//          road's long edges (visual-only; collision is a future pass).
if (room != Room_florence_v2) exit;

var _g  = FV2_GRID;
var _rw = room_width, _rh = room_height;

// ── 1. grass base ───────────────────────────────────────────────────────────────
draw_set_color(make_color_rgb(74, 138, 48));
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);
for (var _gy = 0; _gy < _rh; _gy += 64)
    for (var _gx = 0; _gx < _rw; _gx += 64)
        draw_sprite(spr_florence_grass, 0, _gx, _gy);

// ── 1b. PACKED EARTH over the whole CITY INTERIOR (GAP 2: no grass inside the
//        walls — grass lives only outside). Roads/plazas pave over this next.
var _t_earth = asset_get_index("spr_florence_packed_earth");
if (_t_earth >= 0 && asset_get_type("spr_florence_packed_earth") == asset_sprite) {
    for (var _ey2 = 128; _ey2 < 1638; _ey2 += 64)
        for (var _ex2 = 320; _ex2 < 2538; _ex2 += 64)
            draw_sprite_part(_t_earth, 0, 0, 0, min(64, 2538 - _ex2), min(64, 1638 - _ey2), _ex2, _ey2);
}

// ── 2. roads ────────────────────────────────────────────────────────────────────
var _t_road = asset_get_index("spr_florence_road_cobble");
if (_t_road < 0 || asset_get_type("spr_florence_road_cobble") != asset_sprite) _t_road = spr_florence_street;
var _t_ints = asset_get_index("spr_florence_road_intersection");
if (_t_ints < 0 || asset_get_type("spr_florence_road_intersection") != asset_sprite) _t_ints = _t_road;

var _plaza = [spr_florence_plaza,     spr_florence_plaza_v2,  spr_florence_plaza_v3,  spr_florence_plaza_v4,
              spr_florence_plaza_v5,  spr_florence_plaza_v6,  spr_florence_plaza_v7,  spr_florence_plaza_v8,
              spr_florence_plaza_v9,  spr_florence_plaza_v10, spr_florence_plaza_v11, spr_florence_plaza_v12,
              spr_florence_plaza_v13, spr_florence_plaza_v14, spr_florence_plaza_v15, spr_florence_plaza_v16];

var _roads = scr_fv2_roads();
var _n = array_length(_roads);

// pass 1 — fill every rect, tile-snapped (plaza = deterministic variation pick)
for (var _i = 0; _i < _n; _i++) {
    var _r  = _roads[_i];
    var _x0 = round(_r[0]) * _g, _y0 = round(_r[1]) * _g;
    var _x1 = round(_r[2]) * _g, _y1 = round(_r[3]) * _g;
    if (_r[4] == 1) {
        // plazas: CONTINUOUS half-scale cobble base (the 16 medallion tiles
        // each carry their own grey base, so tiling them wall-to-wall read as
        // spaced dots) with a plaza medallion inset every few cells as a
        // decorative pavement rosette
        for (var _ty = _y0; _ty < _y1; _ty += 32)
            for (var _tx = _x0; _tx < _x1; _tx += 32)
                draw_sprite_ext(_t_road, 0, _tx, _ty, 0.5, 0.5, 0, c_white, 1);
        for (var _py = _y0; _py < _y1; _py += _g) {
            for (var _px = _x0; _px < _x1; _px += _g) {
                var _pi = (((_px div 64) * 7) + ((_py div 64) * 13)) mod 16;
                if ((((_px div 64) * 3) + ((_py div 64) * 5)) mod 7 == 0)
                    draw_sprite(_plaza[_pi], 0, _px, _py);
            }
        }
    } else {
        // roads at HALF SCALE (32px cobbles) — twice as fine, so a 2-cell road
        // reads as a narrow Florentine street, not a 3-stone highway (user fix 5)
        for (var _rty = _y0; _rty < _y1; _rty += 32) {
            for (var _rtx = _x0; _rtx < _x1; _rtx += 32) {
                draw_sprite_ext(_t_road, 0, _rtx, _rty, 0.5, 0.5, 0, c_white, 1);
            }
        }
    }
}

// pass 2 — intersection tiles wherever two ROAD rects overlap
for (var _a = 0; _a < _n; _a++) {
    if (_roads[_a][4] != 0) continue;
    for (var _b = _a + 1; _b < _n; _b++) {
        if (_roads[_b][4] != 0) continue;
        var _ox0 = max(round(_roads[_a][0]), round(_roads[_b][0])) * _g;
        var _oy0 = max(round(_roads[_a][1]), round(_roads[_b][1])) * _g;
        var _ox1 = min(round(_roads[_a][2]), round(_roads[_b][2])) * _g;
        var _oy1 = min(round(_roads[_a][3]), round(_roads[_b][3])) * _g;
        if (_ox1 <= _ox0 || _oy1 <= _oy0) continue;
        for (var _iy = _oy0; _iy < _oy1; _iy += 32)
            for (var _ix = _ox0; _ix < _ox1; _ix += 32)
                draw_sprite_ext(_t_ints, 0, _ix, _iy, 0.5, 0.5, 0, c_white, 1);
    }
}

// pass 3 — STREET SUBWALLS: the void+art standard at street scale. Each
// road's long edges get a CONTINUOUS thin wall: a black void underlay band
// with the 128x32 thin-wall tile running unbroken at half scale (64x16) —
// replaces the old per-tile curb slices that read as disconnected caps.
var _t_curb = asset_get_index("spr_florence_thin_wall");
if (_t_curb >= 0 && asset_get_type("spr_florence_thin_wall") == asset_sprite) {
    for (var _c = 0; _c < _n; _c++) {
        var _cr  = _roads[_c];
        if (_cr[4] != 0) continue;
        var _cx0 = round(_cr[0]) * _g, _cy0 = round(_cr[1]) * _g;
        var _cx1 = round(_cr[2]) * _g, _cy1 = round(_cr[3]) * _g;
        var _horiz = (_cx1 - _cx0) >= (_cy1 - _cy0);
        draw_set_color(c_black);
        if (_horiz) {
            draw_rectangle(_cx0, _cy0 - 2, _cx1, _cy0 + 16, false);
            draw_rectangle(_cx0, _cy1 - 16, _cx1, _cy1 + 2, false);
            for (var _ex = _cx0; _ex < _cx1; _ex += 64) {
                var _ew = min(128, (_cx1 - _ex) * 2);
                draw_sprite_part_ext(_t_curb, 0, 0, 0, _ew, 32, _ex, _cy0,      0.5, 0.5, c_white, 1);
                draw_sprite_part_ext(_t_curb, 0, 0, 0, _ew, 32, _ex, _cy1 - 16, 0.5, 0.5, c_white, 1);
            }
        } else {
            draw_rectangle(_cx0 - 2, _cy0, _cx0 + 16, _cy1, false);
            draw_rectangle(_cx1 - 16, _cy0, _cx1 + 2, _cy1, false);
            for (var _ey = _cy0; _ey < _cy1; _ey += 64) {
                var _eh = min(128, (_cy1 - _ey) * 2);
                draw_sprite_general(_t_curb, 0, 0, 0, _eh, 32, _cx0,      _ey + _eh * 0.5, 0.5, 0.5, 90, c_white, c_white, c_white, c_white, 1);
                draw_sprite_general(_t_curb, 0, 0, 0, _eh, 32, _cx1 - 16, _ey + _eh * 0.5, 0.5, 0.5, 90, c_white, c_white, c_white, c_white, 1);
            }
        }
        draw_set_color(c_white);
    }
}
draw_set_color(c_white);

// ── 3. CITY WALLS — stable-style black-void bands + stone texture + merlons,
//      gatehouses and towers on top (geometry = scr_fv2_walls, also collision)
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
scr_fv2_draw_walls(_corr);

// ── 4. THE ARNO (east band, flows south) — corruption water carried over:
//      forward → silty → slow → REVERSED at 75% → red and wrong at 100
scr_fv2_draw_arno(_corr);

// ── 5. street life + shrines react to corruption; torch/candle glow pass ───────
scr_fv2_corruption_sync();
scr_fv2_torch_glow();

// ── 6. the city itself dirties as Limbo deepens (50%+) ─────────────────────────
if (_corr >= 0.5) {
    draw_set_alpha(0.05 + 0.10 * ((_corr - 0.5) / 0.5));
    draw_set_color(make_color_rgb(40, 34, 26));
    draw_rectangle(0, 0, _rw, _rh, false);
    draw_set_alpha(1); draw_set_color(c_white);
}
