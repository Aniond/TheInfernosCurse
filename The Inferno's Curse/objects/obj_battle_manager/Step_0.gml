// =============================================================================
// obj_battle_manager — Step
// =============================================================================

if (battle_phase == "end") exit;

// ── Mirror corruption every step ──────────────────────────────────────────────
displayed_corruption = global.battle_corruption;

// ── Tile movement at 75%+ corruption ─────────────────────────────────────────
if (global.battle_corruption >= LIMBO_MOVE_THRESHOLD) {
    tile_move_timer++;
    if (tile_move_timer >= LIMBO_TILE_MOVE_INTERVAL) {
        tile_move_timer = 0;
        scr_battle_move_limbo_tiles();
    }
}

// ── Sanity zero check — clamp to 1 in battle (floor already in scr_corruption)
if (instance_exists(obj_unit_benedetto)) {
    if (global.sanity <= 0) global.sanity = 1;   // hard floor — 0 is open-world only
}

// ── Flee confirmation input ───────────────────────────────────────────────────
if (flee_confirm) {
    // Y = confirm flee
    if (keyboard_check_pressed(ord("Y"))) {
        flee_confirm = false;
        scr_battle_flee();
    }
    // N or ESC = cancel
    if (keyboard_check_pressed(ord("N")) || keyboard_check_pressed(vk_escape)) {
        flee_confirm = false;
        scr_battle_add_log("Benedetto steadied himself. He would not run.");
    }
    exit;   // block all other input while confirming
}

// ── ESC to flee (player turn only) ───────────────────────────────────────────
if (battle_phase == "player_turn" && keyboard_check_pressed(vk_escape)) {
    flee_confirm = true;
    exit;
}

// ── Player-turn end detection ─────────────────────────────────────────────────
// Only advances when unit explicitly sets turn_done = true (Z/ENTER).
// AP exhaustion no longer auto-advances — player must confirm.
if (battle_phase == "player_turn" && array_length(turn_order) > 0) {
    var _active = turn_order[active_unit_idx];
    if (instance_exists(_active) && _active.turn_done) {
        _active.turn_done = false;
        scr_battle_advance_turn();
    }
}

// ── Enemy turn: 250ms delay between enemies so player can read what happened ──
if (battle_phase == "enemy_turn") {
    enemy_turn_timer++;
    if (enemy_turn_timer >= ENEMY_TURN_DELAY) {
        enemy_turn_timer = 0;
        scr_battle_process_enemy_turn();
    }
}
