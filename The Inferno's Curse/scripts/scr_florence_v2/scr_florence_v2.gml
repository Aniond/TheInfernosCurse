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
        [36, 12, 38, 26, 0],   // South-Gate road, north run (2 cells, past the Apothecary)
        [36, 26, 38, 32, 0],   // South Gate passage + outside stub
        [27, 23, 36, 25, 0],   // south plaza -> South-Gate road (meets it at x36)
        [ 7, 21,  9, 26, 0],   // West-Gate road (inside the walls)
        [ 7, 26,  9, 32, 0],   // West Gate passage + outside stub
        [ 7, 21, 18, 23, 0],   // west road -> south plaza
        [12,  8, 21, 10, 0],   // Duomo approach -> market
        [12, 10, 14, 17, 0],   // Duomo -> Artisans vertical lane
        [ 6, 17, 18, 19, 0],   // Artisans lane -> the Inn
        [27, 11, 40, 13, 0],   // Ponte Vecchio road (2 cells, feeds the crossing mid-deck)
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
    // ALTERNATING masonry tones (user fix 3): real medieval walls were never
    // uniform — each 32px block picks pale sandy / mid grey / deep charcoal
    // from a deterministic hash, so sections connect with varied stonework.
    var _col_a = merge_color(make_color_rgb(225, 214, 192), make_color_rgb(112, 114, 126), _corr01);
    var _col_b = merge_color(make_color_rgb(158, 152, 142), make_color_rgb(84, 86, 98),    _corr01);
    var _col_c = merge_color(make_color_rgb(110, 104, 98),  make_color_rgb(60, 62, 72),    _corr01);
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
                    var _pick = (((_tx div 32) * 7) + ((_ty div 32) * 13) + _i * 3) mod 5;
                    var _col = (_pick <= 1) ? _col_a : ((_pick <= 3) ? _col_b : _col_c);
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

// ── STEP 9 — THE ARNO (vertical east band, flows SOUTH) ────────────────────────
#macro FV2_RIVER_X0  2560
#macro FV2_RIVER_X1  2752
#macro FV2_PONTE_Y0  640
#macro FV2_PONTE_Y1  896

