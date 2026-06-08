// =============================================================================
// scr_inn — Room_fiorentine_inn (ground floor) — BLACK-VOID rectangular interior
// =============================================================================
// 20 x 20 cells (1280 x 1280). Walkable floor is an inset rectangle; the 1-cell
// black-void border is the walls. A 3-cell gap in the SOUTH wall (cols 9-11) is the
// entrance doorway. Props (obj_mercato_prop carrying a sprite, draggable like the
// market/bridge) lay out the reference zones: bar (N-left), kitchen hearth (left),
// storage barrels (top-right), stairs up (right), central dining tables+chairs on a
// red rug. INTERIOR room → black-void method (see CLAUDE.md). FF6 camera in the room.
// =============================================================================

#macro INN_W_CELLS 20
#macro INN_H_CELLS 20
#macro INN_GRID_PX 64

// South doorway centre — the entry gap + the return-to-Florence trigger.
#macro INN_EXIT_X 640
#macro INN_EXIT_Y 1216   // row 19 centre

// TEMP: boot straight into the inn for testing (takes precedence over DUOMO_LOAD_POINT
// in obj_game_manager Create). Flip to false to restore the normal start.
#macro INN_LOAD_POINT true

/// Player's guild-reputation TIER → which inn room the innkeeper offers.
/// <34 = low · 34-66 = medium · >66 = high. (global.guild_reputation, 0-100.)
function scr_inn_rep_tier() {
    var _r = variable_global_exists("guild_reputation") ? global.guild_reputation : 50;
    if (_r > 66)  return "high";
    if (_r >= 34) return "medium";
    return "low";
}

// ── Cell predicates ─────────────────────────────────────────────────────────────
function scr_inn_is_interior(_cx, _cy) {
    var _main  = (_cx >= 1 && _cx <= 18 && _cy >= 1 && _cy <= 18);
    var _entry = (_cy == 19 && _cx >= 9 && _cx <= 11);   // south doorway gap
    return _main || _entry;
}

/// Void cell touching interior (8-neighbour) — invisible obj_wall collision ring.
function scr_inn_is_wall(_cx, _cy) {
    if (_cx < 0 || _cx >= INN_W_CELLS || _cy < 0 || _cy >= INN_H_CELLS) return false;
    if (scr_inn_is_interior(_cx, _cy)) return false;
    for (var _dx = -1; _dx <= 1; _dx++)
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (_dx == 0 && _dy == 0) continue;
            if (scr_inn_is_interior(_cx + _dx, _cy + _dy)) return true;
        }
    return false;
}

/// Interior cell touching void (4-neighbour) — dark BORDER tile.
function scr_inn_is_border(_cx, _cy) {
    if (!scr_inn_is_interior(_cx, _cy)) return false;
    return (!scr_inn_is_interior(_cx - 1, _cy) || !scr_inn_is_interior(_cx + 1, _cy)
         || !scr_inn_is_interior(_cx, _cy - 1) || !scr_inn_is_interior(_cx, _cy + 1));
}

/// Inside-corner border cell — darkest corner tile.
function scr_inn_is_corner(_cx, _cy) {
    if (!scr_inn_is_interior(_cx, _cy)) return false;
    var _h = (!scr_inn_is_interior(_cx - 1, _cy) || !scr_inn_is_interior(_cx + 1, _cy));
    var _v = (!scr_inn_is_interior(_cx, _cy - 1) || !scr_inn_is_interior(_cx, _cy + 1));
    return _h && _v;
}

/// Red/brown dining rug — centre of the common room (drawn in obj_inn_scene Draw).
function scr_inn_is_rug(_cx, _cy) {
    return (_cx >= 7 && _cx <= 12 && _cy >= 8 && _cy <= 14);
}

