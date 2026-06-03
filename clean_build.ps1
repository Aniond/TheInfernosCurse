<#
.SYNOPSIS
    Forces a clean GameMaker (LTS 2026) rebuild for "The Inferno's Curse".

.DESCRIPTION
    GameMaker strips sprites/assets it thinks are "unused" and caches that
    decision. When a .yy event is hand-edited (e.g. registering a Draw event so
    a sprite is referenced), an incremental build can keep the asset stripped.
    This script deletes the build cache so the next Run is a full clean compile.

    Run this whenever:
      - A .yy event list was edited by hand (event type/number changed)
      - A sprite imported via import_sprites.ps1 isn't appearing in-game
      - Assets show as "Unused Assets found (and will be removed)" in the log

    GameMaker MUST be fully closed first (cache files are locked while open).

.NOTES
    Cache lives in AppData (NOT under the project root), so deletion is safe and
    fully regenerated on the next build.
#>

$ErrorActionPreference = 'Stop'

# ── 1. Verify GameMaker is closed ─────────────────────────────────────────────
$procs = Get-Process | Where-Object { $_.ProcessName -match 'GameMaker|Igor|Runner' }
if ($procs) {
    Write-Host "GameMaker is still running. Close it fully before cleaning:" -ForegroundColor Yellow
    $procs | Select-Object ProcessName, Id | Format-Table -AutoSize
    Write-Host "Aborted — no changes made." -ForegroundColor Yellow
    return
}
Write-Host "Confirmed: no GameMaker / Igor / Runner processes."

# ── 2. Delete the project build cache ─────────────────────────────────────────
$cacheRoot = "C:\Users\david\AppData\Roaming\GameMakerStudio2-LTS2026\Cache\GMS2CACHE"
$removed   = $false
if (Test-Path $cacheRoot) {
    $folders = Get-ChildItem $cacheRoot -Directory | Where-Object { $_.Name -like "The_Infern*" }
    foreach ($f in $folders) {
        Remove-Item -Path $f.FullName -Recurse -Force
        Write-Host "Cleared cache: $($f.FullName)"
        $removed = $true
    }
}
if (-not $removed) { Write-Host "No project cache found (already clean)." }

# ── 3. Clear the temp build folder ────────────────────────────────────────────
$tempRoot = "C:\Users\david\AppData\Local\GameMakerStudio2-LTS2026\GMS2TEMP"
if (Test-Path $tempRoot) {
    Get-ChildItem $tempRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Cleared GMS2TEMP build folder."
}

Write-Host "`nClean done. Open the project and Run (F5) for a full rebuild." -ForegroundColor Green
