local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(Iris.ShowDemoWindow)

local function recursive()
    -- stylua: ignore start
    if Iris.Menu({ "Recursive" }).state.isOpened.value then
        Iris.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl })
        Iris.MenuItem({ "Open", Enum.KeyCode.O, Enum.ModifierKey.Ctrl })
        Iris.MenuItem({ "Save", Enum.KeyCode.S, Enum.ModifierKey.Ctrl })
        Iris.Separator()
        Iris.MenuToggle({ "Autosave" })
        Iris.MenuToggle({ "Checked" })
        Iris.Separator()
        Iris.Menu({ "Options" })
            Iris.MenuItem({ "Red" })
            Iris.MenuItem({ "Yellow" })
            Iris.MenuItem({ "Green" })
            Iris.MenuItem({ "Blue" })
            Iris.Separator()
            recursive()
        Iris.End()
    end
    Iris.End()
    -- stylua: ignore end
end

Iris:Connect(function()
    -- stylua: ignore start
    Iris.Window({ "Testing Window" })

        Iris.MenuBar()
            Iris.Menu({ "File" })
                recursive()
            Iris.End()
            
            Iris.Menu({ "Edit" })
            Iris.End()

            Iris.Menu({ "View" })
            Iris.End()
        Iris.End()

        if Iris.Button({ "Disable Iris" }).clicked() then
            Iris.Disabled = true
        end

        Iris.InputVector3({ "Dynamic Formatting", 0.05, 0, 1 })

        local NumberState = Iris.State(0)
        local Vector2State = Iris.State(Vector2.zero)
        local Vector3State = Iris.State(Vector3.zero)
        local UDimState = Iris.State(UDim.new())
        local UDim2State = Iris.State(UDim2.new())
        local RectState = Iris.State(Rect.new(0, 0, 960, 960))

        Iris.Text({ tostring(NumberState:get()) })
        Iris.Text({ tostring(Vector2State:get()) })
        Iris.Text({ tostring(Vector3State:get()) })
        Iris.Text({ tostring(UDimState:get()) })
        Iris.Text({ tostring(UDim2State:get()) })
        Iris.Text({ tostring(RectState:get()) })

        local UseFloats = Iris.State(false)
        local UseHSV = Iris.State(false)
        local sharedColor = Iris.State(Color3.new())
        local transparency = Iris.State(0)
        Iris.SliderNum({ "Transparency", 0.01, 0, 1 }, { number = transparency })
        Iris.InputColor3({ "InputColor3", UseFloats:get(), UseHSV:get() }, { color = sharedColor })
        Iris.InputColor4({ "InputColor4", UseFloats:get(), UseHSV:get() }, { color = sharedColor, transparency = transparency })
        Iris.SameLine()
            Iris.Text({ sharedColor:get():ToHex() })
            Iris.Checkbox({ "Use Floats" }, { isChecked = UseFloats })
            Iris.Checkbox({ "Use HSV" }, { isChecked = UseHSV })
        Iris.End()

        Iris.CollapsingHeader("Input")
            Iris.InputNum({ "InputNum" }, { number = NumberState})
            Iris.InputVector2({ "InputVector2" }, { number = Vector2State})
            Iris.InputVector3({ "InputVector3" }, { number = Vector3State})
            Iris.InputUDim({ "InputUDim" }, { number = UDimState})
            Iris.InputUDim2({ "InputUDim2" }, { number = UDim2State})
            Iris.InputRect({ "InputRect" }, { number = RectState})
        Iris.End()

        Iris.CollapsingHeader("Drag")
            Iris.DragNum({ "DragNum" }, { number = NumberState})
            Iris.DragVector2({ "DragVector2" }, { number = Vector2State})
            Iris.DragVector3({ "DragVector3" }, { number = Vector3State})
            Iris.DragUDim({ "DragUDim" }, { number = UDimState})
            Iris.DragUDim2({ "DragUDim2" }, { number = UDim2State})
            Iris.DragRect({ "DragRect" }, { number = RectState})
        Iris.End()

        Iris.CollapsingHeader("Slider")
            Iris.SliderNum({ "SliderNum" }, { number = NumberState})
            Iris.SliderVector2({ "SliderVector2" }, { number = Vector2State})
            Iris.SliderVector3({ "SliderVector3" }, { number = Vector3State})
            Iris.SliderUDim({ "SliderUDim" }, { number = UDimState})
            Iris.SliderUDim2({ "SliderUDim2" }, { number = UDim2State})
            Iris.SliderRect({ "SliderRect" }, { number = RectState})
        Iris.End()

    Iris.End()
    -- stylua: ignore end
end)
