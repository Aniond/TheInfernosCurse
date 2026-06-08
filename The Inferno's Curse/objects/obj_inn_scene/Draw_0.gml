// =============================================================================
// obj_inn_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void inn interior, warm dark-stone floor + a red dining rug.
//   Layer 1  black void everywhere (= the walls).
//   Layer 2  warm dark-stone floor on the walkable rectangle (border/corner tiles
//            at the edges), with a red/brown rug + gold trim in the dining centre.
//   Layer 3  a lighter doorstep in the south entrance gap; warm/cold ambient by corruption.
if (room != Room_fiorentine_inn) exit;

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
var _rx0 = 7 * _g, _ry0 = 8 * _g, _rx1 = 13 * _g, _ry1 = 15 * _g;
draw_set_color(merge_color(make_color_rgb(196, 160, 86), make_color_rgb(96, 84, 70), _corr));
draw_rectangle(_rx0, _ry0, _rx1, _ry0 + 4, false);
draw_rectangle(_rx0, _ry1 - 4, _rx1, _ry1, false);
draw_rectangle(_rx0, _ry0, _rx0 + 4, _ry1, false);
draw_rectangle(_rx1 - 4, _ry0, _rx1, _ry1, false);
draw_set_color(c_white);

// South entrance threshold — a lighter doorstep in the 3-cell gap (cols 9-11, row 19)
var _thr = merge_color(_amb, c_white, 0.28);
for (var _tcx = 9; _tcx <= 11; _tcx++)
    draw_sprite_ext(spr_duomo_floor_field, 0, _tcx * _g, 19 * _g, 1, 1, 0, _thr, 1);

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
