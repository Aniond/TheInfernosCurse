// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild, step 1: GROUND ONLY — solid grass across the whole room.
//
// spr_florence_grass is a SOFT-EDGED BLOB, not a solid square tile, so it must
// be drawn over a flat green base or its transparent edges leave gaps. Two passes:
//   1) Flat country-green rectangle over the ENTIRE room — gap-free coverage so
//      no black shows, and (since the view is set not to clear) a full repaint
//      each frame so nothing smears as the camera follows the player.
//   2) Overlap-tile the grass blob (step < sprite size) for organic texture.
//
// Drawn at depth 160: behind the player/characters (depth 100). Roads, river,
// props, scenery and buildings get layered on top of this from here.
// =============================================================================
if (room != Room1) exit;

// 1) Solid base fill.
draw_set_color(make_color_rgb(74, 138, 48));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_color(c_white);

// 2) Organic grass texture over the base (soft edges knit together at step < 64).
var _gs = 56;
for (var _gy = 0; _gy < room_height; _gy += _gs) {
    for (var _gx = 0; _gx < room_width; _gx += _gs) {
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}
