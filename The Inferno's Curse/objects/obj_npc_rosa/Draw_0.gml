// =============================================================================
// obj_npc_rosa — Draw  (Rosa + her floating mood icon · off-shift: "Back later." sign)
// =============================================================================
// Off-shift (outside 14-22) the bar counter is empty — no figure, no icon, no
// prompt. Just a small wooden plaque where she stands.
if (!on_shift) {
    var _sx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
    var _sy = y + sprite_get_height(sprite_index) * image_yscale * 0.65;
    draw_set_color(make_color_rgb(58, 40, 24));
    draw_rectangle(_sx - 34, _sy - 11, _sx + 34, _sy + 11, false);
    draw_set_color(make_color_rgb(206, 172, 84));
    draw_rectangle(_sx - 34, _sy - 11, _sx + 34, _sy + 11, true);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(236, 220, 180));
    draw_text_transformed(_sx, _sy, "Back later.", 0.85, 0.85, 0);
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    exit;
}

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);

var _ix = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _iy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;

// Floating parchment emotion icon above her head (emotion system: pop, 3s fade,
// corruption override). Drawn after her sprite so it sits on top.
scr_npc_emotion_draw(id, npc_id, _ix, y - 12);

// FIX 3: "[E] Talk" prompt above her head while in talk range. proximity_radius
// (120) not a literal 80 — the deep counter keeps the player ~120px from her.
scr_npc_talk_prompt(_ix, _ix, _iy, y - 28, proximity_radius);
