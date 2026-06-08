// =============================================================================
// obj_duomo_save_point — Step
// =============================================================================
pulse += 0.08;
if (cooldown > 0) cooldown--;

player_near = false;
if (!instance_exists(obj_player)) exit;

var _d = point_distance(x, y, obj_player.x, obj_player.y);
if (_d < interact_range) {
    player_near = true;
    if (keyboard_check_pressed(ord("E")) && cooldown == 0) {
        scr_save_world_state();
        scr_chronicle_add("The cathedral remembers you.");
        cooldown = 40;
    }
}
