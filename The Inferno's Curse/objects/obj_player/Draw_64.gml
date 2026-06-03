// ── Player: Draw GUI — HUD ───────────────────────────────────────────────────
// Numbers are hidden from the player. Atmosphere carries the state.
// HP is the only objective reality shown — it is physical, not psychological.

// Hide HUD entirely when dialogue is open — frame covers the same GUI area
if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) {
    if (global.debug_mode) {
        draw_set_color(make_color_rgb(160, 220, 160));
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        draw_text(16, display_get_gui_height() - 240,
            "S:" + string(round(global.sanity)) +
            " | C:" + string(round(global.circle_corruption[global.current_circle])) +
            " | PC:" + string(round(corruption)));
        draw_set_color(c_white);
    }
    exit;
}

var _bar_x = 16;
var _bar_y  = display_get_gui_height() - 40;

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(_bar_x, _bar_y - 22, "HP  " + string(hp) + " / " + string(max_hp));

// Debug overlay — everything visible, nothing hidden
if (global.debug_mode) {
    draw_set_color(make_color_rgb(160, 220, 160));
    draw_text(32, 32,
        "S:" + string(round(global.sanity)) +
        " | C:" + string(round(global.circle_corruption[global.current_circle])) +
        " | PC:" + string(round(corruption)));
}

draw_set_color(c_white);
