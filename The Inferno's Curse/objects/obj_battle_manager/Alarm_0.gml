// Alarm 0 — fires 2 steps after Create so obj_unit_benedetto exists.
// Spawns enemy Hollows, builds turn order, places Limbo tiles, starts round 1.

// ── Spawn Hollow enemies (count from global.battle_enemy_count) ───────────────
// Spread positions on the right side of the grid — up to 5 slots.
// Positions are set directly so there's no per-instance creation-code risk.
var _hollow_slots = [
    [6, 3],
    [8, 4],
    [8, 6],
    [7, 2],
    [7, 5],
];
var _count = clamp(global.battle_enemy_count, 1, array_length(_hollow_slots));
for (var _i = 0; _i < _count; _i++) {
    var _h = instance_create_layer(0, 0, "Instances", obj_unit_hollow);
    _h.grid_x    = _hollow_slots[_i][0];
    _h.grid_y    = _hollow_slots[_i][1];
    _h.unit_name = "The Hollow";   // identical names — they've forgotten themselves
}
show_debug_message("[Battle] Hollow count: " + string(instance_number(obj_unit_hollow))
    + "  |  battle_enemy_count: " + string(global.battle_enemy_count));

// ── TEMP DEBUG — force one Shambler for Prompt 12 testing ─────────────────────
// Remove once encounter table handles Legendary spawns correctly.
var _s = instance_create_layer(0, 0, "Instances", obj_unit_shambler);
_s.grid_x    = 8;
_s.grid_y    = 3;
_s.unit_name = "The Shambler";
show_debug_message("[Battle] Shambler count: " + string(instance_number(obj_unit_shambler)));

// ── Build turn order: player units first, then enemies ────────────────────────
// Guard: never build twice (e.g. if alarm fires more than once somehow)
if (turn_order_built) exit;
turn_order_built = true;

turn_order = [];
with (obj_unit_base) {
    if (team == 0) {
        // Dedup: only add if not already in the array
        var _already = false;
        for (var _di = 0; _di < array_length(other.turn_order); _di++) {
            if (other.turn_order[_di] == id) { _already = true; break; }
        }
        if (!_already) array_push(other.turn_order, id);
    }
}
with (obj_unit_base) {
    if (team == 1) {
        var _already = false;
        for (var _di = 0; _di < array_length(other.turn_order); _di++) {
            if (other.turn_order[_di] == id) { _already = true; break; }
        }
        if (!_already) array_push(other.turn_order, id);
    }
}

// ── Place Limbo tiles after all units are positioned ──────────────────────────
scr_battle_place_limbo_tiles(global.battle_corruption);

// ── Start round 1 ─────────────────────────────────────────────────────────────
scr_battle_start_round();
