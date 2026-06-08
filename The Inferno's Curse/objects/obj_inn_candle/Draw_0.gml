// =============================================================================
// obj_inn_candle — Draw
// =============================================================================
// Lit (warm flicker glow) below this candle's threshold; cold/snuffed above it.
var _corr = global.circle_corruption[CIRCLE_LIMBO];
var _cold = (_corr >= cold_at);
var _spr  = _cold ? spr_inn_candle_unlit : spr_inn_candle_lit;

if (!_cold) {
    var _cx = x + sprite_get_width(spr_inn_candle_lit)  * image_xscale * 0.5;
    var _cy = y + sprite_get_height(spr_inn_candle_lit) * image_yscale * 0.5;
    var _f  = 0.5 + 0.18 * sin(current_time / 140 + flick);
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 168, 72));
    draw_set_alpha(0.24 * _f);
    draw_circle(_cx, _cy, 18, false);
    draw_set_alpha(0.14 * _f);
    draw_circle(_cx, _cy, 30, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

draw_sprite_ext(_spr, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
draw_set_color(c_white);
