// =============================================================================
// scr_relief — GLOBAL normal-mapped floor relief (shd_floor_relief)
// =============================================================================
// The global system that replaced the dropped shd_ponte_floor POC (4845d20).
// SELF-CONTAINED: normal maps are DERIVED AT RUNTIME from the albedo sprite
// (luminance -> wrapped 3x3 blur -> wrapped Sobel -> OpenGL encode), cached
// per sprite — NO per-floor asset, no python step, no PixelLab (which cannot
// make normal maps). Any room's floor drawer wraps its tile loop in ONE call:
//
//     var _relief = scr_relief_begin(spr_my_floor);
//     ... draw_sprite_ext / draw_sprite_part_ext tile loop (frame 0) ...
//     if (_relief) scr_relief_end();
//
// DIVISION OF LABOUR with the global light map (scr_lightmap):
//   - scr_lightmap OWNS room darkness + the coloured glow pools (multiply).
//   - this shader NEVER darkens — near-white ambient, lights only add
//     normal-mapped RELIEF (stone edges catch the lantern, mortar stays
//     recessed). That is the fix for the POC "fighting" the light map.
// Both passes gather the SAME light sources with the SAME corruption snuff
// hash, so the relief pools sit exactly under the light-map glow pools.
//
// Daylight (glow <= 0): no point lights -> ambient-only -> the shader is a
// near-passthrough, so daytime floors look unchanged.
//
// NOT for procedural floors (flagstone rects etc.) — there is no albedo
// texture to derive relief from; those stay on the light map alone.
// =============================================================================

#macro RELIEF_MAX_LIGHTS     8
#macro RELIEF_NORMAL_STRENGTH 4.0

/// Returns true when the relief shader can run this frame.
function scr_relief_supported() {
    return shaders_are_supported() && shader_is_compiled(shd_floor_relief);
}

/// Byte index of the RED channel in buffer_get_surface data (BGRA on the DX
/// renderer, RGBA elsewhere) — detected ONCE with a 1x1 pure-red surface so
/// the encoded normal channels can never silently swap.
function scr_relief_red_index() {
    if (variable_global_exists("__relief_red_idx")) return global.__relief_red_idx;
    var _s = surface_create(1, 1);
    surface_set_target(_s);
    draw_clear(make_color_rgb(255, 0, 0));
    surface_reset_target();
    var _b = buffer_create(4, buffer_fixed, 1);
    buffer_get_surface(_b, _s, 0);
    global.__relief_red_idx = (buffer_peek(_b, 0, buffer_u8) >= 128) ? 0 : 2;
    buffer_delete(_b);
    surface_free(_s);
    return global.__relief_red_idx;
}

