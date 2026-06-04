// =============================================================================
// obj_game_manager — Create Event
// =============================================================================
// The single source of truth for all global game state.
// This object is PERSISTENT — one instance survives every room transition.
// It is placed FIRST in Room1's creation order so every other object can
// safely read globals from their own Create events.
//
// Circle array indexing (0-based) used throughout the entire project:
//   [0] Limbo  [1] Lust  [2] Gluttony  [3] Greed
//   [4] Wrath  [5] Heresy  [6] Violence
//
// All functions in scr_corruption.gml use the same 0-based scheme.
// The CIRCLE_* macros (CIRCLE_LIMBO=0 … CIRCLE_VIOLENCE=6) are defined
// in scr_corruption.gml and are available globally.
// =============================================================================


// ── API / AI ──────────────────────────────────────────────────────────────────
// Populated by scr_config_load() at the end of this event.
// Never hardcode a key here.
global.claude_api_key = "";

// Instance ID of the NPC currently speaking in a dialogue box.
// noone = no active conversation.
global.dialogue_npc = noone;


// ── Core game state ───────────────────────────────────────────────────────────
// High-level flow controller.
// Valid values: "playing" | "paused" | "game_over"
global.game_state = "playing";

// In-world days elapsed. Drives NPC schedules and world-progression events.
global.day_count = 1;

// Index (0-6) of the circle the player is currently occupying.
// 0 = Limbo (starting circle). Increases as the player descends.
global.current_circle = 0;

// ── Circle enabled flags ──────────────────────────────────────────────────────
// Only ENABLED circles apply sin effects, advance corruption, or receive bleed.
// A circle enables when the player reaches its city (scr_solve_circle unlocks
// the next one). During Circle 1 development only Limbo is live.
// TODO: Re-enable the others as each circle is sealed and tested completely.
global.circle_enabled[0] = true;   // Limbo    — always starts enabled (Florence)
global.circle_enabled[1] = false;  // Lust     — locked until Siena
global.circle_enabled[2] = false;  // Gluttony — locked until Genoa
global.circle_enabled[3] = false;  // Greed    — locked until Venice
global.circle_enabled[4] = false;  // Wrath    — locked until Naples
global.circle_enabled[5] = false;  // Heresy   — locked until Rome
global.circle_enabled[6] = false;  // Violence — locked until Ravenna


// ── Circle name tables (0-indexed, parallel to all circle arrays) ─────────────
// Used by scr_build_npc_system_prompt() and UI elements.
// Index matches circle: [0]=Limbo … [6]=Violence.
global.circle_names = [
    "Limbo",     // 0
    "Lust",      // 1
    "Gluttony",  // 2
    "Greed",     // 3
    "Wrath",     // 4
    "Heresy",    // 5
    "Violence"   // 6
];

// The sin that defines each circle (used in system prompt context).
global.sin_names = [
    "Grief",     // 0 — Limbo's essence is loss and forgetting
    "Lust",      // 1
    "Gluttony",  // 2
    "Greed",     // 3
    "Wrath",     // 4
    "Heresy",    // 5
    "Violence"   // 6
];

// ── Italian city names (parallel to circle indices) ───────────────────────────
// Real historical Italy, 1300 AD. Florence = starting city. Ravenna = finale.
// Where Dante actually died. The streets he walked — now consumed by the Curse.
global.city_names = [
    "Florence",  // 0 — Limbo
    "Siena",     // 1 — Lust
    "Genoa",     // 2 — Gluttony
    "Venice",    // 3 — Greed
    "Naples",    // 4 — Wrath
    "Rome",      // 5 — Heresy
    "Ravenna"    // 6 — Violence
];

// ── City entry descriptions (shown when entering each circle / city) ──────────
global.city_desc = [
    "Florence, 1300 AD. City of Dante. City of faith. City of forgetting.",
    "Siena. Beautiful. Dangerous. Nothing here is what it appears.",
    "Genoa. The port city devours itself. Even the sea smells of rot.",
    "Venice. Everything floats. Everything has a price. Even passage.",
    "Naples. They have always fought here. Now they cannot stop.",
    "Rome. The holy city. Nothing holy remains.",
    "Ravenna. The last city. He knew he would end here."
];


// ── Per-circle corruption (indices 0-6) ───────────────────────────────────────
// How corrupted each circle currently is (0 = pristine, 100 = fully consumed).
global.circle_corruption = array_create(7, 0);

// Rate at which a circle bleeds corruption into its neighbours per spread event.
// 0.1 = the neighbour receives 10% of this circle's corruption per tick.
global.circle_bleed_rate = array_create(7, 0.1);

// Corruption level a circle must exceed before it bleeds outward.
// Below this value the circle is contained; at or above it, spread begins.
global.circle_bleed_threshold = array_create(7, 50);


// ── Per-circle player sin affinity (indices 0-6) ──────────────────────────────
// How deeply the player has engaged with each circle's sin (0-100).
// High affinity unlocks sin abilities but closes off alternative paths.
global.player_sin_affinity = array_create(7, 0);


// ── World event log ───────────────────────────────────────────────────────────
// Rolling log of narrative events passed as context to the Claude API.
// Managed by scr_world_event_log() in scr_corruption.gml.
// Newest entry is always at index 0; capped at 20 entries.
global.world_event_log = [];


// ── Player psychological state ────────────────────────────────────────────────
// Sanity decreases from witnessing corruption and taking unholy damage.
// At 0, hallucinations and gameplay distortions activate.
global.sanity = 100;

