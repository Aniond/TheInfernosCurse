// =============================================================================
// obj_stable_rest — Step
// =============================================================================
if (msg_timer > 0) msg_timer--;
player_near = false;
if (room != Room_fiorentine_stable) exit;
if (!instance_exists(obj_player)) exit;
if (variable_global_exists("debug_mode") && global.debug_mode) exit;   // draggable in debug
if (global.input_locked) exit;

var _cx = x + 32 * image_xscale;
var _cy = y + 32 * image_yscale;
if (point_distance(_cx, _cy, obj_player.x, obj_player.y) >= interact_range) exit;
player_near = true;

if (!keyboard_check_pressed(ord("E"))) exit;

// ── Reputation gate: guild men sleep at the inn, not in straw ──────────────────
var _guild = variable_global_exists("merchant_guild") ? global.merchant_guild : 0;
if (_guild > 0) {
    msg_text  = "A man of your standing, in straw? The Locanda della Rosa Camuna keeps proper beds.";
    msg_timer = 180;
    exit;
}

// ── Rest in the straw — full HP, night passes, the curse seeps in (+2%) ─────────
obj_player.hp = obj_player.max_hp;
scr_corruption_taint(2);
scr_time_sleep();                       // skip to 06:00 next day (scr_time_system)
msg_text  = "You sleep among the horses. The straw whispers. (+2% corruption)";
msg_timer = 180;
scr_chronicle_add("A night in the straw of the Fiorentine Stable.");
