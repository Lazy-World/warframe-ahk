; Accurate values
global minSleepTime := Clamp(Round(1000 / fps), 1, 60)

global gScreen := Array( Ceil(A_ScreenWidth), Ceil(A_ScreenHeight) )
global gScreenCenter := Array( Ceil(A_ScreenWidth / 2), Ceil(A_ScreenHeight / 2) )

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
    ScaledX := move_x * 1920 / gScreen[1]
    ScaledY := move_y * 1080 / gScreen[2]
    DllCall("mouse_event", "UInt", 0x01, "Int", ScaledX, "Int", ScaledY, "UInt", 0, "Int", 0)
    return
}
