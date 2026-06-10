// =============================================================================
// scr_camera — global FF6 follow-and-clamp camera (project default)
// =============================================================================
// The standard camera for EVERY room going forward (set up with Room_duomo): a
// zoomed view that follows Benedetto and clamps to the room edges, so you never
// see the whole room and never see black past the edges. Distance sells scale.
//
// Driven each step by obj_game_manager — no per-room view setup needed. Tune with:
//   global.cam_enabled  — master on/off (default true)
//   global.cam_view_h   — view HEIGHT in px = the zoom (default 384 → 2x on a
//                         768 port). Width is derived from the port aspect so the
//                         image never distorts; both are clamped to the room size
//                         so small rooms (e.g. the bridge) never show black bars.
//   global.cam_skip_room — optional room asset to leave alone (e.g. a battle screen)
// =============================================================================

#macro CAM_PORT_W 1366
#macro CAM_PORT_H 768

/// Initialise the camera globals once (called from obj_game_manager Create).
function scr_camera_init() {
    if (!variable_global_exists("cam_enabled"))   global.cam_enabled   = true;
    if (!variable_global_exists("cam_view_h"))    global.cam_view_h    = 384;
    if (!variable_global_exists("cam_skip_room")) global.cam_skip_room = room_battle;
    // smooth ZONE ZOOM (e.g. the Ponte crossing): a zone sets cam_zoom_target
    // (<1 = zoom IN); the camera lerps toward it every step and back to 1 when
    // the zone releases it.
    if (!variable_global_exists("cam_zoom"))        global.cam_zoom        = 1;
    if (!variable_global_exists("cam_zoom_target")) global.cam_zoom_target = 1;
}

/// Apply + update the camera for the current room. Call every step.
function scr_camera_update() {
    if (!variable_global_exists("cam_enabled") || !global.cam_enabled) return;
    if (room == global.cam_skip_room) return;          // leave static-framed rooms alone
    if (!instance_exists(obj_player)) return;

    // Aspect-correct view size, clamped to the room (no distortion, no black bars).
    // cam_zoom eases toward cam_zoom_target (zone zoom; <1 = closer).
    if (!variable_global_exists("cam_zoom")) { global.cam_zoom = 1; global.cam_zoom_target = 1; }
    global.cam_zoom = lerp(global.cam_zoom, global.cam_zoom_target, 0.08);
    var _aspect = CAM_PORT_W / CAM_PORT_H;
    var _vh = min(global.cam_view_h * global.cam_zoom, room_height);
    var _vw = _vh * _aspect;
    if (_vw > room_width) { _vw = room_width; _vh = _vw / _aspect; }

    if (!view_enabled) view_enabled = true;
    view_set_visible(0, true);
    view_wport[0] = CAM_PORT_W;
    view_hport[0] = CAM_PORT_H;

    var _cam = view_camera[0];
    if (_cam < 0) { _cam = camera_create(); view_set_camera(0, _cam); }
    camera_set_view_size(_cam, _vw, _vh);

    // Clamp-follow Benedetto (centre on him, never scroll past a room edge).
    var _tx = clamp(obj_player.x - _vw * 0.5, 0, max(0, room_width  - _vw));
    var _ty = clamp(obj_player.y - _vh * 0.5, 0, max(0, room_height - _vh));
    camera_set_view_pos(_cam, _tx, _ty);
}
