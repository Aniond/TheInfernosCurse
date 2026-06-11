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
#macro ROOM_BUILDER_LAYOUT_VERSION  12

// Per-room layout versions — the UNIVERSAL stale-layout guard. Every room's
// loader ignores a save-folder layout whose "# VERSION n" stamp doesn't match
// its macro and falls back to the code default, so a code relayout always
// reaches the player. F8 re-stamps the CURRENT version, so hand-tuned layouts
// persist until the next deliberate bump. BUMP a room's macro whenever you
// change that room's code-default layout. (Initial values match the stamps
// already in save folders, so existing hand-tuned layouts stay valid.)
#macro DUOMO_LAYOUT_VERSION   10
#macro INN_LAYOUT_VERSION     16
#macro PONTE_LAYOUT_VERSION   5
#macro STABLE_LAYOUT_VERSION  3
#macro FLORENCE_V2_LAYOUT_VERSION 9

/// The CURRENT room's layout schema version (Room_florence = ROOM_BUILDER_LAYOUT_VERSION).
function scr_room_builder_layout_version() {
    if (room == Room_duomo)               return DUOMO_LAYOUT_VERSION;
    if (room == Room_locanda_rosa_camuna) return INN_LAYOUT_VERSION;
    if (room == Room_fiorentine_stable)   return STABLE_LAYOUT_VERSION;
    if (room == Room_florence_v2)         return FLORENCE_V2_LAYOUT_VERSION;
    if (room_get_name(room) == "Room_ponte_vecchio") return PONTE_LAYOUT_VERSION;   // room archived 2026-06-10 (EW redo pending)
    return ROOM_BUILDER_LAYOUT_VERSION;
}

/// TRUE when a saved layout exists. CHANGED 2026-06-10 (David): the player's
/// F8 save ALWAYS WINS — a version mismatch no longer discards hand-dragged
/// work (that fight cost real progress). A stale stamp just raises an on-screen
/// notice; Shift+F8 resets to the new code defaults on demand. Loaders already
/// skip retired sprites/objects gracefully, so old saves can't crash a build.
function scr_room_builder_layout_current(_path) {
    if (!file_exists(_path)) return false;
    var _fv = scr_room_builder_file_version(_path);
    var _cv = scr_room_builder_layout_version();
    if (_fv != _cv && variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "YOUR F8 LAYOUT LOADED (v" + string(_fv)
            + "; defaults now v" + string(_cv) + ") — Shift+F8 resets to defaults";
        global.save_indicator_timer = 300;
    }
    return true;
}

