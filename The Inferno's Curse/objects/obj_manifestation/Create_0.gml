// =============================================================================
// obj_manifestation — Create Event
// =============================================================================
// The things only Benedetto can see.
//
// Manifestations are not enemies — they never attack.
// They drift, observe, and approach. Their presence is the horror.
// Each instance is tied to a circle (manifest_type 0-6) which determines
// colour and behaviour weight.
//
// Spawned by scr_trigger_vision() for THING_WATCHING and FULL_MANIFEST.
// Destroyed when vision_timer in obj_vision_manager reaches 0.
// =============================================================================

// How intensely this entity has locked onto the player (0-100).
// Increases when it is within the player's facing arc; decreases otherwise.
awareness_level = 0;

// Circle index (0-6) this manifestation embodies.
// Set externally by the spawning code before or immediately after creation.
// Drives colour in the Draw event.
manifest_type = 0;

// Passive drift speed when not pursuing.
drift_speed = 0.3;

// Initial drift direction (random so entities spread naturally).
drift_dir = random(360);

// Whether this manifestation is currently visible.
// False during low-intensity visions to keep some ambiguity.
visible_to_player = true;

// True once awareness_level reaches 100 — entity begins slow approach.
is_aware = false;

// Stop distance from player (px). Manifestation never closes this gap.
_approach_stop_distance = 64;
