# watch-game

Triggered when the user says "watch the game", "watch game", or similar.
For burst/animation analysis, triggered by "burst", "check animation", "watch animation", "check sprites", or similar.

---

## Single frame — "watch the game"

1. Run: `C:\TheInfernoCurse\watch_game.ps1`
2. Read the screenshot at the returned path.
3. Analyze and report:
   - Is the GameMaker window visible?
   - Player sprite: direction, position, animation frame?
   - UI/HUD: aligned, visible, correct values?
   - Visual glitches: missing sprites, wrong layering, corruption?
   - Room/tileset: tile gaps, misalignment?
   - Any error overlays or debug output?

4. Report format:
   ```
   WATCH REPORT — <timestamp>
   Screenshot: <path>

   WHAT I SEE:
   <description>

   ISSUES FOUND:
   <numbered list or "None detected">

   SUGGESTED FIXES:
   <numbered list or "N/A">
   ```

---

## Burst mode — "burst" / "check animation" / "watch animation"

1. Run: `C:\TheInfernoCurse\watch_burst.ps1`
2. Read all 10 frames: `screenshots\burst_001.png` through `burst_010.png`.
3. Analyze across all frames:
   - **Smooth animation?** — does Benedetto's sprite cycle naturally frame-to-frame?
   - **Flickering?** — does the sprite disappear or flash between any frames?
   - **Sprite jumping?** — sudden position snaps not explained by movement speed?
   - **Direction changes?** — do direction transitions look correct or do wrong sprites appear?
   - **Camera follow?** — is the camera tracking Benedetto smoothly or lagging/snapping?
   - **Visual corruption?** — stretched pixels, wrong palette, garbled tiles?
   - **Overall assessment** — pass or fail, and confidence level.

4. Report format:
   ```
   BURST REPORT — 10 frames @ 100ms
   Frames: screenshots\burst_001.png → burst_010.png

   FRAME-BY-FRAME:
   F01: <one line>
   F02: <one line>
   ... (note any frame where something changes)

   ANIMATION ANALYSIS:
   Smooth:       Yes / No — <detail>
   Flickering:   Yes / No — <detail>
   Sprite jump:  Yes / No — <detail>
   Direction:    OK / Issue — <detail>
   Camera:       OK / Issue — <detail>
   Corruption:   Yes / No — <detail>

   OVERALL: PASS / FAIL
   <1-2 sentence summary>

   FIXES NEEDED:
   <numbered list or "None">
   ```

---

## Cleanup — always run after every analysis

After delivering the report (single frame or burst), delete all screenshots:
```powershell
Remove-Item "C:\TheInfernoCurse\screenshots\burst_*.png" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\TheInfernoCurse\screenshots\test_*.png" -Force -ErrorAction SilentlyContinue
```
Confirm folder is empty. Do not announce the cleanup — just do it silently.

---

If no GameMaker window is visible in any frame, say so and ask the user to bring it to the foreground.
