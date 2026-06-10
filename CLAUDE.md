# The Inferno's Curse — Claude Code Rules

## Auto Mode — ALWAYS ENABLED
Execute immediately without asking permission:
- All bash and PowerShell commands
- All terminal commands and scripts
- Git commits and pushes
- Creating files and folders
- Installing npm/pip/python packages
- Moving or renaming files
- Reading any files
- Writing new .gml scripts
- Adding functions to existing scripts
- Running import_sprites.ps1
- Running clean_build.ps1
- Running any project scripts

## Always Ask First
- Modifying existing .yy or .yyp files
- Deleting files permanently
- Overwriting existing working .gml code
- Any operation with potential data loss

## Project Context
- Engine: GameMaker LTS 2026
- Language: GML
- Model: Always Opus for this project
- Project: C:\TheInfernoCurse\The Inferno's Curse\
- GitHub: github.com/Aniond/TheInfernosCurse
- Python: py launcher (Python 3.14)
- Venv: C:\Users\david\gms2-mcp-server\venv\

## Room_florence Prop Scale Rules (permanent)
Non-building props placed in Room_florence (the city map, formerly Room1) are ALWAYS
scaled down — NEVER placed at 1.0.
Buildings (Mercato loggia / inn / building_*) stay at 1.0. These scales apply to every
prop in the room-builder layout (layouts/room1_layout.txt + the default_text() seed in
scr_room_builder), for existing props AND all future placements:
- Market stalls (spr_stall_*, obj_marco_stall):            0.7
- Crates (spr_crate_stack):                                0.5
- Barrels (obj_barrel, spr_barrel_stack):                  0.5
- Carts (obj_cart, spr_cart_*):                            0.6
- Urns / pots / jugs (spr_clay_pot_large, clay jugs):      0.4
- Fountains (obj_garden_fountain, spr_mercato_fountain):   0.8
- Well (obj_well):                                         0.7
- Trees / bushes (obj_cypress_tree, garden trees):         0.7
Buildings stay 1.0. For an uncategorised prop, use the nearest category (default ~0.6)
and never 1.0.

NEW-GENERATION assets (2026-06-09 standard, set by David):
- New Florence STREET PROPS: generate on a 64x64 canvas, prop fills 60% MAX;
  place at 0.7 (stalls/carts) or 0.5 (small details).
- BUILDING sprites target the ~128px class at 1.0. PixelLab buildings generated
  larger than that get scaled DOWN in the layout: landmarks (duomo, campanile,
  palazzo) 0.7 · standard buildings (church, guild, inn, apothecary, gates,
  workshops, row houses) 0.65. "Buildings stay 1.0" applies to the legacy
  mercato set, whose art was already sized for 1.0.

## Single System — Corruption IS Sanity (permanent)
There is NO separate sanity stat. `global.circle_corruption[CIRCLE_LIMBO]` (0-100)
is the one axis. Benedetto only THINKS he is going insane — it is the corruption
tainting him. Anything that needs a "high = lucid" value uses the derived
`scr_perceived_sanity()` = `100 - clamp(Limbo corruption, 0, 100)`. Mutations:
`scr_corruption_taint(amount)` raises it (fires 25/50/75 thresholds + game over at
100); `scr_corruption_relieve(amount, deep)` lowers it but never below a floor
(15 normal / 10 deep). Do NOT reintroduce `global.sanity`.

## Battle Rules (permanent)
- Player can always flee with ESC — costs +8% Limbo corruption (the old +3% +
  the converted -5 sanity, now a single corruption hit)
- Corruption is the single axis — there is no in-battle sanity floor
- AP exhaustion NEVER auto-advances the player's turn — Z/ENTER required
- Enemy turns have a 250ms delay between each (15 steps @ 60fps) — readable
- API takeover fires at corruption >= 100 (Benedetto "clings on" — resets to 90
  until the real Claude-driven takeover is wired)

## Burst Testing — user runs it manually, do NOT automate
The user runs burst tests / watch_game.ps1 manually themselves. Do NOT run
watch_game.ps1 or capture-and-analyze screenshots automatically after changes,
and do NOT treat "burst test" / "watch the game" as commands to execute. After
a change, just commit + clean build and tell the user it's ready to test.

