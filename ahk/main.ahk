#NoEnv
#Persistent
#InstallKeybdHook
#InstallMouseHook
#SingleInstance Force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%

; need to set paths absolutely in order for them to process correctly on startup
#Include %A_ScriptDir%\lib\utils.ahk
#Include %A_ScriptDir%\lib\keep_awake.ahk
#Include %A_ScriptDir%\lib\window_positions.ahk
#Include %A_ScriptDir%\lib\obsidian.ahk
#Include %A_ScriptDir%\lib\remove_edge_from_quickbar.ahk

; Hotkeys # = win key, ^ = ctrl, ! = alt, + = shift
#^s::SaveWindowPositions()
#^r::RestoreWindowPositions()
#t::PromptTask()
#n::PromptNote()

SetTimer, KeepAwake, 30000
return