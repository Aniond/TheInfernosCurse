// =============================================================================
// obj_street_scene — Draw (world space, depth 160)
// =============================================================================

// Only dress Room1 — this instance is persistent and would otherwise draw in
// the battle room too.
if (room != Room1) exit;

// ── Countryside grass ─────────────────────────────────────────────────────────
// Lay grass over everything OUTSIDE the cobbled city core, covering the bare
// background out to the room edges. Drawn first so the road and props paint over
// it. spr_florence_grass is a 64px tile; skip tiles whose center is inside the
// core so the city keeps its cobblestone.
var _cx1 = core_rect[0], _cy1 = core_rect[1];
var _cx2 = core_rect[2], _cy2 = core_rect[3];

// Flat country-green base over the ring (four border bands around the core) — a
// gap-free ground so no cobble or black shows through the grass texture above.
draw_set_color(make_color_rgb(74, 138, 48));
draw_rectangle(0, 0, room_width, _cy1, false);                // top band (full width)
draw_rectangle(0, _cy2, room_width, room_height, false);      // bottom band (full width)
draw_rectangle(0, _cy1, _cx1, _cy2, false);                   // left band
draw_rectangle(_cx2, _cy1, room_width, _cy2, false);          // right band
draw_set_color(c_white);

// Organic texture: overlap-tile the grass sprite over the ring. The base fill
// below guarantees coverage, so the blob's soft edges just add variation. Step
// is < the 64px sprite so blobs knit together.
var _gs = 56;
for (var _gy = 0; _gy < room_height; _gy += _gs) {
    for (var _gx = 0; _gx < room_width; _gx += _gs) {
        var _mx = _gx + 32;
        var _my = _gy + 32;
        if (_mx >= _cx1 && _mx <= _cx2 && _my >= _cy1 && _my <= _cy2) continue;
        draw_sprite(spr_florence_grass, 0, _gx, _gy);
    }
}

// ── The Arno ──────────────────────────────────────────────────────────────────
// Full-width animated river quartering the city. The seamless water tile is
// scrolled horizontally (driven by current_time, so no Step event is needed) to
// give the current a downstream flow. Drawn over the grass; bridges below repaint
// the paved road across each walkable gap.
var _wy1 = global.river_y1, _wy2 = global.river_y2;
var _wts = sprite_get_width(spr_florence_water);          // 64
var _flow = (current_time / 1000 * 28) mod _wts;          // ~28 px/s downstream
for (var _wy = _wy1; _wy < _wy2; _wy += _wts) {
    for (var _wx = -_wts; _wx < room_width + _wts; _wx += _wts) {
        draw_sprite(spr_florence_water, 0, _wx - _flow, _wy);
    }
}

// Grassy waterline along both banks for definition.
draw_set_color(make_color_rgb(52, 84, 40));
draw_rectangle(0, _wy1 - 4, room_width, _wy1 + 2, false);
draw_rectangle(0, _wy2 - 2, room_width, _wy2 + 4, false);
draw_set_color(c_white);

// Bridges — paved deck + stone parapets over each walkable gap. The deck runs a
// tile past each bank so it meets the grass approach on either side.
var _rts = sprite_get_width(spr_florence_road);           // 64
for (var _b = 0; _b < array_length(global.river_bridges); _b++) {
    var _bx1 = global.river_bridges[_b][0];
    var _bx2 = global.river_bridges[_b][1];
    for (var _by = _wy1 - _rts; _by < _wy2 + _rts; _by += _rts) {
        for (var _bx = _bx1; _bx < _bx2; _bx += _rts) {
            draw_sprite(spr_florence_road, 0, _bx, _by);
        }
    }
    // Stone parapets along the up/downstream edges.
    draw_set_color(make_color_rgb(120, 110, 95));
    draw_rectangle(_bx1, _wy1 - _rts,     _bx2, _wy1 - _rts + 8, false);
    draw_rectangle(_bx1, _wy2 + _rts - 8, _bx2, _wy2 + _rts,     false);
    draw_set_color(c_white);
}

// ── Paved road ────────────────────────────────────────────────────────────────
// Tile spr_florence_road within each road rectangle, over the cobblestone floor.
var _ts = sprite_get_width(spr_florence_road);   // 64
for (var _r = 0; _r < array_length(road_rects); _r++) {
    var _rect = road_rects[_r];
    var _x1 = _rect[0], _y1 = _rect[1], _x2 = _rect[2], _y2 = _rect[3];
    for (var _ry = _y1; _ry < _y2; _ry += _ts) {
        for (var _rx = _x1; _rx < _x2; _rx += _ts) {
            draw_sprite(spr_florence_road, 0, _rx, _ry);
        }
    }
}

// ── Market props (bottom-centered) ───────────────────────────────────────────
for (var _p = 0; _p < array_length(props); _p++) {
    var _prop = props[_p];
    var _spr = _prop[0];
    var _px  = _prop[1];
    var _py  = _prop[2];
    var _w = sprite_get_width(_spr);
    var _h = sprite_get_height(_spr);
    draw_sprite(_spr, 0, _px - _w * 0.5, _py - _h);
}

// ── Countryside scenery (trees & bushes) ──────────────────────────────────────
// Bottom-centered over the grass ring. At depth 160 these sit behind characters
// and buildings (depth < 160) — fine for the outer verge the player rarely treads.
for (var _s = 0; _s < array_length(scenery); _s++) {
    var _item = scenery[_s];
    var _ssp = _item[0];
    var _sx  = _item[1];
    var _sy  = _item[2];
    var _sw = sprite_get_width(_ssp);
    var _sh = sprite_get_height(_ssp);
    draw_sprite(_ssp, 0, _sx - _sw * 0.5, _sy - _sh);
}
