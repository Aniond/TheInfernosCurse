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

var _icx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _icy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;

// Floating parchment emotion icon above his head (emotion system).
scr_npc_emotion_draw(id, "innkeeper", _icx, y - 12);

// FIX 3: "[E] Talk" prompt above his head, shown only while in talk range and the
// menu is closed. Uses proximity_radius (130) not a literal 80 — the player can't
// get within 80px of him across the ~2-cell-deep counter, so 80 would never show.
if (!menu_open) scr_npc_talk_prompt(_icx, _icx, _icy, y - 28, proximity_radius);
