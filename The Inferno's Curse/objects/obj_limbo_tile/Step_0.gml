// =============================================================================
// obj_limbo_tile — Step
// Keeps world position in sync with grid coords.
// Manages shimmer visibility decay.
// Tile movement and unit-trigger are handled by scr_battle functions
// (called from obj_battle_manager and obj_unit_benedetto respectively).
// =============================================================================

// ── Sync world position to grid ───────────────────────────────────────────────
x = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;
y = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2;

// Draw above the grid background (manager is depth 0), below units (depth < -100)
// so the Focus shimmer / debug boxes are actually visible.
depth = -50;

// ── Shimmer timer + alpha ─────────────────────────────────────────────────────
if (is_shimmer_visible) {
    shimmer_timer++;
    shimmer_alpha = 0.25 + sin(shimmer_timer * 0.18) * 0.10;
    if (shimmer_timer >= LIMBO_SHIMMER_STEPS) {
        is_shimmer_visible = false;
        shimmer_timer      = 0;
        shimmer_alpha      = 0;
    }
} else {
    shimmer_alpha = 0;
}