/// Derive (and cache) a tangent-space normal map sprite for an albedo sprite.
/// Same algorithm as tools/regen_floor_normal.py: luminance height, wrapped
/// 3x3 blur, wrapped Sobel, OpenGL +Y-up encode (mortar reads recessed).
/// One-time cost per sprite (~75k ops for 64x64), cached for the session.
function scr_relief_normal_for(_spr) {
    if (!variable_global_exists("__relief_normals")) global.__relief_normals = {};
    var _key = sprite_get_name(_spr);
    if (variable_struct_exists(global.__relief_normals, _key))
        return global.__relief_normals[$ _key];

    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _n = _w * _h;

    // grab the albedo pixels (part-draw ignores the sprite origin)
    var _surf = surface_create(_w, _h);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendenable(false);
    draw_sprite_part_ext(_spr, 0, 0, 0, _w, _h, 0, 0, 1, 1, c_white, 1);
    gpu_set_blendenable(true);
    surface_reset_target();
    var _buf = buffer_create(_n * 4, buffer_fixed, 1);
    buffer_get_surface(_buf, _surf, 0);

    // luminance height field (plain average — channel-order agnostic)
    var _hgt = array_create(_n);
    for (var _i = 0; _i < _n; _i++) {
        var _o = _i * 4;
        _hgt[_i] = (buffer_peek(_buf, _o,     buffer_u8)
                  + buffer_peek(_buf, _o + 1, buffer_u8)
                  + buffer_peek(_buf, _o + 2, buffer_u8)) / 765;
    }
    // wrapped 3x3 box blur (tile-safe) to soften pixel noise
    var _bl = array_create(_n);
    for (var _y = 0; _y < _h; _y++) {
        var _ym = ((_y - 1) + _h) mod _h, _yp = (_y + 1) mod _h;
        for (var _x = 0; _x < _w; _x++) {
            var _xm = ((_x - 1) + _w) mod _w, _xp = (_x + 1) mod _w;
            _bl[_y * _w + _x] =
                ( _hgt[_ym * _w + _xm] + _hgt[_ym * _w + _x] + _hgt[_ym * _w + _xp]
                + _hgt[_y  * _w + _xm] + _hgt[_y  * _w + _x] + _hgt[_y  * _w + _xp]
                + _hgt[_yp * _w + _xm] + _hgt[_yp * _w + _x] + _hgt[_yp * _w + _xp]) / 9;
        }
    }
    // wrapped Sobel -> normal -> encode into the same buffer
    var _ri = scr_relief_red_index();      // red byte index (0 or 2)
    var _bi = 2 - _ri;                     // blue is the mirror
    for (var _y = 0; _y < _h; _y++) {
        var _ym = ((_y - 1) + _h) mod _h, _yp = (_y + 1) mod _h;
        for (var _x = 0; _x < _w; _x++) {
            var _xm = ((_x - 1) + _w) mod _w, _xp = (_x + 1) mod _w;
            var _gx = _bl[_ym * _w + _xm] + 2 * _bl[_y * _w + _xm] + _bl[_yp * _w + _xm]
                    - _bl[_ym * _w + _xp] - 2 * _bl[_y * _w + _xp] - _bl[_yp * _w + _xp];
            var _gy = _bl[_ym * _w + _xm] + 2 * _bl[_ym * _w + _x] + _bl[_ym * _w + _xp]
                    - _bl[_yp * _w + _xm] - 2 * _bl[_yp * _w + _x] - _bl[_yp * _w + _xp];
            var _nx =  _gx * RELIEF_NORMAL_STRENGTH;
            var _ny = -_gy * RELIEF_NORMAL_STRENGTH;   // screen y down -> GL green up
            var _ln = sqrt(_nx * _nx + _ny * _ny + 1);
            var _o  = (_y * _w + _x) * 4;
            buffer_poke(_buf, _o + _ri, buffer_u8, round((_nx / _ln + 1) * 127.5));
            buffer_poke(_buf, _o + 1,   buffer_u8, round((_ny / _ln + 1) * 127.5));
            buffer_poke(_buf, _o + _bi, buffer_u8, round((1   / _ln + 1) * 127.5));
            buffer_poke(_buf, _o + 3,   buffer_u8, 255);
        }
    }
    buffer_set_surface(_buf, _surf, 0);
    var _nrm = sprite_create_from_surface(_surf, 0, 0, _w, _h, false, false, 0, 0);
    buffer_delete(_buf);
    surface_free(_surf);
    global.__relief_normals[$ _key] = _nrm;
    return _nrm;
}

