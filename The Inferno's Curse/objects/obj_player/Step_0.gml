// ── Player: Step ────────────────────────────────────────────────────────────

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

x += _dx * move_spd;
y += _dy * move_spd;

// ── Wall collision ────────────────────────────────────────────────────────────
// Border walls are 32 px thick on all four sides. Player placeholder is 32x32
// with its origin at centre, so we offset by half-size (16 px) to keep the
// visible rectangle fully inside the walls.
var _wall_thick = 32;
var _half       = 16; // half of the 32x32 placeholder size
x = clamp(x, _wall_thick + _half, room_width  - _wall_thick - _half);
y = clamp(y, _wall_thick + _half, room_height - _wall_thick - _half);