/// Animated Arno — the SAME corruption water language as the old map, rotated
/// to the reference's vertical course: murky forward current (south) → silty →
/// slower → the current REVERSES at 75% → red and flowing the wrong way at 100.
function scr_fv2_draw_arno(_corr) {
    var _bankw = 22;
    // flow speed (px/sec; + = south). Never zero; flips at 75%.
    var _spd;
    if (_corr < 0.50)      _spd = lerp(16,  9,  (_corr       ) / 0.50);
    else if (_corr < 0.75) _spd = lerp( 9,  5,  (_corr - 0.50) / 0.25);
    else                   _spd = lerp(-5, -16, (_corr - 0.75) / 0.25);
    var _wh = sprite_get_height(spr_florence_water);
    var _scroll = (current_time / 1000 * _spd) mod _wh;
    for (var _wx = FV2_RIVER_X0; _wx < FV2_RIVER_X1; _wx += 64)
        for (var _wy = -_wh + _scroll; _wy < room_height; _wy += _wh)
            draw_sprite(spr_florence_water, 0, _wx, _wy);
    // corruption colour bleed (silty brown → dark murk → blood red)
    var _a;
    if (_corr < 0.25)      _a = 0;
    else if (_corr < 0.50) _a = lerp(0,    0.70, (_corr - 0.25) / 0.25);
    else                   _a = lerp(0.70, 0.92, (_corr - 0.50) / 0.50);
    if (_a > 0) {
        var _oc;
        if (_corr < 0.50)      _oc = make_color_rgb(150, 112, 62);
        else if (_corr < 0.75) _oc = merge_color(make_color_rgb(150,112,62), make_color_rgb(84,60,42),  (_corr-0.50)/0.25);
        else if (_corr < 0.85) _oc = make_color_rgb(84, 60, 42);
        else                   _oc = merge_color(make_color_rgb(84,60,42),   make_color_rgb(150,30,26), (_corr-0.85)/0.15);
        draw_set_alpha(_a); draw_set_color(_oc);
        draw_rectangle(FV2_RIVER_X0, 0, FV2_RIVER_X1, room_height, false);
        draw_set_alpha(1); draw_set_color(c_white);
    }
    // stone banks: plain stone strips, with the stepped bank tile placed
    // SPARSELY (every 5 cells) so it reads as occasional river-access stairs —
    // tiled continuously it read as endless ladders (user fix 4).
    draw_set_color(make_color_rgb(150, 140, 118));
    draw_rectangle(FV2_RIVER_X0 - _bankw, 0, FV2_RIVER_X0, room_height, false);
    draw_rectangle(FV2_RIVER_X1, 0, FV2_RIVER_X1 + _bankw, room_height, false);
    draw_set_color(make_color_rgb(108, 98, 80));
    draw_rectangle(FV2_RIVER_X0 - 4, 0, FV2_RIVER_X0, room_height, false);
    draw_rectangle(FV2_RIVER_X1, 0, FV2_RIVER_X1 + 4, room_height, false);
    draw_set_color(c_white);
    var _bank = asset_get_index("spr_arno_stone_bank");
    if (_bank >= 0 && asset_get_type("spr_arno_stone_bank") == asset_sprite) {
        for (var _by = 160; _by < room_height - 64; _by += 320) {
            if (_by + 64 > FV2_PONTE_Y0 - 32 && _by < FV2_PONTE_Y1 + 32) continue;   // not at the deck
            draw_sprite_ext(_bank, 0, FV2_RIVER_X0 - 42, _by, 0.66, 1, 0, c_white, 1);
            draw_sprite_ext(_bank, 0, FV2_RIVER_X1,      _by, 0.66, 1, 0, c_white, 1);
        }
    }
    // shingle pebbles just inside both waterlines (gap only at the deck)
    var _ss = 0.42;
    var _col_stone = merge_color(c_white, make_color_rgb(96, 120, 112), 0.10);
    for (var _sy = 0; _sy <= room_height - 27; _sy += 16) {
        if (_sy + 27 + 16 > FV2_PONTE_Y0 && _sy - 16 < FV2_PONTE_Y1) continue;
        draw_sprite_ext(spr_river_stone, 0, FV2_RIVER_X0 - 8, _sy, _ss, _ss, 0, _col_stone, 1);
        draw_sprite_ext(spr_river_stone, 0, FV2_RIVER_X1 - 19, _sy, _ss, _ss, 0, _col_stone, 1);
    }
    // the Ponte Vecchio deck across the band — the EAST-WEST rotated sprite
    // (spr_ponte_vecchio_ew, the original turned 90°), stretched to the river
    // width exactly so the crossing runs west bank → east bank (user fix 1)
    draw_sprite_ext(spr_ponte_vecchio_ew, 0, FV2_RIVER_X0 - _bankw, FV2_PONTE_Y0,
        (FV2_RIVER_X1 - FV2_RIVER_X0 + _bankw * 2) / sprite_get_width(spr_ponte_vecchio_ew),
        (FV2_PONTE_Y1 - FV2_PONTE_Y0) / sprite_get_height(spr_ponte_vecchio_ew), 0, c_white, 1);
}

