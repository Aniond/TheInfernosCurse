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

// The benedetto sprites are 128x128 with origin (0,0), but collision is a small
// foot-box centred at (x,y). Drawing at (x,y) would put the sprite's TOP-LEFT on
// the collision point, so the whole ~160px body renders down-and-right of where
// Benedetto actually stands — he looks stranded a tile south of whatever he's
// touching (the river edge, building faces, etc.). Anchor his FEET to (x,y)
// instead. _foot_dx/_foot_dy = character centre-x / feet-y inside the 128 frame
// (tune these if he sits slightly high/low or off-centre).
var _spr_scale = 0.9;
var _foot_dx   = 62 * _spr_scale;   // horizontal centre of the character in-frame
var _foot_dy   = 120 * _spr_scale;  // feet (bottom of the character) in-frame
draw_sprite_ext(
    sprite_index,   // current directional sprite (set each step in Step_0)
    image_index,    // current animation frame
    x - _foot_dx, y - _foot_dy,   // anchor feet to the collision point
    _spr_scale, _spr_scale,       // display scale
    0,              // no rotation
    _tint,          // corruption-driven colour tint
    1               // full alpha
);

// ── Comprehensive debug overlay (F1) — world-space layer ──────────────────────
// Collision outlines, player foot-box + crosshair + coords, NPC interaction
// rings/labels, and the river collision/bridge zones — all in scr_debug.
scr_debug_world_overworld();
