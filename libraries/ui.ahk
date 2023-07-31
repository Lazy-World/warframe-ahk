DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

NonNull_Ret(var, DefaultValue, MinValue:="", MaxValue:="") {
	return, var="" ? DefaultValue : MinValue="" ? (MaxValue="" ? var : Min(var, MaxValue)) : (MaxValue!="" ? Max(Min(var, MaxValue), MinValue) : Max(var, MinValue))
}

ArraysEqual(arr1, arr2) {
    if (arr1.Length() != arr2.Length())
        return false
    for idx, val in arr1
        if (IsObject(val) && IsObject(arr2[idx])) {
            if (!ArraysEqual(val, arr2[idx]))
                return false
        } else if (val != arr2[idx])
            return false
    return true
}

class Vector {
    __new(vec_x, vec_y) {
        this.x := vec_x
        this.y := vec_y

        return this
    }

    add(params*) {
        if (params.Length() == 1) {
            other := params[1]
            return new Vector(this.x + other.x, this.y + other.y)
        } else if (params.Length() == 2) {
            x := params[1]
            y := params[2]
            return new Vector(this.x + x, this.y + y)
        } else {
            return new Vector(0, 0)
        }
    }

    swap() {
        return new Vector(this.y, this.x)
    }
}

class Text {
    __new(name, vec_pos, vec_size, theme, Config := "")
    {
        static controls := {}

        this.name := "txt_" + name
        this.pos := vec_pos
        this.size := vec_size
        this.theme := theme

        this.mtl := NonNull_Ret(Config.margin, 2) ; margin top left
        this.mbr := this.mtl + this.mtl ; margin bottom right

        Gui % this.name ": +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwnd"myHwnd
        Gui % this.name ": Margin", 0, 0
        Gui % this.name ": Color", 0x000000
        Winset, Transcolor, 0x000000  
    }

    new_text(control_name, body, category, prop := "") {
        StringLower, category, category
        StringLower, prop, prop

        prop := Trim(prop)
        
        if (prop = "")
            prop := "center xs ym0"
        else if (prop = "auto")
            prop := "center xs ym0"
        else if (prop = "left")
            prop := "left xs ym0"
        else if (prop = "right")
            prop := "right xs ym0"
        else if (RegExMatch(prop, "auto"))
            prop := RegExReplace(prop, "auto", "center")
        else if (!RegExMatch(prop, "(\+?center|\+?left|\+?right)"))
            prop := "center " . prop

        fontName := this.theme[category]
        fontSize := this.theme[category "SZ"]
        fontColor := this.theme[category "Col"]

        Gui % this.name ": Font", % "s" fontSize " q4", % fontName
        Gui % this.name ": Add",% "Text", % " " prop " w" this.size.x-this.mbr " BackgroundTrans 0x200 Hwnd"control_name " c" fontColor, % body
        this.controls[control_name] := {"control": %control_name%, "body": body, "font": fontName, "fontSZ": fontSize, "fontCol": fontColor}
    }

    edit_text(control_name, new_text) {
        GuiControl % this.name ":", % this.controls[control_name]["control"], % new_text
    }

    get_size(control_name) {
        WinGetPos, , , width, height, % "ahk_id " this.controls[control_name]["control"]
        return [width, height]
    }

    get_control(name) {
        return this.controls[name]
    }

    measure(control_name) {
        textBody := this.controls[control_name]["body"]
        fontName := this.controls[control_name]["font"]
        fontSize := "s" . this.controls[control_name]["fontSZ"]
        
        Static DT_FLAGS := 0x0520 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400
        Static WM_GETFONT := 0x31

        Gui, New

        If (fontSize <> "") || (FontName <> "")
            Gui, Font, %fontSize%, %FontName%

        Gui, Add, Text, hwndHWND
        SendMessage, WM_GETFONT, 0, 0,, ahk_id %HWND%

        HFONT := ErrorLevel
        HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")

        DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
        VarSetCapacity(RECT, 16, 0)

        DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", textBody, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
        DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)

        Gui, Destroy

        width := NumGet(RECT, 8, "Int")
        height := NumGet(RECT, 12, "Int")
        
