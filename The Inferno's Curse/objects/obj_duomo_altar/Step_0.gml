// =============================================================================
// obj_duomo_altar — Step
// =============================================================================
// 80px proximity trigger, fires ONCE per approach (re-arms on leave).
//   corruption < 100 : -5% Limbo corruption + "The altar still holds…"
//   corruption == 100: broken — no relief, a colder chronicle line
player_near = false;
if (!instance_exists(obj_player)) exit;

var _cx = (bbox_left + bbox_right)  * 0.5;
var _cy = (bbox_top  + bbox_bottom) * 0.5;
var _d  = point_distance(_cx, _cy, obj_player.x, obj_player.y);

if (_d < interact_range) {
    player_near = true;
    if (!triggered) {
        triggered = true;
        if (global.circle_corruption[CIRCLE_LIMBO] >= 100) {
            // The church has forgotten what it was — nothing left to hold.
            scr_chronicle_add("The altar is broken. It holds nothing now.");
        } else {
            scr_corruption_relieve(5);
            scr_chronicle_add("The altar still holds. Something here resists.");
        }
    }
} else {
    triggered = false;   // left the radius — next approach can fire again
}
