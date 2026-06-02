// =============================================================================
// obj_battle_manager — Draw GUI
// HUD: corruption meter, turn order strip, combat log, action hints,
// sanity-zero freeze message.
// All coordinates are in GUI space (1366×768).
// =============================================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// ── Header bar ────────────────────────────────────────────────────────────────
// Round counter + corruption meter across the top 64px.
draw_set_color(make_color_rgb(6, 4, 10));
draw_rectangle(0, 0, _gw, 63, false);
draw_set_color(make_color_rgb(40, 28, 60));
draw_rectangle(0, 62, _gw, 63, false);

// Round counter
draw_set_color(make_color_rgb(160, 140, 200));
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(12, 32, "Round " + string(global.battle_round));

// Corruption meter (centred in header)
var _bar_x   = 300;
var _bar_y   = 20;
var _bar_w   = _gw - 600;
var _bar_h   = 22;
var _cf      = clamp(global.battle_corruption / 100, 0, 1);

draw_set_color(make_color_rgb(30, 20, 45));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
var _fill_col = merge_color(
    make_color_rgb(80, 40, 160),
    make_color_rgb(180, 20, 20),
    _cf
);
draw_set_color(_fill_col);
draw_rectangle(_bar_x, _bar_y, _bar_x + floor(_bar_w * _cf), _bar_y + _bar_h, false);
draw_set_color(make_color_rgb(100, 80, 160));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

draw_set_color(make_color_rgb(200, 180, 230));
draw_set_halign(fa_center);
draw_text(_bar_x + _bar_w / 2, _bar_y + _bar_h / 2 + 1,
    "Limbo Corruption: " + string(round(global.battle_corruption)) + "%");

// Phase label (right side)
var _phase_str = "";
switch (battle_phase) {
    case "player_turn": _phase_str = "[ YOUR TURN ]";   break;
    case "enemy_turn":  _phase_str = "[ ENEMY TURN ]";  break;
    case "setup":       _phase_str = "...";             break;
    case "end":         _phase_str = "[ BATTLE END ]";  break;
}
draw_set_color(make_color_rgb(180, 160, 100));
draw_set_halign(fa_right);
draw_text(_gw - 12, 32, _phase_str);

// ── Left panel: turn order strip (0-191, 64-575) ──────────────────────────────
draw_set_color(make_color_rgb(10, 6, 16));
draw_rectangle(0, 64, 191, 575, false);
draw_set_color(make_color_rgb(30, 20, 50));
draw_rectangle(190, 64, 191, 575, false);

draw_set_color(make_color_rgb(120, 100, 160));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(95, 72, "Turn Order");
draw_set_color(make_color_rgb(50, 35, 70));
draw_line(10, 88, 182, 88);

var _slot_y = 96;
for (var _i = 0; _i < array_length(turn_order); _i++) {
    var _uid = turn_order[_i];
    if (!instance_exists(_uid)) continue;

    var _is_active = (_i == active_unit_idx)
                  && (battle_phase == "player_turn" || battle_phase == "enemy_turn");

    // Slot background
    draw_set_color(_is_active ? make_color_rgb(60, 50, 20) : make_color_rgb(20, 14, 30));
    draw_rectangle(8, _slot_y, 183, _slot_y + 36, false);
    if (_is_active) {
        draw_set_color(make_color_rgb(180, 160, 60));
        draw_rectangle(8, _slot_y, 183, _slot_y + 36, true);
    }

    // Unit name
    var _name_col = (_uid.team == 0)
        ? make_color_rgb(200, 180, 120)
        : make_color_rgb(200, 80, 80);
    draw_set_color(_name_col);
    draw_set_halign(fa_left);
    draw_text(14, _slot_y + 4, _uid.unit_name);

    // HP bar in slot
    var _hp_ratio = clamp(_uid.hp / _uid.max_hp, 0, 1);
    draw_set_color(make_color_rgb(50, 10, 10));
    draw_rectangle(14, _slot_y + 22, 178, _slot_y + 30, false);
    draw_set_color(make_color_rgb(60, 200, 60));
    draw_rectangle(14, _slot_y + 22, 14 + floor(164 * _hp_ratio), _slot_y + 30, false);

    // Forgotten icon
    if (scr_battle_has_status(_uid, "forgotten")) {
        draw_set_color(make_color_rgb(120, 90, 220));
        draw_set_halign(fa_right);
        draw_text(180, _slot_y + 4, "FORGOT");
    }

    _slot_y += 42;
    if (_slot_y > 550) break;   // overflow guard
}

// ── Right panel: combat log (832-1365, 64-575) ────────────────────────────────
draw_set_color(make_color_rgb(10, 6, 16));
draw_rectangle(833, 64, _gw - 1, 575, false);
draw_set_color(make_color_rgb(40, 28, 60));
draw_rectangle(833, 64, 834, 575, false);

draw_set_color(make_color_rgb(120, 100, 160));
draw_set_halign(fa_left);
draw_text(844, 72, "Chronicle");
draw_set_color(make_color_rgb(50, 35, 70));
draw_line(844, 88, _gw - 10, 88);

var _log_y = 96;
var _log_entries = min(array_length(combat_log), combat_log_capacity);
for (var _li = 0; _li < _log_entries; _li++) {
    draw_set_color(make_color_rgb(160 - _li * 12, 140 - _li * 10, 180 - _li * 8));
    draw_text_ext(844, _log_y, combat_log[_li], -1, _gw - 854);
    _log_y += 24;
}

// ── Bottom bar: action hints (576-767) ────────────────────────────────────────
draw_set_color(make_color_rgb(8, 5, 12));
draw_rectangle(0, 576, _gw, _gh, false);
draw_set_color(make_color_rgb(40, 28, 60));
draw_rectangle(0, 576, _gw, 577, false);

draw_set_color(make_color_rgb(100, 85, 130));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
if (battle_phase == "player_turn") {
    draw_text(_gw / 2, 620,
        "[WASD] Move   [F] Focus (see shimmer, -" + string(LIMBO_SHIMMER_COST) + " sanity)   [Z / ENTER] End turn");
    draw_text(_gw / 2, 648,
        "Sanity: " + string(round(global.sanity)) + "%   "
        + "AP: " + (instance_exists(obj_unit_benedetto)
                    ? string(obj_unit_benedetto.ap) + "/" + string(obj_unit_benedetto.max_ap)
                    : "--"));
}

// ── Sanity-zero freeze message ────────────────────────────────────────────────
if (show_sanity_zero_text && sanity_zero_alpha > 0) {
    draw_set_alpha(sanity_zero_alpha * 0.85);
    draw_set_color(make_color_rgb(4, 2, 8));
    draw_rectangle(_gw / 2 - 340, _gh / 2 - 50, _gw / 2 + 340, _gh / 2 + 50, false);
    draw_set_alpha(sanity_zero_alpha);
    draw_set_color(make_color_rgb(160, 120, 200));
    draw_rectangle(_gw / 2 - 340, _gh / 2 - 50, _gw / 2 + 340, _gh / 2 + 50, true);
    draw_set_color(make_color_rgb(200, 180, 230));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_gw / 2, _gh / 2, "He could no longer find his way back.");
}

// ── Reset draw state ──────────────────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
