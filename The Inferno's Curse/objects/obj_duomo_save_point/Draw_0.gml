// =============================================================================
// obj_duomo_save_point — Draw
// =============================================================================
// A faceted blue crystal on a stone base with a soft pulsing glow. A "[E] Save"
// hint floats above when the player is near.
var _gl = 0.55 + 0.25 * sin(pulse);

// glow
gpu_set_blendmode(bm_add);
draw_set_color(make_color_rgb(90, 150, 230));
draw_set_alpha(0.30 * _gl);
draw_circle(x, y, 30, false);
draw_set_alpha(0.18 * _gl);
draw_circle(x, y, 46, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// stone base
draw_set_color(make_color_rgb(70, 66, 74));
draw_rectangle(x - 12, y + 8, x + 12, y + 16, false);

// crystal (diamond)
draw_set_color(make_color_rgb(150, 200, 255));
draw_triangle(x, y - 18, x - 9, y + 2, x + 9, y + 2, false);
draw_triangle(x - 9, y + 2, x + 9, y + 2, x, y + 12, false);
draw_set_color(make_color_rgb(220, 240, 255));
draw_triangle(x, y - 18, x - 4, y - 2, x + 4, y - 2, false);
draw_set_color(c_white);

if (player_near) {
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(c_black); draw_text(x + 1, y - 33, "[E] Save");
    draw_set_color(make_color_rgb(190, 220, 255)); draw_text(x, y - 34, "[E] Save");
    draw_set_color(c_white);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}
