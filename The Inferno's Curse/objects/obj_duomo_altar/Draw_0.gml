// =============================================================================
// obj_duomo_altar — Draw
// =============================================================================
// Sprite + corruption-driven state:
//   0-49%   : altar glowing softly, warm golden light
//   50-74%  : glow fades
//   75-99%  : a crack splits the stone
//   100%    : cold, broken, no glow
draw_self();

var _corr = global.circle_corruption[CIRCLE_LIMBO];
var _cx   = (bbox_left + bbox_right)  * 0.5;
var _cy   = (bbox_top  + bbox_bottom) * 0.5;

// Soft warm glow — strongest when lucid, gone entirely once broken.
if (_corr < 100) {
    var _g   = 0.25 * (1 - _corr / 100);
    var _flk = 1 + 0.10 * sin(current_time / 130);
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 208, 120));
    draw_set_alpha(max(0.05, _g) * _flk);
    draw_circle(_cx, _cy, 42, false);
    draw_set_alpha(max(0.03, _g * 0.6) * _flk);
    draw_circle(_cx, _cy, 22, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Cracks once the place has been wrong for a while.
if (_corr >= 75) {
    draw_set_color(make_color_rgb(18, 14, 14));
    draw_line_width(_cx - 12, bbox_top + 6,  _cx + 4,  _cy + 2,            2);
    draw_line_width(_cx + 4,  _cy + 2,       _cx - 2,  bbox_bottom - 6,    2);
    draw_set_color(c_white);
}
