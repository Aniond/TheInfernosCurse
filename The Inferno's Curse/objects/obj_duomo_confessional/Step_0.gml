// =============================================================================
// obj_duomo_confessional — Step
// =============================================================================
if (cooldown > 0) cooldown--;

player_near = false;
if (!instance_exists(obj_player)) exit;

var _corr = global.circle_corruption[CIRCLE_LIMBO];
var _cx   = (bbox_left + bbox_right)  * 0.5;
var _cy   = (bbox_top  + bbox_bottom) * 0.5;
var _d    = point_distance(_cx, _cy, obj_player.x, obj_player.y);

// ── Resolve an open prompt (Y / N / ESC) ──────────────────────────────────────
if (prompt_active) {
    if (keyboard_check_pressed(ord("Y")) || keyboard_check_pressed(vk_enter)) {
        scr_corruption_relieve(10);
        scr_chronicle_add("I confessed. I did not say everything.");
        prompt_active       = false;
        global.input_locked = false;
        cooldown            = 20;
    } else if (keyboard_check_pressed(ord("N")) || keyboard_check_pressed(vk_escape)) {
        prompt_active       = false;
        global.input_locked = false;
        cooldown            = 20;
    }
    exit;   // while choosing, ignore proximity/open logic
}

// ── Proximity + open ──────────────────────────────────────────────────────────
if (_d < interact_range) {
    player_near = true;
    if (keyboard_check_pressed(ord("E")) && cooldown == 0) {
        if (_corr >= 75) {
            // Something is wrong with this place — the booth has sealed itself.
            scr_chronicle_add("The confessional door will not open.");
            cooldown = 40;
        } else {
            prompt_active       = true;
            global.input_locked = true;   // freeze movement while choosing
        }
    }
}
