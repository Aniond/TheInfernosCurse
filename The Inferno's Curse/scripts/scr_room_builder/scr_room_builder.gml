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
#macro ROOM_BUILDER_LAYOUT_VERSION  6


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
    // Building grid_y — each is calculated so its BASE sits exactly at the street
    // edge (y=928). Formula: grid_y = (928 - sprite_h * scale) / 64
    //   obj_florence_building  (200px × 1.5 = 300px): (928-300)/64 = 9.8125
    //   obj_florence_tower     (320px × 1.5 = 480px): (928-480)/64 = 7.0
    //   obj_florence_cathedral (400px × 1.5 = 600px): (928-600)/64 = 5.125
    // X layout — 4 buildings across the 1936px interior (no overlap):
    //   Building  x=1  (px 64,  right 640)  → 64px gap
    //   Tower     x=11 (px 704, right 848)  → 112px gap
    //   Cathedral x=15 (px 960, right 1344) → 64px gap
    //   Building  x=22 (px 1408,right 1984) → 8px gap to east wall (1992)
    return
        "# VERSION 6\n" +
        "# Florence layout — buildings at 1.5×, bases 12px INTO cobblestone (anchored).\n" +
        "# Street centred at y928-1120; park y1120-1514; Arno y1536-1728.\n" +
        "# obj_florence_* SOLID. Format: OBJECT  GRID_X  GRID_Y  SCALE\n" +
        "\n" +
        "# --- 4 buildings lining the NORTH street edge, bases at y=940 (12px into street) ---\n" +
        "obj_florence_building    1    10.0     1.5\n" +
        "obj_florence_tower      11     7.1875  1.5\n" +
        "obj_florence_cathedral  15     5.3125  1.5\n" +
        "obj_florence_building   22    10.0     1.5\n" +
        "\n" +
        "# --- Market in the open PIAZZA (park zone, north half, grid y~18-20) ---\n" +
        "obj_well                16  20   1.0\n" +
        "obj_marco_stall         13  19   1.0\n" +
        "obj_cart                19  21   0.8\n" +
        "obj_barrel              11  19   0.5\n" +
        "obj_barrel              21  20   0.5\n" +
        "\n" +
        "# --- Cypress trees framing the park edges ---\n" +
        "obj_cypress_tree         3  18   1.0\n" +
        "obj_cypress_tree         3  22   1.0\n" +
        "obj_cypress_tree        28  18   1.0\n" +
        "obj_cypress_tree        28  22   1.0\n" +
        "\n" +
        "# --- Giardino delle Rose — formal parterre is DRAWN by obj_street_scene; ---\n" +
        "# --- only the fountain is a placed object, centred in the garden court.  ---\n" +
        "obj_garden_fountain     5.1875  19.828125  1.5\n" +
        "\n" +
        "# --- Wayside shrine on the south bank ---\n" +
        "obj_shrine              16  28   1.0\n";
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
        obj_garden_urn, obj_garden_cypress, obj_garden_tree_olive, obj_garden_tree_flowering];

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
        array_push(global.room_builder_objects, _inst);
        _placed++;
    }
    file_text_close(_f);

    show_debug_message("[room_builder] loaded " + string(_placed) + " placed, " +
        string(_skipped) + " skipped from " + _path);
    if (variable_global_exists("world_event_log"))
        scr_world_event_log("Room builder: " + string(_placed) + " placed, " + string(_skipped) + " skipped");
    return _placed;
}


// ── SAVE ───────────────────────────────────────────────────────────────────────
/// Writes every builder-placed instance back to the layout file (current grid
/// position + scale). Tries the project-tree path first, then the save folder.
function scr_room_builder_save() {
    var _path = working_directory + "room1_layout.txt";   // sandbox-safe save area
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

            var _name = object_get_name(_inst.object_index);
            var _gx   = round(_inst.x / ROOM_BUILDER_GRID);
            var _gy   = round(_inst.y / ROOM_BUILDER_GRID);
            var _sc   = _inst.image_xscale;

            var _line = scr_room_builder_pad(_name, 24) +
                        scr_room_builder_pad(string(_gx), 4) +
                        scr_room_builder_pad(string(_gy), 4) +
                        string(_sc);
            file_text_write_string(_f, _line);
            file_text_writeln(_f);
            _count++;
        }
    }
    file_text_close(_f);

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
    if (room != Room1) return;
    if (variable_global_exists("input_locked") && global.input_locked) return;
    if (!variable_global_exists("room_builder_objects")) return;
    if (!variable_global_exists("room_builder_drag")) global.room_builder_drag = noone;

    var _mx = mouse_x, _my = mouse_y;

    // begin drag — pick the last (topmost) builder instance under the cursor
    if (global.room_builder_drag == noone && mouse_check_button_pressed(mb_left)) {
        for (var _i = array_length(global.room_builder_objects) - 1; _i >= 0; _i--) {
            var _inst = global.room_builder_objects[_i];
            if (!instance_exists(_inst)) continue;
            if (scr_room_builder_point_in(_inst, _mx, _my)) {
                global.room_builder_drag    = _inst;
                global.room_builder_drag_dx = _inst.x - _mx;
                global.room_builder_drag_dy = _inst.y - _my;
                break;
            }
        }
    }

    // active drag
    if (global.room_builder_drag != noone) {
        if (!instance_exists(global.room_builder_drag)) { global.room_builder_drag = noone; return; }
        var _o = global.room_builder_drag;
        if (mouse_check_button(mb_left)) {
            _o.x = _mx + global.room_builder_drag_dx;     // follow cursor (smooth, unsnapped)
            _o.y = _my + global.room_builder_drag_dy;
        } else {
            // release -> snap to the 64px grid
            _o.x = round(_o.x / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
            _o.y = round(_o.y / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
            if (variable_global_exists("world_event_log"))
                scr_world_event_log(object_get_name(_o.object_index) + " moved -> grid " +
                    string(_o.x / ROOM_BUILDER_GRID) + "," + string(_o.y / ROOM_BUILDER_GRID) + "  (F8 to save)");
            global.room_builder_drag = noone;
        }
    }
}