// ── STEPS 5-8 — DEFAULT LAYOUT (all draggable obj_mercato_prop; F8 saves) ──────
function scr_fv2_default_layout() {
    var _L = [];
    // STEP 5 — LANDMARKS at measured reference cells
    array_push(_L, ["obj_mercato_prop", 8,    4,    1,    "spr_duomo_exterior",       "solid"]);
    array_push(_L, ["obj_mercato_prop", 15.9, 7.6,  1,    "spr_florence_campanile",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 29,   5.8,  0.85, "spr_palazzo_signoria",     "solid"]);
    array_push(_L, ["obj_mercato_prop", 34.5, 8.2,  0.8,  "spr_merchant_guild",       "solid"]);
    array_push(_L, ["obj_mercato_prop", 30,   13,   0.85, "spr_parish_church",        "solid"]);
    array_push(_L, ["obj_mercato_prop", 19.2, 15,   0.8,  "spr_locanda_exterior",     "solid"]);
    array_push(_L, ["obj_mercato_prop", 31.8, 18,   0.8,  "spr_apothecary",           "solid"]);
    array_push(_L, ["obj_mercato_prop", 18,   5.2,  1,    "spr_florence_stable",      "solid"]);
    // STEP 6 — ARTISANS DISTRICT (southwest, flanking the artisans lane y17-19)
    array_push(_L, ["obj_mercato_prop", 6,    14.6, 0.7,  "spr_artisan_workshop_a",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 9.2,  14.7, 0.7,  "spr_artisan_workshop_b",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 6,    19.2, 0.7,  "spr_artisan_forge",        "solid"]);
    array_push(_L, ["obj_mercato_prop", 9.6,  19.4, 0.8,  "spr_florence_cottage",     "solid"]);
    // STEP 6 — RESIDENTIAL fill (narrow residences + row blocks + cottages)
    var _res = [[15.2,11],[17,11.2],[20.8,11],[15.5,19.6],[17,19.8],
                [25.6,15.5],[27,15.7],[33,14.5],[34.6,14.7],[31.5,21.4]];
    for (var _i = 0; _i < array_length(_res); _i++)
        array_push(_L, ["obj_mercato_prop", _res[_i][0], _res[_i][1], 1, "spr_florence_residence", "solid"]);
    array_push(_L, ["obj_mercato_prop", 15,   12.5, 0.8,  "spr_florence_row_block",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 15.5, 1.5,  0.8,  "spr_florence_row_block",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 25.8, 19.6, 0.8,  "spr_florence_cottage",     "solid"]);
    array_push(_L, ["obj_mercato_prop", 38,   14.2, 0.8,  "spr_florence_cottage",     "solid"]);
    // STEP 6 — NOBLE TOWERS + tower houses (Florence's skyline of family towers)
    var _twr = [[21.8,12],[27.3,7.2],[12.2,21.3],[33.8,12.6]];
    for (var _t = 0; _t < array_length(_twr); _t++)
        array_push(_L, ["obj_mercato_prop", _twr[_t][0], _twr[_t][1], 1, "spr_florence_noble_tower", "solid"]);
    array_push(_L, ["obj_mercato_prop", 35,   2.5,  0.7,  "spr_florence_tower_house", "solid"]);
    array_push(_L, ["obj_mercato_prop", 18.5, 2,    0.7,  "spr_florence_tower_house", "solid"]);
    // STEP 7 — PIAZZA DEL GRANDE MERCATO: fountain centre, ring of awning stalls
    array_push(_L, ["obj_mercato_prop", 23.5, 7.8,  1,    "spr_mercato_fountain_piazza", "solid"]);
    var _stl = [[21.8,7.3],[25.6,7.3],[21.8,9.4],[25.6,9.4],[23.6,6.3],[23.6,10.3]];
    for (var _s = 0; _s < array_length(_stl); _s++)
        array_push(_L, ["obj_mercato_prop", _stl[_s][0], _stl[_s][1], 0.7, "spr_mercato_stall_awning", "solid"]);
    array_push(_L, ["obj_marco_stall",  22,   10.6, 0.7]);
    array_push(_L, ["obj_barrel",       21.2, 8.4,  0.5]);
    array_push(_L, ["obj_barrel",       26.6, 8.6,  0.5]);
    array_push(_L, ["obj_mercato_prop", 26.3, 6.5,  0.5,  "spr_crate_stack",          "solid"]);
    array_push(_L, ["obj_cart",         20.2, 9.8,  0.6]);
    // PUBLIC WELL + fountain on the south plaza (reference centre-south)
    array_push(_L, ["obj_well",         23,   22.6, 0.7]);
    array_push(_L, ["obj_mercato_prop", 24.4, 23.2, 0.8,  "spr_mercato_fountain",     "solid"]);
    array_push(_L, ["obj_cart",         19.5, 23.8, 0.6]);
    array_push(_L, ["obj_barrel",       26.2, 22.3, 0.5]);
    array_push(_L, ["obj_barrel",       20,   21.8, 0.5]);
    // STEP 8 — STREET DETAILS: shrines on corners, torches on main streets,
    // cats near market/tavern, pigeons near the fountains, washing lines
    var _shr = [[14.6,10.3],[22.5,16.2],[30.4,12.4],[8.9,21.4],[26.5,23.4]];
    for (var _h = 0; _h < array_length(_shr); _h++)
        array_push(_L, ["obj_mercato_prop", _shr[_h][0], _shr[_h][1], 1, "spr_florence_street_shrine"]);
    var _tor = [[22.7,11],[24.9,13.5],[22.7,17],[24.9,20],[35.3,14],[37.4,18],
                [13.5,8.6],[19.5,8.6],[28.7,11.2],[33,11.2]];
    for (var _o = 0; _o < array_length(_tor); _o++)
        array_push(_L, ["obj_mercato_prop", _tor[_o][0], _tor[_o][1], 1, "spr_florence_wall_torch"]);
    var _cat = [[26.3,9.8],[21.6,17.8],[32.6,20.6]];
    for (var _c = 0; _c < array_length(_cat); _c++)
        array_push(_L, ["obj_mercato_prop", _cat[_c][0], _cat[_c][1], 1, "spr_florence_stray_cat"]);
    var _pig = [[24.3,9.6],[23,7.5],[21,23.2],[25.2,24.2]];
    for (var _p = 0; _p < array_length(_pig); _p++)
        array_push(_L, ["obj_mercato_prop", _pig[_p][0], _pig[_p][1], 1, "spr_florence_pigeon_cluster"]);
    var _wsh = [[16,11.7],[25.7,16.9],[33.4,15.9]];
    for (var _w = 0; _w < array_length(_wsh); _w++)
        array_push(_L, ["obj_mercato_prop", _wsh[_w][0], _wsh[_w][1], 1, "spr_florence_washing_line"]);
    // citizens (reused from the project set; walk-through)
    array_push(_L, ["obj_mercato_prop", 23.6, 12.5, 1, "spr_citizen_man"]);
    array_push(_L, ["obj_mercato_prop", 36.5, 21,   1, "spr_citizen_man"]);
    array_push(_L, ["obj_mercato_prop", 10,   21.5, 1, "spr_citizen_man"]);
    array_push(_L, ["obj_mercato_prop", 24,   8.8,  1, "spr_citizen_woman"]);
    array_push(_L, ["obj_mercato_prop", 22,   23.5, 1, "spr_citizen_woman"]);
    array_push(_L, ["obj_mercato_prop", 31,   16.5, 1, "spr_citizen_monk"]);
    // cypress trees
    var _cyp = [[5,5],[16,21],[28,21.5],[38.5,9],[2.2,12],[11,2.5],[33,22.5]];
    for (var _y = 0; _y < array_length(_cyp); _y++)
        array_push(_L, ["obj_cypress_tree", _cyp[_y][0], _cyp[_y][1], 0.7]);
    // VEGETATION flourish — Tuscan olives, street flower beds, doorstep pots
    var _olv = [[3,8],[10.5,23.5],[38.5,5],[27,2.2]];
    for (var _v = 0; _v < array_length(_olv); _v++)
        array_push(_L, ["obj_mercato_prop", _olv[_v][0], _olv[_v][1], 1, "spr_florence_olive_tree", "solid"]);
    var _fbd = [[21.3,6.6],[26.2,6.6],[20.6,22.2],[26,24.6],[14.9,10.8],[30.2,17.6]];
    for (var _b2 = 0; _b2 < array_length(_fbd); _b2++)
        array_push(_L, ["obj_mercato_prop", _fbd[_b2][0], _fbd[_b2][1], 1, "spr_florence_flower_bed"]);
    var _pot = [[19.4,17.9],[32.2,20.2],[23.1,10.9],[34.9,10.9]];
    for (var _q = 0; _q < array_length(_pot); _q++)
        array_push(_L, ["obj_mercato_prop", _pot[_q][0], _pot[_q][1], 1, "spr_inn_plant"]);
    // LITTLE WALLS — the reference's internal low walls (a signature of the
    // Florentine fabric): Duomo precinct yard, district edges, courtyards,
    // Arno terraces. 2-cell segments; trailing 90 = vertical run.
    var _lwH = [[8.5,10.6],[10.5,10.6],          // Duomo precinct, south edge
                [5.8,13.6],[7.8,13.6],           // Artisans district, north edge
                [5.8,21.6],[7.8,21.6],           // Artisans district, south edge
                [29.5,11],[31.5,11],             // Palazzo courtyard wall
                [32.5,21.8],                     // Apothecary block, south
                [27.2,5.8]];                     // market piazza NE corner
    for (var _lw = 0; _lw < array_length(_lwH); _lw++)
        array_push(_L, ["obj_mercato_prop", _lwH[_lw][0], _lwH[_lw][1], 1, "spr_florence_low_wall", "solid"]);
    var _lwV = [[6.8,5.5],[6.8,7.5],             // Duomo precinct, west run
                [38.8,13.5],[38.8,15.5],         // Arno terrace walls
                [35.4,18.5]];                    // Apothecary block, east
    for (var _lv = 0; _lv < array_length(_lwV); _lv++)
        array_push(_L, ["obj_mercato_prop", _lwV[_lv][0], _lwV[_lv][1], 1, "spr_florence_low_wall", "solid", 90]);
    return _L;
}

