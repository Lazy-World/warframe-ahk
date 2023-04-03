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
global textToSend := [  "Cat :poop: 1"
                    ,   "Cat :poop: 2"
                    ,   "Cat :poop: 3"]
global cooldownInSec    := 5

global IsInOrbiter      := False
global IsWarframeChat   := True
global shouldAltTab     := True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Macros                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChatSpamKey     = F2

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChatSpam:
    loop
    {
        WinGet, winId ,, A

        if shouldAltTab
            GoSub, OpenWarframeWindow
    
        if IsWarframeChat
            GoSub, SafeOpenChat
    
        SendMessage(textToSend[mod(A_Index, textToSend.Length())], 100)

        if IsInOrbiter
            CloseOrbiterChat(100)

        afkTimer := 0
        SetTimer, UpdateAfkTimer, 1000

        if shouldAltTab
            OpenLastFoundWindow(winId)

        Sleep cooldownInSec * 1000
        WinGet, winId ,, A
    }
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Utils                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SendMessage(message, delay = 50)
{
    SendInput % "{Text}"message
    Sleep % delay
    SendInput, {Enter}
    Sleep % delay
}

OpenWarframeWindow:
    WinActivate, ahk_exe Warframe.x64.exe
return

OpenLastFoundWindow(windowId)
{
    WinActivate, ahk_id %windowId%
}

SafeOpenChat:
    SendInput % chatKey
    Sleep 150
return

CloseOrbiterChat(delay = 50)
{
    SendInput, {Esc}
    Sleep % delay
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateAfkTimer:
    afkTimer += 1
    timeDisplay := cooldownInSec - afkTimer

    if (timeDisplay <= 0)
    {
        SetTimer, UpdateAfkTimer, off
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