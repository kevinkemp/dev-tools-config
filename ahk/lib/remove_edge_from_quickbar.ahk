#Include %A_LineFile%\..\utils.ahk

edgeShortNames := ["Microsoft Edge.lnk", "Edge.lnk"]

; --- Known pinned folders (Windows 10/11) ---
; User Pinned Taskbar folder is the usual quick launch location for shortcuts
pinnedTaskbar := A_AppData "\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
quickLaunch   := A_AppData "\Microsoft\Internet Explorer\Quick Launch"

didChange := false

; --- Try unpin via COM verb "taskbarunpin" on found .lnk files ---
for idx, shortName in edgeShortNames
{
    edgeLink1 := pinnedTaskbar "\" shortName
    edgeLink2 := quickLaunch "\" shortName

    if (FileExist(edgeLink1)) {
        if UnpinFromTaskbar(edgeLink1)
            didChange := true
        ; also delete the shortcut to avoid re-surface
        FileDelete, %edgeLink1%
        if (ErrorLevel = 0)
            didChange := true
    }

    if (FileExist(edgeLink2)) {
        if UnpinFromTaskbar(edgeLink2)
            didChange := true
        FileDelete, %edgeLink2%
        if (ErrorLevel = 0)
            didChange := true
    }
}

; --- Additional heuristic: attempt unpin on Edge’s app path if present ---
; This helps if the pinned icon is stored in Taskband registry without an .lnk file.
; Common Edge executable path:
edgeExe := A_ProgramFiles "\Microsoft\Edge\Application\msedge.exe"
if FileExist(edgeExe) {
    if UnpinFromTaskbar(edgeExe)
        didChange := true
}