/// Place one v2 prop (draggable, F8-saveable; solid only when flagged).
function scr_fv2_place(_objname, _gx, _gy, _sc, _sprn, _solid, _layer) {
    var _obj = asset_get_index(_objname);
    if (_obj < 0 || asset_get_type(_objname) != asset_object) return noone;
    var _inst = (_layer != "")
        ? instance_create_layer(_gx * FV2_GRID, _gy * FV2_GRID, _layer, _obj)
        : instance_create_depth(_gx * FV2_GRID, _gy * FV2_GRID, 100, _obj);
    _inst.image_xscale = _sc;  _inst.image_yscale = _sc;
    _inst.room_builder_placed = true;
    _inst.builder_sprite = "";  _inst.builder_solid = false;  _inst.builder_angle = 0;
    if (_sprn != "") {
        var _sid = asset_get_index(_sprn);
        if (_sid >= 0 && asset_get_type(_sprn) == asset_sprite) {
            _inst.sprite_index = _sid;  _inst.builder_sprite = _sprn;
        }
    }
    if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = _solid;
    array_push(global.room_builder_objects, _inst);
    return _inst;
}

function scr_fv2_default_place() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _L = scr_fv2_default_layout();
    for (var _i = 0; _i < array_length(_L); _i++) {
        var _e = _L[_i];
        var _spr   = (array_length(_e) >= 5) ? _e[4] : "";
        var _solid = (array_length(_e) >= 6 && _e[5] == "solid");
        var _inst  = scr_fv2_place(_e[0], _e[1], _e[2], _e[3], _spr, _solid, _layer);
        // optional trailing ANGLE (deg CW, centre-pivot) — used by vertical
        // low-wall runs; drawn via scr_room_builder_draw_rotated
        if (_inst != noone && array_length(_e) >= 7 && is_real(_e[6]))
            _inst.builder_angle = _e[6];
    }
}

