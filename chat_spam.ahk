global ui_theme := {voidTheme: {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}}
ui_theme := ui_theme.voidTheme

#include %A_AppData%\LazyHub\lib
#include headers.ahk
#include custom_ui.ahk
#include game_settings.ahk
#include utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Globals               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
textToSend := [     "Cat :poop: 1"
                ,   "Cat :poop: 2"
                ,   "Cat :poop: 3"]
cooldownInSec := 5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Macros                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChatSpamKey     = F2
IsInOrbiter     := False
InGameChat      := True
shouldAltTab    := True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%ChatSpamKey%, ChatSpam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

ui.push(new Window("gui_chat", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui[1].new_text("Cooldown", "chat", "auto", "title", "dadada")
ui[1].show()
return

ChatSpam:
    WinGet, winId ,, A

    if InGameChat
    {
        if (shouldAltTab)
            WinActivate, ahk_exe Warframe.x64.exe

        SendInput % chatKey
        Sleep 50
    }

    SendInput % "{Text}"textToSend[1]
    Sleep 50
    SendInput, {Enter}
    Sleep 50

    if IsInOrbiter
    {
        SendInput, {Esc}
        Sleep 50
    }

    afkTimer := 0
    SetTimer, UpdateAftTimer, 1000

    if InGameChat
    {
        if shouldAltTab
            WinActivate, ahk_id %winId%  
    }

    Sleep cooldownInSec * 1000
    WinGet, winId ,, A

    loop
    {
        SetTimer, UpdateAftTimer, Delete

        if InGameChat
        {
            if (shouldAltTab)
                WinActivate, ahk_exe Warframe.x64.exe

            SendInput % chatKey
            Sleep 50
        }
        
        SendInput % "{Text}"textToSend[mod(A_Index, textToSend.Length())+1]
        Sleep 50
        SendInput, {Enter}
        Sleep 50

        if IsInOrbiter
        {
            SendInput, {Esc}
            Sleep 50
        }

        afkTimer := 0
        SetTimer, UpdateAftTimer, 1000

        if InGameChat
        {
            if shouldAltTab
                WinActivate, ahk_id %winId%  
        }

        Sleep cooldownInSec * 1000
        WinGet, winId ,, A
    }
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