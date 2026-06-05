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

// ── Direct instance vars (for scr_npc_build_system_prompt spec interface) ────
// These mirror npc_data struct fields so both access patterns work.
// Children should set these AND pass equivalent values to scr_npc_create().
npc_name        = npc_data.name;
npc_role        = npc_data.role;
npc_location    = npc_data.location;
npc_personality = npc_data.personality;

// ── Sprites (optional — children assign; noone = grey placeholder) ────────────
// npc_sprite:  the character's facing sprite (drawn centered on x,y).
// bg_sprite:   a static prop drawn BEHIND the NPC (e.g. Marco's stall).
// prop_sprite: a static prop drawn IN FRONT (e.g. bread on the counter).
npc_sprite  = noone;
bg_sprite   = noone;
prop_sprite = noone;
npc_scale   = 1;       // overall display scale for sprite + bg/prop (children may shrink)

// ── API state ─────────────────────────────────────────────────────────────────
// api_response: last text received from Claude. Mirrors npc_data.last_response.
// api_pending:  true while an async request is in flight.
// request_id:   async HTTP request ID returned by http_request(). -1 = none in flight.
api_response = "";
api_pending  = false;
request_id   = -1;

// ── Memory corruption ─────────────────────────────────────────────────────────
// Tracks how corrupted this NPC's perception is, driven by their home circle.
// Updated every step. Drives Draw colour and system prompt tone.
// Scale: 0-100 (the single corruption scale).
npc_memory_corruption = 0;
