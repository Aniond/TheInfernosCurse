---
name: corruption-states
description: The corruption state standard for The Inferno's Curse — the four thresholds (0-49/50-74/75-99/100) and how lighting, water, shrines, animals, moon, NPCs, Chronicle entries, and sin bleed respond at each. Use whenever adding corruption reactions to any room, object, or NPC. Describes target architecture, not just current code.
---

# Corruption State Standard

> Canonical: this file

## The Four Thresholds
Every interactive object and NPC
must respond to global.circle_corruption[0].

0-49%   — Clean. Florence as it should be.
50-74%  — Something is wrong. Subtle.
75-99%  — Clearly disturbing. Wrong details.
100%    — City swallowed. The Forgotten state.

## Environmental Rules

### Lighting
Torches: 100% lit at 0-49%
         15% chance dark at 50-74%
         50% dark at 75-99%
         ~90% dark at 100% — survivors burn GREEN

### Water
Arno: normal blue at 0-49%
      darkening at 50-74%
      reverses flow direction at 75%+
      blood red at 100%

### Street Shrines
Candles lit at 0-49%
Candles flicker at 50-74%
Madonna facing wrong way at 75%+
Madonna GONE at 100% — empty alcove
Chronicle fires once:
"The Madonna is gone.
 I do not know when she left.
 I do not know if anyone else noticed."

### Animals
Cats and pigeons present at 0-49%
Fewer at 50-74%
Gone entirely at 75%+

### Moon (night only)
White at 0-74%
Red tinted at 75%+
Blood red at 100%
Stars: 40 at 0-49%, 14 at 75%+, 0 at 100%

## NPC Rules
See the npc-create skill for emotion overrides.
All NPCs fear Benedetto at 75%+.
All NPCs terrified and jittering at 100%.

## Chronicle Entries
At 100% corruption key moments
fire Chronicle entries ONCE only.
Use a flag to prevent repeat firing.
Always in first person.
Always understated. Never melodramatic.
The horror is in what is NOT said.

## Sin Bleed
Unresolved circles bleed into Florence daily.
Rate: 0.1 per day per unsolved circle.
Threshold: 50% before bleeding begins.
Handled by scr_corruption_spread()
called from obj_time_manager day rollover.
