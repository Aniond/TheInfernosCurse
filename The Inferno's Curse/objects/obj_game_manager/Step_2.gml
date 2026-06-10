// =============================================================================
// obj_game_manager — End Step: GLOBAL DEPTH RULE (David, 2026-06-10)
// =============================================================================
// Every world object layers by its feet (depth = -bbox_bottom), re-sorted
// after all movement so the player draws in front of things north of him and
// behind things south of him — in every room. Exemptions (scene drawers,
// managers, UI, battle room) live in scr_depth_ysort (scr_room_builder.gml).
scr_depth_ysort();
