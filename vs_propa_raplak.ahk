#include %A_AppData%\LazyHub\libraries

global g_uiTheme := {}

g_uiTheme.insert("winOL", "879CD4")
g_uiTheme.insert("alpOL", 255)
g_uiTheme.insert("winBG", "151515")
g_uiTheme.insert("alpBG", 170)

g_uiTheme.insert("title", "Helvetica")
g_uiTheme.insert("titleCol", "ff68b5")
g_uiTheme.insert("titleSZ", 13)

g_uiTheme.insert("menu_icon", "menu_font")
g_uiTheme.insert("menu_iconCol", "f7f2d2")
g_uiTheme.insert("menu_iconSZ", 15)

g_uiTheme.insert("main", "Helvetica")
g_uiTheme.insert("mainCol", "White")
g_uiTheme.insert("mainSZ", 13)

g_uiTheme.insert("accent", "Helvetica")
g_uiTheme.insert("accentCol", "FFF6BD")
g_uiTheme.insert("accentSZ", 13)

g_uiTheme.insert("bullet", "bullet")
g_uiTheme.insert("bulletCol", "f7f2d2")
g_uiTheme.insert("bulletSZ", 14)

g_uiTheme.insert("tech", "JetBrains Mono")
g_uiTheme.insert("techCol", "White")
g_uiTheme.insert("techSZ", 13)

g_uiTheme.insert("debug", "Small Fonts")
g_uiTheme.insert("debugCol", "White")
g_uiTheme.insert("debugSZ", 5)

g_uiTheme.insert("debug_w", "Small Fonts")
g_uiTheme.insert("debug_wCol", "f2af50")
g_uiTheme.insert("debug_wSZ", 5)

#include headers.ahk
#include game_settings.ahk

#include timers.ahk
#include ui.ahk
#include utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include settings\cfg_%A_Scriptname%

global g_cooldown := 17186 - g_propaExplodeTime  + g_desiredLimb

Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro
Hotkey, *%MiscPauseMacroKey%, MiscPauseMacro

; Technical part
#IfWinActive ahk_exe Warframe.x64.exe
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hotkeys := {  "AntiDesync": AntiDesyncKey
            , "EnergyDrain": EnergyDrainKey
            , "IncreaseTime": IncreaseTimeKey
            , "DecreaseTime": DecreaseTimeKey

            , "FasterArchwing": FasterArchwingKey
            , "ConsoleHack": ConsoleHackKey }

