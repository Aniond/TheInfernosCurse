// =============================================================================
// scr_room_builder — text-file room layout: load + save
// =============================================================================
// Place props from a plain-text file instead of the room editor. One line per
// instance:   OBJECT_NAME  GRID_X  GRID_Y  SCALE   (1 grid cell = 64 px).
//
//   scr_room_builder_load()  — read the file, create instances at grid*64.
//   scr_room_builder_save()  — write every builder-placed instance back out
//                              (object name + current grid pos + scale).
//
// File location: ROOM_BUILDER_FILE (absolute path in the project tree). The
// runtime file sandbox normally blocks absolute paths — if it is enabled the
// scripts fall back to the game's save folder (working_directory) so the tool
// still works; flip "Disable file system sandbox" (Game Options > Windows) to
// read/write the project-tree file directly.
//
// Unknown / not-yet-created object names are skipped and logged, never fatal.
// =============================================================================

#macro ROOM_BUILDER_FILE  "C:/TheInfernoCurse/layouts/room1_layout.txt"
#macro ROOM_BUILDER_GRID  64

// Layout schema version. The runtime reads a per-machine copy from the save folder
// (the sandbox blocks the project-tree file). That copy is re-seeded from
// scr_room_builder_default_text() whenever its embedded "# VERSION n" differs from
// this number, so a structural relayout actually reaches the player. Bump this when
// you change default_text(). F8 saves stamp the current version, so hand-dragged
// layouts are preserved across launches and only a version bump clobbers them.
#macro ROOM_BUILDER_LAYOUT_VERSION  10


/// Split a line on runs of spaces/tabs. Returns an array of tokens.
function scr_room_builder_tokenize(_s) {
    var _out = [];
    var _cur = "";
    var _n = string_length(_s);
    for (var _i = 1; _i <= _n; _i++) {
        var _c = string_char_at(_s, _i);
        if (_c == " " || _c == chr(9)) {
            if (_cur != "") { array_push(_out, _cur); _cur = ""; }
        } else {
            _cur += _c;
        }
    }
    if (_cur != "") array_push(_out, _cur);
    return _out;
}

/// Right-pad a string with spaces to _w columns (for readable saved files).
function scr_room_builder_pad(_s, _w) {
    var _r = _s;
    while (string_length(_r) < _w) _r += " ";
    return _r;
}

/// Resolve the readable layout path: project-tree file if reachable (sandbox
/// off), else the save-folder copy. Returns "" if neither exists.
function scr_room_builder_read_path() {
    // Sandbox is ON: only the save folder is reachable at runtime, so we don't
    // touch the absolute project path (it just errors). The project-tree file
    // (ROOM_BUILDER_FILE) is the human-readable source mirrored into the seed.
    var _wd = working_directory + "room1_layout.txt";
    if (file_exists(_wd)) return _wd;
    return "";
}

/// Returns the "# VERSION n" stamped at the top of a layout file, or -1 if absent.
/// Only scans the first few lines so a stray digit further down never matches.
function scr_room_builder_file_version(_path) {
    if (!file_exists(_path)) return -1;
    var _f = file_text_open_read(_path);
    if (_f == -1) return -1;
    var _ver  = -1;
    var _scan = 0;
    while (!file_text_eof(_f) && _scan < 6) {
        var _l = file_text_read_string(_f);
        file_text_readln(_f);
        _scan++;
        var _p = string_pos("# VERSION", _l);
        if (_p > 0) {
            var _digits = string_digits(string_copy(_l, _p, string_length(_l) - _p + 1));
            if (_digits != "") _ver = real(_digits);
            break;
        }
    }
    file_text_close(_f);
    return _ver;
}

/// Seed (or RE-seed) the save-folder layout copy from default_text() when it is
/// missing or its version is stale. Returns true if the file is ready to read.
/// A version bump in ROOM_BUILDER_LAYOUT_VERSION forces a one-time overwrite — the
/// intended way to push a structural relayout to every machine.
function scr_room_builder_seed_if_needed() {
    var _seed = working_directory + "room1_layout.txt";
    var _have = scr_room_builder_file_version(_seed);
    if (file_exists(_seed) && _have == ROOM_BUILDER_LAYOUT_VERSION) return true;

    var _wf = file_text_open_write(_seed);
    if (_wf == -1) {
        show_debug_message("[room_builder] could not seed layout -> " + _seed);
        return false;
    }
    file_text_write_string(_wf, scr_room_builder_default_text());
    file_text_close(_wf);
    show_debug_message("[room_builder] " + (_have == -1 ? "seeded" : "re-seeded (v" +
        string(_have) + "->v" + string(ROOM_BUILDER_LAYOUT_VERSION) + ")") +
        " layout -> " + _seed);
    return true;
}

