// =============================================================================
// obj_limbo_tile — Create
// Invisible hazard tile spawned on the battle grid by scr_battle_place_limbo_tiles().
// Teleports any unit that steps on it. Shimmer revealed by Benedetto's Focus.
// Starts MOVING at 75%+ corruption (driven by obj_battle_manager Step).
// =============================================================================

grid_x = 0;
grid_y = 0;

// ── Shimmer state ─────────────────────────────────────────────────────────────
is_shimmer_visible = false;   // true while the FOCUS shimmer is drawn
shimmer_timer      = 0;       // counts up while visible; resets on hide
shimmer_alpha      = 0;       // current alpha for draw event

// ── Passive shimmer (rare faint hint, high corruption only) ───────────────────
// Focus [F] is the PRIMARY reveal. Passive shimmer is barely-there and
// infrequent, and never appears below the corruption/sanity gates (see Step).
passive_active   = false;
passive_timer    = 0;
passive_alpha    = 0;
passive_cooldown = irandom_range(300, 600);   // staggered so tiles don't pulse in sync

// ── Trigger flag ─────────────────────────────────────────────────────────────
// true while the tile has just fired (prevents double-teleport this step).
// Alarm 0 resets it after 1 second so the tile can fire again.
triggered = false;
