---
name: void-wall
description: The permanent VOID WALL + ART standard for The Inferno's Curse — every wall is a black void band (which IS the collision rect) with tile art inset at exact band size, plus lit top edge. Use whenever building or modifying any wall in any room.
---

# Void Wall + Art Standard

## The Rule
EVERY wall in the game uses VOID WALL + ART.
No exceptions. Established 2026-06-09.
"It looks better and it's professional." — David

## How It Works
Three layers only:

Layer 1 — BLACK VOID BAND
- Solid filled black rectangle
- This IS the collision geometry
- Single source for both visual and collision
- Never use separate invisible wall objects

Layer 2 — ART INSET
- Sprite or tile art sitting ON TOP of void
- Generated AT the band's exact dimensions
- NEVER stretch a mismatched tile
- Black outline frames the art naturally

Layer 3 — LIT TOP EDGE (where appropriate)
- Subtle lighter line at top of wall band
- Suggests light hitting the top of the wall
- Adds depth without complexity

## Band Dimensions
- City walls: 128px tall band
- Thin interior walls: 32-48px tall band
- Stall partitions: 32px tall band
- Generate fill tile AT band size exactly

## Procedural Fallback
If PixelLab tile fails or looks wrong:
Use deterministic procedural masonry:
- Dark warm stone base color
- Multi-frequency speckle overlay
- Alternating light/dark block pattern
- Never uniform — real walls have variation

## Collision Rule
The void band IS the collision rect.
Never add separate obj_wall instances.
Never place invisible collision objects.
The black void stops the player.
That's it.

## What This Prevents
- Ghost collision objects
- Floating sprites against grass
- Mismatched collision and visuals
- Players getting stuck on invisible walls
- Debugging hours hunting wrong collisions

## Applies To
- City walls and curtain walls
- Interior room walls
- Stall and shop partitions
- Courtyard and precinct walls
- Any future wall in any room
