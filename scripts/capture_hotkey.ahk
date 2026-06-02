; AutoHotkey script: press F9 to capture a short sequence using the PowerShell script
; Place this AHK file in the same folder as capture_screenshots.ps1 and run it with AutoHotkey.

#NoTrayIcon
#SingleInstance force

F9::
{
    ; Adjust frames and interval as desired
    frames := 8
    interval := 150
    script := A_ScriptDir "\\capture_screenshots.ps1"

    Run, powershell -ExecutionPolicy Bypass -File "%script%" -Frames %frames% -IntervalMs %interval% -OutDir captures -ToGif, %A_ScriptDir%, Hide
    return
}
