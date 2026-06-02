// =============================================================================
// obj_manifestation — Draw Event
// =============================================================================
// Renders a wrong-proportioned silhouette using draw_rectangle.
// Only draws when a vision is active or vision_intensity is high enough
// for the entity to bleed into peripheral awareness.
// Replace rectangles with a proper sprite during the art pass.
// =============================================================================

// ── Visibility gate ───────────────────────────────────────────────────────────
// Only visible during an active vision or when intensity is above 60.
if (!instance_exists(obj_vision_manager)) exit;
if (obj_vision_manager.vision_timer <= 0 && global.vision_intensity <= 60) exit;

// ── Opacity scales with vision_intensity ─────────────────────────────────────
var _alpha = global.vision_intensity / 100;
draw_set_alpha(_alpha);

// ── Colour by manifest_type (circle index) ───────────────────────────────────
var _col;
switch (manifest_type) {
    case CIRCLE_LIMBO:    _col = make_colour_rgb(100, 100, 100); break; // translucent grey
    case CIRCLE_LUST:     _col = make_colour_rgb(120, 0,   20);  break; // deep crimson
    case CIRCLE_GLUTTONY: _col = make_colour_rgb(30,  80,  10);  break; // sickly green
    case CIRCLE_GREED:    _col = make_colour_rgb(100, 85,  10);  break; // tarnished gold
    case CIRCLE_WRATH:    _col = make_colour_rgb(180, 60,  0);   break; // burning orange
    case CIRCLE_HERESY:   _col = make_colour_rgb(200, 210, 220); break; // cold white
    case CIRCLE_VIOLENCE: _col = make_colour_rgb(10,  0,   0);   break; // fractured black
    default:              _col = c_dkgray; break;
}
draw_set_colour(_col);

// ── Wrong proportions — the geometry of something that should not exist ───────
// Tall and narrow: head too small, torso too long, limbs wrong.
// All measurements in pixels relative to (x, y) as the entity centre.
var _body_w = 14;
var _body_h = 52;
var _head_r = 5;  // head is a small square, not a circle

// Body (torso — too elongated)
draw_rectangle(x - _body_w/2, y - _body_h/2, x + _body_w/2, y + _body_h/2, false);

// Head (too small for the body)
draw_rectangle(x - _head_r, y - _body_h/2 - _head_r*2 - 2, x + _head_r, y - _body_h/2 - 2, false);

// Arms (too long, angled downward — hanging wrong)
draw_rectangle(x - _body_w/2 - 18, y - _body_h/4, x - _body_w/2, y + _body_h/2 + 10, false);
draw_rectangle(x + _body_w/2,      y - _body_h/4, x + _body_w/2 + 18, y + _body_h/2 + 10, false);

// Reset draw state.
draw_set_alpha(1);
draw_set_colour(c_white);
