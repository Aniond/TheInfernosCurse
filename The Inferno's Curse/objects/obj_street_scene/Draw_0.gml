// =============================================================================
// obj_street_scene — Draw (world space, depth 160)
// =============================================================================

// Only dress Room1 — this instance is persistent and would otherwise draw in
// the battle room too.
if (room != Room1) exit;

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
