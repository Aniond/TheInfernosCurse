// Alarm 0 — fires 2 steps after Create so all unit instances exist.
// Builds turn order and places Limbo tiles, then starts the first turn.

// ── Build turn order: player units first, then enemies ────────────────────────
turn_order = [];
with (obj_unit_base) {
    if (team == 0) array_push(other.turn_order, id);   // player team
}
with (obj_unit_base) {
    if (team == 1) array_push(other.turn_order, id);   // enemy team
}

// ── Place Limbo tiles after units are positioned ──────────────────────────────
scr_battle_place_limbo_tiles(global.battle_corruption);

// ── Start round 1 ─────────────────────────────────────────────────────────────
scr_battle_start_round();
