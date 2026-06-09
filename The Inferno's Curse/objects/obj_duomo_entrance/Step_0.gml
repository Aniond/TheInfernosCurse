// =============================================================================
// obj_duomo_entrance — Step
// =============================================================================
// Press E within range → enter the cathedral. The player is dropped just inside
// the south doorway of Room_duomo (matching where the interior exit returns from).
player_near = false;
if (room != Room_florence) exit;
if (!instance_exists(obj_player)) exit;

var _d = point_distance(x, y, obj_player.x, obj_player.y);
if (_d < interact_range) {
    player_near = true;
    if (keyboard_check_pressed(ord("E"))) {
        global.player_spawn_override = [640, 1216];   // inside the Duomo entrance
        room_goto(Room_duomo);
    }
}
