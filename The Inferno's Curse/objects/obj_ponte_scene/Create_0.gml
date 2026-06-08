// =============================================================================
// obj_ponte_scene — Create
// =============================================================================
// Room controller for Room_ponte_vecchio (the Ponte Vecchio crossing). It spawns
// the invisible confinement walls and the two walk-into transition zones; the
// visuals (animated Arno on both sides, cobble walkway + landings, stacked shop
// SPRITES with warm window light) are painted in Draw_0.
//
// GEOMETRY (576 x 896 room, 9 x 14 cells @ 64px) — must match Draw_0 + the layout:
//   water columns   x[0,32]   and x[544,576]   (Arno, animated, corruption-tinted)
//   shop columns    x[32,160] & x[416,544], y[128,768]  (spr_bridge_shop_left/right)
//   central walkway x[160,416]  full length    (4 cells of cobblestone)
//   north landing   y[0,128]    cobble plaza  → NORTH exit (to Room1)
//   south landing   y[768,896]  cobble plaza  → SOUTH exit (placeholder)
// =============================================================================
if (room != Room_ponte_vecchio) exit;

var _rw = room_width;    // 576
var _rh = room_height;   // 896

// ── confinement walls (invisible obj_wall; AABB-tested by obj_player Step) ──────
// Keep the player on the I-beam walkable area: wide cobble landings N & S joined
// by the 4-cell central walkway. Water columns + shop columns are solid.
var _walls = [
    [0,   0, 32,  _rh],     // left Arno
    [544, 0, 32,  _rh],     // right Arno
    [32,  0, 128, _rh],     // left side (shops + statues) — FULL length corridor wall
    [416, 0, 128, _rh],     // right side — FULL length
];
for (var _i = 0; _i < array_length(_walls); _i++) {
    var _w = instance_create_depth(_walls[_i][0], _walls[_i][1], 500, obj_wall);
    _w.wall_w  = _walls[_i][2];
    _w.wall_h  = _walls[_i][3];
    _w.visible = false;
}

// ── draggable statue guides lining the corridor ────────────────────────────────
// Default layout (or the player's saved/tweaked positions). Movable in debug mode
// like Room1 props: click-drag, arrow-nudge, Delete, F8 saves to the bridge's own
// layout file. The full-length side walls above guarantee the corridor regardless.
scr_ponte_statues_build();

// ── transition zones (obj_mercato_exit — walk into the rectangle to fire) ───────
// 3 tiles (192px) wide, centred on the room (centre x = 288). BOTH exits return to
// Room1 (the south bank is future content) but drop the player on different Arno
// banks at the WEST crossing (x = 768) — the Ponte Vecchio's two ends.
// NORTH (top centre) → Room1, arriving on the Arno's NORTH bank (Florence side).
var _n = instance_create_depth(192, 0, 400, obj_mercato_exit);
_n.zone_w      = 192;
_n.zone_h      = 112;
_n.exit_target = "Room1";
_n.exit_label  = "Florence";
_n.pre_text    = "Firenze";
_n.arrive_x    = 768;     // west-crossing centre, just NORTH of the Arno bank
_n.arrive_y    = 1490;

// SOUTH (bottom centre) → Room1 for now, arriving on the Arno's SOUTH bank.
var _s = instance_create_depth(192, _rh - 112, 400, obj_mercato_exit);
_s.zone_w      = 192;
_s.zone_h      = 112;
_s.exit_target = "Room1";
_s.exit_label  = "The road south";
_s.pre_text    = "The road south. Not yet.";   // placeholder card, then load
_s.arrive_x    = 768;     // west-crossing centre, just SOUTH of the Arno bank
_s.arrive_y    = 1780;

// ── Corruption disorientation (coded — no API) ─────────────────────────────────
// At high Limbo corruption, entering the bridge sometimes lands Benedetto at the
// SOUTH end instead of where he meant to arrive — the span "forgets which way he was
// going." Roll on entry; a hit forces the south-end spawn + logs a chronicle line.
// (This Create runs before obj_player's, so overriding the spawn here takes effect.)
if (variable_global_exists("circle_corruption")) {
    var _corrz     = global.circle_corruption[CIRCLE_LIMBO];
    var _disorient = false;
    if (_corrz >= 75)      _disorient = (irandom(100) < 50);   // deeper: half the time
    else if (_corrz >= 50) _disorient = (irandom(100) < 25);   // 25% chance
    if (_disorient) {
        global.player_spawn_override = [288, 700];   // south end (just N of the south exit)
        // Robust vs Create-event order: if the player already exists, move it now too.
        if (instance_exists(obj_player)) { obj_player.x = 288; obj_player.y = 700; }
        var _lines;
        if (_corrz >= 75) {
            _lines = ["The bridge forgot which way I was going.",
                      "So did I.",
                      "I have been here before. Just now. Again.",
                      "The Arno looks the same from both ends."];
        } else {
            _lines = ["I must have lost my way on the bridge.",
                      "The bridge is longer than I remembered.",
                      "I crossed it. I think I crossed it.",
                      "Something is wrong with the distance here.",
                      "I entered from the north. I arrived at the south."];
        }
        scr_chronicle_add(_lines[irandom(array_length(_lines) - 1)]);
    }
}
