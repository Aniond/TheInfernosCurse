Capture scripts for quick gameplay screenshots and GIFs

Usage (PowerShell):

Open PowerShell in the repository root and run:

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts\capture_screenshots.ps1 -Frames 10 -IntervalMs 100 -OutDir captures -ToGif
```

Options:
- `-Frames`: number of frames to capture (default 1)
- `-IntervalMs`: milliseconds between frames (default 500)
- `-OutDir`: output folder for frames/GIF (default `captures`)
- `-ToGif`: if supplied, attempts to build a GIF using `ffmpeg` (must be in PATH)
- `-GifFps`: frame rate used when building the GIF (default 15)

AutoHotkey (optional):
- `scripts\capture_hotkey.ahk` binds `F9` to run the PowerShell script with configured parameters.
- Place AutoHotkey executable on your system and run the AHK script. The script uses a relative path so keep it next to `capture_screenshots.ps1`.

Notes:
- The script captures the primary display. If you need a specific window, consider cropping frames or using a window-focused capture utility.
- GIF creation requires `ffmpeg` installed and in your PATH. If unavailable, the script will still save PNG frames.

Next steps:
- Run a short capture and upload the GIF or frames here for analysis. I'll inspect each frame and report visual issues.