for hotkeyFunction, hotkeyCombination in hotkeys {
    Hotkey, *%hotkeyCombination%, %hotkeyFunction%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             UI Settings             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global gPosX := Ceil(gScreen[1] * 0.0066)
global gPosY := Ceil(gScreen[2] * 0.47)
global gRowH := 25

global header_pos       := new Vector(gPosX, gPosY)
global header_size      := new Vector(120, 22)

global body_pos         := header_pos.add(0, header_size.y + 4)
global body_size        := new Vector(header_size.x, gRowH)

global ind_pos          := new Vector(gPosX, gScreen[2] - 260 - 8 - gRowH*3)
global ind_size         := new Vector(body_size.x, gRowH)

global warnUi_pos       := new Vector(gScreenCenter[1], gScreen[2] * 0.53)
global warnUi_size      := new Vector(30, 25)
global warnIcon_size    := new Vector(20, 19)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                  UI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ui          := new Ui(g_uiTheme)
ui_ind      := new Ui(g_uiTheme)
ui_warn     := new Ui(g_uiTheme)

header      := ui.new_window("header", header_pos, header_size, {"margin": 2, "blur": 1, "border": 0, "ol": [0, 1, 0, 0]})
body        := ui.new_window("body", body_pos, body_size, {"blur": 1, "border": 0, "ol": [0, 0, 0, 1]})
ind         := ui_ind.new_window("ind", ind_pos, ind_size, {"blur": 1, "border": 1, "ol": "corner"})
warnUi      := ui_warn.new_window("lang_warn", warnUi_pos, warnUi_size, {"blur": 1, "alpha": 115})

pic_warn    := new Picture("pic_warn", "warn.png", warnUi_pos.add(5, 3), warnIcon_size, {"alpha": 255})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               UI Text               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header.new_text("T1", "D", "menu_icon", "auto")

body.new_text("T2_1", "Limb", "main", "left ys xs xm+10")
body.new_text("T2_2", Format("{1:.3f}", g_desiredLimb * 0.001), "accent", "xs ys xp+15")
body.new_text("T2_3", "", "bullet", "xs ys xm ym+22")

ind.new_slider("S1", new Vector(31, 5), new Vector(body_size.x - 40, 7), 0, g_TerrySpawn, 0)
ind.new_text("T3_1", "AD", "tech", "left ys xs xm+5") ; WS - Water Shield
ind.new_text("T3_2", "NEXT: ", "debug", "left ys xs xm+30 ym+11")
ind.new_text("T3_3", "TERRY", "debug_w", "left ys xs xm+59 ym+11")

warnUi.new_text("T4", "", "main", "left ys xs ym+0 xm+" . warnIcon_size.x+11, {"fit_x": 1})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               UI Misc               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global body_S1 := ind.slider("S1")

SetTimer, WarnCheck, 979

ui.show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Funcs                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AntiDesync:
    oldBodySize := body_size.y
    newBodySize := body_size.y + gRowH

    body.new_size(body_size.x, newBodySize)
    body.edit_text("T2_3", "AAAAA")

    ui_ind.show()
    GoSub, AntiDesyncLoop
    ui_ind.hide()

    body.new_size(body_size.x, oldBodySize)
return 

EnergyDrain:
    SendInput {Blind}{%secondAKey%}
    SendInput {Blind}{%shiftKey% Down}
    lSleep(10)
    
    Loop, 18
    {
        SendInput {Blind}{%jumpKey%}
        SendInput {Blind}{%shootKey%}
        lSleep(12)
    }
    SendInput {Blind}{%shiftKey% Up}

    if (g_energyPadTablet)
        SendInput {Blind}{%energyPadKey%} 
return

IncreaseTime:
    if (g_desiredLimb > 300)
        return

    g_desiredLimb += g_step
    g_cooldown += g_step

    limbText := Format("{1:.0f}", g_desiredLimb)
    body.edit_text("T2_2", limbText)
return

DecreaseTime:
    if (g_desiredLimb - g_step < -150)
        return

    g_desiredLimb -= g_step
    g_cooldown -= g_step

    limbText := Format("{1:.0f}", g_desiredLimb)
    body.edit_text("T2_2", limbText)
return

FasterArchwing:
    Critical
    BlockInput On

    if (g_fasterArchwingTablet)
    {
        SendInput {Blind}{%energyPadKey%}
        lSleep(minSleepTime)
    }

    SendInput {Blind}{%secondAKey%} ; 2nd volt skill
    lSleep(minSleepTime)
    SendInput {Blind}{%archwingKey%}

    BlockInput Off
    Critical Off

    lSleep(1500) ; Archwing recharge time
return

ConsoleHack:
    BlockInput On

    SendInput {Blind}{%aimKey% Down}
    lSleep(25)
        TimeStamp(blink)
        SendInput {Blind}{%shiftKey%}
    lSleep(minSleepTime)

    lSleep(100) ; blink time
    SendInput {Blind}{%aimKey% Up}

    loop, 3
    {
        SendInput {Blind}{%useKey%}
        lSleep(30)
        SendInput {Blind}{%hackKey%}
        lSleep(50)
    }

    lSleep(1500, blink)
    BlockInput Off
return

AntiDesyncLoop:
    loop % 5
    {
        TimeStamp(beforePropa)
        SendInput {Blind}{%shoot2Key%}

        lSleep(5)
        SendInput {Blind}{%secondAKey%}
        
        ind.edit_text("T3_3", "RAPLAK")
        body_S1.run({"max": g_propaExplodeTime, "ext": beforePropa})
        body_S1.set(g_propaExplodeTime)
        
        TimeStamp(limb)
        SendInput {Blind}{%shootKey%}

        body.edit_text("T2_3", StrRepeat("A", 5 - A_Index))
        
        if A_Index = 5
            break

        ind.edit_text("T3_3", "DRAIN")
        body_S1.run({"max": 12500})
        body_S1.set(12500)

        GoSub, EnergyDrain

        ind.edit_text("T3_3", "PROPA")
        body_S1.run({"max": g_cooldown, "ext": limb})
        body_S1.set(g_cooldown)
    }
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WarnCheck:
    if (not g_enableWarnings)
        return
    
    scriptStabilityState := []
    
    warnUi_size.x := 30
    warnUi_pos.x := gScreenCenter[1]

    str := ""
    sep := ", "

    if !LangID := GetKeyboardLanguage()
    {
        scriptStabilityState.push("IRAQ")
    } else {
        if (LangID != 0x0409) ; if not english
            scriptStabilityState.push("EN")
    }

    if GetKeyState("CapsLock","T")
        scriptStabilityState.push("CAPS")

    if scriptStabilityState.length() = 0
    {
        ui_warn.hide()
        pic_warn.hide()
        oldStr := ""
        return
    }

    for index, param in scriptStabilityState
        str .= sep . param
    str := SubStr(str, StrLen(sep)+1)

    if (str == oldStr)
        return

    warnUi.edit_text("T4", str)
    oldStr := str
    
    curWidth := warnUi_size.x + warnUi.text().measure("T4")[1] + 10
    newX := warnUi_pos.x - curWidth // 2

    warnUi.new_pos(newX, warnUi_pos.y)
    pic_warn.pos.x := newX + 5
    oldX := warnUi_pos.x

    warnUi.new_size(curWidth, warnUi_size.y)
    oldWidth := warnUi_size.x

    pic_warn.show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive

MiscReloadMacro:
    reload
return

MiscUnloadMacro:
    exitapp
return

MiscPauseMacro:
    suspend, toggle

    if A_IsSuspended
        mainText := header.text().get_control("T1")["body"]

    state := A_IsSuspended ? "suspended" : mainText
    header.edit_text("T1", state)
return
