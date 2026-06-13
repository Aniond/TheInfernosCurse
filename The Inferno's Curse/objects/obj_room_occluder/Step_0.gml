// =============================================================================
// obj_room_occluder — Step
// =============================================================================

var _player_inside = false;
if (instance_exists(obj_player)) {
    var _x2 = x + 64 * image_xscale;
    var _y2 = y + 64 * image_yscale;
    if (point_in_rectangle(obj_player.x, obj_player.y - 16, x, y, _x2, _y2)) {
        _player_inside = true;
        unveiled = true; // Memory: once you step in, it stays unveiled
    }
}

// Optional logic for linked doors: if a door is open, we can unveil the room early.
var _door_open = false;
if (linked_door_id != noone && instance_exists(linked_door_id)) {
    // Assuming standard door variables (update if a specific door system is built)
    if (variable_instance_exists(linked_door_id, "is_open") && linked_door_id.is_open) {
        _door_open = true;
        unveiled = true; // Memory applies to door openings as well
    }
}

// Fade out permanently if we ever entered; fade in to black out the room otherwise.
if (unveiled || _player_inside || _door_open) {
    target_alpha = 0.0;
} else {
    target_alpha = 1.0;
}

// Smooth fade (10% per frame)
alpha = lerp(alpha, target_alpha, 0.1);
