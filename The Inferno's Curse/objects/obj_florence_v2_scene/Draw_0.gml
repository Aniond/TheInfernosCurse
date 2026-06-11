// =============================================================================
// obj_florence_v2_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Layer 1  grass base over the whole 48x32 world.
// Layer 2  THE ROAD NETWORK (scr_fv2_roads — roads before buildings, the city
//          skeleton): ROADS = procedural warm pietra forte flagstone over the
//          citywide grey cobble base (the road SYSTEM reads warm-on-grey),
//          plaza fields = cobble + subtle procedural herringbone accents,
//          the Duomo precinct = the same flagstone, and INNER
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

// ── 1b. COBBLE PAVING over the whole CITY INTERIOR (David 2026-06-10: the
//        plaza's seamless cobble citywide — packed earth retired inside the
//        walls; grass lives only outside). Same tile, same half scale, same
//        32px snap as the road/plaza passes, so every join is invisible.
var _t_pave = asset_get_index("spr_florence_road_cobble");
if (_t_pave < 0 || asset_get_type("spr_florence_road_cobble") != asset_sprite) _t_pave = spr_florence_street;
for (var _ey2 = 128; _ey2 < 1638; _ey2 += 32)
    for (var _ex2 = 320; _ex2 < 2538; _ex2 += 32)
        draw_sprite_part_ext(_t_pave, 0, 0, 0,
            min(64, (2538 - _ex2) * 2), min(64, (1638 - _ey2) * 2),
            _ex2, _ey2, 0.5, 0.5, c_white, 1);

// ── 2. roads ────────────────────────────────────────────────────────────────────
var _t_road = asset_get_index("spr_florence_road_cobble");
if (_t_road < 0 || asset_get_type("spr_florence_road_cobble") != asset_sprite) _t_road = spr_florence_street;

var _roads = scr_fv2_roads();
var _n = array_length(_roads);

// pass 1 — fill every rect, tile-snapped. kind 1 plazas = continuous cobble
// + a SUBTLE procedural herringbone accent (the old dark medallion sprites
// read as pasted-on boulders — David); kind 2 = the Duomo's procedural
// flagstone precinct (scr_fv2_draw_flagstone, no sprite tile at all).
for (var _i = 0; _i < _n; _i++) {
    var _r  = _roads[_i];
    var _x0 = round(_r[0]) * _g, _y0 = round(_r[1]) * _g;
    var _x1 = round(_r[2]) * _g, _y1 = round(_r[3]) * _g;
    if (_r[4] == 2) {
        // Piazza del Duomo — warm pietra forte flagstone, drawn procedurally
        scr_fv2_draw_flagstone(_x0, _y0, _x1, _y1);
    } else if (_r[4] == 1) {
        // plazas: CONTINUOUS half-scale cobble base...
        for (var _ty = _y0; _ty < _y1; _ty += 32)
            for (var _tx = _x0; _tx < _x1; _tx += 32)
                draw_sprite_ext(_t_road, 0, _tx, _ty, 0.5, 0.5, 0, c_white, 1);
        // ...with a herringbone (spina di pesce) brick motif in a hash-picked
        // subset of cells — only ~10% darker than the cobble and half-alpha,
        // so it reads as pavement variation, never as an object. Pure
        // procedural rects, deterministic, clamped to the plaza.
        draw_set_alpha(0.5);
        draw_set_color(make_color_rgb(132, 128, 124));   // cobble grey, -10%
        for (var _py = _y0; _py < _y1; _py += _g) {
            for (var _px = _x0; _px < _x1; _px += _g) {
                if ((((_px div 64) * 3) + ((_py div 64) * 5)) mod 6 != 0) continue;
                // classic zig-zag: 4 courses of paired bricks per 64px cell,
                // alternating horizontal / vertical lay, 16x6 bricks inset 8px
                for (var _hr = 0; _hr < 4; _hr++) {
                    for (var _hc = 0; _hc < 3; _hc++) {
                        var _hx = _px + 8 + _hc * 16, _hy = _py + 8 + _hr * 12;
                        if ((_hr + _hc) mod 2 == 0) {
                            draw_rectangle(min(_hx, _x1 - 1),      min(_hy, _y1 - 1),
                                           min(_hx + 14, _x1 - 1), min(_hy + 5, _y1 - 1), false);
                        } else {
                            draw_rectangle(min(_hx + 4, _x1 - 1),  min(_hy - 4, _y1 - 1),
                                           min(_hx + 9, _x1 - 1),  min(_hy + 9, _y1 - 1), false);
                        }
                    }
                }
            }
        }
        draw_set_alpha(1);
        draw_set_color(c_white);
    } else {
        // ROADS = the warm pietra forte flagstone over the grey cobble base
        // (David 2026-06-10: "the idea is to create a road system" — warm-on-
        // grey reads as the road network). Same procedural language as the
        // Duomo precinct. Junction overlaps self-resolve: the later road's
        // full-cover mortar base simply repaves the shared cells.
        scr_fv2_draw_flagstone(_x0, _y0, _x1, _y1);
    }
}
// (the old pass 2 — cobble intersection tiles — is retired: flagstone roads
//  resolve their own junctions, and cobble squares would read as holes)

