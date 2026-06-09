// =============================================================================
// obj_npc_stableboy — Step
// =============================================================================
if (msg_timer > 0) msg_timer--;
if (!instance_exists(obj_player)) exit;

// In debug mode Pietro is a draggable builder object — never open the menu.
if (variable_global_exists("debug_mode") && global.debug_mode) {
    visible = true;
    menu_open = false; global.input_locked = false;   // never hold the input lock in debug → drag works
    player_near = false; greeted = false;
    exit;
}

// Schedule (scr_time_system): the stable boy works 05:00–12:00. Off-shift he is
// absent — hide him, close any open menu, and skip interaction. Re-evaluated live.
if (!scr_time_npc_active("stable_boy")) {
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
// Corruption-keyed emotion on each fresh approach: Pietro reads the taint on
// Benedetto before a word is spoken (suspicious 50+, afraid 75+, terrified 100).
if (!player_near) {
    var _c0 = global.circle_corruption[CIRCLE_LIMBO];
    if      (_c0 >= 100) scr_npc_show_emotion(id, "terrified");
    else if (_c0 >= 75)  scr_npc_show_emotion(id, "afraid");
    else if (_c0 >= 50)  scr_npc_show_emotion(id, "suspicious");
}
player_near = true;

// No proximity auto-open: the player must FACE Pietro and press E.
if (!menu_open) {
    if (!global.input_locked && keyboard_check_pressed(ord("E")) && scr_npc_player_facing(_cx, _cy, 60)) {
        greeted   = true;
        menu_open = true;
        menu_sel  = 0;
        global.input_locked = true;
    }
    exit;
}

// ── menu navigation (3 options) ────────────────────────────────────────────────
if (keyboard_check_pressed(vk_down)) menu_sel = (menu_sel + 1) mod 3;
if (keyboard_check_pressed(vk_up))   menu_sel = (menu_sel + 2) mod 3;
if (keyboard_check_pressed(vk_escape)) { menu_open = false; global.input_locked = false; exit; }

if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    if (menu_sel == 2) {                                     // "Never mind"
        menu_open = false; global.input_locked = false; exit;
    }
    if (menu_sel == 0) {
        // STABLE MY HORSE — placeholder until the horse system arrives.
        if      (_corr >= 100) msg_text = "Pietro can't take his eyes off you. \"...The stalls are full, signore. They're full.\"";
        else if (_corr >= 75)  msg_text = "\"I— I would, signore, but the horses won't settle with... please.\" (Horse stabling — future update.)";
        else                   msg_text = "\"When you've a horse, signore, she'll want for nothing here.\" (Horse stabling — future update.)";
        // Asking for honest work done is patronage Pietro remembers.
        var _delta = 0;
        if (global.game_day != rel_day_logged) {
            rel_day_logged = global.game_day;
            _delta = 2;
        }
        scr_npc_log_event("stableboy", "polite", "Asked to stable a horse.", _delta);
        if (_corr < 50) scr_npc_show_emotion(id, "happy");
    } else {
        // CLAIM MY HORSE — placeholder until the horse system arrives.
        if (_corr >= 75) msg_text = "Pietro checks the ledger without coming closer. \"No horse of yours here, signore.\"";
        else             msg_text = "\"No horse of yours in my stalls yet, signore.\" (Horse claiming — future update.)";
        scr_npc_log_event("stableboy", "polite", "Asked after a horse.", 0);
    }
    msg_timer = 180;
    menu_open = false;
    global.input_locked = false;
}