/// Shift+F8 — RESET the current room's layout to the code defaults: deletes
/// the save-folder F8 file and restarts the room so the build re-seeds clean.
function scr_room_builder_reset_layout() {
    var _path = working_directory + "room1_layout.txt";
    if (room_get_name(room) == "Room_ponte_vecchio")  _path = working_directory + "room_ponte_vecchio_layout.txt";
    if (room == Room_duomo)               _path = working_directory + "room_duomo_layout.txt";
    if (room == Room_locanda_rosa_camuna) _path = working_directory + "room_locanda_rosa_camuna_layout.txt";
    if (room == Room_fiorentine_stable)   _path = working_directory + "room_fiorentine_stable_layout.txt";
    if (room == Room_florence_v2)         _path = working_directory + "room_florence_v2_layout.txt";
    if (file_exists(_path)) file_delete(_path);
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "LAYOUT RESET TO DEFAULTS";
        global.save_indicator_timer = 120;
    }
    room_restart();
}


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
// (room1 seed/default_text/loader DELETED 2026-06-10 with old Room_florence.)



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
/// The obj_wall footprint [x0,y0,x1,y1] that build_collision() lays under one
/// solid builder prop, or undefined (not solid / no sprite / empty bbox). Shared
/// by the collision builder AND the debug ORANGE footprint preview (scr_debug),
/// so what the preview shows is exactly what the player collides with.
function scr_room_builder_footprint(_o) {
    if (_o.sprite_index == -1 || !sprite_exists(_o.sprite_index)) return undefined;

    var _nm = (variable_instance_exists(_o, "builder_sprite") && _o.builder_sprite != "")
        ? _o.builder_sprite : sprite_get_name(_o.sprite_index);

    // trees collide at the trunk even when not flagged solid (obj_cypress_tree
    // props carry builder_solid=false); everything else still requires the flag
    var _is_tree = (string_pos("cypress", _nm) > 0 || string_pos("olive", _nm) > 0
                 || string_pos("tree", _nm) > 0);
    var _solid = variable_instance_exists(_o, "builder_solid") && _o.builder_solid;
    if (!_solid && !_is_tree) return undefined;

    // on-screen extent (Full-Image bbox == the displayed sprite rectangle)
    var _L = _o.bbox_left, _T = _o.bbox_top, _R = _o.bbox_right, _B = _o.bbox_bottom;
    var _bw = _R - _L, _bh = _B - _T;
    if (_bw <= 0 || _bh <= 0) return undefined;

    // ── BOTTOM-ONLY COLLISION RULE (David, permanent — see CLAUDE.md) ──────────
    // Tall sprites block only at their base: players walk under canopies,
    // through arch openings, beneath overhangs. The world reads 3D.
    var _x0f, _y0f, _x1f, _y1f;
    if (string_pos("stall", _nm) > 0 || string_pos("awning", _nm) > 0) {
        return undefined;                          // market awnings: NO collision
    } else if (string_pos("arch", _nm) > 0) {
        return undefined;                          // arch columns spawn in the caller
    } else if (_is_tree) {
        _x0f = 0.36; _y0f = 0.80; _x1f = 0.64; _y1f = 0.96;   // trunk only (bottom 20%)
    } else if (string_pos("duomo_exterior", _nm) > 0) {
        // THE DUOMO (David directive 2026-06-10): invisible boundary spanning
        // the cathedral's width, bottom 25% solid / top 75% walkable — the
        // player can never walk through the building itself.
        _x0f = 0.10; _y0f = 0.75; _x1f = 0.90; _y1f = 0.95;
    } else if (string_pos("fountain", _nm) > 0) {
        _x0f = 0.18; _y0f = 0.24; _x1f = 0.82; _y1f = 0.90;   // squat basin — full
    } else if (string_pos("building", _nm) > 0 || string_pos("loggia", _nm) > 0
            || string_pos("inn", _nm) > 0 || string_pos("church", _nm) > 0
            || string_pos("stable", _nm) > 0 || string_pos("cathedral", _nm) > 0
            || string_pos("tower", _nm) > 0 || string_pos("house", _nm) > 0
            || string_pos("duomo", _nm) > 0 || string_pos("basilica", _nm) > 0
            || string_pos("residence", _nm) > 0 || string_pos("row_block", _nm) > 0
            || string_pos("cottage", _nm) > 0 || string_pos("palazzo", _nm) > 0
            || string_pos("guild", _nm) > 0 || string_pos("shop", _nm) > 0
            || string_pos("forge", _nm) > 0 || string_pos("apothecary", _nm) > 0
            || string_pos("campanile", _nm) > 0 || string_pos("locanda", _nm) > 0) {
        if (_bh > 128) { _x0f = 0.18; _y0f = 0.84; _x1f = 0.82; _y1f = 0.94; }   // tall: doorstep band (~10%)
        else           { _x0f = 0.18; _y0f = 0.78; _x1f = 0.82; _y1f = 0.94; }   // one-cell: bottom ~16%
    } else {
        // small ground prop (urn, pot, statue, crate, sack, cloth…)
        _x0f = 0.22; _y0f = 0.50; _x1f = 0.78; _y1f = 0.92;
    }

    return [_L + _bw * _x0f, _T + _bh * _y0f, _L + _bw * _x1f, _T + _bh * _y1f];
}

