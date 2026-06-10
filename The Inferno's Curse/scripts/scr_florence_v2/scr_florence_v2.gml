// =============================================================================
// scr_florence_v2 — Room_florence_v2 — the reference-exact Florence (48 x 32)
// =============================================================================
// Built from references/florence.png at 1 reference px = 5.12 world px
// (12.5 ref px = one 64px cell): room 3072 x 2048, exact 3:2 like the image.
// ROADS FIRST (the city skeleton), then walls (stable-style black-void bands +
// wall texture), landmarks, districts, market, street life, the Arno east band.
// Room_florence (old map) is UNTOUCHED as a backup. The Giardino delle Rose
// does not exist on this map.
// =============================================================================

#macro FV2_W_CELLS 48
#macro FV2_H_CELLS 32
#macro FV2_GRID    64

// TEMP: boot straight into the v2 city for testing (checked in obj_game_manager
// Create's load-point chain). Flip to false to restore the normal start.
#macro FLORENCE_V2_LOAD_POINT true

// ── ROAD NETWORK — the city skeleton, measured off the reference ──────────────
/// Rects in CELLS [x0, y0, x1, y1, kind] · kind 0 = road · 1 = plaza field.
/// Main roads 2-2.4 cells wide, side lanes 1.5-2 — the reference's measured
/// widths. Rects are snapped to whole tiles at draw time.
function scr_fv2_roads() {
    return [
        [21,  7, 27, 10, 1],   // Piazza del Grande Mercato (market field)
        [18, 22, 27, 25, 1],   // south plaza — Public Well + fountain
        [23, 10, 25, 22, 0],   // main street: market <-> south plaza
        [35, 12, 38, 26, 0],   // South-Gate road, north run (past the Apothecary)
        [36, 26, 38, 32, 0],   // South Gate passage + outside stub
        [27, 23, 35, 25, 0],   // south plaza -> South-Gate road
        [ 7, 21,  9, 26, 0],   // West-Gate road (inside the walls)
        [ 7, 26,  9, 32, 0],   // West Gate passage + outside stub
        [ 7, 21, 18, 23, 0],   // west road -> south plaza
        [12,  8, 21, 10, 0],   // Duomo approach -> market
        [12, 10, 14, 17, 0],   // Duomo -> Artisans vertical lane
        [ 6, 17, 18, 19, 0],   // Artisans lane -> the Inn
        [27, 10, 40, 13, 0],   // Ponte Vecchio road (east, feeds the crossing)
        [28, 13, 30, 22, 0],   // Parish-Church lane south
        [15,  4, 28,  6, 0],   // north lane: Duomo -> Palazzo della Signoria
    ];
}

/// Step-3 collision: the room-edge ring only. The proper city-wall bands
/// (black-void + texture, with gate gaps) replace this in Step 4.
function scr_fv2_build() {
    if (room != Room_florence_v2) return;
    // keep-alive: tiles resolved by NAME in Draw are invisible to the asset
    // stripper — compile-time identifiers here force them into the build.
    global.__fv2_keep_spr = [spr_florence_road_cobble, spr_florence_road_intersection,
        spr_florence_road_edge, spr_florence_grass, spr_florence_street];
    var _edges = [
        [0, 0, room_width, 56], [0, room_height - 56, room_width, 56],
        [0, 0, 56, room_height], [room_width - 56, 0, 56, room_height],
    ];
    for (var _i = 0; _i < array_length(_edges); _i++) {
        var _w = instance_create_depth(_edges[_i][0], _edges[_i][1], 500, obj_wall);
        _w.wall_w = _edges[_i][2]; _w.wall_h = _edges[_i][3]; _w.visible = false;
    }
}
