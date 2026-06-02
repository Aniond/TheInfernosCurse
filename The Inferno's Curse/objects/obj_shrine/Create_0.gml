// =============================================================================
// obj_shrine — Create Event
// =============================================================================
// A place of prayer in Ashenveil. While Limbo corruption is low the shrine
// answers: praying restores a little of Benedetto's sanity. Once corruption
// takes the circle (>= 50) the shrine goes dark and silent. After a successful
// prayer it must rest one in-game hour before it can be used again.
// =============================================================================

shrine_active  = true;   // false while on cooldown; the cross dims when inactive
interact_range = 48;     // px radius within which the player can pray
cooldown       = 0;      // steps remaining until the shrine answers again
cooldown_max   = 3600;   // one in-game hour at 60 fps

// Set in Step each frame; Draw reads it to show/hide the "[E] Pray" prompt.
player_near = false;