/// Rebuild whichever collision set the CURRENT room uses, so footprints always
/// follow their props after any edit (move / scale / rotate / duplicate / delete
/// / undo). Previously only the Duomo + inn rebuilt — Room_florence / Ponte footprints
/// stayed at the prop's ORIGINAL spot until restart (the invisible-wall bug).
function scr_room_builder_refresh_collision() {
    if (room == Room_duomo)               { scr_duomo_rebuild_collision();  return; }
    if (room == Room_locanda_rosa_camuna) { scr_inn_rebuild_collision();    return; }
    if (room == Room_fiorentine_stable)   { scr_stable_rebuild_collision(); return; }
    if (room == Room_florence_v2)         { scr_fv2_rebuild_collision();    return; }
    if (room_get_name(room) == "Room_ponte_vecchio") { scr_ponte_rebuild_collision(); return; }
    scr_room_builder_build_collision();
}

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
        if (_o.sprite_index == -1 || !sprite_exists(_o.sprite_index)) continue;

        // ARCHES: base columns only — the opening stays walkable (David's
        // bottom-only rule). Two thin walls at the pillar feet, nothing between.
        var _anm = (variable_instance_exists(_o, "builder_sprite") && _o.builder_sprite != "")
            ? _o.builder_sprite : sprite_get_name(_o.sprite_index);
        if (string_pos("arch", _anm) > 0) {
            var _aL = _o.bbox_left, _aT = _o.bbox_top, _aR = _o.bbox_right, _aB = _o.bbox_bottom;
            var _acw = (_aR - _aL) * 0.20;
            var _acy = _aT + (_aB - _aT) * 0.55;
            var _wl2 = instance_create_depth(_aL, _acy, 500, obj_wall);
            _wl2.wall_w = _acw; _wl2.wall_h = _aB - _acy; _wl2.visible = false;
            array_push(global.__room_builder_collision, _wl2);
            var _wr2 = instance_create_depth(_aR - _acw, _acy, 500, obj_wall);
            _wr2.wall_w = _acw; _wr2.wall_h = _aB - _acy; _wr2.visible = false;
            array_push(global.__room_builder_collision, _wr2);
            _made += 2;
            continue;
        }

        // footprint geometry shared with the debug preview — see scr_room_builder_footprint
        // (gating — solid flag, tree trunks, awning exemption — lives in there)
        var _fp = scr_room_builder_footprint(_o);
        if (is_undefined(_fp)) continue;

        var _w = instance_create_depth(_fp[0], _fp[1], 500, obj_wall);
        _w.wall_w  = _fp[2] - _fp[0];
        _w.wall_h  = _fp[3] - _fp[1];
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
    if (room_get_name(room) == "Room_ponte_vecchio")  _path = working_directory + "room_ponte_vecchio_layout.txt";
    if (room == Room_duomo)          _path = working_directory + "room_duomo_layout.txt";
    if (room == Room_locanda_rosa_camuna) _path = working_directory + "room_locanda_rosa_camuna_layout.txt";
    if (room == Room_fiorentine_stable)   _path = working_directory + "room_fiorentine_stable_layout.txt";
    if (room == Room_florence_v2)         _path = working_directory + "room_florence_v2_layout.txt";
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

    // Stamp the CURRENT room's version so the stale-layout guard
    // (scr_room_builder_layout_current / seed_if_needed) treats this hand-saved
    // layout as current and never clobbers it — until the room's macro is bumped.
    file_text_write_string(_f, "# VERSION " + string(scr_room_builder_layout_version()));
    file_text_writeln(_f);
    file_text_write_string(_f, "# Room layout — OBJECT_NAME  GRID_X  GRID_Y  SCALE   (1 cell = 64 px)");
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
    if (room != Room_duomo && room != Room_locanda_rosa_camuna && room != Room_fiorentine_stable && room != Room_florence_v2 && room != Room_ponte_vecchio) return;   // draggable in all built rooms
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
                scr_room_builder_undo_push({act:"move", inst:_o,
                    px:global.room_builder_drag_ox, py:global.room_builder_drag_oy});
                _o.x = round(_o.x / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
                _o.y = round(_o.y / ROOM_BUILDER_GRID) * ROOM_BUILDER_GRID;
                if (variable_global_exists("world_event_log"))
                    scr_world_event_log(object_get_name(_o.object_index) + " moved -> grid " +
                        string(_o.x / ROOM_BUILDER_GRID) + "," + string(_o.y / ROOM_BUILDER_GRID) + "  (F8 to save)");
            }
            scr_room_builder_refresh_collision();   // footprint follows the prop — no ghosts
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

    // Record everything needed to recreate it, so Ctrl+Z can bring it back.
    scr_room_builder_undo_push({act:"delete", obj:_sel.object_index,
        px:_sel.x, py:_sel.y, sc:_sel.image_xscale,
        spr:   variable_instance_exists(_sel, "builder_sprite") ? _sel.builder_sprite : "",
        solid: variable_instance_exists(_sel, "builder_solid") && _sel.builder_solid,
        ang:   variable_instance_exists(_sel, "builder_angle") ? _sel.builder_angle : 0});

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
    scr_room_builder_refresh_collision();   // drop the deleted prop's footprint

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
    if (room != Room_duomo && room != Room_locanda_rosa_camuna && room != Room_fiorentine_stable && room != Room_florence_v2 && room != Room_ponte_vecchio) return;   // nudge in all built rooms
    if (variable_global_exists("input_locked") && global.input_locked) return;
    if (!variable_global_exists("room_builder_selected")) return;
    var _sel = global.room_builder_selected;
    if (!instance_exists(_sel)) return;

    // R = rotate 90° clockwise · Shift+R = 90° counter-clockwise (any selected prop).
    // , / . = FINE rotate 5° counter-clockwise / clockwise (VK_OEM_COMMA/PERIOD —
    // ord(",") would be the ASCII code, not the Windows VK code these keys send).
    // NOTE: only props drawn via scr_room_builder_draw_rotated show it (mercato
    // props, duomo statues/pews); other objects keep their own Draw, and the
    // collision footprint stays axis-aligned either way.
    var _rd = 0;
    if (keyboard_check_pressed(ord("R"))) _rd = keyboard_check(vk_shift) ? -90 : 90;
    _rd += (keyboard_check_pressed(190) - keyboard_check_pressed(188)) * 5;   // . / ,
    if (_rd != 0) {
        if (!variable_instance_exists(_sel, "builder_angle")) _sel.builder_angle = 0;
        scr_room_builder_undo_push({act:"rotate", inst:_sel, ang:_sel.builder_angle});
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

    scr_room_builder_undo_push({act:"move", inst:_sel, px:_sel.x, py:_sel.y});
    _sel.x += _nx;
    _sel.y += _ny;
    scr_room_builder_refresh_collision();   // footprint follows the prop — no ghosts
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "Nudged " + object_get_name(_sel.object_index) +
            " -> " + string(_sel.x) + "," + string(_sel.y) + "  (F8 to save)";
        global.save_indicator_timer = 90;
    }
}


// ── EDIT-MODE EXTRAS — undo (Ctrl+Z) · duplicate (Ctrl+D) · scale ([ / ]) ───────

/// Push one undoable action (stack capped at 40 — oldest dropped). Action structs:
///   {act:"move",   inst, px, py}                       restore a pre-move position
///   {act:"scale",  inst, sc}                           restore a pre-scale value
///   {act:"rotate", inst, ang}                          restore a pre-rotate angle
///   {act:"create", inst}                               destroy (undoes Ctrl+D)
///   {act:"delete", obj, px, py, sc, spr, solid, ang}   recreate a deleted prop
function scr_room_builder_undo_push(_a) {
    if (!variable_global_exists("room_builder_undo")) global.room_builder_undo = [];
    array_push(global.room_builder_undo, _a);
    if (array_length(global.room_builder_undo) > 40) array_delete(global.room_builder_undo, 0, 1);
}

