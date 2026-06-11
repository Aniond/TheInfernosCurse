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

// ── 3. the deck (FIX 2 final): shop bands = plain foundation tone; the
//      WALKWAY = the seamless cobble tile (edge-crossfaded at import so the
//      64px repeats cannot show seams). NO line overlays — nothing to strip.
var _found = merge_color(make_color_rgb(146, 132, 110), make_color_rgb(70, 68, 74), _corr01 * 0.4);
draw_set_color(_found);
draw_rectangle(0, 64, room_width, 448, false);
draw_set_color(c_white);
var _t_floor = asset_get_index("spr_ponte_floor_cobble");
if (_t_floor >= 0 && asset_get_type("spr_ponte_floor_cobble") == asset_sprite) {
    var _ftint = merge_color(c_white, make_color_rgb(96, 92, 100), _corr01 * 0.4);

    // ── NORMAL-MAPPED DYNAMIC LIGHTING (POC, 2026-06-10) ──────────────────────
    // shd_ponte_floor lights the walkway from the lantern posts: normal map
    // derived from the cobble albedo, light colour = time of day x corruption
    // (scr_ponte_light_color), ambient = scr_ponte_ambient_color. Falls back
    // to the plain tint loop if shaders are unavailable.
    var _use_shader = shaders_are_supported() && shader_is_compiled(shd_ponte_floor);
    if (_use_shader) {
        // gather lantern lights (max 8 — shader MAX_LIGHTS)
        var _lights = array_create(24, 0);
        var _lc = 0;
        if (variable_global_exists("room_builder_objects")) {
            var _objs = global.room_builder_objects;
            for (var _li = 0; _li < array_length(_objs) && _lc < 8; _li++) {
                var _lo = _objs[_li];
                if (!instance_exists(_lo)) continue;
                if (!variable_instance_exists(_lo, "builder_sprite")) continue;
                if (_lo.builder_sprite != "spr_ponte_lantern_post") continue;
                _lights[_lc * 3]     = _lo.x + sprite_get_width(spr_ponte_lantern_post) * 0.5 * _lo.image_xscale;
                _lights[_lc * 3 + 1] = _lo.y + 12;   // the lamp head, not the post base
                _lights[_lc * 3 + 2] = 170;          // pool radius in px
                _lc++;
            }
        }
        var _lcol = scr_ponte_light_color();
        var _amb  = scr_ponte_ambient_color();
        var _auv  = sprite_get_uvs(_t_floor, 0);
        var _nuv  = sprite_get_uvs(spr_ponte_floor_normal, 0);

        shader_set(shd_ponte_floor);
        texture_set_stage(shader_get_sampler_index(shd_ponte_floor, "u_normal_tex"),
                          sprite_get_texture(spr_ponte_floor_normal, 0));
        shader_set_uniform_f(shader_get_uniform(shd_ponte_floor, "u_albedo_uvs"),
                             _auv[0], _auv[1], _auv[2] - _auv[0], _auv[3] - _auv[1]);
        shader_set_uniform_f(shader_get_uniform(shd_ponte_floor, "u_normal_uvs"),
                             _nuv[0], _nuv[1], _nuv[2] - _nuv[0], _nuv[3] - _nuv[1]);
        shader_set_uniform_f(shader_get_uniform(shd_ponte_floor, "u_light_count"), _lc);
        shader_set_uniform_f_array(shader_get_uniform(shd_ponte_floor, "u_lights"), _lights);
        shader_set_uniform_f(shader_get_uniform(shd_ponte_floor, "u_light_color"),
                             color_get_red(_lcol) / 255, color_get_green(_lcol) / 255, color_get_blue(_lcol) / 255);
        shader_set_uniform_f(shader_get_uniform(shd_ponte_floor, "u_ambient"),
                             color_get_red(_amb) / 255, color_get_green(_amb) / 255, color_get_blue(_amb) / 255);

        for (var _fy = 160; _fy < 352; _fy += 64)
            for (var _fx = 0; _fx < room_width; _fx += 64)
                draw_sprite_ext(_t_floor, 0, _fx, _fy, 1, 1, 0, _ftint, 1);

        shader_reset();
    } else {
        for (var _fy = 160; _fy < 352; _fy += 64)
            for (var _fx = 0; _fx < room_width; _fx += 64)
                draw_sprite_ext(_t_floor, 0, _fx, _fy, 1, 1, 0, _ftint, 1);
    }
} else {
    draw_set_color(merge_color(make_color_rgb(176, 160, 134), make_color_rgb(84, 80, 84), _corr01 * 0.4));
    draw_rectangle(0, 160, room_width, 352, false);
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