/// Default layout written to the save folder on first run (sandbox-safe seed).
/// Mirrors layouts/room1.txt in the project tree. Unknown objects are skipped.
function scr_room_builder_default_text() {
    // FINALISED market square (locked 2026-06-07). Positions are the exact hand-
    // curated save-folder layout; every obj_mercato_prop is SOLID. Collision boxes
    // are built from these by scr_room_builder_build_collision() (stalls = back+sides
    // only so the player shops from the front; buildings + fountain = full body).
    // Bump ROOM_BUILDER_LAYOUT_VERSION whenever this text changes (forces a re-seed).
    return
        "# VERSION 10\n" +
        "# Room1 layout — OBJECT  GRID_X  GRID_Y  SCALE  [SPRITE]  [solid]   (1 cell = 64 px)\n" +
        "# Market square FINALISED + collision LOCKED. All obj_mercato_prop are solid\n" +
        "# (stalls: back+sides only; buildings + fountain: full body). Park/piazza props\n" +
        "# scaled per CLAUDE.md Room1 Prop Scale Rules.\n" +
        "\n" +
        "# --- Piazza + park ---\n" +
        "obj_well                16        20        0.7\n" +
        "obj_marco_stall         13        19        0.7\n" +
        "obj_cart                19        21        0.6\n" +
        "obj_barrel              11        19        0.5\n" +
        "obj_barrel              21        20        0.5\n" +
        "obj_garden_fountain     5         20        0.8\n" +
        "obj_shrine              16        28        1\n" +
        "\n" +
        "# --- Cypress trees (park edges + market backdrop) ---\n" +
        "obj_cypress_tree        3         18        0.7\n" +
        "obj_cypress_tree        3         22        0.7\n" +
        "obj_cypress_tree        28        18        0.7\n" +
        "obj_cypress_tree        28        22        0.7\n" +
        "obj_cypress_tree        14        8         0.7\n" +
        "obj_cypress_tree        16        3.6875    0.7\n" +
        "obj_cypress_tree        11.25     3.4375    0.7\n" +
        "obj_cypress_tree        19.625    3.5       0.7\n" +
        "obj_cypress_tree        8.9375    3.5       0.7\n" +
        "\n" +
        "# --- MERCATO VECCHIO market (north zone) — all SOLID ---\n" +
        "obj_mercato_prop        1         1         1     spr_mercato_building_a   solid\n" +
        "obj_mercato_prop        9         1         1     spr_mercato_inn          solid\n" +
        "obj_mercato_prop        15.875    0.9375    1     spr_mercato_loggia       solid\n" +
        "obj_mercato_prop        20.4375   1         1     spr_mercato_building_a   solid\n" +
        "obj_mercato_prop        4.5625    2.3125    1     spr_florence_church      solid\n" +
        "obj_mercato_prop        11.8125   2.6875    1     spr_florence_stable      solid\n" +
        "obj_mercato_prop        11.62     7         0.7   spr_stall_striped_green  solid\n" +
        "obj_mercato_prop        8.62      5.62      0.7   spr_stall_striped_cream  solid\n" +
        "obj_mercato_prop        11.62     5.62      0.7   spr_stall_striped_blue   solid\n" +
        "obj_mercato_prop        10        6         0.7   spr_stall_herbalist      solid\n" +
        "obj_mercato_prop        10        5         0.8   spr_mercato_fountain     solid\n" +
        "obj_mercato_prop        11.81     7.56      0.4   spr_hanging_herbs        solid\n" +
        "obj_mercato_prop        9.125     5.875     0.4   spr_bread_board          solid\n" +
        "obj_mercato_prop        12.4375   6.625     0.4   spr_clay_jugs            solid\n" +
        "obj_mercato_prop        21        4         0.4   spr_clay_pot_large       solid\n" +
        "\n" +
        "# --- Landmark: Basilica di Santa Maria del Fiore (draggable; open area) ---\n" +
        "obj_mercato_prop        24        10        1     spr_duomo_exterior       solid\n";
}


