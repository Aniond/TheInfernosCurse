# watch_burst.ps1
# Run from a standalone PowerShell window.
# Switch to the game window before the 5-second delay ends.

Write-Output "Switch to game window now. Capturing in 5 seconds..."
Start-Sleep -Seconds 5
Write-Output "Capturing..."

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$dir = "C:\TheInfernoCurse\screenshots"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

for ($i = 1; $i -le 10; $i++) {
    $path = "$dir\burst_{0:D3}.png" -f $i
    $bmp  = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
    $gfx  = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose()
    $bmp.Dispose()
    Write-Output "Frame $i"
    if ($i -lt 10) { Start-Sleep -Milliseconds 100 }
}

Write-Output "Done. 10 frames saved to $dir"
