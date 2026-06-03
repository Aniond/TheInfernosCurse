// =============================================================================
// obj_unit_benedetto — Create
// The player-controlled unit. Child of obj_unit_base.
// Circle 1 testing: solo unit, team=0.
// =============================================================================

event_inherited();

unit_name  = "Benedetto";
max_hp     = 100;
hp         = max_hp;
max_ap     = 3;
team       = 0;
unit_color = make_color_rgb(180, 160, 100);

// Facing direction — updated on movement, controls battle sprite selection.
unit_facing = "south";

// Starting position: left side of the grid, row 3
grid_x = 1;
grid_y = 3;
