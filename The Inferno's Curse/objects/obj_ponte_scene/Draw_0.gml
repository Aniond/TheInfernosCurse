// =============================================================================
// obj_ponte_scene — Draw  (depth 160: behind the player at depth 100)
// =============================================================================
// Paints the Ponte Vecchio crossing top-down (ref: references/Ponte Vecchio.png):
//   1) deep base fill
//   2) animated Arno water in the left & right columns — SAME system as Room1
//      (spr_florence_water tiles + the identical Limbo-corruption flow/colour
//       progression), scrolling along the channel
//   3) cobble bridge core: wide landings N & S + the 4-cell central walkway
//   4) stacked shop SPRITES (spr_bridge_shop_left / _right) down both sides, each
//      with a terracotta roof + warm window baked in, plus a warm light spill
//   5) stone parapets at the water's edge + a few moored boats on the Arno
//   6) NORTH / SOUTH landing plaques
// =============================================================================
if (room != Room_ponte_vecchio) exit;

var _rw = room_width;    // 576
var _rh = room_height;   // 896

// zone metrics (mirror Create_0 + the layout)
var _wat_l = 32;            // left water column  x[0,32]
var _wat_r = _rw - 32;      // right water starts  x[544,576]
var _cx0   = 32,  _cx1 = _rw - 32;   // cobble core x[32,544]
var _shp_l = 32,  _shp_r = 416;      // shop column left edges
var _shp_y0 = 128, _shp_y1 = 768;    // shop span (cobble landings above/below)

// ── 1. base fill (deep Arno, so nothing smears) ────────────────────────────────
draw_set_color(make_color_rgb(30, 42, 47));
draw_rectangle(0, 0, _rw, _rh, false);

// ── 2. ANIMATED ARNO — left & right water columns ──────────────────────────────
// Identical corruption staging to obj_street_scene: forward & easing until 50%,
// slower (floored) to 75%, then the current REVERSES and reddens to 100%.
var _ww   = sprite_get_width(spr_florence_water);    // 64
var _wh   = sprite_get_height(spr_florence_water);   // 64
var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);

var _spd;
if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);
else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);
else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);
var _scroll = (current_time / 1000 * _spd) mod _wh;   // scroll along the channel (N–S)

draw_set_color(c_white);
for (var _wy = -_wh + _scroll; _wy < _rh; _wy += _wh) {
    for (var _wx = 0; _wx < _wat_l; _wx += _ww)   draw_sprite(spr_florence_water, 0, _wx, _wy);   // left column
    for (var _wx = _wat_r; _wx < _rw; _wx += _ww) draw_sprite(spr_florence_water, 0, _wx, _wy);   // right column
}

// ── 3. cobble bridge core (covers any water overshoot at x32 / x544) ───────────
var _cob = [spr_florence_plaza,     spr_florence_plaza_v2,  spr_florence_plaza_v3,  spr_florence_plaza_v4,
            spr_florence_plaza_v5,  spr_florence_plaza_v6,  spr_florence_plaza_v7,  spr_florence_plaza_v8,
            spr_florence_plaza_v9,  spr_florence_plaza_v10, spr_florence_plaza_v11, spr_florence_plaza_v12,
            spr_florence_plaza_v13, spr_florence_plaza_v14, spr_florence_plaza_v15, spr_florence_plaza_v16];
for (var _cy = 0; _cy < _rh; _cy += 64) {
    for (var _ccx = _cx0; _ccx < _cx1; _ccx += 64) {
        var _ci = (((_ccx div 64) * 7) + ((_cy div 64) * 13)) mod 16;
        draw_sprite_part(_cob[_ci], 0, 0, 0, min(64, _cx1 - _ccx), min(64, _rh - _cy), _ccx, _cy);
    }
}

// ── 2b. corruption colour bleed over the EXPOSED water only ─────────────────────
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
    draw_rectangle(0,      0, _wat_l, _rh, false);   // left channel
    draw_rectangle(_wat_r, 0, _rw,    _rh, false);   // right channel
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// ── 5a. boats on the Arno — 3 total (2 left, 1 right), slow drift ───────────────
// Calm water: spr_boat_rowing gently bobs as if moored/being rowed. At Limbo
// corruption >= 50% the hull swaps to spr_boat_abandoned and drifts AIMLESSLY (no
// heading). Drawn centred (origin is top-left) and scaled to fit the narrow channel.
var _abandoned = (_corr >= 0.50);
var _bspr = spr_boat_rowing;
if (_abandoned) _bspr = spr_boat_abandoned;
var _bsc = 0.4;                                            // boat scale (per request)
var _bhw = sprite_get_width(_bspr)  * _bsc * 0.5;
var _bhh = sprite_get_height(_bspr) * _bsc * 0.5;
var _bt  = current_time / 1000;
// [base_x, base_y, phase] — two on the LEFT Arno, one on the RIGHT; scattered
var _boats = [[15, 235, 0.0], [18, 600, 2.3], [560, 410, 4.1]];
for (var _bi = 0; _bi < array_length(_boats); _bi++) {
    var _bx = _boats[_bi][0];
    var _by = _boats[_bi][1];
    var _ph = _boats[_bi][2];
    if (_abandoned) {
        _bx += sin(_bt * 0.17 + _ph)       * 5;            // aimless wander, no direction
        _by += sin(_bt * 0.11 + _ph * 1.7) * 16 + cos(_bt * 0.06 + _ph) * 5;
    } else {
        _bx += sin(_bt * 0.50 + _ph) * 2;                  // calm moored bob
        _by += sin(_bt * 0.33 + _ph) * 6;
    }
    draw_sprite_ext(_bspr, 0, _bx - _bhw, _by - _bhh, _bsc, _bsc, 0, c_white, 1);
}
draw_set_color(c_white);

// ── 5b. stone parapets along the water's edge ──────────────────────────────────
draw_set_color(make_color_rgb(120, 112, 92));
draw_rectangle(_cx0 - 6, 0, _cx0,     _rh, false);   // left edge
draw_rectangle(_cx1,     0, _cx1 + 6, _rh, false);   // right edge
draw_set_color(make_color_rgb(160, 150, 128));       // lit top of the curb
draw_rectangle(_cx0 - 6, 0, _cx0 - 3, _rh, false);
draw_rectangle(_cx1 + 3, 0, _cx1 + 6, _rh, false);
draw_set_color(c_white);

// ── 4. shops — stacked spr_bridge_shop_left / _right down the full span ─────────
var _sh = sprite_get_height(spr_bridge_shop_left);    // 128
var _shop_n = (_shp_y1 - _shp_y0) div _sh;            // 5 (640 / 128)
for (var _si = 0; _si < _shop_n; _si++) {
    var _sy = _shp_y0 + _si * _sh;
    draw_sprite(spr_bridge_shop_left,  0, _shp_l, _sy);   // left column  x[32,160], balcony faces walkway
    draw_sprite(spr_bridge_shop_right, 0, _shp_r, _sy);   // right column x[416,544]
}

// warm light spilling from the shop windows onto the walkway edge (additive)
gpu_set_blendmode(bm_add);
draw_set_color(make_color_rgb(74, 46, 14));
for (var _si = 0; _si < _shop_n; _si++) {
    var _gy = _shp_y0 + _si * _sh + _sh * 0.58;          // ~window height
    draw_circle(_shp_l + _sh, _gy, 30, false);           // left  → spills RIGHT onto walkway
    draw_circle(_shp_r,       _gy, 30, false);           // right → spills LEFT onto walkway
}
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);

// (NORTH / SOUTH text plaques removed — the statue rows are the natural guides now.)
