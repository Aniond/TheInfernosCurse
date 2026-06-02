// ── Brother Anselmo (Test NPC): Create ───────────────────────────────────────
// Florence Circle 0 (Limbo) NPC — exercises the full corruption + dialogue pipeline.
// An elderly Franciscan monk who has lived near Santa Croce his entire life.

// Set npc_data BEFORE event_inherited() so the parent can reference it safely
npc_data = scr_npc_create(
    "brother_anselmo",
    "Brother Anselmo",
    "monk",
    "The monastery near Santa Croce, Florence",
    CIRCLE_LIMBO,
    "An elderly Franciscan monk. Gentle, deeply faithful, but increasingly confused. He has lived near Santa Croce his entire life and knows every face in the quarter — or did. He cannot remember the last time the bells rang at the right hour."
);

// Pre-seed one memory so the API context is never empty on first run
scr_npc_add_memory(
    npc_data,
    "player_arrived",
    "A priest from another parish came to the monastery asking strange questions about the bells.",
    "curious"
);

// Inherit shared interaction state from obj_npc_base
event_inherited();
