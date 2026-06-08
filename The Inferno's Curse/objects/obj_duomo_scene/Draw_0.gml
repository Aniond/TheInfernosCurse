// =============================================================================
// obj_duomo_scene — Draw  (depth 160: under the player at 100)
// =============================================================================
// Black-void cathedral, dark warm-stone tileset.
//   Layer 1  black void everywhere outside the cross.
//   Layer 2  dark BORDER tile outlines the floor; darkest CORNER tile at corners.
//   Layer 3  dark FIELD tile fills the floor; PLATFORM tile on the apse dais;
//            CENTER medallion at the crossing; CARPET tile up the nave.
//   FIX 1    apse north wall: stone face + stained-glass windows + purple/gold
//            banners behind the raised altar (priest is a placed object).
//   FIX 5    south entrance archway + step lines.
if (room != Room_duomo) exit;

var _rw = room_width, _rh = room_height;
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _g = DUOMO_GRID_PX;

// Layer 1 — black void
draw_set_color(c_black);
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);

// FIX 3 — brighter floor: warmer tile tint + a lifted stone base so the field
// detail reads, while the void stays black and the mood stays dark.
var _amb     = merge_color(make_color_rgb(250, 246, 236), make_color_rgb(150, 150, 162), _corr);
var _darkbase = merge_color(make_color_rgb(58, 50, 44), make_color_rgb(28, 30, 38), _corr);

// ── FLOOR (layers 2 & 3) ─────────────────────────────────────────────────────
for (var _cy = 0; _cy < DUOMO_H_CELLS; _cy++) {
    for (var _cx = 0; _cx < DUOMO_W_CELLS; _cx++) {
        if (!scr_duomo_is_interior(_cx, _cy)) continue;
        var _px = _cx * _g, _py = _cy * _g;
        draw_set_color(_darkbase); draw_rectangle(_px, _py, _px + _g, _py + _g, false);
        draw_set_color(c_white);

        var _fspr;
        if      (scr_duomo_is_dais(_cx, _cy))   _fspr = spr_duomo_floor_field;   // plain dais fill (one medallion drawn below)
        else if (scr_duomo_is_dome(_cx, _cy))   _fspr = spr_duomo_floor_center;
        else if (scr_duomo_is_corner(_cx, _cy)) _fspr = spr_duomo_floor_corner;
        else if (scr_duomo_is_border(_cx, _cy)) _fspr = spr_duomo_floor_border;
        else                                    _fspr = spr_duomo_floor_field;
        draw_sprite_ext(_fspr, 0, _px, _py, 1, 1, 0, _amb, 1);
    }
}

// ── FIX 1 — bright crimson carpet + gold trim (strongest eye-line to the altar)
var _cx0 = 9 * _g, _cx1 = 11 * _g, _cy0 = 4 * _g, _cy1 = 21 * _g;
for (var _ry = 4; _ry <= 20; _ry++) {                              // textured base (stops above the doorway gap)
    draw_sprite_ext(spr_duomo_floor_carpet, 0, 9 * _g, _ry * _g, 1, 1, 0, _amb, 1);
    draw_sprite_ext(spr_duomo_floor_carpet, 0, 10 * _g, _ry * _g, 1, 1, 0, _amb, 1);
}
draw_set_color(merge_color(make_color_rgb(182, 32, 36), make_color_rgb(74, 18, 24), _corr));
draw_set_alpha(0.58);                                              // boost the crimson
draw_rectangle(_cx0, _cy0, _cx1, _cy1, false);
draw_set_alpha(1);
var _cgold = merge_color(make_color_rgb(216, 180, 94), make_color_rgb(96, 84, 70), _corr);
draw_set_color(_cgold);                                            // gold trim, both edges
draw_rectangle(_cx0, _cy0, _cx0 + 5, _cy1, false);
draw_rectangle(_cx1 - 5, _cy0, _cx1, _cy1, false);
draw_set_color(c_white);

// ── FIX 2 — ONE grand medallion centred on the dais (plain platform fill around) ─
draw_sprite_ext(spr_duomo_floor_platform, 0, 640 - 64, 192 - 64, 2, 2, 0, _amb, 1);

