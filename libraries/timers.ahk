global Frequency
Process, Priority,, A
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Lumi                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lSleep(s_time, ByRef start = "") {
    ; Critical
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    if (start != "")
        CounterBefore := start
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    if (s_time > 20) {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        ; Critical Off
        Sleep % s_time - (1000 * (CounterAfter - CounterBefore) / Frequency) - 20
    }
    ; Critical
    End := (CounterBefore + ( Frequency * (s_time/1000))) - 1
    loop
    {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        if (End <= CounterAfter)
            break
    }
    ; Critical Off
}

; s_time = time in milliseconds to sleep, can be input as a decimal, as accurate as frequency (10 MHz)
; start = optional parameter, should pass in a QPC timestamp as a variable, will sleep to s_time
;         after the the timestamp
;         e.g. lSleep(20, ext) followed by lSleep(40, ext) will only sleep a total 40 ms, not 60 ms
; the return statement returns the time actually slept, will slow down the sleep marginally


MeasureTime(ByRef begin, ByRef end) {
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    return Round(( 1000 * (end - begin) / Frequency), 3)
}

; begin/end = pass in two QPC timestamps as variables, returns a rounded difference, mostly a helper func

HoldKey(keyName, duration, wait := 0) {
    SendInput {%keyName% down}
    lSleep(duration)
    SendInput {%keyName% up}
    lSleep(wait)
    return
}

; keyName = should be a key name or vk code that AHK recognizes
; duration = how long in milliseconds the key should be held
; wait = optional parameter, will sleep after the key release (useful for archwing movement)

TimedKeyLoop(keyName, timeBetweenInputs, endTime, ByRef start := "") {
    start ? start : DllCall("QueryPerformanceCounter", "Int64*", start)
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    tkl_end := (start + ( Frequency * (endTime/1000))) - 1
    loop {
        SendInput {%keyName%}
        DllCall("QueryPerformanceCounter", "Int64*", tkl_sleep)
        tkl_sleep_end := (tkl_sleep + ( Frequency * (timeBetweenInputs/1000))) - 1
        loop {
            DllCall("QueryPerformanceCounter", "Int64*", tkl_sleep_time)
            if (tkl_end < tkl_sleep_time) 
                break 2 
            (tkl_sleep_end < tkl_sleep_time) ? break : lSleep(0.3, tkl_sleep_time)
        }
        until (tkl_sleep_end < tkl_sleep_time)
        DllCall("QueryPerformanceCounter", "Int64*", tkl_time)
    }
    until (tkl_end < tkl_time)
    return
}

; presses a key at desired interval for desired duration 
;
; keyName = should be a key name or vk code that AHK recognizes
; timeBetweenInputs = time between the key presses
; endTime = how long in milliseconds the macro will loop for
; start = see the start variable in lsleep

/*
F1::
DllCall("QueryPerformanceCounter", "Int64*", Before)

;insert code here

DllCall("QueryPerformanceCounter", "Int64*", After)
MsgBox % 1000 * (After - Before) / Frequency
return
*/

; used to check duration of a macro, leave it commented out just copy paste it somewhere else