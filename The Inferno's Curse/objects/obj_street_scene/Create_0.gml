// =============================================================================
// obj_street_scene — Create
// =============================================================================
// Static Florentine street dressing for Room1: a paved-stone road laid over the
// cobblestone floor, plus market props (well, cart, stall, barrels). Spawned by
// obj_game_manager at depth 160 — over the cobble background (200) but under
// characters and buildings (100). Persistent + a room guard in Draw so it only
// renders in Room1.
// =============================================================================

// Paved-road segments as rectangles [x1, y1, x2, y2], tiled with spr_florence_road:
//   1) main east-west street running past Marco and the building row
//   2) north avenue leading up to the church / shrine
//   3) short south spur leading to the south shrine
road_rects = [
    [ 160, 1556, 3040, 1684],
    [1456,  884, 1584, 1556],
    [1456, 1684, 1584, 2080],
];

// Market props: [sprite, x, y] — drawn bottom-centered (base sits at y).
// Positions are first-pass estimates relative to the building coordinates;
// easy to nudge here.
props = [
    [spr_florence_well,          1520, 1660],  // piazza centerpiece at the road junction
    [spr_florence_cart,           980, 1672],  // just west of Marco
    [spr_florence_market_stall,  1720, 1648],  // market row, east of Marco
    [spr_florence_barrels,       1808, 1544],  // goods by the eastern buildings
    [spr_florence_barrels,        856, 1544],  // goods by the western houses
];
