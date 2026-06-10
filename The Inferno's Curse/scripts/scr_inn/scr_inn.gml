// =============================================================================
// scr_inn — Room_locanda_rosa_camuna (ground floor) — BLACK-VOID rectangular interior
// =============================================================================
// 16 x 14 cells (1024 x 896) — CONDENSED packed-tavern cut (interior 14x12).
// Walkable floor is an inset rectangle; the 1-cell black-void border is the
// walls. A 2-cell gap in the SOUTH wall (cols 7-8) is the entrance doorway.
// Props (obj_mercato_prop carrying a sprite, draggable like the market/bridge):
// the one-piece bar ring backed against the room's own TOP wall, kitchen line
// east of it on the same wall, storage top-right, 2x4 staircase right wall,
// long communal table mid-floor, round tables on the rug, time-of-day-reactive
// windows on the side walls (scr_inn_window_glow). INTERIOR room → black-void
// method (see CLAUDE.md). FF6 camera in the room.
// =============================================================================

#macro INN_W_CELLS 16
#macro INN_H_CELLS 14
#macro INN_GRID_PX 64

// South doorway centre — the entry gap + the return-to-Florence trigger.
#macro INN_EXIT_X 512
#macro INN_EXIT_Y 864    // row 13.5

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
    var _main  = (_cx >= 1 && _cx <= 14 && _cy >= 1 && _cy <= 12);
    var _entry = (_cy == 13 && _cx >= 7 && _cx <= 8);   // south doorway gap
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

/// Red/brown dining rug — centre of the common room (drawn in obj_inn_scene Draw),
/// plus a small side rug bottom-right (code-only, per the reference).
function scr_inn_is_rug(_cx, _cy) {
    if (_cx >= 3 && _cx <= 10 && _cy >= 7 && _cy <= 10) return true;    // main rug
    if (_cx >= 12 && _cx <= 13 && _cy >= 11 && _cy <= 12) return true;  // side rug
    return false;
}