// ── LOAD ───────────────────────────────────────────────────────────────────────
/// Reads the layout file and creates one instance per line. Returns the number
/// placed. Re-running first clears anything a previous load placed (no dupes).
function scr_room_builder_load() {
    // KEEP-ALIVE: these objects are only ever placed by NAME (asset_get_index),
    // which the asset stripper cannot see — without a static reference it deletes
    // them as "unused" and asset_get_index() returns -1 at runtime. Referencing
    // each identifier here forces the compiler to keep them (and their sprites).
    // Add any new object type used in the layout file to this list.
    global.__room_builder_keep = [obj_florence_building, obj_florence_house,
        obj_florence_cathedral, obj_florence_tower, obj_marco_stall, obj_well,
        obj_cart, obj_cypress_tree, obj_barrel, obj_shrine,
        obj_garden_fountain, obj_garden_bench, obj_garden_archway,
        obj_garden_urn, obj_garden_cypress, obj_garden_tree_olive, obj_garden_tree_flowering,
        obj_mercato_prop];
    // Market sprites are placed by NAME (asset_get_index in the loader), invisible to
    // the stripper — reference each identifier here so they survive into the build.
    global.__mercato_keep_sprites = [spr_mercato_loggia, spr_mercato_building_a,
        spr_mercato_building_b, spr_mercato_building_c, spr_mercato_inn, spr_mercato_fountain,
        spr_stall_striped_green, spr_stall_striped_cream, spr_stall_striped_red,
        spr_stall_striped_blue, spr_stall_striped_purple, spr_stall_flat_green,
        spr_stall_dye_merchant, spr_stall_weapon_smith, spr_stall_herbalist, spr_stall_produce,
        spr_barrel_stack, spr_crate_stack, spr_sack_pile, spr_clay_pot_large,
        spr_cart_loaded, spr_cart_covered, spr_hanging_cloth,
        spr_hanging_herbs, spr_bread_board, spr_clay_jugs,
        spr_florence_church, spr_florence_stable, spr_duomo_exterior];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];

    // clear previously-built instances
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++) {
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    }
    global.room_builder_objects = [];

    // Seed/re-seed the save-folder copy from default_text() if it is missing or its
    // version is stale (sandbox keeps the runtime off the project-tree file). Edit
    // default_text() + bump ROOM_BUILDER_LAYOUT_VERSION to push a new layout.
    scr_room_builder_seed_if_needed();

    var _path = scr_room_builder_read_path();
    if (_path == "") {
        show_debug_message("[room_builder] no layout file available after seeding");
        return 0;
    }

    var _f = file_text_open_read(_path);
    if (_f == -1) {
        show_debug_message("[room_builder] could not open: " + _path);
        return 0;
    }

    var _layer   = layer_exists("Instances") ? "Instances" : "";
    var _placed  = 0;
    var _skipped = 0;
    var _ln      = 0;

    while (!file_text_eof(_f)) {
        var _raw = file_text_read_string(_f);
        file_text_readln(_f);
        _ln++;

        var _line = string_trim(string_replace_all(_raw, chr(13), ""));   // strip CR + trim
        if (_line == "" || string_char_at(_line, 1) == "#") continue;     // blank / comment

        var _tok = scr_room_builder_tokenize(_line);
        if (array_length(_tok) < 3) {
            show_debug_message("[room_builder] line " + string(_ln) + " malformed: " + _line);
            _skipped++;
            continue;
        }

        var _name  = _tok[0];
        var _gx    = real(_tok[1]);
        var _gy    = real(_tok[2]);
        var _scale = (array_length(_tok) >= 4) ? real(_tok[3]) : 1.0;

        var _obj = asset_get_index(_name);
        if (_obj < 0 || asset_get_type(_name) != asset_object) {
            show_debug_message("[room_builder] line " + string(_ln) + ": object not found -> " + _name);
            _skipped++;
            continue;
        }

        var _px = _gx * ROOM_BUILDER_GRID;
        var _py = _gy * ROOM_BUILDER_GRID;
        var _inst = (_layer != "")
            ? instance_create_layer(_px, _py, _layer, _obj)
            : instance_create_depth(_px, _py, 100, _obj);

        _inst.image_xscale = _scale;
        _inst.image_yscale = _scale;
        _inst.room_builder_placed = true;        // tag for save

        // Optional ROTATION — the last PURE-INTEGER token (e.g. "90"). Works for both
        // "obj gx gy scale ANGLE" and "...sprite solid ANGLE". 0 if absent.
        _inst.builder_angle = 0;
        if (array_length(_tok) >= 5) {
            var _angt = _tok[array_length(_tok) - 1];
            if (_angt != "" && string_digits(_angt) == _angt) _inst.builder_angle = real(_angt);
        }

        // Optional SPRITE override (token 5) + SOLID flag (token 6). Generic
        // placeables (obj_mercato_prop) carry their sprite + collision in the layout,
        // so the whole market is draggable + F8-saveable like every other object.
        _inst.builder_sprite = "";
        _inst.builder_solid  = false;
        if (array_length(_tok) >= 5) {
            var _sprn  = _tok[4];
            var _sprid = asset_get_index(_sprn);
            if (_sprid >= 0 && asset_get_type(_sprn) == asset_sprite) {
                _inst.sprite_index   = _sprid;
                _inst.builder_sprite = _sprn;
            }
        }
        if (array_length(_tok) >= 6 && _tok[5] == "solid") {
            _inst.builder_solid = true;
        }
        // Market square FINALISED: EVERY obj_mercato_prop is solid (the layout's
        // "solid" token is still honoured for other types, but a mercato prop is
        // always solid regardless). scr_room_builder_build_collision() then lays a
        // tight, per-category obj_wall footprint under each — no full-bbox ghosts.
        if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = true;

        array_push(global.room_builder_objects, _inst);
        _placed++;
    }
    file_text_close(_f);

    // Build the market collision now that every prop is placed + flagged.
    scr_room_builder_build_collision();

    show_debug_message("[room_builder] loaded " + string(_placed) + " placed, " +
        string(_skipped) + " skipped from " + _path);
    if (variable_global_exists("world_event_log"))
        scr_world_event_log("Room builder: " + string(_placed) + " placed, " + string(_skipped) + " skipped");
    return _placed;
}


