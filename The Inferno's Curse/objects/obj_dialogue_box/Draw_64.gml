// ── Dialogue Box: Draw GUI ───────────────────────────────────────────────────
// Runs in GUI space so the box is always screen-anchored regardless of camera.

var _gw  = display_get_gui_width();
var _gh  = display_get_gui_height();
var _pad = 18;
var _bx  = 40;
var _bh  = 130;
var _by  = _gh - _bh - 20;
var _bw  = _gw - 80;

// ── Background (semi-transparent deep blue-black) ────────────────────────────
draw_set_alpha(0.88);
draw_set_color(make_color_rgb(8, 8, 18));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
draw_set_alpha(1.0);

// ── Border (hellish purple) ───────────────────────────────────────────────────
draw_set_color(make_color_rgb(130, 80, 180));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);

// ── Speaker name ──────────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(190, 140, 255));
draw_text(_bx + _pad, _by + _pad - 4, npc_name);

// ── Divider below name ────────────────────────────────────────────────────────
draw_set_color(make_color_rgb(70, 40, 100));
draw_line(_bx + _pad, _by + _pad + 16, _bx + _bw - _pad, _by + _pad + 16);

// ── Dialogue text (word-wrapped) ──────────────────────────────────────────────
draw_set_color(c_white);
draw_text_ext(
    _bx + _pad,
    _by + _pad + 22,
    display_text,
    -1,               // auto line height
    _bw - _pad * 2   // wrap width
);

// ── Continue prompt (pulsing once the line is fully revealed) ─────────────────
if (finished) {
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.009);
    draw_set_color(merge_color(make_color_rgb(130, 80, 180), c_white, _pulse));
    draw_set_halign(fa_right);
    draw_text(_bx + _bw - _pad, _by + _bh - _pad - 4, "[ E ] Continue");
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
draw_set_color(c_white);