        return [width+1, height]
    }
        
    new_pos(params*) {
        if (params.Length() == 1) {
            this.pos := params[1]
        } else if (params.Length() == 2) { 
            this.pos.x := params[1]
            this.pos.y := params[2]
        }

        this.show()
    }
    
    move(params*) {
        if (params.Length() == 1) {
            this.pos := this.pos.add(params[1])
        } else if (params.Length() == 2) { 
            this.pos := this.pos.add(new Vector(params[1], params[2]))
        }

        this.show()
    }

    new_size(params*) {
        if (params.Length() == 1) {
            this.size := params[1]
        } else if (params.Length() == 2) { 
            this.size.x := params[1]
            this.size.y := params[2]
        }
    
        for name in this.controls
            GuiControl % this.name ": Move", % this.controls[name]["control"], % "w" this.size.x-this.mbr " h" this.size.y-this.mbr
    
        this.show()
    }
    
    resize(params*) {
        if (params.Length() == 1) {
            this.size := this.size.add(params[1])
        } else if (params.Length() == 2) { 
            this.size := this.size.add(new Vector(params[1], params[2]))
        }
    
        for name in this.controls
        {
            GuiControl % this.name ": Move", % this.controls[name]["control"], % "w" this.size.x-this.mbr " h" this.size.y-this.mbr
        }
    
        this.show()
    }

    show() {
        Gui % this.name ": Show", %  "x" this.pos.x+this.mtl " y" this.pos.y+this.mtl " w" this.size.x-this.mbr " h" this.size.y-this.mbr " NoActivate"
    }

    hide() {
        Gui % this.name ": Hide"
    }

    __delete() {
        Gui % this.name ": Destroy"
    }
}

class Picture {
    __new(ui_name, name, vec_pos, vec_size, Config := "") 
    {
        this.name := ui_name
        this.pos := vec_pos
        this.size := vec_size

        this.bgCol          := NonNull_Ret(Config.color         , 0x151515)
        this.bgAlp          := NonNull_Ret(Config.alpha         , 255)
        this.add_x          := NonNull_Ret(Config.x             , 0)
        this.add_y          := NonNull_Ret(Config.y             , 0)

        myHwnd := this.name
        titleString := "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"

        Gui % this.name ": " titleString " +Hwnd"myHwnd
        Gui % this.name ": Margin", 0, 0
        Gui % this.name ": Color", %  this.bgCol

        if this.bgAlp != 255
            WinSet, Transparent, % this.bgAlp
        else 
            WinSet, TransColor, % this.bgCol

        path =  %A_ScriptDir%\pictures\%name%
        Gui % this.name ": Add", Picture, % " w" this.size.x " h" this.size.y " x" this.add_x " y" this.add_y " AltSubmit BackgroundTrans", % path

        this.hwnd := %myHwnd%
    }

    show() {
        Gui % this.name ": Show", %  "x" this.pos.x " y" this.pos.y " w" this.size.x " h" this.size.y " NoActivate"
    }

    hide() {
        Gui % this.name ": Hide"
    }

    __delete() {
        Gui % this.name ": Destroy"
    }
}

class Line {
    __new(name, vec_pos, vec_size, Config := "")
    {
        this.name := name
        this.pos := vec_pos
        this.size := vec_size

        this.bgCol          := NonNull_Ret(Config.color         , 0x151515)
        this.bgAlp          := NonNull_Ret(Config.alpha         , 255)
        this.border         := NonNull_Ret(Config.border        , 0)
        this.blur           := NonNull_Ret(Config.blur          , 0)
        this.noBG           := NonNull_Ret(Config.no_bg         , 0)

        myHwnd := this.name
        titleString := "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"

        if this.border
            titleString := titleString . " +Border"

        Gui % this.name ": " titleString " +Hwnd"myHwnd
        Gui % this.name ": Margin", 0, 0
        Gui % this.name ": Color", % this.noBG ? 151515 : this.bgCol

        if this.blur
            WinSet, TransColor, 151515
        else 
            WinSet, Transparent, % this.noBG ? 0 : this.bgAlp
        
        this.hwnd := %myHwnd%
    }

