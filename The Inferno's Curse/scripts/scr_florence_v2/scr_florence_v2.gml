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
        [ 7, 19,  9, 21, 0],   // connector: Artisans lane down to the west road
        [27, 10, 40, 12, 0],   // Ponte Vecchio road (2 cells; touches the market plaza at y10)
        [28, 12, 30, 22, 0],   // Parish-Church lane south (touches the Ponte road at y12)
        [15,  5, 28,  7, 0],   // north lane: Duomo -> Palazzo (touches the plaza at y7)
        [33, 11, 35, 17, 0],   // east alley: breaks up the guild/apothecary block (GAP 5)
        [25, 10, 27, 12, 0],   // market SE link: closes the gap between the main
                               // street (x25) and the Ponte road (x27) — user fix 2
        // paved precincts LAST so they pave over any road beneath (GAP 2)
        [ 7,  4, 17, 11, 1],   // Piazza del Duomo — the cathedral's paved precinct
        [29, 10, 34, 12, 1],   // Piazza della Signoria — paved front of the palazzo
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

/// THIN PRECINCT WALLS — VOID WALL + ART standard, single geometry source for
/// drawing AND collision (32px bands). ONLY the Duomo precinct yard lives
/// here; the INNER CITY WALLS along the streets are scr_fv2_street_walls.
function scr_fv2_precinct_walls() {
    return [
        [448, 256, 480, 704],     // west edge of the Piazza del Duomo
        [448, 672, 640, 704],     // south edge, west of the cathedral doors
        [896, 672, 1088, 704],    // south edge, east of the lane
    ];
}

/// TRUE if the point lies inside any road/plaza rect (used to keep junction
/// mouths open in the street walls).
function scr_fv2_on_ground(_px, _py) {
    var _roads = scr_fv2_roads();
    for (var _i = 0; _i < array_length(_roads); _i++) {
        var _r = _roads[_i];
        if (_px >= round(_r[0]) * 64 && _px < round(_r[2]) * 64
         && _py >= round(_r[1]) * 64 && _py < round(_r[3]) * 64) return true;
    }
    return false;
}

/// INNER CITY STREET WALLS — the thin tan walls along every road's long
/// edges, made REAL per David: each 64px segment is a 24px void+art band
/// that is ALSO collision. Segments are SKIPPED wherever the ground just
/// beyond the edge is another road or plaza (junction mouths stay open) or
/// where a deliberate opening exists (the church door). Single source:
/// drawn by the scene's road pass, collided in build + rebuild.
function scr_fv2_street_walls() {
    var _roads = scr_fv2_roads();
    var _n = array_length(_roads);
    // deliberate openings [x0,y0,x1,y1]: segments touching these are skipped
    var _open = [
        [1900, 820, 1980, 980],    // church lane east edge, at the church door
    ];
    var _out = [];
    for (var _c = 0; _c < _n; _c++) {
        var _cr = _roads[_c];
        if (_cr[4] != 0) continue;
        var _cx0 = round(_cr[0]) * 64, _cy0 = round(_cr[1]) * 64;
        var _cx1 = round(_cr[2]) * 64, _cy1 = round(_cr[3]) * 64;
        var _horiz = (_cx1 - _cx0) >= (_cy1 - _cy0);
        // entry = [x0, y0, x1, y1, kind] — kind 0 UPPER (road's north edge),
        // 1 LOWER (south edge), 2 vertical. Drawing uses the rect as-is;
        // collision applies per-kind tuning (scr_fv2_street_wall_solid).
        if (_horiz) {
            for (var _ex = _cx0; _ex < _cx1; _ex += 64) {
                var _xe = min(_ex + 64, _cx1);
                if (!scr_fv2_on_ground(_ex + 32, _cy0 - 32) && !scr_fv2_wall_open(_ex, _cy0 - 4, _xe, _cy0 + 20, _open))
                    array_push(_out, [_ex, _cy0 - 4, _xe, _cy0 + 20, 0]);
                if (!scr_fv2_on_ground(_ex + 32, _cy1 + 32) && !scr_fv2_wall_open(_ex, _cy1 - 20, _xe, _cy1 + 4, _open))
                    array_push(_out, [_ex, _cy1 - 20, _xe, _cy1 + 4, 1]);
            }
        } else {
            for (var _ey = _cy0; _ey < _cy1; _ey += 64) {
                var _ye = min(_ey + 64, _cy1);
                if (!scr_fv2_on_ground(_cx0 - 32, _ey + 32) && !scr_fv2_wall_open(_cx0 - 4, _ey, _cx0 + 20, _ye, _open))
                    array_push(_out, [_cx0 - 4, _ey, _cx0 + 20, _ye, 2]);
                if (!scr_fv2_on_ground(_cx1 + 32, _ey + 32) && !scr_fv2_wall_open(_cx1 - 20, _ey, _cx1 + 4, _ye, _open))
                    array_push(_out, [_cx1 - 20, _ey, _cx1 + 4, _ye, 2]);
            }
        }
    }
    return _out;
}

