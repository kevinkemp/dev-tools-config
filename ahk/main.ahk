#NoEnv
#Persistent
#InstallKeybdHook
#InstallMouseHook
#SingleInstance Force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%

#Include lib\utils.ahk
#Include lib\keep_awake.ahk
#Include lib\window_positions.ahk
#Include lib\obsidian.ahk
#Include lib\remove_edge_from_quickbar.ahk

; Hotkeys # = win key, ^ = ctrl, ! = alt, + = shift
#^s::SaveWindowPositions()
#^r::RestoreWindowPositions()
#t::PromptTask()
#n::PromptNote()

SetTimer, KeepAwake, 30000
return