# The Inferno's Curse

> *A world corrupted by the seven circles of Hell. One soul must descend through each layer to break the curse before reality itself collapses.*

---

## Project Overview

**Engine:** GameMaker  
**Genre:** Action RPG (FF7-inspired)  
**Art Style:** 16-bit pixel art, dark fantasy  
**AI Integration:** Claude API (NPC dialogue, world events, adaptive enemies)

---

## The Concept

The world has been fractured by a ancient curse tied to Dante's seven circles of Hell. Each circle's corruption has bled into the living world, warping entire regions into reflections of that sin. The player must descend through each corrupted layer, confront its ruler, and sever the curse — before the circles fully merge and destroy existence.

---

## The Seven Circles (World Structure)

| Circle | Sin | World Region | Corruption Effect |
|--------|-----|-------------|-------------------|
| 1 | Limbo | The Ashen Wastes | Souls lost, forgotten, NPCs have no memory |
| 2 | Lust | The Crimson Veil | Reality warps seductively, illusions everywhere |
| 3 | Gluttony | The Rotting Fields | World consumed and decaying, resources scarce |
| 4 | Greed | The Iron City | Everything has a cost, pay-to-survive mechanics |
| 5 | Wrath | The Ember Wastes | Perpetual war, factions in endless conflict |
| 6 | Heresy | The False Heaven | Cult-controlled cities, false gods rule |
| 7 | Violence | The Shattered Realm | Pure chaos, broken landscape, reality fractures |

---

## Core Systems

- **Corruption Meter** — tracks how deeply each circle affects the world
- **Sin Affinity** — player choices align with different sins, affecting abilities
- **Living World AI** — NPCs powered by Claude API, react dynamically to player actions
- **Adaptive Combat** — enemies learn player patterns via AI
- **Corruption Spread** — circles bleed into each other based on player progression

---

## Tech Stack

- **GameMaker** — core engine (GML)
- **Claude API** — NPC dialogue, world events, adaptive storytelling
- **Leonardo.ai** — sprite and asset generation
- **VS Code + Claude Code** — development environment

---

## Project Structure

```
The Infernos Curse/
├── docs/               # Design documents, notes, references
├── assets/
│   ├── sprites/        # Character and enemy sprites
│   ├── tilesets/       # World tilesets per circle
│   ├── audio/          # Music and SFX
│   ├── ui/             # HUD, menus, interface elements
│   └── concepts/       # Concept art, mood boards
├── src/
│   ├── scripts/        # GML scripts
│   ├── objects/        # GameMaker objects
│   ├── rooms/          # Game rooms/maps
│   └── shaders/        # Visual shaders for corruption effects
├── ai/
│   ├── prompts/        # System prompts for Claude API integration
│   └── integration/    # API call scripts and handlers
└── design/
    ├── story/          # Story bible, dialogue, lore
    ├── systems/        # Game system design docs
    └── levels/         # Level/circle design docs
```

---

## Development Phases

### Phase 1 — Foundation
- [ ] GameMaker project setup
- [ ] Core movement and combat prototype
- [ ] Circle 1 (Limbo) — first playable area
- [ ] Basic AI integration (NPC dialogue)

### Phase 2 — Systems
- [ ] Corruption meter implementation
- [ ] Sin Affinity system
- [ ] Adaptive enemy AI
- [ ] Full Circle 1 complete

### Phase 3 — Expansion
- [ ] Circles 2-4 built out
- [ ] Dynamic world state system
- [ ] Full Claude API living world integration

### Phase 4 — Completion
- [ ] Circles 5-7
- [ ] Final boss and ending
- [ ] Polish and optimization
- [ ] Release build

---

## Status: Pre-Production