    new_pos(params*) {
        if (params.Length() == 1) {
            this.pos := params[1]
        } else if (params.Length() == 2) { 
            this.pos.x := params[1]
            this.pos.y := params[2]
        }

        this.show()
    }
    
    move(params*) {
        if (params.Length() == 1) {
            this.pos := this.pos.add(params[1])
        } else if (params.Length() == 2) { 
            this.pos := this.pos.add(new Vector(params[1], params[2]))
        }

        this.show()
    }
    
    new_size(params*) {
        if (params.Length() == 1) {
            this.size := params[1]
        } else if (params.Length() == 2) { 
            this.size.x := params[1]
            this.size.y := params[2]
        }

        this.show()
    }

    resize(params*) {
        if (params.Length() == 1) {
            this.size := this.size.add(params[1])
        } else if (params.Length() == 2) { 
            this.size := this.size.add(new Vector(params[1], params[2]))
        }

        this.show()
    }

    get_hwnd() {
        return this.hwnd
    }

    _set_blur(hWnd) {
        ;Function by qwerty12 and jNizM (found on https://autohotkey.com/boards/viewtopic.php?t=18823)
      
        ;WindowCompositionAttribute
        WCA_ACCENT_POLICY := 19
       
        ;AccentState
        ACCENT_DISABLED := 0,
        ACCENT_ENABLE_GRADIENT := 1,
        ACCENT_ENABLE_TRANSPARENTGRADIENT := 2,
        ACCENT_ENABLE_BLURBEHIND := 3,
        ACCENT_INVALID_STATE := 4
      
        accentStructSize := VarSetCapacity(AccentPolicy, 4*4, 0)
        NumPut(ACCENT_ENABLE_BLURBEHIND, AccentPolicy, 0, "Uint")
       
        padding := A_PtrSize == 8 ? 4 : 0
        VarSetCapacity(WindowCompositionAttributeData, 4 + padding + A_PtrSize + 4 + padding)
        NumPut(WCA_ACCENT_POLICY, WindowCompositionAttributeData, 0, "UInt")
        NumPut(&AccentPolicy, WindowCompositionAttributeData, 4 + padding, "Ptr")
        NumPut(accentStructSize, WindowCompositionAttributeData, 4 + padding + A_PtrSize, "UInt")
       
        DllCall("SetWindowCompositionAttribute", "Ptr", hWnd, "Ptr", &WindowCompositionAttributeData)
    }

    show() {
        x := this.pos.x + (this.blur && this.border ? -1 : 0)
        y := this.pos.y + (this.blur && this.border ? -1 : 0)
        Gui % this.name ": Show", %  "x" x " y" y " w" this.size.x " h" this.size.y " NoActivate"

        if this.blur 
            this._set_blur(this.hwnd)
    }

    hide() {
        Gui % this.name ": Hide"
    }

    __delete() {
        Gui % this.name ": Destroy"
    }
}

class Slider {
    __new(name, vec_pos, vec_size, min, max, val, Config := "")
    {
        this.name := name
        this.pos := vec_pos
        this.size := vec_size

        this.color          := NonNull_Ret(Config.color         , 0x879CD4) ; 879CD4-blue EA254E-red
        this.bgCol          := NonNull_Ret(Config.bgCol         , 0x191920)
        this.olCol          := NonNull_Ret(Config.olCol         , 0xADADAD)
        this.olAlp          := NonNull_Ret(Config.olAlp         , 255)
        this.border         := NonNull_Ret(Config.border        , 0)
        this.outline        := NonNull_Ret(Config.ol            , [0, 0, 0, 0])
        this.outline_sz     := NonNull_Ret(Config.ol_sz         , 2)

        this.outline_elements := []
        this.min := min
        this.max := max
        this.val := ceil((val - min) / (max - min) * 100)

        for i, val in this.outline
            this.outline[i] := ceil(abs(this.outline[i])) != 0 ? 1 : 0
        this.border := ceil(abs(this.border)) != 0 ? 1 : 0

        myHwnd := this.name
        titleString := "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"

        if this.border
            titleString := titleString . " +Border"

        Gui % this.name ": " titleString
        Gui % this.name ": Margin", 0, 0
        Gui % this.name ": Color", 0xFFFFFF
        WinSet, TransColor, 0xFFFFFF
        Gui % this.name ": Add", Progress, % " x0 y0 w" this.size.x " h" this.size.y " c" this.color  " Background" this.bgCol " +Hwnd"myHwnd, % this.val

        this._draw_outline(vec_pos, vec_size)

        this.hwnd := %myHwnd%
    }

