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
    [spr_florence_cart,           980, 1672],  // on the street, west side
    [spr_florence_barrels,       1808, 1544],  // goods beside Marco's bakery
    [spr_florence_barrels,       1130, 1545],  // logs to the RIGHT of the safe-house door
];
// (Empty market stall removed — Marco's bakery now occupies that spot at 1720.)

// ── Countryside ring ──────────────────────────────────────────────────────────
// Firenze is a walled city ringed by green country. Inside this rectangle the
// paved/cobbled city shows; everything OUTSIDE it is grassed over (drawn in Draw
// before the road, so road exits still cut through the grass) and dotted with
// trees & bushes. Box generously covers every building, prop, shrine and NPC.
core_rect = [560, 480, 2480, 2300];   // [x1, y1, x2, y2] — stays cobblestone

// Scenery: [sprite, x, y] — trees, cypress, bushes & flowering shrubs, bottom-
// centered like props. Hand-placed around the ring for a natural Tuscan scatter,
// kept clear of the E/W road exits. Cypress cluster as accents/rows (iconic
// lining the approaches); flowering shrubs add colour near the verge edges.
scenery = [
    // West verge
    [spr_florence_tree,          280,  420],
    [spr_florence_shrub_flower,  170,  720],
    [spr_florence_cypress,       380,  980],
    [spr_florence_tree,          210, 1300],
    [spr_florence_bush,          430, 1460],
    [spr_florence_cypress,       260, 1880],   // below the west road exit
    [spr_florence_shrub_flower,  400, 2160],
    [spr_florence_bush,          440, 2860],
    // North verge — cypress row flanking the church approach
    [spr_florence_cypress,       720,  300],
    [spr_florence_bush,         1060,  210],
    [spr_florence_cypress,      1380,  240],
    [spr_florence_cypress,      1620,  240],
    [spr_florence_shrub_flower, 1960,  220],
    [spr_florence_cypress,      2300,  340],
    // East verge
    [spr_florence_tree,         2760,  520],
    [spr_florence_bush,         2920,  860],
    [spr_florence_cypress,      2660, 1260],
    [spr_florence_shrub_flower, 2980, 1480],
    [spr_florence_tree,         2820, 1900],   // below the east road exit
    [spr_florence_cypress,      2640, 2320],
    [spr_florence_bush,         2940, 2680],
    // South bank (Oltrarno) — kept below the river band (river y 2368–2560)
    [spr_florence_cypress,       360, 2740],
    [spr_florence_tree,          820, 2740],
    [spr_florence_shrub_flower, 1240, 2820],
    [spr_florence_cypress,      1640, 2760],
    [spr_florence_bush,         2060, 2860],
    [spr_florence_tree,         2440, 2780],
    // Reeds at the waterline — north bank (base ~2380) and south bank (~2600),
    // clear of the two bridge gaps (1040–1240, 1980–2180).
    [spr_florence_reeds,         700, 2392],
    [spr_florence_reeds,        1520, 2392],
    [spr_florence_reeds,        2400, 2392],
    [spr_florence_reeds,         640, 2604],
    [spr_florence_reeds,        1640, 2604],
    [spr_florence_reeds,        2480, 2604],
];
