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

// ── Focus shimmer timer + alpha (full strength) ───────────────────────────────
if (is_shimmer_visible) {
    shimmer_timer++;
    shimmer_alpha = 0.25 + sin(shimmer_timer * 0.18) * 0.10;
    if (shimmer_timer >= LIMBO_SHIMMER_STEPS) {
        is_shimmer_visible = false;
        shimmer_timer      = 0;
        shimmer_alpha      = 0;   // Focus expired — tile goes fully dark, no residue
    }
} else {
    shimmer_alpha = 0;
}

// ── Passive shimmer — rare, faint, high-corruption only ───────────────────────
// Eligibility + alpha cap by corruption and sanity tier ("class"):
//   corruption >= 90                            -> cap 0.20
//   corruption >= 75                            -> cap 0.15
//   sanity 50-74 (Witness) AND corruption >= 50 -> cap 0.12  (reward for mid sanity)
//   otherwise                                   -> none — Focus is the only reveal
// Priest (sanity 75+): no passive — relies on Focus quality (reveals 4 tiles).
// Tainted (low sanity): no passive — mostly blind.
var _corr = global.battle_corruption;
var _san  = scr_lucidity();
var _cap  = 0;
// Only the Witness tier (50-74) gets passive shimmer — Priest relies on Focus quality,
// Tainted/Cursed/Forgotten are too far gone to benefit.
if (_san >= 50 && _san < 75) {
    if      (_corr >= 90) _cap = 0.20;
    else if (_corr >= 75) _cap = 0.15;
    else if (_corr >= 50) _cap = 0.12;
}

if (_cap > 0 && !is_shimmer_visible) {
    if (passive_active) {
        passive_timer--;
        // Gentle half-sine pulse: 0 -> cap -> 0 over the flash window.
        passive_alpha = _cap * sin((1 - passive_timer / 36) * pi);
        if (passive_timer <= 0) { passive_active = false; passive_alpha = 0; }
    } else {
        passive_cooldown--;
        if (passive_cooldown <= 0) {
            passive_active   = true;
            passive_timer    = 36;                       // ~0.6 s flash
            passive_cooldown = irandom_range(480, 600);  // 8-10 s between flashes
        }
    }
} else {
    passive_active = false;
    passive_alpha  = 0;
}