// Player class — affects the Focus ability:
//   "witness" = Focus is free (no sanity cost)
//   "cursed"  = Focus reveals only 1 tile, perception check can reveal a false one
//   "default" = standard scaled reveal at -LIMBO_SHIMMER_COST sanity
global.player_class = "default";

// Focus charges — set once at battle start from the sanity class (min 1), never refreshed.
// Spent for the whole battle; resets at the next battle start via scr_battle_globals_init.
// Debug mode grants unlimited. See scr_focus_class / scr_battle_focus.
global.focus_charges = 1;

// Controls hallucination / corruption overlay intensity (0 = none, 100 = max).
// Driven by low sanity and high local corruption.
global.vision_intensity = 0;

// True when an active hallucination manifestation is on screen.
// Prevents multiple manifestations stacking simultaneously.
global.manifestation_active = false;

// Timestamp of last triggered vision (microseconds via get_timer()).
// Initialised to get_timer() so the first vision waits the full cooldown.
global.last_vision_time = get_timer();

// Player movement state — read by scr_check_trigger_vision to block idle visions.
global.player_is_moving      = false;
global.last_player_move_time = get_timer();

// Minimum steps between visions (dynamically shortened at low sanity).
// Base value; scr_check_trigger_vision() computes the live cooldown.
global.vision_cooldown = 300;

// String tag of the most recently triggered vision type.
// Logged to world_state and read by obj_vision_manager for overlay colour.
global.last_vision_type = "";

// Running count of visions Benedetto has witnessed this run.
// Shown on game-over screen; feeds into narrative severity.
global.manifestation_count = 0;


// ── Combat and economy modifiers ─────────────────────────────────────────────
// Written every step by scr_apply_active_sin_effects() for active circles.
// Reset to 1.0 / false by scr_solve_circle() when a circle is cleansed.
global.shop_price_modifier   = 1.0;  // multiplied against all shop prices
global.attack_speed_modifier = 1.0;  // multiplied against base attack rate
global.attack_accuracy       = 1.0;  // 1.0 = perfect; lower = more misses

// ── Input lock (Limbo / Violence dissociation) ────────────────────────────────
// When input_locked is true, obj_player ignores movement and action input.
// input_lock_timer counts down each step; hitting 0 clears the lock.
global.input_locked     = false;
global.input_lock_timer = 0;

// ── Vision cooldown base ──────────────────────────────────────────────────────
// Base step count between visions. obj_safe_house raises this to 600 while the
// player is resting (halving vision frequency) and resets it to 300 on exit.
// scr_check_trigger_vision() reads it as its base cooldown.
global.vision_cooldown = 300;


// ── Debug mode ────────────────────────────────────────────────────────────────
// true  = placeholder rectangles visible (dev/testing mode)
// false = all placeholders hidden (player-facing build)
// Every placeholder object's Draw event checks this flag before drawing.
global.debug_mode = false;

// ── NPC persistence globals ───────────────────────────────────────────────────
// These hold the last saved state for NPC instances that need cross-session
// persistence. scr_load_world_state() overwrites them from disk; NPC Create
// events read them after event_inherited().
global.marco_met            = false;
global.marco_recognition    = 100;
global.marco_corruption_arc = 0;
global.marco_day_first_met  = 0;

// ── Codex persistence globals ─────────────────────────────────────────────────
global.codex_entries     = [];
global.codex_entry_count = 0;

// ── Player spawn globals (restored from save, applied when player Create runs) ─
global.save_player_x    = 1100;
global.save_player_y    = 1600;
global.save_player_room = "Room1";

// ── Save indicator UI state ───────────────────────────────────────────────────
// Drives obj_save_indicator's fade-out flash in the top-right corner.
global.save_indicator_timer = 0;   // counts down from 120 (2 sec); 0 = hidden
global.save_indicator_text  = "";  // "SAVED" or "LOADED"

// ── Battle globals ────────────────────────────────────────────────────────────
global.battle_active       = false;
global.battle_corruption   = 0;
global.battle_enemy_count  = 2;    // default; overwritten by scr_battle_trigger()
global.battle_turn         = 0;
global.battle_round        = 1;
global.battle_result       = "";

// Focus false-reveal (Cursed perception failure) — drawn by obj_battle_manager.
global.false_shimmer_active = false;
global.false_shimmer_gx     = 0;
global.false_shimmer_gy     = 0;
global.false_shimmer_timer  = 0;

// ── Boot sequence ─────────────────────────────────────────────────────────────
// Order matters: config (API key) must load before world state, so the key
// is known before any NPC or corruption data is restored.
scr_config_load();
scr_load_world_state();

// Disable texture filtering globally — keeps pixel art sharp at any zoom level.
gpu_set_tex_filter(false);

// ── The Arno (river that quarters the city) ───────────────────────────────────
// Geometry shared by obj_street_scene (draws the animated water + bridges) and
// obj_player (collision routes the player over the bridge gaps). A full-width
// band across the south of the map; two bridges flank the south_row building so
// each crossing lands in an open grass corridor. Tile-aligned (64px grid).
global.river_y1      = 2368;
global.river_y2      = 2560;
global.river_bridges = [[1040, 1240], [1980, 2180]];   // walkable x-spans

// ── Street dressing ───────────────────────────────────────────────────────────
// Spawn the persistent Florence street scene (paved road + market props) at a
// low depth so it sits over the cobble floor but under characters/buildings.
// It draws only in Room1 (room guard in its Draw event).
if (!instance_exists(obj_street_scene)) {
    instance_create_depth(0, 0, 160, obj_street_scene);
}

// NOTE: obj_journal and obj_vision_manager are placed directly in Room1 (see the
// room's instance list), so they are NOT spawned here — doing both would create
// duplicate instances because this Create runs before the room instances exist.
