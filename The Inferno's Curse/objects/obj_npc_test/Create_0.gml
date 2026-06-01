// ── Elder Maren (Test NPC): Create ───────────────────────────────────────────
// Limbo NPC used to exercise the full corruption + dialogue pipeline.
// Replace with proper NPC objects as content is built.

// Set npc_data BEFORE event_inherited() so the parent can reference it safely
npc_data = scr_npc_create(
    "elder_maren",
    "Elder Maren",
    "elder",
    "The Threshold",      // Limbo's entry zone — edge of the first circle
    CIRCLE_LIMBO,
    "Haunted and wise, slowly losing her memories to Limbo's corruption"
);

// Pre-seed one memory so the API context is never empty on first run
scr_npc_add_memory(
    npc_data,
    "player_arrived",
    "A stranger came through the Threshold gate.",
    "curious"
);

// Inherit shared interaction state from obj_npc_base
event_inherited();