/// Ctrl+Z — revert the most recent edit. Stale instance refs (prop destroyed by a
/// room change / reload) are skipped until a still-valid action is found.
function scr_room_builder_undo() {
    if (!variable_global_exists("room_builder_undo")) global.room_builder_undo = [];
    while (array_length(global.room_builder_undo) > 0) {
        var _a   = array_pop(global.room_builder_undo);
        var _msg = "";

        if (_a.act == "delete") {
            // recreate exactly as the loader would, re-list, reselect, re-save
            // (delete persisted the layout, so its undo must persist too)
            var _layer = layer_exists("Instances") ? "Instances" : "";
            var _r = (_layer != "")
                ? instance_create_layer(_a.px, _a.py, _layer, _a.obj)
                : instance_create_depth(_a.px, _a.py, 100, _a.obj);
            _r.image_xscale = _a.sc;  _r.image_yscale = _a.sc;
            _r.room_builder_placed = true;
            _r.builder_sprite = _a.spr;
            _r.builder_solid  = _a.solid;
            _r.builder_angle  = _a.ang;
            if (_a.spr != "") {
                var _si = asset_get_index(_a.spr);
                if (_si >= 0 && asset_get_type(_a.spr) == asset_sprite) _r.sprite_index = _si;
            }
            if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
            array_push(global.room_builder_objects, _r);
            global.room_builder_selected = _r;
            scr_room_builder_save();
            _msg = "UNDO delete — " + object_get_name(_a.obj) + " restored";
        } else {
            if (!instance_exists(_a.inst)) continue;   // stale ref — try the next action
            if (_a.act == "move") {
                _a.inst.x = _a.px;  _a.inst.y = _a.py;
                _msg = "UNDO move — " + object_get_name(_a.inst.object_index);
            } else if (_a.act == "scale") {
                _a.inst.image_xscale = _a.sc;  _a.inst.image_yscale = _a.sc;
                _msg = "UNDO scale -> " + string(_a.sc);
            } else if (_a.act == "rotate") {
                _a.inst.builder_angle = _a.ang;
                _msg = "UNDO rotate -> " + string(_a.ang) + "°";
            } else if (_a.act == "create") {
                if (variable_global_exists("room_builder_objects")) {
                    for (var _i = array_length(global.room_builder_objects) - 1; _i >= 0; _i--)
                        if (global.room_builder_objects[_i] == _a.inst)
                            array_delete(global.room_builder_objects, _i, 1);
                }
                if (variable_global_exists("room_builder_selected") && global.room_builder_selected == _a.inst)
                    global.room_builder_selected = noone;
                _msg = "UNDO duplicate — " + object_get_name(_a.inst.object_index) + " removed";
                instance_destroy(_a.inst);
            } else continue;                            // unknown action — skip
        }

        scr_room_builder_refresh_collision();
        if (variable_global_exists("save_indicator_text")) {
            global.save_indicator_text  = _msg + "  (F8 to save)";
            global.save_indicator_timer = 120;
        }
        if (variable_global_exists("world_event_log")) scr_world_event_log(_msg);
        return true;
    }
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = "NOTHING TO UNDO";
        global.save_indicator_timer = 90;
    }
    return false;
}

/// Ctrl+D — clone the selected prop one cell to the right (same sprite / scale /
/// angle / solid) and select the CLONE, so it can be dragged straight into place.
function scr_room_builder_duplicate_selected() {
    if (!variable_global_exists("room_builder_selected")) return false;
    var _sel = global.room_builder_selected;
    if (!instance_exists(_sel)) return false;
    if (_sel.object_index == obj_mercato_exit) return false;   // transitions aren't cloneable
    if (_sel.object_index == obj_wall)         return false;

    var _layer = layer_exists("Instances") ? "Instances" : "";
    var _c = (_layer != "")
        ? instance_create_layer(_sel.x + ROOM_BUILDER_GRID, _sel.y, _layer, _sel.object_index)
        : instance_create_depth(_sel.x + ROOM_BUILDER_GRID, _sel.y, 100, _sel.object_index);
    _c.image_xscale = _sel.image_xscale;
    _c.image_yscale = _sel.image_yscale;
    _c.room_builder_placed = true;
    _c.builder_sprite = variable_instance_exists(_sel, "builder_sprite") ? _sel.builder_sprite : "";
    _c.builder_solid  = variable_instance_exists(_sel, "builder_solid")  ? _sel.builder_solid  : false;
    _c.builder_angle  = variable_instance_exists(_sel, "builder_angle")  ? _sel.builder_angle  : 0;
    if (_sel.sprite_index != -1) _c.sprite_index = _sel.sprite_index;

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    array_push(global.room_builder_objects, _c);
    global.room_builder_selected = _c;

    scr_room_builder_undo_push({act:"create", inst:_c});
    scr_room_builder_refresh_collision();

    var _msg = "Duplicated " + object_get_name(_c.object_index) + " -> grid " +
        string(_c.x / ROOM_BUILDER_GRID) + "," + string(_c.y / ROOM_BUILDER_GRID);
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = _msg + "  (F8 to save)";
        global.save_indicator_timer = 120;
    }
    if (variable_global_exists("world_event_log")) scr_world_event_log(_msg);
    return true;
}