// ── COLLISION (market props) ────────────────────────────────────────────────────
/// Build an invisible obj_wall footprint under every "solid" builder prop. Called
/// once at the end of scr_room_builder_load(). Footprints are INSET fractions of
/// each prop's on-screen bbox — the prop sprites use a Full-Image mask, so the raw
/// bbox is the whole PNG incl. transparent padding; using it whole is what put stray
/// walls out in the open cobble before. Per category:
///   • stalls    — BACK + SIDES only (top ~55% of height). The front (south) strip is
///                 left open so Benedetto can step up to the counter and shop.
///   • buildings — near-full body (church, stable, loggia, inn, building…), inset off
///                 the painted edges.
///   • fountain  — solid central basin.
///   • all else  — small base footprint (urns, pots, herbs, bread, jugs, crates…).
/// Walls are tracked in global.__room_builder_collision so a rebuild clears only
/// THESE, never the river / garden walls (also obj_wall) that obj_game_manager owns.
function scr_room_builder_build_collision() {
    if (!variable_global_exists("__room_builder_collision")) global.__room_builder_collision = [];
    // clear any walls from a previous build (defensive — load normally runs once)
    for (var _i = 0; _i < array_length(global.__room_builder_collision); _i++) {
        if (instance_exists(global.__room_builder_collision[_i])) instance_destroy(global.__room_builder_collision[_i]);
    }
    global.__room_builder_collision = [];

    if (!variable_global_exists("room_builder_objects")) return 0;
    var _made = 0;

    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++) {
        var _o = global.room_builder_objects[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_solid") || !_o.builder_solid) continue;
        if (_o.sprite_index == -1 || !sprite_exists(_o.sprite_index)) continue;

        // on-screen extent (Full-Image bbox == the displayed sprite rectangle)
        var _L = _o.bbox_left, _T = _o.bbox_top, _R = _o.bbox_right, _B = _o.bbox_bottom;
        var _bw = _R - _L, _bh = _B - _T;
        if (_bw <= 0 || _bh <= 0) continue;

        var _nm = (variable_instance_exists(_o, "builder_sprite") && _o.builder_sprite != "")
            ? _o.builder_sprite : sprite_get_name(_o.sprite_index);

        // category → inset fractions [x0,y0,x1,y1] of the bbox
        var _x0f, _y0f, _x1f, _y1f;
        if (string_pos("stall", _nm) > 0) {
            // BACK + SIDES: top band only, front (south) left open to shop from
            _x0f = 0.05; _y0f = 0.05; _x1f = 0.95; _y1f = 0.58;
        } else if (string_pos("fountain", _nm) > 0) {
            // solid central basin
            _x0f = 0.18; _y0f = 0.24; _x1f = 0.82; _y1f = 0.90;
        } else if (string_pos("building", _nm) > 0 || string_pos("loggia", _nm) > 0
                || string_pos("inn", _nm) > 0 || string_pos("church", _nm) > 0
                || string_pos("stable", _nm) > 0 || string_pos("cathedral", _nm) > 0
                || string_pos("tower", _nm) > 0 || string_pos("house", _nm) > 0
                || string_pos("duomo", _nm) > 0 || string_pos("basilica", _nm) > 0) {
            // building body — inset off the painted edges so no ghost in the cobble
            _x0f = 0.12; _y0f = 0.10; _x1f = 0.88; _y1f = 0.94;
        } else {
            // small ground prop (urn, pot, herbs, bread, jugs, crate, sack, cloth…)
            _x0f = 0.22; _y0f = 0.50; _x1f = 0.78; _y1f = 0.92;
        }

        var _wx0 = _L + _bw * _x0f, _wy0 = _T + _bh * _y0f;
        var _wx1 = _L + _bw * _x1f, _wy1 = _T + _bh * _y1f;

        var _w = instance_create_depth(_wx0, _wy0, 500, obj_wall);
        _w.wall_w  = _wx1 - _wx0;
        _w.wall_h  = _wy1 - _wy0;
        _w.visible = false;
        array_push(global.__room_builder_collision, _w);
        _made++;
    }

    show_debug_message("[room_builder] built " + string(_made) + " market collision boxes");
    return _made;
}


// ── SAVE ───────────────────────────────────────────────────────────────────────
/// Writes every builder-placed instance back to the layout file (current grid
/// position + scale). Tries the project-tree path first, then the save folder.
function scr_room_builder_save() {
    // Per-room save file (sandbox-safe save area) — the bridge room has its own
    // statue layout so F8 there never clobbers Florence's market layout.
    var _path = working_directory + "room1_layout.txt";
    if (room == Room_ponte_vecchio)  _path = working_directory + "room_ponte_vecchio_layout.txt";
    if (room == Room_duomo)          _path = working_directory + "room_duomo_layout.txt";
    if (room == Room_locanda_rosa_camuna) _path = working_directory + "room_locanda_rosa_camuna_layout.txt";
    var _f = file_text_open_write(_path);
    if (_f == -1) {
        show_debug_message("[room_builder] SAVE FAILED — sandbox blocks " + ROOM_BUILDER_FILE +
            ". Enable 'Disable file system sandbox' (Game Options > Windows).");
        if (variable_global_exists("save_indicator_text")) {
            global.save_indicator_text  = "LAYOUT SAVE FAILED";
            global.save_indicator_timer = 120;
        }
        return false;
    }

    // Stamp the current version so the re-seed check (scr_room_builder_seed_if_needed)
    // treats this hand-saved layout as current and never clobbers it.
    file_text_write_string(_f, "# VERSION " + string(ROOM_BUILDER_LAYOUT_VERSION));
    file_text_writeln(_f);
    file_text_write_string(_f, "# Room1 layout — OBJECT_NAME  GRID_X  GRID_Y  SCALE   (1 cell = 64 px)");
    file_text_writeln(_f);

    var _count = 0;
    if (variable_global_exists("room_builder_objects")) {
        for (var _i = 0; _i < array_length(global.room_builder_objects); _i++) {
            var _inst = global.room_builder_objects[_i];
            if (!instance_exists(_inst)) continue;

            if (_inst.object_index == obj_wall) continue;        // collision boxes aren't saved
            if (_inst.object_index == obj_mercato_exit) continue; // transitions saved separately (overrides)
            var _name = object_get_name(_inst.object_index);
            var _gx   = _inst.x / ROOM_BUILDER_GRID;   // fractional — keeps fine-nudge sub-grid offsets
            var _gy   = _inst.y / ROOM_BUILDER_GRID;
            var _sc   = _inst.image_xscale;

            // Whole cells print as integers; nudged props keep 4-decimal precision.
            // Explicit "  " separators guarantee fields never merge (a fractional value
            // can be wider than the pad width, which previously ran columns together).
            var _gxs = (_gx == round(_gx)) ? string(round(_gx)) : string_format(_gx, 0, 4);
            var _gys = (_gy == round(_gy)) ? string(round(_gy)) : string_format(_gy, 0, 4);
            var _line = scr_room_builder_pad(_name, 22) + "  " +
                        scr_room_builder_pad(_gxs, 9) + "  " +
                        scr_room_builder_pad(_gys, 9) + "  " +
                        scr_room_builder_pad(string(_sc), 5);
            // generic placeables carry their sprite (+ solid flag) so F8 round-trips them
            if (_name == "obj_mercato_prop") {
                var _sn = (variable_instance_exists(_inst, "builder_sprite") && _inst.builder_sprite != "")
                    ? _inst.builder_sprite : sprite_get_name(_inst.sprite_index);
                _line += "  " + _sn;
                if (variable_instance_exists(_inst, "builder_solid") && _inst.builder_solid) _line += "  solid";
            }
            // ROTATION — appended as the last column only when non-zero, so unrotated
            // lines stay clean and both loaders read it as the trailing integer.
            if (variable_instance_exists(_inst, "builder_angle") && _inst.builder_angle != 0)
                _line += "  " + string(_inst.builder_angle);
            file_text_write_string(_f, _line);
            file_text_writeln(_f);
            _count++;
        }
    }
    file_text_close(_f);

    // Transitions persist to their own override file (drag in debug, F8 saves here).
    scr_transition_save_overrides();

    // NPC data persists too (save-folder copy; layouts\npc_data.json synced on commit).
    if (variable_global_exists("npc_data")) scr_npc_sync_to_layouts();

    show_debug_message("[room_builder] saved " + string(_count) + " objects -> " + _path);
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "LAYOUT SAVED (" + string(_count) + ")";
        global.save_indicator_timer = 120;
    }
    if (variable_global_exists("world_event_log"))
        scr_world_event_log("Layout saved (" + string(_count) + " objects)");
    return true;
}


