// =============================================================================
// obj_npc_rosa — Draw  (Rosa + her floating mood icon)
// =============================================================================
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);

// Mood icon above her head, from the NPC system's emotion_state for "barmaid".
var _npc = scr_npc_get(npc_id);
if (!is_undefined(_npc)) {
    var _icon = scr_npc_emotion_sprite(_npc.emotion_state);
    var _ix   = x + sprite_get_width(sprite_index) * image_xscale * 0.5;
    var _bob  = sin(current_time / 320) * 2;
    draw_sprite_ext(_icon, 0, _ix - 12, y - 26 + _bob, 0.75, 0.75, 0, c_white, 1);   // ~24px icon
}

if (greeted && say_timer <= 0) {
    draw_set_halign(fa_center);
    draw_set_color(c_black);                       draw_text(_ix + 1, y - 1, "[E]");
    draw_set_color(make_color_rgb(236, 220, 180)); draw_text(_ix,     y - 2, "[E]");
    draw_set_color(c_white); draw_set_halign(fa_left);
}
