// =============================================================================
// obj_unit_base — Create
// Base for all battle units (Benedetto, Marco, Dante, Hollow enemies).
// Child objects call event_inherited() then override what they need.
// =============================================================================

// ── Grid position ─────────────────────────────────────────────────────────────
grid_x      = 0;
grid_y      = 0;
prev_grid_x = -1;   // position before last move; teleport never returns here
prev_grid_y = -1;

// ── Stats ─────────────────────────────────────────────────────────────────────
unit_name    = "Unit";
max_hp       = 100;
hp           = max_hp;
max_ap       = 3;       // action points per turn
ap           = 0;       // current AP (reset by scr_battle_start_round)
team         = 0;       // 0 = player side, 1 = enemy side
is_hollow    = false;   // set true on Hollow enemy units

// ── Turn flags ────────────────────────────────────────────────────────────────
is_active_turn      = false;
turn_done           = false;   // set true by unit when it finishes; manager reads this
sanity_zero_message = false;   // used by Benedetto's frozen display

// ── Status effects ────────────────────────────────────────────────────────────
// String array. Valid values: "forgotten", "frozen", "burning", etc.
status_effects = [];

// ── Limbo teleport tracking ───────────────────────────────────────────────────
// Incremented before each recursive chain call; reset to 0 after resolution.
// Limits chain teleports to 2 depth maximum.
teleport_chain_count = 0;

// ── Display ───────────────────────────────────────────────────────────────────
unit_color = c_white;   // overridden in child Create events

// ── SnowState FSM ─────────────────────────────────────────────────────────────
// States: "waiting" | "acting" | "forgotten" | "frozen" | "dead"
fsm = new SnowState("waiting");

fsm.add("waiting", {
    enter: function() {
        is_active_turn = false;
    },
});

fsm.add("acting", {
    enter: function() {
        is_active_turn = true;
        sanity_warned_this_turn = false;   // reset warning flag each new turn
    },
});

fsm.add("forgotten", {
    enter: function() {
        is_active_turn = false;
    },
});

fsm.add("frozen", {
    enter: function() {
        is_active_turn = false;
    },
});

fsm.add("dead", {
    enter: function() {
        hp             = 0;
        is_active_turn = false;
    },
});
