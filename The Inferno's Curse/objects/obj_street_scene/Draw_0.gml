// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Clean rebuild. Layers so far:
//   1) GROUND — seamless grass across the whole room.
//   2) CITY WALL — fortress wall ringing the room perimeter, corners on the
//      four corners, and the gate at the south-centre.
//
// Drawn at depth 160 (behind the player/characters at depth 100). More layers
// (roads, river, props, buildings) get added on top from here.
// =============================================================================
if (room != Room1) exit;

// ── 1. GROUND: seamless grass ─────────────────────────────────────────────────
draw_set_color(make_color_rgb(74, 138, 48));        // backstop base (also kills smear)
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_color(c_white);

var _gw = sprite_get_width(spr_florence_grass);     // 64
var _gh = sprite_get_height(spr_florence_grass);    // 64
for (var _gy = 0; _gy < room_height; _gy += _gh) {
    for (var _gx = 0; _gx < room_width; _gx += _gw) {
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}

// ── 2. CITY WALL ring + gate ──────────────────────────────────────────────────
var _wt     = 64;
var _right  = room_width  - _wt;
var _bottom = room_height - _wt;

// Straight sections along the four edges.
for (var _x = 0; _x < room_width; _x += _wt) {
    draw_sprite(spr_florence_wall, 0, _x, 0);        // north edge
    draw_sprite(spr_florence_wall, 0, _x, _bottom);  // south edge
}
for (var _y = 0; _y < room_height; _y += _wt) {
    draw_sprite(spr_florence_wall, 0, 0, _y);        // west edge
    draw_sprite(spr_florence_wall, 0, _right, _y);   // east edge
}

// Corner pieces over the four corners.
draw_sprite(spr_florence_wall_corner, 0, 0,      0);
draw_sprite(spr_florence_wall_corner, 0, _right, 0);
draw_sprite(spr_florence_wall_corner, 0, 0,      _bottom);
draw_sprite(spr_florence_wall_corner, 0, _right, _bottom);

// Gate (128x64) at the south-centre, over the south wall run.
draw_sprite(spr_florence_gate, 0, room_width * 0.5 - 64, _bottom);
