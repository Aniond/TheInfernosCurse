// obj_mercato_exit ?" Step
// Fire when the player's position enters the trigger rectangle. If exit_target
// exists: pre_text set -> brief centred title card + frozen player, then load;
// pre_text empty -> load immediately. If the target room doesn't exist yet, flash
// a "coming soon" notice instead (safe for the unbuilt Signoria / Ponte Vecchio).

// ?"?" Gatehouse atmospheric fade-to-black sequence ?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"
if (transition_triggered) {
    // 1. Forced movement: continue walking in the trigger direction
    if (instance_exists(obj_player)) {
        var _dx = 0;
        var _dy = 0;
        var _spr_idx = 6; // default walk south
        
        if (trigger_dir == "south") {
            _dy = 1;
            _spr_idx = 6;
        } else if (trigger_dir == "north") {
            _dy = -1;
            _spr_idx = 2;
        } else if (trigger_dir == "east") {
            _dx = 1;
            _spr_idx = 0;
        } else if (trigger_dir == "west") {
            _dx = -1;
            _spr_idx = 4;
        } else {
            // fallback: check player's current facing direction to infer
            var _dir_idx = (round(obj_player.facing_dir / 45)) mod 8;
            _spr_idx = _dir_idx;
            _dx = lengthdir_x(1, obj_player.facing_dir);
            _dy = lengthdir_y(1, obj_player.facing_dir);
        }
        
        obj_player.x += _dx * obj_player.base_move_spd * 0.5;
        obj_player.y += _dy * obj_player.base_move_spd * 0.5;
        obj_player.sprite_index = obj_player.walk_sprites[_spr_idx];
        obj_player.image_speed  = 0.5;
    }

    // 2. Fade alpha increases
    fade_alpha = min(fade_alpha + fade_speed, 1.0);

    // 3. Complete transition when fully black
    if (fade_alpha >= 1.0) {
        global.input_locked = false;
        var _r = asset_get_index(exit_target);
        if (_r >= 0 && room_exists(_r) && room != _r) {
            room_goto(_r);
        }
    }
    exit;
}

// ?"?" gated transition counting down (pre_text title card style) ?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"
if (trans_timer > 0) {
    trans_timer -= 1;
    if (trans_timer <= 0) {
        global.transition_text = "";
        global.input_locked     = false;
        var _r = asset_get_index(exit_target);
        if (_r >= 0 && room_exists(_r) && room != _r) room_goto(_r);
    }
    exit;
}

if (!instance_exists(obj_player)) exit;

// In debug mode, transitions are draggable TUNING objects ?" never fire them, so you
// can reposition a zone (even onto the player) without being warped out of the room.
if (variable_global_exists("debug_mode") && global.debug_mode) exit;

var _inside = point_in_rectangle(obj_player.x, obj_player.y, x, y, x + zone_w, y + zone_h);

// Verify movement direction based on trigger_dir
var _dir_ok = false;
if (trigger_dir == "south") {
    _dir_ok = (obj_player.y > obj_player.yprevious || obj_player.facing_dir == 270);
} else if (trigger_dir == "north") {
    _dir_ok = (obj_player.y < obj_player.yprevious || obj_player.facing_dir == 90);
} else if (trigger_dir == "east") {
    _dir_ok = (obj_player.x > obj_player.xprevious || obj_player.facing_dir == 0);
} else if (trigger_dir == "west") {
    _dir_ok = (obj_player.x < obj_player.xprevious || obj_player.facing_dir == 180);
} else {
    _dir_ok = true; // "any"
}

if (_inside) {
    if (!zone_active && _dir_ok) {
        zone_active = true;
        var _r = asset_get_index(exit_target);
        if (_r >= 0 && room_exists(_r) && room != _r) {
            // optional arrival override - place the player at a set spot in the new room
            if (variable_instance_exists(id, "arrive_x") && !is_undefined(arrive_x)) {
                global.player_spawn_override = [arrive_x, arrive_y];
            }

            if (string_length(pre_text) == 0) {
                // Lock state to start the fade
                transition_triggered = true;
                global.input_locked  = true; // Freeze player input
            } else {
                global.transition_text = pre_text;   // drawn centred by obj_player Draw GUI
                global.input_locked     = true;      // freeze the player while the card shows
                trans_timer             = 48;        // ~0.8s, then load
            }
        } else {
            if (variable_global_exists("save_indicator_text")) {
                global.save_indicator_text  = exit_label + " - coming soon";
                global.save_indicator_timer = 90;
            }
            if (variable_global_exists("world_event_log"))
                scr_world_event_log("Mercato exit (" + string(exit_target) + ") not built yet");
        }
    }
} else {
    zone_active = false;
}
