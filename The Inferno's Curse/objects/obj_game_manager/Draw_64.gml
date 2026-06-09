// =============================================================================
// obj_game_manager — Draw GUI
// Day/night lighting overlay — tinted full-screen rectangle over the world.
// Dawn: soft orange · Day: clear · Dusk: warm amber · Night: dark blue
// =============================================================================
if (!variable_global_exists("game_hour")) exit;

var _L = scr_time_lighting();
if (_L.alpha <= 0) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_alpha(_L.alpha);
draw_set_color(_L.col);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);
draw_set_color(c_white);
