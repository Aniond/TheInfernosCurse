// =============================================================================
// obj_npc_innkeeper — Step
// =============================================================================
if (msg_timer > 0) msg_timer--;
if (!instance_exists(obj_player)) exit;

// In debug mode the innkeeper is a draggable builder object — never open the menu.
if (variable_global_exists("debug_mode") && global.debug_mode) {
    visible = true;
    menu_open = false; global.input_locked = false;   // never hold the input lock in debug → drag works
    player_near = false; greeted = false;
    exit;
}

// Schedule (scr_time_system): the innkeeper tends the bar 06:00–23:00. Off-shift he is
// absent — hide him, close any open menu, and skip interaction. Re-evaluated live.
if (!scr_time_npc_active("innkeeper")) {
    visible = false;
    if (menu_open) { menu_open = false; global.input_locked = false; }
    player_near = false; greeted = false;
    exit;
}
visible = true;

var _cx = x + sprite_get_width(sprite_index)  * image_xscale * 0.5;
var _cy = y + sprite_get_height(sprite_index) * image_yscale * 0.5;
var _near = (point_distance(_cx, _cy, obj_player.x, obj_player.y) < proximity_radius);

// leaving the zone closes the menu + re-arms the greeting
if (!_near) {
    if (menu_open) { menu_open = false; global.input_locked = false; }
    player_near = false;
    greeted = false;
    exit;
}
player_near = true;

// FIX 1: NO proximity auto-open. Walking past the counter does nothing. The player
// must FACE the counter (turn toward Aldo) and press E to open the rest menu.
// Aldo and Rosa stand a cell apart so their facing cones overlap — he only claims
// the press when he is at least as directly faced as her (<= : ties go to him,
// strict < on her side, so one E press opens exactly ONE menu). Rooms are HIS only;
// drinks/food are hers (division of roles).
if (!menu_open) {
    if (!global.input_locked && keyboard_check_pressed(ord("E")) && scr_npc_player_facing(_cx, _cy, 60)) {
        var _mine = scr_npc_facing_delta(_cx, _cy);
        var _rosa = 999;
        if (instance_exists(obj_npc_rosa) && obj_npc_rosa.on_shift) {
            var _r = obj_npc_rosa;
            _rosa  = scr_npc_facing_delta(
                _r.x + sprite_get_width(_r.sprite_index)  * _r.image_xscale * 0.5,
                _r.y + sprite_get_height(_r.sprite_index) * _r.image_yscale * 0.5);
        }
        if (_mine <= _rosa) {
            greeted   = true;
            menu_open = true;
            menu_sel  = 0;
            global.input_locked = true;
        }
    }
    exit;
}

// ── menu navigation (2 options) ────────────────────────────────────────────────
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) menu_sel = (menu_sel + 1) mod 2;
if (keyboard_check_pressed(vk_escape)) { menu_open = false; global.input_locked = false; exit; }

if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    if (menu_sel == 1) {                                     // "Maybe later"
        menu_open = false; global.input_locked = false; exit;
    }
    // Buy the room offered for the player's reputation tier.
    var _tier = scr_inn_rep_tier();
    var _cost, _relief, _name;
    if      (_tier == "high")   { _name = "The Merchant's Suite"; _cost = 20; _relief = 3;   }
    else if (_tier == "medium") { _name = "Standard Room";        _cost = 10; _relief = 1.5; }
    else                        { _name = "Common Cot";           _cost = 4;  _relief = 0;   }

    if (global.player_gold >= _cost) {
        global.player_gold -= _cost;
        obj_player.hp = obj_player.max_hp;                   // full rest
        if (_relief > 0) scr_corruption_relieve(_relief, false);
        scr_time_sleep();                                    // sleep → skip to 06:00 next day (scr_time_system)
        msg_text = "You take " + _name + ". The night passes.  (-" + string(_cost) + "g)";
        scr_chronicle_add("A night's rest at the Locanda della Rosa Camuna — " + _name + ".");
    } else {
        msg_text = "Not enough gold for " + _name + " (" + string(_cost) + "g).";
    }
    msg_timer = 150;
    menu_open = false;
    global.input_locked = false;
}
