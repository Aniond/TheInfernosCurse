// =============================================================================
// obj_florence_v2_scene — Create
// =============================================================================
// Room controller for Room_florence_v2 — the reference-exact Florence
// (references/florence.png, 48x32 cells). STEP 3 state: room-edge collision +
// entry banner. Walls, landmarks, transitions and street life arrive in the
// next build steps. Ground + the road network are PAINTED in Draw_0.
if (room != Room_florence_v2) exit;

scr_fv2_build();

scr_banner_show("Florence, 1300 AD");
