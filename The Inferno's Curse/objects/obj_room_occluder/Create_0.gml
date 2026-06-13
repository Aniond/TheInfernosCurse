// =============================================================================
// obj_room_occluder — Create
// =============================================================================
// Used to create a classic 2D RPG "Fog of War" over interior private rooms.
// Place and scale this object to perfectly cover a room. When the player enters
// its bounding box, the black rectangle fades out. When they leave, it fades in.
// =============================================================================
alpha = 1.0;
target_alpha = 1.0;
unveiled = false;
linked_door_id = noone; // Optional: instance ID of a door. If door is open, unveil.

// Sort very high to draw over all standard objects and tiles in the room.
depth = -9000;
