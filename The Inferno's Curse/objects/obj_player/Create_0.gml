// ── Player: Create ──────────────────────────────────────────────────────────
// All core state lives here so other objects can read obj_player.corruption etc.

// --- Stats ---
hp        = 100;
max_hp    = 100;
// 0 = untouched by the Curse, 100 = fully consumed — gates events and endings
corruption = 0;

// --- Movement ---
move_spd      = 4;
base_move_spd = 4;   // Gluttony sin effect subtracts from this; never modify directly
facing_dir    = 270; // degrees (GameMaker: 0=right, 90=up, 180=left, 270=down)
                     // 270 = facing up — Benedetto enters each circle looking inward
                     // Read by obj_manifestation awareness check each step

// --- Combat ---
attack_speed    = 1.0;  // multiplied by global.attack_speed_modifier (Wrath effect)
attack_accuracy = 1.0;  // 0.0-1.0; reduced by global.attack_accuracy (Wrath effect)

// --- Sprites ---
// 8-way lookup arrays, indexed by (round(facing_dir / 45)) mod 8.
// Index: 0=E  1=NE  2=N  3=NW  4=W  5=SW  6=S  7=SE
walk_sprites = [
    spr_benedetto_walk_east,
    spr_benedetto_walk_north_east,
    spr_benedetto_walk_north,
    spr_benedetto_walk_north_west,
    spr_benedetto_walk_west,
    spr_benedetto_walk_south_west,
    spr_benedetto_walk_south,
    spr_benedetto_walk_south_east,
];
idle_sprites = [
    spr_benedetto_idle_east,
    spr_benedetto_idle_north_east,
    spr_benedetto_idle_north,
    spr_benedetto_idle_north_west,
    spr_benedetto_idle_west,
    spr_benedetto_idle_south_west,
    spr_benedetto_idle_south,
    spr_benedetto_idle_south_east,
];
run_sprites = [
    spr_benedetto_run_east,
    spr_benedetto_run_north_east,
    spr_benedetto_run_north,
    spr_benedetto_run_north_west,
    spr_benedetto_run_west,
    spr_benedetto_run_south_west,
    spr_benedetto_run_south,
    spr_benedetto_run_south_east,
];
sluggish_sprites = [
    spr_benedetto_walk_sluggish_east,
    spr_benedetto_walk_sluggish_north_east,
    spr_benedetto_walk_sluggish_north,
    spr_benedetto_walk_sluggish_north_west,
    spr_benedetto_walk_sluggish_west,
    spr_benedetto_walk_sluggish_south_west,
    spr_benedetto_walk_sluggish_south,
    spr_benedetto_walk_sluggish_south_east,
];
sprite_index = spr_benedetto_walk_south;
image_speed  = 1;  // sprites use their own baked playback speed

// Safety: if a saved position landed inside the river band, push to nearest bank.
if (room == Room1 && variable_global_exists("river_y1")) {
    var _ry1 = global.river_y1;
    var _ry2 = global.river_y2;
    if (y > _ry1 && y < _ry2) {
        y = (y - _ry1 < _ry2 - y) ? (_ry1 - 8) : (_ry2 + 8);
    }
}
