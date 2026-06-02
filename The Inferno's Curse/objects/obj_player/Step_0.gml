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

// Intended movement this step (kept separate so we can resolve each axis alone)
var _mx = _dx * move_spd;
var _my = _dy * move_spd;

// ── Facing direction ──────────────────────────────────────────────────────────
// Only update when the player is actually moving so idle facing is preserved.
// obj_manifestation reads this to decide whether it's in the player's arc.
if (_dx != 0 || _dy != 0) {
    facing_dir = point_direction(0, 0, _dx, _dy);
}

// ── Directional sprite ────────────────────────────────────────────────────────
// Pick the facing sprite from the 8-way lookup. facing_dir only changes while
// moving, so when idle this keeps the last sprite the player faced.
sprite_index = dir_sprites[(round(facing_dir / 45)) mod 8];

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

// ── Room border clamp (safety net) ────────────────────────────────────────────
// Border walls are 32 px thick on all four sides; the player is 32x32 centred,
// so we keep its centre at least 48 px from each room edge. Backs up the AABB
// test above against the border obj_wall instances.
var _wall_thick = 32;
var _half       = 16;
x = clamp(x, _wall_thick + _half, room_width  - _wall_thick - _half);
y = clamp(y, _wall_thick + _half, room_height - _wall_thick - _half);
