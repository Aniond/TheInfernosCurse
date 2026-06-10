// =============================================================================
// obj_florence_v2_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Layer 1  grass base over the whole 48x32 world.
// Layer 2  THE ROAD NETWORK (scr_fv2_roads — roads before buildings, the city
//          skeleton): authentic cobble (spr_florence_road_cobble, falls back to
//          spr_florence_street until imported), plaza fields from the 16 plaza
//          variations, intersection tiles wherever two roads cross, curb strips
//          (spr_florence_road_edge) along every road's long edges.
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

// ── 2. roads ────────────────────────────────────────────────────────────────────
var _t_road = asset_get_index("spr_florence_road_cobble");
if (_t_road < 0 || asset_get_type("spr_florence_road_cobble") != asset_sprite) _t_road = spr_florence_street;
var _t_ints = asset_get_index("spr_florence_road_intersection");
if (_t_ints < 0 || asset_get_type("spr_florence_road_intersection") != asset_sprite) _t_ints = _t_road;
var _t_edge = asset_get_index("spr_florence_road_edge");
if (_t_edge >= 0 && asset_get_type("spr_florence_road_edge") != asset_sprite) _t_edge = -1;

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
    for (var _ty = _y0; _ty < _y1; _ty += _g) {
        for (var _tx = _x0; _tx < _x1; _tx += _g) {
            if (_r[4] == 1) {
                var _pi = (((_tx div 64) * 7) + ((_ty div 64) * 13)) mod 16;
                draw_sprite(_plaza[_pi], 0, _tx, _ty);
            } else {
                draw_sprite(_t_road, 0, _tx, _ty);
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
        for (var _iy = _oy0; _iy < _oy1; _iy += _g)
            for (var _ix = _ox0; _ix < _ox1; _ix += _g)
                draw_sprite(_t_ints, 0, _ix, _iy);
    }
}

// pass 3 — curb strips along each road's long edges (16px slice of the curb tile)
if (_t_edge >= 0) {
    for (var _c = 0; _c < _n; _c++) {
        var _r  = _roads[_c];
        if (_r[4] != 0) continue;
        var _x0 = round(_r[0]) * _g, _y0 = round(_r[1]) * _g;
        var _x1 = round(_r[2]) * _g, _y1 = round(_r[3]) * _g;
        var _horiz = (_x1 - _x0) >= (_y1 - _y0);
        if (_horiz) {
            for (var _ex = _x0; _ex < _x1; _ex += _g) {
                draw_sprite_part(_t_edge, 0, 0, 0,  64, 16, _ex, _y0);
                draw_sprite_part(_t_edge, 0, 0, 48, 64, 16, _ex, _y1 - 16);
            }
        } else {
            for (var _ey = _y0; _ey < _y1; _ey += _g) {
                draw_sprite_part(_t_edge, 0, 0,  0, 16, 64, _x0, _ey);
                draw_sprite_part(_t_edge, 0, 48, 0, 16, 64, _x1 - 16, _ey);
            }
        }
    }
}
draw_set_color(c_white);

// ── 3. CITY WALLS — stable-style black-void bands + stone texture + merlons,
//      gatehouses and towers on top (geometry = scr_fv2_walls, also collision)
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
scr_fv2_draw_walls(_corr);
