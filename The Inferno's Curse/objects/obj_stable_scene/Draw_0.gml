// =============================================================================
// obj_stable_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void stable interior, straw-strewn timber floor.
//   Layer 1  black void everywhere (= the walls).
//   Layer 2  spr_stable_floor tiles on the walkable cells (darker at the border
//            ring), warm/cold ambient tint by Limbo corruption.
//   Layer 3  lighter doorstep in the south entrance gap; lantern glow pass
//            (warm → uneasy → cold → GREEN at 100); horses ease away at 75+.
if (room != Room_fiorentine_stable) exit;

// Horses back away from Benedetto at 75%+ corruption (eased, restores below).
scr_stable_horse_sync();

var _rw = room_width, _rh = room_height;
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _g = STABLE_GRID_PX;

// Layer 1 — black void (the walls)
draw_set_color(c_black);
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);

// Layer 2 — timber floor, warm straw tint cooling as corruption deepens
var _amb    = merge_color(make_color_rgb(216, 188, 140), make_color_rgb(122, 120, 126), _corr);
var _border = merge_color(make_color_rgb(132, 108, 76),  make_color_rgb(62, 62, 70),    _corr);
var _floor  = asset_get_index("spr_stable_floor");
var _has    = (_floor >= 0 && asset_get_type("spr_stable_floor") == asset_sprite);
// GLOBAL relief shader (scr_relief): lantern relief on the timber at night,
// daytime passthrough; the rect fallback only runs when the sprite is
// missing, and then _relief is false anyway (begin rejects a bad sprite)
var _relief = _has ? scr_relief_begin(_floor) : false;
for (var _cy = 0; _cy < STABLE_H_CELLS; _cy++)
    for (var _cx = 0; _cx < STABLE_W_CELLS; _cx++) {
        if (!scr_stable_is_interior(_cx, _cy)) continue;
        var _px = _cx * _g, _py = _cy * _g;
        var _tint = scr_stable_is_border(_cx, _cy) ? _border : _amb;
        if (_has) draw_sprite_ext(_floor, 0, _px, _py, 1, 1, 0, _tint, 1);
        else { draw_set_color(_tint); draw_rectangle(_px, _py, _px + _g, _py + _g, false); draw_set_color(c_white); }
    }
if (_relief) scr_relief_end();

// South entrance threshold — a lighter doorstep in the 2-cell gap (cols 4-5, row 14)
var _thr = merge_color(_amb, c_white, 0.28);
if (_has) {
    draw_sprite_ext(_floor, 0, 4 * _g, 14 * _g, 1, 1, 0, _thr, 1);
    draw_sprite_ext(_floor, 0, 5 * _g, 14 * _g, 1, 1, 0, _thr, 1);
}

// Layer 3 — STALL PARTITION WALLS (dark timber dividers; same geometry as the
// obj_wall collision — scr_stable_partitions is the single source)
scr_stable_draw_partitions(_corr);

// Layer 4 — lantern glow (corruption-keyed: warm → dim → cold → GREEN at 100)
scr_stable_lantern_glow();

// Ambient — warm hay-light when lucid, cold dark as corruption deepens
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
