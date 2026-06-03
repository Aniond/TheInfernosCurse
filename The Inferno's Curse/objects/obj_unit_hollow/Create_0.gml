// =============================================================================
// obj_unit_hollow — Create
// Enemy unit. A person so consumed by Limbo's corruption they have forgotten
// themselves entirely. Still moves. Still acts. Doesn't know why.
//
// is_hollow = true enables the forget-chance roll at round start
// (see scr_battle_hollow_forget_roll in scr_battle.gml).
// Multiple Hollows can be placed in the room — each gets its own grid position
// set by the room instance's creation code or manually before Alarm fires.
// =============================================================================

event_inherited();

unit_name  = "The Hollow";
max_hp     = 60;
hp         = max_hp;
max_ap     = 2;
team       = 1;        // enemy side
is_hollow  = true;     // enables Forgotten roll each round
unit_color = make_color_rgb(200, 180, 220);  // pale ghost-violet — visible on near-black grid

// Facing direction — updated when the unit moves. Controls sprite selection.
unit_facing = "south";

// Assign the sprite directly. This guarantees the asset is referenced in
// compiled code (so it is never stripped as "unused") and gives a fallback
// even if the custom Draw event fails to register. One sprite for now.
sprite_index = spr_enemy_hollow_south;

// Starting positions are set per-instance in room_battle.
// Defaults here in case a Hollow is spawned programmatically.
grid_x = 8;
grid_y = 3;
