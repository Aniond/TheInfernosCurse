// ── NPC Base: Step ───────────────────────────────────────────────────────────

// Decrement cooldown that blocks re-opening dialogue the same frame it closed
if (interact_cooldown > 0) interact_cooldown--;

// ── Memory corruption update ──────────────────────────────────────────────────
// Driven by the corruption of the circle this NPC lives in (from npc_data.circle).
// Clamped to 0-200 to match the extended corruption scale.
npc_memory_corruption = clamp(
    global.circle_corruption[npc_data.circle], 0, 200
);

// Proximity check against the player
if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    near_player = (_dist <= interact_dist);

    // Begin dialogue on E or SPACE when close, idle, and cooled down.
    // E is the primary key; SPACE is the alternative for controller / spec compat.
    var _interact_pressed = keyboard_check_pressed(ord("E"))
                         || keyboard_check_pressed(vk_space);

    if (near_player && _interact_pressed
        && !is_talking && !api_pending && interact_cooldown == 0)
    {
        scr_npc_interact(id);
    }
} else {
    near_player = false;
}
