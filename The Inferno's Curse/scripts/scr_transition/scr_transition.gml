// =============================================================================
// scr_transition — draggable, persistable room-transition zones
// =============================================================================
// Transition triggers (obj_mercato_exit) are spawned in CODE, so to fine-tune
// where they fire WITHOUT touching code, each one gets a unique KEY and its dragged
// position is saved to a small override file (working_directory). On spawn the
// override (if any) replaces the default position. Spawned transitions are also
// registered as room-builder objects, so debug drag / nudge / Delete / F8 work on
// them like any other prop.
//
//   scr_transition_spawn(key, x,y, w,h, target, label, ax,ay, pre) — spawn + register
//   scr_transition_save_overrides()  — F8: write every transition's current x,y
//   scr_transition_load_overrides()  — read the override file once
// =============================================================================

function scr_transition_overrides_path() {
    return working_directory + "transition_overrides.txt";
}

function scr_transition_load_overrides() {
    if (variable_global_exists("transition_overrides")) return;
    global.transition_overrides = {};
    var _p = scr_transition_overrides_path();
    if (!file_exists(_p)) return;
    var _f = file_text_open_read(_p);
    if (_f == -1) return;
    while (!file_text_eof(_f)) {
        var _raw = file_text_read_string(_f); file_text_readln(_f);
        var _l = string_trim(string_replace_all(_raw, chr(13), ""));
        if (_l == "" || string_char_at(_l, 1) == "#") continue;
        var _t = scr_room_builder_tokenize(_l);
        if (array_length(_t) < 3) continue;
        global.transition_overrides[$ _t[0]] = [real(_t[1]), real(_t[2])];
    }
    file_text_close(_f);
}

/// Spawn a transition trigger (with any saved position override applied) and
/// register it as a draggable builder object. Returns the instance.
function scr_transition_spawn(_key, _x, _y, _w, _h, _target, _label, _ax, _ay, _pre) {
    scr_transition_load_overrides();
    if (variable_struct_exists(global.transition_overrides, _key)) {
        var _o = global.transition_overrides[$ _key];
        _x = _o[0]; _y = _o[1];
    }
    var _ex = instance_create_depth(_x, _y, 400, obj_mercato_exit);
    _ex.zone_w        = _w;
    _ex.zone_h        = _h;
    _ex.exit_target   = _target;
    _ex.exit_label    = _label;
    _ex.arrive_x      = _ax;
    _ex.arrive_y      = _ay;
    _ex.pre_text      = _pre;
    _ex.transition_key = _key;
    _ex.visible       = false;
    // draggable-object tagging
    _ex.room_builder_placed = true;
    _ex.builder_sprite = "";
    _ex.builder_solid  = false;
    _ex.builder_angle  = 0;
    if (!variable_global_exists("room_builder_objects")) global.room_builder_objects = [];
    array_push(global.room_builder_objects, _ex);
    return _ex;
}

/// F8: merge the current room's transition positions into the override MAP, then
/// write the WHOLE map — so saving in one room never wipes another room's overrides.
function scr_transition_save_overrides() {
    scr_transition_load_overrides();   // ensure the accumulated map is loaded
    if (variable_global_exists("room_builder_objects")) {
        for (var _i = 0; _i < array_length(global.room_builder_objects); _i++) {
            var _o = global.room_builder_objects[_i];
            if (!instance_exists(_o)) continue;
            if (_o.object_index != obj_mercato_exit) continue;
            if (!variable_instance_exists(_o, "transition_key")) continue;
            global.transition_overrides[$ _o.transition_key] = [_o.x, _o.y];
        }
    }
    var _f = file_text_open_write(scr_transition_overrides_path());
    if (_f == -1) return false;
    file_text_write_string(_f, "# Transition overrides — KEY  x  y  (drag transitions in debug; F8 saves)");
    file_text_writeln(_f);
    var _keys = struct_get_names(global.transition_overrides);
    for (var _k = 0; _k < array_length(_keys); _k++) {
        var _v = global.transition_overrides[$ _keys[_k]];
        file_text_write_string(_f, _keys[_k] + "  " + string(_v[0]) + "  " + string(_v[1]));
        file_text_writeln(_f);
    }
    file_text_close(_f);
    return true;
}
