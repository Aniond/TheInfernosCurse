// =============================================================================
// obj_npc_stableboy — Draw  (the figure + a near hint)
// =============================================================================
// Drawn at the object origin (top-left, like the other stable props) so it lines
// up with the grid. A warm floor glow sits under him while the lanterns are warm;
// it cools and dies with the corruption tiers like everything else in the room.
var _corr = global.circle_corruption[CIRCLE_LIMBO];
if (_corr < 75) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(120, 80, 30));
    draw_set_alpha(_corr < 50 ? 0.16 : 0.08);
    draw_circle(x + 32, y + 40, 30, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);

var _icx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _icy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;

// Floating parchment emotion icon above his head (emotion system).
scr_npc_emotion_draw(id, "stableboy", _icx, y - 12);

// "[E] Talk" prompt above his head while in range and the menu is closed.
if (!menu_open) scr_npc_talk_prompt(_icx, _icx, _icy, y - 28, proximity_radius);
