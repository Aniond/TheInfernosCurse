// =============================================================================
// obj_unit_hollow — Draw
// Renders the Hollow sprite (single south-facing for now), HP bar, status
// icons, and active-turn ring. Overrides obj_unit_base's placeholder rectangle.
// =============================================================================

if (fsm.state_is("dead")) exit;

var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
var _ts = BATTLE_TILE_SIZE;
var _cx = _tx + _ts / 2;
var _cy = _ty + _ts / 2;

// ── Sprite ────────────────────────────────────────────────────────────────────
draw_set_alpha(is_active_turn ? 1.0 : 0.8);
draw_set_color(c_white);
draw_sprite(sprite_index, 0, _cx, _cy);

// ── Enemy marker box — bright crimson so the Hollow stands out on the dark grid
// 2px outline for visibility. Distinct from Benedetto's gold turn-ring and the
// blue move-range tiles.
draw_set_alpha(1);
draw_set_color(make_color_rgb(230, 40, 40));
draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, true);
draw_rectangle(_tx + 2, _ty + 2, _tx + _ts - 3, _ty + _ts - 3, true);

// ── Active turn ring ──────────────────────────────────────────────────────────
if (is_active_turn) {
    draw_set_alpha(0.9);
    draw_set_color(c_yellow);
    draw_circle(_cx, _cy, 34, true);
}

// ── HP bar ────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
var _pad  = 4;
var _hp_ratio = clamp(hp / max_hp, 0, 1);
var _bar_x = _tx + _pad;
var _bar_y = _ty + _ts - 8;
var _bar_w = _ts - _pad * 2;

draw_set_color(make_color_rgb(50, 10, 10));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + 5, false);
draw_set_color(make_color_rgb(50, 210, 50));
draw_rectangle(_bar_x, _bar_y, _bar_x + floor(_bar_w * _hp_ratio), _bar_y + 5, false);

// ── Status icons ──────────────────────────────────────────────────────────────
var _icon_x = _tx + _pad;
for (var _s = 0; _s < array_length(status_effects); _s++) {
    if (status_effects[_s] == "forgotten") {
        draw_set_color(make_color_rgb(110, 80, 220));
        draw_circle(_icon_x + 4, _ty + _pad + 4, 4, false);
        _icon_x += 10;
    }
}

// ── Reset ──────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
draw_set_color(c_white);
