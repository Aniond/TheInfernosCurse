// =============================================================================
// obj_wall_stone — Draw Event
// =============================================================================
// Sprite path:    square-footprint buildings (houses) draw their Florence sprite,
//                 scaled to fill the wall area. Corruption tints toward void-black.
// Rectangle path: asymmetric structures (church, market) keep the grey placeholder
//                 until dedicated art ships for those buildings.

var _corrupt = clamp(wall_corruption, 0, 100);

// ── Breathing offset (past 50% corruption) ────────────────────────────────────
// Debug mode (F1) holds buildings still so the true static scene is visible.
var _breathe = 0;
if (_corrupt > 50 && !global.debug_mode) {
    _breathe = sin(breathe_offset) * (_corrupt / 100) * 2;
}

var _x1 = x + _breathe;
var _y1 = y + _breathe;
var _x2 = x + wall_w + _breathe;
var _y2 = y + wall_h + _breathe;

if (wall_sprite >= 0 && sprite_exists(wall_sprite)) {

    // ── Sprite path ───────────────────────────────────────────────────────────
    // Scale sprite to fill the wall footprint exactly.
    // Corruption tints the sprite toward void-black above 50%.
    // Debug mode shows buildings at full brightness (no corruption darkening)
    var _tint = c_white;
    if (_corrupt > 50 && !global.debug_mode) {
        var _dark = (_corrupt - 50) / 50;
        _tint = merge_color(c_white, make_color_rgb(20, 20, 30), _dark);
    }
    if (wall_fill) {
        // Big structures (cathedral, bell towers, building rows): the footprint
        // IS the building size, so stretch the sprite to fill it exactly.
        draw_sprite_stretched_ext(wall_sprite, 0, _x1, _y1, wall_w, wall_h, _tint, 1);
    } else {
        // Houses: fixed 3x scale, bottom-centre (footprint defines collision only,
        // the visual is not stretched to fill it).
        var _sw = sprite_get_width(wall_sprite) * 3;
        var _sh = sprite_get_height(wall_sprite) * 3;
        var _dx = _x1 + (wall_w * 0.5) - (_sw * 0.5);
        var _dy = _y1 + wall_h - _sh;
        draw_sprite_ext(wall_sprite, 0, _dx, _dy, 3, 3, 0, _tint, 1);
    }

    // Dark corruption veins drawn over the sprite at high corruption
    if (_corrupt > 75 && !global.debug_mode) {
        draw_set_color(make_color_rgb(10, 0, 20));
        draw_set_alpha(0.4);
        var _step = 48;
        var _vx = _x1 + _step;
        while (_vx < _x2) {
            draw_line(_vx, _y1, _vx - wall_h, _y2);
            _vx += _step;
        }
        draw_set_alpha(1);
    }

} else {

    // ── Rectangle fallback (church, market, structural placeholders) ──────────
    // Only visible in debug mode — hidden in player builds.
    if (global.debug_mode) {
        var _col;
        if (_corrupt < 25) {
            _col = make_color_rgb(80, 80, 90);
        } else if (_corrupt < 50) {
            _col = make_color_rgb(60, 60, 70);
        } else if (_corrupt < 75) {
            _col = make_color_rgb(40, 40, 50);
        } else {
            _col = make_color_rgb(20, 20, 30);
        }

        draw_set_color(_col);
        draw_rectangle(_x1, _y1, _x2, _y2, false);
        draw_set_color(merge_color(_col, c_white, 0.25));
        draw_rectangle(_x1, _y1, _x2, _y2, true);

        if (_corrupt > 75) {
            draw_set_color(make_color_rgb(10, 0, 20));
            var _step = 48;
            var _vx = _x1 + _step;
            while (_vx < _x2) {
                draw_line(_vx, _y1, _vx - wall_h, _y2);
                _vx += _step;
            }
        }
    }

}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_color(c_white);
draw_set_alpha(1);
