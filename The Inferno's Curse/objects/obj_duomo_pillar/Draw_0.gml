// =============================================================================
// obj_duomo_pillar — Draw
// =============================================================================
// FIX 2 — a dark contact shadow under the column base anchors it to the floor so
// it never looks like it's floating, then the column sprite on top.
var _cx = (bbox_left + bbox_right) * 0.5;
var _by = bbox_bottom - 6;
draw_set_alpha(0.45);
draw_set_color(c_black);
draw_ellipse(_cx - 22 * image_xscale, _by - 7, _cx + 22 * image_xscale, _by + 7, false);
draw_set_alpha(1);
draw_set_color(c_white);

draw_self();