/// Debug-mode editor chords, called every step from obj_game_manager:
///   Ctrl+Z = undo · Ctrl+D = duplicate · [ / ] = scale selected prop down/up
///   (0.05 per tap; Shift = 0.01 fine). Player WASD is suppressed while Ctrl is
///   held (obj_player Step) so chords never also walk Benedetto.
function scr_room_builder_edit_update() {
    if (!global.debug_mode) return;
    if (room != Room_duomo && room != Room_locanda_rosa_camuna && room != Room_fiorentine_stable && room != Room_florence_v2 && room != Room_ponte_vecchio) return;
    if (variable_global_exists("input_locked") && global.input_locked) return;

    var _ctrl = keyboard_check(vk_control);
    if (_ctrl && keyboard_check_pressed(ord("Z"))) { scr_room_builder_undo();               return; }
    if (_ctrl && keyboard_check_pressed(ord("D"))) { scr_room_builder_duplicate_selected(); return; }

    // [ / ] — scale the selected prop (Windows VK_OEM_4 = 219 '[', VK_OEM_6 = 221 ']')
    if (!variable_global_exists("room_builder_selected")) return;
    var _sel = global.room_builder_selected;
    if (!instance_exists(_sel)) return;
    if (_sel.object_index == obj_mercato_exit) return;   // zones have no scale
    var _ds = (keyboard_check_pressed(221) - keyboard_check_pressed(219))
            * (keyboard_check(vk_shift) ? 0.01 : 0.05);
    if (_ds == 0) return;

    scr_room_builder_undo_push({act:"scale", inst:_sel, sc:_sel.image_xscale});
    var _ns = clamp(_sel.image_xscale + _ds, 0.1, 3.0);
    _sel.image_xscale = _ns;
    _sel.image_yscale = _ns;
    scr_room_builder_refresh_collision();   // footprint follows the new size
    if (variable_global_exists("save_indicator_text")) {
        global.save_indicator_text  = object_get_name(_sel.object_index) +
            " scale " + string(_ns) + "  (F8 to save)";
        global.save_indicator_timer = 90;
    }
}


/// Draw a builder instance's sprite rotated by its builder_angle (CLOCKWISE degrees)
/// around the sprite CENTRE, so 90° turns stay put. image_angle stays 0, so the bbox
/// (click-pick + collision) is never disturbed. Objects call this from their Draw.
/// _tint is the blend colour (c_white normally).
function scr_room_builder_draw_rotated(_inst, _tint) {
    if (_inst.sprite_index == -1 || !sprite_exists(_inst.sprite_index)) {
        // A name-assigned sprite failed to resolve (not imported / stripped /
        // stale GM session). Invisible props are undebuggable — in debug mode
        // (F1) draw a MAGENTA marker so "missing" is visible instead of silent.
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            draw_set_color(c_fuchsia);
            draw_rectangle(_inst.x, _inst.y, _inst.x + 48, _inst.y + 48, true);
            draw_line(_inst.x, _inst.y, _inst.x + 48, _inst.y + 48);
            draw_line(_inst.x + 48, _inst.y, _inst.x, _inst.y + 48);
            draw_set_halign(fa_left); draw_set_valign(fa_bottom);
            draw_text(_inst.x, _inst.y - 2, variable_instance_exists(_inst, "builder_sprite")
                ? string(_inst.builder_sprite) : "(no sprite)");
            draw_set_valign(fa_top);
            draw_set_color(c_white);
        }
        return;
    }
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
// (scr_florence_build + the v1 city geometry DELETED 2026-06-10 with old
//  Room_florence - recoverable at git tag pre-wipe-old-florence.)



// =============================================================================
// PONTE VECCHIO — the marketplace bridge (REBUILT 2026-06-10)
// Reference: references/ponte_vecchio_interior_map.png — "Cuore del Commercio
// Fiorentino". 1280x896 (20x14 cells), EW crossing. Not a corridor with shops:
// a marketplace suspended over the Arno.
//   water N  y0-192 · shops N y192-288 · WALKWAY y288-576 (plaza mid-bridge)
//   shops S y576-672 · water S y672-896 (the arches live here)
// =============================================================================

/// Parapet bands — VOID WALL + ART standard, single source for draw AND
/// collision. They run behind both shop rows and seal the deck from the water.
/// NARROW BRIDGE (1280x512, 20x8): water 0-64 · shops N 64-160 · WALKWAY
/// 160-352 · shops S 352-448 · water 448-512. Claustrophobic, like the real one.
function scr_ponte_walls() {
    return [
        [0, 40,  1280, 64],      // north parapet (water edge, behind the shops)
        [0, 448, 1280, 472],     // south parapet (between shops and the water)
    ];
}

