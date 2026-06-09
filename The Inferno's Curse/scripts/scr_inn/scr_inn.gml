// =============================================================================
// scr_inn — Room_locanda_rosa_camuna (ground floor) — BLACK-VOID rectangular interior
// =============================================================================
// 16 x 17 cells (1024 x 1088) — maps references/inn_interior_map.png 1F 1:1 (one
// reference tile = one 64px cell; interior 14x15). Walkable floor is an inset
// rectangle; the 1-cell black-void border is the walls. A 2-cell gap in the SOUTH
// wall (cols 7-8) is the entrance doorway. Props (obj_mercato_prop carrying a
// sprite, draggable like the market/bridge) lay out the reference zones: kitchen
// across the TOP wall, bar counter below it (modular run + corner, stools), storage
// top-right, 2x4 staircase on the right wall, dining tables scattered on the rug.
// INTERIOR room → black-void method (see CLAUDE.md). FF6 camera in the room.
// =============================================================================

#macro INN_W_CELLS 16
#macro INN_H_CELLS 17
#macro INN_GRID_PX 64

// South doorway centre — the entry gap + the return-to-Florence trigger.
#macro INN_EXIT_X 512
#macro INN_EXIT_Y 1056   // row 16.5

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
    var _main  = (_cx >= 1 && _cx <= 14 && _cy >= 1 && _cy <= 15);
    var _entry = (_cy == 16 && _cx >= 7 && _cx <= 8);   // south doorway gap
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
    return (_cx >= 3 && _cx <= 10 && _cy >= 9 && _cy <= 13);
}

