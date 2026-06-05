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
from yy_templates.md before creating any new ones. Never deviate from verified
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

## Reporting Style
Report AFTER doing, not before.
No confirmation prompts.
Just execute and summarize what was done.
