param(
    [string]$WindowTitle = '',
    [string]$OutputDir = '.\screenshots',
    [int]$Count = 10,
    [int]$DelayMs = 100
)

Set-StrictMode -Version Latest

function Get-TargetWindowHandle {
    param([string]$Title)
    $processes = [System.Diagnostics.Process]::GetProcesses() | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle }
    if ($Title.Trim()) {
        $exact = $processes | Where-Object { $_.MainWindowTitle -ieq $Title }
        if ($exact) { return $exact[0].MainWindowHandle }
        $contains = $processes | Where-Object { $_.MainWindowTitle -like "*$Title*" }
        if ($contains) { return $contains[0].MainWindowHandle }
    }
    if ($processes) { return $processes[0].MainWindowHandle }
    return [IntPtr]::Zero
}

Add-Type -AssemblyName System.Drawing
Add-Type -Namespace Native -Name User32 -MemberDefinition @"
using System;
using System.Runtime.InteropServices;

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}

public static class User32 {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}
"@

$hwnd = Get-TargetWindowHandle -Title $WindowTitle
if (-not $hwnd -or $hwnd -eq [IntPtr]::Zero) {
    Throw "No window found matching title '$WindowTitle'. Use an exact or partial visible window title."
}

if (-not (Test-Path -Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory | Out-Null
}
$OutputDir = (Resolve-Path -Path $OutputDir).Path

$rect = New-Object Native.RECT
if (-not [Native.User32]::GetWindowRect($hwnd, [ref]$rect)) {
    Throw "Unable to read window bounds for handle $hwnd."
}

$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top
if ($width -le 0 -or $height -le 0) {
    Throw "Window bounds are invalid: ${width}x${height}."
}

Write-Host "Capturing $Count screenshots from window title '$WindowTitle' to '$OutputDir'..."
for ($i = 1; $i -le $Count; $i++) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
    $filename = "burst_{0:000}_{1}.png" -f $i, $timestamp
    $path = Join-Path $OutputDir $filename

    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size, [System.Drawing.CopyPixelOperation]::SourceCopy)
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "Saved $path"
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }

    if ($i -lt $Count) { Start-Sleep -Milliseconds $DelayMs }
}

Write-Host "Capture complete."
