// =============================================================================
// obj_duomo_scene — Create
// =============================================================================
// Room controller for Room_duomo (the cathedral interior). Builds the props +
// collision (scr_duomo_build), spawns the south doorway exit back to Florence, and
// fires a corruption-keyed chronicle line on entry. The floor/walls/dome and the
// candle-lit corruption states are PAINTED in Draw_0. obj_game_manager is
// persistent (created in Florence) so all globals are already live here.
if (room != Room_duomo) exit;

// ── Props + collision (cross walls + per-prop footprints) ───────────────────────
scr_duomo_build();

// ── Exit door → Florence ─────────────────────────────────────────────────────
// Trigger zone centred on the visible FF-style door (DUOMO_EXIT_X/Y), so walking
// onto the door returns Benedetto to Florence by the Duomo exterior.
// Draggable + persistable (drag in debug, F8 saves). The door art (Draw_0) follows
// global.duomo_exit so the visible door and the trigger never separate.
global.duomo_exit = scr_transition_spawn("duomo_south",
    DUOMO_EXIT_X - 96, DUOMO_EXIT_Y - 32, 192, 64,
    "Room1", "Florence", 1118, 1462, "");

// ── Entry chronicle, keyed to how far the corruption has taken the church ────────
var _corr = global.circle_corruption[CIRCLE_LIMBO];
if (_corr >= 100) {
    scr_chronicle_add("The cathedral is cold and dark. The church has forgotten what it was.");
} else if (_corr >= 75) {
    scr_chronicle_add("Something is wrong with this place. Something has been wrong for a while.");
}
