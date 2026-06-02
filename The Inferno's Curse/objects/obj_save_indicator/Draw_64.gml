// =============================================================================
// obj_save_indicator — Draw GUI Event
// =============================================================================
// Renders the save/load flash in the top-right corner.
// Fades out over the last 30 steps of its 120-step lifetime.

if (global.save_indicator_timer <= 0) exit;

var _t     = global.save_indicator_timer;
var _alpha = clamp(_t / 30, 0, 1);   // full opacity until last 30 steps, then fade
var _gw    = display_get_gui_width();
var _saved = (global.save_indicator_text == "SAVED");

// Background
draw_set_alpha(_alpha * 0.85);
draw_set_color(make_color_rgb(8, 8, 12));
draw_rectangle(_gw - 160, 10, _gw - 10, 40, false);

// Border: green for SAVED, gold for LOADED
draw_set_alpha(_alpha);
draw_set_color(_saved ? make_color_rgb(50, 200, 80) : make_color_rgb(220, 180, 40));
draw_rectangle(_gw - 160, 10, _gw - 10, 40, true);

// Label text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_saved ? make_color_rgb(80, 255, 120) : make_color_rgb(255, 220, 80));
draw_text(
    _gw - 85, 25,
    global.save_indicator_text + "  Day " + string(global.day_count)
);

// Reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
