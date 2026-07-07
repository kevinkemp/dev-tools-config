; Always-on-top overlay that lists every shortcut this script provides.
; Toggled with Windows + H (wired up in ..\main.ahk).
; Modifier buttons are spelled out (Windows / Ctrl / Alt / Shift) for readability.

global ShortcutsHelp_Visible := false
global ShortcutsHelp_Built   := false
global ShortcutsHelp_Hwnd    := 0

ToggleShortcutsHelp()
{
    global ShortcutsHelp_Visible
    global ShortcutsHelp_Built
    global ShortcutsHelp_Hwnd

    if (ShortcutsHelp_Visible)
    {
        Gui, Hide
        ShortcutsHelp_Visible := false
        return
    }

    if (!ShortcutsHelp_Built)
    {
        BuildShortcutsHelpGui()
        ShortcutsHelp_Built := true

        ; Realize the size off-screen, then dock it to the top-right corner.
        Gui, Show, AutoSize NoActivate x-30000 y-30000, Shortcuts
        WinGetPos, , , helpWidth, , ahk_id %ShortcutsHelp_Hwnd%
        xPos := A_ScreenWidth - helpWidth - 24
        Gui, Show, NoActivate x%xPos% y24, Shortcuts
        ShortcutsHelp_Visible := true
        return
    }

    Gui, Show, NoActivate, Shortcuts
    ShortcutsHelp_Visible := true
}

BuildShortcutsHelpGui()
{
    global ShortcutsHelp_Hwnd

    Gui, +AlwaysOnTop +ToolWindow +LabelShortcutsHelp_ +HwndShortcutsHelp_Hwnd
    Gui, Margin, 20, 18
    Gui, Color, 0x1F1F1F

    Gui, Font, s12 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, , Keyboard Shortcuts

    ; Each command: shortcut (full modifier-button names) + what it does.
    Gui, Font, s10 Norm cFFFFFF, Segoe UI
    Gui, Add, Text, xm y+14 w170 cFFFFFF, Windows + Ctrl + S
    Gui, Add, Text, x+20 yp w210 cBFBFBF, Save window positions
    Gui, Add, Text, xm y+10 w170 cFFFFFF, Windows + Ctrl + R
    Gui, Add, Text, x+20 yp w210 cBFBFBF, Restore window positions
    Gui, Add, Text, xm y+10 w170 cFFFFFF, Windows + T
    Gui, Add, Text, x+20 yp w210 cBFBFBF, New Obsidian task
    Gui, Add, Text, xm y+10 w170 cFFFFFF, Windows + N
    Gui, Add, Text, x+20 yp w210 cBFBFBF, New Obsidian note
    Gui, Add, Text, xm y+10 w170 cFFFFFF, Windows + H
    Gui, Add, Text, x+20 yp w210 cBFBFBF, Toggle this shortcuts window

    Gui, Font, s8 Norm c8C8C8C, Segoe UI
    Gui, Add, Text, xm y+16, Windows + H toggles this window.
}
