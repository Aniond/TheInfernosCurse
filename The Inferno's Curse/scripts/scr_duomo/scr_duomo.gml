// =============================================================================
// scr_duomo — Room_duomo interior — BLACK-VOID cross (20x22) + alcove fakery
// =============================================================================
// 20 x 22 cell grid (1280 x 1408 px). Walkable floor is a CROSS; side chambers
// are FAKED with alcove objects (shrine, confessional, transept statues). Outside
// is pure black void; a dark border tile outlines the edge. A FF6 scrolling camera
// (set in the room) shows only part of the cross at a time — distance sells scale.
//
//   NAVE   cols 6-13, rows 2-20      (carpet + columns + pews; apse at the top)
//   TRANS  cols 1-18, rows 9-12      (transept arms; crossing at the centre)
//   ENTRY  cols 9-11, row 21         (south doorway → Florence; save point)
// =============================================================================

#macro DUOMO_W_CELLS 30
#macro DUOMO_H_CELLS 37
#macro DUOMO_GRID_PX 64

// Cathedral exit doorway centre
#macro DUOMO_EXIT_X 960
#macro DUOMO_EXIT_Y 2336

// Boot straight into the cathedral
#macro DUOMO_LOAD_POINT false

// ── Cell predicates ─────────────────────────────────────────────────────────────
function scr_duomo_is_interior(_cx, _cy) {
    var _nave       = (_cx >= 10 && _cx <= 19 && _cy >= 6  && _cy <= 33);
    var _entry      = (_cx >= 12 && _cx <= 17 && _cy >= 34 && _cy <= 34);
    var _altar_back = (_cx >= 12 && _cx <= 17 && _cy >= 2  && _cy <= 5);
    
    // Chapels (Top)
    var _chapel_l   = (_cx >= 4  && _cx <= 8  && _cy >= 4  && _cy <= 10);
    var _chap_l_hal = (_cx == 9               && _cy == 10);
    var _chapel_r   = (_cx >= 21 && _cx <= 25 && _cy >= 4  && _cy <= 10);
    var _chap_r_hal = (_cx == 20              && _cy == 10);
    
    // Transepts (Wide Middle)
    var _trans_l    = (_cx >= 3  && _cx <= 9  && _cy >= 13 && _cy <= 17);
    var _trans_r    = (_cx >= 20 && _cx <= 26 && _cy >= 13 && _cy <= 17);
    
    // Crypt / Priest (Lower Middle)
    var _crypt      = (_cx >= 4  && _cx <= 8  && _cy >= 20 && _cy <= 24);
    var _crypt_hal  = (_cx == 9               && _cy == 24);
    var _priest     = (_cx >= 21 && _cx <= 25 && _cy >= 20 && _cy <= 24);
    var _priest_hal = (_cx == 20              && _cy == 24);
    
    // Treasury / Confessional (Bottom)
    var _treasury   = (_cx >= 4  && _cx <= 8  && _cy >= 27 && _cy <= 31);
    var _treas_hal  = (_cx == 9               && _cy == 31);
    var _confess    = (_cx >= 21 && _cx <= 25 && _cy >= 27 && _cy <= 31);
    var _conf_hal   = (_cx == 20              && _cy == 31);
    
    // South Exit Tunnel
    var _tunnel     = (_cx >= 14 && _cx <= 15 && _cy >= 35 && _cy <= 36);
    
    return _nave || _entry || _altar_back || 
           _chapel_l || _chap_l_hal || _chapel_r || _chap_r_hal ||
           _trans_l || _trans_r || 
           _crypt || _crypt_hal || _priest || _priest_hal || 
           _treasury || _treas_hal || _confess || _conf_hal ||
           _tunnel;
}

/// Apse dais — raised altar platform tile.
function scr_duomo_is_dais(_cx, _cy) {
    return (_cx >= 12 && _cx <= 17 && _cy >= 5 && _cy <= 10);
}

function scr_duomo_is_dome(_cx, _cy) {
    return (_cx >= 14 && _cx <= 15 && _cy >= 12 && _cy <= 13);
}

/// Void cell touching interior (8-neighbour) — invisible obj_wall collision ring.
function scr_duomo_is_wall(_cx, _cy) {
    if (_cx < 0 || _cx >= DUOMO_W_CELLS || _cy < 0 || _cy >= DUOMO_H_CELLS) return false;
    if (scr_duomo_is_interior(_cx, _cy)) return false;
    for (var _dx = -1; _dx <= 1; _dx++)
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (_dx == 0 && _dy == 0) continue;
            if (scr_duomo_is_interior(_cx + _dx, _cy + _dy)) return true;
        }
    return false;
}

/// Interior cell touching void (4-neighbour) — dark BORDER tile.
function scr_duomo_is_border(_cx, _cy) {
    if (!scr_duomo_is_interior(_cx, _cy)) return false;
    return (!scr_duomo_is_interior(_cx - 1, _cy) || !scr_duomo_is_interior(_cx + 1, _cy)
         || !scr_duomo_is_interior(_cx, _cy - 1) || !scr_duomo_is_interior(_cx, _cy + 1));
}

