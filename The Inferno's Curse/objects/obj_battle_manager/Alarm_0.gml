// Alarm 0 — fires 2 steps after Create so obj_unit_benedetto exists.
// Spawns enemy Hollows, builds turn order, places Limbo tiles, starts round 1.

// ── Spawn Circle 1 encounter: two Hollows on the right side of the grid ───────
// Positions are set directly so there's no per-instance creation-code risk.
var _h1 = instance_create_layer(0, 0, "Instances", obj_unit_hollow);
_h1.grid_x    = 8;
_h1.grid_y    = 2;
_h1.unit_name = "The Hollow";

var _h2 = instance_create_layer(0, 0, "Instances", obj_unit_hollow);
_h2.grid_x    = 8;
_h2.grid_y    = 5;
_h2.unit_name = "The Hollow";   // identical names intentional — they've forgotten themselves

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
