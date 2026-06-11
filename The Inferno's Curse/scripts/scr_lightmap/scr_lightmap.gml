// =============================================================================
// scr_lightmap — GLOBAL surface light map (true multiply lighting)
// =============================================================================
// Upgrades the day/night pass in obj_game_manager Draw GUI from "darken tint +
// additive glow circles" to a real light map:
//   1. an offscreen surface is cleared to the AMBIENT colour (the time-of-day
//      phase tint converted to a multiplier, corruption-darkened),
//   2. every torch/lantern/candle/shrine instance stamps a soft radial glow
//      into the surface additively (same snuff/flicker/green-remnant staging
//      as before — scr_time_lighting drives everything),
//   3. the surface multiplies over the whole frame in ONE draw call
//      (bm_dest_colour x bm_zero) — light pools genuinely restore local
//      colour out of the darkness instead of washing over it.
// Works in EVERY room with zero room-specific code. Battle gets ambient only
// (its own staging, no world lights). Moon + stars remain additive on top,
// drawn by the manager after this pass.
// =============================================================================

/// Lazily build the soft radial glow sprite (128px, centre origin).
function scr_lightmap_glow_sprite() {
    if (variable_global_exists("__lightmap_glow") && sprite_exists(global.__lightmap_glow))
        return global.__lightmap_glow;
    var _s = 128, _h = _s div 2;
    var _surf = surface_create(_s, _s);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    // accumulate concentric circles — smooth falloff, hot centre
    for (var _r = _h; _r >= 1; _r--) {
        draw_set_alpha(0.005 + 0.045 * power(1 - _r / _h, 2));
        draw_circle(_h, _h, _r, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    surface_reset_target();
    global.__lightmap_glow = sprite_create_from_surface(_surf, 0, 0, _s, _s, false, false, _h, _h);
    surface_free(_surf);
    return global.__lightmap_glow;
}

/// The full light-map pass. Call from obj_game_manager Draw GUI in place of
/// the old tint + glow sections. No-ops in full daylight (multiply by white).
function scr_lightmap_draw() {
    if (!variable_global_exists("game_hour")) return;
    var _L  = scr_time_lighting();
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // ambient = the phase tint as a true multiplier (white = untouched midday)
    var _amb = merge_color(c_white, _L.col, _L.alpha);
    if (_amb == c_white && _L.glow <= 0.01) return;

    // (re)create the surface — surfaces are volatile, size tracks the GUI
    if (!variable_global_exists("__lightmap_surf")) global.__lightmap_surf = -1;
    if (!surface_exists(global.__lightmap_surf)
     || surface_get_width(global.__lightmap_surf)  != _gw
     || surface_get_height(global.__lightmap_surf) != _gh) {
        if (surface_exists(global.__lightmap_surf)) surface_free(global.__lightmap_surf);
        global.__lightmap_surf = surface_create(_gw, _gh);
    }

    surface_set_target(global.__lightmap_surf);
    draw_clear(_amb);

    // ── light pools (not in battle — own staging) ─────────────────────────────
    if (room != room_battle && _L.glow > 0.01) {
        var _cam = view_camera[0];
        var _cx  = camera_get_view_x(_cam),     _cy = camera_get_view_y(_cam);
        var _cw  = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);
        if (_cw > 0 && _ch > 0) {
            var _sx = _gw / _cw, _sy = _gh / _ch;
            // corruption snuffs lights: fraction that stay dark (stable per-light hash)
            var _dark_frac = 0;
            if (_L.corr >= 1.0)       _dark_frac = 0.90;
            else if (_L.corr >= 0.75) _dark_frac = 0.50;
            else if (_L.corr >= 0.50) _dark_frac = 0.15;
            var _green = (_L.corr >= 1.0);     // the remnants burn wrong
            var _glow_spr = scr_lightmap_glow_sprite();
            gpu_set_blendmode(bm_add);
            with (all) {
                if (sprite_index == -1 || !visible) continue;
                var _nm = sprite_get_name(sprite_index);
                var _r = 0;
                if (string_pos("torch", _nm) > 0)        _r = 110;
                else if (string_pos("lantern", _nm) > 0) _r = 80;
                else if (string_pos("candle", _nm) > 0)  _r = 40;
                else if (string_pos("shrine", _nm) > 0)  _r = 34;
                if (_r == 0) continue;
                if (string_pos("shrine", _nm) > 0 && _L.corr >= 1) continue;   // she is gone
                var _hash = (((x div 16) * 73 + (y div 16) * 151) mod 100) / 100;
                if (_hash < _dark_frac) continue;
                var _lx = ((bbox_left + bbox_right) * 0.5 - _cx) * _sx;
                var _ly = (bbox_top + (bbox_bottom - bbox_top) * 0.30 - _cy) * _sy;
                if (_lx < -160 || _ly < -160 || _lx > _gw + 160 || _ly > _gh + 160) continue;
                var _flick = 1 + 0.08 * sin(current_time * 0.004 + x * 0.13 + y * 0.07);
                var _col   = _green ? make_color_rgb(70, 235, 110)
                                    : make_color_rgb(255, 205, 120);
                var _sc    = (_r * _sx * _flick) / 64;     // glow sprite radius = 64
                draw_sprite_ext(_glow_spr, 0, _lx, _ly, _sc, _sc, 0, _col, _L.glow);
                draw_sprite_ext(_glow_spr, 0, _lx, _ly, _sc * 0.45, _sc * 0.45, 0, _col, _L.glow * 0.7);
            }
            gpu_set_blendmode(bm_normal);
        }
    }
    surface_reset_target();

    // ── multiply the map over the frame — ONE draw call ───────────────────────
    gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
    draw_surface(global.__lightmap_surf, 0, 0);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