// ── FIX 1 — APSE: stone wall + stained glass + banners behind the altar ──────
// Void rows 0-1 above the nave top (row 2) form the back wall of the apse.
draw_set_color(merge_color(make_color_rgb(40, 36, 42), make_color_rgb(18, 20, 30), _corr));
draw_rectangle(6 * _g, 0, 14 * _g, 2 * _g, false);                       // stone wall face
// stained-glass windows (row 1)
var _wcols = [7, 9, 11, 13];
for (var _wi = 0; _wi < array_length(_wcols); _wi++) {
    draw_sprite_ext(spr_duomo_wall_window, 0, _wcols[_wi] * _g, 1 * _g, 1, 1, 0, _amb, 1);
    // soft coloured glow spilling down onto the dais
    var _glc = (_wi & 1) ? make_color_rgb(200, 70, 70) : make_color_rgb(80, 120, 220);
    gpu_set_blendmode(bm_add);
    draw_set_color(_glc); draw_set_alpha(0.22 * (1 - _corr * 0.6));
    draw_circle(_wcols[_wi] * _g + _g * 0.5, 2 * _g + _g * 0.4, 30, false);
    gpu_set_blendmode(bm_normal); draw_set_alpha(1); draw_set_color(c_white);
}
// purple/gold banners (row 0), flanking the windows
var _bcols = [6, 8, 12, 14];
for (var _bi = 0; _bi < array_length(_bcols); _bi++) {
    var _bx = _bcols[_bi] * _g + 14;
    draw_set_color(merge_color(make_color_rgb(78, 36, 120), c_black, _corr * 0.6));
    draw_rectangle(_bx, 4, _bx + 36, 2 * _g - 4, false);                 // banner cloth
    draw_set_color(merge_color(make_color_rgb(206, 172, 84), c_black, _corr * 0.5));
    draw_rectangle(_bx, 4, _bx + 36, 8, false);                          // gold top
    draw_line_width(_bx + 18, 8, _bx + 18, 2 * _g - 6, 1);               // gold centre line
}
draw_set_color(c_white);

// ── Step lines (dais front + entrance) ───────────────────────────────────────
draw_set_color(merge_color(make_color_rgb(20, 16, 14), c_black, 0.3));
for (var _s = 0; _s < 2; _s++) { var _sy = (4 * _g) + _s * 5;  draw_line_width(7 * _g, _sy, 13 * _g, _sy, 3); }
for (var _s2 = 0; _s2 < 2; _s2++){ var _sy2 = (20 * _g) + _s2 * 6; draw_line_width(8 * _g, _sy2, 12 * _g, _sy2, 3); }
draw_set_color(c_white);

// ── SOUTH DOORWAY — FF6 wall gap (NO door). The geometry already opens a 3-cell
// gap (cols 9-11) at row 21 with black-void wall on both sides and black beyond.
// Here we just lay a slightly-LIGHTER floor in the gap as a threshold/doorstep so
// the opening reads as the way out. Players understand the gap naturally. ────────
var _thr = merge_color(_amb, c_white, 0.30);              // brighter than the nave floor
for (var _tcx = 9; _tcx <= 11; _tcx++) {
    draw_sprite_ext(spr_duomo_floor_field, 0, _tcx * _g, 21 * _g, 1, 1, 0, _thr, 1);
}
draw_set_color(merge_color(make_color_rgb(126, 112, 94), c_black, _corr * 0.4));   // worn doorstep line
draw_line_width(9 * _g + 2, 21 * _g + 5, 12 * _g - 2, 21 * _g + 5, 2);
draw_set_color(c_white);

// ── Ambient overlay ──────────────────────────────────────────────────────────
if (_corr < 0.5) {
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.06 * (1 - _corr / 0.5));
    draw_set_color(make_color_rgb(255, 198, 110));
    draw_rectangle(0, 0, _rw, _rh, false);
    gpu_set_blendmode(bm_normal);
} else {
    draw_set_alpha(0.08 + 0.26 * ((_corr - 0.5) / 0.5));   // FIX 3 — gentler darkening for floor readability
    draw_set_color(make_color_rgb(6, 8, 16));
    draw_rectangle(0, 0, _rw, _rh, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
