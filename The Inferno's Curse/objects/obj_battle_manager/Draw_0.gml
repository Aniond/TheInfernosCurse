// =============================================================================
// obj_battle_manager — Draw (world space)
// Renders the battle grid: background, lines, active-cell highlight.
// Units and tiles draw themselves; this is purely structural chrome.
// =============================================================================

var _gx0 = BATTLE_GRID_X;
var _gy0 = BATTLE_GRID_Y;
var _gx1 = BATTLE_GRID_X + BATTLE_GRID_W * BATTLE_TILE_SIZE;
var _gy1 = BATTLE_GRID_Y + BATTLE_GRID_H * BATTLE_TILE_SIZE;

// ── Grid background ───────────────────────────────────────────────────────────
draw_set_color(make_color_rgb(12, 8, 18));
draw_rectangle(_gx0, _gy0, _gx1, _gy1, false);

// ── Grid lines ────────────────────────────────────────────────────────────────
var _line_col = make_color_rgb(28, 18, 42);
draw_set_color(_line_col);
var _col, _row;
for (_col = 0; _col <= BATTLE_GRID_W; _col++) {
    var _lx = _gx0 + _col * BATTLE_TILE_SIZE;
    draw_line(_lx, _gy0, _lx, _gy1);
}
for (_row = 0; _row <= BATTLE_GRID_H; _row++) {
    var _ly = _gy0 + _row * BATTLE_TILE_SIZE;
    draw_line(_gx0, _ly, _gx1, _ly);
}

// ── Room background (outside grid) ───────────────────────────────────────────
draw_set_color(make_color_rgb(6, 4, 10));
// Left panel
draw_rectangle(0, 0, _gx0 - 1, display_get_height(), false);
// Right panel
draw_rectangle(_gx1 + 1, 0, display_get_width(), display_get_height(), false);
// Bottom bar
draw_rectangle(0, _gy1 + 1, display_get_width(), display_get_height(), false);
// Top bar
draw_rectangle(0, 0, display_get_width(), _gy0 - 1, false);

// ── Active-unit tile highlight ────────────────────────────────────────────────
if (battle_phase == "player_turn" || battle_phase == "enemy_turn") {
    if (array_length(turn_order) > 0) {
        var _uid = turn_order[active_unit_idx];
        if (instance_exists(_uid)) {
            var _tx = _gx0 + _uid.grid_x * BATTLE_TILE_SIZE;
            var _ty = _gy0 + _uid.grid_y * BATTLE_TILE_SIZE;
            var _ts = BATTLE_TILE_SIZE;
            draw_set_color(make_color_rgb(90, 75, 30));
            draw_set_alpha(0.35);
            draw_rectangle(_tx, _ty, _tx + _ts - 1, _ty + _ts - 1, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(200, 175, 80));
            draw_rectangle(_tx, _ty, _tx + _ts - 1, _ty + _ts - 1, true);
        }
    }
}

draw_set_color(c_white);
draw_set_alpha(1);
