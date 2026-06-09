// =============================================================================
// obj_npc_rosa — Step
// =============================================================================
if (say_timer > 0) say_timer--;
if (msg_timer > 0) msg_timer--;
if (!instance_exists(obj_player)) exit;

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

// FIX 1: NO proximity auto-open. The player must FACE the bar and press E. Rosa and
// Aldo stand a cell apart so their facing cones overlap — she only claims the press
// when SHE is the more directly-faced target (strict <; Aldo uses <= so a dead tie
// resolves to him, never to both menus at once).
if (!menu_open) {
    if (!global.input_locked && keyboard_check_pressed(ord("E")) && scr_npc_player_facing(_cx, _cy, 60)) {
        var _mine = scr_npc_facing_delta(_cx, _cy);
        var _aldo = 999;
        if (instance_exists(obj_npc_innkeeper) && obj_npc_innkeeper.visible) {
            var _a = obj_npc_innkeeper;
            _aldo  = scr_npc_facing_delta(
                _a.x + sprite_get_width(_a.sprite_index)  * _a.image_xscale * 0.5,
                _a.y + sprite_get_height(_a.sprite_index) * _a.image_yscale * 0.5);
        }
        if (_mine < _aldo) {
            greeted   = true;
            menu_open = true;
            menu_sel  = 0;
            global.input_locked = true;
        }
    }
    exit;
}

// ── menu navigation (4 options) ────────────────────────────────────────────────
var _count = 4;
if (keyboard_check_pressed(vk_up))     menu_sel = (menu_sel + _count - 1) mod _count;
if (keyboard_check_pressed(vk_down))   menu_sel = (menu_sel + 1) mod _count;
if (keyboard_check_pressed(vk_escape)) { menu_open = false; global.input_locked = false; exit; }

// Relationship: each successful order/chat feeds scr_npc_log_event so Rosa
// REMEMBERS it (event_log → AI context), but the score delta applies only on
// the first interaction of each game day — gold isn't a relationship grind.
if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    var _first_today = (global.game_day != rel_day_logged);
    switch (menu_sel) {
        case 0:   // cup of wine — 2g, dulls the whispers a touch
            if (global.player_gold >= 2) {
                global.player_gold -= 2;
                scr_corruption_relieve(0.5, false);
                msg_text = "Rosa pours a cup of red. The whispers dull, a little.  (-2g)";
                if (_first_today) rel_day_logged = global.game_day;
                scr_npc_log_event(npc_id, "generous", "Ordered a cup of wine at the bar.", _first_today ? 1 : 0);
                scr_npc_show_emotion(id, "happy");
            } else msg_text = "Not enough gold for wine (2g).";
            msg_timer = 150;
            break;
        case 1:   // ribollita stew — 4g, restores half max HP
            if (global.player_gold >= 4) {
                global.player_gold -= 4;
                obj_player.hp = min(obj_player.max_hp, obj_player.hp + obj_player.max_hp * 0.5);
                msg_text = "Ribollita, hot from the hearth. You feel restored.  (-4g)";
                if (_first_today) rel_day_logged = global.game_day;
                scr_npc_log_event(npc_id, "generous", "Ordered the ribollita — ate at her counter.", _first_today ? 2 : 0);
                scr_npc_show_emotion(id, "happy");
            } else msg_text = "Not enough gold for a meal (4g).";
            msg_timer = 150;
            break;
        case 2:   // just talk — her emotion/corruption-keyed line
            say_text  = scr_npc_get_response(npc_id, "");
            say_timer = 240;
            if (_first_today) rel_day_logged = global.game_day;
            scr_npc_log_event(npc_id, "charming", "Stopped to talk at the bar.", _first_today ? 1 : 0);
            break;
        case 3: break;   // nothing, thanks
    }
    menu_open = false;
    global.input_locked = false;
}
