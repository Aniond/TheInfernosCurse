---
name: pixellab-sprite
description: PixelLab sprite generation rules for The Inferno's Curse — mandatory top-down view enforcement, rejection criteria, canvas sizes, in-engine scales, and seamless tile rules. Use whenever generating, regenerating, or importing any sprite via PixelLab MCP.
---

# PixelLab Sprite Generation Rules

## Mandatory View Enforcement
Every sprite prompt MUST include:
"strict top down view,
viewed directly from above,
zero perspective angle,
no isometric, no 3/4 view,
flat 90 degree overhead only,
no angles, no side view, no front elevation,
rooftops clearly visible from overhead,
facing [north/south/east/west as appropriate]"

## Rejection Criteria
> Canonical: CLAUDE.md §PixelLab Isometric Rejection Rule

Reject immediately if sprite returns:
- Any angled or isometric view
- Side elevation or front elevation
- Perspective distortion
- Diagonal rooftops
- Walls visible from the side

On rejection: tighten prompt with
"BIRD'S EYE VIEW ONLY, camera directly
overhead looking straight down" and regenerate.

## Canvas Rules
> Canonical: CLAUDE.md §Character Sprite Standard (for character/NPC canvases)

- Characters: 64px canvas, figure 60% max
- Props: 64px canvas, object 60% max
- Buildings small: 128x128px
- Buildings large: 256x256px
- Landmarks: 256x256px
- Lanterns/small details: 32px
- Always transparent background
- Always black outline

## Scale Rules (in engine)
- Characters: 0.45 scale
- Market stalls: 0.7 scale
- Crates/barrels: 0.5 scale
- Carts: 0.6 scale
- Urns/pots: 0.4 scale
- Fountains: 0.8 scale
- Trees/bushes: 0.7 scale
- Buildings: 1.0 scale always
- Landmarks: 1.0 scale always

## Always Use
- mode="v3" for animate_character
- Check asset exists before generating
- Never regenerate existing assets
- Save path: assets\sprites\environment\florence\[location]\
- NPC path: assets\sprites\npcs\florence\[location]\

## Seamless Tiles
For floor and ground tiles add:
"seamless tileable, no visible seams,
wraps perfectly at all edges"
Apply 6px edge cross-fade mechanically
after import to guarantee seamlessness.
