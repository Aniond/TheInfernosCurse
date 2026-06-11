// =============================================================================
// obj_character_sheet — Draw GUI
// =============================================================================
// Layout matches references/character_sheet.png: dark oak frame, parchment
// body; LEFT portrait panel (Benedetto — single permanent portrait, David's
// call 2026-06-10) with name plate + Florentine banner; RIGHT panel with
// class/level/Firenze header + Duomo silhouette, HP/MP bars, four reputation
// rows with procedural pips, seven stats with bars, candlelit quote box, red
// wax seal. ALL colors via scr_ui_theme_get (UI THEME RULE); fonts scr_fonts.
// =============================================================================
if (fade <= 0.01) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// theme palette
var _bg     = scr_ui_theme_get(UI_BACKGROUND);
var _parch  = scr_ui_theme_get(UI_PARCHMENT);
var _ink    = scr_ui_theme_get(UI_TEXT_PRIMARY);
var _ink2   = scr_ui_theme_get(UI_TEXT_SECONDARY);
var _accent = scr_ui_theme_get(UI_ACCENT);
var _high   = scr_ui_theme_get(UI_HIGHLIGHT);
var _border = scr_ui_theme_get(UI_BORDER);
var _glow   = scr_ui_theme_get(UI_CANDLE_GLOW);

// ── dark overlay ──────────────────────────────────────────────────────────────
draw_set_alpha(0.82 * fade);
draw_set_color(merge_color(c_black, _bg, 0.4));
draw_rectangle(0, 0, _gw, _gh, false);

// ── sheet geometry ────────────────────────────────────────────────────────────
var _w  = 920, _h = 620;
var _x0 = (_gw - _w) * 0.5;
var _y0 = (_gh - _h) * 0.5 + (1 - fade) * 24;   // slides up slightly as it fades in
draw_set_alpha(fade);

// dark oak frame (outer) + parchment body (inner)
draw_set_color(merge_color(_bg, c_black, 0.25));
draw_rectangle(_x0 - 14, _y0 - 14, _x0 + _w + 14, _y0 + _h + 14, false);
draw_set_color(_border);
draw_rectangle(_x0 - 14, _y0 - 14, _x0 + _w + 14, _y0 + _h + 14, true);
draw_rectangle(_x0 - 10, _y0 - 10, _x0 + _w + 10, _y0 + _h + 10, true);
draw_set_color(_parch);
draw_rectangle(_x0, _y0, _x0 + _w, _y0 + _h, false);
draw_set_color(_border);
draw_rectangle(_x0, _y0, _x0 + _w, _y0 + _h, true);

// =============================================================================
// LEFT PANEL — portrait
// =============================================================================
var _lp_w = 300;
draw_set_color(_border);
draw_line(_x0 + _lp_w, _y0, _x0 + _lp_w, _y0 + _h);

// Florentine banner strip (left edge) with gold fleur pips
draw_set_color(merge_color(_high, _bg, 0.2));
draw_rectangle(_x0 + 10, _y0 + 10, _x0 + 38, _y0 + 150, false);
draw_set_color(_accent);
for (var _f = 0; _f < 3; _f++) scr_cs_fleur(_x0 + 24, _y0 + 36 + _f * 40, 7, _accent);

// portrait frame + the one permanent Benedetto
var _pw = 128 * 1.8, _ph = 128 * 1.8;          // 230x230
var _px = _x0 + (_lp_w - _pw) * 0.5 + 12;
var _py = _y0 + 36;
draw_set_color(merge_color(_bg, c_black, 0.3));
draw_rectangle(_px - 8, _py - 8, _px + _pw + 8, _py + _ph + 8, false);
draw_set_color(_accent);
draw_rectangle(_px - 8, _py - 8, _px + _pw + 8, _py + _ph + 8, true);
draw_sprite_ext(spr_benedetto_portrait, 0, _px, _py, 1.8, 1.8, 0, c_white, fade);
draw_set_color(_border);
draw_rectangle(_px - 2, _py - 2, _px + _pw + 2, _py + _ph + 2, true);

// name plate
var _np_y = _py + _ph + 26;
draw_set_color(merge_color(_parch, _bg, 0.12));
draw_rectangle(_x0 + 34, _np_y - 8, _x0 + _lp_w - 34, _np_y + 52, false);
draw_set_color(_border);
draw_rectangle(_x0 + 34, _np_y - 8, _x0 + _lp_w - 34, _np_y + 52, true);
draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_set_font(FONT_TITLE);
draw_set_color(_ink);
draw_text(_x0 + _lp_w * 0.5, _np_y, "Benedetto");
draw_set_font(FONT_BODY);
draw_set_color(merge_color(_high, _ink2, 0.35));
draw_text(_x0 + _lp_w * 0.5, _np_y + 28, "Chierico di Santa Trinita");

