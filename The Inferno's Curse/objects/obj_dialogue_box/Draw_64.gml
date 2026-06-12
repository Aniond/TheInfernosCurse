// =============================================================================
// obj_dialogue_box — Draw GUI Event
// =============================================================================
// Runs in GUI space — always screen-anchored, above all world sprites.
// This is the window into every soul Benedetto meets.
//
// The frame is a properly proportioned 4:1 bar (spr_ui_dialogue_frame),
// stretched flush to the screen bottom. Its height auto-sizes to the text
// content (clamped 150-300px) and lerps smoothly as lines page through.
// No nine-slice — the art is already at the correct ratio.
// Dynamic elements (corruption tint, name colour, sanity jitter) still shift
// with the NPC's state so the reader feels a mind losing itself.
// =============================================================================

if (!is_active) exit;

draw_set_font(FONT_BODY);   // pixel body font (scr_fonts) — debug may have reset it

// ── Layout constants ──────────────────────────────────────────────────────────
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _text_x = 180;
var _text_w = _gw - 360;          // 180px margin each side; also the wrap width

// ── Autosize: measure required height for the current line ────────────────────
// Recalculated every Draw so the bar tracks whatever text is showing. We measure
// the full line (dialogue_text), not the partially-typed display_text, so the bar
// is sized correctly the instant a line loads and only animates between lines.
var _measure_text = is_loading ? ("Benedetto listens" + dot_string) : dialogue_text;
var _text_height  = string_height_ext(_measure_text, -1, _text_w);

var _padding_top     = 40;
var _padding_bottom  = 35;
var _name_height     = 25;
var _continue_height = 20;

var _total_height = _padding_top + _name_height + _text_height + _continue_height + _padding_bottom;
if (input_active) {
    var _prompt_count = array_length(suggested_prompts);
    _total_height += 30 + (_prompt_count * 20); // 30 for input box, 20 per prompt
}
_total_height = clamp(_total_height, 150, 600);

// Smoothly expand/contract toward the target height (lerp every Draw).
bar_height_current = lerp(bar_height_current, _total_height, 0.15);
if (abs(bar_height_current - _total_height) < 0.5) bar_height_current = _total_height;

var _bar_h = bar_height_current;
var _bar_y = _gh - _bar_h;        // bottom-anchored: bar grows upward

// Text positions anchored to the (animated) top of the bar.
var _name_x   = 180;
var _name_y   = _bar_y + _padding_top;
var _text_y   = _bar_y + _padding_top + _name_height;
var _prompt_x = _gw - 200;
var _prompt_y = _gh - 25;          // continue prompt rides the fixed bottom edge

// ── Corruption factor (0-1) ───────────────────────────────────────────────────
var _cf = clamp(corruption_level / 100, 0, 1);

// =============================================================================
// FRAME — gothic parchment art
// =============================================================================
// At high corruption the frame takes on a faint blood wash, but the tint is
// capped at 20% so the parchment stays clearly readable at all times.
// Below 50% corruption it renders perfectly clean.
var _frame_blend = c_white;
if (_cf > 0.5) {
    var _dark = (_cf - 0.5) / 0.5;          // 0..1 across 50%-100% corruption
    _frame_blend = merge_color(c_white, scr_ui_theme_get(UI_HIGHLIGHT), _dark * 0.2);
}
draw_sprite_stretched_ext(
    spr_ui_dialogue_frame, 0,
    0, _bar_y, _gw, _bar_h,
    _frame_blend, 1
);

// =============================================================================
// NPC NAME
// =============================================================================
// Name colour: themed secondary text at low corruption, bleeding toward the
// theme highlight (blood) as the NPC loses themselves. UI THEME RULE: colors
// come from scr_ui_theme_get — the bleed rides whichever theme is active.
var _name_col = merge_color(
    scr_ui_theme_get(UI_TEXT_SECONDARY),
    scr_ui_theme_get(UI_HIGHLIGHT),
    _cf
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_name_col);
draw_text(_name_x, _name_y, npc_name_display);

// =============================================================================
// BODY TEXT
// =============================================================================
if (is_loading) {
    // ── Loading state — waiting for Claude ───────────────────────────────────
    draw_set_color(scr_ui_theme_get(UI_TEXT_SECONDARY));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_text_x, _text_y, "Benedetto listens" + dot_string);

} else {

    // ── Sanity: alpha and distortion ─────────────────────────────────────────
    // Text alpha fades slightly as sanity drops — words become harder to hold.
    // Below sanity 50, the text occasionally jitters by ±1 pixel.
    var _text_alpha = 0.7 + (scr_lucidity() / 100 * 0.3);
    draw_set_alpha(_text_alpha);

    var _jitter_x = 0;
    var _jitter_y = 0;
    if (scr_lucidity() < 50) {
        var _jitter_chance = (50 - scr_lucidity()) / 50; // 0.0-1.0
        var _jitter_seed   = floor(current_time / (30 + 60 * (1 - _jitter_chance)));
        if ((_jitter_seed & 3) == 0) {
            _jitter_x = irandom_range(-1, 1);
            _jitter_y = irandom_range(-1, 1);
        }
    }

    draw_set_color(scr_ui_theme_get(UI_TEXT_PRIMARY));
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
// CONTINUE OR INPUT PROMPT
// =============================================================================
if (is_complete && !is_loading) {
    if (input_active) {
        // Draw 4 suggested prompts
        draw_set_font(FONT_BODY);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        var _prompt_start_y = _text_y + _text_height + 20;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        selected_prompt = -1;
        
        for (var _i = 0; _i < array_length(suggested_prompts); _i++) {
            var _py = _prompt_start_y + (_i * 20);
            var _pstr = "> " + suggested_prompts[_i];
            
            var _pw = string_width(_pstr);
            var _ph = string_height(_pstr);
            
            var _col = scr_ui_theme_get(UI_TEXT_SECONDARY);
            if (_mx >= _text_x && _mx <= _text_x + _pw && _my >= _py && _my <= _py + _ph) {
                _col = scr_ui_theme_get(UI_HIGHLIGHT);
                selected_prompt = _i;
            }
            
            draw_set_color(_col);
            draw_text(_text_x, _py, _pstr);
        }
        
        // Draw Text Input Box
        var _input_y = _prompt_start_y + (array_length(suggested_prompts) * 20) + 10;
        draw_set_color(scr_ui_theme_get(UI_TEXT_PRIMARY));
        var _disp_input = typed_input;
        if (floor(current_time / 500) mod 2 == 0) _disp_input += "_";
        draw_text(_text_x, _input_y, "Say: " + _disp_input);
        
    } else {
        // Blinks every 30 steps so the player knows to press a key.
        var _blink = (floor(current_time / (30 * (1000 / game_get_speed(gamespeed_fps)))) & 1) == 0;
        if (_blink) {
            draw_set_color(scr_ui_theme_get(UI_TEXT_SECONDARY));
            draw_set_halign(fa_right);
            draw_set_valign(fa_middle);
            draw_text(_prompt_x, _prompt_y, "[ E / SPACE ] Continue");
        }
    }
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