/// Inside-corner border cell — darkest corner tile.
function scr_duomo_is_corner(_cx, _cy) {
    if (!scr_duomo_is_interior(_cx, _cy)) return false;
    var _hout = (!scr_duomo_is_interior(_cx - 1, _cy) || !scr_duomo_is_interior(_cx + 1, _cy));
    var _vout = (!scr_duomo_is_interior(_cx, _cy - 1) || !scr_duomo_is_interior(_cx, _cy + 1));
    return _hout && _vout;
}


function scr_duomo_default_layout() {
    var _L = [];
    // Sanctuary (Altar)
    array_push(_L, ["obj_duomo_cross",       14.5, 3,    1]);
    array_push(_L, ["obj_duomo_altar",       14.5, 5,    1]);
    array_push(_L, ["obj_duomo_priest",      14.5, 7,   1]);
    array_push(_L, ["obj_duomo_candelabra",  12,   6,   0.6]);
    array_push(_L, ["obj_duomo_candelabra",  17,   6,   0.6]);
    
    // Nave
    var _crows = [17, 21, 25, 29, 33];
    for (var _ci = 0; _ci < array_length(_crows); _ci++) {
        array_push(_L, ["obj_duomo_pillar", 11, _crows[_ci], 1]);
        array_push(_L, ["obj_duomo_pillar", 18, _crows[_ci], 1]);
    }
    var _prows = [12, 14, 16, 18, 20, 22, 24, 26, 28, 30];
    for (var _pi = 0; _pi < array_length(_prows); _pi++) {
        array_push(_L, ["obj_duomo_pew", 13, _prows[_pi], 1, 0]);
        array_push(_L, ["obj_duomo_pew", 16, _prows[_pi], 1, 0]);
    }

    // Chapels
    array_push(_L, ["obj_shrine",            6,  6, 1]);      
    array_push(_L, ["obj_duomo_candelabra",  5,  8, 0.6]);    
    array_push(_L, ["obj_duomo_candelabra",  7,  8, 0.6]);
    array_push(_L, ["obj_shrine",            23, 6, 1]);      
    array_push(_L, ["obj_duomo_candelabra",  22, 8, 0.6]);    
    array_push(_L, ["obj_duomo_candelabra",  24, 8, 0.6]);
    
    // Transepts
    array_push(_L, ["obj_duomo_statue",      5,  15, 1]);      
    array_push(_L, ["obj_duomo_candelabra",  4,  15, 0.6]);
    array_push(_L, ["obj_duomo_candelabra",  6,  15, 0.6]);
    array_push(_L, ["obj_duomo_statue",      24, 15, 1]);      
    array_push(_L, ["obj_duomo_candelabra",  23, 15, 0.6]);
    array_push(_L, ["obj_duomo_candelabra",  25, 15, 0.6]);
    
    // Crypt (Tombs)
    array_push(_L, ["obj_duomo_statue",      4,  21, 1]);
    array_push(_L, ["obj_duomo_statue",      7,  21, 1]);
    
    // Priest Quarters
    array_push(_L, ["obj_duomo_pew",         22, 21, 1, 90]);
    array_push(_L, ["obj_duomo_pew",         25, 21, 1, 90]);
    
    // Treasury
    array_push(_L, ["obj_duomo_candelabra",  5,  29, 0.6]);
    
    // Confessional
    array_push(_L, ["obj_duomo_confessional",24, 29, 1]);      
    
    // Entrance / Save
    array_push(_L, ["obj_duomo_save_point",  14.5, 32, 1]);
    array_push(_L, ["obj_duomo_candelabra",  13,   32, 0.6]);
    array_push(_L, ["obj_duomo_candelabra",  16,   32, 0.6]);

    return _L;
}


// ── Build (called from obj_duomo_scene Create) ──────────────────────────────────
function scr_duomo_build() {
    if (room != Room_duomo) return 0;

    global.__duomo_keep = [obj_duomo_altar, obj_duomo_pillar, obj_duomo_pew,
        obj_duomo_confessional, obj_duomo_candelabra, obj_duomo_stairs,
        obj_duomo_save_point, obj_duomo_statue, obj_duomo_priest, obj_shrine, obj_duomo_cross];
    global.__duomo_keep_spr = [spr_statue_madonna];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_duomo_layout.txt";
    // Stale-layout guard: only load an F8-saved copy stamped with the CURRENT
    // DUOMO_LAYOUT_VERSION; otherwise the code default below takes over.
    var _placed = scr_room_builder_layout_current(_path) ? scr_duomo_load(_path) : 0;
    if (_placed == 0) scr_duomo_default_place();

    scr_duomo_build_collision();
    return array_length(global.room_builder_objects);
}

function scr_duomo_default_place() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _L = scr_duomo_default_layout();
    for (var _i = 0; _i < array_length(_L); _i++) {
        var _ang = (array_length(_L[_i]) >= 5) ? _L[_i][4] : 0;
        scr_duomo_place(_L[_i][0], _L[_i][1], _L[_i][2], _L[_i][3], _layer, _ang);
    }
}

