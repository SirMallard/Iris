local Types = require(script.Parent.Types)

return function(Iris: Types.Iris)
    local showMainWindow = Iris.State(true)
    local showRecursiveWindow = Iris.State(false)
    local showRuntimeInfo = Iris.State(false)
    local showStyleEditor = Iris.State(false)
    local showWindowlessDemo = Iris.State(false)
    local showMainMenuBarWindow = Iris.State(false)

    -- stylua: ignore start
    local function helpMarker(helpText)
        Iris.PushConfig({ TextColor = Iris._config.TextDisabledColor })
        local text = Iris.Text({ "(?)" })
        Iris.PopConfig()

        Iris.PushConfig({ ContentWidth = UDim.new(0, 350) })
        if text.hovered() then
            Iris.Tooltip({ helpText })
        end
        Iris.PopConfig()
    end

    -- shows each widgets functionality
    local widgetDemos = {
        Basic = function()
            Iris.Tree({ "Basic" })
                Iris.SeparatorText({ "Basic" })

                local radioButtonState = Iris.State(1)
                Iris.Button({ "Button" })
                Iris.SmallButton({ "SmallButton" })
                Iris.Text({ "Text" })
                Iris.TextWrapped({ string.rep("Text Wrapped ", 5) })
                Iris.TextColored({ "Colored Text", Color3.fromRGB(255, 128, 0) })
                Iris.Text({ `Rich Text: <b>bold text</b> <i>italic text</i> <u>underline text</u> <s>strikethrough text</s> <font color= "rgb(240, 40, 10)">red text</font> <font size="32">bigger text</font>`, true, nil, true })
                Iris.SameLine()
                    Iris.RadioButton({ "Index '1'", 1 }, { index = radioButtonState })
                    Iris.RadioButton({ "Index 'two'", "two" }, { index = radioButtonState })
                    if Iris.RadioButton({ "Index 'false'", false }, { index = radioButtonState }).active() == false then
                        if Iris.SmallButton({ "Select last" }).clicked() then
                            radioButtonState:set(false)
                        end
                    end
                Iris.End()
                Iris.Text({ "The Index is: " .. tostring(radioButtonState.value) })

                Iris.SeparatorText({ "Inputs" })

                Iris.InputNum({})
                Iris.DragNum({})
                Iris.SliderNum({})

            Iris.End()
        end,

        Tree = function()
            Iris.Tree({ "Trees" })
                Iris.Tree({ "Tree using SpanAvailWidth", [Iris.Args.Tree.SpanAvailWidth] = true })
                    helpMarker("SpanAvailWidth determines if the Tree is selectable from its entire with, or only the text area")
                Iris.End()

                local tree1 = Iris.Tree({ "Tree with Children" })
                    Iris.Text({ "Im inside the first tree!" })
                    Iris.Button({ "Im a button inside the first tree!" })
                    Iris.Tree({ "Im a tree inside the first tree!" })
                        Iris.Text({ "I am the innermost text!" })
                    Iris.End()
                Iris.End()

                Iris.Checkbox({ "Toggle above tree" }, { isChecked = tree1.state.isUncollapsed })

            Iris.End()
        end,

        CollapsingHeader = function()
            Iris.Tree({ "Collapsing Headers" })
                Iris.CollapsingHeader({ "A header" })
                    Iris.Text({ "This is under the first header!" })
                Iris.End()

                local secondHeader = Iris.State(true)
                Iris.CollapsingHeader({ "Another header" }, { isUncollapsed = secondHeader })
                    if Iris.Button({ "Shhh... secret button!" }).clicked() then
                        secondHeader:set(true)
                    end
                Iris.End()
            Iris.End()
        end,

        Group = function()
            Iris.Tree({ "Groups" })
                Iris.SameLine()
                    Iris.Group()
                        Iris.Text({ "I am in group A" })
                        Iris.Button({ "Im also in A" })
                    Iris.End()
                    
                    Iris.Separator()
                    
                    Iris.Group()
                        Iris.Text({ "I am in group B" })
                        Iris.Button({ "Im also in B" })
                        Iris.Button({ "Also group B" })
                    Iris.End()
                Iris.End()
            Iris.End()
        end,

        Indent = function()
            Iris.Tree({ "Indents" })
                Iris.Text({ "Not Indented" })
                Iris.Indent()
                    Iris.Text({ "Indented" })
                    Iris.Indent({ 7 })
                        Iris.Text({ "Indented by 7 more pixels" })
                    Iris.End()

                    Iris.Indent({ -7 })
                        Iris.Text({ "Indented by 7 less pixels" })
                    Iris.End()
                Iris.End()
            Iris.End()
        end,

        Input = function()
            Iris.Tree({ "Input" })
                local NoField, NoButtons, Min, Max, Increment, Format = Iris.State(false), Iris.State(false), Iris.State(0), Iris.State(100), Iris.State(1), Iris.State("%d")

                Iris.PushConfig({ ContentWidth = UDim.new(1, -120) })
                local InputNum = Iris.InputNum({
                    "Input Number",
                    -- [Iris.Args.InputNum.NoField] = NoField.value,
                    [Iris.Args.InputNum.NoButtons] = NoButtons.value,
                    [Iris.Args.InputNum.Min] = Min.value,
                    [Iris.Args.InputNum.Max] = Max.value,
                    [Iris.Args.InputNum.Increment] = Increment.value,
                    [Iris.Args.InputNum.Format] = { Format.value },
                })
                Iris.PopConfig()
                Iris.Text({ "The Value is: " .. InputNum.number.value })
                if Iris.Button({ "Randomize Number" }).clicked() then
                    InputNum.number:set(math.random(1, 99))
                end
                local NoFieldCheckbox = Iris.Checkbox({ "NoField" }, { isChecked = NoField })
                local NoButtonsCheckbox = Iris.Checkbox({ "NoButtons" }, { isChecked = NoButtons })
                if NoFieldCheckbox.checked() and NoButtonsCheckbox.isChecked.value == true then
                    NoButtonsCheckbox.isChecked:set(false)
                end
                if NoButtonsCheckbox.checked() and NoFieldCheckbox.isChecked.value == true then
                    NoFieldCheckbox.isChecked:set(false)
                end

                Iris.PushConfig({ ContentWidth = UDim.new(1, -120) })
                Iris.InputVector2({ "InputVector2" })
                Iris.InputVector3({ "InputVector3" })
                Iris.InputUDim({ "InputUDim" })
                Iris.InputUDim2({ "InputUDim2" })
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

                Iris.PopConfig()

                Iris.Separator()

                Iris.SameLine()
                    Iris.Text({ "Slider Numbers" })
                    helpMarker("ctrl + click slider number widgets to input a number")
                Iris.End()
                Iris.PushConfig({ ContentWidth = UDim.new(1, -120) })
                Iris.SliderNum({ "Slide Int", 1, 1, 8 })
                Iris.SliderNum({ "Slide Float", 0.01, 0, 100 })
                Iris.SliderNum({ "Small Numbers", 0.001, -2, 1, "%f radians" })
                Iris.SliderNum({ "Odd Ranges", 0.001, -math.pi, math.pi, "%f radians" })
                Iris.SliderNum({ "Big Numbers", 1e4, 1e5, 1e7 })
                Iris.SliderNum({ "Few Numbers", 1, 0, 3 })
                Iris.PopConfig()

                Iris.Separator()

                Iris.SameLine()
                    Iris.Text({ "Drag Numbers" })
                    helpMarker("ctrl + click or double click drag number widgets to input a number, hold shift/alt while dragging to increase/decrease speed")
                Iris.End()
                Iris.PushConfig({ ContentWidth = UDim.new(1, -120) })
                Iris.DragNum({ "Drag Int" })
                Iris.DragNum({ "Slide Float", 0.001, -10, 10 })
                Iris.DragNum({ "Percentage", 1, 0, 100, "%d %%" })
                Iris.PopConfig()
            Iris.End()
        end,

        InputText = function()
            Iris.Tree({ "Input Text" })
                Iris.PushConfig({ ContentWidth = UDim.new(0, 250) })
                local InputText = Iris.InputText({ "Input Text Test", [Iris.Args.InputText.TextHint] = "Input Text here" })
                Iris.PopConfig()
                Iris.Text({ "The text is: " .. InputText.text.value })
            Iris.End()
        end,

        MultiInput = function()
            Iris.Tree({"Multi-Component Input"})

                local sharedVector2 = Iris.State(Vector2.new())
                local sharedVector3 = Iris.State(Vector3.new())
                local sharedUDim = Iris.State(UDim.new())
                local sharedUDim2 = Iris.State(UDim2.new())
                local sharedColor3 = Iris.State(Color3.new())
                local SharedRect = Iris.State(Rect.new())

                Iris.SeparatorText({"Input"})

                Iris.InputVector2({}, {number = sharedVector2})
                Iris.InputVector3({}, {number = sharedVector3})
                Iris.InputUDim({}, {number = sharedUDim})
                Iris.InputUDim2({}, {number = sharedUDim2})
                Iris.InputRect({}, {number = SharedRect})

                Iris.SeparatorText({"Drag"})

                Iris.DragVector2({}, {number = sharedVector2})
                Iris.DragVector3({}, {number = sharedVector3})
                Iris.DragUDim({}, {number = sharedUDim})
                Iris.DragUDim2({}, {number = sharedUDim2})
                Iris.DragRect({}, {number = SharedRect})

                Iris.SeparatorText({"Slider"})

                Iris.SliderVector2({}, {number = sharedVector2})
                Iris.SliderVector3({}, {number = sharedVector3})
                Iris.SliderUDim({}, {number = sharedUDim})
                Iris.SliderUDim2({}, {number = sharedUDim2})
                Iris.SliderRect({}, {number = SharedRect})

                Iris.SeparatorText({"Color"})

                Iris.InputColor3({}, {color = sharedColor3})
                Iris.InputColor4({}, {color = sharedColor3})

            Iris.End()
        end,

        Tooltip = function()
            Iris.PushConfig({ ContentWidth = UDim.new(0, 250) })
            Iris.Tree({ "Tooltip" })
                if Iris.Text({ "Hover over me to reveal a tooltip" }).hovered() then
                    Iris.Tooltip({ "I am some helpful tooltip text" })
                end
                local dynamicText = Iris.State("Hello ")
                local numRepeat = Iris.State(1)
                if Iris.InputNum({ "# of repeat", 1, 1, 50 }, { number = numRepeat }).numberChanged() then
                    dynamicText:set(string.rep("Hello ", numRepeat:get()))
                end
                if Iris.Checkbox({ "Show dynamic text tooltip" }).isChecked.value then
                    Iris.Tooltip({ dynamicText:get() })
                end
            Iris.End()
            Iris.PopConfig()
        end,

        Selectable = function()
            Iris.Tree({ "Selectable" })
                local sharedIndex = Iris.State(2)
                Iris.Selectable({ "Selectable #1", 1 }, { index = sharedIndex })
                Iris.Selectable({ "Selectable #2", 2 }, { index = sharedIndex })
                if Iris.Selectable({ "Double click Selectable", 3, true }, { index = sharedIndex }).doubleClicked() then
                    sharedIndex:set(3)
                end
                Iris.Selectable({ "Impossible to select", 4, true }, { index = sharedIndex })
                if Iris.Button({ "Select last" }).clicked() then
                    sharedIndex:set(4)
                end
                Iris.Selectable({ "Independent Selectable" })
            Iris.End()
        end,

        Combo = function()
            Iris.Tree({ "Combo" })
                Iris.PushConfig({ ContentWidth = UDim.new(1, -120) })
                local sharedComboIndex = Iris.State("No Selection")
                Iris.SameLine()
                    local NoPreview = Iris.Checkbox({ "No Preview" })
                    local NoButton = Iris.Checkbox({ "No Button" })
                    if NoPreview.checked() and NoButton.isChecked.value == true then
                        NoButton.isChecked:set(false)
                    end
                    if NoButton.checked() and NoPreview.isChecked.value == true then
                        NoPreview.isChecked:set(false)
                    end
                Iris.End()
                Iris.Combo({ "Basic Usage", NoButton.isChecked:get(), NoPreview.isChecked:get() }, { index = sharedComboIndex })
                    Iris.Selectable({ "Select 1", "One" }, { index = sharedComboIndex })
                    Iris.Selectable({ "Select 2", "Two" }, { index = sharedComboIndex })
                    Iris.Selectable({ "Select 3", "Three" }, { index = sharedComboIndex })
                Iris.End()

                Iris.ComboArray({ "Using ComboArray" }, { index = "No Selection" }, { "Red", "Green", "Blue" })

                local sharedComboIndex2 = Iris.State("7 AM")
                Iris.Combo({ "Combo with Inner widgets" }, { index = sharedComboIndex2 })
                    Iris.Tree({ "Morning Shifts" })
                        Iris.Selectable({ "Shift at 7 AM", "7 AM" }, { index = sharedComboIndex2 })
                        Iris.Selectable({ "Shift at 11 AM", "11 AM" }, { index = sharedComboIndex2 })
                        Iris.Selectable({ "Shist at 3 PM", "3 PM" }, { index = sharedComboIndex2 })
                    Iris.End()
                    Iris.Tree({ "Night Shifts" })
                        Iris.Selectable({ "Shift at 6 PM", "6 PM" }, { index = sharedComboIndex2 })
                        Iris.Selectable({ "Shift at 9 PM", "9 PM" }, { index = sharedComboIndex2 })
                    Iris.End()
                Iris.End()

                local ComboEnum = Iris.ComboEnum({ "Using ComboEnum" }, { index = Enum.UserInputState.Begin }, Enum.UserInputState)
                Iris.Text({ "Selected: " .. ComboEnum.index:get().Name })
                Iris.PopConfig()
            Iris.End()
        end,
    }
    local widgetDemosOrder = { "Basic", "Tree", "CollapsingHeader", "Group", "Indent", "Input", "MultiInput", "InputText", "Tooltip", "Selectable", "Combo" }

    local function recursiveTree()
        local theTree = Iris.Tree({ "Recursive Tree" })
        if theTree.state.isUncollapsed.value then
            recursiveTree()
        end
        Iris.End()
    end

    local function recursiveWindow(parentCheckboxState)
        Iris.Window({ "Recursive Window" }, { size = Iris.State(Vector2.new(175, 100)), isOpened = parentCheckboxState })
            local theCheckbox = Iris.Checkbox({ "Recurse Again" })
        Iris.End()
        if theCheckbox.isChecked.value then
            recursiveWindow(theCheckbox.isChecked)
        end
    end

    -- shows list of runtime widgets and states, including IDs. shows other info about runtime and can show widgets/state info in depth.
    local function runtimeInfo()
        local runtimeInfoWindow = Iris.Window({ "Runtime Info" }, { isOpened = showRuntimeInfo })
            local lastVDOM = Iris.Internal._lastVDOM
            local states = Iris.Internal._states

            local numSecondsDisabled = Iris.State(3)
            local rollingDT = Iris.State(0)
            local lastT = Iris.State(os.clock())

            Iris.SameLine()
                Iris.InputNum({ "", [Iris.Args.InputNum.Format] = "%d Seconds", [Iris.Args.InputNum.Max] = 10 }, { number = numSecondsDisabled })
                if Iris.Button({ "Disable" }).clicked() then
                    Iris.Disabled = true
                    task.delay(numSecondsDisabled:get(), function()
                        Iris.Disabled = false
                    end)
                end
            Iris.End()

            local t = os.clock()
            local dt = t - lastT.value
            rollingDT.value += (dt - rollingDT.value) * 0.2
            lastT.value = t
            Iris.Text({ string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT.value * 1000, 1 / rollingDT.value) })

            Iris.Text({
                string.format("Window Position: (%d, %d), Window Size: (%d, %d)", runtimeInfoWindow.position.value.X, runtimeInfoWindow.position.value.Y, runtimeInfoWindow.size.value.X, runtimeInfoWindow.size.value.Y),
            })

            Iris.SameLine()
                Iris.Text({ "Enter an ID to learn more about it." })
                helpMarker("every widget and state has an ID which Iris tracks to remember which widget is which. below lists all widgets and states, with their respective IDs")
            Iris.End()

            Iris.PushConfig({ ItemWidth = UDim.new(1, -150) })
            local enteredText = Iris.InputText({ "ID field" }, { text = Iris.State(runtimeInfoWindow.ID) }).text.value
            Iris.PopConfig()

            Iris.Indent()
                local enteredWidget = lastVDOM[enteredText]
                local enteredState = states[enteredText]
                if enteredWidget then
                    Iris.Table({ 1, [Iris.Args.Table.RowBg] = false })
                        Iris.Text({ string.format('The ID, "%s", is a widget', enteredText) })
                        Iris.NextRow()

                        Iris.Text({ string.format("Widget is type: %s", enteredWidget.type) })
                        Iris.NextRow()

                        Iris.Tree({ "Widget has Args:" }, { isUncollapsed = Iris.State(true) })
                            for i, v in enteredWidget.arguments do
                                Iris.Text({ i .. " - " .. tostring(v) })
                            end
                        Iris.End()
                        Iris.NextRow()

                        if enteredWidget.state then
                            Iris.Tree({ "Widget has State:" }, { isUncollapsed = Iris.State(true) })
                                for i, v in enteredWidget.state do
                                    Iris.Text({ i .. " - " .. tostring(v.value) })
                                end
                            Iris.End()
                        end
                    Iris.End()
                elseif enteredState then
                    Iris.Table({ 1, [Iris.Args.Table.RowBg] = false })
                        Iris.Text({ string.format('The ID, "%s", is a state', enteredText) })
                        Iris.NextRow()

                        Iris.Text({ string.format("Value is type: %s, Value = %s", typeof(enteredState.value), tostring(enteredState.value)) })
                        Iris.NextRow()

                        Iris.Tree({ "state has connected widgets:" }, { isUncollapsed = Iris.State(true) })
                            for i, v in enteredState.ConnectedWidgets do
                                Iris.Text({ i .. " - " .. v.type })
                            end
                        Iris.End()
                        Iris.NextRow()

                        Iris.Text({ string.format("state has: %d connected functions", #enteredState.ConnectedFunctions) })
                    Iris.End()
                else
                    Iris.Text({ string.format('The ID, "%s", is not a state or widget', enteredText) })
                end
            Iris.End()

            if Iris.Tree({ "Widgets" }).isUncollapsed.value then
                local widgetCount = 0
                local widgetStr = ""
                for _, v in lastVDOM do
                    widgetCount += 1
                    widgetStr ..= "\n" .. v.ID .. " - " .. v.type
                end

                Iris.Text({ "Number of Widgets: " .. widgetCount })

                Iris.Text({ widgetStr })
            end
            Iris.End()
            if Iris.Tree({ "States" }).isUncollapsed.value then
                local stateCount = 0
                local stateStr = ""
                for i, v in states do
                    stateCount += 1
                    stateStr ..= "\n" .. i .. " - " .. tostring(v.value)
                end

                Iris.Text({ "Number of States: " .. stateCount })

                Iris.Text({ stateStr })
            end
            Iris.End()
        Iris.End()
    end

    local function recursiveMenu()
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
                recursiveMenu()
            Iris.End()
        end
        Iris.End()
        -- stylua: ignore end
        
    end

    local function mainMenuBar()
        Iris.MenuBar()
            Iris.Menu({ "File" })
                Iris.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl })
                Iris.MenuItem({ "Open", Enum.KeyCode.O, Enum.ModifierKey.Ctrl })
                Iris.MenuItem({ "Save", Enum.KeyCode.S, Enum.ModifierKey.Ctrl })
                recursiveMenu()
                Iris.MenuItem({ "Quit", Enum.KeyCode.Q, Enum.ModifierKey.Alt })
            Iris.End()
            
            Iris.Menu({ "Examples" })
                Iris.MenuToggle({ "Recursive Window" }, { isChecked = showRecursiveWindow })
                Iris.MenuToggle({ "Windowless" }, { isChecked = showWindowlessDemo })
                Iris.MenuToggle({ "Main Menu Bar" }, { isChecked = showMainMenuBarWindow })
            Iris.End()

            Iris.Menu({ "Tools" })
                Iris.MenuToggle({ "Runtime Info" }, { isChecked = showRuntimeInfo })
                Iris.MenuToggle({ "Style Editor" }, { isChecked = showStyleEditor })
            Iris.End()
        Iris.End()
    end

    local function mainMenuBarExample()
        local screenSize = Iris.Internal._rootWidget.Instance.PseudoWindowScreenGui.AbsoluteSize
        -- Iris.Window(
        --     {[Iris.Args.Window.NoBackground] = true, [Iris.Args.Window.NoTitleBar] = true, [Iris.Args.Window.NoMove] = true, [Iris.Args.Window.NoResize] = true},
        --     {size = Iris.State(screenSize), position = Iris.State(Vector2.new(0, 0))}
        -- )
        
        mainMenuBar()

        --Iris.End()
    end

    -- allows users to edit state
    local styleEditor
    do
        styleEditor = function()
            local selectedPanel = Iris.State(1)

            local styleList = {
                {
                    "Sizing",
                    function()
                        local UpdatedConfig = Iris.State({})

                        if Iris.Button({ "Update Config" }).clicked() then
                            Iris.UpdateGlobalConfig(UpdatedConfig:get())
                            UpdatedConfig:set({})
                        end

                        local UDims = {
                            { "ItemWidth", nil,  UDim.new(), UDim.new(1, 200) },
                            { "ContentWidth", nil, UDim.new(), UDim.new(1, 200) }
                        }
                        for _, vUDim in UDims do
                            local Input = Iris.SliderUDim({ table.unpack(vUDim) }, { number = Iris.WeakState(Iris._config[vUDim[1]]) })
                            if Input.numberChanged() then
                                UpdatedConfig:get()[vUDim[1]] = Input.number:get()
                            end
                        end

                        local Vector2s = {
                            { "WindowPadding", nil, Vector2.zero, Vector2.one * 20 },
                            { "WindowResizePadding", nil, Vector2.zero, Vector2.one * 20 },
                            { "FramePadding", nil, Vector2.zero, Vector2.one * 20 },
                            { "ItemSpacing", nil, Vector2.zero, Vector2.one * 20 },
                            { "ItemInnerSpacing", nil, Vector2.zero, Vector2.one * 20 },
                            { "CellPadding", nil, Vector2.zero, Vector2.one * 20 },
                            { "DisplaySafeAreaPadding", nil, Vector2.zero, Vector2.one * 20 },
                        }
                        for _, vVector2 in Vector2s do
                            local Input = Iris.SliderVector2({ table.unpack(vVector2) }, { number = Iris.WeakState(Iris._config[vVector2[1]]) })
                            if Input.numberChanged() then
                                UpdatedConfig:get()[vVector2[1]] = Input.number:get()
                            end
                        end

                        local Numbers = {
                            { "TextSize", 1, 4, 20 },
                            { "FrameBorderSize", 0.1, 0, 1 },
                            { "FrameRounding", 1, 0, 12 },
                            { "GrabRounding", 1, 0, 12 },
                            { "WindowBorderSize", 0.1, 0, 1 },
                            { "PopupBorderSize", 0.1, 0, 1 },
                            { "PopupRounding", 1, 0, 12 },
                            { "ScrollbarSize", 1, 0, 20 },
                            { "GrabMinSize", 1, 0, 20 },
                        }
                        for _, vNumber in Numbers do
                            local Input = Iris.SliderNum({ table.unpack(vNumber) }, { number = Iris.WeakState(Iris._config[vNumber[1]]) })
                            if Input.numberChanged() then
                                UpdatedConfig:get()[vNumber[1]] = Input.number:get()
                            end
                        end

                        local Enums = {
                            "WindowTitleAlign",
                            -- "TextFont"
                        }
                        for _, vEnum in Enums do
                            local Input = Iris.ComboEnum({ vEnum }, { index = Iris.WeakState(Iris._config[vEnum]) }, Iris._config[vEnum].EnumType)
                            if Input.closed() then
                                Iris.UpdateGlobalConfig({ [vEnum] = Input.index:get() })
                            end
                        end
                    end,
                },
                {
                    "Colors",
                    function()
                        local UpdatedConfig = Iris.State({})

                        if Iris.Button({ "Update Config" }).clicked() then
                            Iris.UpdateGlobalConfig(UpdatedConfig:get())
                            UpdatedConfig:set({})
                        end
                        
                        local color3s = { "BorderColor", "BorderActiveColor" }

                        for _, vColor in color3s do
                            local Input = Iris.InputColor3({ vColor }, { color = Iris.WeakState(Iris._config[vColor]) })
                            if Input.numberChanged() then
                                Iris.UpdateGlobalConfig({ [vColor] = Input.color:get() })
                            end
                        end

                        local color4s = {
                            "Text",
                            "TextDisabled",
                            "WindowBg",
                            "ScrollbarGrab",
                            "TitleBg",
                            "TitleBgActive",
                            "TitleBgCollapsed",
                            "MenubarBg",
                            "FrameBg",
                            "FrameBgHovered",
                            "FrameBgActive",
                            "Button",
                            "ButtonHovered",
                            "ButtonActive",
                            "SliderGrab",
                            "SliderGrabActive",
                            "Header",
                            "HeaderHovered",
                            "HeaderActive",
                            "SelectionImageObject",
                            "SelectionImageObjectBorder",
                            "TableBorderStrong",
                            "TableBorderLight",
                            "TableRowBg",
                            "TableRowBgAlt",
                            "NavWindowingHighlight",
                            "NavWindowingDimBg",
                            "Separator",
                            "CheckMark",
                        }

                        for _, vColor in color4s do
                            local Input = Iris.InputColor4({ vColor }, {
                                color = Iris.WeakState(Iris._config[vColor .. "Color"]),
                                transparency = Iris.WeakState(Iris._config[vColor .. "Transparency"]),
                            })
                            if Input.numberChanged() then
                                UpdatedConfig:get()[vColor .. "Color"] = Input.color:get()
                                UpdatedConfig:get()[vColor .. "Transparency"] = Input.transparency:get()
                            end
                        end
                    end,
                },
            }

            Iris.Window({ "Style Editor" }, { isOpened = showStyleEditor })
                Iris.Text({ "Customize the look of Iris in realtime." })
                Iris.SameLine()
                    if Iris.SmallButton({ "Light Theme" }).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
                    end
                    if Iris.SmallButton({ "Dark Theme" }).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                    end
                Iris.End()

                Iris.SameLine()
                    if Iris.SmallButton({ "Classic Size" }).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                    end
                    if Iris.SmallButton({ "Larger Size" }).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
                    end
                Iris.End()

                if Iris.SmallButton({ "Reset Everything" }).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                end
                Iris.Separator()

                Iris.SameLine()
                    for i, v in ipairs(styleList) do
                        Iris.RadioButton({ v[1], i }, { index = selectedPanel })
                    end
                Iris.End()

                styleList[selectedPanel:get()][2]()
            Iris.End()
        end
    end

    local function widgetEventInteractivity()
        Iris.CollapsingHeader({ "Widget Event Interactivity" })
        local clickCount = Iris.State(0)
        if Iris.Button({ "Click to increase Number" }).clicked() then
            clickCount:set(clickCount:get() + 1)
        end
        Iris.Text({ "The Number is: " .. clickCount:get() })

        Iris.Separator()

        local showEventText = Iris.State(false)
        local selectedEvent = Iris.State("clicked")
        Iris.SameLine()
        Iris.RadioButton({ "clicked", "clicked" }, { index = selectedEvent })
        Iris.RadioButton({ "rightClicked", "rightClicked" }, { index = selectedEvent })
        Iris.RadioButton({ "doubleClicked", "doubleClicked" }, { index = selectedEvent })
        Iris.RadioButton({ "ctrlClicked", "ctrlClicked" }, { index = selectedEvent })
        Iris.End()
        Iris.SameLine()

        if Iris.Button({ selectedEvent:get() .. " to reveal text" })[selectedEvent:get()]() then
            showEventText:set(not showEventText:get())
        end
        if showEventText:get() then
            Iris.Text({ "Here i am!" })
        end

        Iris.End()

        Iris.Separator()

        local showTextTimer = Iris.State(0)
        Iris.SameLine()
        if Iris.Button({ "Click to show text for 20 frames" }).clicked() then
            showTextTimer:set(20)
        end
        if showTextTimer:get() > 0 then
            Iris.Text({ "Here i am!" })
        end
        Iris.End()
        showTextTimer:set(math.max(0, showTextTimer:get() - 1))
        Iris.Text({ "Text Timer: " .. showTextTimer:get() })

        local checkbox0 = Iris.Checkbox({ "Event-tracked checkbox" })
        Iris.Indent()
        Iris.Text({ "unchecked: " .. tostring(checkbox0.unchecked()) })
        Iris.Text({ "checked: " .. tostring(checkbox0.checked()) })
        Iris.End()
        Iris.SameLine()
        if Iris.Button({ "Hover over me" }).hovered() then
            Iris.Text({ "The button is hovered" })
        end
        Iris.End()
        Iris.End()
    end

    local function widgetStateInteractivity()
        Iris.CollapsingHeader({ "Widget State Interactivity" })
        local checkbox0 = Iris.Checkbox({ "Widget-Generated State" })
        Iris.Text({ `isChecked: {checkbox0.state.isChecked.value}\n` })

        local checkboxState0 = Iris.State(false)
        local checkbox1 = Iris.Checkbox({ "User-Generated State" }, { isChecked = checkboxState0 })
        Iris.Text({ `isChecked: {checkbox1.state.isChecked.value}\n` })

        local checkbox2 = Iris.Checkbox({ "Widget Coupled State" })
        local checkbox3 = Iris.Checkbox({ "Coupled to above Checkbox" }, { isChecked = checkbox2.state.isChecked })
        Iris.Text({ `isChecked: {checkbox3.state.isChecked.value}\n` })

        local checkboxState1 = Iris.State(false)
        local _checkbox4 = Iris.Checkbox({ "Widget and Code Coupled State" }, { isChecked = checkboxState1 })
        local Button0 = Iris.Button({ "Click to toggle above checkbox" })
        if Button0.clicked() then
            checkboxState1:set(not checkboxState1:get())
        end
        Iris.Text({ `isChecked: {checkboxState1.value}\n` })

        local checkboxState2 = Iris.State(true)
        local checkboxState3 = Iris.ComputedState(checkboxState2, function(newValue)
            return not newValue
        end)
        local _checkbox5 = Iris.Checkbox({ "ComputedState (dynamic coupling)" }, { isChecked = checkboxState2 })
        local _checkbox5 = Iris.Checkbox({ "Inverted of above checkbox" }, { isChecked = checkboxState3 })
        Iris.Text({ `isChecked: {checkboxState3.value}\n` })

        Iris.End()
    end

    local function dynamicStyle()
        Iris.CollapsingHeader({ "Dynamic Styles" })
        local colorH = Iris.State(0)
        Iris.SameLine()
        if Iris.Button({ "Change Color" }).clicked() then
            colorH:set(math.random())
        end
        Iris.Text({ "Hue: " .. math.floor(colorH:get() * 255) })
        helpMarker("Using PushConfig with a changing value, this can be done with any config field")
        Iris.End()
        Iris.PushConfig({ TextColor = Color3.fromHSV(colorH:get(), 1, 1) })
        Iris.Text({ "Text with a unique and changable color" })
        Iris.PopConfig()
        Iris.End()
    end

    local function tablesDemo()
        local showTablesTree = Iris.State(false)

        Iris.CollapsingHeader({ "Tables & Columns" }, { isUncollapsed = showTablesTree })
        if showTablesTree.value == false then
            -- optimization to skip code which draws GUI which wont be seen.
            -- its a trade off because when the tree becomes opened widgets will all have to be generated again.
            -- Dear ImGui utilizes the same trick, but its less useful here because the Retained mode Backend
            Iris.End()
        else
            Iris.SameLine()
            Iris.Text({ "Table using NextRow and NextColumn syntax:" })
            helpMarker("calling Iris.NextRow() in the outer loop, and Iris.NextColumn()in the inner loop")
            Iris.End()
            Iris.Table({ 3 })
            for i = 1, 4 do
                Iris.NextRow()
                for i2 = 1, 3 do
                    Iris.NextColumn()
                    Iris.Text({ `Row: {i}, Column: {i2}` })
                end
            end
            Iris.End()

            Iris.Text({ "" })

            Iris.SameLine()
            Iris.Text({ "Table using NextColumn only syntax:" })
            helpMarker("only calling Iris.NextColumn() in the inner loop, the result is identical")
            Iris.End()

            Iris.Table({ 2 })
            for i = 1, 4 do
                for i2 = 1, 2 do
                    Iris.NextColumn()
                    Iris.Text({ `Row: {i}, Column: {i2}` })
                end
            end
            Iris.End()

            Iris.Separator()

            local TableRowBg = Iris.State(false)
            local TableBordersOuter = Iris.State(false)
            local TableBordersInner = Iris.State(true)
            local TableUseButtons = Iris.State(true)
            local TableNumRows = Iris.State(3)

            Iris.Text({ "Table with Customizable Arguments" })
            Iris.Table({
                4,
                [Iris.Args.Table.RowBg] = TableRowBg.value,
                [Iris.Args.Table.BordersOuter] = TableBordersOuter.value,
                [Iris.Args.Table.BordersInner] = TableBordersInner.value,
            })
            for i = 1, TableNumRows:get() do
                for i2 = 1, 4 do
                    Iris.NextColumn()
                    if TableUseButtons.value then
                        Iris.Button({ `Month: {i}, Week: {i2}` })
                    else
                        Iris.Text({ `Month: {i}, Week: {i2}` })
                    end
                end
            end
            Iris.End()

            Iris.Checkbox({ "RowBg" }, { isChecked = TableRowBg })
            Iris.Checkbox({ "BordersOuter" }, { isChecked = TableBordersOuter })
            Iris.Checkbox({ "BordersInner" }, { isChecked = TableBordersInner })
            Iris.SameLine()
            Iris.RadioButton({ "Buttons", true }, { index = TableUseButtons })
            Iris.RadioButton({ "Text", false }, { index = TableUseButtons })
            Iris.End()
            Iris.InputNum({
                "Number of rows",
                [Iris.Args.InputNum.Min] = 0,
                [Iris.Args.InputNum.Max] = 100,
                [Iris.Args.InputNum.Format] = "%d",
            }, { number = TableNumRows })

            Iris.End()
        end
    end

    local function layoutDemo()
        Iris.CollapsingHeader({ "Widget Layout" })
        Iris.Tree({ "Content Width" })
        local value = Iris.State(50)
        local index = Iris.State(Enum.Axis.X)

        Iris.Text({ "The Content Width is a size property which determines the width of input fields." })
        Iris.SameLine()
        Iris.Text({ "By default the value is UDim.new(0.65, 0)" })
        helpMarker("This is the default value from Dear ImGui.\nIt is 65% of the window width.")
        Iris.End()
        Iris.Text({ "This works well, but sometimes we know how wide elements are going to be and want to maximise the space." })
        Iris.Text({ "Therefore, we can use Iris.PushConfig() to change the width" })

        Iris.Separator()

        Iris.SameLine()
        Iris.Text({ "Content Width = 150 pixels" })
        helpMarker("UDim.new(0, 150)")
        Iris.End()
        Iris.PushConfig({ ContentWidth = UDim.new(0, 150) })
        Iris.DragNum({ "number", 1, 0, 100 }, { number = value })
        Iris.ComboEnum({ "axis" }, { index = index }, Enum.Axis)
        Iris.PopConfig()

        Iris.SameLine()
        Iris.Text({ "Content Width = 50% window width" })
        helpMarker("UDim.new(0.5, 0)")
        Iris.End()
        Iris.PushConfig({ ContentWidth = UDim.new(0.5, 0) })
        Iris.DragNum({ "number", 1, 0, 100 }, { number = value })
        Iris.ComboEnum({ "axis" }, { index = index }, Enum.Axis)
        Iris.PopConfig()

        Iris.SameLine()
        Iris.Text({ "Content Width = -150 pixels from the right side" })
        helpMarker("UDim.new(1, -150)")
        Iris.End()
        Iris.PushConfig({ ContentWidth = UDim.new(1, -150) })
        Iris.DragNum({ "number", 1, 0, 100 }, { number = value })
        Iris.InputEnum({ "axis" }, { index = index }, Enum.Axis)
        Iris.PopConfig()
        Iris.End()
        Iris.End()
    end

    -- showcases how widgets placed outside of a window are placed inside root
    local function windowlessDemo()
        Iris.PushConfig({ ItemWidth = UDim.new(0, 150) })
        Iris.SameLine()
        Iris.TextWrapped({ "Windowless widgets" })
        helpMarker("Widgets which are placed outside of a window will appear on the top left side of the screen.")
        Iris.End()
        Iris.Button({})
        Iris.Tree({})
        Iris.InputText({})
        Iris.End()
        Iris.PopConfig()
    end

    -- main demo window
    return function()
        local NoTitleBar = Iris.State(false)
        local NoBackground = Iris.State(false)
        local NoCollapse = Iris.State(false)
        local NoClose = Iris.State(true)
        local NoMove = Iris.State(false)
        local NoScrollbar = Iris.State(false)
        local NoResize = Iris.State(false)
        local NoNav = Iris.State(false)
        local NoMenu = Iris.State(false)

        if showMainWindow.value == false then
            Iris.Checkbox({ "Open main window" }, { isChecked = showMainWindow })
            return
        end

        Iris.Window({
            "Iris Demo Window",
            [Iris.Args.Window.NoTitleBar] = NoTitleBar.value,
            [Iris.Args.Window.NoBackground] = NoBackground.value,
            [Iris.Args.Window.NoCollapse] = NoCollapse.value,
            [Iris.Args.Window.NoClose] = NoClose.value,
            [Iris.Args.Window.NoMove] = NoMove.value,
            [Iris.Args.Window.NoScrollbar] = NoScrollbar.value,
            [Iris.Args.Window.NoResize] = NoResize.value,
            [Iris.Args.Window.NoNav] = NoNav.value,
            [Iris.Args.Window.NoMenu] = NoMenu.value,
        }, { size = Iris.State(Vector2.new(600, 550)), position = Iris.State(Vector2.new(100, 25)), isOpened = showMainWindow })

        mainMenuBar()

        Iris.Text({ "Iris says hello. (2.1.1)" })

        Iris.CollapsingHeader({ "Window Options" })
        Iris.Table({ 3, false, false, false })
        Iris.NextColumn()
        Iris.Checkbox({ "NoTitleBar" }, { isChecked = NoTitleBar })
        Iris.NextColumn()
        Iris.Checkbox({ "NoBackground" }, { isChecked = NoBackground })
        Iris.NextColumn()
        Iris.Checkbox({ "NoCollapse" }, { isChecked = NoCollapse })
        Iris.NextColumn()
        Iris.Checkbox({ "NoClose" }, { isChecked = NoClose })
        Iris.NextColumn()
        Iris.Checkbox({ "NoMove" }, { isChecked = NoMove })
        Iris.NextColumn()
        Iris.Checkbox({ "NoScrollbar" }, { isChecked = NoScrollbar })
        Iris.NextColumn()
        Iris.Checkbox({ "NoResize" }, { isChecked = NoResize })
        Iris.NextColumn()
        Iris.Checkbox({ "NoNav" }, { isChecked = NoNav })
        Iris.NextColumn()
        Iris.Checkbox({ "NoMenu" }, { isChecked = NoMenu })
        Iris.End()
        Iris.End()

        -- stylua: ignore end

        widgetEventInteractivity()

        widgetStateInteractivity()

        Iris.CollapsingHeader({ "Recursive Tree" })
        recursiveTree()
        Iris.End()

        dynamicStyle()

        Iris.Separator()

        Iris.CollapsingHeader({ "Widgets" })
        for _, name in widgetDemosOrder do
            widgetDemos[name]()
        end
        Iris.End()

        tablesDemo()

        layoutDemo()
        Iris.End()

        if showRecursiveWindow.value then
            recursiveWindow(showRecursiveWindow)
        end
        if showRuntimeInfo.value then
            runtimeInfo()
        end
        if showStyleEditor.value then
            styleEditor()
        end
        if showWindowlessDemo.value then
            windowlessDemo()
        end

        if showMainMenuBarWindow.value then
            mainMenuBarExample()
        end
    end
end
