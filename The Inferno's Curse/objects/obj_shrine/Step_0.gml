// =============================================================================
// obj_shrine — Step Event
// =============================================================================
// Counts down the cooldown, detects the player, and handles the prayer input.
// NOTE: all rendering (cross, glow, prompt) lives in the Draw event — GML draw
// functions do nothing when called from Step.

// ── Cooldown ──────────────────────────────────────────────────────────────────
if (cooldown > 0) {
    cooldown--;
}
if (cooldown <= 0) {
    shrine_active = true;
}

// ── Player proximity + prayer ─────────────────────────────────────────────────
player_near = false;

if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);

    if (_dist < interact_range) {
        player_near = true;

        if (keyboard_check_pressed(ord("E"))) {
            if (shrine_active && global.circle_corruption[0] < 50) {
                // The shrine answers.
                scr_corruption_relieve(10);
                scr_time_advance_hours(2);   // prayer takes time — advance 2 hours (scr_time_system)
                shrine_active = false;
                cooldown      = cooldown_max;
                show_debug_message("Corruption eased at shrine");
            } else if (global.circle_corruption[0] >= 50) {
                // Corruption has silenced this place.
                show_debug_message("The shrine is dark. It does not respond.");
            }
        }
    }
}
