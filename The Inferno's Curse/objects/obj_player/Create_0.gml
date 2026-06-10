// ── Player: Create ──────────────────────────────────────────────────────────
// All core state lives here so other objects can read obj_player.corruption etc.

// --- Bootstrap the persistent game manager ---
// Its only placed instance lived in the old Room_florence (wiped 2026-06-10),
// so the boot room no longer carries one. Creating it here runs its Create
// immediately — all globals (input_locked etc.) exist before any Step fires.
if (!instance_exists(obj_game_manager)) {
    instance_create_depth(0, 0, 0, obj_game_manager);
}

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

// (Old-map river spawn-safety removed 2026-06-10 with Room_florence — the v2
//  river is sealed by obj_wall collision, no spawn rescue needed.)

// ── One-shot arrival override ─────────────────────────────────────────────────
// A room transition (obj_mercato_exit with arrive_x/arrive_y set) drops the player
// at a specific spot in the destination room — e.g. returning from the Ponte
// Vecchio onto the correct Arno bank at the west crossing. Cleared after use so it
// never re-applies on the next room load.
if (variable_global_exists("player_spawn_override") && is_array(global.player_spawn_override)) {
    x = global.player_spawn_override[0];
    y = global.player_spawn_override[1];
    global.player_spawn_override = undefined;
}
