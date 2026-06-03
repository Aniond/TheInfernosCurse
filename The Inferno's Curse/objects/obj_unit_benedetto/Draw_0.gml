// =============================================================================
// obj_unit_benedetto — Draw
// Renders directional sprite based on unit_facing, with HP bar, AP pips,
// and active-turn glow. Overrides obj_unit_base placeholder rectangle.
// Sprites are 88x88 with origin at center (44,44).
// =============================================================================

if (fsm.state_is("dead")) exit;

var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
var _ts = BATTLE_TILE_SIZE;
var _cx = _tx + _ts / 2;
var _cy = _ty + _ts / 2;

// ── Directional sprite ────────────────────────────────────────────────────────
var _spr;
switch (unit_facing) {
    case "north":      _spr = spr_benedetto_north;      break;
    case "north_east": _spr = spr_benedetto_north_east; break;
    case "east":       _spr = spr_benedetto_east;       break;
    case "south_east": _spr = spr_benedetto_south_east; break;
    case "south_west": _spr = spr_benedetto_south_west; break;
    case "west":       _spr = spr_benedetto_west;       break;
    case "north_west": _spr = spr_benedetto_north_west; break;
    default:           _spr = spr_benedetto_south;      break;
}

draw_set_alpha(is_active_turn ? 1.0 : 0.8);
draw_sprite(_spr, 0, _cx, _cy);

// ── HP bar ────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
var _pad     = 4;
var _hp_ratio = clamp(hp / max_hp, 0, 1);
var _bar_x   = _tx + _pad;
var _bar_y   = _ty + _ts - 8;
var _bar_w   = _ts - _pad * 2;

draw_set_color(make_color_rgb(50, 10, 10));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + 5, false);
draw_set_color(make_color_rgb(50, 210, 50));
draw_rectangle(_bar_x, _bar_y, _bar_x + floor(_bar_w * _hp_ratio), _bar_y + 5, false);

// ── AP pips ───────────────────────────────────────────────────────────────────
if (is_active_turn) {
    var _pip_x = _tx + _pad;
    for (var _a = 0; _a < max_ap; _a++) {
        draw_set_color((_a < ap) ? make_color_rgb(220, 200, 80) : make_color_rgb(50, 40, 15));
        draw_circle(_pip_x + 4, _bar_y - 7, 3, false);
        _pip_x += 10;
    }
}

// ── Reset ──────────────────────────────────────────────────────────────────────
draw_set_alpha(1);
draw_set_color(c_white);