/// Geometry collision + exits — called by build AND the debug rebuild.
function scr_ponte_spawn_geometry() {
    var _solids = scr_ponte_walls();
    array_push(_solids, [0, 0, 1280, 40]);           // north water (sealed)
    array_push(_solids, [0, 472, 1280, 512]);        // south water (sealed)
    array_push(_solids, [0, 0, 8, 160]);             // west edge above walkway
    array_push(_solids, [0, 352, 8, 512]);           // west edge below walkway
    array_push(_solids, [1272, 0, 1280, 160]);       // east edge above walkway
    array_push(_solids, [1272, 352, 1280, 512]);     // east edge below walkway
    for (var _w = 0; _w < array_length(_solids); _w++) {
        var _s = _solids[_w];
        var _wl = instance_create_depth(_s[0], _s[1], 500, obj_wall);
        _wl.wall_w = _s[2] - _s[0]; _wl.wall_h = _s[3] - _s[1]; _wl.visible = false;
    }
    // WEST: back to Florence — arrive on the v2 west bank beside the deck
    scr_transition_spawn("ponte_w", 0, 160, 28, 192,
        "Room_florence_v2", "Firenze", 2486, 704, "Firenze");
    // EAST: Santa Croce — not built yet (graceful coming-soon)
    scr_transition_spawn("ponte_e", 1252, 160, 28, 192,
        "Room_santa_croce", "Verso il Quartiere di Santa Croce. Not yet.", 0, 0, "");
}

// TEMP debug boot: flip true to launch straight onto the Ponte Vecchio for
// testing (mirrors STABLE/INN/DUOMO_LOAD_POINT). obj_game_manager Create reads
// it. Flip back to false for the normal Florence start.
#macro PONTE_LOAD_POINT false

/// Build the bridge marketplace: David's F8 layout if present (SOURCE OF
/// TRUTH), else the reference default. Called from obj_ponte_scene Create.
function scr_ponte_build() {
    if (room_get_name(room) != "Room_ponte_vecchio") return;
    // keep-alive: name-placed assets are invisible to the stripper
    global.__ponte_keep     = [obj_mercato_prop, obj_npc_marco];
    global.__ponte_keep_spr = [spr_ponte_floor_cobble, spr_ponte_shop_north,
        spr_ponte_shop_south, spr_ponte_fountain, spr_ponte_guild_board,
        spr_ponte_lantern_post, spr_ponte_seagull, spr_arno_rowing_boat,
        spr_florence_water, spr_florence_thin_wall, spr_ponte_roof_tile,
        spr_ponte_bench, spr_inn_plant,
        spr_ponte_floor_normal, spr_ponte_floor_pietra, spr_ponte_border_serena,
        spr_ponte_canopy];

    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    for (var _i = 0; _i < array_length(global.room_builder_objects); _i++)
        if (instance_exists(global.room_builder_objects[_i])) instance_destroy(global.room_builder_objects[_i]);
    global.room_builder_objects = [];

    var _path   = working_directory + "room_ponte_vecchio_layout.txt";
    var _placed = scr_room_builder_layout_current(_path) ? scr_ponte_load(_path) : 0;
    if (_placed == 0) scr_ponte_default();

    scr_ponte_spawn_geometry();
    scr_room_builder_build_collision();
}

/// Debug rebuild after drag/nudge/delete — walls + transitions + footprints.
function scr_ponte_rebuild_collision() {
    if (room_get_name(room) != "Room_ponte_vecchio") return;
    with (obj_wall) instance_destroy();
    with (obj_mercato_exit) instance_destroy();
    scr_ponte_spawn_geometry();
    scr_room_builder_build_collision();
}

/// Read a saved ponte layout (OBJECT GX GY SCALE [SPRITE] [solid]).
function scr_ponte_load(_path) {
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
        var _solid = false;
        for (var _k = 4; _k < array_length(_tok); _k++) if (_tok[_k] == "solid") _solid = true;
        var _inst = scr_ponte_place(_obj, real(_tok[1]), real(_tok[2]),
            (array_length(_tok) >= 4) ? real(_tok[3]) : 1,
            (array_length(_tok) >= 5) ? _tok[4] : "", _solid, _layer);
        if (_inst != noone) _n++;
    }
    file_text_close(_f);
    return _n;
}

