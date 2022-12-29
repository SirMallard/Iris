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
        local function drawData(_arguments, _events, _state)
            Iris.SameLine({[Iris.Args.SameLine.VerticalAlignment] = Enum.VerticalAlignment.Top})
                Iris.Group()
                    Iris.Text({"Arguments"})
                    Iris.Separator()
                    Iris.Text({_arguments})
                Iris.End()
                Iris.Separator()
                Iris.Group()
                    Iris.Text({"Events"})
                    Iris.Separator()
                    Iris.Text({_events})
                Iris.End()
                Iris.Separator()
                Iris.Group()
                    Iris.Text({"State"})
                    Iris.Separator()
                    Iris.Text({_state})
                Iris.End()
            Iris.End()
            Iris.Separator()
        end
        Iris.Window({"Widget Info"},{size = Iris.State(Vector2.new(450, 300)), isOpened = showWidgetInfo})
            Iris.Text({"information of Iris Widgets."})
            Iris.Tree({"Iris.Text / Iris.TextWrapped"})
                drawData("Text: string", "", "")
            Iris.End()
            Iris.Tree({"Iris.Button / Iris.SmallButton"})
                drawData("Text: string", "clicked: boolean", "")
            Iris.End()
            Iris.Tree({"Iris.Separator"})
                drawData("", "", "")
            Iris.End()
            Iris.Tree({"Iris.Indent"})
                drawData("Width: number", "", "")
            Iris.End()
            Iris.Tree({"Iris.SameLine"})
                drawData("Width: number\nVerticalAlignment: Enum.VerticalAlignment", "", "")
            Iris.End()
            Iris.Tree({"Iris.Group"})
                drawData("", "", "")
            Iris.End()
            Iris.Tree({"Iris.Checkbox"})
                drawData(
                    "Text: string",
                    "checked: boolean\nunchecked: boolean",
                    "isChecked: boolean"
                )
            Iris.End()
            Iris.Tree({"Iris.Tree"})
                drawData(
                    "Text: string\nSpanAvailWidth: boolean",
                    "collapsed: boolean\nuncollapsed: boolean",
                    "isUncollapsed: boolean"
                )
            Iris.End()
            Iris.Tree({"Iris.InputNum"})
                drawData(
                    "Text: string\nIncrement: number\nMin: number\nMax: number\nFormat: string\nNoButtons: boolean\nNoField: boolean",
                    "valueChanged: boolean",
                    "number: number"
                )
            Iris.End()
            Iris.Tree({"Iris.InputText"})
                drawData(
                    "Text: string\nTextHint: string",
                    "textChanged: boolean",
                    "text: string"
                )
            Iris.End()
            Iris.Tree({"Iris.Window"})
                drawData(
                    "Title: string\nNoTitleBar: boolean\nNoBackground: boolean\nNoCollapse: boolean\nNoClose: boolean\nNoMove: boolean\nNoScrollbar: boolean\nNoResize: boolean",
                    "closed: boolean\nopened: boolean\ncollapsed: boolean\nuncollapsed: boolean",
                    "size: Vector2\nposition: Vector2\nisUncollapsed: boolean\nisOpened: boolean"
                )
            Iris.End()
        Iris.End()
    end

    local function runtimeInfo()
        Iris.Window({"Runtime Info"}, {isOpened = showRuntimeInfo})
            local widgetCount = 0
            local str = ""
            local a = Iris._GetVDOM()
            for i,v in a do
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

            Iris.Tree({"Widget IDs"})
                Iris.Text({str})
            Iris.End()
        Iris.End()
    end

    local function styleEditor()
        local styleLists = {
            {
                TextColor = Color3.fromRGB(255, 255, 255),
                TextDisabledColor = Color3.fromRGB(128, 128, 128),

                BorderColor = Color3.fromRGB(110, 110, 125),
                BorderActiveColor = Color3.fromRGB(160, 160, 175),
        
                WindowBgColor = Color3.fromRGB(15, 15, 15),

                ScrollbarGrabColor = Color3.fromRGB(128, 128, 128),
        
                TitleBgColor = Color3.fromRGB(10, 10, 10),
                TitleBgActiveColor = Color3.fromRGB(41, 74, 122),
                TitleBgCollapsedColor = Color3.fromRGB(0, 0, 0),
        
                FrameBgColor = Color3.fromRGB(41, 74, 122),
                FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
                FrameBgActiveColor = Color3.fromRGB(66, 150, 250),

                ButtonColor = Color3.fromRGB(66, 150, 250),
                ButtonHoveredColor = Color3.fromRGB(66, 150, 250),
                ButtonActiveColor = Color3.fromRGB(15, 135, 250),

                HeaderColor = Color3.fromRGB(66, 150, 250),
                HeaderHoveredColor = Color3.fromRGB(66, 150, 250),
                HeaderActiveColor = Color3.fromRGB(66, 150, 250),

                SelectionImageObjectColor = Color3.fromRGB(255, 255, 255),
                SelectionImageObjectBorderColor = Color3.fromRGB(255, 255, 255),

                NavWindowingHighlightColor = Color3.fromRGB(255, 255, 255),
                NavWindowingDimBgColor = Color3.fromRGB(204, 204, 204),

                SeparatorColor = Color3.fromRGB(110, 110, 128),

                CheckMarkColor = Color3.fromRGB(66, 150, 250),
            },
            {
                ItemWidth = UDim.new(1, 0),

                WindowPadding = Vector2.new(8, 8),
                FramePadding = Vector2.new(4, 3),
                ItemSpacing = Vector2.new(8, 4),
                ItemInnerSpacing = Vector2.new(4, 4),
                IndentSpacing = 21,
                TextFont = Enum.Font.Code,
                TextSize = 13,
                FrameBorderSize = 0,
                FrameRounding = 0,
                WindowBorderSize = 1,
                WindowTitleAlign = Enum.LeftRight.Left,
        
                ScrollbarSize = 7, -- Dear ImGui is 14 but these are equal because ScrollbarSize property is doubled by roblox
            },
            {
                TextTransparency = 0,
                TextDisabledTransparency = 0,
                WindowBgTransparency = 0.072,
                ScrollbarGrabTransparency = 0,
                TitleBgTransparency = 0,
                TitleBgActiveTransparency = 0,
                TitleBgCollapsedTransparency = .5,
                FrameBgTransparency = 0.46,
                FrameBgHoveredTransparency = 0.46,
                FrameBgActiveTransparency = 0.33,
                ButtonTransparency = 0.6,
                ButtonHoveredTransparency = 0,
                ButtonActiveTransparency = 0,
                HeaderTransparency = 0.31,
                HeaderHoveredTransparency = 0.2,
                HeaderActiveTransparency = 0,
                SelectionImageObjectTransparency = .8,
                SelectionImageObjectBorderTransparency = 0,
                NavWindowingHighlightTransparency = .3,
                NavWindowingDimBgTransparency = .65,
                SeparatorTransparency = .5,
                CheckMarkTransparency = 0
            }
        }
        local SelectedListIndex = Iris.State(1)
        Iris.Window({"Style Editor"}, {isOpened = showStyleEditor})
            Iris.Text({"Customize the look of Iris in realtime."})
            Iris.SameLine()
                if Iris.SmallButton({"Light Theme"}).clicked then
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorLight)
                    Iris.ForceRefresh()
                end
                if Iris.SmallButton({"Dark Theme"}).clicked then
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                    Iris.ForceRefresh()
                end
                if Iris.SmallButton({"Reset Sizes"}).clicked then
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                    Iris.ForceRefresh()
                end
                if Iris.SmallButton({"Reset Everything"}).clicked then
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                    Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                    Iris.ForceRefresh()
                end
            Iris.End()
            Iris.Separator()
            Iris.SameLine()
                if Iris.SmallButton({"Colors"}).clicked then
                    SelectedListIndex:Set(1)
                end
                if Iris.SmallButton({"Sizes"}).clicked then
                    SelectedListIndex:Set(2)
                end
                if Iris.SmallButton({"Transparency"}).clicked then
                    SelectedListIndex:Set(3)
                end
                
            Iris.End()
            for i,v in styleLists[SelectedListIndex.value] do
                
                if type(v) == "number" then
                    Iris.PushStyle({ItemWidth = UDim.new(.5, 0)})
                        local thisNum = Iris.InputNum({i, if SelectedListIndex.value == 3 then 0.1 else 1, -math.huge, math.huge}, {number = Iris.State(v)})
                    Iris.PopStyle()

                    if thisNum.valueChanged then
                        Iris.UpdateGlobalStyle({[i] = thisNum.number.value})
                        Iris.ForceRefresh()
                    end
                elseif typeof(v) == "Vector2" then
                    Iris.PushStyle({ItemWidth = UDim.new(0, 60)})
                        Iris.SameLine()
                            local thisNumX = Iris.InputNum({"X"    , 1, 0, 100, [Iris.Args.InputNum.NoField] = true}, {number = Iris.State(v.X)})
                            local thisNumY = Iris.InputNum({"Y "..i, 1, 0, 100, [Iris.Args.InputNum.NoField] = true}, {number = Iris.State(v.Y)})
                        Iris.End()
                    Iris.PopStyle()

                    if thisNumX.valueChanged or thisNumY.valueChanged then
                        Iris.UpdateGlobalStyle({[i] = Vector2.new(thisNumX.number.value, thisNumY.number.value)})
                        Iris.ForceRefresh()
                    end
                elseif typeof(v) == "Color3" then
                    Iris.PushStyle({ItemWidth = UDim.new(0, 60)})
                        Iris.SameLine({25})
                            local thisNumR = Iris.InputNum(
                                {"R"    ,  5, 0, 255, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                                {number = Iris.State(math.round(v.R * 255))}
                            )
                            local thisNumG = Iris.InputNum(
                                {"G"    ,  5, 0, 255, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                                {number = Iris.State(math.round(v.G * 255))}
                            )
                            local thisNumB = Iris.InputNum(
                                {"B "..i,  5, 0, 255, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                                {number = Iris.State(math.round(v.B * 255))}
                            )
                        Iris.End()
                    Iris.PopStyle()

                    if thisNumR.valueChanged or thisNumG.valueChanged or thisNumB.valueChanged then
                        Iris.UpdateGlobalStyle({[i] = Color3.fromRGB(thisNumR.number.value, thisNumG.number.value, thisNumB.number.value)})
                        Iris.ForceRefresh()
                    end

                end
            end
        Iris.End()
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
            Iris.Text({"isChecked: " .. tostring(Checkbox0.state.isChecked.value)})
            
            local CheckboxState0 = Iris.State(false)
            local Checkbox1 = Iris.Checkbox({"User-Generated State"}, {isChecked = CheckboxState0})
            Iris.Text({"isChecked: " .. tostring(Checkbox1.state.isChecked.value)})

            local Checkbox2 = Iris.Checkbox({"Widget Coupled State"})
            local Checkbox3 = Iris.Checkbox({"Coupled to above Checkbox"}, {isChecked = Checkbox2.state.isChecked})
            Iris.Text({"isChecked: " .. tostring(Checkbox3.state.isChecked.value)})

            local CheckboxState1 = Iris.State(false)
            local Checkbox4 = Iris.Checkbox({"Widget and Code Coupled State"}, {isChecked = CheckboxState1})
            local Button0 = Iris.Button({"Click to toggle above checkbox"})
            if Button0.clicked then
                CheckboxState1:Set(not CheckboxState1:Get())
            end
            Iris.Text({"isChecked: " .. tostring(CheckboxState1.value)})

        Iris.End()
    end

    local widgetDemos = {
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
    local widgetDemosOrder = {"Tree", "Group", "Indent", "InputNum", "InputText"}

    return function()
        local NoTitleBar, NoBackground, NoCollapse, NoClose, NoMove, NoScrollbar, NoResize, NoNav =
        Iris.State(false), Iris.State(false), Iris.State(false), Iris.State(false), Iris.State(false), Iris.State(false), Iris.State(false), Iris.State(false)

        Iris.Window({"Iris Demo Window",
            [Iris.Args.Window.NoTitleBar] = NoTitleBar.value,
            [Iris.Args.Window.NoBackground] = NoBackground.value,
            [Iris.Args.Window.NoCollapse] = NoCollapse.value,
            [Iris.Args.Window.NoClose] = NoClose.value,
            [Iris.Args.Window.NoMove] = NoMove.value,
            [Iris.Args.Window.NoScrollbar] = NoScrollbar.value,
            [Iris.Args.Window.NoResize] = NoResize.value,
            [Iris.Args.Window.NoNav] = NoNav.value
        })

            Iris.Text{"Iris says hello!"}
            Iris.Separator()

            Iris.SameLine()
                Iris.Checkbox({"Recursive Window"}, {isChecked = showRecursiveWindow})
                Iris.Checkbox({"Widget Info"}, {isChecked = showWidgetInfo})
                Iris.Checkbox({"Runtime Info"}, {isChecked = showRuntimeInfo})
                Iris.Checkbox({"Style Editor"}, {isChecked = showStyleEditor})
            Iris.End()

            Iris.Separator()

            Iris.Tree({"Window Options"})
                Iris.Checkbox({"NoTitleBar"}, {isChecked = NoTitleBar})
                Iris.Checkbox({"NoBackground"}, {isChecked = NoBackground})
                Iris.Checkbox({"NoCollapse"}, {isChecked = NoCollapse})
                Iris.Checkbox({"NoClose"}, {isChecked = NoClose})
                Iris.Checkbox({"NoMove"}, {isChecked = NoMove})
                Iris.Checkbox({"NoScrollbar"}, {isChecked = NoScrollbar})
                Iris.Checkbox({"NoResize"}, {isChecked = NoResize})
                Iris.Checkbox({"NoNav"}, {isChecked = NoNav})
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