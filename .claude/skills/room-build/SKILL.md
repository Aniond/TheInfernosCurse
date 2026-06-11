---
name: room-build
description: The room construction standard for The Inferno's Curse — build order (reference analysis → sprites → structure → transitions → corruption states → layout file), dimensions, floor types, collision masks, depth sorting, camera, interior void vs exterior art, and entry banners. Use whenever building or rebuilding any room.
---

# Room Build Standard

## Before Building Any Room
1. Read reference image if available
2. Perform geometric analysis
3. Calculate exact cell positions
4. Report dimensions and wait for approval
5. Generate sprites FIRST — confirm before placing
6. Build room structure
7. Place objects
8. Wire transitions
9. Add corruption states
10. Write layout file
11. Commit

## Room Dimensions
Always derive from reference image.
Use 64px grid cells.
Report aspect ratio vs reference.
Never guess dimensions.

## Floor Types
Interior rooms — dark warm stone or wood
Exterior city — cobblestone road tiles
Gardens — grass and path tiles
Black void — walls only, never floor

## Grass Rule
Grass lives OUTSIDE city walls only.
Inside city walls = packed earth or cobblestone.
Never grass inside Florence.

## Collision Mask Rules
> Canonical: CLAUDE.md §BOTTOM-ONLY COLLISION

Tall sprites use bottom-only collision:
- Trees: bottom 20% — trunk only
- Buildings over 128px: bottom 25%
- Bridges: pillar bases only
- Arches: base columns only
- Market awnings: NO collision
- Players walk under canopies naturally

## Depth Sorting
> Canonical: CLAUDE.md §GLOBAL DEPTH RULE

All objects: depth = -bbox_bottom
Never use fixed depth values.
Applied globally from obj_game_manager.

## Layout File
Every room has a layout file at:
C:\TheInfernoCurse\layouts\[room_name]_layout.txt
Every layout has a VERSION macro.
Bump version on every layout-changing commit.
All objects draggable in debug mode.
F8 saves layout.

## Camera
Standard viewport: 1366x768
Room-specific override only when justified.
Ponte Vecchio: cam_view_h = 448
Document any override in room notes.

## Interior Rooms — Black Void Method
Walls are black void + art.
No outside visible through walls.
Black void surrounds all walkable floor.
Objects against black void read as walls naturally.

## Exterior Rooms — Art Fills Space
Room1/Florence — art fills everything.
Black only beyond room boundaries.
NEVER apply black void to exterior rooms.
This would destroy Florence.

## Corruption States
Every room needs at minimum:
- 0-49%: Clean default state
- 50-74%: Subtle wrong details
- 75-99%: Clearly disturbing
- 100%: City swallowed, chronicle fires once

## Entry Banner
Every room shows location name on entry.
Gold text, fades after 3 seconds.
FF6 location banner style.
