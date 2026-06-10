// =============================================================================
// scr_stable — Room_fiorentine_stable — BLACK-VOID rectangular interior
// =============================================================================
// 10 x 15 cells (640 x 960) — CRAMPED per the reference's 2:3 proportions: snug
// one-horse stalls, a narrow 2-cell aisle. Walkable floor is an inset rectangle;
// the 1-cell black-void border is the walls. A 2-cell gap in the SOUTH wall (cols 4-5) is the
// entrance doorway. Props (obj_mercato_prop carrying a sprite, draggable like the
// market/inn) lay out the reference zones (references/stables_interior_map.png):
// hay storage (top-left), water trough (top-centre), tack room (top-right), six
// horse stalls flanking a central aisle, sleeping area (bottom-right, reputation-
// gated via obj_stable_rest), Pietro the stable boy in the centre aisle.
// INTERIOR room → black-void method (see CLAUDE.md). FF6 camera in the room.
// =============================================================================

#macro STABLE_W_CELLS 10
#macro STABLE_H_CELLS 15
#macro STABLE_GRID_PX 64

// South doorway centre — the entry gap + the return-to-Florence trigger.
#macro STABLE_EXIT_X 320
#macro STABLE_EXIT_Y 928    // row 14.5

// TEMP: boot straight into the stable for testing (takes precedence over the inn
// and Duomo load points in obj_game_manager Create). Flip to false to restore the
// normal Florence start.
#macro STABLE_LOAD_POINT false

