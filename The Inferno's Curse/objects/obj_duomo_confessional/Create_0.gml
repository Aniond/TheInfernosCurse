// =============================================================================
// obj_duomo_confessional — Create
// =============================================================================
// A curtained booth on the right side of the nave. Step within range and press E
// to be offered confession (a self-contained Yes/No prompt — no dialogue object).
//   Yes : -10% Limbo corruption + chronicle
//   No  : nothing
// At/above 75% Limbo corruption the door will not open at all.
interact_range = 80;
player_near    = false;
prompt_active  = false;   // true while the Yes/No prompt is on screen
cooldown       = 0;       // brief debounce after any interaction
