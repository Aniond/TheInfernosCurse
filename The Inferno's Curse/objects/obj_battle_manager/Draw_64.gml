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

// Atmospheric header text — no numbers, no meter
var _atm_str;
if (global.battle_corruption < 25)       _atm_str = "The air feels wrong.";
else if (global.battle_corruption < 50)  _atm_str = "Something stirs beneath Florence.";
else if (global.battle_corruption < 75)  _atm_str = "Florence is forgetting itself.";
else if (global.battle_corruption < 100) _atm_str = "The city is almost lost.";
else                                      _atm_str = "He could no longer find his way back.";

draw_set_color(make_color_rgb(140, 120, 170));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_gw / 2, 32, _atm_str);

// Debug overlay
if (global.debug_mode) {
    draw_set_color(make_color_rgb(160, 220, 160));
    draw_set_halign(fa_left);
    draw_text(32, 32,
        "S:" + string(round(global.sanity)) +
        " | C:" + string(round(global.battle_corruption)) +
        " | R:" + string(global.battle_round));
}

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

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (battle_phase == "player_turn") {
    var _bene_ap = instance_exists(obj_unit_benedetto) ? obj_unit_benedetto.ap : 0;
    var _bene_max = instance_exists(obj_unit_benedetto) ? obj_unit_benedetto.max_ap : 3;

    // Movement / turn / flee hints
    draw_set_color(make_color_rgb(100, 85, 130));
    if (_bene_ap <= 0) {
        draw_set_color(make_color_rgb(220, 200, 80));
        draw_text(_gw / 2, 600, "No moves remaining  --  [Z / ENTER] to end turn   [ESC] Flee  (+corruption)");
    } else {
        draw_text(_gw / 2, 600, "[WASD / ↑↓←→] Move      [Z / ENTER] End turn      [ESC] Flee  (+corruption)");
    }

    // Focus hint — ALWAYS visible. Label + colour reflect remaining charges.
    var _fc = variable_global_exists("focus_charges") ? global.focus_charges : 1;
    var _focus_label;
    var _focus_col;
    if (global.debug_mode) {
        _focus_label = "[F] Focus  (debug: unlimited)";
        _focus_col   = make_color_rgb(160, 220, 160);
    } else if (_fc <= 0) {
        _focus_label = "[F] Focus  (spent)";
        _focus_col   = make_color_rgb(70, 62, 80);     // greyed out — gone, but still shown
    } else if (_fc == 1) {
        _focus_label = "[F] Focus  (last chance)";
        _focus_col   = make_color_rgb(210, 130, 90);   // warm amber — urgent
    } else {
        _focus_label = "[F] Focus  (" + string(_fc) + " charges)";
        _focus_col   = make_color_rgb(150, 130, 190);
    }
    draw_set_color(_focus_col);
    draw_text(_gw / 2, 632, _focus_label);

    if (global.debug_mode) {
        draw_set_color(make_color_rgb(160, 220, 160));
        draw_set_halign(fa_right);
        draw_text(_gw - 16, 32,
            "AP:" + string(_bene_ap) + "/" + string(_bene_max) + "  FC:inf");
    }
}

// ── Flee confirmation overlay ─────────────────────────────────────────────────
if (flee_confirm) {
    // Dim background
    draw_set_alpha(0.8);
    draw_set_color(make_color_rgb(4, 2, 8));
    draw_rectangle(_gw / 2 - 320, _gh / 2 - 70, _gw / 2 + 320, _gh / 2 + 70, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(160, 60, 60));
    draw_rectangle(_gw / 2 - 320, _gh / 2 - 70, _gw / 2 + 320, _gh / 2 + 70, true);

    draw_set_color(make_color_rgb(230, 200, 200));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_gw / 2, _gh / 2 - 28, "Flee from battle?");
    draw_text(_gw / 2, _gh / 2,      "Cowardice has a cost.");
    draw_set_color(make_color_rgb(200, 160, 80));
    draw_text(_gw / 2, _gh / 2 + 32, "[Y] Flee          [N / ESC] Stay and fight");
}

// ── Sanity-zero message (now just informational — no lock) ───────────────────
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