## External Libraries — CRITICAL
Do NOT install external GameMaker libraries without first verifying IDEVersion
compatibility with LTS 2026 specifically. LTS 2026 is a SEPARATE branch from the
Monthly releases — a library built on "2024.x" Monthly can be INcompatible even
though the number looks older:
- Libraries from Monthly 2024.11+ use resource formats NEWER than the LTS 2026
  fork point → "Project is later than this GameMaker release" warning (won't open).
- Old libraries (2022-era) use the pre-$GM-tag .yy format → JSON parse errors
  ("A type tag field is required at the start of the JSON record").
Rules:
- Test every library install on a throwaway branch FIRST. Never install directly
  to master.
- Have the user open it in GameMaker and confirm a clean load before merging.
- (History: 2026-06-02 — Scribble, Bulb, Input all had to be removed for this.
  Only SnowState was salvageable, after fixing its 2 .yy files to LTS 2026 format.)

## .yy File Rules
CRITICAL — always read existing .yy files first and match exact verified format
from docs/yy_templates.md before creating any new ones. Never deviate from verified
format. Close GameMaker before editing .yy files.

## Tilesets — NEVER hand-author
NEVER hand-author tileset .yy files.
Only GameMaker IDE creates tilesets.
Hand-authored tileset .yy always fails
due to required fields like
tileAnimationFrames that GM manages.
(History: 2026-06-04 — a hand-authored ts_florence_cobblestone.yy failed
project load and the whole branch had to be discarded. Tilesets MUST be made
via IDE: right-click Tilesets > Create, assign sprite, set tile size. Same for
assigning a tileset to a room Ground layer — do it in the IDE room editor.)

## Clean Build — AUTOMATIC after every change that needs a rebuild
GameMaker caches "unused asset" stripping, so incremental builds keep assets
stripped even after the .gml/.yy edit that should reference them.
ALWAYS run clean_build.ps1 automatically — without being asked — at the end of
any change set that touches code, .yy files, or sprites, so the user's next Run
is a guaranteed clean compile. The script self-aborts if GameMaker is open (no
harm), so running it every time is safe. Do not ask first; just run it and note
it in the report. Especially required after hand-editing a .yy event list or
when an imported sprite isn't appearing (sign: compile log lists "Unused Assets
found", or a unit draws nothing — no sprite AND no placeholder rectangle).

## WALLS — Void Wall + Art (permanent standard, set 2026-06-10)
EVERY wall in the game — city walls, interior partitions, precinct/courtyard
walls, any future wall — is built as VOID WALL + ART: a solid BLACK void band
(which is also the collision rect, single geometry source) with sprite/tile
art filling it inset (black outline frame), plus a lit top edge where it fits.
Established in the stable partitions, proven on the Florence v2 city walls and
the Duomo precinct walls. Generate the fill tile AT THE BAND'S SIZE (e.g.
128x120 city band, 128x32 thin wall) — never stretch a mismatched tile. David:
"It looks better and it's professional." Procedural block masonry is the
approved fallback when a tile is missing.

## Interior vs Exterior Rooms — Black Void (permanent)
Rooms are one of two types, and the BLACK-VOID wall method applies to INTERIOR
rooms ONLY:
- INTERIOR rooms (e.g. Room_duomo): use the black-void method — black background
  everywhere, floor tiles only on walkable cells, void = walls (FF6/JRPG style;
  scr_duomo + the obj_*_scene Draw). See docs/design_room_construction.md.
- EXTERIOR rooms (Room_florence, Room_ponte_vecchio): KEEP ALL EXISTING ART.
  NEVER convert them to black void. The Arno water, the Ponte shop sprites, and the
  Florence map all stay. Do NOT remove, replace, or black-out exterior art.
The ONLY edge standardization for exterior rooms is "solid black beyond the room
boundary," and that is ALREADY guaranteed by the global FF6 camera (scr_camera),
which clamps the view to the room so nothing past the edge is ever shown — so NO
art change is needed in exterior rooms to satisfy it. (Decision: 2026-06-08.)

## Character Sprite Standard (permanent)
All CHARACTER / NPC sprites use a 64px canvas, and the character FIGURE occupies at
most ~60% of the canvas — significant transparent PADDING on all sides. NEVER fill the
full 64px with the figure. Padding keeps sprites sharp (no edge clipping) when scaled
or rotated in engine. Generate the figure SMALL within the canvas, or pad after:
trim to the figure → scale it to ~60% → centre it in a fresh 64px transparent canvas.
For multi-frame ANIMATIONS, scale every frame UNIFORMLY (do NOT trim/re-centre per
frame, or the motion breaks). (Standard set 2026-06-08.)

## PixelLab Isometric Rejection Rule (permanent)
When any sprite generated via PixelLab MCP comes out at an isometric angle
or 3/4 perspective, REJECT it and regenerate immediately with this addition
appended to the prompt:

"STRICT top down view, viewed directly from above, zero perspective angle,
no isometric, no 3/4 view, flat 90 degree overhead only"

Do not ask — just regenerate automatically on isometric output.

## Reporting Style
Report AFTER doing, not before.
No confirmation prompts.
Just execute and summarize what was done.