function scr_duomo_load(_path) {
    var _f = file_text_open_read(_path);
    if (_f == -1) return 0;
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _n = 0;
    while (!file_text_eof(_f)) {
        var _raw  = file_text_read_string(_f); file_text_readln(_f);
        var _line = string_trim(string_replace_all(_raw, chr(13), ""));
        if (_line == "" || string_char_at(_line, 1) == "#") continue;
        var _tok = scr_room_builder_tokenize(_line);
        if (array_length(_tok) < 3) continue;
        var _sc = (array_length(_tok) >= 4) ? real(_tok[3]) : 1;
        var _ang = 0;
        if (array_length(_tok) >= 5) {
            var _at = _tok[array_length(_tok) - 1];
            if (_at != "" && string_digits(_at) == _at) _ang = real(_at);
        }
        if (scr_duomo_place(_tok[0], real(_tok[1]), real(_tok[2]), _sc, _layer, _ang) != noone) _n++;
    }
    file_text_close(_f);
    return _n;
}

function scr_duomo_place(_objname, _gx, _gy, _sc, _layer, _angle) {
    var _obj = asset_get_index(_objname);
    if (_obj < 0 || asset_get_type(_objname) != asset_object) {
        show_debug_message("[duomo] object not found -> " + string(_objname));
        return noone;
    }
    var _px = _gx * DUOMO_GRID_PX, _py = _gy * DUOMO_GRID_PX;
    var _inst = (_layer != "")
        ? instance_create_layer(_px, _py, _layer, _obj)
        : instance_create_depth(_px, _py, 100, _obj);
    _inst.image_xscale = _sc;
    _inst.image_yscale = _sc;
    _inst.room_builder_placed = true;
    _inst.builder_sprite = "";
    _inst.builder_solid  = false;
    _inst.builder_angle  = is_undefined(_angle) ? 0 : _angle;
    array_push(global.room_builder_objects, _inst);
    return _inst;
}

// ── Collision (invisible obj_wall ring around the cross) ─────────────────────────
function scr_duomo_build_collision() {
    for (var _cy = 0; _cy < DUOMO_H_CELLS; _cy++)
        for (var _cx = 0; _cx < DUOMO_W_CELLS; _cx++) {
            if (!scr_duomo_is_wall(_cx, _cy)) continue;
            var _w = instance_create_depth(_cx * DUOMO_GRID_PX, _cy * DUOMO_GRID_PX, 500, obj_wall);
            _w.wall_w  = DUOMO_GRID_PX;
            _w.wall_h  = DUOMO_GRID_PX;
            _w.visible = false;
        }

    if (!variable_global_exists("room_builder_objects")) return;
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++) {
        var _o = global.room_builder_objects[_i];
        if (!instance_exists(_o)) continue;
        if (_o.sprite_index == -1 || !sprite_exists(_o.sprite_index)) continue;

        var _x0f, _y0f, _x1f, _y1f;
        switch (_o.object_index) {
            case obj_duomo_pillar:       _x0f = 0.24; _y0f = 0.22; _x1f = 0.76; _y1f = 0.86; break;
            case obj_duomo_pew:          _x0f = 0.08; _y0f = 0.32; _x1f = 0.92; _y1f = 0.84; break;
            case obj_duomo_altar:        _x0f = 0.15; _y0f = 0.22; _x1f = 0.85; _y1f = 0.90; break;
            case obj_duomo_confessional: _x0f = 0.16; _y0f = 0.12; _x1f = 0.84; _y1f = 0.92; break;
            case obj_duomo_statue:       _x0f = 0.28; _y0f = 0.30; _x1f = 0.72; _y1f = 0.92; break;
            case obj_shrine:             _x0f = 0.10; _y0f = 0.30; _x1f = 0.90; _y1f = 0.90; break;
            case obj_duomo_candelabra:   _x0f = 0.25; _y0f = 0.60; _x1f = 0.75; _y1f = 0.95; break;
            case obj_duomo_priest:       _x0f = 0.25; _y0f = 0.50; _x1f = 0.75; _y1f = 0.95; break;
            case obj_duomo_save_point:   _x0f = 0.20; _y0f = 0.50; _x1f = 0.80; _y1f = 0.95; break;
            default: continue;
        }
        var _L = _o.bbox_left, _T = _o.bbox_top, _R = _o.bbox_right, _B = _o.bbox_bottom;
        var _bw = _R - _L, _bh = _B - _T;
        if (_bw <= 0 || _bh <= 0) continue;
        var _w = instance_create_depth(_L + _bw * _x0f, _T + _bh * _y0f, 500, obj_wall);
        _w.wall_w  = _bw * (_x1f - _x0f);
        _w.wall_h  = _bh * (_y1f - _y0f);
        _w.visible = false;
    }
}

/// Rebuild the duomo's collision from CURRENT prop positions (debug: after a drag /
/// nudge / delete) so footprints follow their props and no ghost boxes are left
/// behind. Safe only here — in Room_duomo every obj_wall comes from build_collision.
function scr_duomo_rebuild_collision() {
    if (room != Room_duomo) return;
    with (obj_wall) instance_destroy();
    scr_duomo_build_collision();
}
