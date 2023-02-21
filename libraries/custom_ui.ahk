DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

class GuiObject {
    __new(name, pos_x, pos_y, ui_width, ui_height, ui_theme, no_background := false)
    {
        this.name := name
        this.x := pos_x
        this.y := pos_y
        this.w := ui_width
        this.h := ui_height
        this.theme := ui_theme

        Gui % this.name ": +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwnd" this.name
        Gui % this.name ": Margin", 0, 0
        Gui % this.name ": Color", % this.theme.winBG
        WinSet, Transparent, % no_background ? 0 : this.theme.alpBG

        Gui % this.name "txt: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwndtxt" this.name
        Gui % this.name "txt: Margin", 0, 0
        Gui % this.name "txt: Color", 0x000000
        Winset, Transcolor, 0x000000

        return this
    }

    show()
    {
        Gui % this.name ": Show", %  "x" this.x " y" this.y " w" this.w " h" this.h " NoActivate"
        Gui % this.name "txt: Show", %  " x" this.x+2 " y" this.y+2 " w" this.w-4 " h" this.h-4 " NoActivate"
    }

    hide()
    {
        Gui % this.name ": Hide"
        Gui % this.name "txt: Hide"
    }

    __call(method, args*)
    {
        if !ObjHasKey(this.base, method)
            throw exception("Method does not exist", -1, method)
    }

    __delete()
    {
        Gui % this.name ": Destroy"
        Gui % this.name "txt: Destroy"
    }
}

class Window extends GuiObject {
    __new(name, pos_x, pos_y, ui_width, ui_height, ui_theme, ui_outline := 0, no_background := false)
    {
        base.__new(name, pos_x, pos_y, ui_width, ui_height, ui_theme, no_background)
        static controls := []

        this.no_bg := no_background
        this.outline := ui_outline
        this.outline_list := []
        this.o_pos := []
        this.thickness := 2

        if ui_outline != 0
        {
            outline_colors := {winBG: ui_theme.winOL, alpBG: ui_theme.alpOL}

            if ceil(ui_outline) = -1
            {
                this.o_pos.push([pos_x, pos_y+ui_height-this.thickness, ui_width, this.thickness])
                this.outline_list.push(new GuiObject(name "_ol_1", this.o_pos[1][1], this.o_pos[1][2], this.o_pos[1][3], this.o_pos[1][4], outline_colors))
            }

            if ceil(ui_outline) = 1
            {
                this.o_pos.push([pos_x, pos_y, ui_width, this.thickness])
                this.outline_list.push(new GuiObject(name "_ol_1", this.o_pos[1][1], this.o_pos[1][2], this.o_pos[1][3], this.o_pos[1][4], outline_colors))
            }
            
            if abs(ceil(ui_outline)) = 2
            {
                this.o_pos.push([pos_x, pos_y, this.thickness, ui_height])
                this.o_pos.push([pos_x+ui_width-this.thickness, pos_y, this.thickness, ui_height])

                loop, 2
                    this.outline_list.push(new GuiObject(name "_ol_" A_Index, this.o_pos[A_Index][1], this.o_pos[A_Index][2], this.o_pos[A_Index][3], this.o_pos[A_Index][4], outline_colors))
            }

            if abs(ceil(ui_outline)) > 2
            {
                this.o_pos.push([pos_x, pos_y, ui_width, this.thickness])
                this.o_pos.push([pos_x, pos_y+this.thickness, this.thickness, ui_height-this.thickness*2])
                this.o_pos.push([pos_x+ui_width-this.thickness, pos_y+this.thickness, this.thickness, ui_height-this.thickness*2])
                this.o_pos.push([pos_x, pos_y+ui_height-this.thickness, ui_width, this.thickness])
                
                loop, 4
                    this.outline_list.push(new GuiObject(name "_ol_" A_Index, this.o_pos[A_Index][1], this.o_pos[A_Index][2], this.o_pos[A_Index][3], this.o_pos[A_Index][4], outline_colors))
            }
        }

        return this
    }

    new_text(control_name, body, align, category, my_color := 0xFFFFFF)
    {
        fontName := this.theme[category]
        fontSize := this.theme[category "SZ"]

        if my_color != 0xFFFFFF
            fontColor := my_color
        else
            fontColor := this.theme[category "Col"]

        StringLower, align, align
        StringLower, category, category

        alignPresets := ["auto", "right", "left"]
        if align = % alignPresets[1]
            align := alignPresets[1]  := "center"
        
        flag := false
        for key, val in alignPresets
            if align = % val
            {
                flag := true
                break
            }
        
        if !flag
        {
            presetCorrection := align
            align := "center"
        } else
            presetCorrection := "xs" 
        

        Gui % this.name "txt: Font", % "s" fontSize " q4", % fontName
        Gui % this.name "txt: Add",% "Text",% " +"align " " presetCorrection " w" this.w-4 " Hwnd"control_name " c" fontColor, % body
        this.controls[control_name] := %control_name%
    }

    edit_text(control_name, new_text)
    {
        GuiControl % this.name "txt:", % this.controls[control_name], % new_text
    }

    edit_theme(new_theme)
    {
        this.hide()
        this := this.__new(this.name, this.x, this.y, this.w, this.h, new_theme, this.outline, this.no_bg)
        this.show()
    }

    show()
    {
        base.show()

        if ui_outline != 0
            loop % this.outline_list.length()
            {
                this.outline_list[A_Index].show()
            }
    }

    hide()
    {
        base.hide()

        if ui_outline != 0
            loop % this.outline_list.length()
            {
                this.outline_list[A_Index].hide()
            }
    }

    __delete()
    {
        Gui % this.name ": Destroy"
        Gui % this.name "txt: Destroy"

        if ui_outline != 0
            loop % this.outline_list.length()
            {
                this.outline_list[A_Index].__delete()
            }
    }
}