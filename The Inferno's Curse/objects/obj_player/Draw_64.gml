// ── Player: Draw GUI — HUD ───────────────────────────────────────────────────
// Numbers are hidden from the player. Atmosphere carries the state.
// HP is the only objective reality shown — it is physical, not psychological.

// Hide HUD entirely when dialogue is open — nothing overlays the parchment,
// not even debug values. Debug stats remain available on the normal HUD.
if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) exit;

var _bar_x = 16;
var _bar_y  = display_get_gui_height() - 40;

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(_bar_x, _bar_y - 22, "HP  " + string(round(hp)) + " / " + string(round(max_hp)));

// Debug overlay — everything visible, nothing hidden
if (global.debug_mode) {
    draw_set_color(make_color_rgb(160, 220, 160));
    draw_text(32, 32,
        "S:" + string(round(scr_lucidity())) +
        " | C:" + string(round(global.circle_corruption[global.current_circle])) +
        " | PC:" + string(round(corruption)));
    draw_text(32, 52,
        "spd:" + string(image_speed) +
        " | idx:" + string(string_format(image_index, 1, 2)) +
        " | spr:" + string(sprite_index));
}

draw_set_color(c_white);
