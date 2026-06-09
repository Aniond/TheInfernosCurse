// =============================================================================
// obj_time_manager — Draw GUI Event
// =============================================================================
// Renders the sky colour overlay, current time period label, and day counter.
// All coordinates are in GUI space (screen-relative, camera-independent).

var _gui_w = display_get_gui_width();
var _tod   = global.time_of_day;

// ── Sky colour overlay (top of screen) ───────────────────────────────────────
// A semi-transparent band that tints the top of the HUD with the current
// sky colour. Gets greyer as Limbo corruption rises.
var _sky_col = scr_get_sky_color();

draw_set_alpha(0.6); // semi-transparent so UI elements beneath still read
draw_set_color(_sky_col);
draw_rectangle(0, 0, _gui_w, 60, false);
draw_set_alpha(1.0);

// Thin bottom edge of the sky band, slightly more opaque for definition
draw_set_alpha(0.8);
draw_set_color(_sky_col);
draw_rectangle(0, 58, _gui_w, 60, false);
draw_set_alpha(1.0);

// ── Time period label ─────────────────────────────────────────────────────────
// Use the canonical phase from scr_time_system so this HUD can never drift from the
// real clock again (Dawn 05-07 · Day 08-17 · Dusk 18-20 · Night 21-04).
var _phase = scr_time_phase();
var _period = "Night";
if      (_phase == "dawn") _period = "Dawn";
else if (_phase == "day")  _period = "Day";
else if (_phase == "dusk") _period = "Dusk";

// Format as HH:MM so testers can see the exact time
var _h   = floor(_tod);
var _m   = floor((_tod - _h) * 60);
var _hh  = string(_h);
var _mm  = (_m < 10) ? ("0" + string(_m)) : string(_m); // zero-pad minutes
var _time_str = _hh + ":" + _mm;

// Draw period + clock, centred across the sky band
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_gui_w / 2, 26, _period + "   " + _time_str);

// ── Day counter ───────────────────────────────────────────────────────────────
// Right-aligned in the sky band. Matches the style of the corruption HUD below.
draw_set_halign(fa_right);
draw_text(_gui_w - 16, 26, "Day " + string(global.day_count));

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
draw_set_color(c_white);
