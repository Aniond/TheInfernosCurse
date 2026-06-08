// =============================================================================
// obj_duomo_confessional — Draw (world)
// =============================================================================
// Sprite + a small "[E] Confess" hint floating above the booth when the player is
// near and no prompt is open. The modal Yes/No box itself is drawn in Draw GUI.
draw_self();

if (player_near && !prompt_active) {
    var _cx  = (bbox_left + bbox_right) * 0.5;
    var _txt = (global.circle_corruption[CIRCLE_LIMBO] >= 75) ? "[E] (sealed)" : "[E] Confess";
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text(_cx + 1, bbox_top - 13, _txt);
    draw_set_color(make_color_rgb(235, 225, 200));
    draw_text(_cx, bbox_top - 14, _txt);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
