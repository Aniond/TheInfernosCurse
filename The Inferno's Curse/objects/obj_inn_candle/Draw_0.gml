// =============================================================================
// obj_inn_candle — Draw
// =============================================================================
// Three states by Limbo corruption:
//   < cold_at      warm lit (orange flicker glow)
//   cold_at .. 99  cold / snuffed (no glow)
//   100            eerie GREEN relight — the curse rekindles it with unnatural fire
var _corr  = global.circle_corruption[CIRCLE_LIMBO];
var _green = (_corr >= 100);
var _cold  = (!_green && _corr >= cold_at);
var _spr   = _green ? spr_inn_candle_green : (_cold ? spr_inn_candle_unlit : spr_inn_candle_lit);

if (!_cold) {   // glowing: warm below the threshold, green at full corruption
    var _cx = x + sprite_get_width(spr_inn_candle_lit)  * image_xscale * 0.5;
    var _cy = y + sprite_get_height(spr_inn_candle_lit) * image_yscale * 0.5;
    var _f  = 0.5 + 0.18 * sin(current_time / 140 + flick);
    var _glow = _green ? make_color_rgb(96, 255, 120) : make_color_rgb(255, 168, 72);
    gpu_set_blendmode(bm_add);
    draw_set_color(_glow);
    draw_set_alpha(0.24 * _f);
    draw_circle(_cx, _cy, 18, false);
    draw_set_alpha(0.14 * _f);
    draw_circle(_cx, _cy, 30, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

draw_sprite_ext(_spr, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
draw_set_color(c_white);
