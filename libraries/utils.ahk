; Excludes stupid values' usage
Clamp(num, min, max) 
{
    return num > max ? max : num < min ? min : num
}

ResetCursor()
{
    Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
}

MouseMove(move_x, move_y) 
{
    DllCall("mouse_event", "UInt", 0x01, "Int", move_x, "Int", move_y, "UInt", 0, "Int", 0)
    return
}

; Accurate values
minSleepTime := Clamp(Round(1000 / fps), 1, 60)

gScreen := Array( Ceil(A_ScreenWidth), Ceil(A_ScreenHeight) )
gScreenCenter := Array( Ceil(A_ScreenWidth / 2), Ceil(A_ScreenHeight / 2) )