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
// Frame is a bottom-anchored bar across the lower third of the screen.
var _gw      = display_get_gui_width();
var _gh      = display_get_gui_height();
var _frame_h = round(_gh * 0.32);        // bottom bar height
var _frame_y = _gh - _frame_h;           // anchored flush to screen bottom
var _frame_x = 0;
var _frame_w = _gw;

// Text area inset within the parchment zone of the bar.
var _text_left   = round(_gw * 0.09);
var _text_right  = round(_gw * 0.91);
var _text_width  = _text_right - _text_left;
var _name_y      = _frame_y + round(_frame_h * 0.20);   // name baseline
var _text_top    = _name_y;

// ── Corruption factor (0-1) ───────────────────────────────────────────────────
var _cf = clamp(corruption_level / 200, 0, 1);

// =============================================================================
// FRAME — gothic parchment art
// =============================================================================
// At high corruption the frame darkens toward void-black, as if the parchment
// itself is being consumed. Below 50% corruption it renders clean.
var _frame_blend = c_white;
if (_cf > 0.5) {
    var _dark = (_cf - 0.5) / 0.5;
    _frame_blend = merge_color(c_white, make_color_rgb(40, 0, 0), _dark);
}
draw_sprite_stretched_ext(
    spr_ui_dialogue_frame, 0,
    _frame_x, _frame_y, _frame_w, _frame_h,
    _frame_blend, 1
);

// =============================================================================
// NPC NAME
// =============================================================================
// Colour drains as the NPC loses themselves.
// 0-25%: white            255,255,255
// 25-50%: warm grey        220,200,200
// 50-75%: washed rose      180,150,150
// 75-100%: faded bloodstone 140,100,100
// Name colour: deep brown at low corruption, bleeding toward blood-red as
// the NPC loses themselves. Both readable on parchment.
var _name_col;
if (_cf <= 0.25) {
    _name_col = merge_color(
        make_color_rgb(60, 30, 10),
        make_color_rgb(80, 40, 20),
        _cf / 0.25
    );
} else if (_cf <= 0.50) {
    _name_col = merge_color(
        make_color_rgb(80, 40, 20),
        make_color_rgb(120, 40, 20),
        (_cf - 0.25) / 0.25
    );
} else if (_cf <= 0.75) {
    _name_col = merge_color(
        make_color_rgb(120, 40, 20),
        make_color_rgb(140, 20, 10),
        (_cf - 0.50) / 0.25
    );
} else {
    _name_col = make_color_rgb(140, 20, 10);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_name_col);
draw_text(_text_left, _text_top, npc_name_display);

// ── Divider below name ────────────────────────────────────────────────────────
draw_set_color(make_color_rgb(80, 60, 40));
draw_line(_text_left, _text_top + 20, _text_right, _text_top + 20);

// =============================================================================
// BODY TEXT
// =============================================================================
var _text_y = _text_top + 42;
var _text_x = _text_left;
var _text_w = _text_width;

if (is_loading) {
    // ── Loading state — waiting for Claude ───────────────────────────────────
    draw_set_color(make_color_rgb(80, 50, 20));
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

    draw_set_color(make_color_rgb(50, 25, 8));
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
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(_text_right, _gh - 16, "[ E / SPACE ] Continue");
    }
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
