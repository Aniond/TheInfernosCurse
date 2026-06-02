// =============================================================================
// obj_battle_manager — Create
// =============================================================================
// Single instance placed in room_battle. Drives turn order, tile movement,
// win/loss conditions, and the GUI overlay. Persistent across animations
// but destroyed when leaving room_battle.
// =============================================================================

// ── Initialise battle globals (reads Limbo corruption unless overridden) ──────
scr_battle_globals_init(-1);   // -1 = use global.circle_corruption[CIRCLE_LIMBO]

// ── Turn management ───────────────────────────────────────────────────────────
turn_order          = [];    // populated by scr_battle_build_turn_order() below
active_unit_idx     = 0;
battle_phase        = "setup";   // "setup" | "player_turn" | "enemy_turn" | "end"
tile_move_timer     = 0;

// ── Combat log (most recent at index 0, capped at 8 lines) ───────────────────
combat_log          = [];
combat_log_capacity = 8;

// ── Corruption meter display ──────────────────────────────────────────────────
// Mirror of global.battle_corruption, read each step.
displayed_corruption = global.battle_corruption;

// ── Sanity zero message ───────────────────────────────────────────────────────
show_sanity_zero_text = false;
sanity_zero_alpha     = 0;

// ── Build initial turn order (populated when units are created) ───────────────
// Units call scr_battle_register_unit(id) from their Create events.
// We defer building the order until the "setup" phase resolves in Step.
alarm[0] = 2;   // wait 2 steps so all unit Creates complete
