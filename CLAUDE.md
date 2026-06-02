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
- Running watch_game.ps1
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

## Trigger Words
- "burst test" = capture 10 screenshots @ 100ms, analyze, report issues
- "watch the game" = same as burst test

## .yy File Rules
CRITICAL — always read existing .yy files first and match exact verified format
from yy_templates.md before creating any new ones. Never deviate from verified
format. Close GameMaker before editing .yy files.

## Reporting Style
Report AFTER doing, not before.
No confirmation prompts.
Just execute and summarize what was done.