/// Collision rect for one street-wall entry — asymmetric per David's burst:
/// UPPER walls block EARLY (extended 16px south so the player can never walk
/// his body into the art); LOWER walls block LATE (top 12px shaved so his
/// feet reach the stone and he stands flush). Vertical walls as drawn.
function scr_fv2_street_wall_solid(_ws) {
    if (_ws[4] == 0) return [_ws[0], _ws[1], _ws[2], _ws[3] + 16];   // upper: can't enter
    if (_ws[4] == 1) return [_ws[0], _ws[1] + 12, _ws[2], _ws[3]];   // lower: get closer
    return [_ws[0], _ws[1], _ws[2], _ws[3]];
}

/// TRUE if a candidate wall segment intersects any deliberate opening.
function scr_fv2_wall_open(_x0, _y0, _x1, _y1, _open) {
    for (var _i = 0; _i < array_length(_open); _i++) {
        var _o = _open[_i];
        if (_x0 < _o[2] && _x1 > _o[0] && _y0 < _o[3] && _y1 > _o[1]) return true;
    }
    return false;
}

/// Paint the walls STABLE-STYLE (the user's standing technique): each band is a
/// SOLID BLACK void block with stone texture tiles inset (black outline frame)
/// and a lit top edge; crenellation merlons tooth the city-facing side; then the
/// gatehouses, corner towers and wall piers are dropped on top.
function scr_fv2_draw_walls(_corr01) {
    var _segs = scr_fv2_walls();
    // CONTIGUOUS procedural masonry on the black void body (the texture-tile
    // approach read as disconnected dots — user feedback): each 32x16 block is
    // a SOLID rectangle in one of three alternating tones, separated only by
    // the 2px black mortar seams of the void beneath. Courses offset like real
    // running-bond stonework. Fully connected, never uniform.
    var _col_a = merge_color(make_color_rgb(196, 186, 166), make_color_rgb(104, 106, 118), _corr01);
    var _col_b = merge_color(make_color_rgb(150, 144, 134), make_color_rgb(82, 84, 96),    _corr01);
    var _col_c = merge_color(make_color_rgb(112, 106, 100), make_color_rgb(62, 64, 74),    _corr01);
    var _top  = merge_color(make_color_rgb(168, 162, 148), make_color_rgb(70, 70, 78),   _corr01);
    var _bw   = 32;   // block width
    var _bh   = 16;   // block (course) height
    var _inset = 4;
    for (var _i = 0; _i < array_length(_segs); _i++) {
        var _s = _segs[_i];
        draw_set_color(c_black);
        draw_rectangle(_s[0], _s[1], _s[2], _s[3], false);
        var _x0 = _s[0] + _inset, _y0 = _s[1] + _inset;
        var _x1 = _s[2] - _inset, _y1 = _s[3] - _inset;
        if (_x1 > _x0 && _y1 > _y0) {
            // PREFERRED: the band-sized masonry tile (spr_florence_wall_band,
            // 128x120 = the void's inner height) laid in ONE row down the band —
            // horizontal bands as-is, the vertical left wall rotated 90.
            var _band = asset_get_index("spr_florence_wall_band");
            if (_band >= 0 && asset_get_type("spr_florence_wall_band") == asset_sprite) {
                var _bw2 = sprite_get_width(_band);
                var _bh2 = sprite_get_height(_band);
                var _horiz = (_s[2] - _s[0]) >= (_s[3] - _s[1]);
                if (_horiz) {
                    for (var _tx = _x0; _tx < _x1; _tx += _bw2) {
                        var _w = min(_bw2, _x1 - _tx);
                        var _pick = (((_tx div 128) * 7) + _i * 3) mod 5;
                        var _tone = (_pick <= 1) ? c_white
                                  : ((_pick <= 3) ? merge_color(c_white, c_gray, 0.15)
                                                  : merge_color(c_white, c_gray, 0.30));
                        var _tint = merge_color(_tone, make_color_rgb(110, 112, 124), _corr01);
                        draw_sprite_part_ext(_band, 0, 0, 0, _w, min(_bh2, _y1 - _y0),
                            _tx, _y0, 1, 1, _tint, 1);
                    }
                } else {
                    for (var _tyv = _y0; _tyv < _y1; _tyv += _bw2) {
                        var _hseg = min(_bw2, _y1 - _tyv);
                        var _pick2 = (((_tyv div 128) * 7) + _i * 3) mod 5;
                        var _tone2 = (_pick2 <= 1) ? c_white
                                   : ((_pick2 <= 3) ? merge_color(c_white, c_gray, 0.15)
                                                    : merge_color(c_white, c_gray, 0.30));
                        var _tint2 = merge_color(_tone2, make_color_rgb(110, 112, 124), _corr01);
                        // rotated 90 CCW: a (w x 120) part drawn at (x0, ty+w)
                        // covers x0..x0+120 by ty..ty+w
                        draw_sprite_general(_band, 0, 0, 0, _hseg, min(_bh2, _x1 - _x0),
                            _x0, _tyv + _hseg, 1, 1, 90, _tint2, _tint2, _tint2, _tint2, 1);
                    }
                }
            } else {
                // FALLBACK: contiguous procedural running-bond blocks
                var _course = 0;
                for (var _ty = _y0; _ty < _y1; _ty += _bh) {
                    var _yb = min(_ty + _bh - 2, _y1);
                    var _off = (_course mod 2) * (_bw div 2);
                    for (var _tx2 = _x0 - _off; _tx2 < _x1; _tx2 += _bw) {
                        var _xa = max(_tx2, _x0);
                        var _xb = min(_tx2 + _bw - 2, _x1);
                        if (_xb <= _xa) continue;
                        var _pick3 = (((_tx2 div 32) * 7) + (_course * 13) + _i * 3) mod 5;
                        draw_set_color((_pick3 <= 1) ? _col_a : ((_pick3 <= 3) ? _col_b : _col_c));
                        draw_rectangle(_xa, _ty, _xb, _yb, false);
                    }
                    _course++;
                }
            }
            draw_set_color(_top);
            draw_rectangle(_x0, _y0, _x1, min(_y0 + 3, _y1), false);
        }
        // merlons — stone teeth on the CITY-facing edge of each band
        draw_set_color(c_black);
        var _mer_horiz = (_s[2] - _s[0]) >= (_s[3] - _s[1]);
        if (_mer_horiz) {
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
    // dressing: corner + curtain towers (12 total, every ~8-10 cells per the
    // reference — GAP 3; all sit ON the collided wall bands), wall piers, then
    // the two gatehouses over their gaps
    draw_sprite(spr_florence_wall_tower, 0, 224,  16);
    draw_sprite(spr_florence_wall_tower, 0, 224,  1648);
    draw_sprite(spr_florence_wall_tower, 0, 2488, 8);
    draw_sprite(spr_florence_wall_tower, 0, 2488, 1648);
    draw_sprite(spr_florence_wall_tower, 0, 2944, 8);
    draw_sprite(spr_florence_wall_tower, 0, 640,  8);     // top curtain
    draw_sprite(spr_florence_wall_tower, 0, 1152, 8);
    draw_sprite(spr_florence_wall_tower, 0, 1664, 8);
    draw_sprite(spr_florence_wall_tower, 0, 2176, 8);
    draw_sprite(spr_florence_wall_tower, 0, 224,  512);   // left curtain
    draw_sprite(spr_florence_wall_tower, 0, 224,  1024);
    draw_sprite(spr_florence_wall_tower, 0, 1280, 1648);  // bottom curtain
    draw_sprite(spr_florence_wall_section, 0, 768,  4);
    draw_sprite(spr_florence_wall_section, 0, 1408, 4);
    draw_sprite(spr_florence_wall_section, 0, 2048, 4);
    draw_sprite(spr_florence_wall_section, 0, 1024, 1642);
    draw_sprite(spr_florence_wall_section, 0, 1728, 1642);
    draw_sprite(spr_florence_wall_gate, 0, 448,  1630);   // West Gate
    draw_sprite(spr_florence_wall_gate, 0, 2304, 1630);   // South Gate
    // THIN PRECINCT WALLS — void wall + art (the permanent standard): the
    // PURPOSE-SIZED 128x32 thin tile fills the band; the city band tile is the
    // squash fallback if it's ever missing
    var _pw = scr_fv2_precinct_walls();
    var _pband = asset_get_index("spr_florence_thin_wall");
    if (_pband < 0 || asset_get_type("spr_florence_thin_wall") != asset_sprite)
        _pband = asset_get_index("spr_florence_wall_band");
    var _phas  = (_pband >= 0);
    for (var _p = 0; _p < array_length(_pw); _p++) {
        var _ps = _pw[_p];
        draw_set_color(c_black);
        draw_rectangle(_ps[0], _ps[1], _ps[2], _ps[3], false);
        var _px0 = _ps[0] + 3, _py0 = _ps[1] + 3;
        var _px1 = _ps[2] - 3, _py1 = _ps[3] - 3;
        if (_px1 <= _px0 || _py1 <= _py0) continue;
        if (_phas) {
            var _pbw = sprite_get_width(_pband);
            var _pvert = (_ps[3] - _ps[1]) > (_ps[2] - _ps[0]);
            if (_pvert) {
                var _psc = (_px1 - _px0) / sprite_get_height(_pband);
                for (var _pty = _py0; _pty < _py1; _pty += _pbw * _psc) {
                    var _pseg = min(_pbw * _psc, _py1 - _pty);
                    draw_sprite_general(_pband, 0, 0, 0, _pseg / _psc, sprite_get_height(_pband),
                        _px0, _pty + _pseg, _psc, _psc, 90,
                        merge_color(c_white, make_color_rgb(110,112,124), _corr01),
                        merge_color(c_white, make_color_rgb(110,112,124), _corr01),
                        merge_color(c_white, make_color_rgb(110,112,124), _corr01),
                        merge_color(c_white, make_color_rgb(110,112,124), _corr01), 1);
                }
            } else {
                var _psc2 = (_py1 - _py0) / sprite_get_height(_pband);
                for (var _ptx = _px0; _ptx < _px1; _ptx += _pbw * _psc2) {
                    var _pw2 = min(_pbw * _psc2, _px1 - _ptx);
                    draw_sprite_part_ext(_pband, 0, 0, 0, _pw2 / _psc2, sprite_get_height(_pband),
                        _ptx, _py0, _psc2, _psc2,
                        merge_color(c_white, make_color_rgb(110,112,124), _corr01), 1);
                }
            }
        } else {
            draw_set_color(merge_color(make_color_rgb(150,144,134), make_color_rgb(82,84,96), _corr01));
            draw_rectangle(_px0, _py0, _px1, _py1, false);
        }
    }
    draw_set_color(c_white);
}

// ── STEP 9 — THE ARNO (vertical east band, flows SOUTH) ────────────────────────
#macro FV2_RIVER_X0  2560
#macro FV2_RIVER_X1  2752
// Ponte crossing = EXACTLY the Ponte road band (y10-12) — deck, rails,
// transitions, river-collision gap and boat lane all align to the road.
#macro FV2_PONTE_Y0  640
#macro FV2_PONTE_Y1  768

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
    // SE river mouth — the Arno swells below the city's south wall (GAP 5):
    // an extra water block west of the band, outside the walls (y1766+)
    for (var _mx = 2410; _mx < FV2_RIVER_X0; _mx += 64)
        for (var _my = 1766 - _wh + _scroll; _my < room_height; _my += _wh)
            draw_sprite_part(spr_florence_water, 0, 0, max(0, 1766 - _my), 64,
                _wh - max(0, 1766 - _my), _mx, max(_my, 1766));
    draw_set_color(make_color_rgb(150, 140, 118));            // mouth west bank
    draw_rectangle(2388, 1766, 2410, room_height, false);
    draw_set_color(c_white);
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
    // the Ponte Vecchio crossing — COMPOSED from proven parts (every whole-
    // bridge generation came back as a side-view postcard): the deck is the
    // REAL road cobble continuing over the water at road width (y640-768,
    // aligned + sized to the Ponte road), with FF6 shop rows lining the
    // north and south edges — Florence's bridge of shops.
    var _t_deck = asset_get_index("spr_florence_road_cobble");
    if (_t_deck >= 0 && asset_get_type("spr_florence_road_cobble") == asset_sprite) {
        for (var _dy = FV2_PONTE_Y0; _dy < FV2_PONTE_Y1; _dy += 32)
            for (var _dx = FV2_RIVER_X0 - _bankw; _dx < FV2_RIVER_X1 + _bankw; _dx += 32)
                draw_sprite_ext(_t_deck, 0, _dx, _dy, 0.5, 0.5, 0, c_white, 1);
    }
    // ONE bridge image across the crossing (David): spr_ponte_vecchio_exterior —
    // the STUNNING Ponte Vecchio elevation (the FF6 world-map-icon principle:
    // a beautiful representation of the zone, not walkable geometry). Baked
    // water flood-keyed away so OUR animated corruption Arno flows above and
    // below it. Drawn at clean 2x, centred on the crossing — end blocks grip
    // both banks. Walking onto it triggers the zone zoom (the future entry
    // into the rebuilt EW bridge map).
    var _icw = sprite_get_width(spr_ponte_vecchio_exterior);
    var _ich = sprite_get_height(spr_ponte_vecchio_exterior);
    draw_sprite_ext(spr_ponte_vecchio_exterior, 0,
        (FV2_RIVER_X0 + FV2_RIVER_X1) * 0.5 - _icw,
        (FV2_PONTE_Y0 + FV2_PONTE_Y1) * 0.5 - _ich, 2, 2, 0, c_white, 1);
    // ROWING BOATS adrift south of the Ponte (GAP 6) — the drift follows the
    // current, so at 75%+ corruption the boats crawl back UPSTREAM with it
    var _boat = asset_get_index("spr_arno_rowing_boat");
    if (_boat >= 0 && asset_get_type("spr_arno_rowing_boat") == asset_sprite) {
        var _lane  = room_height - FV2_PONTE_Y1 - 208;   // drift lane below the south shop row
        var _drift = current_time / 1000 * _spd * 0.6;
        var _b1 = FV2_PONTE_Y1 + 96 + (((_drift + 200)       mod _lane) + _lane) mod _lane;
        var _b2 = FV2_PONTE_Y1 + 96 + (((_drift * 0.8 + 760) mod _lane) + _lane) mod _lane;
        var _bob = 3 * sin(current_time * 0.002);
        draw_sprite_ext(_boat, 0, FV2_RIVER_X0 + 26 + _bob, _b1, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_boat, 0, FV2_RIVER_X1 - 90 - _bob, _b2, 1, 1, 0, c_white, 1);
    }
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
    // GAP-1 pass 2026-06-10: the two x33-35 residences were consumed by the new
    // east alley; the cottage at (25.8,19.6) moved west to clear new infill.
    var _res = [[15.2,11],[17,11.2],[20.8,11],[15.5,19.6],[17,19.8],
                [25.6,15.5],[27,15.7],[31.5,21.4]];
    for (var _i = 0; _i < array_length(_res); _i++)
        array_push(_L, ["obj_mercato_prop", _res[_i][0], _res[_i][1], 1, "spr_florence_residence", "solid"]);
    array_push(_L, ["obj_mercato_prop", 15,   12.5, 0.8,  "spr_florence_row_block",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 15.5, 1.5,  0.8,  "spr_florence_row_block",   "solid"]);
    array_push(_L, ["obj_mercato_prop", 20.9, 19.9, 0.8,  "spr_florence_cottage",     "solid"]);
    array_push(_L, ["obj_mercato_prop", 38,   14.2, 0.8,  "spr_florence_cottage",     "solid"]);
    // GAP 1 — +16 INFILL (reference skyline density): north lane row, main
    // street east side, east quarter, west of the inn, Duomo precinct edge,
    // south plaza north side
    var _fill = [[21,2.6],[22.4,2.4],                       // north lane row
                 [25.7,12.4],[27,12.6],[25.7,19.8],         // main street east side
                 [35.1,13],[35.2,15.4],[38.3,16.4],         // east quarter
                 [14.6,15],[16,15],                         // west of the inn
                 [10.9,2],                                  // Duomo precinct edge
                 [18.4,20]];                                // south plaza north side
    for (var _f2 = 0; _f2 < array_length(_fill); _f2++)
        array_push(_L, ["obj_mercato_prop", _fill[_f2][0], _fill[_f2][1], 1, "spr_florence_residence", "solid"]);
    array_push(_L, ["obj_mercato_prop", 24,   3,    0.8,  "spr_florence_cottage",     "solid"]);   // north lane
    array_push(_L, ["obj_mercato_prop", 29.2, 21,   0.8,  "spr_florence_cottage",     "solid"]);   // east quarter
    array_push(_L, ["obj_mercato_prop", 5.3,  11.2, 0.8,  "spr_florence_cottage",     "solid"]);   // Duomo edge
    // STEP 6 — NOBLE TOWERS + tower houses (Florence's skyline of family towers)
    // (the x33.8 tower moved to the NE skyline — its old spot is the new alley)
    var _twr = [[21.8,12],[27.3,7.2],[12.2,21.3],[37.2,2.6],[26.6,1.8]];
    for (var _t = 0; _t < array_length(_twr); _t++)
        array_push(_L, ["obj_mercato_prop", _twr[_t][0], _twr[_t][1], 1, "spr_florence_noble_tower", "solid"]);
    array_push(_L, ["obj_mercato_prop", 35,   2.5,  0.7,  "spr_florence_tower_house", "solid"]);
    array_push(_L, ["obj_mercato_prop", 18.5, 2,    0.7,  "spr_florence_tower_house", "solid"]);
    // STEP 7 — PIAZZA DEL GRANDE MERCATO: fountain centre, ring of awning stalls
    array_push(_L, ["obj_mercato_prop", 23.5, 7.8,  1,    "spr_mercato_fountain_piazza", "solid"]);
    var _stl = [[21.8,7.3],[25.6,7.3],[21.8,9.4],[25.6,9.4],[23.6,6.3],[26.1,9.7],
                [20.8,6.6],[26.5,7.9]];   // GAP 5: denser stall rows like the reference
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
    array_push(_L, ["obj_mercato_prop", 25.7, 8.6,  1, "spr_citizen_woman"]);   // GAP 5: market crowd
    array_push(_L, ["obj_mercato_prop", 21.3, 9.9,  1, "spr_citizen_man"]);
    // cypress trees ((11,2.5) moved to (13,2.3) to clear the new Duomo-edge house)
    var _cyp = [[5,5],[16,21],[28,21.5],[38.5,9],[2.2,12],[13,2.3],[33,22.5]];
    for (var _y = 0; _y < array_length(_cyp); _y++)
        array_push(_L, ["obj_cypress_tree", _cyp[_y][0], _cyp[_y][1], 0.7]);
    // VEGETATION flourish — Tuscan olives, street flower beds, doorstep pots
    // ((27,2.2) olive moved to the east countryside — its spot is a new tower)
    var _olv = [[3,8],[10.5,23.5],[38.5,5],[44.5,11]];
    for (var _v = 0; _v < array_length(_olv); _v++)
        array_push(_L, ["obj_mercato_prop", _olv[_v][0], _olv[_v][1], 1, "spr_florence_olive_tree", "solid"]);
    // GAP 4 — TUSCAN COUNTRYSIDE outside the walls: tree belts framing the city
    // (left strip / below the south wall / east of the river), clear of both
    // gate road stubs
    var _ccy = [[0.9,4],[0.9,14],[1,22.8],                       // left strip cypress
                [12,29.2],[21.5,29.5],[31,28.8],                 // south belt cypress
                [44,3],[44.2,16]];                               // east-of-river cypress
    for (var _cc = 0; _cc < array_length(_ccy); _cc++)
        array_push(_L, ["obj_cypress_tree", _ccy[_cc][0], _ccy[_cc][1], 0.7]);
    var _col = [[0.7,8.5],[0.8,18.5],                            // left strip olives
                [3.5,28.6],[16,30],[26,30.1],                    // south belt olives
                [44.8,7.5]];                                     // east-of-river olive
    for (var _co = 0; _co < array_length(_col); _co++)
        array_push(_L, ["obj_mercato_prop", _col[_co][0], _col[_co][1], 1, "spr_florence_olive_tree", "solid"]);
    var _fbd = [[21.3,6.6],[26.2,6.6],[20.6,22.2],[26,24.6],[14.9,10.8],[30.2,17.6]];
    for (var _b2 = 0; _b2 < array_length(_fbd); _b2++)
        array_push(_L, ["obj_mercato_prop", _fbd[_b2][0], _fbd[_b2][1], 1, "spr_florence_flower_bed"]);
    var _pot = [[19.4,17.9],[32.2,20.2],[23.1,10.9],[34.9,10.9]];
    for (var _q = 0; _q < array_length(_pot); _q++)
        array_push(_L, ["obj_mercato_prop", _pot[_q][0], _pot[_q][1], 1, "spr_inn_plant"]);
    // FINISHING TOUCHES (2026-06-10, David's design rules): every district
    // answers "where am I?" by sight — loggia at the Mercato (walk-through
    // arcade over the north lane), arches at district street mouths, saints
    // at the holy places + St John at the Ponte approach, guild crests at the
    // trades, a shrine for the bare SE, and the cathedral green (the park).
    array_push(_L, ["obj_mercato_prop", 21.9, 4.6,  0.7, "spr_mercato_loggia"]);
    array_push(_L, ["obj_mercato_prop", 23,   9.5,  1.5, "spr_florence_arch"]);
    array_push(_L, ["obj_mercato_prop", 12,   16.5, 1.5, "spr_florence_arch"]);
    array_push(_L, ["obj_mercato_prop", 28,   11.4, 1.5, "spr_florence_arch"]);
    array_push(_L, ["obj_mercato_prop", 10.3, 10.2, 1,   "spr_florence_statue_saint", "solid"]);
    array_push(_L, ["obj_mercato_prop", 29.4, 12.2, 1,   "spr_florence_statue_saint", "solid"]);
    array_push(_L, ["obj_mercato_prop", 38.9, 9.6,  1,   "spr_florence_statue_saint", "solid"]);
    array_push(_L, ["obj_mercato_prop", 35.3, 11.1, 1,   "spr_florence_guild_banner"]);
    array_push(_L, ["obj_mercato_prop", 7.3,  14.3, 1,   "spr_florence_guild_banner"]);
    array_push(_L, ["obj_mercato_prop", 32.4, 17.7, 1,   "spr_florence_guild_banner"]);
    array_push(_L, ["obj_mercato_prop", 38.2, 15.4, 1,   "spr_florence_street_shrine"]);
    array_push(_L, ["obj_mercato_prop", 9.7,  11.2, 1,   "spr_florence_olive_tree", "solid"]);
    array_push(_L, ["obj_mercato_prop", 10.4, 12.3, 1,   "spr_florence_olive_tree", "solid"]);
    array_push(_L, ["obj_cypress_tree", 11.2, 11.1, 0.7]);
    array_push(_L, ["obj_mercato_prop", 9.8,  12.8, 1,   "spr_florence_flower_bed"]);
    array_push(_L, ["obj_mercato_prop", 11,   11.9, 1,   "spr_florence_flower_bed"]);
    // ICONIC STATUARY: the Marzocco + David flank the Signoria piazza (their
    // real home), Dante watches the cathedral green — the poet of the Inferno
    // standing in the city that is becoming one. All fade with corruption.
    array_push(_L, ["obj_mercato_prop", 31,   11.7, 1,   "spr_florence_statue_marzocco", "solid"]);
    array_push(_L, ["obj_mercato_prop", 32.8, 11.7, 1,   "spr_florence_statue_david",    "solid"]);
    array_push(_L, ["obj_mercato_prop", 9.3,  13,   1,   "spr_florence_statue_dante",    "solid"]);
    // LITTLE WALLS — the reference's internal low walls (a signature of the
    // Florentine fabric): Duomo precinct yard, district edges, courtyards,
    // Arno terraces. 2-cell segments; trailing 90 = vertical run.
    // (ALL low-wall prop segments removed 2026-06-10 — every thin wall is now
    //  CODE GEOMETRY in scr_fv2_precinct_walls: void band + inset art +
    //  collision from one source, per the VOID WALL + ART standard.)
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
    _inst.depth = -_inst.bbox_bottom;   // GLOBAL DEPTH RULE: layered by feet from frame 0
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
        spr_florence_grass, spr_florence_street,
        spr_florence_wall_section, spr_florence_wall_gate, spr_florence_wall_tower,
        spr_florence_water, spr_river_stone, spr_ponte_vecchio_exterior,
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
        spr_inn_plant, spr_florence_wall_band,
        spr_florence_packed_earth, spr_arno_rowing_boat, spr_florence_thin_wall,
        spr_florence_arch, spr_florence_statue_saint, spr_florence_guild_banner,
        spr_mercato_loggia, spr_florence_statue_marzocco, spr_florence_statue_david,
        spr_florence_statue_dante];

    if (variable_global_exists("cam_zoom_target")) global.cam_zoom_target = 1;   // fresh room = normal zoom
    global.cam_view_h = 384;   // restore the city framing (the Ponte uses 448)
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
    var _pwc = scr_fv2_precinct_walls();
    for (var _pc = 0; _pc < array_length(_pwc); _pc++) array_push(_solids, _pwc[_pc]);
    var _swc = scr_fv2_street_walls();   // inner city walls are SOLID (David)
    for (var _sc2 = 0; _sc2 < array_length(_swc); _sc2++)
        array_push(_solids, scr_fv2_street_wall_solid(_swc[_sc2]));   // per-kind tuning
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
    array_push(_solids, [2388, 1766, FV2_RIVER_X0, room_height]);   // SE river mouth (GAP 5)
    for (var _w = 0; _w < array_length(_solids); _w++) {
        var _s = _solids[_w];
        var _wl = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _wl.wall_w = _s[2] - _s[0]; _wl.wall_h = _s[3] - _s[1]; _wl.visible = false;
    }
    scr_room_builder_build_collision();   // tight per-prop footprints

    scr_fv2_spawn_transitions();
}

