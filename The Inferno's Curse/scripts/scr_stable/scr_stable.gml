// =============================================================================
// scr_stable — Room_fiorentine_stable — BLACK-VOID rectangular interior
// =============================================================================
// 14 x 22 cells (896 x 1408). Walkable floor is an inset rectangle; the 1-cell
// black-void border is the walls. A 2-cell gap in the SOUTH wall (cols 6-7) is the
// entrance doorway. Props (obj_mercato_prop carrying a sprite, draggable like the
// market/inn) lay out the reference zones (references/stables_interior_map.png):
// hay storage (top-left), water trough (top-centre), tack room (top-right), six
// horse stalls flanking a central aisle, sleeping area (bottom-right, reputation-
// gated via obj_stable_rest), Pietro the stable boy in the centre aisle.
// INTERIOR room → black-void method (see CLAUDE.md). FF6 camera in the room.
// =============================================================================

#macro STABLE_W_CELLS 14
#macro STABLE_H_CELLS 22
#macro STABLE_GRID_PX 64

// South doorway centre — the entry gap + the return-to-Florence trigger.
#macro STABLE_EXIT_X 448
#macro STABLE_EXIT_Y 1376   // row 21.5

// TEMP: boot straight into the stable for testing (takes precedence over the inn
// and Duomo load points in obj_game_manager Create). Flip to false to restore the
// normal Florence start.
#macro STABLE_LOAD_POINT true

// ── Cell predicates ─────────────────────────────────────────────────────────────
function scr_stable_is_interior(_cx, _cy) {
    var _main  = (_cx >= 1 && _cx <= 12 && _cy >= 1 && _cy <= 20);
    var _entry = (_cy == 21 && _cx >= 6 && _cx <= 7);   // south doorway gap
    return _main || _entry;
}

/// Void cell touching interior (8-neighbour) — invisible obj_wall collision ring.
function scr_stable_is_wall(_cx, _cy) {
    if (_cx < 0 || _cx >= STABLE_W_CELLS || _cy < 0 || _cy >= STABLE_H_CELLS) return false;
    if (scr_stable_is_interior(_cx, _cy)) return false;
    for (var _dx = -1; _dx <= 1; _dx++)
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (_dx == 0 && _dy == 0) continue;
            if (scr_stable_is_interior(_cx + _dx, _cy + _dy)) return true;
        }
    return false;
}

/// Interior cell touching void (4-neighbour) — drawn as a darker BORDER tile.
function scr_stable_is_border(_cx, _cy) {
    if (!scr_stable_is_interior(_cx, _cy)) return false;
    return (!scr_stable_is_interior(_cx - 1, _cy) || !scr_stable_is_interior(_cx + 1, _cy)
         || !scr_stable_is_interior(_cx, _cy - 1) || !scr_stable_is_interior(_cx, _cy + 1));
}

