// =============================================================================
// scr_fonts — runtime bitmap/pixel fonts (no IDE font assets needed)
// =============================================================================
// Loaded via font_add() from Included Files (datafiles/fonts/) — sandbox-safe.
//   FONT_BODY  — Pixelify Sans (OFL): readable pixel body text. Dialogue,
//                journal entries, HUD, prompts, NPC labels, battle text.
//   FONT_TITLE — Alagard (free/commercial, Hewett Tsoi): medieval display.
//                Banners, the codex header, big UI titles.
// Every getter falls back to -1 (the engine default font) if loading failed,
// so a missing/broken TTF can never crash a draw call.
//
// scr_fonts_default() re-asserts FONT_BODY as the standing draw font — called
// once per frame from obj_game_manager Step because scr_debug intentionally
// switches to the default font (-1) for its overlays and never restores.
// =============================================================================

#macro FONT_BODY  scr_font_body()
#macro FONT_TITLE scr_font_title()

function scr_fonts_init() {
    global.__font_body  = font_add("fonts/PixelifySans-Regular.ttf", 14, false, false, 32, 255);
    global.__font_title = font_add("fonts/alagard.ttf",              20, false, false, 32, 255);
    if (global.__font_body  == -1) show_debug_message("[scr_fonts] body font failed to load — engine default in use");
    if (global.__font_title == -1) show_debug_message("[scr_fonts] title font failed to load — engine default in use");
    draw_set_font(scr_font_body());
}

function scr_font_body() {
    if (!variable_global_exists("__font_body"))  return -1;
    return (global.__font_body  >= 0) ? global.__font_body  : -1;
}

function scr_font_title() {
    if (!variable_global_exists("__font_title")) return -1;
    return (global.__font_title >= 0) ? global.__font_title : -1;
}

/// Re-assert the body font as the standing default (debug overlays reset it).
function scr_fonts_default() {
    draw_set_font(scr_font_body());
}