// ── DRAG-TO-MOVE (debug mode) ──────────────────────────────────────────────────
/// True if (mx,my) is over a builder instance — sprite bbox if it has one, else a
/// ~grid-sized box around the origin (for shape-drawn objects like obj_shrine).
function scr_room_builder_point_in(_inst, _mx, _my) {
    if (_inst.object_index == obj_mercato_exit && variable_instance_exists(_inst, "zone_w")) {
        return point_in_rectangle(_mx, _my, _inst.x, _inst.y, _inst.x + _inst.zone_w, _inst.y + _inst.zone_h);
    }
    if (_inst.sprite_index != -1 && sprite_exists(_inst.sprite_index)) {
        return point_in_rectangle(_mx, _my, _inst.bbox_left, _inst.bbox_top, _inst.bbox_right, _inst.bbox_bottom);
    }
    var _h = 24 * max(_inst.image_xscale, 0.5);
    return point_in_rectangle(_mx, _my, _inst.x - _h, _inst.y - _h, _inst.x + _h, _inst.y + _h);
}

/// Debug-mode click-drag of builder-placed objects, grid-snapped on release.
/// Called every step from obj_game_manager. F8 then writes the new positions.
function scr_room_builder_drag_update() {
    if (!global.debug_mode) return;
    if (room != Room1 && room != Room_ponte_vecchio && room != Room_duomo && room != Room_locanda_rosa_camuna) return;   // draggable in all built rooms
    if (variable_global_exists("input_locked") && global.input_locked) return;
    if (!variable_global_exists("room_builder_objects")) return;
    if (!variable_global_exists("room_builder_drag")) global.room_builder_drag = noone;

    if (!variable_global_exists("room_builder_selected")) global.room_builder_selected = noone;

    var _mx = mouse_x, _my = mouse_y;

    // begin drag — pick the last (topmost) builder instance under the cursor
    if (global.room_builder_drag == noone && mouse_check_button_pressed(mb_left)) {
        var _picked = noone;
        for (var _i = array_length(global.room_builder_objects) - 1; _i >= 0; _i--) {
            var _inst = global.room_builder_objects[_i];
            if (!instance_exists(_inst)) continue;
            if (_inst.object_index == obj_wall) continue;     // invisible collision boxes aren't draggable
            if (scr_room_builder_point_in(_inst, _mx, _my)) {
                global.room_builder_drag    = _inst;
                global.room_builder_drag_dx = _inst.x - _mx;
                global.room_builder_drag_dy = _inst.y - _my;
                global.room_builder_drag_ox = _inst.x;   // grab position — distinguishes
                global.room_builder_drag_oy = _inst.y;   // a pure select-click from a drag
                _picked = _inst;
                break;
            }
        }
        // Left click selects the picked object (red outline + inspector panel);
        // clicking empty space clears the selection.
        global.room_builder_selected = _picked;
    }

    // active drag
    if (global.room_builder_drag != noone) {
        if (!instance_exists(global.room_builder_drag)) { global.room_builder_drag = noone; return; }
        var _o = global.room_builder_drag;
        if (mouse_check_button(mb_left)) {
            _o.x = _mx + global.room_builder_drag_dx;     // follow cursor (smooth, unsnapped)
            _o.y = _my + global.room_builder_drag_dy;
        } else {
            // release -> snap to the 64px grid, but ONLY if it actually moved. A pure
            // click (no movement) just selects, leaving fractional positions intact.
            if (_o.x != global.room_builder_drag_ox || _o.y != global.room_builder_drag_oy) {
                _o.x = round(_o.x / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
                _o.y = round(_o.y / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
                if (variable_global_exists("world_event_log"))
                    scr_world_event_log(object_get_name(_o.object_index) + " moved -> grid " +
                        string(_o.x / ROOM_BUILDER_GRID) + "," + string(_o.y / ROOM_BUILDER_GRID) + "  (F8 to save)");
            }
            if (room == Room_duomo) scr_duomo_rebuild_collision(); if (room == Room_locanda_rosa_camuna) scr_inn_rebuild_collision();   // footprint follows the prop — no ghosts
            global.room_builder_drag = noone;
        }
    }
}


/// DEBUG: delete the currently-selected builder object. Destroys the instance,
/// drops it from the builder list, persists the layout (save-folder copy, minus the
/// deleted entry) and shows a confirmation. Bound to the Delete key in debug mode.
function scr_room_builder_delete_selected() {
    if (!variable_global_exists("room_builder_selected")) return false;
    var _sel = global.room_builder_selected;
    if (!instance_exists(_sel)) { global.room_builder_selected = noone; return false; }

    var _name = object_get_name(_sel.object_index);
    var _gx   = round(_sel.x / ROOM_BUILDER_GRID);
    var _gy   = round(_sel.y / ROOM_BUILDER_GRID);

    // Drop from the builder list so it is neither re-saved nor re-outlined.
    if (variable_global_exists("room_builder_objects")) {
        for (var _i = array_length(global.room_builder_objects) - 1; _i >= 0; _i--) {
            if (global.room_builder_objects[_i] == _sel)
                array_delete(global.room_builder_objects, _i, 1);
        }
    }
    instance_destroy(_sel);
    global.room_builder_selected = noone;
    if (variable_global_exists("room_builder_drag")) global.room_builder_drag = noone;
    if (room == Room_duomo) scr_duomo_rebuild_collision(); if (room == Room_locanda_rosa_camuna) scr_inn_rebuild_collision();   // drop the deleted prop's footprint

    // Persist: rewrite the layout file (save folder) without the deleted entry.
    scr_room_builder_save();

    var _msg = "Deleted " + _name + " at " + string(_gx) + "," + string(_gy);
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = _msg;
        global.save_indicator_timer = 150;
    }
    if (variable_global_exists("world_event_log")) scr_world_event_log(_msg);
    return true;
}


/// DEBUG: fine-nudge the selected builder object with the ARROW KEYS (sub-grid).
/// 4px per tap; hold Shift for 1px ultra-fine. Player arrow-movement is suppressed
/// while a prop is selected (see obj_player Step) so the arrows drive the nudge.
/// F8 then saves the exact fractional position (the save no longer rounds to grid).
function scr_room_builder_nudge_update() {
    if (!global.debug_mode) return;
    if (room != Room1 && room != Room_ponte_vecchio && room != Room_duomo && room != Room_locanda_rosa_camuna) return;   // nudge in all built rooms
    if (variable_global_exists("input_locked") && global.input_locked) return;
    if (!variable_global_exists("room_builder_selected")) return;
    var _sel = global.room_builder_selected;
    if (!instance_exists(_sel)) return;

    // R = rotate 90° clockwise · Shift+R = 90° counter-clockwise (any selected prop).
    if (keyboard_check_pressed(ord("R"))) {
        if (!variable_instance_exists(_sel, "builder_angle")) _sel.builder_angle = 0;
        var _rd = keyboard_check(vk_shift) ? -90 : 90;
        _sel.builder_angle = ((_sel.builder_angle + _rd) mod 360 + 360) mod 360;
        if (variable_global_exists("save_indicator_text")) {
            global.save_indicator_text  = object_get_name(_sel.object_index) +
                " [" + string(_sel.builder_angle) + "°]  (F8 to save)";
            global.save_indicator_timer = 90;
        }
    }

    var _step = keyboard_check(vk_shift) ? 1 : 4;   // Shift = 1px ultra-fine
    var _nx = (keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left)) * _step;
    var _ny = (keyboard_check_pressed(vk_down)  - keyboard_check_pressed(vk_up))   * _step;
    if (_nx == 0 && _ny == 0) return;

    _sel.x += _nx;
    _sel.y += _ny;
    if (room == Room_duomo) scr_duomo_rebuild_collision(); if (room == Room_locanda_rosa_camuna) scr_inn_rebuild_collision();   // footprint follows the prop — no ghosts
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "Nudged " + object_get_name(_sel.object_index) +
            " -> " + string(_sel.x) + "," + string(_sel.y) + "  (F8 to save)";
        global.save_indicator_timer = 90;
    }
}