/// Reference default — 12 trades (3+3 per row, the centre break holds the
/// plaza), fountain + guild board mid-bridge, lantern posts every 3 cells,
/// seagulls on the parapets, and Marco the Baker at the Fornaio.
function scr_ponte_default() {
    var _layer = layer_exists("Instances") ? "Instances" : "";
    // COVERED MERCHANT BRIDGE (David's design): tightly packed shops dominate —
    // 8 per row at near-touching pitch, two covered runs with the central
    // plaza OPEN to the sky (the Arno viewing point). Canopy segments over the
    // corridor are drawn by the scene's Draw End pass.
    // NARROW BRIDGE (20x8): shops N gy1.0 (band 64-160), walkway 160-352,
    // shops S gy5.5 (band 352-448) — pressed tight, corridor 3 cells.
    var _sx = [1.4, 3.2, 5.0, 6.8,   12.0, 13.8, 15.6, 17.4];
    for (var _i = 0; _i < 8; _i++)
        scr_ponte_place(obj_mercato_prop, _sx[_i], 1.0, 1, "spr_ponte_shop_north", true, _layer);
    for (var _j = 0; _j < 8; _j++)
        scr_ponte_place(obj_mercato_prop, _sx[_j], 5.5, 0.9, "spr_ponte_shop_south", true, _layer);   // scaled to match the north row
    // CENTRAL MEETING PLACE (David, from the real bridge's mid-span terrace):
    // fountain at the heart, guild board east, marble benches ringing the
    // piazza with walk-through gaps, greenery at the corners
    scr_ponte_place(obj_mercato_prop, 9.0,  3.05, 1, "spr_ponte_fountain",    true,  _layer);
    scr_ponte_place(obj_mercato_prop, 11.4, 3.35, 1, "spr_ponte_guild_board", true,  _layer);
    // benches against the shop bands (David's F8 arrangement, synced 2026-06-10)
    scr_ponte_place(obj_mercato_prop, 9.0,    1.0,   1, "spr_ponte_bench",     true,  _layer);
    scr_ponte_place(obj_mercato_prop, 10.4375, 0.9875, 1, "spr_ponte_bench",   true,  _layer);
    scr_ponte_place(obj_mercato_prop, 8.6,    6.7,   1, "spr_ponte_bench",     true,  _layer);
    scr_ponte_place(obj_mercato_prop, 10.1875, 6.6875, 1, "spr_ponte_bench",   true,  _layer);
    scr_ponte_place(obj_mercato_prop, 8.05, 3.7,  1, "spr_inn_plant",         false, _layer);
    scr_ponte_place(obj_mercato_prop, 10.55, 3.9, 1, "spr_inn_plant",         false, _layer);
    // lantern posts along both walkway edges (under the canopy they ARE the light)
    var _lx = [2, 5, 8, 12, 15, 17.9];
    for (var _l = 0; _l < array_length(_lx); _l++) {
        scr_ponte_place(obj_mercato_prop, _lx[_l], 1.66, 1, "spr_ponte_lantern_post", false, _layer);
        scr_ponte_place(obj_mercato_prop, _lx[_l], 3.97, 1, "spr_ponte_lantern_post", false, _layer);
    }
    // seagulls on the parapets at the OPEN-air spots: plaza + both landings
    var _gull = [[9.7,0.55],[10.6,6.95],[0.7,0.55],[19.1,0.6],[0.8,6.9]];
    for (var _g = 0; _g < array_length(_gull); _g++)
        scr_ponte_place(obj_mercato_prop, _gull[_g][0], _gull[_g][1], 1, "spr_ponte_seagull", false, _layer);
    // MARCO THE BAKER at the Fornaio (2nd from west, north row) — full live
    // NPC: E to talk, Claude-driven dialogue, corruption arc (wired 2026-06-10)
    scr_ponte_place(obj_npc_marco, 3.9, 2.3, 1, "", false, _layer);
}

/// Place one ponte prop + register it for dragging. Solid only when flagged.
function scr_ponte_place(_obj, _gx, _gy, _sc, _sprn, _solid, _layer) {
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
    if (_inst.object_index == obj_mercato_prop) _inst.builder_solid = _solid;
    _inst.depth = -_inst.bbox_bottom;   // GLOBAL DEPTH RULE: layered by feet from frame 0
    array_push(global.room_builder_objects, _inst);
    return _inst;
}

/// Corruption states for the marketplace — called every frame from scene Draw.
///   0-49 alive · 50-74 some shops closed, fewer gulls · 75-99 most closed,
///   no gulls, fountain wrong · 100 all closed, fountain stopped + chronicle.
function scr_ponte_corruption_sync() {
    if (room_get_name(room) != "Room_ponte_vecchio") return;
    if (!variable_global_exists("room_builder_objects")) return;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    var _objs = global.room_builder_objects;
    var _si = 0; var _gi = 0;
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];
        if (!instance_exists(_o)) continue;
        if (!variable_instance_exists(_o, "builder_sprite")) continue;
        var _s = _o.builder_sprite;
        if (string_pos("spr_ponte_shop", _s) == 1) {
            _si++;
            var _closed = false;
            if (_corr >= 100)     _closed = true;                      // all closed
            else if (_corr >= 75) _closed = ((_si mod 4) != 0);        // most closed
            else if (_corr >= 50) _closed = ((_si mod 3) == 0);        // some closed
            _o.image_blend = _closed ? make_color_rgb(118, 108, 104) : c_white;
        } else if (_s == "spr_ponte_seagull") {
            _gi++;
            if (_corr >= 75)      _o.visible = false;                  // no gulls
            else if (_corr >= 50) _o.visible = ((_gi mod 2) == 1);     // fewer
            else                  _o.visible = true;
        } else if (_s == "spr_ponte_fountain") {
            if (_corr >= 100)     _o.image_blend = make_color_rgb(120, 120, 124); // stopped, grey
            else if (_corr >= 75) _o.image_blend = make_color_rgb(150, 124, 168); // wrong colour
            else if (_corr >= 50) _o.image_blend = make_color_rgb(200, 190, 196); // slightly dark
            else                  _o.image_blend = c_white;
        }
    }
    if (_corr >= 100 && !variable_global_exists("ponte_quiet_noted")) {
        global.ponte_quiet_noted = true;
        scr_chronicle_add("The bridge is quiet. It was never quiet before. I cannot remember when it changed.");
    }
}