// ── Default prop layout — [object, gx, gy, scale, (sprite)] ───────────────────────
// Mirrors references/stables_interior_map.png. obj_mercato_prop carries the sprite +
// collision, so every piece is click-drag / nudge / rotate / Delete / F8-saveable.
function scr_stable_default_layout() {
    var _L = [];
    // Zone 4 — HAY STORAGE (top-left)
    array_push(_L, ["obj_mercato_prop", 1,    1,    1.2, "spr_stable_hay"]);
    array_push(_L, ["obj_mercato_prop", 2.6,  1.4,  0.9, "spr_stable_hay"]);
    array_push(_L, ["obj_mercato_prop", 1.3,  2.6,  0.8, "spr_stable_hay"]);
    // Zone 5 — WATER TROUGH (top-centre, two segments read as one long trough)
    array_push(_L, ["obj_mercato_prop", 5.4,  1,    1.2, "spr_stable_trough"]);
    array_push(_L, ["obj_mercato_prop", 6.9,  1,    1.2, "spr_stable_trough"]);
    // Zone 6 — TACK ROOM (top-right)
    array_push(_L, ["obj_mercato_prop", 10.4, 1,    1.2, "spr_stable_tack"]);
    array_push(_L, ["obj_mercato_prop", 11.8, 1.6,  0.9, "spr_stable_tack"]);
    array_push(_L, ["obj_barrel",       12,   2.8,  0.5]);
    // Zone 3 — SIX HORSE STALLS (3 left + 3 right, fronts open to the centre aisle)
    var _stalls = [
        [1,    4,  "spr_stable_horse_grey"],   [10,   4,  "spr_stable_horse_brown"],
        [1,    8.5,"spr_stable_horse_black"],  [10,   8.5,"spr_stable_horse_grey"],
        [1,    13, "spr_stable_horse_brown"],  [10,   13, "spr_stable_horse_black"],
    ];
    for (var _i = 0; _i < array_length(_stalls); _i++) {
        var _s = _stalls[_i];
        array_push(_L, ["obj_mercato_prop", _s[0],       _s[1],       2.5, "spr_stable_stall"]);
        array_push(_L, ["obj_mercato_prop", _s[0] + 0.5, _s[1] + 0.5, 1.5, _s[2]]);
    }
    // Aisle LANTERNS on the stall posts (warm → cold → green; glow in scene Draw)
    var _lrows = [5, 9, 13, 17];
    for (var _l = 0; _l < array_length(_lrows); _l++) {
        array_push(_L, ["obj_mercato_prop", 4.1, _lrows[_l], 1.0, "spr_stable_lantern"]);
        array_push(_L, ["obj_mercato_prop", 9.4, _lrows[_l], 1.0, "spr_stable_lantern"]);
    }
    // Zone 7 — SLEEPING AREA (bottom-right; rest gate handled by obj_stable_rest)
    array_push(_L, ["obj_mercato_prop", 10.5, 18,   1.3, "spr_stable_sleeping"]);
    array_push(_L, ["obj_mercato_prop", 12,   17.4, 0.8, "spr_stable_hay"]);
    array_push(_L, ["obj_barrel",       12.1, 19.2, 0.5]);
    array_push(_L, ["obj_stable_rest",  10.5, 18,   1]);
    // Bottom-left clutter (barrels per the reference)
    array_push(_L, ["obj_barrel",       1,    18,   0.5]);
    array_push(_L, ["obj_barrel",       2,    18.6, 0.5]);
    array_push(_L, ["obj_barrel",       1.2,  19.6, 0.5]);
    // Zone 2 — PIETRO the stable boy, centre aisle
    array_push(_L, ["obj_npc_stableboy", 6.5, 14.5, 1]);
    return _L;
}

// ── Build (called from obj_stable_scene Create) ──────────────────────────────────
function scr_stable_build() {
    if (room != Room_fiorentine_stable) return 0;

    // keep-alive: name-placed sprites + objects are invisible to the asset stripper.
    global.__stable_keep     = [obj_mercato_prop, obj_barrel, obj_npc_stableboy, obj_stable_rest];
    global.__stable_keep_spr = [spr_stable_floor, spr_stable_stall,
        spr_stable_horse_grey, spr_stable_horse_brown, spr_stable_horse_black,
        spr_stable_hay, spr_stable_trough, spr_stable_tack, spr_stable_sleeping,
        spr_stable_lantern, spr_npc_stableboy];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_fiorentine_stable_layout.txt";
    var _placed = file_exists(_path) ? scr_stable_load(_path) : 0;
    if (_placed == 0) scr_stable_default_place();

    scr_stable_build_collision();
    return array_length(global.room_builder_objects);
}

function scr_stable_default_place() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _L = scr_stable_default_layout();
    for (var _i = 0; _i < array_length(_L); _i++) {
        var _e   = _L[_i];
        var _spr = (array_length(_e) >= 5) ? _e[4] : "";
        scr_stable_place(_e[0], _e[1], _e[2], _e[3], _spr, _layer);
    }
}

/// Place one stable prop (+ register it as a draggable builder object).
function scr_stable_place(_objname, _gx, _gy, _sc, _sprn, _layer) {
    var _obj = asset_get_index(_objname);
    if (_obj < 0 || asset_get_type(_objname) != asset_object) {
        show_debug_message("[stable] object not found -> " + string(_objname));
        return noone;
    }
    var _px = _gx * STABLE_GRID_PX, _py = _gy * STABLE_GRID_PX;
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
    // furniture is solid — EXCEPT lanterns (aisle posts stay walkable past) and the
    // sleeping pallet (the player walks onto it to rest at the obj_stable_rest zone)
    if (_inst.object_index == obj_mercato_prop)
        _inst.builder_solid = (_sprn != "spr_stable_lantern" && _sprn != "spr_stable_sleeping");
    array_push(global.room_builder_objects, _inst);
    return _inst;
}