/// Draw a builder instance's sprite rotated by its builder_angle (CLOCKWISE degrees)
/// around the sprite CENTRE, so 90° turns stay put. image_angle stays 0, so the bbox
/// (click-pick + collision) is never disturbed. Objects call this from their Draw.
/// _tint is the blend colour (c_white normally).
function scr_room_builder_draw_rotated(_inst, _tint) {
    if (_inst.sprite_index == -1 || !sprite_exists(_inst.sprite_index)) return;
    var _ang = variable_instance_exists(_inst, "builder_angle") ? _inst.builder_angle : 0;
    if (_ang == 0) {
        draw_sprite_ext(_inst.sprite_index, _inst.image_index, _inst.x, _inst.y,
            _inst.image_xscale, _inst.image_yscale, 0, _tint, _inst.image_alpha);
        return;
    }
    var _w  = sprite_get_width(_inst.sprite_index)  * _inst.image_xscale;
    var _h  = sprite_get_height(_inst.sprite_index) * _inst.image_yscale;
    var _gm = -_ang;                                  // GM rotates CCW; builder_angle is CW
    var _a  = degtorad(_gm);
    var _cx = (_w * 0.5) * cos(_a) + (_h * 0.5) * sin(_a);
    var _cy = -(_w * 0.5) * sin(_a) + (_h * 0.5) * cos(_a);
    draw_sprite_ext(_inst.sprite_index, _inst.image_index,
        _inst.x + _w * 0.5 - _cx, _inst.y + _h * 0.5 - _cy,
        _inst.image_xscale, _inst.image_yscale, _gm, _tint, _inst.image_alpha);
}


