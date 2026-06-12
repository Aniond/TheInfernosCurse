// =============================================================================
// obj_mercato_scene — Create
// =============================================================================
// Populates Room_mercato_vecchio: places every building / loggia / stall / prop /
// fountain as a lightweight obj_mercato_prop (sprite assigned by NAME at runtime,
// so a not-yet-imported sprite is skipped instead of crashing), builds an invisible
// obj_wall footprint under each solid piece, walls off the Arno (gap at the steps),
// and drops the three exit triggers. Positions mirror layouts/room_mercato_vecchio_layout.txt.
// 1 grid cell = 64 px.  Hand-tune freely; this is a first pass.
// =============================================================================
if (room_get_name(room) != "Room_mercato_vecchio") exit;

#macro MERCATO_GRID 64

if (!variable_global_exists("mercato_objects")) global.mercato_objects = [];
global.mercato_objects = [];

// ── helpers ───────────────────────────────────────────────────────────────────
// NOTE: instance-scope (no `var`) on purpose — GML method functions do NOT close
// over enclosing `var` locals, so _place() must reach _mk_wall via self.
// invisible solid box (top-left x,y + size), same collision obj_player tests.
_mk_wall = function(_x, _y, _w, _h) {
    var _w2 = instance_create_depth(_x, _y, 500, obj_wall);
    _w2.wall_w  = _w;
    _w2.wall_h  = _h;
    _w2.visible = false;
    array_push(global.mercato_objects, _w2);
    return _w2;
};

// place a sprite (by name) at a grid cell; bottom-anchored depth (y-sort). When
// _solid, lay a footprint wall over the bottom band. Missing sprite -> skipped.
var _place = function(_name, _gx, _gy, _scale, _solid) {
    var _spr = asset_get_index(_name);
    if (_spr < 0 || asset_get_type(_name) != asset_sprite) {
        show_debug_message("[mercato] sprite not found (skipped): " + _name);
        return noone;
    }
    var _px = _gx * MERCATO_GRID;
    var _py = _gy * MERCATO_GRID;
    var _sw = sprite_get_width(_spr)  * _scale;
    var _sh = sprite_get_height(_spr) * _scale;
    var _base_y = _py + _sh;                                  // bottom of the sprite
    var _inst = instance_create_depth(_px, _py, -_base_y, obj_mercato_prop);
    _inst.sprite_index = _spr;
    _inst.image_xscale = _scale;
    _inst.image_yscale = _scale;
    array_push(global.mercato_objects, _inst);
    if (_solid) {
        var _cw = _sw * 0.80;
        var _ch = _sh * 0.35;                                 // bottom band = footprint
        _mk_wall(_px + (_sw - _cw) * 0.5, _base_y - _ch, _cw, _ch);
    }
    return _inst;
};

// ── BUILDINGS lining the top + side edges (vary types; leave alley gaps) ───────
// New mercato variants + reused Florence sprites. solid = true.
_place("spr_mercato_building_a", 1,  0.2, 1.0, true);
_place("spr_florence_house",     4,  0.5, 1.4, true);
_place("spr_mercato_building_c", 6,  0.0, 1.0, true);
_place("spr_mercato_building_b", 18, 0.4, 1.0, true);
_place("spr_florence_building",  22, 1.0, 1.3, true);
_place("spr_mercato_building_a", 25, 0.2, 1.0, true);
_place("spr_florence_tower",     28, 0.6, 1.1, true);
// left edge — the INN is the hub landmark (food/lodging), mid-west so it reads on entry
_place("spr_florence_house",     0,  5,   1.4, true);
_place("spr_mercato_inn",        0,  9,   1.1, true);
_place("spr_mercato_building_a", 0,  13,  1.0, true);
_place("spr_florence_house",     0,  18,  1.4, true);
// right edge
_place("spr_mercato_building_b", 26, 5,   1.0, true);
_place("spr_florence_tower",     27, 9,   1.1, true);
_place("spr_mercato_building_a", 26, 14,  1.0, true);
_place("spr_florence_house",     27, 18,  1.4, true);

