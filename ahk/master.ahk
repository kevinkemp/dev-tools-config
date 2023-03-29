; SaveAndRestoreWindows.ahk
; KeepAwakeDuringWorkHours.ahk

#NoEnv
#Persistent
#InstallKeybdHook
#InstallMouseHook
#SingleInstance Force
SetBatchLines, -1

SetTimer, KeepAwake, 30000

; Set the hotkeys (Win + S to save, Win + R to restore)
#s::SaveWindowPositions()
#r::RestoreWindowPositions()

SaveWindowPositions() 
{
    ; Enumerate all top-level windows
    WinGet, windowIDs, List

    ; Loop through each window ID
    Loop, % windowIDs
    {
        thisID := windowIDs%A_Index%

        ; Get window process and check if it's explorer.exe
        WinGet, process, ProcessName, ahk_id %thisID%
        if (process = "explorer.exe")
            continue

        ; Get window position, size, and z-index
        WinGetPos, x, y, width, height, ahk_id %thisID%
        WinGet, zIndex, MinMax, ahk_id %thisID%

        ; Save the window position, size, process, and z-index in the INI file
        IniWrite, % x "|" y "|" width "|" height "|" zIndex, WindowPositions.ini, Positions, % process
    }
}

RestoreWindowPositions() 
{
    ; Check if the INI file exists
    if !FileExist("WindowPositions.ini")
    {
        MsgBox, 48, Error, No window positions have been saved yet.
        return
    }

    ; Loop through the saved windows in the INI file
    Loop, Read, WindowPositions.ini
    {
        ; Extract the process, position, size, and z-index
        RegExMatch(A_LoopReadLine, "^(.*?)=(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)$", match)

        process := match1
        x := match2
        y := match3
        width := match4
        height := match5
        zIndex := match6

        ; Restore the window position, size, and z-index
        WinMove, % "ahk_exe " process, , % x, % y, % width, % height
        if (zIndex = "-1")
            WinMinimize, % "ahk_exe " process
        else if (zIndex = "1")
            WinMaximize, % "ahk_exe " process
    }
}

KeepAwake:
    KeepAwake()
    Return

KeepAwake()
{
    IsWorkday := TodayIsWorkday()
    IsWorkHours := TimeIsBetween(070000, 180000)
    IsIdle := A_TimeIdle >= 3 * 60 * 1000
    OutputDebug, %IsIdle% %IsWorkday% %IsWorkHours% %A_TimeIdle%
    if (IsIdle and IsWorkday and IsWorkHours)
    {
        MouseMove, 1, 0, 1, R  ;Move the mouse one pixel to the right
        MouseMove, -1, 0, 1, R ;Move the mouse back one pixel
    }
    Return
}

TodayIsWorkday()
{
    FormatTime, DayOfWeek,,dddd,
    Answer := false
    if (DayOfWeek in Tuesday, Wednesday, Thursday, Friday)
    {
        Answer := true
    }
    Return Answer
}

TimeIsBetween(LowerBound, UpperBound)
{
    FormatTime,CurrentTime,,HHmmss
    Return CurrentTime >= LowerBound and CurrentTime <= UpperBound
}