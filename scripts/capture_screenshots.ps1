<#
.SYNOPSIS
  Capture one or more screenshots and optionally build a GIF using ffmpeg.

.DESCRIPTION
  Captures the primary screen at a specified interval. Saves PNG frames
  into the output directory. If `-ToGif` is supplied and `ffmpeg` is
  available in PATH, a GIF will be created from the captured frames.

.EXAMPLE
  PowerShell -ExecutionPolicy Bypass -File scripts\capture_screenshots.ps1 -Frames 10 -IntervalMs 200 -OutDir captures -ToGif
#>

param(
    [int]$Frames = 1,
    [int]$IntervalMs = 500,
    [string]$OutDir = "captures",
    [switch]$ToGif,
    [int]$GifFps = 15
)

Add-Type -AssemblyName System.Drawing, System.Windows.Forms

# ensure output directory exists
$fullOut = Join-Path -Path (Get-Location) -ChildPath $OutDir
if (-not (Test-Path $fullOut)) { New-Item -ItemType Directory -Path $fullOut | Out-Null }

Write-Host "Capturing $Frames frame(s) to: $fullOut (interval ${IntervalMs}ms)"

for ($i = 1; $i -le $Frames; $i++) {
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bmp.Size)

    $filename = Join-Path $fullOut ("frame_{0:d4}.png" -f $i)
    $bmp.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose()
    $bmp.Dispose()

    Write-Host "Saved $filename"
    if ($i -lt $Frames) { Start-Sleep -Milliseconds $IntervalMs }
}

if ($ToGif) {
    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $ffmpeg) {
        Write-Warning "ffmpeg not found in PATH; GIF creation skipped. Install ffmpeg and retry."
        exit 0
    }

    $pattern = Join-Path $fullOut "frame_%04d.png"
    $outGif = Join-Path $fullOut "capture_$(Get-Date -Format yyyyMMdd_HHmmss).gif"

    # Call ffmpeg to build GIF with a reasonable palette for smaller size
    $palette = Join-Path $fullOut "palette.png"
    & ffmpeg -y -f image2 -framerate $GifFps -i $pattern -vf "palettegen" $palette
    & ffmpeg -y -f image2 -framerate $GifFps -i $pattern -i $palette -lavfi "paletteuse" $outGif

    if (Test-Path $outGif) { Write-Host "GIF created: $outGif" } else { Write-Warning "GIF creation failed." }
}

Write-Host "Done."
