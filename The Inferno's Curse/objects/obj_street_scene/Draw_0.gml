// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild, step 1: GROUND ONLY — seamless grass across the whole room.
//
// spr_florence_grass is now a normal, fully-opaque 64x64 SEAMLESS tile, so it
// tiles wall-to-wall at a flat 64px step with no gaps and no visible repeat
// seams. A flat green base is drawn first only as a backstop: the room's view is
// set not to clear, so painting the full room each frame also stops smearing.
//
// Drawn at depth 160: behind the player/characters (depth 100). Roads, river,
// props, scenery and buildings get layered on top of this from here.
// =============================================================================
if (room != Room1) exit;

// Backstop base (matches the tile's green; never visible under the opaque tile).
draw_set_color(make_color_rgb(74, 138, 48));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_color(c_white);

// Seamless grass tile across the entire room.
var _gw = sprite_get_width(spr_florence_grass);    // 64
var _gh = sprite_get_height(spr_florence_grass);   // 64
for (var _gy = 0; _gy < room_height; _gy += _gh) {
    for (var _gx = 0; _gx < room_width; _gx += _gw) {
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}
