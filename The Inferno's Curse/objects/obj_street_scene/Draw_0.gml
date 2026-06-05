// =============================================================================
// obj_street_scene — Draw
// =============================================================================
// Town dressing temporarily disabled for a clean rebuild. The floor is now a
// plain grass fill from Room1's tiled Background layer (spr_florence_grass,
// htiled/vtiled = wall to wall, no black void). Roads, river, props, scenery
// and buildings get added back one layer at a time from here.
//
// Room guard kept so this persistent object never draws into the battle room.
// =============================================================================
if (room != Room1) exit;