/// Read a saved stable layout (OBJECT GX GY SCALE [SPRITE] [solid] [ANGLE]) and place it.
function scr_stable_load(_path) {
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
        var _inst = scr_stable_place(_t[0], real(_t[1]), real(_t[2]), _sc, _spr, _layer);
        if (_inst != noone) { _inst.builder_angle = _ang; _n++; }
    }
    file_text_close(_f);
    return _n;
}

/// Collision: the void-ring walls + each solid prop's tight footprint.
function scr_stable_build_collision() {
    for (var _cy = 0; _cy < STABLE_H_CELLS; _cy++)
        for (var _cx = 0; _cx < STABLE_W_CELLS; _cx++) {
            if (!scr_stable_is_wall(_cx, _cy)) continue;
            var _w = instance_create_depth(_cx * STABLE_GRID_PX, _cy * STABLE_GRID_PX, 500, obj_wall);
            _w.wall_w  = STABLE_GRID_PX;
            _w.wall_h  = STABLE_GRID_PX;
            _w.visible = false;
        }
    scr_room_builder_build_collision();   // tight per-prop footprints (mercato_prop etc.)
}

/// Rebuild stable collision from current prop positions (debug: drag/nudge/delete).
function scr_stable_rebuild_collision() {
    if (room != Room_fiorentine_stable) return;
    with (obj_wall) instance_destroy();
    scr_stable_build_collision();
}

/// Horses BACK AWAY from Benedetto at 75%+ Limbo corruption — each horse prop eases
/// 14px deeper into its stall and returns when the taint recedes. Base y is captured
/// on first sync. Called every frame from obj_stable_scene Draw.
function scr_stable_horse_sync() {
    if (room != Room_fiorentine_stable) return;
    if (!variable_global_exists("room_builder_objects")) return;
    var _afraid = (global.circle_corruption[CIRCLE_LIMBO] >= 75);
    var _objs = global.room_builder_objects;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        if (string_pos("spr_stable_horse", _o.builder_sprite) != 1) continue;
        // debug: horses are draggable — adopt the dragged spot as the new base
        if (variable_global_exists("debug_mode") && global.debug_mode) { _o.horse_base_y = _o.y; continue; }
        if (!variable_instance_exists(_o, "horse_base_y")) _o.horse_base_y = _o.y;
        var _target = _o.horse_base_y - (_afraid ? 14 : 0);
        _o.y = lerp(_o.y, _target, 0.06);
    }
}

/// Lantern glow pass (called from obj_stable_scene Draw, AFTER the floor):
///   0-49   warm orange light          50-74  dimmer, uneasy amber
///   75-99  faint cold remnant         100    sickly GREEN
function scr_stable_lantern_glow() {
    if (!variable_global_exists("room_builder_objects")) return;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    var _col, _a, _r;
    if      (_corr >= 100) { _col = make_color_rgb(70, 235, 110);  _a = 0.30; _r = 56; }
    else if (_corr >= 75)  { _col = make_color_rgb(120, 110, 160); _a = 0.10; _r = 34; }
    else if (_corr >= 50)  { _col = make_color_rgb(220, 150, 70);  _a = 0.16; _r = 40; }
    else                   { _col = make_color_rgb(255, 186, 96);  _a = 0.26; _r = 52; }
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    var _objs = global.room_builder_objects;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        if (_o.builder_sprite != "spr_stable_lantern") continue;
        var _cx = _o.x + 16 * _o.image_xscale;
        var _cy = _o.y + 16 * _o.image_yscale;
        var _flick = 1 + 0.08 * sin(current_time * 0.004 + _o.x * 0.13 + _o.y * 0.07);
        draw_set_alpha(_a * _flick);
        draw_circle(_cx, _cy, _r * _flick, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
