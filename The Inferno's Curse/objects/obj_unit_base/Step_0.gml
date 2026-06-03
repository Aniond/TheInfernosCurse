// ── Snap world position to grid every step ────────────────────────────────────
// Units live in grid coords; the engine position is just for draw depth.
x = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;
y = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;

// Draw above the battle grid. obj_battle_manager draws the grid background at
// depth 0; a negative depth guarantees every unit (room-placed OR runtime-spawned)
// renders in front of it, removing same-depth draw-order ambiguity.
depth = -100 - grid_y;   // -grid_y also y-sorts units among themselves

// ── Death check ───────────────────────────────────────────────────────────────
if (hp <= 0 && !fsm.state_is("dead")) {
    fsm.change("dead");
    scr_battle_add_log(unit_name + " has fallen.");
}