// red wax seal with fleur — bottom of the left panel
var _seal_x = _x0 + _lp_w * 0.5, _seal_y = _y0 + _h - 38;
draw_set_color(merge_color(_high, c_black, 0.15));
draw_circle(_seal_x, _seal_y, 24, false);
draw_set_color(merge_color(_high, _parch, 0.18));
draw_circle(_seal_x, _seal_y, 24, true);
draw_circle(_seal_x, _seal_y, 17, true);
scr_cs_fleur(_seal_x, _seal_y, 9, merge_color(_high, _parch, 0.4));

// =============================================================================
// RIGHT PANEL
// =============================================================================
var _rx = _x0 + _lp_w + 28;
var _rw = _w - _lp_w - 56;

// ── header: class / level | fleur | Firenze + Duomo silhouette ────────────────
draw_set_halign(fa_left);
draw_set_font(FONT_TITLE);
draw_set_color(_ink);
draw_text(_rx, _y0 + 16, "Chierico");
draw_set_font(FONT_BODY);
draw_set_color(_ink2);
var _lvl = variable_global_exists("player_stats") ? global.player_stats.level : 1;
draw_text(_rx, _y0 + 44, "Livello " + string(_lvl));

// centre fleur
scr_cs_fleur(_rx + _rw * 0.46, _y0 + 34, 12, merge_color(_high, _accent, 0.3));

// Firenze block (right-aligned) + Duomo silhouette
draw_set_halign(fa_right);
draw_set_font(FONT_TITLE);
draw_set_color(_ink);
draw_text(_rx + _rw, _y0 + 16, "Firenze");
draw_set_font(FONT_BODY);
draw_set_color(_ink2);
draw_text(_rx + _rw, _y0 + 44, "Anno del Signore 1300");
// tiny Duomo: drum + dome arc + lantern, in border tone
var _dx = _rx + _rw - 150, _dy = _y0 + 30;
draw_set_color(merge_color(_border, _ink2, 0.4));
draw_rectangle(_dx - 14, _dy + 6, _dx + 14, _dy + 16, false);          // drum
draw_circle(_dx, _dy + 6, 13, false);                                  // dome
draw_rectangle(_dx - 1, _dy - 12, _dx + 1, _dy - 6, false);            // lantern
draw_set_halign(fa_left);

// divider
draw_set_color(_border);
draw_line(_rx, _y0 + 70, _rx + _rw, _y0 + 70);

// ── HP / MP bars (left half) ──────────────────────────────────────────────────
var _hp     = instance_exists(obj_player) ? obj_player.hp     : 0;
var _hp_max = instance_exists(obj_player) ? obj_player.max_hp : 100;
var _st     = variable_global_exists("player_stats") ? global.player_stats : undefined;
var _sp     = (_st != undefined) ? _st.sp     : 0;
var _sp_max = (_st != undefined) ? _st.sp_max : 1;

var _bar_w = 250, _bar_h = 12;
var _by = _y0 + 88;
draw_set_color(_ink);
draw_text(_rx, _by - 4, "HP");
draw_set_halign(fa_right);
draw_text(_rx + _bar_w + 110, _by - 4, string(round(_hp)) + " / " + string(round(_hp_max)));
draw_set_halign(fa_left);
draw_set_color(merge_color(_parch, _bg, 0.35));
draw_rectangle(_rx + 40, _by, _rx + 40 + _bar_w, _by + _bar_h, false);
draw_set_color(_accent);                                   // spec: theme accent bar
draw_rectangle(_rx + 40, _by, _rx + 40 + _bar_w * clamp(_hp / max(_hp_max, 1), 0, 1), _by + _bar_h, false);
draw_set_color(_border);
draw_rectangle(_rx + 40, _by, _rx + 40 + _bar_w, _by + _bar_h, true);

