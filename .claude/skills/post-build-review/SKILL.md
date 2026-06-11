---
name: post-build-review
description: Automatic review after every room build and every PixelLab sprite batch for The Inferno's Curse — compare to reference, present three tiered improvement suggestions, flag off-scale or missing sprite variants. Use immediately after completing any room build or sprite generation batch.
---

# Post-Build Review

## Automatic After Every Room Build
After completing any room build automatically:

1. Compare current room to reference image
2. Generate three improvement suggestions
3. Present as tiers:
   Tier 1 — existing assets, quick wins
   Tier 2 — small new sprites needed
   Tier 3 — bigger structural changes

Present like this:
"Room is built. Here are three suggestions
based on the reference image:
[Tier 1] ...
[Tier 2] ...
[Tier 3] ...
Approve any to implement."

## Post-Generation Sprite Review
After any PixelLab sprite batch completes:
- Flag any sprite that looks off-scale
- Flag missing directional variants
- Flag corruption state variants not generated
- Flag any isometric/angled rejections needed

Present as:
"Sprites generated. Flagging:
[issues found or 'All clean']"
