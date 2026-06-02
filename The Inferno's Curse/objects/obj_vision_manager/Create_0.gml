// =============================================================================
// obj_vision_manager — Create Event
// =============================================================================
// Manages the visual layer of Benedetto's hallucinations.
// One persistent instance lives for the entire game session.
// It reads current_vision_type (set by scr_trigger_vision) and renders
// the appropriate full-screen overlay in Draw GUI.
// =============================================================================

// DS list of currently active vision effect tags.
// Each entry is a string matching a VISION TYPE constant.
active_visions = ds_list_create();

// Alpha of the full-screen overlay (0 = invisible, 1 = fully opaque).
// Fades in when a vision starts; fades out as vision_timer counts down.
vision_overlay_alpha = 0;

// Which vision type is currently showing.
// Written by scr_trigger_vision(); read by Draw GUI for colour/effect choice.
current_vision_type = "";

// Steps remaining for the current vision.
// Set by scr_trigger_vision(); counts down each step in the Step event.
vision_timer = 0;

// Positions of manifestation entities (for THING_WATCHING and FULL_MANIFEST).
// Populated by obj_manifestation instances as they spawn.
entity_positions = ds_list_create();

// Snapshot of game-over stats — populated by scr_game_over() before
// handing rendering responsibility to this object.
game_over_stats = undefined;

// Target overlay alpha — vision fades toward this value each step.
// Set to a peak when vision starts; falls to 0 on expiry.
_target_alpha = 0;