// ── Default prop layout — [object, gx, gy, scale, (sprite)] ───────────────────────
// obj_mercato_prop carries the sprite + collision (solid), so every furniture piece
// is click-drag / nudge / rotate / Delete / F8 like the market & bridge props.
function scr_inn_default_layout() {
    var _L = [];
    // Zone 2 — TAVERN / BAR COUNTER along the north wall (128px each → cols 3-6).
    // Solid; the innkeeper nook behind it is sealed in scr_inn_build_collision.
    array_push(_L, ["obj_mercato_prop", 3, 2, 1, "spr_inn_counter"]);
    array_push(_L, ["obj_mercato_prop", 5, 2, 1, "spr_inn_counter"]);
    // Zone 4 — KITCHEN hearth + prep table (left wall)
    array_push(_L, ["obj_mercato_prop", 2,  7, 1, "spr_inn_fireplace"]);
    array_push(_L, ["obj_mercato_prop", 2, 10, 0.9, "spr_inn_table"]);
    // Common-room hearth (right wall) — the warm focal fire
    array_push(_L, ["obj_mercato_prop", 17, 13, 1, "spr_inn_fireplace"]);
    // Zone 5 — STORAGE / PANTRY (top-right): barrels
    array_push(_L, ["obj_barrel", 16, 2, 0.5]);
    array_push(_L, ["obj_barrel", 17, 2, 0.5]);
    array_push(_L, ["obj_barrel", 17, 3, 0.5]);
    // Zone 6 — STAIRS UP (right wall) → upper floor
    array_push(_L, ["obj_mercato_prop", 17, 8, 1, "spr_inn_stairs"]);
    // Centre DINING — round tables on the rug
    var _tables = [[8, 9], [11, 9], [8, 13], [11, 13], [9.5, 11]];
    for (var _i = 0; _i < array_length(_tables); _i++)
        array_push(_L, ["obj_mercato_prop", _tables[_i][0], _tables[_i][1], 1, "spr_inn_table"]);
    // Directional chairs — 3 of EACH facing (drag into place / Delete extras in debug).
    // Each faces INWARD toward its table: N-side=chair_south · S-side=chair_north ·
    // W-side=chair_east · E-side=chair_west. (Chairs don't rotate — distinct sprites.)
    var _seat = [[8, 9], [11, 9], [8, 13], [11, 13]];   // four seated tables → 16 chairs (4 of each)
    for (var _s = 0; _s < array_length(_seat); _s++) {
        var _sx = _seat[_s][0], _sy = _seat[_s][1];
        array_push(_L, ["obj_mercato_prop", _sx,     _sy - 1, 0.8, "spr_inn_chair_south"]);  // north seat
        array_push(_L, ["obj_mercato_prop", _sx,     _sy + 1, 0.8, "spr_inn_chair_north"]);  // south seat
        array_push(_L, ["obj_mercato_prop", _sx - 1, _sy,     0.8, "spr_inn_chair_east"]);   // west seat
        array_push(_L, ["obj_mercato_prop", _sx + 1, _sy,     0.8, "spr_inn_chair_west"]);   // east seat
    }
    // One candle centred on each dining table — snuffs out ONE BY ONE at 50%+ corruption.
    for (var _cd = 0; _cd < array_length(_tables); _cd++)
        array_push(_L, ["obj_inn_candle", _tables[_cd][0] + 0.25, _tables[_cd][1] + 0.25, 0.5]);
    // Zone 1 — ENTRANCE: two candelabra flanking the south doorway
    array_push(_L, ["obj_duomo_candelabra", 8,  18, 0.6]);
    array_push(_L, ["obj_duomo_candelabra", 12, 18, 0.6]);
    // Zone 3 — INNKEEPER behind the counter (WEST end; proximity rest menu)
    array_push(_L, ["obj_npc_innkeeper", 4, 1, 1]);
    // Rosa the barmaid — EAST end of the counter nook (proximity dialogue + mood icon)
    array_push(_L, ["obj_npc_rosa", 6, 1, 1]);
    return _L;
}

// ── Build (called from obj_inn_scene Create) ─────────────────────────────────────
function scr_inn_build() {
    if (room != Room_fiorentine_inn) return 0;

    // keep-alive: name-placed sprites + objects are invisible to the asset stripper.
    global.__inn_keep     = [obj_mercato_prop, obj_duomo_candelabra, obj_barrel, obj_npc_innkeeper, obj_npc_rosa, obj_inn_candle];
    global.__inn_keep_spr = [spr_inn_counter, spr_inn_table,
        spr_inn_chair_south, spr_inn_chair_north, spr_inn_chair_east, spr_inn_chair_west,
        spr_inn_fireplace, spr_inn_bed, spr_inn_stairs, spr_npc_innkeeper, spr_npc_rosa,
        spr_inn_candle, spr_inn_candle_lit, spr_inn_candle_unlit];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_fiorentine_inn_layout.txt";
    var _placed = file_exists(_path) ? scr_inn_load(_path) : 0;
    if (_placed == 0) scr_inn_default_place();

    scr_inn_build_collision();
    return array_length(global.room_builder_objects);
}

