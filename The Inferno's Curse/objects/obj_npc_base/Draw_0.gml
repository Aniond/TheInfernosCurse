// ── NPC Base: Draw ───────────────────────────────────────────────────────────
// Placeholder silhouette until sprites are assigned.
// Colour fades from teal toward grey as npc_memory_corruption rises —
// the NPC becomes ghost-like as their circle is consumed.

// ── Body colour driven by npc_memory_corruption (0-200 scale) ────────────────
// Map 0-200 corruption to a 0-1 fade factor (full = 1.0 at corruption 200).
var _fade  = clamp(npc_memory_corruption / 200, 0, 1);

// Base body colour lerps from teal (fully present) to dark grey (near-ghost).
var _body_col = merge_color(
    make_color_rgb(60, 160, 180),  // teal — fully present
    make_color_rgb(60,  60,  60),  // dark grey — near-ghost
    _fade
);
var _head_col = merge_color(
    make_color_rgb(80, 200, 220),
    make_color_rgb(80,  80,  80),
    _fade
);

// Body — 32x48 rectangle centered on (x, y)
draw_set_color(_body_col);
draw_rectangle(x - 16, y - 24, x + 16, y + 24, false);

// Head
draw_set_color(_head_col);
draw_circle(x, y - 32, 8, false);

// Pulsing interact prompt above the NPC when the player is close
if (near_player && !is_talking) {
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.006);
    draw_set_color(merge_color(c_yellow, c_white, _pulse));
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(x, y - 48, "[E / SPACE] Talk");
}

// Name tag — always visible
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, y - 58, npc_data.name);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