/// Lantern light colour for the bridge floor shader — time of day blended
/// across hour boundaries, then bent by corruption. (shd_ponte_floor POC)
///   Dawn 5-8 #FF9B3D · Day 8-17 #FFF5E0 · Dusk 17-21 #FF7B1D · Night #3D5080
///   50%+ slightly sickly · 75%+ clearly wrong · 100% surviving lights GREEN
function scr_ponte_light_color() {
    var _h = variable_global_exists("time_of_day") ? global.time_of_day
           : (variable_global_exists("game_hour") ? global.game_hour : 12);
    var _dawn  = make_color_rgb(0xFF, 0x9B, 0x3D);
    var _day   = make_color_rgb(0xFF, 0xF5, 0xE0);
    var _dusk  = make_color_rgb(0xFF, 0x7B, 0x1D);
    var _night = make_color_rgb(0x3D, 0x50, 0x80);
    var _c;
    if      (_h <  4)  _c = _night;
    else if (_h <  5)  _c = merge_color(_night, _dawn, _h - 4);          // night→dawn
    else if (_h <  8)  _c = _dawn;
    else if (_h <  9)  _c = merge_color(_dawn,  _day,  _h - 8);          // dawn→day
    else if (_h < 17)  _c = _day;
    else if (_h < 18)  _c = merge_color(_day,   _dusk, _h - 17);         // day→dusk
    else if (_h < 21)  _c = _dusk;
    else if (_h < 22)  _c = merge_color(_dusk,  _night, _h - 21);        // dusk→night
    else               _c = _night;
    // corruption bends the light
    var _corr = clamp(global.circle_corruption[CIRCLE_LIMBO], 0, 100);
    var _green = make_color_rgb(0x1A, 0x4A, 0x0A);
    if      (_corr >= 100) _c = _green;                                          // survivors burn green
    else if (_corr >= 75)  _c = merge_color(_c, make_color_rgb(0x50, 0x6B, 0x14), 0.55); // clearly wrong
    else if (_corr >= 50)  _c = merge_color(_c, make_color_rgb(0x8F, 0xA0, 0x60), 0.30); // slightly sickly
    return _c;
}

/// Ambient floor for the bridge shader — bright by day (lanterns barely
/// matter), dark blue at night (lantern pools carry the scene), dimmed by
/// corruption so the Forgotten bridge sits near-black between lights.
function scr_ponte_ambient_color() {
    var _h = variable_global_exists("time_of_day") ? global.time_of_day
           : (variable_global_exists("game_hour") ? global.game_hour : 12);
    // NOTE: the GLOBAL light map (scr_lightmap, 2026-06-10) multiplies the
    // whole frame with room darkness — this shader ambient stays bright and
    // carries only the floor RELIEF + lantern pools, or night would darken
    // the walkway twice.
    var _day_amb   = make_color_rgb(236, 230, 218);
    var _night_amb = make_color_rgb(168, 170, 184);
    var _a;
    if      (_h < 5)   _a = _night_amb;
    else if (_h < 8)   _a = merge_color(_night_amb, _day_amb, (_h - 5) / 3);
    else if (_h < 17)  _a = _day_amb;
    else if (_h < 21)  _a = merge_color(_day_amb, _night_amb, (_h - 17) / 4);
    else               _a = _night_amb;
    var _corr01 = clamp(global.circle_corruption[CIRCLE_LIMBO] / 100, 0, 1);
    return merge_color(_a, make_color_rgb(40, 38, 44), _corr01 * 0.35);
}

// =============================================================================
// GLOBAL DEPTH RULE (David, 2026-06-10) — Y-based depth sorting, everywhere
// =============================================================================
/// Every WORLD object layers by its feet: depth = -bbox_bottom. The player
/// draws in front of what's north of him and behind what's south — FF6
/// layering in every room. Called once from obj_game_manager Create and every
/// frame from its End Step (movers re-sort as they walk).
/// EXEMPT (fixed staging, never Y-sorted): scene drawers (ground would cover
/// the world), managers, UI (dialogue/journal/save indicator), manifestation
/// overlays, walls/exit zones (invisible), and the battle room entirely.
function scr_depth_ysort() {
    if (room == room_battle) return;            // battle keeps its own staging
    with (all) {
        if (sprite_index == -1) continue;       // zones/managers without art
        if (!visible) continue;                 // hidden walls/markers
        if (object_index == obj_dialogue_box || object_index == obj_journal
         || object_index == obj_save_indicator || object_index == obj_manifestation
         || object_index == obj_wall          || object_index == obj_mercato_exit
         || object_index == obj_inn_candle) continue;   // candle sits ON a table — manages its own depth
        var _nm = object_get_name(object_index);
        if (string_pos("_scene", _nm) > 0)   continue;   // ground/scene drawers
        if (string_pos("_manager", _nm) > 0) continue;   // managers
        depth = -bbox_bottom;
    }
}
