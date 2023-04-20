#include %A_ScriptDir%

global ui_theme := {voidTheme: {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}}
ui_theme := ui_theme.voidTheme

#include libraries\headers.ahk
#include libraries\game_settings.ahk

#include libraries\custom_ui.ahk
#include libraries\timers.ahk
#include libraries\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include settings\cfg_%A_Scriptname%

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%AfkNovaKey%, AfkNova
Hotkey, *%AnomalySpamKey%, AnomalySpam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

ui.push(new Window("gui_nova", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui[1].new_text("Cooldown", "f: nova", "auto", "title", "dadada")
ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global toggleAnemic := false

AfkNova:
    WinGet, winId ,, A

    loop
    {
        SetTimer, AnomalySpamSrc, Delete

        if toggleAnemic
        {
            Sleep 200
            SendInput, {Blind}{%aimKey%}
            SendInput, {Blind}{%meleeKey%}
            lSleep(58+minSleepTime)
        }
        
        if (shouldAltTab)
            WinActivate, ahk_exe Warframe.x64.exe
        SendInput, {Blind}{%shoot2Key%}
        ; SendInput {Blind}{%aimKey% Down}
        ; Sleep 100
        ; SendInput {Blind}{%aimKey% Up}

        ; SendInput {Blind}{%shiftKey%}
        ; Sleep 100
        ; SendInput {Blind}{%sKey% Down}
        ; Sleep 30
        ; SendInput {Blind}{%crouchKey%}
        ; Sleep 30
        ; SendInput {Blind}{%sKey% Up}
        ; Sleep 550

        SendInput {Blind}{%secondAKey%} ; For mag skill
        Sleep 700
        SendInput {Blind}{%fourthAKey%}
        Sleep 1000

        if shouldAltTab
            WinActivate, ahk_id %winId%
        else 
            if toggleAnemic
                SetTimer, AnomalySpamSrc, 1

        afkTimer := 0
        SetTimer, UpdateAftTimer, 1000
        Sleep cooldownInSec * 1000

        WinGet, winId ,, A
    }
return

AnomalySpam:
    toggleAnemic := !toggleAnemic
    SetTimer, AnomalySpamSrc, % toggleAnemic ? 1 : "Off"
return

AnomalySpamSrc:
    SendInput, {Blind}{%operatorKey%}
    lSleep(450)
    SendInput, {Blind}{%aimKey%}
    SendInput, {Blind}{%meleeKey%}
    lSleep(58+minSleepTime)
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateAftTimer:
    afkTimer += 1
    timeDisplay := cooldownInSec - afkTimer

    if (timeDisplay <= 0)
    {
        SetTimer, UpdateAftTimer, off
        ui[1].edit_text("Cooldown", "xx")
        return
    }

    ui[1].edit_text("Cooldown", timeDisplay)
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*Insert::reload
*Del::exitapp