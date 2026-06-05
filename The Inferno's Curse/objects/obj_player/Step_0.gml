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
// building wall. River is handled separately — see below.
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
    return _hit;
};

// Returns true if the position is inside the river band and NOT on a bridge.
// Used only for Y-axis movement so east-west walking on the bank is never blocked.
var _in_river = function(_px, _py, _hh) {
    if (room != Room1 || !variable_global_exists("river_y1")) return false;
    if (_py + _hh <= global.river_y1 || _py - _hh >= global.river_y2) return false;
    for (var _b = 0; _b < array_length(global.river_bridges); _b++) {
        var _br = global.river_bridges[_b];
        if (_px + 16 > _br[0] && _px - 16 < _br[1]) return false;   // AABB bridge — any overlap is passable
    }
    return true;
};

// Horizontal axis — building walls only. River runs E-W and never blocks X movement,
// which also lets the player escape the bank boundary if they loaded there.
if (_mx != 0) {
    x += _mx;
    if (_wall_at(x, y, _phw, _phh)) x -= _mx;
}

// Vertical axis — building walls + one-way river gate.
// The river only blocks movement that ENTERS it (old pos outside, new pos inside).
// If the player is already inside the overlap zone (e.g. loaded at the bank edge),
// they can always move north to escape.
if (_my != 0) {
    var _old_y = y;
    y += _my;
    var _blocked = _wall_at(x, y, _phw, _phh);
    if (!_blocked && _in_river(x, y, _phh) && !_in_river(x, _old_y, _phh)) {
        _blocked = true;   // entering the river from outside
    }
    if (_blocked) y = _old_y;
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
