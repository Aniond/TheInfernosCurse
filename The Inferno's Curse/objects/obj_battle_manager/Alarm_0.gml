// Alarm 0 — fires 2 steps after Create so obj_unit_benedetto exists.
// Spawns enemy Hollows, builds turn order, places Limbo tiles, starts round 1.

// ── Spawn Hollow enemies (count from global.battle_enemy_count) ───────────────
// Spread positions on the right side of the grid — up to 5 slots.
// Positions are set directly so there's no per-instance creation-code risk.
var _hollow_slots = [
    [8, 1],
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

// ── Build turn order: player units first, then enemies ────────────────────────
turn_order = [];
with (obj_unit_base) {
    if (team == 0) array_push(other.turn_order, id);
}
with (obj_unit_base) {
    if (team == 1) array_push(other.turn_order, id);
}

// ── Place Limbo tiles after all units are positioned ──────────────────────────
scr_battle_place_limbo_tiles(global.battle_corruption);

// ── Start round 1 ─────────────────────────────────────────────────────────────
scr_battle_start_round();
