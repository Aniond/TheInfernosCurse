// =============================================================================
// obj_game_manager — Create Event
// =============================================================================
// The single source of truth for all global game state.
// This object is PERSISTENT — one instance survives every room transition.
// It is placed FIRST in Room1's creation order so every other object can
// safely read globals from their own Create events.
//
// Array indexing convention used throughout this project:
//   Index 0 = Limbo    Index 1 = Lust      Index 2 = Gluttony
//   Index 3 = Greed    Index 4 = Wrath     Index 5 = Heresy
//   Index 6 = Violence
// =============================================================================


// ── API / AI ──────────────────────────────────────────────────────────────────
// Populated by scr_config_load() below. Never hardcode a key here.
global.claude_api_key = "";

// Instance ID of the NPC currently speaking in a dialogue box.
// noone = no active conversation.
global.dialogue_npc = noone;


// ── Core game state ───────────────────────────────────────────────────────────
// High-level flow controller. Valid values: "playing" | "paused" | "game_over"
global.game_state = "playing";

// In-world days elapsed. Drives NPC schedules and world progression events.
global.day_count = 1;

// Index (0-6) of the circle the player is currently in.
// 0 = Limbo (starting circle); increases as the player descends.
global.current_circle = 0;


// ── Per-circle corruption arrays (indices 0-6) ────────────────────────────────
// Each circle tracks its own corruption independently. Circles can bleed into
// neighbours via the spread mechanic (see scr_corruption_spread).

// How corrupted each circle currently is (0 = pristine, 100 = fully consumed).
global.circle_corruption    = array_create(7, 0);

// How fast corruption bleeds into adjacent circles per spread event (0.0-1.0).
// Default 0.1 = 10% of the source circle's corruption spreads per tick.
global.circle_bleed_rate    = array_create(7, 0.1);

// The corruption level a circle must reach before it starts bleeding outward.
// Below this threshold the circle is contained; above it, spread begins.
global.circle_bleed_threshold = array_create(7, 50);

// ── Per-circle player sin affinity (indices 0-6) ──────────────────────────────
// Tracks how deeply the player has engaged with each circle's sin (0-100).
// High affinity unlocks sin-specific abilities but closes off other paths.
global.player_sin_affinity  = array_create(7, 0);


// ── Player psychological state ────────────────────────────────────────────────
// Sanity decreases as the player witnesses corruption and takes unholy damage.
// At 0, hallucinations and gameplay distortions begin.
global.sanity = 100;

// Controls how intense the hallucination / corruption visual overlays are.
// Driven by low sanity and high local corruption (0 = none, 100 = overwhelming).
global.vision_intensity = 0;

// True when an active hallucination or corruption manifestation is on screen.
// Prevents stacking multiple manifestations simultaneously.
global.manifestation_active = false;


// ── Boot sequence ─────────────────────────────────────────────────────────────
// Load the API key last, after all globals exist, so any future init scripts
// called from here can safely reference the globals above.
scr_config_load();