/// Begin the relief pass for one floor. Returns true when the shader is set
/// (caller MUST call scr_relief_end() after the tile loop), false to fall
/// back to the plain loop (no shader set — drawing proceeds untouched).
/// _albedo_spr: the tile sprite the loop draws (frame 0).
/// _normal_spr: OPTIONAL hand-made normal map; omit to auto-derive (cached).
function scr_relief_begin(_albedo_spr, _normal_spr = -1) {
    if (!scr_relief_supported()) return false;
    if (!sprite_exists(_albedo_spr)) return false;
    if (!variable_global_exists("game_hour")) return false;
    if (_normal_spr == -1) _normal_spr = scr_relief_normal_for(_albedo_spr);
    if (!sprite_exists(_normal_spr)) return false;

    var _L = scr_time_lighting();

    // ── gather the SAME lights the light map stamps (sprite-name heuristic,
    //    same radii ratios, same corruption snuff hash → pools line up) ──────
    var _lights = array_create(RELIEF_MAX_LIGHTS * 3, 0);
    var _lc = 0;
    if (_L.glow > 0.01) {
        var _dark_frac = 0;
        if (_L.corr >= 1.0)       _dark_frac = 0.90;
        else if (_L.corr >= 0.75) _dark_frac = 0.50;
        else if (_L.corr >= 0.50) _dark_frac = 0.15;
        // view centre — nearest lights win the 8 slots
        var _cam = view_camera[0];
        var _vcx = camera_get_view_x(_cam) + camera_get_view_width(_cam)  * 0.5;
        var _vcy = camera_get_view_y(_cam) + camera_get_view_height(_cam) * 0.5;
        // collect candidates [x, y, radius, dist2]
        var _cand = [];
        with (all) {
            if (sprite_index == -1 || !visible) continue;
            var _nm = sprite_get_name(sprite_index);
            var _r = 0;
            if (string_pos("torch", _nm) > 0)        _r = 190;
            else if (string_pos("lantern", _nm) > 0) _r = 170;
            else if (string_pos("candle", _nm) > 0)  _r = 80;
            else if (string_pos("shrine", _nm) > 0)  _r = 70;
            if (_r == 0) continue;
            if (string_pos("shrine", _nm) > 0 && _L.corr >= 1) continue;   // she is gone
            var _hash = (((x div 16) * 73 + (y div 16) * 151) mod 100) / 100;
            if (_hash < _dark_frac) continue;                              // snuffed
            var _lx = (bbox_left + bbox_right) * 0.5;
            var _ly = bbox_top + (bbox_bottom - bbox_top) * 0.30;          // lamp head
            array_push(_cand, [_lx, _ly, _r, sqr(_lx - _vcx) + sqr(_ly - _vcy)]);
        }
        array_sort(_cand, function(_a, _b) { return _a[3] - _b[3]; });
        _lc = min(array_length(_cand), RELIEF_MAX_LIGHTS);
        for (var _i = 0; _i < _lc; _i++) {
            _lights[_i * 3]     = _cand[_i][0];
            _lights[_i * 3 + 1] = _cand[_i][1];
            _lights[_i * 3 + 2] = _cand[_i][2];
        }
    }

    // shared light colour: warm lantern flame; green remnants at corr 100
    var _green = (_L.corr >= 1.0);
    var _lr = _green ?  70 / 255 : 255 / 255;
    var _lg = _green ? 235 / 255 : 205 / 255;
    var _lb = _green ? 110 / 255 : 120 / 255;
    var _gain = _L.glow;                       // night strength gates the relief

    var _auv = sprite_get_uvs(_albedo_spr, 0);
    var _nuv = sprite_get_uvs(_normal_spr, 0);

    shader_set(shd_floor_relief);
    texture_set_stage(shader_get_sampler_index(shd_floor_relief, "u_normal_tex"),
                      sprite_get_texture(_normal_spr, 0));
    shader_set_uniform_f(shader_get_uniform(shd_floor_relief, "u_albedo_uvs"),
                         _auv[0], _auv[1], _auv[2] - _auv[0], _auv[3] - _auv[1]);
    shader_set_uniform_f(shader_get_uniform(shd_floor_relief, "u_normal_uvs"),
                         _nuv[0], _nuv[1], _nuv[2] - _nuv[0], _nuv[3] - _nuv[1]);
    shader_set_uniform_f(shader_get_uniform(shd_floor_relief, "u_light_count"), _lc);
    shader_set_uniform_f_array(shader_get_uniform(shd_floor_relief, "u_lights"), _lights);
    shader_set_uniform_f(shader_get_uniform(shd_floor_relief, "u_light_color"),
                         _lr * _gain, _lg * _gain, _lb * _gain);
    // near-white ambient: relief never darkens — scr_lightmap owns darkness
    shader_set_uniform_f(shader_get_uniform(shd_floor_relief, "u_ambient"),
                         0.96, 0.96, 0.96);
    return true;
}

/// End the relief pass (only when scr_relief_begin returned true).
function scr_relief_end() {
    shader_reset();
}
