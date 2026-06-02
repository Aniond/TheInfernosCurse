# watch_game.ps1 - Capture screenshot for The Inferno's Curse game testing
# Usage: .\watch_game.ps1
# Output: path to saved screenshot

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$screenshotsDir = "C:\TheInfernoCurse\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$filename  = "test_$timestamp.png"
$filepath  = Join-Path $screenshotsDir $filename

# Capture primary screen
$screen   = [System.Windows.Forms.Screen]::PrimaryScreen
$bounds   = $screen.Bounds
$bitmap   = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

$bitmap.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

# Output path so callers know where to find the file
Write-Output $filepath
