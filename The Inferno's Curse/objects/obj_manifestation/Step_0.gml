// =============================================================================
// obj_manifestation — Step Event
// =============================================================================

// ── Destroy if no vision is active ───────────────────────────────────────────
// Manifestations exist only during a triggered vision. When the manager
// clears, they dissolve.
if (instance_exists(obj_vision_manager)) {
    if (obj_vision_manager.vision_timer <= 0) {
        instance_destroy();
        exit;
    }
} else {
    instance_destroy();
    exit;
}

// ── Drift movement ────────────────────────────────────────────────────────────
// Passive drift while not fully aware. Bounces off room edges so entities
// stay visible rather than wandering off screen.
if (!is_aware) {
    x += lengthdir_x(drift_speed, drift_dir);
    y += lengthdir_y(drift_speed, drift_dir);

    // Bounce off room boundaries.
    if (x < 0 || x > room_width)  { drift_dir = 180 - drift_dir; x = clamp(x, 0, room_width);  }
    if (y < 0 || y > room_height) { drift_dir = -drift_dir;       y = clamp(y, 0, room_height); }
}

// ── Awareness: facing-arc check ───────────────────────────────────────────────
// Awareness rises when the player is looking roughly toward this entity.
// Uses the angle between this entity's position and the player's facing
// direction (stored in obj_player.facing_dir, expected range 0-360).
if (instance_exists(obj_player)) {
    var _angle_to_entity = point_direction(obj_player.x, obj_player.y, x, y);

    // Facing dir — fall back to 0 if the variable doesn't exist yet.
    var _player_facing  = variable_instance_exists(obj_player, "facing_dir")
                          ? obj_player.facing_dir : 0;

    var _angle_diff = abs(angle_difference(_angle_to_entity, _player_facing));

    // Within 90 degrees of facing: gaining awareness.
    if (_angle_diff < 90) {
        awareness_level += 0.5;
    } else {
        awareness_level -= 0.1;
    }
    awareness_level = clamp(awareness_level, 0, 100);

    // ── Become aware ─────────────────────────────────────────────────────────
    if (awareness_level >= 100 && !is_aware) {
        is_aware = true;
    }

    // ── Approach when aware ───────────────────────────────────────────────────
    if (is_aware) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (_dist > _approach_stop_distance) {
            var _spd = (global.sanity < 50) ? 1.0 : 0.5; // faster at low sanity
            var _dir = point_direction(x, y, obj_player.x, obj_player.y);
            x += lengthdir_x(_spd, _dir);
            y += lengthdir_y(_spd, _dir);
        }
        // It never attacks — it only watches from 64px.
    }
}
