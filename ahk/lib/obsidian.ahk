PromptTask()
{
    VaultPath   := "C:\Users\KKemp\OneDrive - Paylocity Corporation\Documents\Obsidian Vault"
    DailyFolder := VaultPath . "\Daily Notes"
    FormatTime, today, , yyyy-MM-dd
    DailyNoteFile := DailyFolder . "\" . today . ".md"

    InputBox, userText, Obsidian Daily Note, Obsidian task:
    if ErrorLevel
        return  ; user cancelled

    if !FileExist(DailyNoteFile)
    {
        FileAppend,, %DailyNoteFile%
    }

    FileAppend, - `n- [ ] #task %userText%, %DailyNoteFile%
    return
}

PromptNote()
{
    VaultPath   := "C:\Users\KKemp\OneDrive - Paylocity Corporation\Documents\Obsidian Vault"
    DailyFolder := VaultPath . "\Daily Notes"
    FormatTime, today, , yyyy-MM-dd
    DailyNoteFile := DailyFolder . "\" . today . ".md"

    InputBox, userText, Obsidian Daily Note, Obsidian note:
    if ErrorLevel
        return  ; user cancelled

    if !FileExist(DailyNoteFile)
    {
        FileAppend,, %DailyNoteFile%
    }

    FileAppend, - `n* %userText%, %DailyNoteFile%
    return
}