// ── Default prop layout — [object, gx, gy, scale, (sprite)] ───────────────────────
// obj_mercato_prop carries the sprite + collision (solid), so every furniture piece
// is click-drag / nudge / rotate / Delete / F8 like the market & bridge props.
function scr_inn_default_layout() {
    var _L = [];
    // Zone 4 — KITCHEN across the TOP wall (per the reference): hearth recessed
    // top-centre, bread oven beside it, prep table below. The oven is placed LIT;
    // scr_inn_oven_sync swaps it cold/corrupt at 50%+ Limbo corruption.
    array_push(_L, ["obj_mercato_prop", 5.5, 1, 1.2, "spr_inn_fireplace"]);
    array_push(_L, ["obj_mercato_prop", 4.3, 1, 1.0, "spr_inn_oven_lit", "solid"]);
    array_push(_L, ["obj_mercato_prop", 2,   2, 0.9, "spr_inn_table"]);
    // Zone 2 — TAVERN / BAR: ONE-PIECE SQUARE bar (spr_inn_bar_counter, PixelLab,
    // 384x192 — a closed rectangular counter ring per the user's design: centre
    // front + connecting sides forming a square, placed FLUSH against the drawn
    // kitchen wall so the ring's back side reads as the back-bar along it). The
    // bartenders stand INSIDE the ring; its manual bbox (the ring's art bounds)
    // is the collision, so patrons are walled out by the counter itself.
    // FLUSH against the wall: at gy 4.0 the ring's back side (sprite art top = 22px
    // in) lands at world y 278, ON the drawn wall band (256-320) — the wall peeks
    // out above the back counter and no floor shows between them.
    array_push(_L, ["obj_mercato_prop", 1.8, 4.0, 1, "spr_inn_bar_counter"]);
    array_push(_L, ["obj_inn_candle",   4.6, 6.0, 0.5]);   // a candle on the bar front
    // Bar stools hugging the front face + one at the east arm
    var _stools = [2.9, 4.0, 5.1, 6.2];
    for (var _st = 0; _st < array_length(_stools); _st++)
        array_push(_L, ["obj_mercato_prop", _stools[_st], 6.9, 0.5, "spr_inn_stool"]);
    array_push(_L, ["obj_mercato_prop", 7.3, 5.4, 0.5, "spr_inn_stool"]);
    // West-side clutter in the 1-cell gap between the bar ring and the west wall
    array_push(_L, ["obj_barrel", 1, 5.2, 0.5]);
    // Zone 3 — Aldo the innkeeper (lodging, WEST end) + Rosa (bar menu, EAST end),
    // both inside the ring's interior opening (world x ~182-423, y ~328-383)
    array_push(_L, ["obj_npc_innkeeper", 3.2, 5.1, 1]);
    array_push(_L, ["obj_npc_rosa",      5.4, 5.1, 1]);
    // Wine shelf moved into the KITCHEN (food prep + wine storage per reference)
    array_push(_L, ["obj_mercato_prop", 1, 1, 0.8, "spr_inn_wine_shelf"]);
    // Zone 5 — STORAGE / PANTRY (top-right): barrels + kegs
    array_push(_L, ["obj_barrel", 11.5, 1.5, 0.5]);
    array_push(_L, ["obj_barrel", 12.5, 1.5, 0.5]);
    array_push(_L, ["obj_barrel", 12.5, 2.5, 0.5]);
    array_push(_L, ["obj_mercato_prop", 13.3, 1.3, 0.7, "spr_inn_keg_group"]);
    // Zone 6 — STAIRS UP: 2x4-cell staircase on the right wall (x13-14, y5-8),
    // non-solid — the player walks onto the bottom landing to trigger going up.
    array_push(_L, ["obj_mercato_prop", 13, 5, 1, "spr_inn_staircase"]);
    // Hearths — LEFT-wall fireplace per the reference + the right-wall focal fire
    array_push(_L, ["obj_mercato_prop", 1,    12, 1, "spr_inn_fireplace"]);
    array_push(_L, ["obj_mercato_prop", 13.5, 11, 1, "spr_inn_fireplace"]);
    // Centre DINING — the reference scatter: 3 tables on the rug + 2 off-rug east.
    // Spacing 2-3.6 cells centre-to-centre (snug, not a grid).
    var _tables = [[4, 10], [7.5, 11.5], [6, 13], [11.5, 10], [11.5, 13]];
    for (var _i = 0; _i < array_length(_tables); _i++)
        array_push(_L, ["obj_mercato_prop", _tables[_i][0], _tables[_i][1], 1, "spr_inn_table"]);
    // Directional chairs HUG their tables (0.7 scale at 0.75-cell offset — the
    // reference stools touch the table edge). Each faces INWARD: N-side=chair_south ·
    // S-side=chair_north · W-side=chair_east · E-side=chair_west. Centre table is
    // unseated. (Chairs don't rotate — distinct sprites.)
    var _seat = [[4, 10], [6, 13], [11.5, 10], [11.5, 13]];
    for (var _s = 0; _s < array_length(_seat); _s++) {
        var _sx = _seat[_s][0], _sy = _seat[_s][1];
        array_push(_L, ["obj_mercato_prop", _sx + 0.15, _sy - 0.75, 0.7, "spr_inn_chair_south"]);  // north seat
        array_push(_L, ["obj_mercato_prop", _sx + 0.15, _sy + 1.05, 0.7, "spr_inn_chair_north"]);  // south seat
        array_push(_L, ["obj_mercato_prop", _sx - 0.75, _sy + 0.15, 0.7, "spr_inn_chair_east"]);   // west seat
        array_push(_L, ["obj_mercato_prop", _sx + 1.05, _sy + 0.15, 0.7, "spr_inn_chair_west"]);   // east seat
    }
    // One candle centred on each dining table — snuffs out ONE BY ONE at 50%+ corruption.
    for (var _cd = 0; _cd < array_length(_tables); _cd++)
        array_push(_L, ["obj_inn_candle", _tables[_cd][0] + 0.25, _tables[_cd][1] + 0.25, 0.5]);
    // Zone 1 — ENTRANCE: two candelabra flanking the south doorway (cols 7-8)
    array_push(_L, ["obj_duomo_candelabra", 5.8, 14.5, 0.6]);
    array_push(_L, ["obj_duomo_candelabra", 9.4, 14.5, 0.6]);
    return _L;
}