// ── Default prop layout — [object, gx, gy, scale, (sprite)] ───────────────────────
// obj_mercato_prop carries the sprite + collision (solid), so every furniture piece
// is click-drag / nudge / rotate / Delete / F8 like the market & bridge props.
function scr_inn_default_layout() {
    var _L = [];
    // Zone 2 — TAVERN / BAR backed against the room's OWN back wall (no divider
    // walls — the counter touches the existing kitchen wall): the one-piece
    // square counter ring (spr_inn_bar_counter, art top is 22px into the canvas)
    // at gy 0.65 puts its back counter at world y ~64 = the interior's top edge,
    // flush under the black void wall. Bartenders stand INSIDE the ring; its
    // manual bbox (the ring's art bounds) walls patrons out by itself.
    array_push(_L, ["obj_mercato_prop", 1.8, 0.65, 1, "spr_inn_bar_counter"]);
    array_push(_L, ["obj_inn_candle",   4.6, 2.7, 0.5]);   // a candle on the bar front
    // Bar stools hugging the front face + one at the east arm
    var _stools = [2.9, 4.0, 5.1, 6.2];
    for (var _st = 0; _st < array_length(_stools); _st++)
        array_push(_L, ["obj_mercato_prop", _stools[_st], 3.6, 0.5, "spr_inn_stool"]);
    array_push(_L, ["obj_mercato_prop", 7.3, 2.0, 0.5, "spr_inn_stool"]);
    // Zone 3 — Aldo the innkeeper (lodging, WEST end) + Rosa (bar menu, EAST end),
    // both inside the ring's interior opening (world x ~182-423, y ~114-169)
    array_push(_L, ["obj_npc_innkeeper", 3.2, 1.75, 1]);
    array_push(_L, ["obj_npc_rosa",      5.4, 1.75, 1]);
    // Zone 4 — KITCHEN on the same back wall, EAST of the bar (wine shelf stays
    // top-left of the bar; oven + hearth slide east toward storage; prep table
    // below them). The oven is placed LIT; scr_inn_oven_sync swaps it cold/corrupt
    // at 50%+ Limbo corruption.
    array_push(_L, ["obj_mercato_prop", 1,    1, 0.8, "spr_inn_wine_shelf"]);
    array_push(_L, ["obj_mercato_prop", 9,    1, 1.0, "spr_inn_oven_lit", "solid"]);
    array_push(_L, ["obj_mercato_prop", 10.3, 1, 1.2, "spr_inn_fireplace"]);
    array_push(_L, ["obj_mercato_prop", 8.2,  2, 0.9, "spr_inn_table"]);
    // West-side clutter in the gap between the bar ring and the west wall
    array_push(_L, ["obj_barrel", 1, 2.2, 0.5]);
    // Zone 5 — STORAGE / PANTRY (top-right): barrels + kegs + clay pots between
    // the oven line and the storage corner (urns at 0.4 per the prop-scale rules)
    array_push(_L, ["obj_barrel", 11.5, 1.5, 0.5]);
    array_push(_L, ["obj_barrel", 12.5, 1.5, 0.5]);
    array_push(_L, ["obj_barrel", 12.5, 2.5, 0.5]);
    array_push(_L, ["obj_mercato_prop", 13.3, 1.3, 0.7, "spr_inn_keg_group"]);
    array_push(_L, ["obj_mercato_prop", 9.9,  2.1, 0.4, "spr_clay_pot_large"]);
    array_push(_L, ["obj_mercato_prop", 11.1, 2.2, 0.4, "spr_clay_pot_large"]);
    // Zone 6 — STAIRS UP: 2x4-cell staircase on the right wall (x13-14, y4-7),
    // non-solid — the player walks onto the bottom landing to trigger going up.
    array_push(_L, ["obj_mercato_prop", 13, 4, 1, "spr_inn_staircase"]);
    array_push(_L, ["obj_mercato_prop", 12.3, 4.3, 1, "spr_inn_plant"]);   // plant by the stairs
    // Cellar corner under the stairs: kegs + barrels
    array_push(_L, ["obj_mercato_prop", 12.6, 9, 0.7, "spr_inn_keg_group"]);
    array_push(_L, ["obj_barrel", 13.6, 9.2, 0.5]);
    array_push(_L, ["obj_barrel", 12.7, 10,  0.5]);
    // Hearths — LEFT-wall fireplace per the reference + the right-wall focal fire
    array_push(_L, ["obj_mercato_prop", 1,    9.5, 1, "spr_inn_fireplace"]);
    array_push(_L, ["obj_mercato_prop", 13.5, 11,  1, "spr_inn_fireplace"]);
    // West-wall service strip: delivery barrels + crates
    array_push(_L, ["obj_barrel", 1,   4.6, 0.5]);
    array_push(_L, ["obj_barrel", 1.1, 5.6, 0.5]);
    array_push(_L, ["obj_mercato_prop", 1, 7.2, 0.5, "spr_crate_stack"]);
    // LONG COMMUNAL TABLE — the centerpiece, mid-floor between bar and rug.
    // The PixelLab sprite has bench seating BAKED IN both sides, so no chair
    // props here — just the two candles on the tabletop.
    array_push(_L, ["obj_mercato_prop", 5.5, 4.8, 1, "spr_inn_table_long"]);
    array_push(_L, ["obj_inn_candle", 5.9, 4.95, 0.5]);
    array_push(_L, ["obj_inn_candle", 6.9, 4.95, 0.5]);
    array_push(_L, ["obj_mercato_prop", 6.3, 5.1, 0.75, "spr_inn_mugs"]);   // ale on the long table
    // Loose stools near the bar (the drunks' corner)
    array_push(_L, ["obj_mercato_prop", 8.5, 3.8, 0.5, "spr_inn_stool"]);
    array_push(_L, ["obj_mercato_prop", 2.2, 4.4, 0.5, "spr_inn_stool"]);
    // Centre DINING — 5 seated round tables: 3 on the rug + 2 off-rug east.
    var _tables = [[3.5, 7.5], [6.5, 7.5], [5, 9.5], [11.5, 7], [11.5, 9.8]];
    for (var _i = 0; _i < array_length(_tables); _i++)
        array_push(_L, ["obj_mercato_prop", _tables[_i][0], _tables[_i][1], 1, "spr_inn_table"]);
    // Directional chairs HUG their tables (0.7 scale at 0.75-cell offset). Each
    // faces INWARD: N-side=chair_south · S-side=chair_north · W-side=chair_east ·
    // E-side=chair_west. (Chairs don't rotate — distinct sprites.)
    for (var _s = 0; _s < array_length(_tables); _s++) {
        var _sx = _tables[_s][0], _sy = _tables[_s][1];
        array_push(_L, ["obj_mercato_prop", _sx + 0.15, _sy - 0.75, 0.7, "spr_inn_chair_south"]);  // north seat
        array_push(_L, ["obj_mercato_prop", _sx + 0.15, _sy + 1.05, 0.7, "spr_inn_chair_north"]);  // south seat
        array_push(_L, ["obj_mercato_prop", _sx - 0.75, _sy + 0.15, 0.7, "spr_inn_chair_east"]);   // west seat
        array_push(_L, ["obj_mercato_prop", _sx + 1.05, _sy + 0.15, 0.7, "spr_inn_chair_west"]);   // east seat
    }
    // One candle centred on each dining table — snuffs out ONE BY ONE at 50%+ corruption.
    for (var _cd = 0; _cd < array_length(_tables); _cd++)
        array_push(_L, ["obj_inn_candle", _tables[_cd][0] + 0.25, _tables[_cd][1] + 0.25, 0.5]);
    // Half-drunk ale on a couple of the round tables (lived-in, not staged)
    array_push(_L, ["obj_mercato_prop", 6.95,  8.0,  0.75, "spr_inn_mugs"]);
    array_push(_L, ["obj_mercato_prop", 11.95, 10.3, 0.75, "spr_inn_mugs"]);
    // Bottom-left barrels (mirrors the reference corner clutter)
    array_push(_L, ["obj_barrel", 1,   10.8, 0.5]);
    array_push(_L, ["obj_barrel", 1.9, 11.4, 0.5]);
    array_push(_L, ["obj_barrel", 1.2, 12.1, 0.5]);
    // WINDOWS — set into the void side walls; time-of-day light pools drawn by
    // scr_inn_window_glow (and the light LIES at full corruption)
    array_push(_L, ["obj_mercato_prop", 0.1,  4.5, 1, "spr_inn_window"]);
    array_push(_L, ["obj_mercato_prop", 0.1,  9,   1, "spr_inn_window"]);
    array_push(_L, ["obj_mercato_prop", 14.9, 6.5, 1, "spr_inn_window"]);
    // WALL DRESSING on the void walls: banner over the bar's back counter, banner
    // by the door, hanging meats over the kitchen oven
    array_push(_L, ["obj_mercato_prop", 4.5, 0.1, 1, "spr_inn_banner"]);
    array_push(_L, ["obj_mercato_prop", 9.6, 12.3, 1, "spr_inn_banner"]);
    array_push(_L, ["obj_mercato_prop", 8.9, 0.1, 1, "spr_inn_meats"]);
    // Zone 1 — ENTRANCE: candelabra + potted flowers flanking the south doorway
    array_push(_L, ["obj_duomo_candelabra", 5.8, 11.5, 0.6]);
    array_push(_L, ["obj_duomo_candelabra", 9.4, 11.5, 0.6]);
    array_push(_L, ["obj_mercato_prop", 6.3, 12.2, 1, "spr_inn_plant"]);
    array_push(_L, ["obj_mercato_prop", 8.6, 12.2, 1, "spr_inn_plant"]);
    return _L;
}

