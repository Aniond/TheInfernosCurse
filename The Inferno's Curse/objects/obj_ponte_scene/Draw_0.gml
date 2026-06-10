// =============================================================================
// obj_ponte_scene — Draw (depth 160) — NARROW BRIDGE (1280x512, 20x8 cells)
// =============================================================================
// water N y0-64 · shops N y64-160 · WALKWAY y160-352 · shops S y352-448 ·
// water S y448-512. Claustrophobic — like the real Ponte Vecchio.
// 1) thin animated Arno strips N+S — same water + corruption staging as v2
// 2) arch crowns hinted in the south strip
// 3) the deck — SOLID warm stone fill (no tile strips) + subtle joints
// 4) parapets — VOID WALL + ART (scr_ponte_walls = the collision)
// 5) small boats drifting the strips
// 6) corruption sync (shops close, gulls leave, fountain dies, chronicle)
// =============================================================================
if (room_get_name(room) != "Room_ponte_vecchio") exit;

var _corr   = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _corr01 = _corr;

// ── 1. the Arno strips (flow W→E; slows; REVERSES at 75%) — FIX 3 ─────────────
var _spd;
if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);
else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);
else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);
var _ww = sprite_get_width(spr_florence_water);
var _scroll = (current_time / 1000 * _spd) mod _ww;
for (var _wx = -_ww + _scroll; _wx < room_width; _wx += _ww) {
    draw_sprite(spr_florence_water, 0, _wx, 0);            // north strip y0-64
    draw_sprite(spr_florence_water, 0, _wx, 448);          // south strip y448-512
}
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
    draw_rectangle(0, 0, room_width, 64, false);
    draw_rectangle(0, 448, room_width, room_height, false);
    draw_set_alpha(1); draw_set_color(c_white);
}

// ── 2. arch crowns hinted in the south strip ───────────────────────────────────
var _pier_col = merge_color(make_color_rgb(142, 132, 114), make_color_rgb(72, 74, 84), _corr01);
for (var _p = 0; _p < 4; _p++) {
    var _px = 188 + _p * 300;
    draw_set_color(_pier_col);
    draw_rectangle(_px, 474, _px + 56, 506, false);          // pier tops at the waterline
    draw_set_color(c_black);
    draw_set_alpha(0.30);
    draw_rectangle(_px, 500, _px + 56, 506, false);
    draw_set_alpha(1);
}
draw_set_color(c_white);

// ── 3. the deck — SOLID warm stone (FIX 2: no strips, no gaps) ─────────────────
// shop bands get the plain foundation tone; the WALKWAY gets the worn-stone
// fill with subtle deterministic joint lines (drawn flat — guaranteed seamless)
var _found = merge_color(make_color_rgb(146, 132, 110), make_color_rgb(70, 68, 74), _corr01 * 0.4);
draw_set_color(_found);
draw_rectangle(0, 64, room_width, 448, false);
var _stone = merge_color(make_color_rgb(176, 160, 134), make_color_rgb(84, 80, 84), _corr01 * 0.4);
draw_set_color(_stone);
draw_rectangle(0, 160, room_width, 352, false);
// faint joint lines + worn patches (deterministic, low alpha — texture, not strips)
draw_set_alpha(0.08);
draw_set_color(make_color_rgb(60, 52, 44));
for (var _jx = 0; _jx < room_width; _jx += 32) draw_line(_jx, 160, _jx - 12, 352);
for (var _jy = 176; _jy < 352; _jy += 24) draw_line(0, _jy, room_width, _jy);
draw_set_alpha(0.05);
draw_set_color(c_white);
for (var _wp = 0; _wp < 26; _wp++) {
    var _wpx = ((_wp * 97) mod 19) * 64 + ((_wp * 31) mod 48);
    var _wpy = 176 + ((_wp * 53) mod 160);
    draw_circle(_wpx, _wpy, 14 + (_wp mod 9), false);
}
draw_set_alpha(1);
draw_set_color(c_white);

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

// ── 5. small boats drifting the strips (follow the current) ────────────────────
var _boat = asset_get_index("spr_arno_rowing_boat");
if (_boat >= 0 && asset_get_type("spr_arno_rowing_boat") == asset_sprite) {
    var _drift = current_time / 1000 * _spd * 0.6;
    var _lane  = room_width - 96;
    var _bob   = 2 * sin(current_time * 0.002);
    var _b1 = 48 + (((_drift + 150)       mod _lane) + _lane) mod _lane;
    var _b2 = 48 + (((_drift * 0.85 + 700) mod _lane) + _lane) mod _lane;
    draw_sprite_ext(_boat, 0, _b1, 58  + _bob, 0.6, 0.6, 90, c_white, 1);
    draw_sprite_ext(_boat, 0, _b2, 508 - _bob, 0.6, 0.6, 90, c_white, 1);
}

// ── 6. corruption: shops close, gulls leave, the fountain dies ─────────────────
scr_ponte_corruption_sync();