// ── ROOM1 BUILD (props + all code-spawned collision) ────────────────────────────
/// Builds (or REBUILDS) everything Florence spawns in code: the market props (room
/// builder), the Arno river+bank collision, the bridge handrails, the Ponte Vecchio
/// entry zones (N/S split → bridge room), and the Giardino delle Rose hedge
/// collision. obj_game_manager is PERSISTENT so its Create runs only once; a room
/// change destroys all these instances, so obj_game_manager Step calls this again on
/// every Florence (re)entry — otherwise returning from the bridge room would leave Florence
/// with no props and no river collision. Reads the geometry globals (river_*,
/// garden_*) that obj_game_manager Create sets once.
function scr_room1_build() {
    if (room != Room1) return;

    // market props (+ their footprint collision, built inside the loader)
    scr_room_builder_load();

    // ── Duomo entrance (walk up + press E → Room_duomo) ────────────────────────
    // Spawned in CODE (not the saved layout, so no version bump / clobber) just
    // south of the Basilica exterior prop. Located off the exterior's live bbox so
    // it follows the prop if it's dragged; falls back to its default grid spot.
    var _dux = 1664, _duy = 960;
    for (var _di = 0; _di < array_length(global.room_builder_objects); _di++) {
        var _dp = global.room_builder_objects[_di];
        if (!instance_exists(_dp)) continue;
        if (_dp.sprite_index == spr_duomo_exterior) {
            _dux = (_dp.bbox_left + _dp.bbox_right) * 0.5;
            _duy = _dp.bbox_bottom + 48;     // just south of the doors
            break;
        }
    }
    var _de = instance_create_depth(_dux, _duy, 400, obj_duomo_entrance);

    // ── Arno river + bank collision ───────────────────────────────────────────
    // Solid water fills every gap BETWEEN the bridges (generic over any count). The
    // band reaches 22px onto each stone bank so the shore ROCKS are solid too.
    var _ry1 = global.river_y1;
    var _rh  = global.river_y2 - global.river_y1;
    var _ixl = 56;
    var _ixr = room_width - 56;
    var _segs = [];
    var _prev = _ixl;
    for (var _bi = 0; _bi < array_length(global.river_bridges); _bi++) {
        array_push(_segs, [_prev, global.river_bridges[_bi][0]]);
        _prev = global.river_bridges[_bi][1];
    }
    array_push(_segs, [_prev, _ixr]);
    for (var _s = 0; _s < array_length(_segs); _s++) {
        var _x0 = _segs[_s][0];
        var _x1 = _segs[_s][1];
        if (_x1 > _x0) {
            var _w = instance_create_depth(_x0, _ry1 - 22, 500, obj_wall);   // -22: north bank rocks
            _w.wall_w  = _x1 - _x0;
            _w.wall_h  = _rh + 44;                                           // +44: north + south banks
            _w.visible = false;
        }
    }

    // ── bridge handrail collision (down each crossing's edges) ────────────────
    var _bankh  = 22;
    var _rthick = sprite_get_height(spr_bridge_railing) * 0.5;   // 32px rail
    var _bdy0   = global.river_y1 - _bankh;                      // deck top
    var _bdy1   = global.river_y2 + _bankh;                      // deck bottom
    for (var _br = 0; _br < array_length(global.river_bridges); _br++) {
        var _rbx0 = global.river_bridges[_br][0];
        var _rbx1 = global.river_bridges[_br][1];
        var _wl = instance_create_depth(_rbx0, _bdy0, 500, obj_wall);
        _wl.wall_w = _rthick;  _wl.wall_h = _bdy1 - _bdy0;  _wl.visible = false;
        var _wr = instance_create_depth(_rbx1 - _rthick, _bdy0, 500, obj_wall);
        _wr.wall_w = _rthick;  _wr.wall_h = _bdy1 - _bdy0;  _wr.visible = false;
    }

    // ── Ponte Vecchio entry zones — N/S split decides the bridge-room landing ──
    var _pv      = global.river_bridges[0];
    var _pe_x    = _pv[0] + _rthick;
    var _pe_w    = (_pv[1] - _pv[0]) - _rthick * 2;
    var _deckmid = (_bdy0 + _bdy1) * 0.5;
    scr_transition_spawn("florence_ponte_n", _pe_x, _bdy0, _pe_w, _deckmid - _bdy0,
        "Room_ponte_vecchio", "Ponte Vecchio", 288, 200, "The Ponte Vecchio");
    scr_transition_spawn("florence_ponte_s", _pe_x, _deckmid, _pe_w, _bdy1 - _deckmid,
        "Room_ponte_vecchio", "Ponte Vecchio", 288, 700, "The Ponte Vecchio");

    // ── Giardino delle Rose hedge collision (four quadrants, open cross-path) ──
    var _gx0 = global.garden_cx - global.garden_hw, _gy0 = global.garden_cy - global.garden_hh;
    var _gx1 = global.garden_cx + global.garden_hw, _gy1 = global.garden_cy + global.garden_hh;
    var _gfx0 = _gx0 + global.garden_wt, _gfy0 = _gy0 + global.garden_wt;
    var _gfx1 = _gx1 - global.garden_wt, _gfy1 = _gy1 - global.garden_wt;
    var _gcphw = global.garden_cph;
    var _gqcx  = global.garden_cx, _gqcy = global.garden_cy;
    var _gquads = [
        [_gfx0,          _gfy0,          _gqcx - _gcphw, _gqcy - _gcphw],   // NW
        [_gqcx + _gcphw, _gfy0,          _gfx1,          _gqcy - _gcphw],   // NE
        [_gfx0,          _gqcy + _gcphw, _gqcx - _gcphw, _gfy1],            // SW
        [_gqcx + _gcphw, _gqcy + _gcphw, _gfx1,          _gfy1],            // SE
    ];
    for (var _gq = 0; _gq < 4; _gq++) {
        var _gw = instance_create_depth(_gquads[_gq][0], _gquads[_gq][1], 500, obj_wall);
        _gw.wall_w  = _gquads[_gq][2] - _gquads[_gq][0];
        _gw.wall_h  = _gquads[_gq][3] - _gquads[_gq][1];
        _gw.visible = false;
    }
}