    run(Config := "") {
        this.min            := NonNull_Ret(Config.min           , this.min)
        this.max            := NonNull_Ret(Config.max           , this.max)
        ext                 := NonNull_Ret(Config.ext           , -1)

        DATA := []
        
        if ext != -1
            lostTime := MeasureTime(ext)
        else {
            DllCall("QueryPerformanceCounter", "Int64*", ext)
            lostTime := 0
        }
        
        duration := this.max - this.min - lostTime
        steps := 100

        stepSize := duration / steps
        inc := 1

        while 15.6 >= stepSize
        {
            stepSize := stepSize * 2
            inc := inc * 2
        }

        DATA.push(stepSize)
        DATA.push(inc)

        timerCount := 1
        stepSize := stepSize * 0.94

        SetTimer, tmpLabel, % stepSize
        Critical, On
            lSleep(this.max - this.min, ext)
        Critical, Off
        SetTimer, tmpLabel, Off

        return DATA
        
        tmpLabel:
            timerCount := timerCount + inc
            GuiControl % this.name ":", % this.hwnd, % timerCount
        return
    }

    reset(Config := "") {
        this.min            := NonNull_Ret(Config.min           , this.min)
        this.max            := NonNull_Ret(Config.max           , this.max)

        GuiControl % this.name ":", % this.hwnd, 0
    }

    set(val) {
        new_val := ceil((val - this.min) / (this.max - this.min) * 100)
        GuiControl % this.name ":", % this.hwnd, % clamp(new_val, 0, 100)
    }

    new_pos(new_pos) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []
            this._draw_outline(new_pos, this.size) ; Brain rot
        }

        this.pos := new_pos
        this.show()
    }

    move(add_pos*) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
            for i, element in this.outline_elements
                element.move(add_pos*)

        if (add_pos.Length() == 1) {
            this.pos := this.pos.add(add_pos[1])
        } else if (add_pos.Length() == 2) { 
            this.pos := this.pos.add(new Vector(add_pos[1], add_pos[2]))
        }

        this.show()
    }

    new_size(new_size*) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []
            if (new_size.Length() == 1) {
                this._draw_outline(this.pos, new Vector(new_size.x, this.size.y))
            } else if (new_size.Length() ==2) { 
                this._draw_outline(this.pos, new Vector(new_size[1], this.size.y))
            } 
        }

        if (new_size.Length() == 1) {
            this.size := new Vector(new_size[1].x, this.size.y)
        } else if (new_size.Length() == 2) { 
            this.size.x := new_size[1]
            this.size.y := this.size.y
        }

        Gui % this.name ": Add", Progress, % " x0 y0 w" this.size.x " h" this.size.y " c" this.color  " Background" this.bgCol " +Hwnd" this.hwnd, % this.val
        this.show()
    }

    resize(add_size*) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []
            if (add_size.Length() == 1) {
                this._draw_outline(this.pos, this.size.add(add_size.x, 0))
            } else if (add_size.Length() == 2) { 
                this._draw_outline(this.pos, this.size.add(add_size[1], 0))
            }
        }

        if (add_size.Length() == 1) {
            this.size := this.size.add(add_size[1].x, 0)
        } else if (add_size.Length() == 2) { 
            this.size := this.size.add(add_size[1], 0)
        }

        Gui % this.name ": Add", Progress, % " x0 y0 w" this.size.x " h" this.size.y " c" this.color  " Background" this.bgCol " +Hwnd" this.hwnd, % this.val
        this.show()
    }

    get_hwnd() {
        return this.hwnd
    }

    _draw_outline(vec_pos, vec_size) {
        ol_r := this.outline[1], ol_l := this.outline[3]
        border := this.border ? 1 : 0

        bold := this.outline_sz
        size_w := vec_size.x
        size_h := vec_size.y

        border2 := border * 2
        ol_sum := ol_r + ol_l
        ol_cond := (ol_sum = 2 ? 0 : ol_sum = 0 ? border2 : border)

        layout := [   [vec_pos.add(-bold, -border), new Vector(bold, size_h + border2)] ; right
                    , [vec_pos.add(-bold + (ol_r ? 0 : bold - border), -bold), new Vector(size_w + bold * ol_sum + ol_cond, bold)] ; top
                    , [vec_pos.add(size_w, -border), new Vector(bold, size_h + border2)] ; left
                    , [vec_pos.add(-bold + (ol_r ? 0 : bold - border), size_h), new Vector(size_w + bold * ol_sum + ol_cond, bold)]] ; bottom

        for i, val in this.outline
            if val
                this.outline_elements.push(new Line(this.name "_ol_" A_Index, layout[i][1], layout[i][2], {"color": this.olCol, "alpha": this.olAlp}))
    } 

    show() {
        x := this.pos.x + (this.border ? -1 : 0)
        y := this.pos.y + (this.border ? -1 : 0)
        Gui % this.name ": Show", %  "x" x " y" y " w" this.size.x " h" this.size.y " NoActivate"

        for idx, element in this.outline_elements
            element.show()
    }

    hide() {
        Gui % this.name ": Hide"

        for idx, element in this.outline_elements
            element.hide()
    }

    __delete() {
        Gui % this.name ": Destroy"

        for idx, element in this.outline_elements
            element.__delete()
    }
}

