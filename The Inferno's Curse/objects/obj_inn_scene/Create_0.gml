// =============================================================================
// obj_inn_scene — Create
// =============================================================================
// Room controller for Room_fiorentine_inn (ground floor). Builds the props +
// black-void collision (scr_inn_build), spawns the south doorway exit back to
// Florence and the stairs-up transition, and fires the entry banner. The floor /
// rug / void are PAINTED in Draw_0. obj_game_manager is persistent so globals are live.
if (room != Room_fiorentine_inn) exit;

// ── Props + black-void collision (void-ring walls + per-prop footprints) ────────
scr_inn_build();

// ── South doorway → Florence (draggable + persistable; F8 saves) ────────────────
global.inn_exit = scr_transition_spawn("inn_south",
    INN_EXIT_X - 96, INN_EXIT_Y - 24, 192, 80,
    "Room1", "Florence", 1118, 1462, "");

// ── Stairs up → upper floor (Room_fiorentine_inn_2f is a later step; the exit
// shows "coming soon" gracefully until that room exists) ────────────────────────
scr_transition_spawn("inn_stairs_up", 17 * 64, 8 * 64, 64, 128,
    "Room_fiorentine_inn_2f", "Upstairs", 640, 768, "");

// ── Entry banner (gold FF6 plaque, fades after 3s) ──────────────────────────────
scr_banner_show("Fiorentine Inn");
