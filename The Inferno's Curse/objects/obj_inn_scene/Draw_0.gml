// =============================================================================
// obj_inn_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void inn interior, dark wood-plank floor + a red dining rug.
//   Layer 1  black void everywhere (= the walls).
//   Layer 2  dark simple wood-plank floor (spr_stable_floor, warm understated
//            tint, darker border ring), red/brown rug + gold trim in the centre.
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

// Layer 2 — hard dark oakwood flooring (spr_inn_floor, dedicated clean plank
// tile — no straw/debris like the stable's). Border ring just tints DARKER on
// the same tile. Tints stay near-white so the dark wood reads as itself.
var _amb      = merge_color(make_color_rgb(235, 224, 210), make_color_rgb(140, 138, 146), _corr);
var _bord     = merge_color(make_color_rgb(150, 130, 108), make_color_rgb(76, 76, 84),    _corr);
var _darkbase = merge_color(make_color_rgb(40, 30, 22),    make_color_rgb(22, 24, 30),    _corr);
for (var _cy = 0; _cy < INN_H_CELLS; _cy++)
    for (var _cx = 0; _cx < INN_W_CELLS; _cx++) {
        if (!scr_inn_is_interior(_cx, _cy)) continue;
        var _px = _cx * _g, _py = _cy * _g;
        draw_set_color(_darkbase); draw_rectangle(_px, _py, _px + _g, _py + _g, false);
        draw_set_color(c_white);
        var _tint = (scr_inn_is_border(_cx, _cy) || scr_inn_is_corner(_cx, _cy)) ? _bord : _amb;
        draw_sprite_ext(spr_inn_floor, 0, _px, _py, 1, 1, 0, _tint, 1);
    }

// Florentine woven rug (centre + side rug) — real crimson/gold rug texture
// tiled per cell (spr_inn_rug), cooling with corruption like everything else
var _rugt = merge_color(c_white, make_color_rgb(110, 105, 115), _corr);
for (var _ry = 0; _ry < INN_H_CELLS; _ry++)
    for (var _rx = 0; _rx < INN_W_CELLS; _rx++)
        if (scr_inn_is_rug(_rx, _ry) && scr_inn_is_interior(_rx, _ry))
            draw_sprite_ext(spr_inn_rug, 0, _rx * _g, _ry * _g, 1, 1, 0, _rugt, 1);
// gold trim around the MAIN rug only (the side rug stays plain)
var _rx0 = 3 * _g, _ry0 = 7 * _g, _rx1 = 11 * _g, _ry1 = 11 * _g;
draw_set_color(merge_color(make_color_rgb(196, 160, 86), make_color_rgb(96, 84, 70), _corr));
draw_rectangle(_rx0, _ry0, _rx1, _ry0 + 4, false);
draw_rectangle(_rx0, _ry1 - 4, _rx1, _ry1, false);
draw_rectangle(_rx0, _ry0, _rx0 + 4, _ry1, false);
draw_rectangle(_rx1 - 4, _ry0, _rx1, _ry1, false);
draw_set_color(c_white);

// South entrance threshold — a lighter doorstep in the 2-cell gap (cols 7-8, row 13)
var _thr = merge_color(_amb, c_white, 0.28);
for (var _tcx = 7; _tcx <= 8; _tcx++)
    draw_sprite_ext(spr_inn_floor, 0, _tcx * _g, 13 * _g, 1, 1, 0, _thr, 1);

// Window light pools — time-of-day reactive (and LYING at full corruption)
scr_inn_window_glow();

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
