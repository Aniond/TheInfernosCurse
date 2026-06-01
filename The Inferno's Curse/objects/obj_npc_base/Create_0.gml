// ── NPC Base: Create ─────────────────────────────────────────────────────────
// Children call event_inherited() AFTER setting npc_data so this code can
// safely reference it. If obj_npc_base is placed directly, the fallback below runs.

near_player       = false;
interact_dist     = 80;  // pixels at which the interact prompt appears
interact_cooldown = 0;   // prevents re-opening dialogue the same frame it closed
is_talking        = false;

// Fallback if child forgot to set npc_data before calling event_inherited()
if (!variable_instance_exists(id, "npc_data")) {
    npc_data = scr_npc_create(
        "unknown_" + string(id), "Wanderer", "wanderer",
        "Somewhere", CIRCLE_LIMBO, "Confused and lost"
    );
}
