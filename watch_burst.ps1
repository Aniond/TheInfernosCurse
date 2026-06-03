# watch_burst.ps1
# Run from a standalone PowerShell window.
# Minimizes its own window after 3 seconds so the game is captured.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Output "Switching to game in 3 seconds -- minimizing this window..."
Start-Sleep -Seconds 3

# Minimize the PowerShell console window so it doesn't cover the game
$sig = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$type = Add-Type -MemberDefinition $sig -Name Win32 -Namespace Win32Functions -PassThru
$hwnd = (Get-Process -Id $PID).MainWindowHandle
$type::ShowWindow($hwnd, 6) | Out-Null   # 6 = SW_MINIMIZE

Start-Sleep -Milliseconds 500   # let the window finish minimizing

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
    if ($i -lt 10) { Start-Sleep -Milliseconds 100 }
}

# Restore window when done
$type::ShowWindow($hwnd, 9) | Out-Null   # 9 = SW_RESTORE
Write-Output "Done. 10 frames saved to $dir"