// ── PONTE VECCHIO STATUES (draggable bridge guides) ─────────────────────────────
/// Build the bridge-room statues: load the player's saved/tweaked layout if present
/// (working_directory/room_ponte_vecchio_layout.txt), else the built-in default
/// corridor layout. Placed as draggable obj_mercato_prop, so the debug drag / nudge
/// (arrows) / Delete / F8-save all work in this room too. Solid footprints come from
/// scr_room_builder_build_collision(). Called from obj_ponte_scene Create.
function scr_ponte_statues_build() {
    if (room != Room_ponte_vecchio) return;
    // keep-alive: the statue sprites are placed by NAME, invisible to the stripper.
    global.__statue_keep = [spr_statue_david, spr_statue_madonna, spr_statue_lion, spr_statue_angel];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_ponte_vecchio_layout.txt";
    var _placed = file_exists(_path) ? scr_ponte_statues_load(_path) : 0;
    if (_placed == 0) scr_ponte_statues_default();

    scr_room_builder_build_collision();
}

/// Read a saved ponte statue layout (OBJECT GX GY SCALE SPRITE [solid]) and place it.
function scr_ponte_statues_load(_path) {
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
        var _obj = asset_get_index(_tok[0]);
        if (_obj < 0 || asset_get_type(_tok[0]) != asset_object) continue;
        var _inst = scr_ponte_place(_obj, real(_tok[1]), real(_tok[2]),
            (array_length(_tok) >= 4) ? real(_tok[3]) : 1,
            (array_length(_tok) >= 5) ? _tok[4] : "", _layer);
        if (_inst != noone) _n++;
    }
    file_text_close(_f);
    return _n;
}

/// Built-in default statue corridor — two columns flanking the walkway, organic y,
/// mixing the three variants (left x=1.5 -> px96, right x=6.5 -> px416). All solid.
/// Plus 2 SPARE statues parked at the top of the walkway for easy grab/delete.
function scr_ponte_statues_default() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _L = [
        // left column — all four variants, organic spacing
        [1.5,  1.75, "spr_statue_david"],   [1.5,  3.50, "spr_statue_angel"],
        [1.5,  5.10, "spr_statue_lion"],    [1.5,  6.80, "spr_statue_madonna"],
        [1.5,  8.35, "spr_statue_david"],   [1.5, 10.05, "spr_statue_angel"],
        [1.5, 11.70, "spr_statue_lion"],
        // right column — all four variants, organic spacing
        [6.5,  2.25, "spr_statue_lion"],    [6.5,  3.85, "spr_statue_madonna"],
        [6.5,  5.45, "spr_statue_angel"],   [6.5,  7.05, "spr_statue_david"],
        [6.5,  8.70, "spr_statue_lion"],    [6.5, 10.30, "spr_statue_angel"],
        [6.5, 11.60, "spr_statue_madonna"],
        // 2 SPARES parked in the walkway near the spawn (drag into place or Delete)
        [3.0, 4.0, "spr_statue_angel"],     [6.0, 4.0, "spr_statue_lion"],
    ];
    for (var _i = 0; _i < array_length(_L); _i++)
        scr_ponte_place(obj_mercato_prop, _L[_i][0], _L[_i][1], 1, _L[_i][2], _layer);
}

/// Place one ponte prop (obj_mercato_prop with a sprite) + register it for dragging.
function scr_ponte_place(_obj, _gx, _gy, _sc, _sprn, _layer) {
    var _px = _gx * ROOM_BUILDER_GRID, _py = _gy * ROOM_BUILDER_GRID;
    var _inst = (_layer != "")
        ? instance_create_layer(_px, _py, _layer, _obj)
        : instance_create_depth(_px, _py, 100, _obj);
    _inst.image_xscale = _sc;  _inst.image_yscale = _sc;
    _inst.room_builder_placed = true;
    _inst.builder_sprite = "";  _inst.builder_solid = false;
    if (_sprn != "") {
        var _sprid = asset_get_index(_sprn);
        if (_sprid >= 0 && asset_get_type(_sprn) == asset_sprite) {
            _inst.sprite_index   = _sprid;
            _inst.builder_sprite = _sprn;
        }
    }
    if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = true;
    array_push(global.room_builder_objects, _inst);
    return _inst;
}
