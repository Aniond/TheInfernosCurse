// =============================================================================
// obj_npc_marco — Create Event
// =============================================================================
// Marco is a Florentine baker who sells bread near the Arno. He is one of the
// first people Benedetto sees consumed by Limbo's corruption — not violently,
// but quietly. The forgetting. A good man becoming a hollow one.
//
// Set npc_data BEFORE event_inherited() so obj_npc_base can reference it safely.
// =============================================================================

npc_id = "marco";
npc_data = scr_npc_get(npc_id);

// ── Marco-specific state ──────────────────────────────────────────────────────
marco_met           = false;  // has Benedetto spoken to him before
marco_recognition   = 100;    // 0-100 — how clearly Marco recognises Benedetto
marco_children      = "Sofia, Luca, Pietro";
marco_day_first_met = 0;      // day_count when they first spoke
marco_corruption_arc = 0;     // 0-4 — which arc Marco is currently in (see Step)
bread_offering_made = false;  // true once Marco has offered bread this run

// Pre-seed memory so the API always has context on first interaction
// If event_log is empty, seed it once.
if (array_length(npc_data.event_log) == 0) {
    scr_npc_log_event(npc_id, "neutral", "A priest from another parish passed by the stall near the Arno bridge.", 0);
}


// Inherit shared NPC state from obj_npc_base
event_inherited();

// ── Sprites ───────────────────────────────────────────────────────────────────
// Marco lives at the Fornaio on the Ponte Vecchio: the bridge's shop front IS
// his bakery, so no stall backdrop there — just Marco and his bread. Anywhere
// else (fallback placements) the freestanding stall assembly returns.
npc_sprite  = spr_npc_marco_south;
bg_sprite   = (room_get_name(room) == "Room_ponte_vecchio") ? noone : spr_marco_stall;
prop_sprite = spr_item_bread;
npc_scale   = 0.75;   // matches bridge shopkeeper scale; sits cleanly on the walkway

// Position comes from placement (scr_ponte_place at the Fornaio / F8 layout) —
// the old hardcoded relocation to the wiped Room_florence was removed 2026-06-10;
// it was teleporting him off the 1280px bridge to x=1340.

// ── Restore from saved world state ───────────────────────────────────────────
// scr_load_world_state() runs before room instances are created, so globals
// already hold the correct saved values by the time Marco's Create fires.
marco_met            = global.marco_met;
marco_recognition    = global.marco_recognition;
marco_corruption_arc = global.marco_corruption_arc;
marco_day_first_met  = global.marco_day_first_met;
bread_offering_made  = global.marco_met; // already offered bread if they've met
