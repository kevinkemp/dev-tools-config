SaveWindowPositions()
{
    windowsPositionsIniPath := A_ScriptDir "\WindowPositions.ini"
    WinGet, windowIDs, List

    Loop, % windowIDs
    {
        thisID := windowIDs%A_Index%

        WinGet, process, ProcessName, ahk_id %thisID%
        if (process = "explorer.exe")
            continue

        WinGetPos, x, y, width, height, ahk_id %thisID%
        WinGet, zIndex, MinMax, ahk_id %thisID%

        IniWrite, % x "|" y "|" width "|" height "|" zIndex
            , %windowsPositionsIniPath%
            , Positions
            , % process
    }
}

RestoreWindowPositions()
{
    windowsPositionsIniPath := A_ScriptDir "\WindowPositions.ini"
    if !FileExist(windowsPositionsIniPath)
    {
        MsgBox, 48, Error, No window positions have been saved yet.
        return
    }

    ; Read INI as lines: Positions section data is stored as "process = x|y|w|h|z"
    Loop, Read, %windowsPositionsIniPath%
    {
        ; Expect "key=value" lines; use regex to split both sides and 5 fields on RHS
        RegExMatch(A_LoopReadLine, "^(.*?)=(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)$", match)

        process := match1
        x       := match2
        y       := match3
        width   := match4
        height  := match5
        zIndex  := match6

        WinMove, % "ahk_exe " process, , % x, % y, % width, % height
        if (zIndex = "-1")
            WinMinimize, % "ahk_exe " process
        else if (zIndex = "1")
            WinMaximize, % "ahk_exe " process
    }
}
