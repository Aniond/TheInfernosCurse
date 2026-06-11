// ── Player: Draw GUI — HUD ───────────────────────────────────────────────────
// Numbers are hidden from the player. Atmosphere carries the state.
// HP is the only objective reality shown — it is physical, not psychological.

// Hide HUD entirely when dialogue is open — nothing overlays the parchment,
// not even debug values. Debug stats remain available on the normal HUD.
if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) exit;

var _bar_x = 16;
var _bar_y  = display_get_gui_height() - 40;

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_color(scr_ui_theme_get(UI_PARCHMENT));   // UI THEME RULE: no hardcoded UI colors
draw_text(_bar_x, _bar_y - 22, "HP  " + string(round(hp)) + " / " + string(round(max_hp)));

// Debug overlay — comprehensive HUD panels (see scr_debug); self-guards on F1.
scr_debug_gui_common(false);

// Location banner (FF6 gold plaque) — shown on entering a named room, fades after 3s.
scr_banner_draw();

draw_set_color(c_white);
