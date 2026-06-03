// =============================================================================
// obj_unit_shambler — Create
// Legendary enemy. A body reclaimed wholesale by Limbo — not forgotten but
// remade. Massive, slow, and capable of crossing folds without harm.
// Encounter rate: 1-3% (Legendary tier). Replacing a Hollow slot when it rolls.
// =============================================================================

event_inherited();

unit_name  = "The Shambler";
max_hp     = 150;
hp         = max_hp;
max_ap     = 3;
team       = 1;        // enemy side
is_hollow  = false;    // Shamblers don't roll Forgotten — they ARE the fold
unit_color = make_color_rgb(220, 160, 60);   // deep amber — distinct from Hollow's violet

// Facing direction — updated when the unit moves. Controls sprite selection.
unit_facing = "south";

// Assign south-facing sprite directly so the asset is never stripped as unused.
sprite_index = spr_enemy_shambler_south;

// Starting positions are overridden by spawn code in Alarm_0 or the encounter table.
grid_x = 8;
grid_y = 3;
