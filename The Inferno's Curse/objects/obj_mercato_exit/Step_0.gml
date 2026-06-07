// obj_mercato_exit — Step
// Fire when the player's position enters the trigger rectangle. If exit_target
// exists: pre_text set -> brief centred title card + frozen player, then load;
// pre_text empty -> load immediately. If the target room doesn't exist yet, flash
// a "coming soon" notice instead (safe for the unbuilt Signoria / Ponte Vecchio).

// ── gated transition counting down ────────────────────────────────────────────
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

var _inside = point_in_rectangle(obj_player.x, obj_player.y, x, y, x + zone_w, y + zone_h);

if (_inside && !zone_active) {
    zone_active = true;
    var _r = asset_get_index(exit_target);
    if (_r >= 0 && room_exists(_r) && room != _r) {
        if (string_length(pre_text) > 0) {
            global.transition_text = pre_text;   // drawn centred by obj_player Draw GUI
            global.input_locked     = true;      // freeze the player while the card shows
            trans_timer             = 48;        // ~0.8s, then load
        } else {
            room_goto(_r);
        }
    } else {
        if (variable_global_exists("save_indicator_text")) {
            global.save_indicator_text  = exit_label + " — coming soon";
            global.save_indicator_timer = 90;
        }
        if (variable_global_exists("world_event_log"))
            scr_world_event_log("Mercato exit (" + string(exit_target) + ") not built yet");
    }
} else if (!_inside) {
    zone_active = false;
}
