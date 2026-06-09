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
C:\TheInfernoCurse\
├── The Inferno's Curse/   # The GameMaker project (LTS 2026) — objects, scripts,
│                          # rooms, sprites, .yyp. Open this in the GM IDE.
├── docs/                  # Tracked design docs (room construction, water
│   │                      # perception, yy_templates.md — verified .yy formats)
│   └── local/             # Gitignored local-only docs (story bible, core
│                          # systems, dev setup, AI integration)
├── layouts/               # Human-readable room layout sources (mirrored into
│                          # the code seeds; runtime copies live in the save dir)
├── assets/                # Source PNGs by category (imported into GM sprites
│                          # via import_sprites.ps1 — never re-download/overwrite)
├── references/            # Gitignored visual references (room maps, PDFs)
├── sprite_import/         # Gitignored staging for PNGs awaiting GM import
├── instructions/          # Gitignored local refs (PixelLab API, watch_game.ps1)
├── scripts/               # Capture/burst-test helper scripts (user-run)
├── _archive/              # Gitignored quarantine: retired staging, strays
├── clean_build.ps1        # Clear GM cache for a guaranteed clean compile
├── import_sprites.ps1     # PNG -> GameMaker sprite resources (+ .yyp entries)
├── watch_burst.ps1        # Burst screenshot capture (user runs manually)
├── CLAUDE.md              # Claude Code project rules
└── config.ini             # Gitignored: Claude API key (Included File source)
```
Note: `ComfyUI/` (127MB, gitignored) lives at the root but is an external tool —
candidate to relocate outside the repo.

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
