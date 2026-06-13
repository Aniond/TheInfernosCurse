// obj_mercato_exit - Draw GUI
// Draws the atmospheric fade-to-black sequence.

if (transition_triggered && fade_alpha > 0) {
    draw_set_color(c_black);
    draw_set_alpha(fade_alpha);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}