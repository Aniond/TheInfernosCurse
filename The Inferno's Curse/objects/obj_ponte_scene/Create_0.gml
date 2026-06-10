// =============================================================================
// obj_ponte_scene — Create (REBUILT 2026-06-10)
// =============================================================================
// The marketplace bridge — "Cuore del Commercio Fiorentino". 1280x896, 20x14.
// Reference: references/ponte_vecchio_interior_map.png.
//   water N y0-192 · shops N y192-288 · WALKWAY y288-576 · shops S y576-672 ·
//   water S y672-896 (arch foundations). Props (12 shops, fountain, guild
//   board, lanterns, gulls, Marco) come from scr_ponte_build — David's F8
//   layout is source of truth, defaults in scr_ponte_default.
// =============================================================================
if (room_get_name(room) != "Room_ponte_vecchio") exit;

// marketplace framing (approved): taller view so BOTH shop rows + the full
// walkway sit in frame. Room_florence_v2's build restores 384 on return.
global.cam_view_h = 448;

scr_ponte_build();
scr_banner_show("Ponte Vecchio");
