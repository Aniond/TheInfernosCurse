// =============================================================================
// obj_dialogue_box — Draw GUI Event
// =============================================================================
// Runs in GUI space — always screen-anchored, above all world sprites.
// This is the window into every soul Benedetto meets.
// Every element here shifts with the NPC's corruption so the reader
// feels the weight of a mind that is losing itself.
// =============================================================================

if (!is_active) exit;

// ── Layout constants ──────────────────────────────────────────────────────────
var _gw  = display_get_gui_width();
var _gh  = display_get_gui_height();
var _pad = 18;
var _bx  = 16;
var _by  = _gh - 160;
var _bw  = _gw - 32;
var _bh  = 144;

// ── Corruption factor (0-1) ───────────────────────────────────────────────────
// Maps npc_memory_corruption (0-200) to a 0-1 scale for lerping colours.
// At 0 the NPC is fully present; at 1 they are almost gone.
var _cf = clamp(corruption_level / 200, 0, 1);

// =============================================================================
// BOX — background fill
// =============================================================================
draw_set_alpha(0.92);
draw_set_color(make_color_rgb(10, 10, 15));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
draw_set_alpha(1);

// ── Border — colour fades from cool stone toward deep blood as corruption rises
// 0-25%: slate   100,100,120
// 25-50%: muted mauve  80, 60, 80
// 50-75%: bruised red  60, 20, 40
// 75-100%: void black  40,  0,  0
var _border_col;
if (_cf <= 0.25) {
    _border_col = merge_color(
        make_color_rgb(100, 100, 120),
        make_color_rgb(80,   60,  80),
        _cf / 0.25
    );
} else if (_cf <= 0.50) {
    _border_col = merge_color(
        make_color_rgb(80,  60,  80),
        make_color_rgb(60,  20,  40),
        (_cf - 0.25) / 0.25
    );
} else if (_cf <= 0.75) {
    _border_col = merge_color(
        make_color_rgb(60,  20,  40),
        make_color_rgb(40,   0,   0),
        (_cf - 0.50) / 0.25
    );
} else {
    _border_col = make_color_rgb(40, 0, 0);
}
draw_set_color(_border_col);
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);

// =============================================================================
// NPC NAME
// =============================================================================
// Colour drains as the NPC loses themselves.
// 0-25%: white            255,255,255
// 25-50%: warm grey        220,200,200
// 50-75%: washed rose      180,150,150
// 75-100%: faded bloodstone 140,100,100
var _name_col;
if (_cf <= 0.25) {
    _name_col = merge_color(
        c_white,
        make_color_rgb(220, 200, 200),
        _cf / 0.25
    );
} else if (_cf <= 0.50) {
    _name_col = merge_color(
        make_color_rgb(220, 200, 200),
        make_color_rgb(180, 150, 150),
        (_cf - 0.25) / 0.25
    );
} else if (_cf <= 0.75) {
    _name_col = merge_color(
        make_color_rgb(180, 150, 150),
        make_color_rgb(140, 100, 100),
        (_cf - 0.50) / 0.25
    );
} else {
    _name_col = make_color_rgb(140, 100, 100);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_name_col);
draw_text(_bx + _pad, _by + _pad - 4, npc_name_display);

// ── Divider below name ────────────────────────────────────────────────────────
// Colour tracks the border so the whole box breathes together.
draw_set_color(_border_col);
draw_line(_bx + _pad, _by + _pad + 16, _bx + _bw - _pad, _by + _pad + 16);

// =============================================================================
// BODY TEXT
// =============================================================================
var _text_y = _by + _pad + 22;
var _text_x = _bx + _pad;
var _text_w = _bw - _pad * 2;

if (is_loading) {
    // ── Loading state — waiting for Claude ───────────────────────────────────
    draw_set_color(make_color_rgb(150, 150, 150));
    draw_set_halign(fa_left);
    draw_text(_text_x, _text_y, "Benedetto listens" + dot_string);

} else {

    // ── Sanity: alpha and distortion ─────────────────────────────────────────
    // Text alpha fades slightly as sanity drops — words become harder to hold.
    // Below sanity 50, the text occasionally jitters by ±1 pixel.
    var _text_alpha = 0.7 + (global.sanity / 100 * 0.3);
    draw_set_alpha(_text_alpha);

    var _jitter_x = 0;
    var _jitter_y = 0;
    if (global.sanity < 50) {
        // Jitter frequency scales as sanity falls:
        //   sanity 50 → ~1/120 chance per step of a 1px shift
        //   sanity 25 → ~1/60 chance
        //   sanity 0  → ~1/30 chance
        // The effect is already baked in by the time Draw runs;
        // using current_time keeps it frame-coherent without extra state.
        var _jitter_chance = (50 - global.sanity) / 50; // 0.0-1.0
        var _jitter_seed   = floor(current_time / (30 + 60 * (1 - _jitter_chance)));
        if ((_jitter_seed & 3) == 0) { // ~25% of "ticks"
            _jitter_x = irandom_range(-1, 1);
            _jitter_y = irandom_range(-1, 1);
        }
    }

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(
        _text_x + _jitter_x,
        _text_y  + _jitter_y,
        display_text,
        -1,
        _text_w
    );

    draw_set_alpha(1);
}

// =============================================================================
// CONTINUE PROMPT
// =============================================================================
if (is_complete && !is_loading) {
    // Blinks every 30 steps so the player knows to press a key.
    var _blink = (floor(current_time / (30 * (1000 / game_get_speed(gamespeed_fps)))) & 1) == 0;
    if (_blink) {
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(_bx + _bw - _pad, _by + _bh - _pad + 4, "[ E / SPACE ] Continue");
    }
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