// pass 3 — STREET SUBWALLS: the void+art standard at street scale. Each
// road's long edges get a CONTINUOUS thin wall: a black void underlay band
// with the 128x32 thin-wall tile running unbroken at half scale (64x16) —
// replaces the old per-tile curb slices that read as disconnected caps.
// Drawn from the SAME geometry that collides (scr_fv2_street_walls): each
// 24px segment = black void band + the 16px stone art inset 4px — and the
// segments skipped for junction mouths / the church-door opening simply
// don't exist, visually or physically.
var _t_curb = asset_get_index("spr_florence_thin_wall");
if (_t_curb >= 0 && asset_get_type("spr_florence_thin_wall") == asset_sprite) {
    var _sw = scr_fv2_street_walls();
    for (var _c = 0; _c < array_length(_sw); _c++) {
        var _ws  = _sw[_c];
        draw_set_color(c_black);
        draw_rectangle(_ws[0], _ws[1], _ws[2], _ws[3], false);
        var _whoriz = (_ws[2] - _ws[0]) >= (_ws[3] - _ws[1]);
        if (_whoriz) {
            var _wlen = (_ws[2] - _ws[0]) * 2;
            draw_sprite_part_ext(_t_curb, 0, 0, 0, min(128, _wlen), 32,
                _ws[0], _ws[1] + 4, 0.5, 0.5, c_white, 1);
        } else {
            var _wlen2 = (_ws[3] - _ws[1]) * 2;
            draw_sprite_general(_t_curb, 0, 0, 0, min(128, _wlen2), 32,
                _ws[0] + 4, _ws[3], 0.5, 0.5, 90, c_white, c_white, c_white, c_white, 1);
        }
    }
    draw_set_color(c_white);
}
draw_set_color(c_white);

// ── 3. CITY WALLS — stable-style black-void bands + stone texture, with
//      gatehouses and towers on top (geometry = scr_fv2_walls, also collision)
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
scr_fv2_draw_walls(_corr);

// ── 4. THE ARNO (east band, flows south) — corruption water carried over:
//      forward → silty → slow → REVERSED at 75% → red and wrong at 100
scr_fv2_draw_arno(_corr);

// ── 5. street life + shrines react to corruption ───────────────────────────────
//      (torch/candle GLOW moved to the GLOBAL lighting system in
//       obj_game_manager Draw GUI — time-of-day + corruption gated, all rooms)
scr_fv2_corruption_sync();

// ── 6. the city itself dirties as Limbo deepens (50%+) ─────────────────────────
if (_corr >= 0.5) {
    draw_set_alpha(0.05 + 0.10 * ((_corr - 0.5) / 0.5));
    draw_set_color(make_color_rgb(40, 34, 26));
    draw_rectangle(0, 0, _rw, _rh, false);
    draw_set_alpha(1); draw_set_color(c_white);
}
