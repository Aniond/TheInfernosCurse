// =============================================================================
// obj_inn_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void inn interior, warm dark-stone floor + a red dining rug.
//   Layer 1  black void everywhere (= the walls).
//   Layer 2  warm dark-stone floor on the walkable rectangle (border/corner tiles
//            at the edges), with a red/brown rug + gold trim in the dining centre.
//   Layer 3  a lighter doorstep in the south entrance gap; warm/cold ambient by corruption.
if (room != Room_locanda_rosa_camuna) exit;

// Bread oven swaps lit(animated) <-> cold/corrupt by Limbo corruption (50% threshold).
// Set here (scene draws at depth 160, before the props at 100) so it lands this frame.
scr_inn_oven_sync();

var _rw = room_width, _rh = room_height;
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _g = INN_GRID_PX;

// Layer 1 — black void (the walls)
draw_set_color(c_black);
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);

// Layer 2 — warm dark-stone floor (reuse the duomo dark tileset, warmer tint)
var _amb      = merge_color(make_color_rgb(214, 182, 142), make_color_rgb(120, 118, 124), _corr);
var _darkbase = merge_color(make_color_rgb(56, 46, 36),    make_color_rgb(26, 28, 34),    _corr);
for (var _cy = 0; _cy < INN_H_CELLS; _cy++)
    for (var _cx = 0; _cx < INN_W_CELLS; _cx++) {
        if (!scr_inn_is_interior(_cx, _cy)) continue;
        var _px = _cx * _g, _py = _cy * _g;
        draw_set_color(_darkbase); draw_rectangle(_px, _py, _px + _g, _py + _g, false);
        draw_set_color(c_white);
        var _f;
        if      (scr_inn_is_corner(_cx, _cy)) _f = spr_duomo_floor_corner;
        else if (scr_inn_is_border(_cx, _cy)) _f = spr_duomo_floor_border;
        else                                  _f = spr_duomo_floor_field;
        draw_sprite_ext(_f, 0, _px, _py, 1, 1, 0, _amb, 1);
    }

// Red/brown dining rug (centre)
var _rugc = merge_color(make_color_rgb(150, 58, 42), make_color_rgb(72, 30, 26), _corr);
draw_set_color(_rugc);
for (var _ry = 0; _ry < INN_H_CELLS; _ry++)
    for (var _rx = 0; _rx < INN_W_CELLS; _rx++)
        if (scr_inn_is_rug(_rx, _ry) && scr_inn_is_interior(_rx, _ry))
            draw_rectangle(_rx * _g, _ry * _g, _rx * _g + _g, _ry * _g + _g, false);
// gold trim around the rug
var _rx0 = 3 * _g, _ry0 = 9 * _g, _rx1 = 11 * _g, _ry1 = 14 * _g;
draw_set_color(merge_color(make_color_rgb(196, 160, 86), make_color_rgb(96, 84, 70), _corr));
draw_rectangle(_rx0, _ry0, _rx1, _ry0 + 4, false);
draw_rectangle(_rx0, _ry1 - 4, _rx1, _ry1, false);
draw_rectangle(_rx0, _ry0, _rx0 + 4, _ry1, false);
draw_rectangle(_rx1 - 4, _ry0, _rx1, _ry1, false);
draw_set_color(c_white);

// Kitchen/bar divider — a REAL drawn wall, stable-style FF6 void band (solid black
// body + 32px plank tile inset for a black outline frame + lit top edge), exactly
// matching its invisible obj_wall collision in scr_inn_build_collision (row 4,
// cols 1-9). The bar counter's east arm joins it — one built structure.
var _dx0 = 1 * _g, _dy0 = 4 * _g, _dx1 = 10 * _g, _dy1 = 5 * _g;
draw_set_color(c_black);
draw_rectangle(_dx0, _dy0, _dx1, _dy1, false);
var _wt   = asset_get_index("spr_stable_wall_tile");
var _whas = (_wt >= 0 && asset_get_type("spr_stable_wall_tile") == asset_sprite);
var _wx0 = _dx0 + 4, _wy0 = _dy0 + 4, _wx1 = _dx1 - 4, _wy1 = _dy1 - 4;
if (_whas) {
    var _wcol = merge_color(c_white, make_color_rgb(110, 112, 124), _corr);
    for (var _wy = _wy0; _wy < _wy1; _wy += 32) {
        var _wh = min(32, _wy1 - _wy);
        for (var _wx = _wx0; _wx < _wx1; _wx += 32) {
            var _ww = min(32, _wx1 - _wx);
            draw_sprite_part_ext(_wt, 0, 0, 0, _ww, _wh, _wx, _wy, 1, 1, _wcol, 1);
        }
    }
} else {
    draw_set_color(merge_color(make_color_rgb(58, 38, 24), make_color_rgb(30, 28, 32), _corr));
    draw_rectangle(_wx0, _wy0, _wx1, _wy1, false);
}
draw_set_color(merge_color(make_color_rgb(132, 92, 54), make_color_rgb(64, 62, 68), _corr));
draw_rectangle(_wx0, _wy0, _wx1, min(_wy0 + 3, _wy1), false);
draw_set_color(c_white);

// South entrance threshold — a lighter doorstep in the 2-cell gap (cols 7-8, row 16)
var _thr = merge_color(_amb, c_white, 0.28);
for (var _tcx = 7; _tcx <= 8; _tcx++)
    draw_sprite_ext(spr_duomo_floor_field, 0, _tcx * _g, 16 * _g, 1, 1, 0, _thr, 1);

// Ambient — warm candlelight when lucid, cold dark as corruption deepens
if (_corr < 0.5) {
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.07 * (1 - _corr / 0.5));
    draw_set_color(make_color_rgb(255, 188, 104));
    draw_rectangle(0, 0, _rw, _rh, false);
    gpu_set_blendmode(bm_normal);
} else {
    draw_set_alpha(0.08 + 0.26 * ((_corr - 0.5) / 0.5));
    draw_set_color(make_color_rgb(6, 8, 16));
    draw_rectangle(0, 0, _rw, _rh, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
