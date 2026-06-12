// =============================================================================
// obj_npc_rosa — Step
// =============================================================================
if (say_timer > 0) say_timer--;
if (msg_timer > 0) msg_timer--;
if (!instance_exists(obj_player)) exit;

npc_memory_corruption = clamp(global.circle_corruption[npc_data.circle], 0, 100);

// In debug she's a draggable builder object — don't auto-greet, and never hold the
// input lock (so the room-builder drag isn't bailed by line 487).
if (variable_global_exists("debug_mode") && global.debug_mode) { visible = true; on_shift = true; greeted = false; menu_open = false; global.input_locked = false; exit; }

// Schedule (scr_time_system): Rosa works the bar 14:00–22:00. Off-shift the bar
// counter is EMPTY — she stays visible so Draw_0 can paint the small "Back later."
// sign in her place, but all interaction is skipped. Re-evaluated live each step.
on_shift = scr_time_npc_active(npc_id);
visible  = true;
if (!on_shift) {
    if (menu_open) { menu_open = false; global.input_locked = false; }
    greeted = false;
    exit;
}

var _cx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _cy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;
var _near = (point_distance(_cx, _cy, obj_player.x, obj_player.y) < proximity_radius);

if (!_near) {
    if (menu_open) { menu_open = false; global.input_locked = false; }
    greeted = false;
    exit;
}

// FIX 1: Auto-approach when the player walks up to the bar.
if (!greeted && !global.input_locked) {
    greeted = true;
    api_pending = true;
    request_id = scr_ai_call("The player just approached the bar. Greet them and ask them what they want to drink or eat.", scr_npc_build_system_prompt(id));
    
    scr_open_dialogue(id, " ");
    if (instance_exists(obj_dialogue_box)) {
        obj_dialogue_box.is_loading = true;
        obj_dialogue_box.dialogue_text = "";
    }
}
