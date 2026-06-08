// =============================================================================
// obj_duomo_confessional — Draw GUI
// =============================================================================
// Modal confession prompt, centred on screen while prompt_active.
if (!prompt_active) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _bw = 420;
var _bh = 130;
var _bx = (_gw - _bw) * 0.5;
var _by = (_gh - _bh) * 0.5;

// dim the world behind the prompt
draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// panel
draw_set_color(make_color_rgb(28, 22, 18));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
draw_set_color(make_color_rgb(150, 120, 70));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);

// text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(238, 228, 205));
draw_text(_bx + _bw * 0.5, _by + 38, "Confess your sins.");
draw_set_color(make_color_rgb(190, 180, 160));
draw_text(_bx + _bw * 0.5, _by + 90, "[Y] Yes        [N] No");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
