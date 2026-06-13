show_debug_message("ALTAR COUNT: " + string(instance_number(obj_duomo_altar)));
show_debug_message("CROSS COUNT: " + string(instance_number(obj_duomo_cross)));
// =============================================================================
// obj_duomo_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void cathedral using FF6 Carving Method.
if (room != Room_duomo) exit;

var _rw = room_width, _rh = room_height;
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _g = DUOMO_GRID_PX;

// Layer 1 — black void everywhere
draw_set_color(c_black);
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);

var _amb = merge_color(make_color_rgb(250, 246, 236), make_color_rgb(150, 150, 162), _corr);

// ── FLOOR (Layer 2) ─────────────────────────────────────────────────────
for (var _cy = 0; _cy < DUOMO_H_CELLS; _cy++) {
    for (var _cx = 0; _cx < DUOMO_W_CELLS; _cx++) {
        if (!scr_duomo_is_interior(_cx, _cy)) continue;
        var _px = _cx * _g, _py = _cy * _g;
        draw_sprite_ext(spr_duomo_floor_marble, 0, _px, _py, 1, 1, 0, _amb, 1);
    }
}

// ── NAVE CARPET ─────────────────────────────────────────────────────────
// A bold crimson carpet rolling down the main nave (cols 14, 15)
var _cgold = merge_color(make_color_rgb(216, 180, 94), make_color_rgb(96, 84, 70), _corr);
draw_set_color(merge_color(make_color_rgb(182, 32, 36), make_color_rgb(74, 18, 24), _corr));
draw_set_alpha(0.85);
draw_rectangle(14 * _g, 15 * _g, 16 * _g, 33 * _g + 32, false); // Crimson base
draw_set_alpha(1);
draw_set_color(_cgold);
draw_rectangle(14 * _g, 15 * _g, 14 * _g + 6, 33 * _g + 32, false); // Left gold trim
draw_rectangle(16 * _g - 6, 15 * _g, 16 * _g, 33 * _g + 32, false); // Right gold trim
draw_set_color(c_white);

// ── WALL ART INSETS (Layer 3) ───────────────────────────────────────────
// We extrude walls upwards from every floor cell until we hit the pure exterior.
// This ensures that L-shaped room corners and horizontal doorways are filled 
// with solid downward walls, creating defined "wall enclosures" (like FF6).
for (var _cx = 0; _cx < DUOMO_W_CELLS; _cx++) {
    var _cy = DUOMO_H_CELLS - 1;
    while (_cy >= 0) {
        if (scr_duomo_is_interior(_cx, _cy)) {
            // Found a floor cell. Look upwards into the void to build the wall.
            var _wall_y = _cy - 1;
            while (_wall_y >= 0 && !scr_duomo_is_interior(_cx, _wall_y) && scr_duomo_is_wall(_cx, _wall_y)) {
                // Draw the 2-tile high wall art so its bottom edge connects seamlessly
                draw_sprite_ext(spr_duomo_wall_art, 0, _cx * _g, (_wall_y - 1) * _g, 1, 1, 0, _amb, 1);
                _wall_y -= 2; // Step up 2 tiles
            }
            _cy = _wall_y; // Skip the void blocks we just filled
        } else {
            _cy--;
        }
    }
}

// ── SOUTH DOORWAY ───────────────────────────────────────────────────────
// Provide a clear visual exit threshold
var _thr = merge_color(_amb, c_white, 0.30);
for (var _tcx = 13; _tcx <= 15; _tcx++) {
    draw_sprite_ext(spr_duomo_floor_marble, 0, _tcx * _g, 34 * _g, 1, 1, 0, _thr, 1);
}
draw_set_color(merge_color(make_color_rgb(126, 112, 94), c_black, _corr * 0.4));
draw_line_width(13 * _g + 2, 34 * _g + 5, 16 * _g - 2, 34 * _g + 5, 2);
draw_set_color(c_white);

// ── AMBIENT OVERLAY ─────────────────────────────────────────────────────
if (_corr < 0.5) {
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.06 * (1 - _corr / 0.5));
    draw_set_color(make_color_rgb(255, 198, 110));
    draw_rectangle(0, 0, _rw, _rh, false);
    gpu_set_blendmode(bm_normal);
} else {
    draw_set_alpha(0.08 + 0.26 * ((_corr - 0.5) / 0.5));
    draw_set_color(make_color_rgb(6, 8, 16));
    draw_rectangle(0, 0, _rw, _rh, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