/// Read a saved v2 layout (OBJECT GX GY SCALE [SPRITE] [solid] [ANGLE]).
function scr_fv2_load(_path) {
    var _f = file_text_open_read(_path);
    if (_f == -1) return 0;
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _n = 0;
    while (!file_text_eof(_f)) {
        var _raw = file_text_read_string(_f); file_text_readln(_f);
        var _l = string_trim(string_replace_all(_raw, chr(13), ""));
        if (_l == "" || string_char_at(_l, 1) == "#") continue;
        var _t = scr_room_builder_tokenize(_l);
        if (array_length(_t) < 3) continue;
        var _sc = (array_length(_t) >= 4) ? real(_t[3]) : 1;
        var _spr = "";
        if (array_length(_t) >= 5 && asset_get_index(_t[4]) >= 0 && asset_get_type(_t[4]) == asset_sprite) _spr = _t[4];
        var _solid = false;
        for (var _k = 4; _k < array_length(_t); _k++) if (_t[_k] == "solid") _solid = true;
        var _ang  = 0;
        var _last = _t[array_length(_t) - 1];
        if (array_length(_t) >= 5 && string_digits(_last) == _last && _last != "") _ang = real(_last);
        var _inst = scr_fv2_place(_t[0], real(_t[1]), real(_t[2]), _sc, _spr, _solid, _layer);
        if (_inst != noone) { _inst.builder_angle = _ang; _n++; }
    }
    file_text_close(_f);
    return _n;
}

