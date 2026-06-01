// ── Player: Create ──────────────────────────────────────────────────────────
// All core state lives here so other objects can read obj_player.corruption etc.

// --- Stats ---
hp        = 100;
max_hp    = 100;
// 0 = untouched by the Curse, 100 = fully consumed — gates events and endings
corruption = 0;

// --- Movement ---
move_spd = 4;
