// ── Player: Draw ────────────────────────────────────────────────────────────
// FF6-style proportions: Benedetto drawn at 50% of sprite size so buildings
// feel large and imposing. Collision is handled via AABB in Step_0 — visual
// scale here does not affect the physics box.
draw_sprite_ext(
    sprite_index,   // current directional sprite (set each step in Step_0)
    image_index,    // current animation frame
    x, y,           // world position
    0.75, 0.75,     // 75% display scale
    0,              // no rotation
    c_white,        // no colour tint
    1               // full alpha
);
