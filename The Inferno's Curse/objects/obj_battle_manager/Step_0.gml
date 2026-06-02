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

// ── Sanity zero check — Benedetto branch ─────────────────────────────────────
if (instance_exists(obj_unit_benedetto)) {
    if (global.sanity <= 0 && !scr_battle_has_status(obj_unit_benedetto, "frozen")) {
        scr_battle_sanity_zero(obj_unit_benedetto);
        show_sanity_zero_text = true;
    }
}

// ── Sanity zero text fade ─────────────────────────────────────────────────────
if (show_sanity_zero_text) {
    sanity_zero_alpha = min(sanity_zero_alpha + 0.02, 1);
}

// ── Player-turn end detection: active unit signals turn complete ───────────────
// Units set .turn_done = true when they finish acting; manager advances.
if (battle_phase == "player_turn" && array_length(turn_order) > 0) {
    var _active = turn_order[active_unit_idx];
    if (instance_exists(_active) && _active.turn_done) {
        _active.turn_done = false;
        scr_battle_advance_turn();
    }
}

// ── Enemy turn: auto-process immediately (no AI yet — just skips) ────────────
if (battle_phase == "enemy_turn") {
    scr_battle_process_enemy_turn();
}
