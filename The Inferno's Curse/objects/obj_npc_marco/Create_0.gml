// =============================================================================
// obj_npc_marco — Create Event
// =============================================================================
// Marco is a Florentine baker who sells bread near the Arno. He is one of the
// first people Benedetto sees consumed by Limbo's corruption — not violently,
// but quietly. The forgetting. A good man becoming a hollow one.
//
// Set npc_data BEFORE event_inherited() so obj_npc_base can reference it safely.
// =============================================================================

npc_data = scr_npc_create(
    "marco",
    "Marco",
    "baker and father of three, market district near the Arno",
    "The market district near the Arno, Florence, 1300 AD",
    CIRCLE_LIMBO,
    "Warm, generous, proud of his bread, devoted to his family, simple faith. " +
    "Laughs easily. Remembers everyone by name. Always has bread to offer. " +
    "Worried about Guelph and Ghibelline tensions but tries to stay neutral. " +
    "Genuinely good man — the kind Florence is full of and never notices until they are gone."
);

// ── Marco-specific state ──────────────────────────────────────────────────────
marco_met           = false;  // has Benedetto spoken to him before
marco_recognition   = 100;    // 0-100 — how clearly Marco recognises Benedetto
marco_children      = "Sofia, Luca, Pietro";
marco_day_first_met = 0;      // day_count when they first spoke
marco_corruption_arc = 0;     // 0-4 — which arc Marco is currently in (see Step)
bread_offering_made = false;  // true once Marco has offered bread this run

// Pre-seed memory so the API always has context on first interaction
scr_npc_add_memory(
    npc_data,
    "first_seen",
    "A priest from another parish passed by the stall near the Arno bridge.",
    "neutral"
);

// Inherit shared NPC state from obj_npc_base
event_inherited();

// ── Sprites ───────────────────────────────────────────────────────────────────
// Marco stands at his stall facing the street (south). The stall draws behind
// him; a loaf sits on the counter in front.
npc_sprite  = spr_npc_marco_south;
bg_sprite   = spr_marco_stall;
prop_sprite = spr_item_bread;
npc_scale   = 0.75;   // shrink the whole bakery assembly to sit cleanly on the street

// Relocate to the old empty-stall spot on the right of the market (was 1200,1600).
// Done in code so no Room1.yy edit is needed; reconcile in the room editor later.
x = 1720;
y = 1640;

// ── Restore from saved world state ───────────────────────────────────────────
// scr_load_world_state() runs before room instances are created, so globals
// already hold the correct saved values by the time Marco's Create fires.
marco_met            = global.marco_met;
marco_recognition    = global.marco_recognition;
marco_corruption_arc = global.marco_corruption_arc;
marco_day_first_met  = global.marco_day_first_met;
bread_offering_made  = global.marco_met; // already offered bread if they've met
