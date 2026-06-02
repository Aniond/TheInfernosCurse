// =============================================================================
// obj_safe_house — Create Event
// =============================================================================
// A refuge in Ashenveil. While the player stands inside, visions come half as
// often (global.vision_cooldown is doubled) and sanity slowly recovers. A place
// to breathe before going back out into the Curse.
//
// (x, y) is the top-left corner; the building footprint is 64 x 64 px.
// =============================================================================

player_inside = false;  // recomputed every step from player overlap
rest_timer    = 0;      // counts up while inside; restores sanity each interval
rest_interval = 300;    // steps between sanity ticks (~5 s at 60 fps)
