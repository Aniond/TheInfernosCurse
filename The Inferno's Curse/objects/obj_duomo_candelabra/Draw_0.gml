// =============================================================================
// obj_duomo_candelabra — Draw
// =============================================================================
// Decorative (never solid). Draws its sprite plus a warm additive flame glow.
// Corruption states (Limbo):
//   0-49%   : lit, full warm glow
//   50-99%  : roughly HALF the candelabra go dark (deterministic by instance id),
//             the lit ones dim as corruption rises
//   100%    : all cold and dark, no glow
draw_self();

var _corr = global.circle_corruption[CIRCLE_LIMBO];

// Deterministic per-candelabra seed from grid position (NOT `id` — `id` is an
// instance ref and `id mod n` throws "Malformed variable").
var _seed = (floor(x / 64) + floor(y / 64) * 7);

var _lit = true;
if (_corr >= 100)      _lit = false;                // cathedral cold and dark
else if (_corr >= 50)  _lit = ((_seed mod 2) == 0); // half the candles dark

if (_lit) {
    var _cx   = x + (sprite_get_width(sprite_index)  * image_xscale) * 0.5;
    var _cy   = y + (sprite_get_height(sprite_index) * image_yscale) * 0.32;
    var _dim  = 1 - (_corr / 100) * 0.55;                     // dims with corruption
    var _flk  = 1 + 0.14 * sin(current_time / 90 + (_seed mod 23));
    var _rad  = 30 * max(image_xscale, 0.5);

    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 188, 92));
    draw_set_alpha(0.34 * _dim * _flk);
    draw_circle(_cx, _cy, _rad, false);
    draw_set_alpha(0.22 * _dim * _flk);
    draw_circle(_cx, _cy, _rad * 0.55, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