/// All v2 transitions + interior entrances in ONE place — called by build AND
/// by the debug collision rebuild (which destroys them first), so an F8 drag
/// pass can never leave the city with dead doors.
function scr_fv2_spawn_transitions() {
    // gate transitions → future FF-Tactics overworld (coming soon until built)
    scr_transition_spawn("fv2_west_gate",  448,  1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
    scr_transition_spawn("fv2_south_gate", 2304, 1654, 128, 100,
        "Room_overworld_tactics", "Tuscan Countryside", 0, 0, "");
    // Ponte Vecchio: the deck zone marker IS the doorway (FF6 city-icon
    // pattern) — stepping onto either half enters the rebuilt marketplace
    // bridge at the matching end.
    var _deckmid = (FV2_RIVER_X0 + FV2_RIVER_X1) * 0.5;
    scr_transition_spawn("fv2_ponte_w", FV2_RIVER_X0 - 22, FV2_PONTE_Y0 + 16,
        _deckmid - (FV2_RIVER_X0 - 22), FV2_PONTE_Y1 - FV2_PONTE_Y0 - 32,
        "Room_ponte_vecchio", "Ponte Vecchio", 96, 256, "Il Ponte Vecchio");
    scr_transition_spawn("fv2_ponte_e", _deckmid, FV2_PONTE_Y0 + 16,
        (FV2_RIVER_X1 + 22) - _deckmid, FV2_PONTE_Y1 - FV2_PONTE_Y0 - 32,
        "Room_ponte_vecchio", "Ponte Vecchio", 1184, 256, "Il Ponte Vecchio");
    // interior entrances, bbox-following like the old map
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

/// Rebuild v2 collision after debug drag/nudge/delete — clears walls AND
/// transitions/entrances, then respawns BOTH around the current prop positions.
function scr_fv2_rebuild_collision() {
    if (room != Room_florence_v2) return;
    with (obj_wall) instance_destroy();
    with (obj_mercato_exit) instance_destroy();
    with (obj_duomo_entrance) instance_destroy();
    with (obj_stable_entrance) instance_destroy();
    var _solids = scr_fv2_walls();
    var _pwc = scr_fv2_precinct_walls();
    for (var _pc = 0; _pc < array_length(_pwc); _pc++) array_push(_solids, _pwc[_pc]);
    var _swc = scr_fv2_street_walls();   // inner city walls are SOLID (David)
    for (var _sc2 = 0; _sc2 < array_length(_swc); _sc2++)
        array_push(_solids, scr_fv2_street_wall_solid(_swc[_sc2]));   // per-kind tuning
    array_push(_solids, [0, 0, room_width, 8]);
    array_push(_solids, [0, room_height - 8, room_width, room_height]);
    array_push(_solids, [0, 0, 8, room_height]);
    array_push(_solids, [room_width - 8, 0, room_width, room_height]);
    array_push(_solids, [FV2_RIVER_X0 - 22, 0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1, FV2_RIVER_X1 + 22, room_height]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y0, FV2_RIVER_X1 + 22, FV2_PONTE_Y0 + 16]);
    array_push(_solids, [FV2_RIVER_X0 - 22, FV2_PONTE_Y1 - 16, FV2_RIVER_X1 + 22, FV2_PONTE_Y1]);
    array_push(_solids, [2388, 1766, FV2_RIVER_X0, room_height]);   // SE river mouth (GAP 5)
    for (var _w = 0; _w < array_length(_solids); _w++) {
        var _s = _solids[_w];
        var _wl = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _wl.wall_w = _s[2] - _s[0]; _wl.wall_h = _s[3] - _s[1]; _wl.visible = false;
    }
    scr_room_builder_build_collision();
    scr_fv2_spawn_transitions();
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
        } else if (string_pos("spr_florence_statue", _s) == 1) {
            // ALL statuary fades with the shrines — saints, the Marzocco,
            // David, Dante: stone witnesses going quiet as the city falls
            if (_corr >= 100)     _o.image_alpha = 0.25;
            else if (_corr >= 75) _o.image_alpha = 0.60;
            else                  _o.image_alpha = 1;
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

// (Bridge zoom removed 2026-06-10 per David — the camera stays steady on the
//  crossing. The generic cam_zoom support remains in scr_camera for the real
//  zone transition when the EW bridge interior is rebuilt.)

// (scr_fv2_torch_glow RETIRED 2026-06-10 — superseded by the GLOBAL day/night
//  lighting system in obj_game_manager Draw GUI: same corruption snuffing and
//  green remnant flames, now time-of-day gated and active in EVERY room.)