// ── LOGGIA DEL MERCATO — top centre, three arches; central arch is the N gate ──
// Placed as one sprite, but collision is the two side piers ONLY, leaving the
// centre arch walkable so the player can step through it into the north exit zone.
var _log = _place("spr_mercato_loggia", 13.5, 0.3, 1.0, false);
if (_log != noone) {
    var _lspr = _log.sprite_index;
    var _lw = sprite_get_width(_lspr);
    var _lh = sprite_get_height(_lspr);
    var _lx = 13.5 * MERCATO_GRID;
    var _ly = 0.3  * MERCATO_GRID;
    var _lbase = _ly + _lh;
    // left pier + right pier (each ~28% width); centre ~44% left open as the arch
    _mk_wall(_lx,                 _lbase - _lh * 0.45, _lw * 0.28, _lh * 0.45);
    _mk_wall(_lx + _lw * 0.72,    _lbase - _lh * 0.45, _lw * 0.28, _lh * 0.45);
}

// ── MARKET STALLS — three rows, all facing south (per spec grid) ──────────────
// Row 1 (near loggia)
_place("spr_stall_striped_green",  8,  6, 1.0, true);
_place("spr_stall_striped_cream",  14, 6, 1.0, true);
_place("spr_stall_flat_green",     20, 6, 1.0, true);
// Row 2 (middle)
_place("spr_stall_dye_merchant",   4,  10, 1.0, true);
_place("spr_stall_striped_red",    10, 10, 1.0, true);
_place("spr_stall_striped_blue",   16, 10, 1.0, true);
_place("spr_stall_weapon_smith",   22, 10, 1.0, true);
// Row 3 (south)
_place("spr_stall_herbalist",      4,  16, 1.0, true);
_place("spr_stall_striped_purple", 10, 16, 1.0, true);
_place("spr_stall_striped_cream",  16, 16, 1.0, true);
_place("spr_stall_produce",        22, 16, 1.0, true);

// ── CENTRAL FOUNTAIN (statue on a circular base) — no collision (walk up to it) ─
_place("spr_mercato_fountain", 15, 12, 1.0, false);

// ── PROPS ─────────────────────────────────────────────────────────────────────
_place("spr_barrel_stack",   2,  4,  1.0, true);
_place("spr_barrel_stack",   26, 8,  1.0, true);
_place("spr_crate_stack",    7,  8,  1.0, true);
_place("spr_crate_stack",    17, 14, 1.0, true);
_place("spr_sack_pile",      12, 8,  1.0, true);
_place("spr_sack_pile",      21, 14, 1.0, true);
_place("spr_clay_pot_large", 1,  12, 1.0, true);
_place("spr_clay_pot_large", 27, 12, 1.0, true);
_place("spr_clay_pot_large", 3,  7,  1.0, true);
_place("spr_cart_loaded",    6,  14, 1.0, true);
_place("spr_cart_covered",   24, 14, 1.0, true);
_place("spr_hanging_cloth",  4,  2,  1.0, false);   // decor, non-solid (overhead)
_place("spr_hanging_cloth",  20, 2,  1.0, false);

// ── ARNO collision — impassable band, gap only at the central steps ───────────
var _ry1   = room_height - 192;
var _bankh = 24;
var _step_w = 192;
var _step_x0 = room_width * 0.5 - _step_w * 0.5;
var _step_x1 = room_width * 0.5 + _step_w * 0.5;
_mk_wall(0,        _ry1 - _bankh, _step_x0,             room_height - (_ry1 - _bankh));   // west of steps
_mk_wall(_step_x1, _ry1 - _bankh, room_width - _step_x1, room_height - (_ry1 - _bankh));   // east of steps

// ── EXIT TRIGGERS ─────────────────────────────────────────────────────────────
// obj_mercato_exit reads exit_target (room name) + its zone (x,y + zone_w/zone_h).
var _mk_exit = function(_x, _y, _w, _h, _target, _label, _dir) {
    var _e = instance_create_depth(_x, _y, 400, obj_mercato_exit);
    _e.zone_w      = _w;
    _e.zone_h      = _h;
    _e.exit_target = _target;
    _e.exit_label  = _label;
    if (!is_undefined(_dir)) _e.trigger_dir = _dir;
    array_push(global.mercato_objects, _e);
    return _e;
};
// North — through the loggia's central arch -> Piazza della Signoria (not built yet)
_mk_exit(room_width * 0.5 - 96, 0, 192, 96, "Room_piazza_signoria", "To Piazza della Signoria", "north");
// East — right edge, mid -> back to Florence (Florence) — Benedetto enters from here
_mk_exit(room_width - 72, room_height * 0.5 - 96, 72, 192, "Room_florence_v2", "To Florence", "east");
// South — central steps -> Ponte Vecchio (RESTORED 2026-06-10: the rebuilt
// marketplace bridge; lands at the west end)
_mk_exit(_step_x0, _ry1 - _bankh - 24, _step_w, 48, "Room_ponte_vecchio", "To Ponte Vecchio", "south");
