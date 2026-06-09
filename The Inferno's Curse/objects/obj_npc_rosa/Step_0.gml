// =============================================================================
// obj_npc_rosa — Step
// =============================================================================
if (say_timer > 0) say_timer--;
if (!instance_exists(obj_player)) exit;

// In debug she's a draggable builder object — don't auto-greet, and never hold the
// input lock (so the room-builder drag isn't bailed by line 487).
if (variable_global_exists("debug_mode") && global.debug_mode) { visible = true; greeted = false; global.input_locked = false; exit; }

// Schedule (scr_time_system): Rosa the barmaid works the counter 14:00–22:00.
// Off-shift she is absent — hide her and skip all interaction. (visible=false also
// suppresses her Draw mood icon.) Re-evaluated live each step as the clock turns.
if (!scr_time_npc_active(npc_id)) { visible = false; greeted = false; exit; }
visible = true;

var _cx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _cy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;
var _near = (point_distance(_cx, _cy, obj_player.x, obj_player.y) < proximity_radius);

if (!_near) { greeted = false; exit; }

// On ENTERING range → her line comes from the NPC system (mock now, AI when live).
if (!greeted) {
    greeted   = true;
    say_text  = scr_npc_get_response(npc_id, "");
    say_timer = 240;
}
// [E] to hear her again while lingering.
if (keyboard_check_pressed(ord("E"))) {
    say_text  = scr_npc_get_response(npc_id, "");
    say_timer = 240;
}
