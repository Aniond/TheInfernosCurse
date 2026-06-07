// =============================================================================
// obj_mercato_scene — Draw  (depth 160)
// =============================================================================
// Ground dressing for Room_mercato_vecchio: worn Florentine cobblestone over the
// whole square, the Arno along the SOUTH edge (same corruption-driven water as
// Room1), a stone embankment, and central stone steps down to the Ponte Vecchio
// exit. The loggia, buildings, stalls, props and fountain are placed OBJECTS
// (spawned in Create), not drawn here. Room-guarded so it only paints in the
// mercato.
// =============================================================================
if (room_get_name(room) != "Room_mercato_vecchio") exit;

var _rw = room_width;
var _rh = room_height;

// ── worn cobblestone ground (darker / more weathered than Room1's street) ─────
draw_set_color(make_color_rgb(60, 54, 48));                 // dark base (no smear under tiles)
draw_rectangle(0, 0, _rw, _rh, false);
draw_set_color(c_white);
var _cw  = sprite_get_width(spr_florence_street);          // 64
var _ch  = sprite_get_height(spr_florence_street);         // 64
var _cob = make_color_rgb(150, 140, 126);                  // multiply tint -> worn, dusty
for (var _gy = 0; _gy < _rh; _gy += _ch) {
    for (var _gx = 0; _gx < _rw; _gx += _cw) {
        draw_sprite_ext(spr_florence_street, 0, _gx, _gy, 1, 1, 0, _cob, 1);
    }
}

// ── Arno river along the SOUTH edge ───────────────────────────────────────────
var _ry1   = _rh - 192;          // river top  (stone bank sits here)
var _ry2   = _rh;                // to the bottom edge
var _ix0   = 0, _ix1 = _rw;
var _bankh = 24;

// water surface — DEGRADES with Limbo corruption, identical staging to Room1.
var _ww   = sprite_get_width(spr_florence_water);          // 64
var _wh   = sprite_get_height(spr_florence_water);         // 64
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _spd;
if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);
else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);
else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);
var _scroll = (current_time / 1000 * _spd) mod _ww;
for (var _wy = _ry1; _wy < _ry2; _wy += _wh) {
    for (var _wx = _ix0 - _ww + _scroll; _wx < _ix1; _wx += _ww) {
        draw_sprite(spr_florence_water, 0, _wx, _wy);
    }
}
// corruption colour bleed — clean -> silty brown -> murk -> blood red
var _a;
if (_corr < 0.25)      _a = 0;
else if (_corr < 0.50) _a = lerp(0,    0.70, (_corr - 0.25) / 0.25);
else                   _a = lerp(0.70, 0.92, (_corr - 0.50) / 0.50);
if (_a > 0) {
    var _oc;
    if (_corr < 0.50)      _oc = make_color_rgb(150, 112, 62);
    else if (_corr < 0.75) _oc = merge_color(make_color_rgb(150,112,62), make_color_rgb(84,60,42),  (_corr-0.50)/0.25);
    else if (_corr < 0.85) _oc = make_color_rgb(84, 60, 42);
    else                   _oc = merge_color(make_color_rgb(84,60,42),    make_color_rgb(150,30,26), (_corr-0.85)/0.15);
    draw_set_alpha(_a);
    draw_set_color(_oc);
    draw_rectangle(_ix0, _ry1, _ix1, _ry2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// stone embankment along the north edge of the river
draw_set_color(make_color_rgb(150, 140, 118));
draw_rectangle(_ix0, _ry1 - _bankh, _ix1, _ry1, false);
draw_set_color(make_color_rgb(108, 98, 80));               // waterline shadow
draw_rectangle(_ix0, _ry1 - 4, _ix1, _ry1, false);
draw_set_color(c_white);

// ── central stone steps down to the water (the Ponte Vecchio exit) ────────────
// Geometry is shared with the south exit trigger in Create via these same numbers.
var _step_cx = _rw * 0.5;
var _step_w  = 192;                                        // 3 tiles wide
var _sx0 = _step_cx - _step_w * 0.5;
var _sx1 = _step_cx + _step_w * 0.5;
for (var _si = 0; _si < 5; _si++) {
    var _sy = _ry1 - _bankh + _si * 16;
    draw_set_color((_si mod 2 == 0) ? make_color_rgb(184, 174, 152) : make_color_rgb(124, 116, 100));
    draw_rectangle(_sx0, _sy, _sx1, _sy + 16, false);
}
draw_set_color(make_color_rgb(96, 90, 78));               // step side rails
draw_rectangle(_sx0 - 6, _ry1 - _bankh, _sx0, _ry2, false);
draw_rectangle(_sx1, _ry1 - _bankh, _sx1 + 6, _ry2, false);
draw_set_color(c_white);
