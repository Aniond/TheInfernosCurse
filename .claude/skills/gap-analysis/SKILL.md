---
name: gap-analysis
description: Morning comparison workflow for The Inferno's Curse — compare a room's current state to its reference image, produce a numbered gap list with coordinates, and present prioritized tiers for approval. Use every morning before new work, after major room changes, and before declaring a room complete.
---

# Gap Analysis — Morning Comparison Workflow

## Purpose
Every morning compare current room state
to reference image and generate
a prioritized improvement list.

## Process

### Step 1 — Read Reference
Read the reference image for the room.
Room_florence_v2 → florence.png
Room_ponte_vecchio → ponte_vecchio_interior_map.png
Room_duomo → duomo_interior_map.png
Room_locanda_rosa_camuna → inn_interior_map.png
Room_fiorentine_stable → stables_interior_map.png

### Step 2 — Geometric Analysis
Compare current room dimensions
to reference image proportions.
Flag any proportion mismatches.

### Step 3 — Content Comparison
Map every element in reference:
- Is it present in current room?
- Is it correctly positioned?
- Is it correct scale?
- Does it have corruption states?

### Step 4 — Gap List
Generate numbered gap list:
GAP 1 — [category] — [description]
  Current: [what exists]
  Reference: [what should exist]
  RECOMMEND: [specific fix with coordinates]

### Step 5 — Prioritized Tiers
Present gaps as tiers:

TIER 1 — Zero new assets, quick wins
TIER 2 — Small new sprites needed
TIER 3 — Structural changes needed

### Step 6 — Present for Approval
"Gap analysis complete.
[N] gaps found across [N] categories.
Tier 1 can be done immediately.
Approve all / approve tier 1 only / select specific gaps."

## Frequency
Run every morning before any new work.
Run after any major room change.
Run before declaring any room complete.