class Window {
    __new(name, vec_pos, vec_size, theme, Config := "")
    {       
        this.name := name
        this.pos := vec_pos
        this.size := vec_size
        this.theme := theme

        no_bg               := NonNull_Ret(Config.no_bg         , 0)
        margin              := NonNull_Ret(Config.margin        , 2)
        this.border         := NonNull_Ret(Config.border        , 0)
        this.blur           := NonNull_Ret(Config.blur          , 0)
        theme.alpBG         := NonNull_Ret(Config.alpha         , theme.alpBG)
        this.bgCol          := NonNull_Ret(Config.bgCol         , theme.winBG)

        this.picture        := NonNull_Ret(Config.pic           , "")
        add_x               := NonNull_Ret(Config.pmx           , 0)
        add_y               := NonNull_Ret(Config.pmy           , 0)

        this.outline_cl     := NonNull_Ret(Config.ol_col        , this.theme.winOL)
        this.outline_al     := NonNull_Ret(Config.ol_alp        , this.theme.alpOL)
        this.outline        := NonNull_Ret(Config.ol            , [0, 0, 0, 0])
        this.outline_sz     := NonNull_Ret(Config.ol_sz         , 2)
        this.outline_len    := NonNull_Ret(Config.ol_len        , ceil(min(vec_size.x, vec_size.y) * 0.22))

        if this.outline != "corner"
            for i, val in this.outline
                this.outline[i] := ceil(abs(this.outline[i])) != 0 ? 1 : 0

        this.border := ceil(abs(this.border)) != 0 ? 1 : 0
        this.outline_len := clamp(this.outline_len, 0, ceil(min(vec_size.x, vec_size.y) * 0.5))

        if this.blur
            this.blur_window := new Line(name "_blur", vec_pos, vec_size, {"color": theme.winBG
                , "alpha": theme.alpBG
                , "no_bg": no_bg
                , "blur": this.blur
                , "border": this.border})

        if this.picture != ""
            this.window := new Picture("pic_" + name, this.picture, vec_pos, vec_size, {"color": theme.winBG, "alpha": theme.alpBG, "x": add_x, "y": add_y})
        else
            this.window := new Line(name, vec_pos, vec_size, {"color": theme.winBG, "alpha": theme.alpBG, "no_bg": no_bg})

        this.text_window := new Text(name, vec_pos, vec_size, theme, {"margin": margin})

        this.outline_elements := []
        this.sliders := {}

        if this.outline != "corner"
            this._draw_outline(vec_pos, vec_size)
        else
            this._draw_corner_outline(vec_pos, vec_size)
    }

