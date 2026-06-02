// =============================================================================
// obj_door_placeholder — Step Event
// =============================================================================

near_player = instance_exists(obj_player)
    && point_distance(x + door_w * 0.5, y + door_h * 0.5,
                      obj_player.x, obj_player.y) < prompt_range;

// Placeholder interact — fires when player presses E while near the door
if (near_player && keyboard_check_pressed(ord("E"))) {
    show_debug_message("[Door] Interact triggered — door interior not yet implemented.");
    scr_save_world_state(); // auto-save on building entry
}
