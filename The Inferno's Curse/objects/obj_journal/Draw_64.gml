if (!is_open) exit;

// Full-screen dark overlay
draw_set_alpha(0.95);
draw_set_color(make_color_rgb(5, 5, 10));
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Journal background
var _x = display_get_gui_width() / 2 - 400;
var _y = 40;
var _w = 800;
var _h = display_get_gui_height() - 80;

draw_set_color(make_color_rgb(20, 15, 10));
draw_rectangle(_x, _y, _x + _w, _y + _h, false);
draw_set_color(make_color_rgb(80, 60, 40));
draw_rectangle(_x, _y, _x + _w, _y + _h, true);

// Title
draw_set_color(make_color_rgb(180, 150, 100));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(display_get_gui_width() / 2, _y + 20, "CODEX OF FATHER BENEDETTO");

// Separator line under title
draw_set_color(make_color_rgb(80, 60, 40));
draw_line(_x + 20, _y + 50, _x + _w - 20, _y + 50);

// Entry content
draw_set_color(make_color_rgb(200, 180, 140));
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _entry_x = _x + 40;
var _entry_y = _y + 70;
var _entry_w = _w - 80;

if (ds_list_size(journal_entries) > 0 && current_page >= 0 && current_page < ds_list_size(journal_entries)) {
    var _raw   = ds_list_find_value(journal_entries, current_page);
    var _entry = json_parse(_raw);
    // Day header
    draw_set_color(make_color_rgb(180, 150, 100));
    draw_text(_entry_x, _entry_y, "Day " + string(_entry.day));
    // Entry body
    draw_set_color(make_color_rgb(200, 180, 140));
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
    draw_set_color(make_color_rgb(140, 120, 90));
    draw_set_halign(fa_center);
    draw_text(display_get_gui_width() / 2, _y + _h / 2, "Benedetto writes" + dot_string);
    draw_set_halign(fa_left);
} else {
    draw_set_color(make_color_rgb(100, 90, 70));
    draw_set_halign(fa_center);
    draw_text(display_get_gui_width() / 2, _y + _h / 2, "The codex is empty.");
    draw_set_halign(fa_left);
}

// Page indicator
if (total_pages > 1) {
    draw_set_color(make_color_rgb(120, 100, 70));
    draw_set_halign(fa_center);
    draw_text(display_get_gui_width() / 2, _y + _h - 30,
        string(current_page + 1) + " / " + string(total_pages));
}

// Navigation hint
draw_set_color(make_color_rgb(80, 70, 55));
draw_set_halign(fa_center);
draw_text(display_get_gui_width() / 2, _y + _h - 15, "[W/S] scroll   [J/ESC] close");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
