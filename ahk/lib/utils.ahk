TodayIsWorkday()
{
    FormatTime, DayOfWeek,, dddd
    Answer := false
    if (IsItemInList(DayOfWeek, "Monday,Tuesday,Wednesday,Thursday,Friday"))
        Answer := true
    Return Answer
}

TimeIsBetween(LowerBound, UpperBound)
{
    ; LowerBound/UpperBound format: HHmmss (e.g., 080000, 150000)
    FormatTime, CurrentTime,, HHmmss
    Return CurrentTime >= LowerBound and CurrentTime <= UpperBound
}

IsItemInList(item, list, del:=",")
{
    If IsObject(list) {
        for k, v in list
            if (v = item)
                return true
        return false
    } else Return !!InStr(del list del, del item del)
}

UnpinFromTaskbar(path) {
    ; Using Shell.Application COM to enumerate verbs
    ; Some systems may block COM verbs for taskbar; this is best-effort.
    try {
        shell := ComObjCreate("Shell.Application")
        folderPath := ""
        itemName := ""

        SplitPath, path, itemName, folderPath

        folder := shell.NameSpace(folderPath)
        if !folder
            return false

        item := folder.ParseName(itemName)
        if !item
            return false

        verbs := item.Verbs
        if !verbs
            return false

        ; Find a verb containing "unpin from taskbar" or internal "taskbarunpin"
        ; Verb names differ by locale; using a case-insensitive search
        loop % verbs.Count {
            v := verbs.Item(A_Index-1)  ; COM is 0-based
            vName := v.Name
            if (InStr(vName, "unpin", false) || InStr(vName, "taskbarunpin", false))
            {
                v.DoIt()
                return true
            }
        }
    } catch e {
        ; swallow
    }
    return false
}