global ui_theme := {voidTheme: {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}}
ui_theme := ui_theme.voidTheme

#include %A_AppData%\LazyHub\lib

#include headers.ahk
#include timers.ahk
#include utils.ahk
#include custom_ui.ahk

#include game_settings.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Globals               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global g_waterShieldDelay := 250 ; depends on client PING
global g_desiredLimb := -20 ; equals to "-0.020" in Yate
global g_raplakDelay := 1610 ; depends on client FPS
global g_step := 5

; Math
global g_cooldown := 17186 - g_raplakDelay + g_desiredLimb - 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Binds                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AntiDesyncKey   = XButton2
IncreaseTimeKey = Down
DecreaseTimeKey = Left
EnergyDrainKey  = F5
WaterShieldKey  = Numpad0

; Technical part
#IfWinActive ahk_exe Warframe.x64.exe
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%AntiDesyncKey%, AntiDesync
Hotkey, *%IncreaseTimeKey%, IncreaseTime
Hotkey, *%DecreaseTimeKey%, DecreaseTime
Hotkey, *%EnergyDrainKey%, EnergyDrain
Hotkey, *%WaterShieldKey%, WaterShield

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             GUI Settings            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ui.push(new Window("vs_title", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui.push(new Window("vs_body", gPosX, gPosY+ui[1].h+4, gGuiW, gGuiH*2, ui_theme, 3.132))

ui[1].new_text("T1", "lazy", "auto", "title")
ui[2].new_text("T2", g_cooldown, "xs ym+3", "main")
ui[2].new_text("T3", "[time]", "xs ym+24", "info")

loop % ui.Length()
    ui[A_Index].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Funcs                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateTimer(begin, end := "", prec := "3") {
    if (end == "")
        DllCall("QueryPerformanceCounter", "Int64*", end)

    offset := MeasureTime(begin, end)
    offsetText := Format(offset >= 9999 ? "{1:.0f}" : "{1:.1f}", offset)

    ui[1].edit_text("T1", offsetText)
}

AntiDesync:
    GoSub, IncreaseTime
    GoSub, DecreaseTime
    
    loop, 5
    {
        DllCall("QueryPerformanceCounter", "Int64*", beforePropa)
        SendInput, {Blind}{%shoot2Key%}
        DllCall("QueryPerformanceCounter", "Int64*", afterPropa)

        lSleep(g_raplakDelay, beforePropa)

        DllCall("QueryPerformanceCounter", "Int64*", beforeRaplak)
        SendInput, {Blind}{%shootKey%}
        Sleep 4000

        UpdateTimer(beforePropa, beforeRaplak)
        lSleep(14700, beforeRaplak)
        
        GuiControl, gui_debug:Text, DebugText, paused
        Hotkey, *%IncreaseTimeKey%, off
        Hotkey, *%DecreaseTimeKey%, off

        lSleep(15300, beforeRaplak)

        Hotkey, *%IncreaseTimeKey%, on
        Hotkey, *%DecreaseTimeKey%, on

        lSleep(g_cooldown, beforeRaplak)
        UpdateTimer(beforeRaplak)
    }
    beforePropa := 0, afterPropa := 0
    beforeRaplak := 0
return

IncreaseTime:
    if (g_desiredLimb > 300)
        return

    g_desiredLimb += g_step
    g_cooldown += g_step

    limbText := Format("{1:.3f}", g_desiredLimb * 0.001)
    ui[2].edit_text("T2", g_cooldown)
    ui[2].edit_text("T3", limbText)
return

DecreaseTime:
    if (g_desiredLimb - g_step < -150)
        return

    g_desiredLimb -= g_step
    g_cooldown -= g_step

    limbText := Format("{1:.3f}", g_desiredLimb * 0.001)
    ui[2].edit_text("T2", g_cooldown)
    ui[2].edit_text("T3", limbText)
return

EnergyDrain:
    SendInput, {Blind}{%shiftKey% Down}
    lSleep(10)
    
    Loop, 18
    {
        SendInput, {Blind}{%jumpKey%}
        SendInput, {Blind}{%shootKey%}
        lSleep(12)
    }
    SendInput, {Blind}{%shiftKey% Up}
return

WaterShield:
    startX  := 0
    startY  := gScreen[2] * 0.45
    endX    := gScreen[1] * 0.35
    endY    := gScreen[2] - startY - 20

    loop
    {
        PixelSearch,,, startX, startY, endX, endY, 0xB51715, 15, Fast RGB ; 0xAD3932
    }
    until (ErrorLevel == 0)

    BlockInput, On

    GoSub, Shard
    SetTimer, Shard, 10
    
    lSleep(g_waterShieldDelay)

    ; MID portal part
    DllCall("QueryPerformanceCounter", "Int64*", beforePropa)
    SendInput, {Blind}{%shoot2Key%}

    MouseMove(-408 , 204)
    lSleep(525, beforePropa)

    ; CL portal part
    DllCall("QueryPerformanceCounter", "Int64*", beforePropa)
    SendInput, {Blind}{%shoot2Key%}

    MouseMove(929, 42)
    lSleep(580, beforePropa)

    ; CR portal part
    DllCall("QueryPerformanceCounter", "Int64*", beforePropa)
    SendInput, {Blind}{%shoot2Key%}

    MouseMove(-1087 , -9)
    lSleep(275, beforePropa)

    ; UNSTUCK part
    SetTimer, Shard, Off
    SendInput, {Blind}{%chatKey%}
    lSleep(15)
    SendInput, {Text}/unstuck
    lSleep(15)
    SendInput, {Enter}
    lSleep(520, beforePropa)

    ; LONG spawn part
    DllCall("QueryPerformanceCounter", "Int64*", beforePropa)
    SendInput, {Blind}{%shoot2Key%}
    SendInput, {Blind}{%meleeKey%}

    MouseMove(-887 , 490)
    lSleep(20, beforePropa)
    SendInput, {Blind}{%emoteKey%}

    SendInput, {Blind}{%aimKey% Down}
    lSleep(100, beforePropa)

    Loop, 35
    {
        SendInput, {Blind}{%shootKey%}
        lSleep(10)
    }
    SendInput {%aimKey% Up}

    BlockInput, OFF
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Shard:
    SendInput, {Blind}{%useKey%}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive
*Insert::reload
*Del::exitapp

*F11::
    suspend, toggle
    state := A_IsSuspended ? "pause" : "lazy"
    ui[1].edit_text("T1", state)
return
