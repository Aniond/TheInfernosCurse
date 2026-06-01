// ── NPC Base: Draw ───────────────────────────────────────────────────────────
// Placeholder silhouette until sprites are assigned.

// Body (teal — distinct from the player's white placeholder)
draw_set_color(make_color_rgb(60, 160, 180));
draw_rectangle(x - 12, y - 28, x + 12, y, false);

// Head
draw_set_color(make_color_rgb(80, 200, 220));
draw_circle(x, y - 34, 8, false);

// Pulsing interact prompt above the NPC when the player is close
if (near_player && !is_talking) {
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.006);
    draw_set_color(merge_color(c_yellow, c_white, _pulse));
    draw_circle(x, y - 50, 5, false);
}

// Name tag — always visible
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, y - 58, npc_data.name);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
