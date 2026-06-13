// =============================================================================
// obj_room_occluder — Draw
// =============================================================================
// Note: This draws a pure black rectangle. Since we set depth = -9000 in Create,
// this will draw above all standard objects and ground tiles.
// =============================================================================

var _x2 = x + 64 * image_xscale;
var _y2 = y + 64 * image_yscale;

if (alpha > 0.01) {
    draw_set_color(c_black);
    draw_set_alpha(alpha);
    draw_rectangle(x, y, _x2, _y2, false);
    
    // Reset alpha/color
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}

// Debug drawing for F8 editor
if (global.debug_mode && alpha <= 0.01) {
    draw_set_color(c_fuchsia);
    draw_set_alpha(0.3);
    draw_rectangle(x, y, _x2, _y2, true);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}
