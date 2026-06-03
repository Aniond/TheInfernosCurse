// =============================================================================
// obj_unit_shambler — Draw
// Renders the Shambler sprite, HP bar, status icons, and active-turn ring.
// Yellow enemy marker (distinct from Hollow's red) so it reads immediately
// as a Legendary threat.
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

// ── Enemy marker — amber/yellow double outline, visually heavier than Hollow's red
draw_set_alpha(1);
draw_set_color(make_color_rgb(220, 160, 60));
draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, true);
draw_rectangle(_tx + 2, _ty + 2, _tx + _ts - 3, _ty + _ts - 3, true);

// ── Active turn ring ──────────────────────────────────────────────────────────
if (is_active_turn) {
    draw_set_alpha(0.9);
    draw_set_color(c_yellow);
    draw_circle(_cx, _cy, 40, true);   // slightly larger ring than Hollow (34) — it's bigger
}

// ── HP bar ────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
var _pad      = 4;
var _hp_ratio = clamp(hp / max_hp, 0, 1);
var _bar_x    = _tx + _pad;
var _bar_y    = _ty + _ts - 8;
var _bar_w    = _ts - _pad * 2;

draw_set_color(make_color_rgb(50, 10, 10));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + 5, false);
draw_set_color(make_color_rgb(220, 160, 60));   // amber HP bar matches marker colour
draw_rectangle(_bar_x, _bar_y, _bar_x + floor(_bar_w * _hp_ratio), _bar_y + 5, false);

// ── Reset ─────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
draw_set_color(c_white);
