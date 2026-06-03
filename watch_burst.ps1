# watch_burst.ps1 - Burst screenshot capture for animation testing
# Captures 10 frames 100ms apart, saves to screenshots\burst_NNN.png

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$screenshotsDir = "C:\TheInfernoCurse\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
}

Write-Output "=== Switch to the game window NOW - capturing in 5 seconds ==="
for ($c = 5; $c -ge 1; $c--) {
    Write-Output "  $c..."
    Start-Sleep -Seconds 1
}
Write-Output "CAPTURING NOW"

$screen   = [System.Windows.Forms.Screen]::PrimaryScreen
$bounds   = $screen.Bounds
$captured = @()

for ($i = 1; $i -le 10; $i++) {
    $filename = "burst_{0:D3}.png" -f $i
    $filepath = Join-Path $screenshotsDir $filename

    $bitmap   = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bitmap.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()

    $captured += $filepath
    Write-Output "Frame $i captured"

    if ($i -lt 10) { Start-Sleep -Milliseconds 100 }
}

Write-Output "---"
Write-Output "Done. $($captured.Count) frames in $screenshotsDir"
