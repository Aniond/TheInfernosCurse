// ── NPC Base: Draw ───────────────────────────────────────────────────────────
// Placeholder silhouette until sprites are assigned.
// Colour fades from teal toward grey as npc_memory_corruption rises —
// the NPC becomes ghost-like as their circle is consumed.

// ── Body colour driven by npc_memory_corruption (0-100 scale) ────────────────
// Map 0-100 corruption to a 0-1 fade factor (full = 1.0 at corruption 100).
var _fade  = clamp(npc_memory_corruption / 100, 0, 1);

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

// Overall display scale for this NPC's whole assembly (stall + character + prop).
var _s = npc_scale;

// ── Background prop (e.g. Marco's stall) — drawn first, behind the NPC ────────
if (bg_sprite != noone) {
    var _bw = sprite_get_width(bg_sprite)  * _s;
    var _bh = sprite_get_height(bg_sprite) * _s;
    // Centered on x, sitting just behind the NPC's feet.
    draw_sprite_ext(bg_sprite, 0, x - _bw * 0.5, y - _bh + 30 * _s, _s, _s, 0, c_white, 1);
}

if (npc_sprite != noone) {
    // ── Real character sprite (centered, feet near y) ─────────────────────────
    // Subtle desaturation toward grey as corruption rises — the NPC ghosts out.
    var _sw   = sprite_get_width(npc_sprite)  * _s;
    var _sh   = sprite_get_height(npc_sprite) * _s;
    var _tint = merge_color(c_white, make_color_rgb(120, 120, 120), _fade * 0.4);
    draw_sprite_ext(
        npc_sprite, 0,
        x - _sw * 0.5, y - _sh + 28 * _s,
        _s, _s, 0, _tint, 1
    );
} else {
    // ── Placeholder silhouette (no sprite assigned) ──────────────────────────
    // Body — 32x48 rectangle centered on (x, y)
    draw_set_color(_body_col);
    draw_rectangle(x - 16, y - 24, x + 16, y + 24, false);

    // Head
    draw_set_color(_head_col);
    draw_circle(x, y - 32, 8, false);
}

// ── Front prop (e.g. a loaf on the counter) — drawn over the NPC ─────────────
if (prop_sprite != noone) {
    var _pw = sprite_get_width(prop_sprite) * _s;
    draw_sprite_ext(prop_sprite, 0, x - _pw * 0.5, y + 6 * _s, _s, _s, 0, c_white, 1);
}

// Labels sit higher when a full-size character sprite is present so they
// clear the head (scaled with the sprite); placeholders keep tight offsets.
var _name_label_y   = (npc_sprite != noone) ? (y - 96 * _s) : (y - 58);
var _prompt_label_y = (npc_sprite != noone) ? (y - 80 * _s) : (y - 48);

// Pulsing interact prompt above the NPC when the player is close
if (near_player && !is_talking) {
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.006);
    draw_set_color(merge_color(c_yellow, c_white, _pulse));
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(x, _prompt_label_y, "[E / SPACE] Talk");
}

// Name tag — always visible
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, _name_label_y, npc_data.name);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
