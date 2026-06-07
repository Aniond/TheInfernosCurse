// =============================================================================
// obj_vision_manager — Draw GUI Event
// =============================================================================
// Renders the full-screen horror overlay when a vision is active.
// Runs in Draw GUI so it sits above all world-space sprites.
// Only draws if there is meaningful alpha to show.
// =============================================================================

if (vision_overlay_alpha <= 0.01) exit;

// Debug mode (F1) hides the vision overlays so the true scene is visible
if (global.debug_mode) exit;

// Suppress overlay during dialogue — parchment frame handles the atmosphere
if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) exit;

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _a = vision_overlay_alpha;

// ── Colour and effect per vision type ────────────────────────────────────────
// Each type has a base colour that communicates the sin behind the vision.
// All use draw_set_alpha and draw_rectangle; more elaborate shaders can
// replace these stubs when the art pass comes.

switch (current_vision_type) {

    // ── WALL_BREATHE: dark grey pulse — walls are alive ──────────────────────
    // Limbo's grief: the world forgets its own boundaries.
    case "WALL_BREATHE":
        draw_set_alpha(_a * 0.5);
        draw_set_colour(c_dkgray);
        draw_rectangle(0, 0, _w, _h, false);
        break;

    // ── FACE_DISTORT: brief white flash — seeing too much ────────────────────
    // Lust: a moment of terrible clarity before the mind blurs it away.
    case "FACE_DISTORT":
        draw_set_alpha(_a * 0.7);
        draw_set_colour(c_white);
        draw_rectangle(0, 0, _w, _h, false);
        break;

    // ── SHADOW_WRONG: deep purple tint — shadows remember their owners ────────
    // Limbo: grief casts shadows that belong to people no longer present.
    case "SHADOW_WRONG":
        draw_set_alpha(_a * 0.45);
        draw_set_colour(make_colour_rgb(40, 0, 60));
        draw_rectangle(0, 0, _w, _h, false);
        break;

    // ── GROUND_PULSE: dark red from bottom — the circle below is showing ─────
    // Gluttony: the next layer of Hell bleeds upward through the floor.
    case "GROUND_PULSE":
        // Gradient effect: draw from bottom half only.
        draw_set_alpha(_a * 0.6);
        draw_set_colour(make_colour_rgb(80, 0, 0));
        draw_rectangle(0, _h * 0.5, _w, _h, false);
        draw_set_alpha(_a * 0.3);
        draw_rectangle(0, _h * 0.25, _w, _h * 0.5, false);
        break;

    // ── THING_WATCHING: black vignette edges — something is at the periphery ──
    // Violence: awareness of being observed by something that should not exist.
    case "THING_WATCHING":
        // Vignette: four dark rectangles at screen edges, leaving centre clear.
        var _edge = 120;
        draw_set_alpha(_a * 0.7);
        draw_set_colour(c_black);
        draw_rectangle(0,        0,        _w,     _edge,         false); // top
        draw_rectangle(0,        _h-_edge, _w,     _h,            false); // bottom
        draw_rectangle(0,        0,        _edge,  _h,            false); // left
        draw_rectangle(_w-_edge, 0,        _w,     _h,            false); // right
        break;

    // ── FULL_MANIFEST: full desaturation + red tint — Hell is undeniable ─────
    // All circles combined: the world becomes what Benedetto fears it is.
    case "FULL_MANIFEST":
        // Full screen fill first (desaturate simulation via dark overlay)
        draw_set_alpha(_a * 0.6);
        draw_set_colour(make_colour_rgb(20, 0, 0));
        draw_rectangle(0, 0, _w, _h, false);
        // Heavy vignette on top
        draw_set_alpha(_a * 0.8);
        draw_set_colour(c_black);
        var _ve = 160;
        draw_rectangle(0,      0,       _w,    _ve,        false);
        draw_rectangle(0,      _h-_ve,  _w,    _h,         false);
        draw_rectangle(0,      0,       _ve,   _h,         false);
        draw_rectangle(_w-_ve, 0,       _w,    _h,         false);
        break;

    // ── GAME_OVER screens ─────────────────────────────────────────────────────
    // Fades handled here; text rendering stubbed until font assets exist.
    case "GAME_OVER_corruption":
        draw_set_alpha(min(_a, 1));
        draw_set_colour(make_colour_rgb(60, 0, 0));   // deep red — the world forgot itself
        draw_rectangle(0, 0, _w, _h, false);
        // TODO: draw "He could no longer find his way back" with game font
        // TODO: draw stats from game_over_stats struct
        break;

    case "GAME_OVER_battle":
        draw_set_alpha(min(_a, 1));
        draw_set_colour(c_black);
        draw_rectangle(0, 0, _w, _h, false);
        // TODO: draw "Even blessed hands can only hold so much"
        break;
}

// Always reset draw state after custom alpha/colour work.
draw_set_alpha(1);
draw_set_colour(c_white);