// ── BUILD: layout + collision + ALL transitions (Steps 4, 9, 10) ───────────────
function scr_fv2_build() {
    if (room != Room_florence_v2) return;
    // keep-alive: name-placed sprites/objects are invisible to the stripper.
    global.__fv2_keep     = [obj_mercato_prop, obj_marco_stall, obj_well, obj_cart,
        obj_barrel, obj_cypress_tree, obj_duomo_entrance, obj_stable_entrance];
    global.__fv2_keep_spr = [spr_florence_road_cobble, spr_florence_road_intersection,
        spr_florence_road_edge, spr_florence_grass, spr_florence_street,
        spr_florence_wall_section, spr_florence_wall_gate, spr_florence_wall_tower,
        spr_florence_wall_tile, spr_florence_water, spr_river_stone, spr_ponte_vecchio_ew,
        spr_florence_tower_house, spr_florence_row_block, spr_florence_cottage,
        spr_duomo_exterior, spr_florence_campanile, spr_palazzo_signoria,
        spr_merchant_guild, spr_parish_church, spr_locanda_exterior, spr_apothecary,
        spr_florence_stable, spr_artisan_workshop_a, spr_artisan_workshop_b,
        spr_artisan_forge, spr_citizen_man, spr_citizen_woman, spr_citizen_monk,
        spr_mercato_fountain, spr_crate_stack,
        spr_florence_residence, spr_florence_noble_tower, spr_mercato_stall_awning,
        spr_mercato_fountain_piazza, spr_florence_street_shrine, spr_florence_wall_torch,
        spr_florence_stray_cat, spr_florence_pigeon_cluster, spr_florence_washing_line,
        spr_arno_stone_bank, spr_florence_olive_tree, spr_florence_flower_bed,
        spr_inn_plant, spr_florence_low_wall];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    // props: saved layout (version-guarded) or the code default
    var _path   = working_directory + "room_florence_v2_layout.txt";
    var _placed = scr_room_builder_layout_current(_path) ? scr_fv2_load(_path) : 0;
    if (_placed == 0) scr_fv2_default_place();

    // walls + river + edge collision
    var _solids = scr_fv2_walls();
    array_push(_solids, [0, 0, room_width, 8]);
    array_push(_solids, [0, room_height - 8, room_width, room_height]);
    array_push(_solids, [0, 0, 8, room_height]);
    array_push(_solids, [room_width - 8, 0, room_width, room_height]);
    // river band split around the Ponte deck (banks included via -22/+22)
    array_push(_solids, [FV2_RIVER_X0 - 22, 0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1, FV2_RIVER_X1 + 22, room_height]);
    // deck handrails (16px, matches the drawn parapets)
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0 + 16]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1 - 16, FV2_RIVER_X1 + 22, FV2_PONTE_Y1]);
    for (var _w = 0; _w < array_length(_solids); _w++) {
        var _s = _solids[_w];
        var _wl = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _wl.wall_w = _s[2] - _s[0]; _wl.wall_h = _s[3] - _s[1]; _wl.visible = false;
    }
    scr_room_builder_build_collision();   // tight per-prop footprints

    // gate transitions → future FF-Tactics overworld (coming soon until built)
    scr_transition_spawn("fv2_west_gate",  448,  1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
    scr_transition_spawn("fv2_south_gate", 2304, 1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
    // Ponte Vecchio entry zones — W/E half decides the bridge-room landing
    var _deckmid = (FV2_RIVER_X0 + FV2_RIVER_X1) * 0.5;
    scr_transition_spawn("fv2_ponte_w", FV2_RIVER_X0 - 22, FV2_PONTE_Y0 + 16,
        _deckmid - (FV2_RIVER_X0 - 22), FV2_PONTE_Y1 - FV2_PONTE_Y0 - 32,
        "Room_ponte_vecchio", "Ponte Vecchio", 288, 200, "The Ponte Vecchio");
    scr_transition_spawn("fv2_ponte_e", _deckmid, FV2_PONTE_Y0 + 16,
        (FV2_RIVER_X1 + 22) - _deckmid, FV2_PONTE_Y1 - FV2_PONTE_Y0 - 32,
        "Room_ponte_vecchio", "Ponte Vecchio", 288, 700, "The Ponte Vecchio");

    // STEP 10 — interior entrances, bbox-following like the old map
    var _dux = 704, _duy = 712;
    var _stx = 1216, _sty = 548;
    var _inx = 1331, _iny = 1170;
    var _chx = 2016, _chy = 1066;
    for (var _e = 0; _e < array_length(global.room_builder_objects); _e++) {
        var _p = global.room_builder_objects[_e];
        if (!instance_exists(_p)) continue;
        if (_p.sprite_index == spr_duomo_exterior)      { _dux = (_p.bbox_left + _p.bbox_right) * 0.5; _duy = _p.bbox_bottom + 48; }
        if (_p.sprite_index == spr_florence_stable)     { _stx = (_p.bbox_left + _p.bbox_right) * 0.5; _sty = _p.bbox_bottom + 48; }
        if (_p.sprite_index == spr_locanda_exterior)    { _inx = (_p.bbox_left + _p.bbox_right) * 0.5; _iny = _p.bbox_bottom; }
        if (_p.sprite_index == spr_parish_church)       { _chx = (_p.bbox_left + _p.bbox_right) * 0.5; _chy = _p.bbox_bottom; }
    }
    instance_create_depth(_dux, _duy, 400, obj_duomo_entrance);
    instance_create_depth(_stx, _sty, 400, obj_stable_entrance);
    scr_transition_spawn("fv2_inn", _inx - 64, _iny + 8, 128, 56,
        "Room_locanda_rosa_camuna", "Locanda della Rosa Camuna", 512, 960, "");
    scr_transition_spawn("fv2_church", _chx - 64, _chy + 8, 128, 56,
        "Room_parish_church", "Parish Church", 0, 0, "");
}

/// Rebuild v2 collision after debug drag/nudge/delete.
function scr_fv2_rebuild_collision() {
    if (room != Room_florence_v2) return;
    with (obj_wall) instance_destroy();
    with (obj_mercato_exit) instance_destroy();
    with (obj_duomo_entrance) instance_destroy();
    with (obj_stable_entrance) instance_destroy();
    var _keep = global.room_builder_objects;   // rebuild walls/transitions only
    // cheap full rebuild: clear walls + transitions then respawn them around the
    // CURRENT prop positions (props themselves are untouched)
    var _solids = scr_fv2_walls();
    array_push(_solids, [0, 0, room_width, 8]);
    array_push(_solids, [0, room_height - 8, room_width, room_height]);
    array_push(_solids, [0, 0, 8, room_height]);
    array_push(_solids, [room_width - 8, 0, room_width, room_height]);
    array_push(_solids, [FV2_RIVER_X0 - 22, 0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1, FV2_RIVER_X1 + 22, room_height]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0 + 16]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1 - 16, FV2_RIVER_X1 + 22, FV2_PONTE_Y1]);
    for (var _w = 0; _w < array_length(_solids); _w++) {
        var _s = _solids[_w];
        var _wl = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _wl.wall_w = _s[2] - _s[0]; _wl.wall_h = _s[3] - _s[1]; _wl.visible = false;
    }
    scr_room_builder_build_collision();
}

