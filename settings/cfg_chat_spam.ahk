; @Tooltip Запускает макрос и начинает спамить в чат
; @Bind
ChatSpamKey = F2 ; Enable chat spam

; @Tooltip Список сообщений, которые макрос будет отправлять в чат
; @Array
textToSend = ["Cat :poop: 1", "Cat :poop: 2", "Cat :poop: 3"] ; Messages

; @Tooltip Время между отправленными сообщениями
; @Value
cooldownInSec := 2 ; Delay between messages (sec)

; @Tooltip Включите если вы стоите на отбитре
; @Boolean
IsInOrbiter := False ; Orbiter

; @Tooltip Включите если вы хотите спамить в игре
; @Boolean
IsWarframeChat := True ; Warframe chat

; @Tooltip Сворачиваться в игру для отправления сообщения
; @Boolean
shouldAltTab := True ; Focus on Warframe

; @Title Misc

; @Tooltip Перезагрузка макроса
; @Bind
MiscReloadMacroKey = Insert ; Reload macros

; @Tooltip Выключить макрос
; @Bind
MiscUnloadMacroKey = Del ; Unload macros