// ── Cell predicates ─────────────────────────────────────────────────────────────
function scr_stable_is_interior(_cx, _cy) {
    var _main  = (_cx >= 1 && _cx <= 8 && _cy >= 1 && _cy <= 13);
    var _entry = (_cy == 14 && _cx >= 4 && _cx <= 5);   // south doorway gap
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

// ── STALL PARTITIONS — real WALLS, not props ────────────────────────────────────
// Six enclosed stall boxes per the reference: the room's void edge is each
// column's back wall; horizontal timber dividers split the band into 3 stalls a
// side; a vertical front wall along the aisle closes each box, with a gate gap
// so Benedetto (and one day the horses) can walk in. ONE geometry source drives
// BOTH the dark-wood drawing (obj_stable_scene Draw) and the obj_wall collision
// (scr_stable_build_collision) — they can never drift apart.
#macro STABLE_STALL_Y0     3.5     // stall band top (cells)
#macro STABLE_STALL_Y3     11      // stall band bottom (3 stalls of 2.5 cells)
#macro STABLE_STALL_LX     4.0     // LEFT column front wall (aisle west edge)
#macro STABLE_STALL_RX     6.0     // RIGHT column front wall (aisle east edge —
                                   // 2-cell aisle, ~80px clear inside the walls)
#macro STABLE_WALL_HALF    24      // wall half-thickness in px (48px — FF6-style
                                   // THICK walls textured with a small plank tile)
#macro STABLE_GATE_HALF    36      // gate gap half-height in px (72px gate)

/// All partition wall segments as [x0, y0, x1, y1] px rects.
function scr_stable_partitions() {
    var _g    = STABLE_GRID_PX;
    var _segs = [];
    var _rows = 3;
    var _band = (STABLE_STALL_Y3 - STABLE_STALL_Y0) / _rows;   // one stall's height

    // horizontal dividers: 4 per side (top edge, 2 between stalls, bottom edge)
    for (var _i = 0; _i <= _rows; _i++) {
        var _wy = (STABLE_STALL_Y0 + _i * _band) * _g;
        array_push(_segs, [1 * _g,                 _wy - STABLE_WALL_HALF, STABLE_STALL_LX * _g, _wy + STABLE_WALL_HALF]);   // left:  west wall -> aisle
        array_push(_segs, [STABLE_STALL_RX * _g,   _wy - STABLE_WALL_HALF, 9 * _g,               _wy + STABLE_WALL_HALF]);   // right: aisle -> east wall
    }
    // vertical front walls along the aisle, split by a centred gate gap per stall
    for (var _s = 0; _s < _rows; _s++) {
        var _ya = (STABLE_STALL_Y0 + _s * _band) * _g;
        var _yb = _ya + _band * _g;
        var _gc = (_ya + _yb) * 0.5;
        var _fxs = [STABLE_STALL_LX * _g, STABLE_STALL_RX * _g];
        for (var _f = 0; _f < 2; _f++) {
            var _fx = _fxs[_f];
            array_push(_segs, [_fx - STABLE_WALL_HALF, _ya, _fx + STABLE_WALL_HALF, _gc - STABLE_GATE_HALF]);   // above the gate
            array_push(_segs, [_fx - STABLE_WALL_HALF, _gc + STABLE_GATE_HALF, _fx + STABLE_WALL_HALF, _yb]);   // below the gate
        }
    }
    return _segs;
}

/// Paint the partitions FF6-style (cf. the SNES inn interiors): THICK wall bands
/// textured by tiling a SMALL plank tile — spr_stable_wall_tile (32px, seamless)
/// drawn 1:1, like FF6 textures its void walls. Fallbacks: quarter-scale
/// spr_stable_floor tinted timber, then flat dark wood. A lit top edge + black
/// grounding shadow make the band read as a raised wall, and corruption cools
/// the wood like everything else in the room.
function scr_stable_draw_partitions(_corr01) {
    var _segs = scr_stable_partitions();
    var _wood = merge_color(c_white,                     make_color_rgb(110, 112, 124), _corr01);
    var _tint = merge_color(make_color_rgb(96, 62, 36),  make_color_rgb(46, 44, 50),    _corr01);
    var _flat = merge_color(make_color_rgb(58, 38, 24),  make_color_rgb(30, 28, 32),    _corr01);
    var _top  = merge_color(make_color_rgb(132, 92, 54), make_color_rgb(64, 62, 68),    _corr01);

    // preferred: the dedicated 32px seamless plank tile, drawn unscaled
    var _tile  = asset_get_index("spr_stable_wall_tile");
    var _scale = 1;
    var _col   = _wood;
    if (_tile < 0 || asset_get_type("spr_stable_wall_tile") != asset_sprite) {
        _tile  = asset_get_index("spr_stable_floor");   // fallback: floor at 0.5, timber tint
        _scale = 0.5;
        _col   = _tint;
        if (_tile < 0 || asset_get_type("spr_stable_floor") != asset_sprite) _tile = -1;
    }
    var _ts = 32;   // texture tile size on screen

    // FF6 layering: each wall is a SOLID BLACK void block (same rect as its
    // obj_wall collision), with the plank tiles placed ON the black, inset so a
    // black frame outlines every wall — reads as a solid built wall, exactly
    // like the SNES inn interiors.
    var _inset = 4;
    for (var _i = 0; _i < array_length(_segs); _i++) {
        var _s = _segs[_i];

        // 1) the black void block — the wall body
        draw_set_color(c_black);
        draw_rectangle(_s[0], _s[1], _s[2], _s[3], false);

        // 2) texture tiles ON the black, inset for the black outline frame
        var _x0 = _s[0] + _inset, _y0 = _s[1] + _inset;
        var _x1 = _s[2] - _inset, _y1 = _s[3] - _inset;
        if (_x1 > _x0 && _y1 > _y0) {
            if (_tile != -1) {
                for (var _ty = _y0; _ty < _y1; _ty += _ts) {
                    var _h = min(_ts, _y1 - _ty);
                    for (var _tx = _x0; _tx < _x1; _tx += _ts) {
                        var _w = min(_ts, _x1 - _tx);
                        draw_sprite_part_ext(_tile, 0, 0, 0, _w / _scale, _h / _scale,
                            _tx, _ty, _scale, _scale, _col, 1);
                    }
                }
            } else {
                draw_set_color(_flat);
                draw_rectangle(_x0, _y0, _x1, _y1, false);
            }
            // 3) lit top edge inside the texture — the wall catches the light
            draw_set_color(_top);
            draw_rectangle(_x0, _y0, _x1, min(_y0 + 3, _y1), false);
        }
    }
    draw_set_color(c_white);
}

// ── Default prop layout — [object, gx, gy, scale, (sprite)] ───────────────────────
// Mirrors references/stables_interior_map.png. obj_mercato_prop carries the sprite +
// collision, so every piece is click-drag / nudge / rotate / Delete / F8-saveable.
function scr_stable_default_layout() {
    var _L = [];
    // Zone 4 — HAY STORAGE (top-left)
    array_push(_L, ["obj_mercato_prop", 1,    1,    1.0, "spr_stable_hay"]);
    array_push(_L, ["obj_mercato_prop", 2.3,  1.3,  0.7, "spr_stable_hay"]);
    array_push(_L, ["obj_mercato_prop", 1.3,  2.3,  0.6, "spr_stable_hay"]);
    // Zone 5 — WATER TROUGH (head of the aisle per the reference, two segments
    // reading as one long trough spanning the aisle mouth x 4-6)
    array_push(_L, ["obj_mercato_prop", 4,    2,    1.0, "spr_stable_trough"]);
    array_push(_L, ["obj_mercato_prop", 5,    2,    1.0, "spr_stable_trough"]);
    // Zone 6 — TACK ROOM (top-right)
    array_push(_L, ["obj_mercato_prop", 6.4,  1,    1.0, "spr_stable_tack"]);
    array_push(_L, ["obj_mercato_prop", 7.5,  1.5,  0.7, "spr_stable_tack"]);
    array_push(_L, ["obj_barrel",       7.7,  2.5,  0.5]);
    // Zone 3 — SIX HORSES inside the partition-wall stalls (the walls themselves
    // are DRAWN + collided by scr_stable_partitions, NOT props — see above).
    // 1.0 scale — ONE horse fills its snug stall like the reference. Stall band
    // 3.5-11, 3 stalls -> centres y 4.75 / 7.25 / 9.75; a 1.0-scale 64px sprite is
    // 1 cell, so top-left = centre - 0.5. Stall inner x: left 64-232px (centre
    // 148 -> gx 1.8), right 408-576px (centre 492 -> gx 7.2).
    var _horses = [
        [1.8, 4.25, "spr_stable_horse_grey"],   [7.2, 4.25, "spr_stable_horse_grey"],
        [1.8, 6.75, "spr_stable_horse_brown"],  [7.2, 6.75, "spr_stable_horse_brown"],
        [1.8, 9.25, "spr_stable_horse_black"],  [7.2, 9.25, "spr_stable_horse_black"],
    ];
    for (var _i = 0; _i < array_length(_horses); _i++)
        array_push(_L, ["obj_mercato_prop", _horses[_i][0], _horses[_i][1], 1.0, _horses[_i][2]]);
    // Aisle LANTERNS mounted on the stall-front gateposts — 0.6 scale, straddling
    // the 48px front walls at x 4.0 / 6.0 (the 80px aisle is too narrow for posts)
    var _lrows = [3.9, 6.4, 8.9, 11.3];
    for (var _l = 0; _l < array_length(_lrows); _l++) {
        array_push(_L, ["obj_mercato_prop", 3.7, _lrows[_l], 0.6, "spr_stable_lantern"]);
        array_push(_L, ["obj_mercato_prop", 5.7, _lrows[_l], 0.6, "spr_stable_lantern"]);
    }
    // Zone 7 — SLEEPING AREA (bottom-right; rest gate handled by obj_stable_rest)
    array_push(_L, ["obj_mercato_prop", 6.6,  11.6, 1.0, "spr_stable_sleeping"]);
    array_push(_L, ["obj_mercato_prop", 7.7,  11.3, 0.6, "spr_stable_hay"]);
    array_push(_L, ["obj_barrel",       7.8,  12.6, 0.5]);
    array_push(_L, ["obj_stable_rest",  6.6,  11.6, 1]);
    // Bottom-left clutter (barrels per the reference)
    array_push(_L, ["obj_barrel",       1,    11.5, 0.5]);
    array_push(_L, ["obj_barrel",       1.9,  12.1, 0.5]);
    array_push(_L, ["obj_barrel",       1.2,  12.9, 0.5]);
    // Zone 2 — PIETRO the stable boy at the aisle mouth (the open zone below the
    // stalls — standing IN the 2-cell aisle would plug it)
    array_push(_L, ["obj_npc_stableboy", 4.4, 11.5, 1]);
    return _L;
}

// ── Build (called from obj_stable_scene Create) ──────────────────────────────────
function scr_stable_build() {
    if (room != Room_fiorentine_stable) return 0;

    // keep-alive: name-placed sprites + objects are invisible to the asset stripper.
    global.__stable_keep     = [obj_mercato_prop, obj_barrel, obj_npc_stableboy, obj_stable_rest];
    global.__stable_keep_spr = [spr_stable_floor, spr_stable_wall_tile,
        spr_stable_horse_grey, spr_stable_horse_brown, spr_stable_horse_black,
        spr_stable_hay, spr_stable_trough, spr_stable_tack, spr_stable_sleeping,
        spr_stable_lantern, spr_npc_stableboy];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_fiorentine_stable_layout.txt";
    // Stale-layout guard: only load an F8-saved copy stamped with the CURRENT
    // STABLE_LAYOUT_VERSION; otherwise the code default below takes over.
    var _placed = scr_room_builder_layout_current(_path) ? scr_stable_load(_path) : 0;
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

/// Collision: the void-ring walls + the stall partition walls + each solid
/// prop's tight footprint.
function scr_stable_build_collision() {
    for (var _cy = 0; _cy < STABLE_H_CELLS; _cy++)
        for (var _cx = 0; _cx < STABLE_W_CELLS; _cx++) {
            if (!scr_stable_is_wall(_cx, _cy)) continue;
            var _w = instance_create_depth(_cx * STABLE_GRID_PX, _cy * STABLE_GRID_PX, 500, obj_wall);
            _w.wall_w  = STABLE_GRID_PX;
            _w.wall_h  = STABLE_GRID_PX;
            _w.visible = false;
        }
    // stall partitions — same rects the scene draws (single geometry source)
    var _segs = scr_stable_partitions();
    for (var _i = 0; _i < array_length(_segs); _i++) {
        var _s  = _segs[_i];
        var _pw = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _pw.wall_w  = _s[2] - _s[0];
        _pw.wall_h  = _s[3] - _s[1];
        _pw.visible = false;
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
