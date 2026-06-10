// =============================================================================
// obj_inn_scene — Create
// =============================================================================
// Room controller for Room_locanda_rosa_camuna (ground floor). Builds the props +
// black-void collision (scr_inn_build), spawns the south doorway exit back to
// Florence and the stairs-up transition, and fires the entry banner. The floor /
// rug / void are PAINTED in Draw_0. obj_game_manager is persistent so globals are live.
if (room != Room_locanda_rosa_camuna) exit;

// ── Props + black-void collision (void-ring walls + per-prop footprints) ────────
scr_inn_build();

// ── South doorway → Florence (draggable + persistable; F8 saves) ────────────────
global.inn_exit = scr_transition_spawn("inn_south",
    INN_EXIT_X - 96, INN_EXIT_Y - 24, 192, 80,
    "Room_florence_v2", "Firenze", 1331, 1240, "");

// ── Stairs up → upper floor (Room_locanda_rosa_camuna_2f is a later step; the exit
// shows "coming soon" gracefully until that room exists). Trigger sits on the
// staircase's bottom landing (the 2x4 run occupies x13-14, y4-7). ───────────────
scr_transition_spawn("inn_stairs_up", 13 * 64, 7 * 64, 128, 64,
    "Room_locanda_rosa_camuna_2f", "Upstairs", 640, 768, "");

// ── Entry banner (gold FF6 plaque, fades after 3s) ──────────────────────────────
scr_banner_show("Locanda della Rosa Camuna");
