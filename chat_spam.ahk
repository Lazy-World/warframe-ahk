#include %A_AppData%\LazyHub\lib
#include headers.ahk
#include game_settings.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Globals               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
textToSend := [     "Cat :poop: 1"
                ,   "Cat :poop: 2"
                ,   "Cat :poop: 3"]
cooldownInSec := 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Macros                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChatSpamKey = F2
InGameChat := True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%ChatSpamKey%, ChatSpam
Return

ChatSpam:
    SendInput % textToSend[1] "{Enter}"
    Sleep cooldownInSec * 1000

    loop
    {
        if InGameChat
        {
            SendInput % chatKey
            Sleep 50
        }
        
        SendInput % textToSend[mod(A_Index, textToSend.Length())+1] "{Enter}"
        Sleep cooldownInSec * 1000
    }
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*Insert::reload