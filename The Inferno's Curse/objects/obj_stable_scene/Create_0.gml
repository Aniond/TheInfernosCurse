// =============================================================================
// obj_stable_scene — Create
// =============================================================================
// Room controller for Room_fiorentine_stable. Builds the props + black-void
// collision (scr_stable_build), spawns the south doorway exit back to Florence,
// and fires the entry banner. The floor / void are PAINTED in Draw_0.
// obj_game_manager is persistent so globals are live.
if (room != Room_fiorentine_stable) exit;

// ── Props + black-void collision (void-ring walls + per-prop footprints) ────────
scr_stable_build();

// ── South doorway → Florence (draggable + persistable; F8 saves) ────────────────
scr_transition_spawn("stable_south",
    STABLE_EXIT_X - 96, STABLE_EXIT_Y - 24, 192, 80,
    "Room_florence_v2", "Firenze", 1216, 616, "");

// ── Entry banner (gold FF6 plaque, fades after 3s) ──────────────────────────────
scr_banner_show("Fiorentine Stable");

// ── Full corruption: the chronicle knows why the animals scream ─────────────────
if (global.circle_corruption[CIRCLE_LIMBO] >= 100)
    scr_chronicle_add("The horses know. They have always known.");
