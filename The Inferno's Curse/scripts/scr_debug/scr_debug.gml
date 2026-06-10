// =============================================================================
// scr_debug — comprehensive F1 debug overlay
// =============================================================================
// ONE toggle drives everything: global.debug_mode (flipped by F1 in
// obj_game_manager Step). On = show all panels + outlines; off = nothing.
//
// Rendering is split into world-space and GUI-space helpers and called from the
// Draw / Draw GUI events that already exist in each room:
//   Florence  : obj_player        — Draw    -> scr_debug_world_overworld()
//                                Draw GUI -> scr_debug_gui_common(false)
//   battle : obj_battle_manager — Draw    -> scr_debug_battle_world()
//                                Draw GUI -> scr_debug_gui_common(true)
//                                            scr_debug_battle_gui()
//
// Every read is guarded (variable_global_exists / instance_exists / struct
// checks) so a missing system degrades to "n/a" instead of throwing. Items the
// game does not implement yet (separate per-unit SPD, focus_charges per unit,
// move/attack/consecrated tiles, remembers_self, relationship) are shown as
// "n/a" rather than invented.
// =============================================================================


// ── small formatting helpers ──────────────────────────────────────────────────
function scr_debug_pad2(_n) {
    return (_n < 10 ? "0" : "") + string(_n);
}

function scr_debug_time_str(_tod) {
    var _h = floor(_tod) mod 24;
    var _m = floor(frac(_tod) * 60);
    return scr_debug_pad2(_h) + ":" + scr_debug_pad2(_m);
}

function scr_debug_mem() {
    // GameMaker exposes no cheap per-frame runtime-memory figure; shown as n/a.
    return "n/a";
}

function scr_debug_circle_name(_i) {
    var _names = ["Limbo", "Lust", "Gluttony", "Greed", "Wrath", "Heresy", "Violence"];
    return (_i >= 0 && _i < array_length(_names)) ? _names[_i] : "?";
}

function scr_debug_circle_short(_i) {
    var _s = ["Lmb", "Lst", "Glt", "Grd", "Wrt", "Hrs", "Vio"];
    return (_i >= 0 && _i < array_length(_s)) ? _s[_i] : "?";
}


// ── drawing primitives ─────────────────────────────────────────────────────────
function scr_debug_box(_x1, _y1, _x2, _y2, _alpha) {
    draw_set_alpha(_alpha);
    draw_set_color(make_color_rgb(8, 8, 14));
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(60, 70, 90));
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_color(c_white);
}