// ── skill points (Punti Abilità) — discrete pips, not a bar ───────────────────
_by += 34;
draw_set_color(_ink);
draw_text(_rx, _by - 4, "PA");
draw_set_halign(fa_right);
draw_text(_rx + _bar_w + 110, _by - 4, string(round(_sp)) + " / " + string(round(_sp_max)));
draw_set_halign(fa_left);
var _sp_col   = merge_color(_glow, _high, 0.30);                       // ember tone, theme-derived
var _sp_empty = merge_color(_parch, _bg, 0.40);
var _sp_n     = clamp(round(_sp_max), 1, 12);
for (var _spi = 0; _spi < _sp_n; _spi++) {
    var _spx = _rx + 44 + _spi * 22;
    draw_set_color((_spi < _sp) ? _sp_col : _sp_empty);
    draw_rectangle(_spx, _by, _spx + 14, _by + _bar_h, false);
    draw_set_color(_border);
    draw_rectangle(_spx, _by, _spx + 14, _by + _bar_h, true);
}

// ── reputation block (right half) ─────────────────────────────────────────────
var _rep = variable_global_exists("reputation") ? global.reputation
         : { gilda: 0, chiesa: 0, comune: 0, nobile: 0 };
var _rep_x = _rx + _rw - 240;
var _rep_y = _y0 + 82;
scr_cs_rep_row(_rep_x, _rep_y,      "Reputazione di Gilda",      _rep.gilda,  0, "Rispettato", "Neutrale", "Disprezzato");
scr_cs_rep_row(_rep_x, _rep_y + 52, "Reputazione Ecclesiastica", _rep.chiesa, 1, "Devoto",     "Neutrale", "Scomunicato");
scr_cs_rep_row(_rep_x, _rep_y + 104,"Reputazione Comune",        _rep.comune, 2, "Amato",      "Neutrale", "Temuto");
scr_cs_rep_row(_rep_x, _rep_y + 156,"Reputazione Nobile",        _rep.nobile, 3, "Favorito",   "Neutrale", "Sospetto");

// ── stats section ─────────────────────────────────────────────────────────────
var _sy = _y0 + 196;
draw_set_color(_border);
draw_line(_rx, _sy - 12, _rx + _rw - 260, _sy - 12);
if (_st != undefined) {
    scr_cs_stat_row(_rx, _sy,       "Forza",     _st.forza,     _high);
    scr_cs_stat_row(_rx, _sy + 30,  "Vitalità",  _st.vitalita,  merge_color(_accent, _high, 0.4));
    scr_cs_stat_row(_rx, _sy + 60,  "Saggezza",  _st.saggezza,  merge_color(_accent, _ink2, 0.3));
    scr_cs_stat_row(_rx, _sy + 90,  "Agilità",   _st.agilita,   merge_color(_glow, _accent, 0.4));
    scr_cs_stat_row(_rx, _sy + 120, "Fede",      _st.fede,      _accent);
    draw_set_color(_ink);
    draw_text(_rx, _sy + 152, "Movimento");
    draw_set_color(_ink2);
    draw_text(_rx + 110, _sy + 152, string(_st.movimento) + " celle per turno");
    draw_set_color(_ink);
    draw_text(_rx, _sy + 176, "Salto");
    draw_set_color(_ink2);
    draw_text(_rx + 110, _sy + 176, string(_st.salto) + " altezza");
}

// ── quote box (candlelit parchment, bottom right) ─────────────────────────────
var _qx = _rx, _qy = _y0 + _h - 120, _qw = _rw, _qh = 96;
draw_set_color(merge_color(_parch, _glow, 0.10));
draw_rectangle(_qx, _qy, _qx + _qw, _qy + _qh, false);
draw_set_color(_border);
draw_rectangle(_qx, _qy, _qx + _qw, _qy + _qh, true);
// candle: stem + flame glow
draw_set_color(merge_color(_parch, _ink2, 0.5));
draw_rectangle(_qx + 18, _qy + 38, _qx + 26, _qy + 74, false);
draw_set_color(_glow);
draw_circle(_qx + 22, _qy + 30, 6, false);
draw_set_alpha(0.35 * fade);
draw_circle(_qx + 22, _qy + 30, 14, false);
draw_set_alpha(fade);
// the quote
draw_set_color(_ink);
draw_text_ext(_qx + 48, _qy + 16, "\"" + quote_text + "\"", 20, _qw - 70);

// ── footer hint ───────────────────────────────────────────────────────────────
draw_set_color(_ink2);
draw_set_halign(fa_center);
draw_text(_x0 + _w * 0.5, _y0 + _h + 18, "[C / ESC] chiudi");
draw_set_halign(fa_left);

// reset
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_valign(fa_top);
