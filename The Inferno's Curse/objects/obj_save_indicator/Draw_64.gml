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

// UI THEME RULE: colors via scr_ui_theme_get (see .claude/skills/ui-theme).
// SAVED rides the candle glow (sickly green at high corruption — fitting),
// LOADED rides the gold accent; text is the border color lifted with parchment.
var _th_edge = _saved ? scr_ui_theme_get(UI_CANDLE_GLOW) : scr_ui_theme_get(UI_ACCENT);

// Background
draw_set_alpha(_alpha * 0.85);
draw_set_color(scr_ui_theme_get(UI_BACKGROUND));
draw_rectangle(_gw - 160, 10, _gw - 10, 40, false);

// Border: candle-glow for SAVED, accent gold for LOADED
draw_set_alpha(_alpha);
draw_set_color(_th_edge);
draw_rectangle(_gw - 160, 10, _gw - 10, 40, true);

// Label text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(merge_color(_th_edge, scr_ui_theme_get(UI_PARCHMENT), 0.35));
draw_text(
    _gw - 85, 25,
    global.save_indicator_text + "  Day " + string(global.day_count)
);

// Reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