/// A backed panel of text lines, anchored by a corner.
/// _halign fa_left/fa_right grows the box right/left; _valign fa_top/fa_bottom
/// grows it down/up. _title "" omits the header row.
function scr_debug_panel(_ax, _ay, _lines, _halign, _valign, _title, _col) {
    draw_set_font(-1);
    var _n = array_length(_lines);
    var _has_title = (_title != "");
    if (_n == 0 && !_has_title) return;

    var _pad = 6;
    var _lh  = string_height("Mg") + 1;
    var _rows = _n + (_has_title ? 1 : 0);

    var _w = 0;
    for (var _i = 0; _i < _n; _i++) _w = max(_w, string_width(_lines[_i]));
    if (_has_title) _w = max(_w, string_width(_title));
    _w += _pad * 2;
    var _h = _rows * _lh + _pad * 2;

    var _bx1, _bx2, _by1, _by2, _tx;
    if (_halign == fa_right) { _bx2 = _ax; _bx1 = _ax - _w; _tx = _ax - _pad; }
    else                     { _bx1 = _ax; _bx2 = _ax + _w; _tx = _ax + _pad; }
    if (_valign == fa_bottom) { _by2 = _ay; _by1 = _ay - _h; }
    else                      { _by1 = _ay; _by2 = _ay + _h; }

    scr_debug_box(_bx1, _by1, _bx2, _by2, 0.74);

    draw_set_halign(_halign);
    draw_set_valign(fa_top);
    var _ty = _by1 + _pad;
    if (_has_title) {
        draw_set_color(make_color_rgb(150, 205, 255));
        draw_text(_tx, _ty, _title);
        _ty += _lh;
    }
    draw_set_color(_col);
    for (var _i = 0; _i < _n; _i++) {
        draw_text(_tx, _ty, _lines[_i]);
        _ty += _lh;
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

/// A single centered label with a backing box, bottom-anchored at (_cx,_by).
function scr_debug_center_label(_cx, _by, _str, _col) {
    draw_set_font(-1);
    var _pad = 6;
    var _w = string_width(_str) + _pad * 2;
    var _h = string_height("Mg") + _pad * 2;
    scr_debug_box(_cx - _w * 0.5, _by - _h, _cx + _w * 0.5, _by, 0.74);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(_col);
    draw_text(_cx, _by - _pad, _str);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}


// ── ALWAYS-ON GUI PANELS (both rooms) ──────────────────────────────────────────
function scr_debug_gui_common(_in_battle) {
    if (!global.debug_mode) return;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    draw_set_font(-1);
    draw_set_alpha(1);
    var _show_panels = !variable_global_exists("debug_show_log") || global.debug_show_log;

    // TOP LEFT — World State -----------------------------------------------------
    var _corrL = variable_global_exists("circle_corruption") ? global.circle_corruption[CIRCLE_LIMBO] : 0;
    var _san   = round(scr_lucidity());
    var _pc    = instance_exists(obj_player) ? string(round(obj_player.corruption)) : "n/a";
    var _day   = variable_global_exists("day_count")  ? global.day_count  : 0;
    var _tod   = variable_global_exists("time_of_day") ? global.time_of_day : 0;
    var _night = (variable_global_exists("is_night") && global.is_night) ? " night" : "";

    var _px = "-", _py = "-", _spd = "-", _sprn = "-", _idx = "-";
    if (instance_exists(obj_player)) {
        _px   = string(round(obj_player.x));
        _py   = string(round(obj_player.y));
        _spd  = string(obj_player.move_spd);
        _sprn = sprite_exists(obj_player.sprite_index) ? sprite_get_name(obj_player.sprite_index) : "-";
        _idx  = string(floor(obj_player.image_index));
    }
    var _frozen = (variable_global_exists("time_frozen") && global.time_frozen) ? " *FROZEN*" : "";
    var _timestr = variable_global_exists("game_hour")
        ? (scr_time_str() + " Day " + string(global.game_day) + " [" + scr_time_phase() + "]" + _frozen)
        : (scr_debug_time_str(_tod) + _night);
    var _tl = [
        "S:" + string(_san) + "  C:" + string(round(_corrL)) + "  PC:" + _pc,
        _timestr + "  Ctrl+T=+1hr  T=freeze",
        "pos:" + _px + "," + _py + "  room:" + room_get_name(room),
        "spd:" + _spd + "  spr:" + _sprn + "  idx:" + _idx,
    ];
    if (_show_panels) scr_debug_panel(6, 6, _tl, fa_left, fa_top, "WORLD STATE", make_color_rgb(210, 220, 235));

    // TOP RIGHT — Systems (F10 to hide) -----------------------------------------
    var _api   = (variable_global_exists("ai_disabled") && global.ai_disabled) ? "OFF (F11)"
               : ((variable_global_exists("claude_api_key") && global.claude_api_key != "") ? "LIVE" : "MOCK(no key)");
    var _calls = variable_global_exists("api_call_count") ? global.api_call_count : 0;
    var _cc    = variable_global_exists("current_circle") ? global.current_circle : 0;
    var _en = "";
    if (variable_global_exists("circle_enabled")) {
        for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
            if (global.circle_enabled[_i]) _en += scr_debug_circle_short(_i) + " ";
        }
    }
    if (_en == "") _en = "(none)";
    var _save = variable_global_exists("last_save_info") ? string(global.last_save_info) : "never";
    var _tr = [
        "API:" + _api + "  calls:" + string(_calls),
        "Circle:" + string(_cc) + " " + scr_debug_circle_name(_cc),
        "Enabled:" + _en,
        "NPCs:" + string(instance_number(obj_npc_base)),
        "Last save:" + _save,
    ];
    if (_show_panels) scr_debug_panel(_gw - 6, 6, _tr, fa_right, fa_top, "SYSTEMS", make_color_rgb(210, 235, 210));

    // TOP RIGHT (below SYSTEMS) — OBJECT INSPECTOR (left-click a builder object).
    // Stays until a different object is selected or you click empty space.
    if (variable_global_exists("room_builder_selected") && instance_exists(global.room_builder_selected)) {
        var _s    = global.room_builder_selected;
        var _hasS = (_s.sprite_index != -1 && sprite_exists(_s.sprite_index));
        var _sprn = _hasS ? sprite_get_name(_s.sprite_index) : "(none)";
        var _mask = _hasS ? (string(_s.bbox_right - _s.bbox_left + 1) + "x" + string(_s.bbox_bottom - _s.bbox_top + 1) + " px") : "(none)";
        var _ins  = [
            "name:  " + object_get_name(_s.object_index),
            "grid:  " + string(round(_s.x / 64)) + "," + string(round(_s.y / 64)),
            "px:    " + string(round(_s.x)) + "," + string(round(_s.y)),
            "scale: " + string(_s.image_xscale),
            "spr:   " + _sprn,
            "mask:  " + _mask,
        ];
        if (variable_instance_exists(_s, "builder_solid"))
            array_push(_ins, "solid: " + (_s.builder_solid ? "yes" : "no"));
        if (variable_instance_exists(_s, "proximity_radius"))
            array_push(_ins, "prox:  " + string(_s.proximity_radius) + " px");
        else if (variable_instance_exists(_s, "interact_dist"))
            array_push(_ins, "prox:  " + string(_s.interact_dist) + " px");
        if (variable_instance_exists(_s, "exit_target")) {
            array_push(_ins, "-> room: " + string(_s.exit_target));
            array_push(_ins, "zone:  " + string(_s.zone_w) + "x" + string(_s.zone_h) + " px");
            if (variable_instance_exists(_s, "arrive_x"))
                array_push(_ins, "land:  " + string(_s.arrive_x) + "," + string(_s.arrive_y));
        }
        if (variable_instance_exists(_s, "corruption"))
            array_push(_ins, "corrupt: " + string(_s.corruption));
        else if (variable_instance_exists(_s, "corruption_state"))
            array_push(_ins, "corrupt: " + string(_s.corruption_state));
        scr_debug_panel(_gw - 6, 150, _ins, fa_right, fa_top, "INSPECTOR [Del · arrows=nudge]", make_color_rgb(255, 190, 190));
    }

    // BOTTOM CENTER — Performance (F10 to hide) ----------------------------------
    if (_show_panels) {
        var _perf = "FPS " + string(fps) + "/60 (cap)   raw " + string(round(fps_real)) +
                    "   inst " + string(instance_count) + "   mem " + scr_debug_mem();
        scr_debug_center_label(_gw * 0.5, _gh - 8, _perf, make_color_rgb(235, 225, 180));
    }

    // Overworld-only panels (battle has its own chronicle / tile legend) ---------
    if (!_in_battle) {
        // BOTTOM LEFT — Event Log (last 10, newest first) — F10 to hide
        if (!variable_global_exists("debug_show_log") || global.debug_show_log) {
            var _log = [];
            if (variable_global_exists("world_event_log")) {
                var _ln = min(10, array_length(global.world_event_log));
                for (var _i = 0; _i < _ln; _i++) array_push(_log, global.world_event_log[_i]);
            }
            if (array_length(_log) == 0) array_push(_log, "(no events yet)");
            scr_debug_panel(6, _gh - 26, _log, fa_left, fa_bottom, "EVENT LOG", make_color_rgb(200, 200, 215));
        }

        // BOTTOM RIGHT — Collision legend (F10 to hide)
        if (_show_panels) {
            var _leg = [
                "red     = solid (walls)",
                "green   = player foot box",
                "yellow  = interaction zone",
                "cyan    = builder prop",
                "orange  = selected footprint",
                "magenta = transition zone",
                "white+  = player origin",
            ];
            scr_debug_panel(_gw - 6, _gh - 26, _leg, fa_right, fa_bottom, "COLLISION", make_color_rgb(215, 210, 200));
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// ── OVERWORLD WORLD-SPACE OVERLAY (Florence) ──────────────────────────────────────
function scr_debug_world_overworld() {
    if (!global.debug_mode) return;
    draw_set_font(-1);
    draw_set_alpha(1);

    // Grid overlay (F2) — 64px lines across the whole room + coords on every 5th cell.
    if (variable_global_exists("debug_grid_overlay") && global.debug_grid_overlay) {
        draw_set_alpha(0.22);
        draw_set_color(make_color_rgb(120, 135, 160));
        for (var _glx = 0; _glx <= room_width;  _glx += 64) draw_line(_glx, 0, _glx, room_height);
        for (var _gly = 0; _gly <= room_height; _gly += 64) draw_line(0, _gly, room_width, _gly);
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(190, 205, 235));
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        for (var _cx = 0; _cx * 64 <= room_width; _cx += 5)
            for (var _cy = 0; _cy * 64 <= room_height; _cy += 5)
                draw_text(_cx * 64 + 3, _cy * 64 + 2, string(_cx) + "," + string(_cy));
        draw_set_alpha(1);
    }

    // (Old-map river debug overlay removed 2026-06-10 with Room_florence —
    //  v2's river is plain obj_wall collision, covered by the red outlines below.)

    // Solid objects — red outlines
    draw_set_color(make_color_rgb(220, 55, 55));
    with (obj_wall)       draw_rectangle(x, y, x + wall_w, y + wall_h, true);
    with (obj_wall_stone) draw_rectangle(x, y, x + wall_w, y + wall_h, true);

    // Interaction zones — yellow rings around NPCs
    draw_set_color(make_color_rgb(230, 210, 60));
    with (obj_npc_base) draw_circle(x, y, interact_dist, true);

    // Player foot-box (green), crosshair (white), coords
    if (instance_exists(obj_player)) {
        var _x = obj_player.x, _y = obj_player.y;
        draw_set_color(make_color_rgb(60, 220, 90));
        draw_rectangle(_x - 16, _y - 8, _x + 16, _y + 8, true);   // matches _phw/_phh
        draw_set_color(c_white);
        draw_line(_x - 12, _y, _x + 12, _y);
        draw_line(_x, _y - 12, _x, _y + 12);
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        draw_text(_x + 14, _y - 12, string(round(_x)) + "," + string(round(_y)));
    }

    // Room-builder objects — cyan outlines (draggable in debug); dragged one yellow
    if (variable_global_exists("room_builder_objects")) {
        for (var _bi = 0; _bi < array_length(global.room_builder_objects); _bi++) {
            var _o = global.room_builder_objects[_bi];
            if (!instance_exists(_o)) continue;
            if (_o.object_index == obj_mercato_exit) continue;   // drawn by the transition block below
            var _drag = (variable_global_exists("room_builder_drag") && global.room_builder_drag == _o);
            var _sel  = (variable_global_exists("room_builder_selected") && global.room_builder_selected == _o);
            draw_set_color(_sel ? make_color_rgb(255, 45, 45) : (_drag ? c_yellow : make_color_rgb(60, 200, 220)));
            if (_o.sprite_index != -1 && sprite_exists(_o.sprite_index))
                draw_rectangle(_o.bbox_left, _o.bbox_top, _o.bbox_right, _o.bbox_bottom, true);
            else
                draw_rectangle(_o.x - 24, _o.y - 24, _o.x + 24, _o.y + 24, true);
            draw_set_halign(fa_center);
            draw_set_valign(fa_bottom);
            var _ba   = variable_instance_exists(_o, "builder_angle") ? _o.builder_angle : 0;
            var _atxt = (_ba != 0 || _sel) ? "  [" + string(_ba) + "°]" : "";
            draw_text(_o.x, _o.y - 26, object_get_name(_o.object_index) + "  " +
                string(round(_o.x / 64)) + "," + string(round(_o.y / 64)) + _atxt);
        }
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }

    // Collision footprint preview — ORANGE band on the SELECTED prop: the exact
    // obj_wall rectangle scr_room_builder_build_collision() lays under it (shared
    // geometry — scr_room_builder_footprint). Live: follows drag / nudge / scale,
    // so misplaced invisible walls are visible the moment they happen.
    if (variable_global_exists("room_builder_selected") && instance_exists(global.room_builder_selected)) {
        var _fp = scr_room_builder_footprint(global.room_builder_selected);
        if (!is_undefined(_fp)) {
            draw_set_color(make_color_rgb(255, 150, 40));
            draw_set_alpha(0.22);
            draw_rectangle(_fp[0], _fp[1], _fp[2], _fp[3], false);
            draw_set_alpha(1);
            draw_rectangle(_fp[0], _fp[1], _fp[2], _fp[3], true);
        }
    }

    // Transition zones — PURPLE (distinct from the red selection blocks). Draws EVERY
    // obj_mercato_exit in the room; the selected one flips to bright yellow.
    with (obj_mercato_exit) {
        var _seltz = (variable_global_exists("room_builder_selected") && global.room_builder_selected == id);
        var _tcol  = _seltz ? make_color_rgb(255, 232, 60) : make_color_rgb(190, 60, 235);
        draw_set_alpha(0.18);
        draw_set_color(_tcol);
        draw_rectangle(x, y, x + zone_w, y + zone_h, false);   // fill
        draw_set_alpha(1);
        draw_rectangle(x, y, x + zone_w, y + zone_h, true);    // outline
        if (_seltz) draw_rectangle(x - 2, y - 2, x + zone_w + 2, y + zone_h + 2, true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + zone_w * 0.5, y + zone_h * 0.5 - 7, "obj_transition [" + string(exit_target) + "]");
        draw_text(x + zone_w * 0.5, y + zone_h * 0.5 + 7, string(zone_w) + "x" + string(zone_h) + " px");
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    // Per-NPC labels
    scr_debug_npc_labels();

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function scr_debug_npc_labels() {
    with (obj_npc_base) {
        var _nm   = variable_instance_exists(id, "npc_name") ? string(npc_name) : object_get_name(object_index);
        var _arc  = variable_instance_exists(id, "marco_corruption_arc") ? string(marco_corruption_arc) : "n/a";
        var _corr = variable_instance_exists(id, "npc_memory_corruption") ? string(round(npc_memory_corruption)) : "-";
        var _remB = variable_instance_exists(id, "marco_met") ? (marco_met ? "Y" : "N") : "n/a";
        var _disp = "n/a";
        if (variable_instance_exists(id, "npc_data") && is_struct(npc_data)
         && variable_struct_exists(npc_data, "disposition")) {
            _disp = string(npc_data.disposition);
        }
        var _lines = [
            _nm + "  arc:" + _arc + "  corr:" + _corr,
            "memBen:" + _remB + "  memSelf:n/a  rel:" + _disp,
        ];
        scr_debug_panel(x - 80, y - 76, _lines, fa_left, fa_top, "", make_color_rgb(230, 220, 160));
    }
}


// ── BATTLE WORLD-SPACE OVERLAY (room_battle) ───────────────────────────────────
function scr_debug_battle_world() {
    if (!global.debug_mode) return;
    draw_set_font(-1);
    draw_set_alpha(1);
    var _ts = BATTLE_TILE_SIZE;

    // Tile coordinates on every cell
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(95, 95, 115));
    for (var _gx = 0; _gx < BATTLE_GRID_W; _gx++) {
        for (var _gy = 0; _gy < BATTLE_GRID_H; _gy++) {
            draw_text(BATTLE_GRID_X + _gx * _ts + 2, BATTLE_GRID_Y + _gy * _ts + 2,
                      string(_gx) + "," + string(_gy));
        }
    }

    // Limbo hazard tiles — red outline (L, or L* when Focus-revealed)
    with (obj_limbo_tile) {
        var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
        var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
        draw_set_color(make_color_rgb(230, 50, 50));
        draw_rectangle(_tx + 1, _ty + 1, _tx + BATTLE_TILE_SIZE - 2, _ty + BATTLE_TILE_SIZE - 2, true);
        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        draw_text(_tx + BATTLE_TILE_SIZE - 3, _ty + 2,
                  (variable_instance_exists(id, "is_shimmer_visible") && is_shimmer_visible) ? "L*" : "L");
        draw_set_halign(fa_left);
    }

    // Floating stats above each living unit
    with (obj_unit_base) {
        if (variable_instance_exists(id, "fsm") && fsm.state_is("dead")) continue;
        var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
        var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
        var _st = "?";
        if (variable_instance_exists(id, "fsm")) _st = fsm.get_current_state();
        var _status = (array_length(status_effects) > 0) ? string(status_effects[0]) : "-";
        var _fc = (object_index == obj_unit_benedetto && variable_global_exists("focus_charges"))
                  ? ("  FC:" + string(global.focus_charges)) : "";
        var _l1 = "HP " + string(round(hp)) + "/" + string(round(max_hp)) +
                  "  AP " + string(ap) + "/" + string(max_ap);
        var _l2 = "[" + _status + "] fsm:" + _st + _fc;
        scr_debug_panel(_tx, _ty - 36, [_l1, _l2], fa_left, fa_top, "", make_color_rgb(200, 230, 255));
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// ── BATTLE GUI OVERLAY (room_battle) ───────────────────────────────────────────
function scr_debug_battle_gui() {
    if (!global.debug_mode) return;
    var _gw = display_get_gui_width();
    draw_set_font(-1);

    var _bc  = variable_global_exists("battle_corruption") ? global.battle_corruption : 0;
    var _rnd = variable_global_exists("battle_round") ? global.battle_round : 0;

    // Per-round escalation estimate: 0.1 + 0.3/Shambler + 0.1/Hollow, capped 0.5
    var _nsh  = instance_number(obj_unit_shambler);
    var _nho  = instance_number(obj_unit_hollow);
    var _rate = min(0.5, 0.1 + 0.3 * _nsh + 0.1 * _nho);

    // Limbo tile-movement threshold countdown
    var _thr;
    if (_bc >= LIMBO_MOVE_THRESHOLD) {
        var _tmt  = instance_exists(obj_battle_manager) ? obj_battle_manager.tile_move_timer : 0;
        var _left = max(0, LIMBO_TILE_MOVE_INTERVAL - _tmt);
        _thr = "tiles move in " + string(_left) + "f (" + string(round(_left / 60 * 10) / 10) + "s)";
    } else {
        _thr = "tiles stable until " + string(LIMBO_MOVE_THRESHOLD) + "% (now " + string(round(_bc)) + "%)";
    }

    var _bar = [
        "battle_corruption: " + string(round(_bc * 10) / 10) + "   round " + string(_rnd),
        "rate/round (est): +" + string(_rate),
        _thr,
    ];
    scr_debug_panel(_gw * 0.5 - 170, 66, _bar, fa_left, fa_top, "BATTLE CORRUPTION", make_color_rgb(235, 180, 180));

    // Tile-type legend (most types not implemented yet — flagged n/a)
    var _leg = [
        "red    = Limbo hazard   (L* = revealed)",
        "blue   = move range      (native HUD)",
        "yellow = active unit      (native HUD)",
        "orange = attack range    n/a",
        "green  = consecrated      n/a",
    ];
    scr_debug_panel(_gw * 0.5 - 170, 66 + (string_height("Mg") + 1) * 4 + 14, _leg, fa_left, fa_top, "TILE LEGEND", make_color_rgb(210, 210, 225));

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
