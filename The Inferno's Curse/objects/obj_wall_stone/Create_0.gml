// =============================================================================
// obj_wall_stone — Create Event
// =============================================================================
// The stone of Ashenveil. These blocks build the city's walls, church, market
// stalls and houses. Each instance is sized per-instance via room creation code
// (wall_w / wall_h), exactly like obj_wall — so one instance = one building wall.
//
// As Limbo corruption (circle 0) rises, the stone darkens, begins to "breathe"
// with a slow sine pulse, and finally cracks with dark veins. Beautiful before
// the Curse. Haunting after.
// =============================================================================

// ── Dimensions ────────────────────────────────────────────────────────────────
// Size is derived from the instance's scaleX/scaleY (set per-instance in the
// room) times a 32px base. GameMaker ALWAYS applies scaleX/scaleY from the room,
// whereas hand-authored room creation code is not reliably compiled — so this is
// the robust way to give each building its own size with one shared object.
// e.g. a 200×400 church body uses scaleX 6.25, scaleY 12.5.
wall_w = 32 * image_xscale;
wall_h = 32 * image_yscale;

// ── Sprite auto-detection ─────────────────────────────────────────────────────
// Pick a building sprite by footprint shape:
//   square   → townhouse        (fixed 3x scale; footprint is collision only)
//   tall     → cathedral        (stretched to fill the footprint)
//   thin     → bell tower / wall (stretched)
//   wide     → townhouse row     (stretched)
if (abs(wall_w - wall_h) < 16) {
    wall_sprite = spr_florence_house_south;
    wall_fill   = false;
} else if (wall_w < 80 || wall_h < 80) {
    wall_sprite = spr_florence_tower;
    wall_fill   = true;
} else if (wall_h > wall_w) {
    wall_sprite = spr_florence_cathedral;
    wall_fill   = true;
} else {
    wall_sprite = spr_florence_building_row;
    wall_fill   = true;
}

// ── Corruption / breathing state ──────────────────────────────────────────────
wall_corruption = 0;             // mirrors global.circle_corruption[0] each step
breathe_offset  = random(360);   // random phase so walls don't pulse in unison
breathe_speed   = 0.02;          // radians added per step — a slow, sickly rhythm
