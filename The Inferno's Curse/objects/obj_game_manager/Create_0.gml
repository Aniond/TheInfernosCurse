// =============================================================================
// obj_game_manager — Create Event
// =============================================================================
// The single source of truth for all global game state.
// This object is PERSISTENT — one instance survives every room transition.
// It is placed FIRST in Florence's creation order so every other object can
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

// ── Day/night clock (scr_time_system) ────────────────────────────────────────
// First pass — 1 real second = 5 game minutes. Tune TIME_RATE after testing.
// game_hour/minute/day are the canonical clock; time_of_day/is_night are kept
// in sync for backwards compatibility with the existing save/debug systems.
global.game_hour   = 6;
global.game_minute = 0;
global.game_day    = 1;
global.__time_accum = 0;
global.time_frozen  = false;   // debug: T pauses the day/night clock (scr_time_step early-outs)

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
global.api_call_count  = 0;        // debug overlay: Claude API calls this run
global.last_save_info  = "never";  // debug overlay: last save stamp


// ── Player psychological state ────────────────────────────────────────────────
// No separate sanity stat — Limbo corruption IS the madness axis. Benedetto only
// thinks he is going insane. Lucidity is derived from it: scr_lucidity().

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
global.debug_mode     = false;
global.debug_show_log = true;    // F10 hides/shows the EVENT LOG panel
global.ai_disabled    = false;   // F11 kills Claude API calls during testing (no tokens spent)

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
global.save_player_x    = 1024;   // centre of the cobblestone street (street is y 928–1120)
global.save_player_y    = 1024;
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

// ── Room builder + Florence collision ─────────────────────────────────────────────
// Props + all of Florence's code-spawned collision are built by scr_room1_build() (the
// call is below, after the garden geometry) and rebuilt by Step on every re-entry.

// Disable texture filtering globally — keeps pixel art sharp at any zoom level.
gpu_set_tex_filter(false);

// Frame-rate cap — lock the game loop to 60 fps. The debug overlay's second
// number is fps_real (raw headroom: how fast it COULD render) and can read in the
// thousands; that is NOT the actual rate, which this pins at 60.
game_set_speed(60, gamespeed_fps);

// ── The Arno (river that quarters the city) ───────────────────────────────────
// Geometry shared by obj_street_scene (draws the animated water + bridges) and
// obj_player (collision routes the player over the bridge gaps). A full-width
// band running just below the central park; two bridges flank the centre so each
// crossing feeds off the piazza into the south grass approach. Tile-aligned (64px).
global.river_y1      = 1536;   // shrunk 2048 world: river runs BELOW the central park
global.river_y2      = 1728;   // 192px band (3 × 64px water tiles)
global.river_bridges = [[640, 896]];   // ONE crossing = the Ponte Vecchio (west). The old
                                       // east "brick bridge" was removed -> that span is plain river now.

// (The Arno river/bank collision, the bridge handrails and the Ponte Vecchio entry
//  zones are built by scr_room1_build() — see the Florence build call below the garden
//  geometry. They are rebuilt on every Florence re-entry, so returning from the bridge
//  room restores them.)

// ── Giardino delle Rose geometry + hedge collision ────────────────────────────
// Geometry OWNED here and read by obj_street_scene Draw (which paints the parterre)
// so the visuals and the collision can never drift. The four boxwood-hedged rose
// quadrants are made solid with invisible obj_wall boxes; the outer stone walkway
// and the gravel cross-path stay open, so the player is guided onto the paths. The
// central fountain is left pass-through — a wall there would plug the 56px cross-
// path (it is barely wider than the 32px player).
global.garden_cx  = 380;    // garden centre  (== fountain centre)
global.garden_cy  = 1317;
global.garden_hw  = 220;    // half width  (outer paving edge)
global.garden_hh  = 190;    // half height
global.garden_wt  = 32;     // outer paving ring thickness
global.garden_cph = 28;     // cross-path half width
// ── Florence props + collision (built here; rebuilt by Step on every re-entry) ─────
// This manager is PERSISTENT (its Create runs once), and a room change destroys
// Florence's code-spawned props + collision — so Step calls scr_room1_build() again
// whenever we return to Florence. Build the first time now.
global.__room1_built = false;
if (room == Room1) { scr_room1_build(); global.__room1_built = true; }

// ── Street dressing ───────────────────────────────────────────────────────────
// Spawn the persistent Florence street scene (paved road + market props) at a
// low depth so it sits over the cobble floor but under characters/buildings.
// It draws only in Florence (room guard in its Draw event).
if (!instance_exists(obj_street_scene)) {
    instance_create_depth(0, 0, 160, obj_street_scene);
}

// (Mercato market collision is built by the room-builder loader — it lays an
//  obj_wall footprint under each "solid" obj_mercato_prop. See scr_room_builder.)

// NOTE: obj_journal and obj_vision_manager are placed directly in Florence (see the
// room's instance list), so they are NOT spawned here — doing both would create
// duplicate instances because this Create runs before the room instances exist.


// ── Global camera (FF6 follow-and-clamp) ──────────────────────────────────────
// Default for every room going forward — see scr_camera. Tune via global.cam_*.
scr_camera_init();

// ── Economy (minimal) — player gold + guild reputation (drives the inn menu) ────
if (!variable_global_exists("player_gold"))      global.player_gold      = 50;
if (!variable_global_exists("guild_reputation")) global.guild_reputation = 50;   // 0-100; 50 = medium tier

// ── NPC behaviour + event tracking (mock AI; ready for live swap) ───────────────
scr_npc_system_init();


// ── LOAD POINT: start inside the cathedral (Room_duomo) ───────────────────────
// Boot Benedetto straight into the Basilica interior instead of the Florence
// street. This Create runs ONCE (obj_game_manager is persistent), so walking back
// out the south door to Florence does NOT bounce you back here. The player spawns at
// Room_duomo's instance position (the south doorway, 640,1252).
// Flip DUOMO_LOAD_POINT (scr_duomo) to false to restore the normal Florence start.
if (INN_LOAD_POINT && room == Room1) {
    room_goto(Room_locanda_rosa_camuna);   // TEMP boot for testing the inn (flip INN_LOAD_POINT to false)
} else if (DUOMO_LOAD_POINT && room == Room1) {
    room_goto(Room_duomo);
}
