// =============================================================================
// obj_shrine — Draw Event
// =============================================================================
// Draws the shrine as a cross built from two rectangles. When active and
// uncorrupted it glows warm gold; when corrupted or on cooldown it is dark and
// cold. Past 75% corruption it appears cracked with dark tendrils at its base.

var _corrupt = global.circle_corruption[0];

// A shrine is "alive" only when active AND corruption hasn't claimed the circle.
var _alive = (shrine_active && _corrupt < 50);

// ── Colour selection ──────────────────────────────────────────────────────────
var _col;
if (_alive) {
    _col = make_color_rgb(200, 180, 120); // warm candlelit gold
} else {
    _col = make_color_rgb(40, 30, 20);    // dark, cold, unanswered
}

// ── Soft glow (alive only) ────────────────────────────────────────────────────
// A larger, faded cross drawn behind the solid one gives a halo of light.
if (_alive) {
    draw_set_alpha(0.20);
    draw_set_color(_col);
    draw_rectangle(x - 8,  y - 26, x + 8,  y + 18, false); // glow vertical
    draw_rectangle(x - 20, y - 12, x + 20, y + 6,  false); // glow horizontal
    draw_set_alpha(1.0);
}

// ── Solid cross ───────────────────────────────────────────────────────────────
draw_set_color(_col);
draw_rectangle(x - 4,  y - 20, x + 4,  y + 12, false); // vertical bar
draw_rectangle(x - 14, y - 6,  x + 14, y + 2,  false); // horizontal bar

// ── Cracks + tendrils past 75% corruption ─────────────────────────────────────
if (_corrupt > 75) {
    // Hairline cracks across the cross.
    draw_set_color(make_color_rgb(10, 0, 20));
    draw_line(x - 2, y - 18, x + 3, y + 10);
    draw_line(x - 10, y - 4, x + 8, y - 1);

    // Dark tendrils reaching up from the base.
    draw_set_color(make_color_rgb(20, 5, 25));
    draw_line(x - 6, y + 12, x - 12, y + 26);
    draw_line(x,     y + 12, x - 2,  y + 30);
    draw_line(x + 6, y + 12, x + 13, y + 27);
}

// ── "[E] Pray" prompt when the player is close ────────────────────────────────
if (player_near) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    if (_alive) {
        draw_set_color(make_color_rgb(220, 200, 140));
    } else {
        draw_set_color(make_color_rgb(110, 100, 90));
    }
    draw_text(x, y - 30, "[E] Pray");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_color(c_white);
draw_set_alpha(1.0);
