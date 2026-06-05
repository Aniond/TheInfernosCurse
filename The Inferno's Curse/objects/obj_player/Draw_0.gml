// ── Player: Draw ────────────────────────────────────────────────────────────
// Benedetto drawn at 1.25x. Corruption tints him toward a sickly pale grey-
// green so the visual feedback applies even while idle, not just when walking.
//   0-30%  : pure white (no tint)
//   30-60% : fading toward grey-green (corruption seeping in)
//   60-85% : deeper sickly grey
//   85-100%: near-corpse pale white-grey (almost consumed)
var _c01  = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
var _tint = c_white;
if (_c01 > 0.3) {
    var _t = (_c01 - 0.3) / 0.7;   // 0=just past threshold, 1=fully consumed
    if (_t < 0.43)       _tint = merge_color(c_white, make_color_rgb(160, 175, 140), _t / 0.43);
    else if (_t < 0.71)  _tint = merge_color(make_color_rgb(160, 175, 140), make_color_rgb(120, 130, 108), (_t - 0.43) / 0.28);
    else                 _tint = merge_color(make_color_rgb(120, 130, 108), make_color_rgb(200, 205, 195), (_t - 0.71) / 0.29);
}

draw_sprite_ext(
    sprite_index,   // current directional sprite (set each step in Step_0)
    image_index,    // current animation frame
    x, y,           // world position
    1.25, 1.25,     // display scale
    0,              // no rotation
    _tint,          // corruption-driven colour tint
    1               // full alpha
);
