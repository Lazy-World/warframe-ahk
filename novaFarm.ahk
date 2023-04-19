global ui_theme := {voidTheme: {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}}
ui_theme := ui_theme.voidTheme

#include %A_AppData%\LazyHub\lib

#include headers.ahk
#include game_settings.ahk

#include custom_ui.ahk
#include timers.ahk
#include utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cooldownInSec   := 20 ; Delay before recast
shouldAltTab    := True ; Focus on game
AfkNovaKey      = F2 ; Automatic cast 
; AnomalySpamKey  = o ; Magus Anomaly spam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkey, *%AfkNovaKey%, AfkNova
; Hotkey, *%AnomalySpamKey%, AnomalySpam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28 + 23

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

ui.push(new Window("gui_nova", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui[1].new_text("SecndA", "2: ", "left xm+10", "title", "dadada")
ui[1].new_text("FurthA", "4: ", "left xm+10", "title", "dadada")
ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AfkNova:
    loop
    {
        WinGet, winId ,, A

        if shouldAltTab
            GoSub, OpenWarframeWindow

        FurthA := 0
        SendInput {Blind}{%fourthAKey%}
        SetTimer, UpdateAftTimer, 1000
        Sleep 450

        
    }
return

AnomalySpam:

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Utils                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OpenWarframeWindow:
    WinActivate, ahk_exe Warframe.x64.exe
return

OpenLastFoundWindow(windowId)
{
    WinActivate, ahk_id %windowId%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateAftTimer:
    afkTimer += 1
    timeDisplay := cooldownInSec - afkTimer

    if (timeDisplay <= 0)
    {
        SetTimer, UpdateAftTimer, off
        ui[1].edit_text("Cooldown", "counting..")
        return
    }

    ui[1].edit_text("Cooldown", timeDisplay)
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*Insert::reload
*Del::exitapp