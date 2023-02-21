; #NoEnv
; #Persistent
; #KeyHistory 0
; #HotkeyInterval 99000000
; #MaxHotkeysPerInterval 99000000
; SetDefaultMouseSpeed, 0
; SetControlDelay, -1
; SetKeyDelay, -1, -1
; SetMouseDelay, -1
; SetBatchLines, -1
; SetWinDelay, -1
; SendMode Input
; ListLines Off
; CoordMode, Mouse, Client

;---------------------------LUMI---------------------------
#SingleInstance Force
#Persistent
#NoEnv
#InstallKeybdHook
#InstallMouseHook
SendMode Input
Process, Priority,, A
SetBatchLines -1
SetKeyDelay, -1, -1
SetMouseDelay, -1, -1
SetControlDelay -1
SetWinDelay -1
#MaxHotkeysPerInterval 100000
#MaxThreads 255
CoordMode, Mouse, Client