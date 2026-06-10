// =============================================================================
// obj_ponte_scene — Draw (depth 160: under the props/player) — REBUILT 2026-06-10
// =============================================================================
// 1) the Arno, north and south bands — same animated water + corruption colour
//    progression as Room_florence_v2, flowing WEST→EAST (reverses at 75%)
// 2) stone ARCH foundations in the south water (the reference's signature)
// 3) the deck — spr_ponte_floor_cobble across the full bridge
// 4) parapets — VOID WALL + ART bands (scr_ponte_walls, also the collision)
// 5) rowing boats drifting with the current, gulls handled as props
// 6) corruption sync (shops close, gulls leave, fountain dies, chronicle)
// =============================================================================
if (room_get_name(room) != "Room_ponte_vecchio") exit;

var _corr   = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _corr01 = _corr;

// ── 1. the Arno (flows W→E; slows with corruption; REVERSES at 75%) ────────────
var _spd;
if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);
else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);
else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);
var _ww = sprite_get_width(spr_florence_water);
var _scroll = (current_time / 1000 * _spd) mod _ww;
for (var _wy = 0; _wy < 192; _wy += 64)
    for (var _wx = -_ww + _scroll; _wx < room_width; _wx += _ww)
        draw_sprite(spr_florence_water, 0, _wx, _wy);
for (var _wy2 = 672; _wy2 < room_height; _wy2 += 64)
    for (var _wx2 = -_ww + _scroll; _wx2 < room_width; _wx2 += _ww)
        draw_sprite(spr_florence_water, 0, _wx2, _wy2);
// corruption colour bleed — identical staging to the city river
var _wa;
if (_corr < 0.25)      _wa = 0;
else if (_corr < 0.50) _wa = lerp(0,    0.70, (_corr - 0.25) / 0.25);
else                   _wa = lerp(0.70, 0.92, (_corr - 0.50) / 0.50);
if (_wa > 0) {
    var _oc;
    if (_corr < 0.50)      _oc = make_color_rgb(150, 112, 62);
    else if (_corr < 0.75) _oc = merge_color(make_color_rgb(150,112,62), make_color_rgb(84,60,42),  (_corr-0.50)/0.25);
    else if (_corr < 0.85) _oc = make_color_rgb(84, 60, 42);
    else                   _oc = merge_color(make_color_rgb(84,60,42),   make_color_rgb(150,30,26), (_corr-0.85)/0.15);
    draw_set_alpha(_wa); draw_set_color(_oc);
    draw_rectangle(0, 0, room_width, 192, false);
    draw_rectangle(0, 672, room_width, room_height, false);
    draw_set_alpha(1); draw_set_color(c_white);
}

// ── 2. stone arch foundations (south water, per the reference) ─────────────────
var _pier_col = merge_color(make_color_rgb(142, 132, 114), make_color_rgb(72, 74, 84), _corr01);
var _arch_col = merge_color(make_color_rgb(106, 98, 86),   make_color_rgb(56, 58, 66), _corr01);
for (var _p = 0; _p < 4; _p++) {
    var _px = 188 + _p * 300;                       // 4 piers across the span
    draw_set_color(_arch_col);
    draw_circle(_px + 150, 700, 96, false);          // arch crown peeking below deck
    draw_set_color(_pier_col);
    draw_rectangle(_px, 696, _px + 56, 808, false);  // pier shaft
    draw_set_color(c_black);
    draw_rectangle(_px, 800, _px + 56, 808, false);  // waterline shadow
}
draw_set_color(c_white);

// ── 3. the deck — worn cobble across the whole bridge ──────────────────────────
var _t_floor = asset_get_index("spr_ponte_floor_cobble");
if (_t_floor >= 0 && asset_get_type("spr_ponte_floor_cobble") == asset_sprite) {
    for (var _fy = 192; _fy < 672; _fy += 64)
        for (var _fx = 0; _fx < room_width; _fx += 64)
            draw_sprite(_t_floor, 0, _fx, _fy);
} else {
    draw_set_color(make_color_rgb(168, 152, 128));   // fallback until imported
    draw_rectangle(0, 192, room_width, 672, false);
    draw_set_color(c_white);
}

// ── 4. parapets — VOID WALL + ART (same rects as the collision) ────────────────
var _pw = scr_ponte_walls();
var _band = asset_get_index("spr_florence_thin_wall");
var _has_band = (_band >= 0 && asset_get_type("spr_florence_thin_wall") == asset_sprite);
for (var _b = 0; _b < array_length(_pw); _b++) {
    var _s = _pw[_b];
    draw_set_color(c_black);
    draw_rectangle(_s[0], _s[1], _s[2], _s[3], false);
    if (_has_band) {
        for (var _bx = _s[0]; _bx < _s[2]; _bx += 64) {
            var _wsrc = min(128, (_s[2] - _bx) * 2);
            draw_sprite_part_ext(_band, 0, 0, 0, _wsrc, 32, _bx, _s[1] + 4, 0.5, 0.5, c_white, 1);
        }
    }
}
draw_set_color(c_white);

// ── 5. rowing boats adrift (2 per band; drift follows the current) ─────────────
var _boat = asset_get_index("spr_arno_rowing_boat");
if (_boat >= 0 && asset_get_type("spr_arno_rowing_boat") == asset_sprite) {
    var _drift = current_time / 1000 * _spd * 0.6;
    var _lane  = room_width - 128;
    var _bob   = 3 * sin(current_time * 0.002);
    var _b1 = 64 + (((_drift + 150)       mod _lane) + _lane) mod _lane;
    var _b2 = 64 + (((_drift * 0.8 + 700) mod _lane) + _lane) mod _lane;
    var _b3 = 64 + (((_drift * 1.1 + 350) mod _lane) + _lane) mod _lane;
    var _b4 = 64 + (((_drift * 0.9 + 990) mod _lane) + _lane) mod _lane;
    draw_sprite_ext(_boat, 0, _b1, 52  + _bob, 1, 1, 90, c_white, 1);
    draw_sprite_ext(_boat, 0, _b2, 120 - _bob, 1, 1, 90, c_white, 1);
    draw_sprite_ext(_boat, 0, _b3, 800 + _bob, 1, 1, 90, c_white, 1);
    draw_sprite_ext(_boat, 0, _b4, 856 - _bob, 1, 1, 90, c_white, 1);
}

// ── 6. corruption: shops close, gulls leave, the fountain dies ─────────────────
scr_ponte_corruption_sync();
