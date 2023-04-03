#include %A_AppData%\LazyHub\lib
#include headers.ahk
#include game_settings.ahk

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
Return

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

    if InGameChat
    {
        if shouldAltTab
            WinActivate, ahk_id %winId%  
    }

    Sleep cooldownInSec * 1000
    WinGet, winId ,, A

    loop
    {
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
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*Insert::reload