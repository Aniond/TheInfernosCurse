if (!is_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// UI THEME RULE: all colors come from scr_ui_theme_get (see .claude/skills/ui-theme).
// The journal panel is dark, so light text = UI_PARCHMENT and dimmer secondary
// lines are derived by merging theme keys — never raw RGB.
var _th_bg     = scr_ui_theme_get(UI_BACKGROUND);
var _th_parch  = scr_ui_theme_get(UI_PARCHMENT);
var _th_accent = scr_ui_theme_get(UI_ACCENT);
var _th_border = scr_ui_theme_get(UI_BORDER);
var _th_dim    = merge_color(_th_parch, _th_bg, 0.35);   // secondary lines
var _th_faint  = merge_color(_th_parch, _th_bg, 0.55);   // hints / empty state

// Full-screen dark overlay
draw_set_alpha(0.95);
draw_set_color(_th_bg);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Codex cover art — drawn behind journal panel, fades 1.0 → 0.3 on open
var _cover_x = _gw / 2 - 400;
var _cover_y = _gh / 2 - 400;
draw_set_alpha(codex_cover_alpha);
draw_sprite_stretched_ext(spr_ui_codex_cover, 0, _cover_x, _cover_y, 800, 800, c_white, 1);
draw_set_alpha(1);

// Journal background — semi-transparent so cover bleeds through at rest alpha
var _x = _gw / 2 - 400;
var _y = 40;
var _w = 800;
var _h = _gh - 80;

draw_set_alpha(0.78);
draw_set_color(_th_bg);
draw_rectangle(_x, _y, _x + _w, _y + _h, false);
draw_set_alpha(1);
draw_set_color(_th_border);
draw_rectangle(_x, _y, _x + _w, _y + _h, true);

// Title
draw_set_color(_th_accent);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_gw / 2, _y + 16, "CODEX OF FATHER BENEDETTO");
draw_set_color(_th_dim);
draw_text(_gw / 2, _y + 34, "Priest of Florence  ·  Anno Domini 1300");

// Separator line under title
draw_set_color(_th_border);
draw_line(_x + 20, _y + 56, _x + _w - 20, _y + 56);

// Entry content
draw_set_color(_th_parch);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _entry_x = _x + 40;
var _entry_y = _y + 70;
var _entry_w = _w - 80;

if (ds_list_size(journal_entries) > 0 && current_page >= 0 && current_page < ds_list_size(journal_entries)) {
    var _raw   = ds_list_find_value(journal_entries, current_page);
    var _entry = json_parse(_raw);
    // Day header
    draw_set_color(_th_accent);
    draw_text(_entry_x, _entry_y, "Day " + string(_entry.day));
    // Entry body
    draw_set_color(_th_parch);
    draw_text_ext(_entry_x, _entry_y + 30, _entry.text, 28, _entry_w);
} else if (generating) {
    // Loading animation
    dot_timer++;
    if (dot_timer >= 20) {
        dot_timer = 0;
        if (string_length(dot_string) >= 4) {
            dot_string = ".";
        } else {
            dot_string += ".";
        }
    }
    draw_set_color(_th_dim);
    draw_set_halign(fa_center);
    draw_text(_gw / 2, _y + _h / 2, "Benedetto writes" + dot_string);
    draw_set_halign(fa_left);
} else {
    draw_set_color(_th_faint);
    draw_set_halign(fa_center);
    draw_text(_gw / 2, _y + _h / 2, "The codex is empty.");
    draw_set_halign(fa_left);
}

// Page indicator
if (total_pages > 1) {
    draw_set_color(_th_dim);
    draw_set_halign(fa_center);
    draw_text(_gw / 2, _y + _h - 30,
        string(current_page + 1) + " / " + string(total_pages));
}

// Navigation hint
draw_set_color(_th_faint);
draw_set_halign(fa_center);
draw_text(_gw / 2, _y + _h - 15, "[W/S] scroll   [J/ESC] close");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