// ── STEP 11 — CORRUPTION STATES ────────────────────────────────────────────────
/// Street life + shrines react to Limbo corruption. Called from scene Draw.
///   0-49  clean: torches lit, candles burning, cats + pigeons out
///   50-74 dirty: half the torches dark, candles flicker, fewer animals
///   75-99 most torches dark, shrines faded/wrong, NO animals
///   100   all dark except GREEN remnant flames; the Madonna is GONE +
///         one-time chronicle line.
function scr_fv2_corruption_sync() {
    if (room != Room_florence_v2) return;
    if (!variable_global_exists("room_builder_objects")) return;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    var _objs = global.room_builder_objects;
    var _ai = 0;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        var _s = _o.builder_sprite;
        if (_s == "spr_florence_stray_cat" || _s == "spr_florence_pigeon_cluster") {
            _ai++;
            if (_corr >= 75)      _o.visible = false;
            else if (_corr >= 50) _o.visible = ((_ai mod 2) == 1);
            else                  _o.visible = true;
        } else if (_s == "spr_florence_street_shrine") {
            if (_corr >= 100) {
                _o.image_alpha = 0.20;   // the alcove, almost empty
                if (!variable_global_exists("fv2_madonna_noted")) {
                    global.fv2_madonna_noted = true;
                    scr_chronicle_add("The Madonna is gone. I do not know when she left. I do not know if anyone else noticed.");
                }
            } else if (_corr >= 75) _o.image_alpha = 0.55;   // faded, wrong somehow
            else                    _o.image_alpha = 1;
        }
    }
}

