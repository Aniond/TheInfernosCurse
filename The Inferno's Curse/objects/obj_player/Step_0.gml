// ── Player: Step ────────────────────────────────────────────────────────────

// Freeze the player while a menu or dialogue has taken input (journal, dialogue
// box, sin-induced dissociation). Movement and collision are skipped entirely.
if (global.input_locked) exit;

// 8-directional movement — WASD and arrow keys
var _dx = (keyboard_check(ord("D")) || keyboard_check(vk_right))
        - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var _dy = (keyboard_check(ord("S")) || keyboard_check(vk_down))
        - (keyboard_check(ord("W")) || keyboard_check(vk_up));

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
// wall. Standard AABB overlap test against both wall object types.
var _wall_at = function(_px, _py, _hw, _hh) {
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
    // River (the Arno): solid water across its full-width band EXCEPT where a
    // bridge gap lets the player cross. Room1-only; geometry from globals set in
    // obj_game_manager. Bridge test is on the player's centre x.
    if (!_hit && room == Room1 && variable_global_exists("river_y1")) {
        if (_py + _hh > global.river_y1 && _py - _hh < global.river_y2) {
            var _on_bridge = false;
            for (var _b = 0; _b < array_length(global.river_bridges); _b++) {
                var _br = global.river_bridges[_b];
                if (_px > _br[0] && _px < _br[1]) { _on_bridge = true; break; }
            }
            if (!_on_bridge) _hit = true;
        }
    }
    return _hit;
};

// Horizontal axis — move, and undo only X if it lands us in a wall.
if (_mx != 0) {
    x += _mx;
    if (_wall_at(x, y, _phw, _phh)) x -= _mx;
}

// Vertical axis — move, and undo only Y if it lands us in a wall.
if (_my != 0) {
    y += _my;
    if (_wall_at(x, y, _phw, _phh)) y -= _my;
}

// ── Room border clamp — matches the 56-px visual wall ring ────────────────────
// The visual city wall is 56px thick on all four sides. Gate openings are 140px
// wide, centred on the room (x/y 1530..1670). Inside a gate the clamp relaxes
// to the room edge so the player can walk through; everywhere else the 56-px
// wall is solid.
var _wt     = 56;
var _half   = 16;
var _gate_h = 70;   // half of 140-px gate gap

// N/S gate: open in x range 1530..1670; W/E gate: open in y range 1530..1670
var _ngx0 = room_width  * 0.5 - _gate_h;   // 1530
var _ngx1 = room_width  * 0.5 + _gate_h;   // 1670
var _egy0 = room_height * 0.5 - _gate_h;   // 1530
var _egy1 = room_height * 0.5 + _gate_h;   // 1670

var _min_x = (y >= _egy0 && y <= _egy1) ? _half                    : _wt + _half;
var _max_x = (y >= _egy0 && y <= _egy1) ? room_width  - _half      : room_width  - _wt - _half;
var _min_y = (x >= _ngx0 && x <= _ngx1) ? _half                    : _wt + _half;
var _max_y = (x >= _ngx0 && x <= _ngx1) ? room_height - _half      : room_height - _wt - _half;

x = clamp(x, _min_x, _max_x);
y = clamp(y, _min_y, _max_y);
