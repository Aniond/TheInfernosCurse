// =============================================================================
// scr_relief — GLOBAL normal-mapped floor relief (shd_floor_relief)
// =============================================================================
// The global system that replaced the dropped shd_ponte_floor POC (4845d20).
// Any room's floor drawer wraps its tile loop:
//
//     var _relief = scr_relief_begin(spr_my_floor, spr_my_floor_normal);
//     ... draw_sprite_ext tile loop (one albedo sprite, frame 0) ...
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
// near-passthrough, so the daytime floor looks unchanged.
//
// Normal maps are DERIVED from the albedo (PixelLab cannot make them):
// tools/regen_floor_normal.py — luminance -> wrapped Sobel -> OpenGL encode.
// =============================================================================

#macro RELIEF_MAX_LIGHTS 8

/// Returns true when the relief shader can run this frame.
function scr_relief_supported() {
    return shaders_are_supported() && shader_is_compiled(shd_floor_relief);
}

/// Begin the relief pass for one floor. Returns true when the shader is set
/// (caller MUST call scr_relief_end() after the tile loop), false to fall
/// back to the plain loop (no shader set — drawing proceeds untouched).
/// _albedo_spr: the tile sprite the loop draws (frame 0).
/// _normal_spr: its derived normal map (same texel layout).
function scr_relief_begin(_albedo_spr, _normal_spr) {
    if (!scr_relief_supported()) return false;
    if (!sprite_exists(_albedo_spr) || !sprite_exists(_normal_spr)) return false;
    if (!variable_global_exists("game_hour")) return false;

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
