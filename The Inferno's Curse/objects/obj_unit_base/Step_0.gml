// ── Snap world position to grid every step ────────────────────────────────────
// Units live in grid coords; the engine position is just for draw depth.
x = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;
y = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;

// ── Death check ───────────────────────────────────────────────────────────────
if (hp <= 0 && !fsm.state_is("dead")) {
    fsm.change("dead");
    scr_battle_add_log(unit_name + " has fallen.");
}
