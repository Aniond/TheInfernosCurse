// =============================================================================
// obj_character_sheet — Create
// =============================================================================
// FF6-style character sheet (reference: references/character_sheet.png).
// Persistent singleton, spawned by obj_game_manager Create. Toggle: C
// (Shift+C while debug mode is on — plain C cycles the Focus class there).
// ESC also closes. Opening pauses GAME TIME (scr_time_step guard) and locks
// player input; corruption keeps running — the Curse does not wait.
// =============================================================================

is_open  = false;
fade     = 0;      // 0..1 — smooth fade in/out
held_input_lock = false;   // we only release input_locked if WE took it

// quote cache — re-rolled each open so the tier always matches
quote_text = "";

global.char_sheet_open = false;

/// Mock quote pool by Limbo corruption tier (Claude API hook goes here later).
function scr_char_sheet_quote() {
    var _c = clamp(global.circle_corruption[CIRCLE_LIMBO], 0, 100);
    if (_c >= 100) return "...";
    if (_c >= 75)  return "Qualcosa cammina nelle mie scarpe. Non sono sicuro di essere ancora io.";
    if (_c >= 50)  return "Non ricordo quando ho smesso di riconoscere le strade.";
    if (_c >= 25)  return "La fede è ancora con me. Ma qualcosa mi segue nell'ombra.";
    return "Un servo di Dio che cammina tra luci e ombre in una città che dimentica.";
}

// ── Procedural drawing helpers (instance methods, used by Draw GUI) ───────────

/// Florentine fleur-de-lis glyph: centre petal + two side petals + band.
function scr_cs_fleur(_fx, _fy, _s, _col) {
    draw_set_color(_col);
    draw_triangle(_fx, _fy - _s, _fx - _s * 0.35, _fy + _s * 0.3, _fx + _s * 0.35, _fy + _s * 0.3, false);            // centre petal
    draw_triangle(_fx - _s * 0.85, _fy - _s * 0.35, _fx - _s * 0.25, _fy + _s * 0.25, _fx - _s * 0.75, _fy + _s * 0.35, false); // left petal
    draw_triangle(_fx + _s * 0.85, _fy - _s * 0.35, _fx + _s * 0.25, _fy + _s * 0.25, _fx + _s * 0.75, _fy + _s * 0.35, false); // right petal
    draw_rectangle(_fx - _s * 0.55, _fy + _s * 0.32, _fx + _s * 0.55, _fy + _s * 0.52, false);                         // band
    draw_triangle(_fx, _fy + _s, _fx - _s * 0.28, _fy + _s * 0.55, _fx + _s * 0.28, _fy + _s * 0.55, false);           // foot
}

/// One reputation row: label, five pips (filled by score), status word.
/// _icon: 0 fleur · 1 cross · 2 person · 3 crown
function scr_cs_rep_row(_x, _y, _label, _score, _icon, _pos, _neu, _neg) {
    var _ink2   = scr_ui_theme_get(UI_TEXT_SECONDARY);
    var _accent = scr_ui_theme_get(UI_ACCENT);
    var _high   = scr_ui_theme_get(UI_HIGHLIGHT);
    var _empty  = merge_color(scr_ui_theme_get(UI_PARCHMENT), scr_ui_theme_get(UI_BACKGROUND), 0.45);
    draw_set_font(FONT_BODY);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(_ink2);
    draw_text(_x, _y, _label);
    // pips
    var _filled = clamp(round((_score + 100) / 40), 0, 5);
    for (var _p = 0; _p < 5; _p++) {
        var _px = _x + 8 + _p * 22, _py = _y + 26;
        var _col = (_p < _filled) ? _accent : _empty;
        switch (_icon) {
            case 0: scr_cs_fleur(_px, _py, 6, _col); break;
            case 1: // cross
                draw_set_color(_col);
                draw_rectangle(_px - 1, _py - 7, _px + 1, _py + 7, false);
                draw_rectangle(_px - 5, _py - 3, _px + 5, _py - 1, false);
                break;
            case 2: // person — head + shoulders
                draw_set_color(_col);
                draw_circle(_px, _py - 4, 3, false);
                draw_triangle(_px, _py - 2, _px - 5, _py + 7, _px + 5, _py + 7, false);
                break;
            case 3: // crown — three spikes on a band
                draw_set_color(_col);
                draw_triangle(_px - 6, _py + 4, _px - 6, _py - 6, _px - 2, _py + 1, false);
                draw_triangle(_px,     _py + 4, _px,     _py - 7, _px,     _py + 4, false);
                draw_triangle(_px - 3, _py + 2, _px,     _py - 7, _px + 3, _py + 2, false);
                draw_triangle(_px + 6, _py + 4, _px + 6, _py - 6, _px + 2, _py + 1, false);
                draw_rectangle(_px - 6, _py + 3, _px + 6, _py + 6, false);
                break;
        }
    }
    // status word
    var _status = (_score >= 30) ? _pos : ((_score <= -30) ? _neg : _neu);
    var _scol   = (_score >= 30) ? _accent : ((_score <= -30) ? _high : _ink2);
    draw_set_color(_scol);
    draw_text(_x + 126, _y + 20, _status);
}

/// One stat row: small icon square, label, value, proportional bar.
function scr_cs_stat_row(_x, _y, _label, _val, _bar_col) {
    var _ink   = scr_ui_theme_get(UI_TEXT_PRIMARY);
    var _ink2  = scr_ui_theme_get(UI_TEXT_SECONDARY);
    var _track = merge_color(scr_ui_theme_get(UI_PARCHMENT), scr_ui_theme_get(UI_BACKGROUND), 0.35);
    draw_set_font(FONT_BODY);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(_bar_col);
    draw_rectangle(_x, _y + 3, _x + 10, _y + 13, false);
    draw_set_color(_ink);
    draw_text(_x + 22, _y, _label);
    draw_set_halign(fa_right);
    draw_set_color(_ink2);
    draw_text(_x + 150, _y, string(_val));
    draw_set_halign(fa_left);
    draw_set_color(_track);
    draw_rectangle(_x + 170, _y + 4, _x + 350, _y + 12, false);
    draw_set_color(_bar_col);
    draw_rectangle(_x + 170, _y + 4, _x + 170 + 180 * clamp(_val / 30, 0, 1), _y + 12, false);
    draw_set_color(scr_ui_theme_get(UI_BORDER));
    draw_rectangle(_x + 170, _y + 4, _x + 350, _y + 12, true);
}
