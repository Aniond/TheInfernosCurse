// =============================================================================
// obj_limbo_tile — Draw (world space)
// Invisible by default. When shimmer_visible, draws a pale violet pulse
// that marks the tile for Benedetto's eyes only.
// =============================================================================

var _tx = BATTLE_GRID_X + grid_x * BATTLE_TILE_SIZE;
var _ty = BATTLE_GRID_Y + grid_y * BATTLE_TILE_SIZE;
var _ts = BATTLE_TILE_SIZE;

// ── DEBUG (F1): show EVERY Limbo tile as a red box, revealed or not ───────────
// Lets you verify tile placement and that Focus reveals the right ones.
if (global.debug_mode) {
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(230, 40, 40));
    draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, true);
    draw_rectangle(_tx + 2, _ty + 2, _tx + _ts - 3, _ty + _ts - 3, true);
    draw_set_color(c_white);
}

// ── Passive faint shimmer (separate from Focus's full-strength shimmer) ───────
// A barely-there hint at high corruption. Capped low in Step so it's easy to miss.
if (passive_active && passive_alpha > 0 && !is_shimmer_visible) {
    draw_set_color(make_color_rgb(130, 90, 220));
    draw_set_alpha(passive_alpha);
    draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Normal play: only the violet shimmer when Focus has revealed this tile
if (!is_shimmer_visible || shimmer_alpha <= 0) exit;

// Shimmer fill — faint violet wash
var _pulse = 0.5 + sin(shimmer_timer * 0.20) * 0.5;   // 0.0 to 1.0
draw_set_color(make_color_rgb(130, 90, 220));
draw_set_alpha(shimmer_alpha * 0.35 * _pulse);
draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, false);

// Shimmer border — brighter edge
draw_set_color(make_color_rgb(190, 150, 255));
draw_set_alpha(shimmer_alpha * 0.80);
draw_rectangle(_tx + 1, _ty + 1, _tx + _ts - 2, _ty + _ts - 2, true);

// Corner flickers — give it a glitchy feel
if (_pulse > 0.7) {
    draw_set_color(make_color_rgb(220, 200, 255));
    draw_set_alpha(shimmer_alpha * 0.60);
    draw_line(_tx + 1,       _ty + 1,       _tx + 6,       _ty + 1);
    draw_line(_tx + 1,       _ty + 1,       _tx + 1,       _ty + 6);
    draw_line(_tx + _ts - 2, _ty + 1,       _tx + _ts - 7, _ty + 1);
    draw_line(_tx + _ts - 2, _ty + 1,       _tx + _ts - 2, _ty + 6);
    draw_line(_tx + 1,       _ty + _ts - 2, _tx + 6,       _ty + _ts - 2);
    draw_line(_tx + 1,       _ty + _ts - 2, _tx + 1,       _ty + _ts - 7);
    draw_line(_tx + _ts - 2, _ty + _ts - 2, _tx + _ts - 7, _ty + _ts - 2);
    draw_line(_tx + _ts - 2, _ty + _ts - 2, _tx + _ts - 2, _ty + _ts - 7);
}

draw_set_alpha(1);
draw_set_color(c_white);
