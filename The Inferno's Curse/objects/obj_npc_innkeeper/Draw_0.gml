// =============================================================================
// obj_npc_innkeeper — Draw  (the figure + a near hint)
// =============================================================================
// Drawn at the object origin (top-left, like the other inn props) so it lines up
// with the grid. A warm floor glow sits under him.
gpu_set_blendmode(bm_add);
draw_set_color(make_color_rgb(120, 80, 30));
draw_set_alpha(0.16);
draw_circle(x + 32, y + 40, 30, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);

if (player_near && !menu_open) {
    draw_set_halign(fa_center);
    draw_set_color(c_black);                       draw_text(x + 33, y - 11, "[E] Speak");
    draw_set_color(make_color_rgb(236, 220, 180)); draw_text(x + 32, y - 12, "[E] Speak");
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}
