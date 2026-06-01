// ── NPC Base: Step ───────────────────────────────────────────────────────────

// Decrement cooldown that blocks re-opening dialogue the same frame it closed
if (interact_cooldown > 0) interact_cooldown--;

// Proximity check against the player
if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    near_player = (_dist <= interact_dist);

    // Begin dialogue on E press when close, idle, and cooled down
    if (near_player && keyboard_check_pressed(ord("E"))
        && !is_talking && interact_cooldown == 0)
    {
        is_talking          = true;
        global.dialogue_npc = id;

        // Fetch response — instant mock, or async if API key is set
        scr_npc_get_dialogue(npc_data, "");

        // Spawn dialogue box if one isn't already open
        if (!instance_exists(obj_dialogue_box)) {
            instance_create_layer(0, 0, "Instances", obj_dialogue_box);
        }
    }
} else {
    near_player = false;
}
