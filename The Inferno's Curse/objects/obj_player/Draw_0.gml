// ── Player: Draw ────────────────────────────────────────────────────────────
// Benedetto drawn at 1.25x so he reads at roughly the same height as Marco
// (~116px) and the market props, instead of looking tiny beside them.
// Collision is handled via AABB in Step_0 — visual scale here does NOT affect
// the physics box.
draw_sprite_ext(
    sprite_index,   // current directional sprite (set each step in Step_0)
    image_index,    // current animation frame
    x, y,           // world position
    1.25, 1.25,     // display scale (was 0.75 — too small next to NPCs/props)
    0,              // no rotation
    c_white,        // no colour tint
    1               // full alpha
);
