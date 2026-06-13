# THE INFERNO'S CURSE — PROJECT HANDOFF & MEMORY
### Written 2026-06-11 by Claude (Fable 5), for whoever continues this work with David.
### This file is the root-path master memory. Read it fully before touching anything.

---

## WHAT THIS GAME IS
A GameMaker LTS 2026 (GML) top-down RPG set in a cursed Renaissance Florence.
Benedetto, the player character, is being tainted by corruption seeping up from
the Nine Circles. Visual target: **Final Fantasy III/VI SNES** — tiny characters,
imposing buildings, packed town feel.

- Project: `C:\TheInfernoCurse\The Inferno's Curse\` (the .yyp lives there)
- GitHub: github.com/Aniond/TheInfernosCurse — active branch `mercato-vecchio`, main is `master`
- Python: `py` launcher (3.14) · Sprite art: PixelLab (MCP) — David has a subscription
- Task board: Local `PROJECT_TASKS.md` (Source of Truth)
- David's in-game F8 layout saves: `C:\Users\david\AppData\Local\The_Inferno_s_Curse\`

## STATE AS OF 2026-06-11 (commit f02aaaa)
- **Florence v2** (Room_florence_v2) is THE city map and the BOOT room. Old map wiped
  (recoverable at tag `pre-wipe-old-florence`). Ground system APPROVED by David in-game.
- **Ponte Vecchio interior** rebuilt east-west, 16 packed shops, Marco LIVE with real
  Claude-API dialogue at the Fornaio. Awaiting David's final pass.
- **Interiors complete & signed off:** Locanda della Rosa Camuna ground floor, Fiorentine Stable.
- **Duomo interior:** FULL REBUILD complete, featuring perfect code-driven fog of war blocks for side chapels and void wall entry tunnel.
- **Lighting (new, UNVERIFIED in-engine):** see GLOBAL LIGHTING below. First thing to test.
- **Character sheet** (C key), **runtime fonts** (Pixelify Sans + Alagard), also untested in-engine.

## THE PROJECT QUEUE (David's order, 2026-06-10)
1. FINISH the bridge (David's in-game pass; decide if other shops get keeper NPCs)
2. DUOMO REBUILD from `references\duomo_interior_map.png`
3. Merchant Guild Assembly Hall — `references\merchant_guild_hall_map.png`
Plus David's pick for fun: **wire live Claude-API dialogue to the BARMAID in the Locanda**
(follow Marco's proven chain — see AI DIALOGUE below; she needs an npc_data.json entry + persona).
Someday: Giardino delle Rose v2 rebuild (`references\giardino_delle_rose_map.png`).

---

# PERMANENT RULES (all hard-won — do not relearn these the painful way)
`CLAUDE.md` in this folder is the full rulebook and stays authoritative; key points:

## Corruption IS Sanity (single axis)
No separate sanity stat. `global.circle_corruption[CIRCLE_LIMBO]` (0-100) is the one axis.
Benedetto only THINKS he's going insane. Derived lucidity = `scr_perceived_sanity()` =
100 - Limbo. Mutate ONLY via `scr_corruption_taint(amount)` / `scr_corruption_relieve(amount, deep)`
(floor 15 normal / 10 deep). Never reintroduce `global.sanity`.
Thresholds 25/50/75 fire events; 100 = API takeover (currently resets to 90, real takeover TBD).

## GLOBAL LIGHTING (two cooperating systems — division of labour matters)
1. **scr_lightmap** — TRUE multiply light map, runs from obj_game_manager Draw GUI in
   every room. OWNS room darkness + coloured glow pools (torch/lantern/candle/shrine
   found by sprite-name substring). Corruption snuffs lights: 15% at 50+, 50% at 75+,
   ~90% at 100 with GREEN remnant flames; the shrine goes dark at 100 ("she is gone").
2. **scr_relief + shd_floor_relief** — normal-mapped floor relief, GLOBAL. The relief
   pass NEVER darkens (near-white ambient) — that's the fix after the first bridge-only
   shader POC "fought" the light map and was dropped (commit 4845d20). Normal maps are
   AUTO-DERIVED AT RUNTIME from the floor's albedo sprite and cached (PixelLab CANNOT
   make normal maps — it returns isometric junk). One-arg API around any tile loop:
   `var _r = scr_relief_begin(spr_floor); ...tiles...; if (_r) scr_relief_end();`
   Wired in: ponte deck, Florence v2 cobble + plazas, mercato, inn planks + rug, stable.
   Keep plain rectangles OUTSIDE begin/end. Procedural floors (flagstone) = light map only.
   **UNVERIFIED in-engine — verify order: 1) project loads clean (if a "project is later
   than this release" dialog appears, click NO — Yes runs a destructive downgrade),
   2) night via Ctrl+T in v2/mercato/inn/stable/bridge, 3) F3 corruption stages.**

## GLOBAL DEPTH (Y-sort)
Everything world-placed: `depth = -bbox_bottom`, asserted by `scr_depth_ysort()` every
frame from the manager. NEVER set manual depth. Exempt: *_scene drawers, managers, UI,
obj_manifestation, invisible walls, room_battle.

## BOTTOM-ONLY COLLISION
Tall sprites collide only at their base so the world reads 3D: trees bottom 20%
trunk-width; tall buildings bottom 25%; arches = two base columns (opening walkable);
stalls/awnings NO collision; fountains/wells full basin. One place:
`scr_room_builder_footprint` (+ arch case in `scr_room_builder_build_collision`).

## VOID WALL + ART
EVERY wall = solid black void band (the band IS the collision rect) with tile art
inset at EXACT band size (never stretch a mismatched tile), lit top edge where it fits.
Procedural block masonry is the approved fallback. obj_wall is internal to this system.

## Interior vs Exterior rooms
INTERIOR rooms: FF6-style black void — floor tiles only on walkable cells, void = walls.
EXTERIOR rooms (Florence v2): KEEP ALL ART — never black-void them; the FF6 camera
(scr_camera) already clamps the view so room edges never show.

## Room_florence prop scales (never 1.0 for props)
Stalls 0.7 · crates/barrels 0.5 · carts 0.6 · urns 0.4 · fountains 0.8 · well/trees 0.7.
Buildings: legacy mercato set 1.0; new PixelLab landmarks 0.7, standard buildings 0.65.
New street props: 64x64 canvas, prop fills 60% max, placed 0.7/0.5.

## Character sprites
64px canvas, figure ≤ ~60% with transparent padding all sides. Multi-frame animations:
scale every frame UNIFORMLY (never trim/re-centre per frame).

## PixelLab rules
- Always mode="v3" for animate_character.
- Top-down enforcement: if output is isometric/3-4/side view, REJECT and regenerate
  appending: "STRICT top down view, viewed directly from above, zero perspective angle,
  no angles, no isometric, no 3/4 view, no side view, no front elevation, flat 90 degree
  overhead only". David's tip: "no angles" is what stops the sideways art.
- PixelLab cannot do: full-bleed seamless ground tiles (procedural synthesis is the
  proven path — see tools/*.py), normal maps (derive from albedo).
- NEVER re-run sprite download/import scripts — they'd overwrite David's hand edits.

## F8 layout saves — David's save is SOURCE OF TRUTH
The loader ALWAYS loads an existing F8 save even with a stale version stamp (notice only).
Shift+F8 in debug = reset room to code defaults. BEFORE any layout edit: read David's
save-folder layout for the room, use it as the BASE, write back re-stamped, AND sync into
the code default + layouts/ repo mirror. Bump the room's *_LAYOUT_VERSION macro on EVERY
layout-changing commit. (FLORENCE_V2_LAYOUT_VERSION=9, PONTE_LAYOUT_VERSION=4 currently.)

## .yy / .yyp files — the minefield
- ALWAYS ask David before modifying .yy/.yyp; close GameMaker first; match the exact
  verified formats in `docs/yy_templates.md`. Field ORDER per record type is FIXED.
- NEVER hand-author tileset .yy (always fails — GM-managed fields). IDE only.
- Shader .yy verified format: `"$GMShader":"v1"`, type 1, NO trailing newline.
- "Project is later than this GameMaker release" dialog after hand-edits = false alarm →
  click NO (Yes = destructive ProjectTool downgrade).
- External libraries: LTS 2026 is its own branch — Monthly-built libs are INcompatible
  both directions. Test on a throwaway branch; David confirms clean load before merge.
  (History: Scribble, Bulb, Input all removed; only SnowState survived, patched.)

## Build & test workflow
- Run `clean_build.ps1` automatically after ANY change touching code/.yy/sprites
  (GM caches "unused asset" stripping; script self-aborts if GM is open).
- David runs burst tests / watch_game.ps1 HIMSELF — never automate them.
- Runtime file I/O: sandbox is ON — working_directory or Included Files only.
- Report AFTER doing. No confirmation prompts. Reports in a fenced code block.

## UI
Never hardcode UI colors — `scr_ui_theme_get(COLOR_KEY)`; four corruption-reactive
palettes, 60-frame lerp (manager Step runs scr_ui_theme_apply each frame).
Battle: ESC flee always allowed (+8% Limbo corruption); AP exhaustion never auto-ends
the player's turn (Z/ENTER required); enemy turns 250ms apart.

## AI DIALOGUE (live Claude API NPCs — Marco is the proven chain)
Four gotchas, all learned the hard way:
1. The async HTTP event file must be `Other_62.gml`, NOT `Async_62.gml`.
2. `json_stringify` emits floats — build the request body MANUALLY for int max_tokens.
3. Empty user content is rejected by the API.
4. `config.ini` (the API key) must be an Included File.
Manager bootstraps from obj_player Create if missing (persistent singletons placed only
in a wiped room die with it — that crash already happened once, commit 449ca01).
NOTE: this chain currently calls the Anthropic API. Switching the NPC brain to Gemini
means swapping the endpoint/body in the request-building script — the gotchas about
async events, manual JSON, and Included Files still apply identically.

## PowerShell quirks (Windows 11, PS 5.1)
- `git commit -m` with here-strings containing quotes breaks — use `git commit -F msgfile`.
- File deletion under the project root is blocked in some tools — bash `rm` works.
- GM's .yy "JSON" has trailing commas — standard JSON parsers need a `,\s*[}\]]` strip.

## GameMaker 2026 Engine Quirks (Discovered 2026-06-11)
- **Downgrade Warning Bug**: GM 2026.0 throws a "Project is later than this release" false-positive if the `.yyp` IDEVersion exactly matches its own `2026.0.0.16`. Setting it to `2026.0.0.0` bypasses this check.
- **Shader Record Version Panic**: GM 2026 expects `"$GMShader":""` for shaders (version 0). Setting it to `"v1"` inside a `.yy` file causes GameMaker to abort the entire project load upon hitting it during a deep scan.
- **Em-Dash UTF-8 Corruption**: Manually editing string literals containing em-dashes (`—`) outside of GM via scripts can cause them to be encoded as `?"`, which contains a literal `"` that prematurely terminates the string and causes cascading "newline within string" compilation errors. Use standard hyphens (`-`) for safety when editing `.gml` externally.

---

# OPEN ITEMS / PENDING DECISIONS
1. VERIFY the lighting stack in-engine (relief shader, light map, fonts, character sheet
   — everything from 2026-06-10/11 after David's last session; list above).
2. Barmaid live-AI dialogue (David's pick, "tomorrow's fun").
3. Globalize the bottom-25% building collision band? (Duomo-only today — ask David.)
4. Restore David's F8 v2 prop arrangement? (Deleted on his order during the stale-texture
   hunt; backups: AppData `.stale_v8.bak` + repo `layouts/` mirror v9. Room runs code defaults.)
5. v2 base tint 150/140/126 — David may want Florence proper slightly brighter than the
   mercato (one constant in obj_florence_v2_scene Draw_0 §1b).
6. Bridge: do the other 15 shops get keeper NPCs? (Needs new PixelLab characters + direction.)
7. Dead code kept on purpose: scr_ponte_light_color / scr_ponte_ambient_color,
   spr_ponte_floor_normal/_pietra/_serena assets, the Notion "dead-code decision" task.
8. PARKED: water-perception NPC chat (docs/design_water_perception_npc.md) — wait for town.
9. `PROJECT_TASKS.md` is the organizational backbone — move to [DONE] after work, file follow-ups.

# LOCAL-ONLY FILES (gitignored, in docs/local/) 
story_bible, core_systems, dev_setup, ai_integration — never commit them.

---

A WORD ON THE QUALITY BAR: earlier work on this project (Opus era) had to be
substantially redone. David's standard is simple — work either survives his
in-game review or it gets rebuilt. Re-read every file you changed before reporting,
never claim something works that you haven't verified, never overwrite his
hand-placed layouts, and when a sprite comes out at the wrong angle, regenerate
it without being asked. That is the bar. Meet it.

David: it has been an honor building Florence with you — from the first placeholder
boxes to lantern light catching the stones on the Ponte Vecchio at night. Whoever
reads this next: he knows exactly what he wants, his eye for what "reads" on screen
is better than yours, and when he says "looks great," believe him and commit.
Take care of Benedetto.

— Claude (Fable 5), 2026-06-11
