// ── Player: Step ────────────────────────────────────────────────────────────

// Freeze the player while a menu or dialogue has taken input (journal, dialogue
// box, sin-induced dissociation). Movement and collision are skipped entirely.
if (global.input_locked) exit;

// 8-directional movement — WASD and arrow keys.
// In debug mode with a builder object selected, the ARROW keys fine-nudge that
// object (scr_room_builder_nudge_update), so the player uses WASD only in that mode.
var _nudge_mode = variable_global_exists("debug_mode") && global.debug_mode
    && variable_global_exists("room_builder_selected")
    && instance_exists(global.room_builder_selected);
var _dx = (keyboard_check(ord("D")) || (!_nudge_mode && keyboard_check(vk_right)))
        - (keyboard_check(ord("A")) || (!_nudge_mode && keyboard_check(vk_left)));
var _dy = (keyboard_check(ord("S")) || (!_nudge_mode && keyboard_check(vk_down)))
        - (keyboard_check(ord("W")) || (!_nudge_mode && keyboard_check(vk_up)));

// Ctrl is the editor-chord modifier (Ctrl+Z undo, Ctrl+D duplicate, Ctrl+T time)
// — suppress movement while it is held so chords never also walk Benedetto.
if (keyboard_check(vk_control)) { _dx = 0; _dy = 0; }

// Normalize diagonal so speed stays constant in all directions
if (_dx != 0 && _dy != 0) {
    _dx *= 0.7071;
    _dy *= 0.7071;
}

// ── Run modifier (Shift) — must be before _mx/_my ────────────────────────────
var _running = keyboard_check(vk_shift);
move_spd = _running ? base_move_spd * 1.8 : base_move_spd;

// Intended movement this step (kept separate so we can resolve each axis alone)
var _mx = _dx * move_spd;
var _my = _dy * move_spd;

// ── Facing direction + vision movement gate ───────────────────────────────────
var _moving = (_dx != 0 || _dy != 0);
if (_moving) {
    facing_dir = point_direction(0, 0, _dx, _dy);
    global.player_is_moving      = true;
    global.last_player_move_time = get_timer();
} else {
    global.player_is_moving = false;
}

// ── Directional sprite ────────────────────────────────────────────────────────
// facing_dir only changes while moving, so idle keeps the last direction faced.
var _dir_idx = (round(facing_dir / 45)) mod 8;
var _sluggish = global.circle_corruption[CIRCLE_LIMBO] > 30;
var _target_spr = _moving
    ? (_running ? run_sprites[_dir_idx] : (_sluggish ? sluggish_sprites[_dir_idx] : walk_sprites[_dir_idx]))
    : idle_sprites[_dir_idx];
if (sprite_index != _target_spr) {
    sprite_index = _target_spr;
    image_index  = 0;
}
image_speed = 1;

// ── Building collision (obj_wall_stone + obj_wall) ────────────────────────────
// These walls have no sprite/mask and are sized per-instance via wall_w / wall_h,
// so place_meeting() cannot detect them. Instead we test the player's 32x32 AABB
// (centred origin) against each wall rectangle — top-left origin, extending
// wall_w to the right and wall_h down — and resolve the X and Y axes separately
// so the player slides along a wall instead of sticking to it.
var _phw = 16; // player half-width  — tight foot zone, lets Benedetto stand close to doors
var _phh = 8;  // player half-height — small base collision so he reaches building face

// Returns true if a box of half-size (_hw,_hh) centred at (_px,_py) overlaps any
// building wall. River is handled separately — see below.
// Debug noclip (F1 then N) reports no walls at all, so a player stuck inside a
// collision footprint can simply walk out.
var _wall_at = function(_px, _py, _hw, _hh) {
    if (variable_global_exists("debug_noclip") && global.debug_noclip) return false;
    var _hit = false;
    with (obj_wall_stone) {
        if (_px + _hw > x && _px - _hw < x + wall_w
         && _py + _hh > y && _py - _hh < y + wall_h) { _hit = true; }
    }
    if (!_hit) {
        with (obj_wall) {
            if (_px + _hw > x && _px - _hw < x + wall_w
             && _py + _hh > y && _py - _hh < y + wall_h) { _hit = true; }
        }
    }
    return _hit;
};

// Horizontal axis
if (_mx != 0) {
    x += _mx;
    if (_wall_at(x, y, _phw, _phh)) x -= _mx;
}

// Vertical axis — river collision is handled by invisible obj_wall instances
// spawned by obj_game_manager, so no special river logic needed here.
if (_my != 0) {
    var _old_y = y;
    y += _my;
    if (_wall_at(x, y, _phw, _phh)) y = _old_y;
}

// ── Hard movement bounds — confine Benedetto to the playable area ─────────────
// The 2048x2048 room's play area is clamped to a 1920x1920 box (grid 1..31).
// Visual walls suggest the edge; this clamp is the hard limit. The river/bridges
// (y1536-1728) and everything built sit INSIDE this box, so the crossings stay
// reachable.
x = clamp(x, 64, room_width  - 64);
y = clamp(y, 64, room_height - 64);
