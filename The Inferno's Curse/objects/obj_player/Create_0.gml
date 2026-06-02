// ── Player: Create ──────────────────────────────────────────────────────────
// All core state lives here so other objects can read obj_player.corruption etc.

// --- Stats ---
hp        = 100;
max_hp    = 100;
// 0 = untouched by the Curse, 100 = fully consumed — gates events and endings
corruption = 0;

// --- Movement ---
move_spd      = 4;
base_move_spd = 4;   // Gluttony sin effect subtracts from this; never modify directly
facing_dir    = 270; // degrees (GameMaker: 0=right, 90=up, 180=left, 270=down)
                     // 270 = facing up — Benedetto enters each circle looking inward
                     // Read by obj_manifestation awareness check each step

// --- Combat ---
attack_speed    = 1.0;  // multiplied by global.attack_speed_modifier (Wrath effect)
attack_accuracy = 1.0;  // 0.0-1.0; reduced by global.attack_accuracy (Wrath effect)
