// ── Florence building — Create ───────────────────────────────────────────────
// A SOLID prop: child of obj_wall, so the player's `with (obj_wall)` collision
// check (and the F1 red outline) pick it up automatically. The collision
// footprint is the drawn sprite's bounds (set here, refreshed each Step in case
// the room builder rescales the instance after this Create runs).
depth  = 120;            // behind the player (depth 100), over the street scene (160)
wall_w = sprite_width;   // sprite_get_width(sprite_index) * image_xscale
wall_h = sprite_height;
