global G := {}
global ui_theme := {}

ui_theme.insert("winOL", "ADADAD")
ui_theme.insert("alpOL", 255)
ui_theme.insert("winBG", "151515")
ui_theme.insert("alpBG", 180)

ui_theme.insert("title", "Montserrat Medium")
ui_theme.insert("titleCol", "86C8BC")
ui_theme.insert("titleSZ", 13)

ui_theme.insert("main", "Montserrat Medium")
ui_theme.insert("mainCol", "White")
ui_theme.insert("mainSZ", 13)

ui_theme.insert("info", "Montserrat Medium")
ui_theme.insert("infoCol", "FFF6BD")
ui_theme.insert("infoSZ", 13)

#include %A_AppData%\LazyHub\lib

#include headers.ahk
#include game_settings.ahk

#include timers.ahk
#include utils.ahk
#include custom_ui.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Globals               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global curVoltSetup := "volt"
global voltSetups := {}

voltSetups.item["volt"] := {"duration": 172, "strength": 309}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Binds                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RapidFireKey            = F4
CastVoltSkillsKey       = F1
dpsModeKey              = F2
ThrowMeleeKey           = XButton2 		
VasarinDashKey          = q
FasterArchwingKey       = c

; Technical part
global voltInfo := SetupVoltBuild(curVoltSetup)

#IfWinActive ahk_exe Warframe.x64.exe
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%CastVoltSkillsKey%, CastVoltSkills
Hotkey, *%RapidFireKey%, RapidFire 
Hotkey, *%ThrowMeleeKey%, ThrowMelee
Hotkey, *%VasarinDashKey%, VasarinDash
Hotkey, *%FasterArchwingKey%, FasterArchwing
Hotkey, *%dpsModeKey%, dpsMode
Hotkey, ~*%secondAKey%, ManualSpeed
Hotkey, ~*%fourthAKey%, ManualEclipse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             GUI Settings            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []
global timers := {"speed": 0, "eclipse": 0}

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ui.push(new Window("pt_title", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui.push(new Window("pt_body", gPosX, gPosY+ui[1].h+4, gGuiW, gGuiH*2, ui_theme, 3.132))

ui[1].new_text("T1", "P.T", "auto", "title")
ui[2].new_text("T2", "speed", "xs ym+3", "main")
ui[2].new_text("T3", "eclipse", "xs ym+24", "info")

loop, 2
    ui[A_Index].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Funcs                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RapidFire:
    loop
        if ( GetKeyState(RapidFireKey, "P") )
        {
            SendInput {Blind}{LButton}
            lSleep(25)
        }
    else
        break
return

ThrowMelee:
	SendInput {Blind}{%jumpKey%}
	lSleep(25)
	SendInput {Blind}{%jumpKey%}
	lSleep(25)
	SendInput {Blind}{%aimKey% Down}
	lSleep(25)
	SendInput {Blind}{%meleeKey%}
	lSleep(25)
	SendInput {Blind}{%aimKey% Up}
	lSleep(500)
return

VasarinDash:
    SendInput {Blind}{%operatorKey%}
    lSleep(200)

    HoldKey(aimKey, 20)
    
    SendInput {Blind}{%crouchKey% Down}
        lSleep(200)
        SendInput {Blind}{%sKey% Down}
            lSleep(20)
            SendInput {Blind}{%jumpKey%}
            lSleep(100)
        SendInput {Blind}{%sKey% Up}
        lSleep(minSleepTime)
    SendInput {Blind}{%crouchKey% Up}

    lSleep(minSleepTime)
    HoldKey(aimKey, 20)
    lSleep(minSleepTime)

    GoSub, BackToWarframe
return

CastVoltSkills:
    Critical
    BlockInput On

    SendInput {Blind}{%energyPadKey%}
    lSleep(50)

    timers["speed"] := 1
    SendInput {Blind}{%secondAKey%}
    SetTimer, UpdateSpeed, 1000

    Sleep 300

    timers["eclipse"] := 1
    SendInput {Blind}{%fourthAKey%}
    SetTimer, UpdateEclipse, 1000

    BlockInput Off
    Critical Off
return

FasterArchwing:
    Critical
    BlockInput On

    SendInput, {Blind}{%energyPadKey%}
    lSleep(5)
    SendInput, {Blind}{2} ; 2nd volt skill
    lSleep(5)
    SendInput, {Blind}{%archwingKey%}
    
    BlockInput Off
    Critical Off
    lSleep(1500)
return

dpsMode:
    
return

BackToWarframe:
    lSleep(1)
    
    SendInput, {Blind}{%meleeKey%}
    lSleep(60)
    GoSub, AnimationSkip
return

AnimationSkip:
    SendInput, {Blind}{%emoteKey%}
    lSleep(1)
    SendInput, {Blind}{%shootKey%}
    lSleep(1)
    SendInput, {Blind}{%shootKey%}
    lSleep(20)
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Timers                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ManualSpeed:
    timers["speed"] := 1
    SetTimer, UpdateSpeed, 1000
return

ManualEclipse:
    timers["eclipse"] := 1
    SetTimer, UpdateEclipse, 1000
return

UpdateSpeed:
    timers["speed"] += 1
    timeDisplay := voltInfo["speed_dur"] - timers["speed"]
    if (timeDisplay <= 0)
    {
        SetTimer, UpdateSpeed, Delete
        ui[2].edit_text("T2", "speed")
        return
    }
    ui[2].edit_text("T2", timeDisplay)
return

UpdateEclipse:
    timers["eclipse"] += 1
    timeDisplay := voltInfo["eclipse_dur"] - timers["eclipse"]
    if (timeDisplay <= 0)
    {
        SetTimer, UpdateEclipse, Delete
        ui[2].edit_text("T3", "eclipse")
        return
    }
    ui[2].edit_text("T3", timeDisplay)
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Utils                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetupVoltBuild(build_name) {
    buildDur := voltSetups.item[build_name]["duration"]
    buildStr := voltSetups.item[build_name]["strength"]

    return {"speed_dur": ceil(buildDur*12/100), "eclipse_dur": ceil(buildDur*25/100)}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive
*Insert::reload
*Del::exitapp

*F11::
    suspend, toggle
    state := A_IsSuspended ? "pause" : "P.T"
    ui[1].edit_text("T1", state)
return