    new_slider(name, vec_pos, vec_size, min, max, cur, Config := "") {
        this.sliders[this.name . "_" . name] := new Slider(this.name . "_" . name, this.pos.add(vec_pos), vec_size, min, max, cur, Config)
    }

    new_text(control_name, body, category, prop := "") {
        this.text_window.new_text(control_name, body, category, prop)
    }

    slider(name) {
        return this.sliders[this.name . "_" . name]
    }

    text() {
        return this.text_window
    }

    size() {
        return this.window.size
    }

    controls() {
        return this.text_window.get_controls()
    }

    hwnd() {
        return this.window.get_hwnd()
    }

    edit_text(control_name, new_text) {
        this.text_window.edit_text(control_name, new_text)
    }

    measure(control_name) {
        return this.text_window.measure(control_name)
    }

    new_pos(new_pos*) {
        cur_win_pos := this.pos

        for idx, element in this.sliders
        {
            real_pos := element.pos.add(-cur_win_pos.x, -cur_win_pos.y)
            if (new_pos.Length() == 1) {
                element.new_pos(new_pos[1].add(real_pos))
            } else if (new_pos.Length() == 2) { 
                element.new_pos(new Vector(new_pos[1] + real_pos.x, new_pos[2] + real_pos.y))
            }
        }

        if this.blur
            this.blur_window.new_pos(new_pos*)

        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []

            if this.outline != "corner"
                this._draw_outline(this.window.pos, this.window.size)
            else 
                this._draw_corner_outline(this.window.pos, this.window.size)

            for idx, element in this.outline_elements
                element.show()
        }

