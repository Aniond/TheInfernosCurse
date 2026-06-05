// =============================================================================
// obj_safe_house — Step Event
// =============================================================================
// Detects whether the player is within the 64x64 footprint and, while inside,
// slows visions and eases Limbo corruption over time.
//
// Overlap is tested with point_in_rectangle rather than collision masks, since
// these objects have no sprite. The footprint runs from (x, y) to (x+64, y+64).

player_inside = false;

if (instance_exists(obj_player)) {
    player_inside = point_in_rectangle(
        obj_player.x, obj_player.y,
        x, y, x + 64, y + 64
    );
}

if (player_inside) {
    // ── Resting: tick toward the next sanity restore ──────────────────────────
    rest_timer++;
    if (rest_timer >= rest_interval) {
        scr_corruption_relieve(3);
        rest_timer = 0;
        show_debug_message("Resting...");
    }

    // Double the vision cooldown so hallucinations come half as often.
    // scr_check_trigger_vision() reads this as its base cooldown.
    global.vision_cooldown = 600;
} else {
    // Back outside — normal vision frequency, rest progress lost.
    global.vision_cooldown = 300;
    rest_timer = 0;
}
