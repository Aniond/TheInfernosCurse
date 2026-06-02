// =============================================================================
// obj_unit_base — Draw (world space)
// Placeholder visual: filled tile with HP bar, status icons, unit name.
// Replace with sprite draws when unit art is imported.
// =============================================================================

if (fsm.state_is("dead")) exit;

var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
var _ts = BATTLE_TILE_SIZE;
var _pad = 5;

// ── Unit body ─────────────────────────────────────────────────────────────────
var _body_alpha = is_active_turn ? 0.95 : 0.75;
draw_set_alpha(_body_alpha);
draw_set_color(unit_color);
draw_rectangle(_tx + _pad, _ty + _pad, _tx + _ts - _pad - 1, _ty + _ts - _pad - 1, false);

// Active outline
if (is_active_turn) {
    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_rectangle(_tx + _pad, _ty + _pad, _tx + _ts - _pad - 1, _ty + _ts - _pad - 1, true);
}

// ── HP bar ────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
var _hp_ratio = clamp(hp / max_hp, 0, 1);
var _bar_x = _tx + _pad;
var _bar_y = _ty + _ts - 10;
var _bar_w = _ts - _pad * 2 - 1;

draw_set_color(make_color_rgb(60, 15, 15));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + 5, false);
draw_set_color(make_color_rgb(50, 210, 50));
draw_rectangle(_bar_x, _bar_y, _bar_x + floor(_bar_w * _hp_ratio), _bar_y + 5, false);

// ── Status effect icons (top-left corner) ─────────────────────────────────────
var _icon_x = _tx + _pad;
for (var _s = 0; _s < array_length(status_effects); _s++) {
    switch (status_effects[_s]) {
        case "forgotten":
            draw_set_color(make_color_rgb(110, 80, 220));
            draw_circle(_icon_x + 4, _ty + _pad + 4, 4, false);
            _icon_x += 10;
            break;
        case "frozen":
            draw_set_color(make_color_rgb(180, 180, 255));
            draw_rectangle(_icon_x, _ty + _pad, _icon_x + 8, _ty + _pad + 8, false);
            _icon_x += 10;
            break;
    }
}

// ── Unit name ─────────────────────────────────────────────────────────────────
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_tx + _ts / 2, _ty + _pad + 2, unit_name);

// ── AP pips (shown on active turn) ────────────────────────────────────────────
if (is_active_turn) {
    var _pip_x = _tx + _pad;
    for (var _a = 0; _a < max_ap; _a++) {
        draw_set_color((_a < ap) ? make_color_rgb(220, 200, 80) : make_color_rgb(60, 50, 20));
        draw_circle(_pip_x + 4, _ty + _ts - 18, 3, false);
        _pip_x += 10;
    }
}

// ── Reset ──────────────────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
