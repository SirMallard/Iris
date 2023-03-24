return function(Iris)
    local showRecursiveWindow = Iris.State(false)
    local showWidgetInfo = Iris.State(false)
    local showRuntimeInfo = Iris.State(false)
    local showStyleEditor = Iris.State(false)

    local function recursiveTree()
        local theTree = Iris.Tree({"Recursive Tree"})
        if theTree.state.isUncollapsed.value then
            recursiveTree()
        end
        Iris.End()
    end

    local function recursiveWindow(parentCheckboxState)
        Iris.Window({"Window"}, {size = Iris.State(Vector2.new(150, 100)), isOpened = parentCheckboxState})
            local theCheckbox = Iris.Checkbox({"Recurse Again"})
        Iris.End()
        if theCheckbox.isChecked.value then
            recursiveWindow(theCheckbox.isChecked)
        end
    end

    local function widgetInfo()
        local function parse2DArray(array)
            Iris.Table({#array[1]})
                for i,v in array do
                    for i,v2 in v do
                        Iris.NextColumn()
                        Iris.Text({tostring(v2)})
                    end
                end
            Iris.End()
        end
        Iris.Window({"Widget Info"},{size = Iris.State(Vector2.new(600, 300)), isOpened = showWidgetInfo})
            Iris.Text({"information of Iris Widgets."})
            Iris.Table({1, [Iris.Args.Table.RowBg] = false})
                Iris.NextColumn()
                Iris.Tree({"\nIris.Text / Iris.TextWrapped\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"}, 
                        {"Text: String", "", ""}, 
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Button / Iris.SmallButton\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"}, 
                        {"Text: string", "clicked: boolean", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Separator\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Indent\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Width: number", "", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.SameLine\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Width: number", "", ""},
                        {"VerticalAlignment: Enum.VerticalAlignment", "", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Group\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Checkbox\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Text: string", "checked: boolean", "isChecked: boolean"},
                        {"", "unchecked: boolean", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Tree\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Text: string", "collapsed: boolean", "isUncollapsed: boolean"},
                        {"SpanAvailWidth: boolean", "uncollapsed: boolean", ""},
                        {"NoIndent: boolean", "", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.InputNum\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Text: string", "numberChanged: boolean", "number: number"},
                        {"Increment: number", "", ""},
                        {"Min: number", "", ""},
                        {"Max: number", "", ""},
                        {"Format: string", "", ""},
                        {"NoButtons: boolean", "", ""},
                        {"NoField: boolean", "", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.InputText\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Text: string", "textChanged: boolean", "text: string"},
                        {"TextHint: string", "", ""}
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Window\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments", "Events", "States"},
                        {"Title: string", "closed: boolean", "size: Vector2"},
                        {"NoTitleBar: boolean", "opened: boolean", "position: Vector2"},
                        {"NoBackground: boolean", "collapsed: boolean", "isUncollapsed: boolean"},
                        {"NoCollapse: boolean", "uncollapsed: boolean", "isOpened: boolean"},
                        {"NoClose: boolean", "", "scrollDistance: number"},
                        {"NoMove: boolean", "", ""},
                        {"NoScrollbar: boolean", "", ""},
                        {"NoResize: boolean", "", ""}
                    })
                Iris.End()
            Iris.End()
        Iris.End()
    end

    local function runtimeInfo()
        local runtimeInfoWindow = Iris.Window({"Runtime Info"}, {isOpened = showRuntimeInfo})
            local widgetCount = 0
            local str = ""
            local lastVDOM = Iris._lastVDOM
            for i,v in lastVDOM do
                widgetCount += 1
                str ..= "\n" .. v.ID .. " - " .. v.type
            end

            local rollingDT = Iris.State(0)
            local lastT = Iris.State(os.clock())

            local t = os.clock()
            local dt = t - lastT.value
            rollingDT.value += (dt - rollingDT.value) * 0.2
            lastT.value = t
            Iris.Text({string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT.value*1000, 1/rollingDT.value)})
            Iris.Text({string.format("Number of Widgets: %d", widgetCount)})
            Iris.Text({string.format(
                "Window Position: (%d, %d), Window Size: (%d, %d)",
                runtimeInfoWindow.position.value.X, runtimeInfoWindow.position.value.Y,
                runtimeInfoWindow.size.value.X, runtimeInfoWindow.size.value.Y
            )})

            Iris.Tree({"Widget IDs"})
                Iris.Text({str})
            Iris.End()
        Iris.End()
    end

    local styleEditor
    do
        -- styleEditor is stupidly coded because Iris dosent have higher-order widgets yet, (Iris.InputNum2 etc.)
        local styleStates = {}
        do -- init style states
            for i,v in Iris._style do
                if typeof(v) == "Color3" then
                    styleStates[i .. "R"] = Iris.State(v.R * 255)
                    styleStates[i .. "G"] = Iris.State(v.G * 255)
                    styleStates[i .. "B"] = Iris.State(v.B * 255)
                elseif typeof(v) == "UDim" then
                    styleStates[i .. "Scale"] = Iris.State(v.Scale)
                    styleStates[i .. "Offset"] = Iris.State(v.Offset)
                elseif typeof(v) == "Vector2" then
                    styleStates[i .. "X"] = Iris.State(v.X)
                    styleStates[i .. "Y"] = Iris.State(v.Y)
                elseif typeof(v) == "EnumItem" then
                    styleStates[i] = Iris.State(v.Name)
                else
                    styleStates[i] = Iris.State(v)
                end
            end
        end

        local function refreshStyleStates()
            for i,v in Iris._style do
                if typeof(v) == "Color3" then
                    styleStates[i .. "R"]:Set(v.R * 255)
                    styleStates[i .. "G"]:Set(v.G * 255)
                    styleStates[i .. "B"]:Set(v.B * 255)
                elseif typeof(v) == "UDim" then
                    styleStates[i .. "Scale"]:Set(v.Scale)
                    styleStates[i .. "Offset"]:Set(v.Offset)
                elseif typeof(v) == "Vector2" then
                    styleStates[i .. "X"]:Set(v.X)
                    styleStates[i .. "Y"]:Set(v.Y)
                elseif typeof(v) == "EnumItem" then
                    styleStates[i]:Set(v.Name)
                else
                    styleStates[i]:Set(v)
                end
            end
        end

        local function InputVector2(name)
            Iris.PushStyle({ItemWidth = UDim.new(0, 100 - Iris._style.ItemInnerSpacing.X)})
                Iris.SameLine()
                    local X = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "X"]}
                    )
                    local Y = Iris.InputNum(
                        {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Y"]}
                    )
                    if X.numberChanged or Y.numberChanged then
                        Iris.UpdateGlobalStyle({[name] = Vector2.new(X.number.value, Y.number.value)})
                    end
                Iris.End()
            Iris.PopStyle()
        end

        local function InputUDim(name)
            Iris.PushStyle({ItemWidth = UDim.new(0, 100 - Iris._style.ItemInnerSpacing.X)})
                Iris.SameLine()
                    local Scale = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Scale"]}
                    )
                    local Offset = Iris.InputNum(
                        {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Offset"]}
                    )
                    if Scale.numberChanged or Offset.numberChanged then
                        Iris.UpdateGlobalStyle({[name] = UDim.new(Scale.number.value, Offset.number.value)})
                    end
                Iris.End()
            Iris.PopStyle()
        end

        local function InputColor4(name, transparencyName)
            Iris.PushStyle({ItemWidth = UDim.new(0, 50 - Iris._style.ItemInnerSpacing.X)})
                Iris.SameLine()
                    local R = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "R"]}
                    )
                    local G = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "G"]}
                    )
                    local B = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "B"]}
                    )
                    local A = Iris.InputNum(
                        {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%.3f"},
                        {number = styleStates[transparencyName]}
                    )
                    if R.numberChanged or G.numberChanged or B.numberChanged or A.numberChanged then
                        Iris.UpdateGlobalStyle({[name] = Color3.fromRGB(R.number.value, G.number.value, B.number.value), [transparencyName] = A.number.value})
                    end
                Iris.End()
            Iris.PopStyle()
        end

        local function InputInt(name)
            Iris.PushStyle({ItemWidth = UDim.new(0, 200)})
                local I = Iris.InputNum(
                    {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                    {number = styleStates[name]}
                )
                if I.numberChanged then
                    Iris.UpdateGlobalStyle({[name] = I.number.value})
                end
            Iris.PopStyle()
        end

        local function InputEnum(name, enumType, default)
            Iris.PushStyle({ItemWidth = UDim.new(0, 200)})
                local V = Iris.InputText(
                    {name},
                    {text = styleStates[name]}
                )
                if V.textChanged then
                    local isValidEnum = false
                    for _, _enumItem in ipairs(enumType:GetEnumItems()) do
                        if _enumItem.Name == V.text.value then
                            isValidEnum = true
                            break
                        end
                    end
                    if isValidEnum then
                        Iris.UpdateGlobalStyle({[name] = enumType[V.text.value]})
                    else
                        Iris.UpdateGlobalStyle({[name] = default})
                        styleStates[name]:Set(tostring(default))
                    end
                end
            Iris.PopStyle()
        end

        local styleList = {
            {[0] = "Sizes",
                function()
                    Iris.Text({"Main"})
                    InputVector2("WindowPadding")
                    InputVector2("WindowResizePadding")
                    InputVector2("FramePadding")
                    InputVector2("CellPadding")
                    InputVector2("ItemSpacing")
                    InputVector2("ItemInnerSpacing")
                    InputInt("IndentSpacing")
                    InputInt("ScrollbarSize")

                    Iris.Text({"Borders"})
                    InputInt("WindowBorderSize")
                    InputInt("FrameBorderSize")

                    Iris.Text({"Rounding"})
                    InputInt("FrameRounding")

                    Iris.Text({"Alignment"})
                    InputEnum("WindowTitleAlign", Enum.LeftRight, Enum.LeftRight.Left)
                end
            },
            {[0] = "Colors",
                function()
                    InputColor4("TextColor", "TextTransparency")
                    InputColor4("TextDisabledColor", "TextDisabledTransparency")

                    InputColor4("BorderColor", "BorderTransparency")
                    InputColor4("BorderActiveColor", "BorderActiveTransparency")

                    InputColor4("WindowBgColor", "WindowBgTransparency")
                    InputColor4("ScrollbarGrabColor", "ScrollbarGrabTransparency")

                    InputColor4("TitleBgColor", "TitleBgTransparnecy")
                    InputColor4("TitleBgActiveColor", "TitleBgActiveTransparency")
                    InputColor4("TitleBgCollapsedColor", "TitleBgCollapsedTransparency")

                    InputColor4("FrameBgColor", "FrameBgTransparency")
                    InputColor4("FrameBgHoveredColor", "FrameBgHoveredTransparency")
                    InputColor4("FrameBgActiveColor", "FrameBgActiveTransparency")

                    InputColor4("ButtonColor", "ButtonTransparency")
                    InputColor4("ButtonHoveredColor", "ButtonHoveredTransparency")
                    InputColor4("ButtonActiveColor", "ButtonActiveTransparency")

                    InputColor4("HeaderColor", "HeaderTransparency")
                    InputColor4("HeaderHoveredColor", "HeaderHoveredTransparency")
                    InputColor4("HeaderActiveColor", "HeaderActiveTransparency")

                    InputColor4("SelectionImageObjectColor", "SelectionImageObjectTransparency")
                    InputColor4("SelectionImageObjectBorderColor", "SelectionImageObjectBorderTransparency")

                    InputColor4("TableBorderStrongColor", "TableBorderStrongTransparency")
                    InputColor4("TableBorderLightColor", "TableBorderLightTransparency")
                    InputColor4("TableRowBgColor", "TableRowBgTransparency")
                    InputColor4("TableRowBgAltColor", "TableRowBgAltTransparency")

                    InputColor4("NavWindowingHighlightColor", "NavWindowingHighlightTransparency")
                    InputColor4("NavWindowingDimBgColor", "NavWindowingDimBgTransparency")

                    InputColor4("SeparatorColor", "SeparatorTransparency")

                    InputColor4("CheckMarkColor", "CheckMarkTransparency")
                end
            },
            {[0] = "Fonts",
                function()
                    InputEnum("TextFont", Enum.Font, Enum.Font.Code)
                    InputInt("TextSize")
                end
            }
        }
        styleEditor = function()
            local SelectedPanel = Iris.State(1)
    
            Iris.Window({"Style Editor"}, {isOpened = showStyleEditor})
                Iris.Text({"Customize the look of Iris in realtime."})
                Iris.SameLine()
                    if Iris.SmallButton({"Light Theme"}).clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorLight)
                        refreshStyleStates()
                    end
                    if Iris.SmallButton({"Dark Theme"}).clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                        refreshStyleStates()
                    end
                Iris.End()
                Iris.SameLine()
                    if Iris.SmallButton({"Classic Size"}).clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                        refreshStyleStates()
                    end
                    if Iris.SmallButton({"Larger Size"}).clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClear)
                        refreshStyleStates()
                    end
                Iris.End()
                if Iris.SmallButton({"Reset Everything"}).clicked then
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                    refreshStyleStates()
                end
                Iris.Separator()
                Iris.SameLine()
                    for i,v in ipairs(styleList) do
                        if Iris.SmallButton({v[0]}).clicked then
                            SelectedPanel:Set(i)
                        end
                    end
                Iris.End()
                styleList[SelectedPanel:Get()][1]()
            Iris.End()
        end
    end

    local function widgetEventInteractivity()
        Iris.Tree({"Widget Event Interactivity"})
            local ClickCount = Iris.State(0)
            if Iris.Button({"Click to increase Number"}).clicked then
                ClickCount:Set(ClickCount:Get() + 1)
            end
            Iris.Text({string.format("The Number is: %d", ClickCount:Get())})
            local ShowTextTimer = Iris.State(0)
            Iris.SameLine()
                if Iris.Button({"Click to show text for 20 frames"}).clicked then
                    ShowTextTimer:Set(20)
                end
                if ShowTextTimer:Get() > 0 then
                    Iris.Text({"Here i am!"})
                end
            Iris.End()
            ShowTextTimer:Set(math.max(0, ShowTextTimer:Get() - 1))
            Iris.Text({string.format("Text Timer: %d", ShowTextTimer:Get())})
        Iris.End()
    end

    local function widgetStateInteractivity()
        Iris.Tree({"Widget State Interactivity"})
            local Checkbox0 = Iris.Checkbox({"Widget-Generated State"})
            Iris.Text({`isChecked: {Checkbox0.state.isChecked.value}`})
            
            local CheckboxState0 = Iris.State(false)
            local Checkbox1 = Iris.Checkbox({"User-Generated State"}, {isChecked = CheckboxState0})
            Iris.Text({`isChecked: {Checkbox1.state.isChecked.value}`})

            local Checkbox2 = Iris.Checkbox({"Widget Coupled State"})
            local Checkbox3 = Iris.Checkbox({"Coupled to above Checkbox"}, {isChecked = Checkbox2.state.isChecked})
            Iris.Text({`isChecked: {Checkbox3.state.isChecked.value}`})

            local CheckboxState1 = Iris.State(false)
            local Checkbox4 = Iris.Checkbox({"Widget and Code Coupled State"}, {isChecked = CheckboxState1})
            local Button0 = Iris.Button({"Click to toggle above checkbox"})
            if Button0.clicked then
                CheckboxState1:Set(not CheckboxState1:Get())
            end
            Iris.Text({`isChecked: {CheckboxState1.value}`})

        Iris.End()
    end

    local widgetDemos = {
        Basic = function()
            Iris.Tree({"Basic"})
                Iris.Button({"Button"})
                Iris.SmallButton({"SmallButton"})
                Iris.Text({"Text"})
                Iris.PushStyle({ItemWidth = UDim.new(1, 0)})
                    Iris.TextWrapped({string.rep("Text Wrapped ", 5)})
                Iris.PopStyle()
                Iris.PushStyle({TextColor = Color3.fromRGB(255, 128, 0)})
                    Iris.Text({"Colored Text"})
                Iris.PopStyle()
            Iris.End()
        end,

        Tree = function()
            Iris.Tree({"Trees"})
                Iris.Tree({"Tree using SpanAvailWidth", [Iris.Args.Tree.SpanAvailWidth] = true})
                Iris.End()

                local tree1 = Iris.Tree({"Tree with Children"})
                    Iris.Text({"Im inside the first tree!"})
                    Iris.Button({"Im a button inside the first tree!"})
                    Iris.Tree({"Im a tree inside the first tree!"})
                        Iris.Text({"I am the innermost text!"})
                    Iris.End()
                Iris.End()

                local collapseCheckbox = Iris.Checkbox({"Toggle above tree"}, {isChecked = tree1.state.isUncollapsed})
                
            Iris.End()
        end,

        Group = function()
            Iris.Tree({"Groups"})
                Iris.SameLine()
                    Iris.Group()
                        Iris.Text({"I am in group A"})
                        Iris.Button({"Im also in A"})
                    Iris.End()
                    Iris.Separator()
                    Iris.Group()
                        Iris.Text({"I am in group B"})
                        Iris.Button({"Im also in B"})
                        Iris.Button({"Also group B"})
                    Iris.End()
                Iris.End()
            Iris.End()
        end,

        Indent = function()
            Iris.Tree({"Indents"})
                Iris.Text({"Not Indented"})
                Iris.Indent()
                    Iris.Text({"Indented"})
                    Iris.Indent({7})
                        Iris.Text({"Indented by 7 more pixels"})
                    Iris.End()
                    Iris.Indent({-7})
                        Iris.Text({"Indented by 7 less pixels"})
                    Iris.End()
                Iris.End()
            Iris.End()
        end,

        InputNum = function()
            Iris.Tree({"Input Num"})
                local NoField, NoButtons, Min, Max, Increment, Format = 
                Iris.State(false), Iris.State(false), Iris.State(0), Iris.State(100), Iris.State(1), Iris.State("%d")

                Iris.PushStyle({ItemWidth = UDim.new(0, 150)})
                local InputNum = Iris.InputNum({"Input Number",
                    [Iris.Args.InputNum.NoField] = NoField.value,
                    [Iris.Args.InputNum.NoButtons] = NoButtons.value,
                    [Iris.Args.InputNum.Min] = Min.value,
                    [Iris.Args.InputNum.Max] = Max.value,
                    [Iris.Args.InputNum.Increment] = Increment.value,
                    [Iris.Args.InputNum.Format] = Format.value,
                })
                Iris.PopStyle()
                Iris.Text({string.format("The Value is: %d", InputNum.number.value)})
                if Iris.Button({"Randomize Number"}).clicked then
                    InputNum.number:Set(math.random(1,99))
                end
                Iris.Separator()
                Iris.Checkbox({"NoField"}, {isChecked = NoField})
                Iris.Checkbox({"NoButtons"}, {isChecked = NoButtons})
            Iris.End()
        end,

        InputText = function()
            Iris.Tree({"Input Text"})
                Iris.PushStyle({ItemWidth = UDim.new(0, 250)})
                local InputText = Iris.InputText({"Input Text Test", [Iris.Args.InputText.TextHint] = "Input Text here"})
                Iris.PopStyle()
                Iris.Text({string.format("The text is: %s", InputText.text.value)})
            Iris.End()
        end
    }
    local widgetDemosOrder = {"Basic", "Tree", "Group", "Indent", "InputNum", "InputText"}

    return function()
        local NoTitleBar = Iris.State(false)
        local NoBackground = Iris.State(false)
        local NoCollapse = Iris.State(false)
        local NoClose = Iris.State(true)
        local NoMove = Iris.State(false)
        local NoScrollbar = Iris.State(false)
        local NoResize = Iris.State(false)
        local NoNav = Iris.State(false)

        Iris.Window({"Iris Demo Window",
            [Iris.Args.Window.NoTitleBar] = NoTitleBar.value,
            [Iris.Args.Window.NoBackground] = NoBackground.value,
            [Iris.Args.Window.NoCollapse] = NoCollapse.value,
            [Iris.Args.Window.NoClose] = NoClose.value,
            [Iris.Args.Window.NoMove] = NoMove.value,
            [Iris.Args.Window.NoScrollbar] = NoScrollbar.value,
            [Iris.Args.Window.NoResize] = NoResize.value,
            [Iris.Args.Window.NoNav] = NoNav.value
        }, {size = Iris.State(Vector2.new(600, 550)), position = Iris.State(Vector2.new(100, 25))})

            Iris.Text{"Iris says hello!"}
            Iris.Separator()

            Iris.Table({3, false, false, false})
                Iris.NextColumn()
                Iris.Checkbox({"Recursive Window"}, {isChecked = showRecursiveWindow})
                Iris.NextColumn()
                Iris.Checkbox({"Widget Info"}, {isChecked = showWidgetInfo})
                Iris.NextColumn()
                Iris.Checkbox({"Runtime Info"}, {isChecked = showRuntimeInfo})
                Iris.NextColumn()
                Iris.Checkbox({"Style Editor"}, {isChecked = showStyleEditor})
            Iris.End()

            Iris.Separator()

            Iris.Tree({"Window Options"})
                Iris.Table({3, false, false, false})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoTitleBar"}, {isChecked = NoTitleBar})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoBackground"}, {isChecked = NoBackground})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoCollapse"}, {isChecked = NoCollapse})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoClose"}, {isChecked = NoClose})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoMove"}, {isChecked = NoMove})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoScrollbar"}, {isChecked = NoScrollbar})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoResize"}, {isChecked = NoResize})
                    Iris.NextColumn()
                    Iris.Checkbox({"NoNav"}, {isChecked = NoNav})
                Iris.End()
            Iris.End()

            widgetEventInteractivity()

            widgetStateInteractivity()

            recursiveTree()

            Iris.Separator()

            Iris.Tree({"Widgets"})
                for i,name in widgetDemosOrder do
                    widgetDemos[name]()
                end
            Iris.End()

            local isTablesTreeOpened = Iris.State(false)
            Iris.Tree({"Tables & Columns", [Iris.Args.Tree.NoIndent] = true}, {isUncollapsed = isTablesTreeOpened})
            if isTablesTreeOpened.value == false then
                -- optimization to skip code which draws GUI which wont be seen.
                -- its a trade off because when the tree becomes opened widgets will all have to be generated again.
                -- Dear ImGui utilizes the same trick, but its less useful here because the Retained mode Backend
            Iris.End()
            else
                Iris.Text({"Table using NextRow and NextColumn syntax:"})
                Iris.Table({3})
                    for i = 1,4 do
                        Iris.NextRow()
                        for i2 = 1,3 do
                            Iris.NextColumn()
                            Iris.Text({`Row: {i}, Column: {i2}`})
                        end
                    end
                Iris.End()

                Iris.Text({""})
                Iris.Text({"Table using NextColumn only syntax:"})

                Iris.Table({3})
                    for i = 1,4 do
                        for i2 = 1,3 do
                            Iris.NextColumn()
                            Iris.Text({`Row: {i}, Column: {i2}`})
                        end
                    end
                Iris.End()

                Iris.Separator()

                local TableRowBg = Iris.State(false)
                local TableBordersOuter = Iris.State(false)
                local TableBordersInner = Iris.State(true)
                local TableUseButtons = Iris.State(true)

                Iris.Text({"Table with Customizable Arguments"})
                Iris.Table({
                    2,
                    [Iris.Args.Table.RowBg] = TableRowBg.value,
                    [Iris.Args.Table.BordersOuter] = TableBordersOuter.value,
                    [Iris.Args.Table.BordersInner] = TableBordersInner.value
                })
                    for i = 1,5 do
                        for i2 = 1,2 do
                            Iris.NextColumn();
                            if TableUseButtons.value then
                                Iris.Button({`Year: {i + 2000}, Month: {i2}`})
                            else
                                Iris.Text({`Year: {i + 2000}, Month: {i2}`})
                            end
                        end
                    end
                Iris.End()

                Iris.Checkbox({"RowBg"}, {isChecked = TableRowBg})
                Iris.Checkbox({"BordersOuter"}, {isChecked = TableBordersOuter})
                Iris.Checkbox({"BordersInner"}, {isChecked = TableBordersInner})
                Iris.Checkbox({"Use Buttons"}, {isChecked = TableUseButtons})

            Iris.End()
            end
        Iris.End()

        if showRecursiveWindow.value then
            recursiveWindow(showRecursiveWindow)
        end
        if showWidgetInfo.value then
            widgetInfo()
        end
        if showRuntimeInfo.value then
            runtimeInfo()
        end
        if showStyleEditor.value then
            styleEditor()
        end
    end
end