// =============================================================================
// obj_dialogue_box — Draw GUI Event
// =============================================================================
// Runs in GUI space — always screen-anchored, above all world sprites.
// This is the window into every soul Benedetto meets.
//
// The frame is a properly proportioned 4:1 bar (spr_ui_dialogue_frame),
// drawn as a fixed 200px strip flush to the screen bottom via stretch.
// No nine-slice — the art is already at the correct ratio.
// Dynamic elements (corruption tint, name colour, sanity jitter) still shift
// with the NPC's state so the reader feels a mind losing itself.
// =============================================================================

if (!is_active) exit;

// ── Layout constants ──────────────────────────────────────────────────────────
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _bar_h = 150;                 // fixed bottom-bar height
var _bar_y = _gh - _bar_h;        // anchored flush to screen bottom

// Text positions inside the parchment (absolute, measured up from bottom).
var _name_x   = 180;
var _name_y   = _gh - 138;
var _text_x   = 180;
var _text_y   = _gh - 115;
var _text_w   = _gw - 360;
var _prompt_x = _gw - 200;
var _prompt_y = _gh - 25;

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
    0, _bar_y, _gw, _bar_h,
    _frame_blend, 1
);

// =============================================================================
// NPC NAME
// =============================================================================
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
draw_text(_name_x, _name_y, npc_name_display);

// =============================================================================
// BODY TEXT
// =============================================================================
if (is_loading) {
    // ── Loading state — waiting for Claude ───────────────────────────────────
    draw_set_color(make_color_rgb(80, 50, 20));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
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
        var _jitter_chance = (50 - global.sanity) / 50; // 0.0-1.0
        var _jitter_seed   = floor(current_time / (30 + 60 * (1 - _jitter_chance)));
        if ((_jitter_seed & 3) == 0) {
            _jitter_x = irandom_range(-1, 1);
            _jitter_y = irandom_range(-1, 1);
        }
    }

    draw_set_color(make_color_rgb(50, 25, 8));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(
        _text_x + _jitter_x,
        _text_y + _jitter_y,
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
        draw_set_valign(fa_middle);
        draw_text(_prompt_x, _prompt_y, "[ E / SPACE ] Continue");
    }
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
