// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild, step 1: GROUND ONLY. Tile spr_florence_grass across the entire
// room every frame. This is the project's proven way to fill the floor — the
// room's Background layer does NOT render here, and the view is set not to clear
// (clearViewBackground:false), so painting the whole room each frame both fills
// the ground wall-to-wall (no black void) and repaints the screen (no smearing
// when the camera follows the player).
//
// Drawn at depth 160: behind the player/characters (depth 100), so nothing the
// player walks on is covered. Roads, river, props, scenery and buildings get
// layered back on top of this from here, one step at a time.
// =============================================================================
if (room != Room1) exit;

var _gw = sprite_get_width(spr_florence_grass);    // 64
var _gh = sprite_get_height(spr_florence_grass);   // 64
for (var _gy = 0; _gy < room_height; _gy += _gh) {
    for (var _gx = 0; _gx < room_width; _gx += _gw) {
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}