/// Torch flames + shrine candles — additive glow pass (after the floor).
function scr_fv2_torch_glow() {
    if (!variable_global_exists("room_builder_objects")) return;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    var _frac;                                  // fraction of torches still lit
    if      (_corr >= 100) _frac = 0.15;        // green remnants only
    else if (_corr >= 75)  _frac = 0.15;
    else if (_corr >= 50)  _frac = 0.5;
    else                   _frac = 1.0;
    var _green = (_corr >= 100);
    gpu_set_blendmode(bm_add);
    var _objs = global.room_builder_objects;
    var _ti = 0;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        var _is_torch  = (_o.builder_sprite == "spr_florence_wall_torch");
        var _is_shrine = (_o.builder_sprite == "spr_florence_street_shrine");
        if (!_is_torch && !_is_shrine) continue;
        _ti++;
        if (((_ti * 7) mod 100) / 100 >= _frac) continue;          // this one is dark
        if (_is_shrine && _corr >= 100) continue;                  // no candle: she is gone
        var _cx = _o.x + 16 * _o.image_xscale;
        var _cy = _o.y + (_is_shrine ? 52 : 16) * _o.image_yscale;
        var _flick = 1 + 0.08 * sin(current_time * 0.004 + _o.x * 0.13 + _o.y * 0.07);
        var _r = (_is_shrine ? 22 : 34) * _flick;
        if (_corr >= 50 && _corr < 75 && _is_shrine) _flick *= 0.7;   // uneasy flicker
        draw_set_color(_green ? make_color_rgb(70, 235, 110) : make_color_rgb(255, 186, 96));
        draw_set_alpha((_green ? 0.30 : 0.24) * _flick);
        draw_circle(_cx, _cy, _r, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
