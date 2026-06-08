// =============================================================================
// obj_duomo_pew — Draw
// =============================================================================
// Drawn via the shared rotation helper so the pew honours builder_angle (default
// 180° → seat faces the altar) and can be re-rotated with R in debug mode. The
// wood dims a touch as Limbo corruption deepens. image_angle stays 0 (bbox intact).
var _corr = global.circle_corruption[CIRCLE_LIMBO];
var _tint = merge_color(c_white, make_color_rgb(120, 110, 105), clamp(_corr / 100, 0, 1) * 0.45);

scr_room_builder_draw_rotated(id, _tint);