function scr_inn_default_place() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _L = scr_inn_default_layout();
    for (var _i = 0; _i < array_length(_L); _i++) {
        var _e   = _L[_i];
        var _spr = (array_length(_e) >= 5) ? _e[4] : "";
        scr_inn_place(_e[0], _e[1], _e[2], _e[3], _spr, _layer);
    }
}

/// Place one inn prop (+ register it as a draggable builder object).
function scr_inn_place(_objname, _gx, _gy, _sc, _sprn, _layer) {
    var _obj = asset_get_index(_objname);
    if (_obj < 0 || asset_get_type(_objname) != asset_object) {
        show_debug_message("[inn] object not found -> " + string(_objname));
        return noone;
    }
    var _px = _gx * INN_GRID_PX, _py = _gy * INN_GRID_PX;
    var _inst = (_layer != "")
        ? instance_create_layer(_px, _py, _layer, _obj)
        : instance_create_depth(_px, _py, 100, _obj);
    _inst.image_xscale = _sc;
    _inst.image_yscale = _sc;
    _inst.room_builder_placed = true;
    _inst.builder_sprite = "";
    _inst.builder_solid  = false;
    _inst.builder_angle  = 0;
    if (_sprn != "") {
        var _sid = asset_get_index(_sprn);
        if (_sid >= 0 && asset_get_type(_sprn) == asset_sprite) {
            _inst.sprite_index   = _sid;
            _inst.builder_sprite = _sprn;
        }
    }
    // furniture is solid — EXCEPT the stairs (you walk onto it to trigger going up)
    if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = (_sprn != "spr_inn_stairs");
    array_push(global.room_builder_objects, _inst);
    return _inst;
}

/// Read a saved inn layout (OBJECT GX GY SCALE [SPRITE] [solid] [ANGLE]) and place it.
function scr_inn_load(_path) {
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
        if (array_length(_t) >= 5) {
            var _cand = _t[4];
            if (asset_get_index(_cand) >= 0 && asset_get_type(_cand) == asset_sprite) _spr = _cand;
        }
        var _ang  = 0;
        var _last = _t[array_length(_t) - 1];
        if (array_length(_t) >= 5 && string_digits(_last) == _last && _last != "") _ang = real(_last);
        var _inst = scr_inn_place(_t[0], real(_t[1]), real(_t[2]), _sc, _spr, _layer);
        if (_inst != noone) { _inst.builder_angle = _ang; _n++; }
    }
    file_text_close(_f);
    return _n;
}

/// Collision: the void-ring walls + each solid prop's tight footprint.
function scr_inn_build_collision() {
    for (var _cy = 0; _cy < INN_H_CELLS; _cy++)
        for (var _cx = 0; _cx < INN_W_CELLS; _cx++) {
            if (!scr_inn_is_wall(_cx, _cy)) continue;
            var _w = instance_create_depth(_cx * INN_GRID_PX, _cy * INN_GRID_PX, 500, obj_wall);
            _w.wall_w  = INN_GRID_PX;
            _w.wall_h  = INN_GRID_PX;
            _w.visible = false;
        }
    // Seal the innkeeper nook behind the counter so the player can't walk around it.
    var _nwA = instance_create_depth(1 * 64, 2 * 64, 500, obj_wall);   // west gap (cols 1-2, row 2)
    _nwA.wall_w = 2 * 64; _nwA.wall_h = 64; _nwA.visible = false;
    var _nwB = instance_create_depth(7 * 64, 1 * 64, 500, obj_wall);   // east side (col 7, rows 1-2)
    _nwB.wall_w = 64; _nwB.wall_h = 2 * 64; _nwB.visible = false;

    scr_room_builder_build_collision();   // tight per-prop footprints (mercato_prop etc.)
}

/// Rebuild inn collision from current prop positions (debug: after drag/nudge/delete).
function scr_inn_rebuild_collision() {
    if (room != Room_fiorentine_inn) return;
    with (obj_wall) instance_destroy();
    scr_inn_build_collision();
}
