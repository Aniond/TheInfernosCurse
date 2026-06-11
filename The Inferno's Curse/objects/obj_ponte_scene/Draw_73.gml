// =============================================================================
// obj_ponte_scene — Draw End: THE CANOPY (David's covered-bridge design)
// =============================================================================
// Two terracotta roof runs span the corridor — the bridge reads as a covered
// merchant gallery. The central plaza + both landings stay OPEN to the sky.
// The segment over Benedetto fades to ~0.45 alpha (SNES roof cutaway).
// (Briefly disabled 2026-06-10 to inspect the open walkway — David prefers
// the covered look, so it stays. The floor-seam fix is a separate tile swap.)
// =============================================================================
if (room_get_name(room) != "Room_ponte_vecchio") exit;

// covered runs [x0, y0, x1, y1] — plaza x512-768 and landings stay open
// (narrow bridge: canopy spans shop mid to shop mid, y100-420)
var _segs = [
    [96,  100, 512,  420],
    [768, 100, 1184, 420],
];

var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _tint = merge_color(c_white, make_color_rgb(96, 84, 90), _corr * 0.55);
// Canopy art = dark weathered wood beams (spr_ponte_canopy, 128x32). Tiled
// across each covered run; falls back to the old roof tile, then a flat
// dark-wood rect. No collision — players walk under (Draw End, overhead only).
var _roof = asset_get_index("spr_ponte_canopy");
if (_roof < 0 || asset_get_type("spr_ponte_canopy") != asset_sprite) _roof = asset_get_index("spr_ponte_roof_tile");
var _has  = (_roof >= 0 && asset_get_type(sprite_get_name(_roof)) == asset_sprite);
var _rw   = _has ? sprite_get_width(_roof)  : 128;
var _rh   = _has ? sprite_get_height(_roof) : 32;

for (var _i = 0; _i < array_length(_segs); _i++) {
    var _s = _segs[_i];
    // roof-cutaway: fade the segment the player stands under
    var _under = instance_exists(obj_player)
        && obj_player.x > _s[0] - 16 && obj_player.x < _s[2] + 16
        && obj_player.y > _s[1]      && obj_player.y < _s[3] + 24;
    canopy_a[_i] = lerp(canopy_a[_i], _under ? 0.45 : 0.96, 0.10);
    draw_set_alpha(canopy_a[_i]);
    if (_has) {
        for (var _ry = _s[1]; _ry < _s[3]; _ry += _rh)
            for (var _rx = _s[0]; _rx < _s[2]; _rx += _rw)
                draw_sprite_part_ext(_roof, 0, 0, 0,
                    min(_rw, _s[2] - _rx), min(_rh, _s[3] - _ry), _rx, _ry, 1, 1, _tint, canopy_a[_i]);
    } else {
        draw_set_color(merge_color(make_color_rgb(92, 66, 44), make_color_rgb(50, 40, 34), _corr * 0.55));
        draw_rectangle(_s[0], _s[1], _s[2], _s[3], false);
    }
    // ridge line + eaves shadow sell the pitched roof
    draw_set_color(c_black);
    draw_set_alpha(0.35 * canopy_a[_i]);
    draw_rectangle(_s[0], (_s[1] + _s[3]) * 0.5 - 2, _s[2], (_s[1] + _s[3]) * 0.5 + 2, false);
    draw_set_alpha(0.45 * canopy_a[_i]);
    draw_rectangle(_s[0], _s[3] - 6, _s[2], _s[3], false);
    draw_rectangle(_s[0], _s[1], _s[0] + 6, _s[3], false);
    draw_rectangle(_s[2] - 6, _s[1], _s[2], _s[3], false);
}
draw_set_alpha(1);
draw_set_color(c_white);
