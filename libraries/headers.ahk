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

;---------------------------NEW---------------------------
#SingleInstance Force
#Persistent
#NoEnv
#InstallKeybdHook
SendMode Input
Process, Priority,, A
ListLines Off
SetWinDelay, -1
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1, -1
SetControlDelay, -1
#MaxHotkeysPerInterval 99000000
#MaxThreads 255
#KeyHistory 0
; CoordMode, Mouse, Client