// ── Build (called from obj_inn_scene Create) ─────────────────────────────────────
function scr_inn_build() {
    if (room != Room_locanda_rosa_camuna) return 0;

    // keep-alive: name-placed sprites + objects are invisible to the asset stripper.
    global.__inn_keep     = [obj_mercato_prop, obj_duomo_candelabra, obj_barrel, obj_npc_innkeeper, obj_npc_rosa, obj_inn_candle];
    global.__inn_keep_spr = [spr_inn_counter_corner, spr_inn_counter_empty, spr_inn_counter_food, spr_inn_keg_group, spr_inn_wine_shelf, spr_inn_table,
        spr_inn_stool, spr_inn_staircase, spr_inn_bar_counter,
        spr_inn_plant, spr_inn_banner, spr_inn_meats, spr_inn_table_long, spr_inn_floor, spr_inn_rug, spr_inn_mugs,
        spr_inn_window, spr_inn_window_open, spr_inn_window_dawn, spr_inn_window_dusk, spr_inn_window_night,
        spr_clay_pot_large, spr_crate_stack,
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
    // No interior seal walls needed: the bar is backed against the room's own
    // void back wall and the counter ring's solid bbox closes the workspace.
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

/// Time-of-day light through the WINDOWS (called from obj_inn_scene Draw, after
/// the floor): a light pool spills inward from each spr_inn_window prop.
///   Dawn 05-07  warm orange   ·  Day 08-17   bright white daylight
///   Dusk 18-20  amber gold    ·  Night 21-04 faint cool moon glow
/// At FULL corruption (100) the light LIES: dawn shows moonlight, day shows
/// darkness, dusk goes dark too, night blazes with harsh noon sun — and the
/// chronicle notes it ONCE, the first time Benedetto sees it.
function scr_inn_window_glow() {
    if (room != Room_locanda_rosa_camuna) return;
    if (!variable_global_exists("room_builder_objects")) return;
    var _hour = variable_global_exists("game_hour") ? global.game_hour : 12;
    var _corrupted = (global.circle_corruption[CIRCLE_LIMBO] >= 100);
    // phase: 0 dawn · 1 day · 2 dusk · 3 night · 4 unnatural dark · 5 harsh noon
    var _phase;
    if      (_hour >= 5  && _hour <= 7)  _phase = 0;
    else if (_hour >= 8  && _hour <= 17) _phase = 1;
    else if (_hour >= 18 && _hour <= 20) _phase = 2;
    else                                 _phase = 3;
    if (_corrupted) {
        if      (_phase == 0) _phase = 3;   // dawn -> moonlight
        else if (_phase == 3) _phase = 5;   // night -> harsh noon sun
        else                  _phase = 4;   // day/dusk -> darkness
        if (!variable_global_exists("inn_window_wrong_noted")) {
            global.inn_window_wrong_noted = true;
            scr_chronicle_add("The light through the window is wrong. It has been wrong for some time.");
        }
    }
    var _col, _a, _r;
    switch (_phase) {
        case 0:  _col = make_color_rgb(255, 160, 80);  _a = 0.30; _r = 60; break;
        case 1:  _col = make_color_rgb(255, 250, 230); _a = 0.34; _r = 72; break;
        case 2:  _col = make_color_rgb(255, 196, 90);  _a = 0.30; _r = 60; break;
        case 3:  _col = make_color_rgb(140, 170, 230); _a = 0.16; _r = 44; break;
        case 4:  _a = 0; _r = 0; _col = c_black;                           break;
        default: _col = make_color_rgb(255, 255, 235); _a = 0.55; _r = 96; break;
    }
    // WINDOW STAGE SYNC — ONE dedicated sprite per stage of the day, and the
    // LYING light at full corruption picks its stage the same way (the shutters
    // swing open under the false noon sun at midnight). Swaps sprite_index only
    // (builder_sprite identity stays "spr_inn_window" for F8), mirroring the
    // oven sync pattern.
    //   dawn -> _dawn · day/harsh-noon -> _open · dusk -> _dusk ·
    //   moon-night -> _night · unnatural dark -> base closed (dead slats)
    var _wspr;
    switch (_phase) {
        case 0:  _wspr = spr_inn_window_dawn;  break;
        case 1:  _wspr = spr_inn_window_open;  break;
        case 2:  _wspr = spr_inn_window_dusk;  break;
        case 3:  _wspr = spr_inn_window_night; break;
        case 4:  _wspr = spr_inn_window;       break;
        default: _wspr = spr_inn_window_open;  break;
    }
    var _objs = global.room_builder_objects;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        if (_o.builder_sprite != "spr_inn_window") continue;
        if (_o.sprite_index != _wspr) _o.sprite_index = _wspr;
    }
    if (_a <= 0) return;   // unnatural dark: the windows give NOTHING
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        if (_o.builder_sprite != "spr_inn_window") continue;
        var _wx = _o.x + 32 * _o.image_xscale;
        var _wy = _o.y + 32 * _o.image_yscale;
        // pool spills INWARD from whichever side wall the window sits on
        var _ix = (_o.x < room_width * 0.5) ? _wx + _r * 0.7 : _wx - _r * 0.7;
        draw_set_alpha(_a);
        draw_circle(_ix, _wy, _r, false);
        draw_set_alpha(_a * 0.45);
        draw_circle(_ix, _wy, _r * 1.6, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