        this.window.new_pos(new_pos*)
        this.text_window.new_pos(new_pos*)
    }

    move(add_pos*) {
        if this.blur
            this.blur_window.move(add_pos*)

        if !ArraysEqual(this.outline, [0, 0, 0, 0])
            for i, element in this.outline_elements
                element.move(add_pos*)

        this.window.move(add_pos*)
        this.text_window.move(add_pos*)

        for idx, element in this.sliders
            element.move(add_pos*)
    }

    new_size(new_size*) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []
            if (new_size.Length() == 1) {
                if this.outline != "corner"
                    this._draw_outline(this.window.pos, new_size)
                else
                    this._draw_corner_outline(this.window.pos, new_size)
            } else if (new_size.Length() == 2) { 
                if this.outline != "corner"
                    this._draw_outline(this.window.pos, new Vector(new_size[1], new_size[2]))
                else
                    this._draw_corner_outline(this.window.pos, new Vector(new_size[1], new_size[2]))
            }

            for idx, element in this.outline_elements
                element.show()
        }

        if this.blur
            this.blur_window.new_size(new_size*)

        this.window.new_size(new_size*)
        this.text_window.new_size(new_size*)

        for idx, element in this.sliders
        {
            if (new_size.Length() == 1) {
                element.new_size(new Vector(new_size[1] - (element.pos.x - this.pos.x)*2, new_size[2]))
            } else if (new_size.Length() == 2) { 
                element.new_size(new_size[1] - (element.pos.x - this.pos.x)*2, new_size[2])
            }
            
        }
            
    }

    resize(add_size*) {
        if !ArraysEqual(this.outline, [0, 0, 0, 0])
        {
            this.outline_elements := []
            if (add_size.Length() == 1) {
                if this.outline != "corner"
                    this._draw_outline(this.window.pos, this.window.size.add(add_size.x, add_size.y))
                else
                    this._draw_corner_outline(this.window.pos, this.window.size.add(add_size.x, add_size.y))
            } else if (add_size.Length() == 2) {
                if this.outline != "corner"
                    this._draw_outline(this.window.pos, this.window.size.add(add_size[1], add_size[2]))
                else
                    this._draw_corner_outline(this.window.pos, this.window.size.add(add_size[1], add_size[2]))
            }

            for idx, element in this.outline_elements
                element.show()
        }

        if this.blur
            this.blur_window.resize(add_size*)

        this.window.resize(add_size*)
        this.text_window.resize(add_size*)

        for idx, element in this.sliders
            element.resize(add_size*)
    }

    _draw_outline(vec_pos, vec_size) {
        ol_r := this.outline[1], ol_l := this.outline[3]
        border := this.blur ? this.border  : 0
        
        bold := this.outline_sz
        size_w := vec_size.x
        size_h := vec_size.y
        
        border2 := border * 2
        ol_sum := ol_r + ol_l
        ol_cond := (ol_sum = 2 ? 0 : ol_sum = 0 ? border2 : border)

        layout := [   [vec_pos.add(-bold, -border), new Vector(bold, size_h + border2)] ; right
                    , [vec_pos.add(-bold + (ol_r ? 0 : bold - border), -bold), new Vector(size_w + bold * ol_sum + ol_cond, bold)] ; top
                    , [vec_pos.add(size_w, -border), new Vector(bold, size_h + border2)] ; left
                    , [vec_pos.add(-bold + (ol_r ? 0 : bold - border), size_h), new Vector(size_w + bold * ol_sum + ol_cond, bold)]] ; bottom

        for i, val in this.outline
            if val
                this.outline_elements.push(new Line(this.name "_ol_" A_Index, layout[i][1], layout[i][2], {"color": this.outline_cl, "alpha": this.outline_al}))
    }
    
    _draw_corner_outline(vec_pos, vec_size) {        
        bold    := this.outline_sz
        len     := this.outline_len
        size_w  := vec_size.x
        size_h  := vec_size.y

        layout := [   [vec_pos.add(-bold, 0), new Vector(bold, len)] ; right top
                    , [vec_pos.add(-bold, size_h - len), new Vector(bold, len)] ; right bottom

                    , [vec_pos.add(-bold, -bold), new Vector(len + bold, bold)] ; top left
                    , [vec_pos.add(size_w - len, -bold), new Vector(len + bold, bold)] ; top right

                    , [vec_pos.add(size_w, 0), new Vector(bold, len)] ; left top
                    , [vec_pos.add(size_w, size_h - len), new Vector(bold, len)] ; left bottom

                    , [vec_pos.add(-bold, size_h), new Vector(len + bold, bold)] ; bottom left
                    , [vec_pos.add(size_w - len, size_h), new Vector(len + bold, bold)]] ; bottom right

        for i, val in layout
            this.outline_elements.push(new Line(this.name "_ol_" A_Index, layout[i][1], layout[i][2], {"color": this.outline_cl, "alpha": this.outline_al}))
    } 

    show() {
        if this.blur
            this.blur_window.show()   

        this.window.show()
        this.text_window.show()

        for idx, element in this.outline_elements
            element.show()

        for idx, element in this.sliders
            element.show()
    }

    hide() {
        if this.blur
            this.blur_window.hide()

        this.window.hide()
        this.text_window.hide()

        for idx, element in this.outline_elements
            element.hide()

        for idx, element in this.sliders
            element.hide()
    }

    __delete() {
        this.window.__delete()
        this.text_window.__delete()

        if this.blur
            this.blur_window.__delete()

        for idx, element in this.outline_elements
            element.__delete()

        for idx, element in this.sliders
            element.__delete()
    }
}

class Ui {
    __new(theme, no_bg := false) 
    {
        this.theme := theme
        this.no_bg := no_bg
        this.windows := {}

        return this
    }

    new_window(name, vec_pos, vec_size, Config := "") {
        return this.windows[name] := new Window(name, vec_pos, vec_size, this.theme, Config)
    }

    get_window(name) {
        return this.windows[name]
    }

    show() {
        for name, window_obj in this.windows
            window_obj.show()
    }

    hide() {
        for name, window_obj in this.windows
            window_obj.hide()
    }

    __delete() {
        for name, window_obj in this.windows
            window_obj.__delete()
    }
}