# Claude Code Project Setup Instructions
## Auto Mode + Screen Capture Testing

Paste this into Claude Code at the start of every new project.

---

## STEP 1 — Enable Auto Mode

```
Enable Auto Mode for this project permanently.

AUTO EXECUTE without confirmation:
- Creating folders and files
- Writing new script files
- Adding functions to existing scripts
- Running PowerShell commands
- Running bash and terminal commands
- Executing any scripts (.ps1, .sh, .bat)
- Running npm, pip, python commands
- Git commits and pushes
- Moving files in assets folder
- Creating documentation
- Installing packages
- Any read-only operations
- Running import scripts

ALWAYS ASK FIRST:
- Modifying existing core config files
- Deleting any files
- Overwriting existing working code
- Anything with potential data loss
- Any destructive operations

DEFAULT BEHAVIOR:
- Execute immediately
- Report what was done
- Never ask for confirmation on auto list
- Only pause for high risk operations

This is the permanent operating mode
for this project.
```

---

## STEP 2 — Set Up Screen Capture Testing

```
Set up screen capture testing for this project.

STEP 1 — Create screenshots folder:
Create folder at:
[YOUR PROJECT ROOT]\screenshots\

STEP 2 — Create burst capture script:
Create watch_game.ps1 at project root.

The script must:
- Find the application window by title
  Window title: "[YOUR APP WINDOW TITLE]"
- Capture 10 screenshots in rapid succession
- 100ms apart (fast enough for animation testing)
- Save to screenshots\ folder
- Named: burst_001.png through burst_010.png
- Include timestamp in filename

STEP 3 — Create analysis trigger:
When I say "burst test" or "watch the game":
- Run watch_game.ps1 automatically
- Read all 10 saved screenshots
- Analyze frame by frame:
  * What is visible on screen?
  * Any visual bugs or issues?
  * Animation problems?
  * UI elements rendering correctly?
  * Layout or scaling issues?
  * Anything unexpected or broken?
- Report findings with specific fixes suggested
- Flag HIGH priority vs LOW priority issues

STEP 4 — Test immediately:
Run the script once right now.
Confirm it captures correctly.
Report what it captured.

STEP 5 — Set trigger words permanently:
"burst test" = run full capture and analyze
"watch the game" = same as burst test
"check screen" = single screenshot and analyze

Auto Mode — build and test everything now.
Report when ready.
```

---

## STEP 3 — Set Non-Risk Autonomous Rules

```
Additional autonomous execution rules:

For this project Claude Code should:

1. Always read existing files before 
   creating or modifying anything
   
2. Never overwrite working code —
   always append or extend

3. When fixing bugs:
   - Diagnose first
   - Report root cause
   - Fix only what is broken
   - Report what was changed

4. For any new file or system:
   - Check if it already exists first
   - Report what was found
   - Only create what is missing

5. After any significant change:
   - Run burst test automatically
   - Report visual results
   - Suggest next steps

6. Git commits:
   - Commit after each completed feature
   - Use descriptive commit messages
   - Push to remote automatically
   - Never commit sensitive data

7. Report format:
   - What existed (pre-flight check)
   - What was created/modified
   - What was left untouched
   - What still needs attention
```

---

## USAGE NOTES

**Trigger words:**
- `"burst test"` — capture and analyze app window
- `"watch the game"` — same as burst test
- `"check screen"` — single screenshot analysis

**Requirements:**
- Claude Code installed in VS Code
- PowerShell available (Windows)
- Know your app/game window title exactly
- Screenshots folder will be created automatically

**Works for:**
- Game development (GameMaker, Unity, Godot)
- Web apps (browser window)
- Desktop applications
- Any software with a visual interface

**What it catches automatically:**
- Visual bugs and rendering issues
- Animation problems
- Scale and proportion issues
- UI element misalignment
- Missing assets or placeholder art
- Camera and viewport issues