// ── Build (called from obj_inn_scene Create) ─────────────────────────────────────
function scr_inn_build() {
    if (room != Room_locanda_rosa_camuna) return 0;

    // keep-alive: name-placed sprites + objects are invisible to the asset stripper.
    global.__inn_keep     = [obj_mercato_prop, obj_duomo_candelabra, obj_barrel, obj_npc_innkeeper, obj_npc_rosa, obj_inn_candle];
    global.__inn_keep_spr = [spr_inn_counter_corner, spr_inn_counter_empty, spr_inn_counter_food, spr_inn_keg_group, spr_inn_wine_shelf, spr_inn_table,
        spr_inn_stool, spr_inn_staircase, spr_inn_bar_counter,
        spr_inn_chair_south, spr_inn_chair_north, spr_inn_chair_east, spr_inn_chair_west,
        spr_inn_fireplace, spr_inn_oven, spr_inn_oven_lit, spr_inn_oven_corrupt, spr_inn_oven_green, spr_inn_bed, spr_inn_stairs, spr_npc_innkeeper, spr_npc_rosa,
        spr_inn_candle, spr_inn_candle_lit, spr_inn_candle_unlit, spr_inn_candle_green];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_locanda_rosa_camuna_layout.txt";
    // Stale-layout guard: only load an F8-saved copy stamped with the CURRENT
    // INN_LAYOUT_VERSION; otherwise the code default below takes over.
    var _placed = scr_room_builder_layout_current(_path) ? scr_inn_load(_path) : 0;
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
        var _inst = scr_inn_place(_e[0], _e[1], _e[2], _e[3], _spr, _layer);
        // optional trailing ANGLE (deg CW, drawn via the centre-pivot rotation
        // helper) — non-numeric extras like the oven's "solid" flag are skipped
        if (_inst != noone && array_length(_e) >= 6 && is_real(_e[5]))
            _inst.builder_angle = _e[5];
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
    // furniture is solid — EXCEPT the stairs/staircase (you walk onto it to trigger going up)
    if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = (string_pos("spr_inn_stair", _sprn) != 1);
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
    // Kitchen/bar divider wall (row 4, cols 1-9) — DRAWN stable-style in
    // obj_inn_scene Draw (black void band + plank tile); this is its collision.
    // The kitchen stays reachable around the east end via col 10. The bar needs
    // no other seals: the one-piece square counter ring (its manual bbox = the
    // ring's art bounds) sits flush under this wall and walls the workspace off
    // by itself — Aldo and Rosa stand inside the ring.
    var _nwA = instance_create_depth(1 * 64, 4 * 64, 500, obj_wall);   // kitchen/bar divider
    _nwA.wall_w = 9 * 64; _nwA.wall_h = 64; _nwA.visible = false;

    scr_room_builder_build_collision();   // tight per-prop footprints (mercato_prop etc.)
}

/// Corruption-reactive bread oven (mirrors the candle pattern). Below 50% Limbo
/// corruption the oven burns warm + animated (spr_inn_oven_lit, 9-frame flame loop);
/// at 50%+ it goes cold and black-tiled (spr_inn_oven_corrupt). Called every frame from
/// obj_inn_scene Draw. Matches any oven prop (builder_sprite begins "spr_inn_oven",
/// covering the lit/corrupt sprites AND a legacy spr_inn_oven from an older saved layout).
/// Only reassigns sprite_index when it actually changes — assigning it every frame would
/// reset image_index to 0 and freeze the flame animation.
function scr_inn_oven_sync() {
    if (room != Room_locanda_rosa_camuna) return;
    if (!variable_global_exists("room_builder_objects")) return;
    // Warm lit (<50) -> cold black, no flame (50-99) -> eerie GREEN relight at full
    // corruption (100). The green oven is the same 9-frame animation recoloured.
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    var _spr;
    if      (_corr >= 100) _spr = spr_inn_oven_green;
    else if (_corr >= 50)  _spr = spr_inn_oven_corrupt;
    else                   _spr = spr_inn_oven_lit;
    var _objs = global.room_builder_objects;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        if (string_pos("spr_inn_oven", _o.builder_sprite) == 1 && _o.sprite_index != _spr) {
            _o.sprite_index = _spr;
        }
    }
}

/// Rebuild inn collision from current prop positions (debug: after drag/nudge/delete).
function scr_inn_rebuild_collision() {
    if (room != Room_locanda_rosa_camuna) return;
    with (obj_wall) instance_destroy();
    scr_inn_build_collision();
}
