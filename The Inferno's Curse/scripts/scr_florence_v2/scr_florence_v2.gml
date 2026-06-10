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

// ── STEP 4 — CITY WALLS ────────────────────────────────────────────────────────
// Reference wall plan: a band along the TOP, a full-height band down the LEFT
// (cols 3-5, countryside strip outside it), the BOTTOM band (rows 25.6-27.6)
// carrying BOTH gates (West Gate gap x448-576, South Gate gap x2304-2432), and
// a NE stub east of where the Arno enters. ONE geometry source drives both the
// drawing (scr_fv2_draw_walls) and the collision (scr_fv2_build).
/// All wall bands as [x0, y0, x1, y1] px rects.
function scr_fv2_walls() {
    return [
        [0,    0,    2560, 128],    // top — stops at the river's west edge
        [2752, 0,    3072, 128],    // NE stub east of the Arno's entry
        [192,  0,    320,  2048],   // left, full height (countryside outside)
        [192,  1638, 448,  1766],   // bottom, west of the West Gate
        [576,  1638, 2304, 1766],   // bottom, between the gates
        [2432, 1638, 2560, 1766],   // bottom, east of the South Gate
    ];
}

/// Paint the walls STABLE-STYLE (the user's standing technique): each band is a
/// SOLID BLACK void block with stone texture tiles inset (black outline frame)
/// and a lit top edge; crenellation merlons tooth the city-facing side; then the
/// gatehouses, corner towers and wall piers are dropped on top.
function scr_fv2_draw_walls(_corr01) {
    var _segs = scr_fv2_walls();
    var _tex  = asset_get_index("spr_florence_wall_tile");
    var _scale = 1;
    if (_tex < 0 || asset_get_type("spr_florence_wall_tile") != asset_sprite) {
        _tex = spr_stable_wall_tile;   // timber fallback until the stone tile lands
    }
    var _col  = merge_color(c_white,                      make_color_rgb(110, 112, 124), _corr01);
    var _top  = merge_color(make_color_rgb(168, 162, 148), make_color_rgb(70, 70, 78),   _corr01);
    var _ts   = 32;
    var _inset = 4;
    for (var _i = 0; _i < array_length(_segs); _i++) {
        var _s = _segs[_i];
        draw_set_color(c_black);
        draw_rectangle(_s[0], _s[1], _s[2], _s[3], false);
        var _x0 = _s[0] + _inset, _y0 = _s[1] + _inset;
        var _x1 = _s[2] - _inset, _y1 = _s[3] - _inset;
        if (_x1 > _x0 && _y1 > _y0) {
            for (var _ty = _y0; _ty < _y1; _ty += _ts) {
                var _h = min(_ts, _y1 - _ty);
                for (var _tx = _x0; _tx < _x1; _tx += _ts) {
                    var _w = min(_ts, _x1 - _tx);
                    draw_sprite_part_ext(_tex, 0, 0, 0, _w / _scale, _h / _scale,
                        _tx, _ty, _scale, _scale, _col, 1);
                }
            }
            draw_set_color(_top);
            draw_rectangle(_x0, _y0, _x1, min(_y0 + 3, _y1), false);
        }
        // merlons — stone teeth on the CITY-facing edge of each band
        draw_set_color(c_black);
        var _horiz = (_s[2] - _s[0]) >= (_s[3] - _s[1]);
        if (_horiz) {
            var _city_south = (_s[1] < 1000);   // top bands face the city downward
            for (var _mx = _s[0] + 8; _mx < _s[2] - 24; _mx += 48) {
                if (_city_south) draw_rectangle(_mx, _s[3], _mx + 24, _s[3] + 12, false);
                else             draw_rectangle(_mx, _s[1] - 12, _mx + 24, _s[1], false);
            }
        } else {
            for (var _my = _s[1] + 8; _my < _s[3] - 24; _my += 48) {
                draw_rectangle(_s[2], _my, _s[2] + 12, _my + 24, false);   // left band faces east
            }
        }
    }
    draw_set_color(c_white);
    // dressing: corner towers, wall piers, then the two gatehouses over their gaps
    draw_sprite(spr_florence_wall_tower, 0, 224,  16);
    draw_sprite(spr_florence_wall_tower, 0, 224,  1648);
    draw_sprite(spr_florence_wall_tower, 0, 2488, 8);
    draw_sprite(spr_florence_wall_tower, 0, 2488, 1648);
    draw_sprite(spr_florence_wall_tower, 0, 2944, 8);
    draw_sprite(spr_florence_wall_section, 0, 768,  4);
    draw_sprite(spr_florence_wall_section, 0, 1408, 4);
    draw_sprite(spr_florence_wall_section, 0, 2048, 4);
    draw_sprite(spr_florence_wall_section, 0, 1024, 1642);
    draw_sprite(spr_florence_wall_section, 0, 1728, 1642);
    draw_sprite(spr_florence_wall_gate, 0, 448,  1630);   // West Gate
    draw_sprite(spr_florence_wall_gate, 0, 2304, 1630);   // South Gate
}

/// Collision + gate transitions: the wall bands (single source above) + the
/// room-edge ring. The gates are open passages — their transitions target the
/// future tactics overworld and show "coming soon" gracefully until it exists.
function scr_fv2_build() {
    if (room != Room_florence_v2) return;
    // keep-alive: tiles resolved by NAME in Draw are invisible to the asset
    // stripper — compile-time identifiers here force them into the build.
    global.__fv2_keep_spr = [spr_florence_road_cobble, spr_florence_road_intersection,
        spr_florence_road_edge, spr_florence_grass, spr_florence_street,
        spr_florence_wall_section, spr_florence_wall_gate, spr_florence_wall_tower,
        spr_florence_wall_tile];
    var _solids = scr_fv2_walls();
    array_push(_solids, [0, 0, room_width, 8]);                       // room-edge ring
    array_push(_solids, [0, room_height - 8, room_width, room_height]);
    array_push(_solids, [0, 0, 8, room_height]);
    array_push(_solids, [room_width - 8, 0, room_width, room_height]);
    for (var _i = 0; _i < array_length(_solids); _i++) {
        var _s = _solids[_i];
        var _w = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _w.wall_w = _s[2] - _s[0]; _w.wall_h = _s[3] - _s[1]; _w.visible = false;
    }
    // gate transitions (walk into the archway): future FF-Tactics overworld
    scr_transition_spawn("fv2_west_gate",  448,  1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
    scr_transition_spawn("fv2_south_gate", 2304, 1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
}
