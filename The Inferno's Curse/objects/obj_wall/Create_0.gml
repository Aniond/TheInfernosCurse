// ── Wall: Create ─────────────────────────────────────────────────────────────
// Size is derived from the instance's scaleX/scaleY (set per-instance in the
// room) times a 32px base. GameMaker always applies room scale, unlike
// hand-authored room creation code, so this sizing is reliable across saves.
wall_w = 32 * image_xscale;
wall_h = 32 * image_yscale;
