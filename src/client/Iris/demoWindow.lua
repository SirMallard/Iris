return function(Iris)
    local showRecursiveWindow = Iris.State(false)
    local showWidgetInfo = Iris.State(false)
    local showRuntimeInfo = Iris.State(false)
    local showStyleEditor = Iris.State(false)
    local showWindowlessDemo = Iris.State(false)

    -- shows each widgets functionality
    local widgetDemos = {
        Basic = function()
            Iris.Tree({"Basic"})
				local radioButtonState = Iris.State(1)
                Iris.Button({"Button"})
                Iris.SmallButton({"SmallButton"})
                Iris.Text({"Text"})
                Iris.TextWrapped({string.rep("Text Wrapped ", 5)})
                Iris.TextColored({"Colored Text", Color3.fromRGB(255, 128, 0)})
				Iris.SameLine()
					Iris.RadioButton({"Index '1'", 1}, {value = radioButtonState})
					Iris.RadioButton({"Index 'two'", "two"}, {value = radioButtonState})
                    if Iris.RadioButton({"Index 'false'", false}, {value = radioButtonState}).selected() == false then
                        if Iris.SmallButton({"Select last"}).clicked() then
                            radioButtonState:set(false)
                        end
                    end
				Iris.End()
				Iris.Text({"The Index is: " .. tostring(radioButtonState.value)})
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

                Iris.Checkbox({"Toggle above tree"}, {isChecked = tree1.state.isUncollapsed})
                
            Iris.End()
        end,

		CollapsingHeader = function()
			Iris.Tree({"Collapsing Headers"})
				Iris.CollapsingHeader({"A header"})
					Iris.Text({"This is under the first header!"})
				Iris.End()

				local secondHeader = Iris.State(true)
				Iris.CollapsingHeader({"Another header"}, { isUncollapsed = secondHeader })
					if Iris.Button({"Shhh... secret button!"}).clicked() then
						secondHeader:set(false)
					end
				Iris.End()
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

                local InputNum = Iris.InputNum({"Input Number",
                    [Iris.Args.InputNum.NoField] = NoField.value,
                    [Iris.Args.InputNum.NoButtons] = NoButtons.value,
                    [Iris.Args.InputNum.Min] = Min.value,
                    [Iris.Args.InputNum.Max] = Max.value,
                    [Iris.Args.InputNum.Increment] = Increment.value,
                    [Iris.Args.InputNum.Format] = Format.value,
                })
                Iris.Text({"The Value is: " .. InputNum.number.value})
                if Iris.Button({"Randomize Number"}).clicked() then
                    InputNum.number:set(math.random(1,99))
                end
                Iris.Separator()
                Iris.Checkbox({"NoField"}, {isChecked = NoField})
                Iris.Checkbox({"NoButtons"}, {isChecked = NoButtons})
            Iris.End()
        end,

        InputText = function()
            Iris.Tree({"Input Text"})
                Iris.PushConfig({ContentWidth = UDim.new(0, 250)})
                local InputText = Iris.InputText({"Input Text Test", [Iris.Args.InputText.TextHint] = "Input Text here"})
                Iris.PopConfig()
                Iris.Text({"The text is: " .. InputText.text.value})
            Iris.End()
        end,

        Tooltip = function()
            Iris.PushConfig({ContentWidth = UDim.new(0, 250)})
            Iris.Tree({"Tooltip"})
                if Iris.Text({"Hover over me to reveal a tooltip"}).hovered() then
                    Iris.Tooltip({"I am some helpful tooltip text"})
                end
                local dynamicText = Iris.State("Hello ")
                local numRepeat = Iris.State(1)
                if Iris.InputNum({"# of repeat", 1, 1, 50}, {number = numRepeat}).numberChanged() then
                    dynamicText:set(string.rep("Hello ", numRepeat:get()))
                end
                if Iris.Checkbox({"Show dynamic text tooltip"}).isChecked.value then
                    Iris.Tooltip({dynamicText:get()})
                end
            Iris.End()
            Iris.PopConfig()
        end
    }
    local widgetDemosOrder = {"Basic", "Tree", "CollapsingHeader", "Group", "Indent", "InputNum", "InputText", "Tooltip"}

    local function recursiveTree()
        local theTree = Iris.Tree({"Recursive Tree"})
        if theTree.state.isUncollapsed.value then
            recursiveTree()
        end
        Iris.End()
    end

    local function recursiveWindow(parentCheckboxState)
        Iris.Window({"Recursive Window"}, {size = Iris.State(Vector2.new(150, 100)), isOpened = parentCheckboxState})
            local theCheckbox = Iris.Checkbox({"Recurse Again"})
        Iris.End()
        if theCheckbox.isChecked.value then
            recursiveWindow(theCheckbox.isChecked)
        end
    end

    -- lists name, arguments, events, and states of each widget
    local function widgetInfo()
        local function parse2DArray(array)
            Iris.Table({#array[1]})
                for _, v in array do
                    for _, v2 in v do
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
                Iris.Tree({"\nIris.Text\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",    "Events", "States"}, 
                        {"Text: String", "",       ""      }, 
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.TextWrapped\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",    "Events", "States"}, 
                        {"Text: String", "",       ""      }, 
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Button\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",    "Events",           "States"}, 
                        {"Text: string", "clicked: boolean", ""      }
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.SmallButton\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",    "Events",           "States"}, 
                        {"Text: string", "clicked: boolean", ""      }
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
                        {"Arguments",     "Events", "States"},
                        {"Width: number", "",       ""      }
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.SameLine\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",                                 "Events", "States"},
                        {"Width: number",                             "",       ""      },
                        {"VerticalAlignment: Enum.VerticalAlignment", "",       ""      }
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
                        {"Arguments",    "Events",             "States"            },
                        {"Text: string", "checked: boolean",   "isChecked: boolean"},
                        {"",             "unchecked: boolean", ""                  }
                    })
                Iris.End()
				Iris.NextColumn()
				Iris.Tree({"\nIris.RadioButton\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
					parse2DArray({
						{"Arguments",	 "Events",               "States"	 },	
						{"Text: string", "activated: boolean",	 "value: any"},
						{"Value: any",	 "deactivated: boolean", ""			 },
                        {"",             "selected: boolean",      ""          }
					})
				Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Tree\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",               "Events",               "States"                },
                        {"Text: string",            "collapsed: boolean",   "isUncollapsed: boolean"},
                        {"SpanAvailWidth: boolean", "uncollapsed: boolean", ""                      },
                        {"NoIndent: boolean",       "",                     ""                      }
                    })
                Iris.End()
				Iris.NextColumn()
                Iris.Tree({"\nIris.CollapsingHeader\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",    "Events",               "States"                },
                        {"Text: string", "collapsed: boolean",   "isUncollapsed: boolean"},
                        {"",			 "uncollapsed: boolean", ""                      },
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.InputNum\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",          "Events",                 "States"        },
                        {"Text: string",       "numberChanged: boolean", "number: number"},
                        {"Increment: number",  "",                       ""              },
                        {"Min: number",        "",                       ""              },
                        {"Max: number",        "",                       ""              },
                        {"Format: string",     "",                       ""              },
                        {"NoButtons: boolean", "",                       ""              },
                        {"NoField: boolean",   "",                       ""              }
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.InputText\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",        "Events",               "States"      },
                        {"Text: string",     "textChanged: boolean", "text: string"},
                        {"TextHint: string", "",                     ""            }
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Table\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",             "Events","States"},
                        {"NumColumns: number",    "",      ""      },
                        {"RowBg: boolean",        "",      ""      },
                        {"BordersOuter: boolean", "",      ""      },
                        {"BordersInner: boolean", "",      ""      }
                    })
                Iris.End()
                Iris.NextColumn()
                Iris.Tree({"\nIris.Window\n", [Iris.Args.Tree.NoIndent] = true, [Iris.Args.Tree.SpanAvailWidth] = true})
                    parse2DArray({
                        {"Arguments",             "Events",               "States"                },
                        {"Title: string",         "closed: boolean",      "size: Vector2"         },
                        {"NoTitleBar: boolean",   "opened: boolean",      "position: Vector2"     },
                        {"NoBackground: boolean", "collapsed: boolean",   "isUncollapsed: boolean"},
                        {"NoCollapse: boolean",   "uncollapsed: boolean", "isOpened: boolean"     },
                        {"NoClose: boolean",      "",                     "scrollDistance: number"},
                        {"NoMove: boolean",       "",                     ""                      },
                        {"NoScrollbar: boolean",  "",                     ""                      },
                        {"NoResize: boolean",     "",                     ""                      }
                    })
                Iris.End()
            Iris.End()
        Iris.End()
    end

    -- shows list of runtime widgets and states, including IDs. shows other info about runtime and can show widgets/state info in depth.
    local function runtimeInfo()
        local runtimeInfoWindow = Iris.Window({"Runtime Info"}, {isOpened = showRuntimeInfo})
            local lastVDOM = Iris._lastVDOM
            local states = Iris._states

            local rollingDT = Iris.State(0)
            local lastT = Iris.State(os.clock())

            local t = os.clock()
            local dt = t - lastT.value
            rollingDT.value += (dt - rollingDT.value) * 0.2
            lastT.value = t
            Iris.Text({string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT.value*1000, 1/rollingDT.value)})

            Iris.Text({string.format(
                "Window Position: (%d, %d), Window Size: (%d, %d)",
                runtimeInfoWindow.position.value.X, runtimeInfoWindow.position.value.Y,
                runtimeInfoWindow.size.value.X, runtimeInfoWindow.size.value.Y
            )})

            Iris.PushConfig({ItemWidth = UDim.new(0.5, 100)})
            local enteredText = Iris.InputText({"Enter an ID to learn more about it."}, {text = Iris.State(runtimeInfoWindow.ID)}).text.value
            Iris.PopConfig()

            Iris.Indent()
                local enteredWidget = lastVDOM[enteredText]
                local enteredState = states[enteredText]
                if enteredWidget then
                    Iris.Table({1, [Iris.Args.Table.RowBg] = false})
                        Iris.Text({string.format("The ID, \"%s\", is a widget", enteredText)})
                        Iris.NextRow()

                        Iris.Text({string.format("Widget is type: %s", enteredWidget.type)})
                        Iris.NextRow()

                        Iris.Tree({"Widget has Args:"}, {isUncollapsed = Iris.State(true)})
                            for i,v in enteredWidget.arguments do
                                Iris.Text({i .. " - " .. tostring(v)})
                            end
                        Iris.End()
                        Iris.NextRow()

                        if enteredWidget.state then
                            Iris.Tree({"Widget has State:"}, {isUncollapsed = Iris.State(true)})
                            for i,v in enteredWidget.state do
                                Iris.Text({i .. " - " .. tostring(v.value)})
                            end
                            Iris.End()
                        end
                    Iris.End()

                elseif enteredState then
                    Iris.Table({1, [Iris.Args.Table.RowBg] = false})
                        Iris.Text({string.format("The ID, \"%s\", is a state", enteredText)})
                        Iris.NextRow()

                        Iris.Text({string.format("Value is type: %s, Value = %s", typeof(enteredState.value), tostring(enteredState.value))})
                        Iris.NextRow()

                        Iris.Tree({"state has connected widgets:"}, {isUncollapsed = Iris.State(true)})
                            for i,v in enteredState.ConnectedWidgets do
                                Iris.Text({i .. " - " .. v.type})
                            end
                        Iris.End()
                        Iris.NextRow()

                        Iris.Text({string.format("state has: %d connected functions", #enteredState.ConnectedFunctions)})
                    Iris.End()
                else
                    Iris.Text({string.format("The ID, \"%s\", is not a state or widget", enteredText)})
                end
            Iris.End()

            if Iris.Tree({"Widgets"}).isUncollapsed.value then
                local widgetCount = 0
                local widgetStr = ""
                for _, v in lastVDOM do
                    widgetCount += 1
                    widgetStr ..= "\n" .. v.ID .. " - " .. v.type
                end

                Iris.Text({"Number of Widgets: " .. widgetCount})

                Iris.Text({widgetStr})
            end
            Iris.End()
            if Iris.Tree({"States"}).isUncollapsed.value then
                local stateCount = 0
                local stateStr = ""
                for i, v in states do
                    stateCount += 1
                    stateStr ..= "\n" .. i .. " - " .. tostring(v.value)
                end

                Iris.Text({"Number of States: " .. stateCount})

                Iris.Text({stateStr})
            end
            Iris.End()
        Iris.End()
    end

    -- allows users to edit state
    local styleEditor
    do
        -- styleEditor is stupidly coded because Iris dosent have higher-order widgets yet, (Iris.InputNum2 etc.)
        local styleStates = {}
        do -- init style states
            for i, v in Iris._config do
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
            for i, v in Iris._config do
                if typeof(v) == "Color3" then
                    styleStates[i .. "R"]:set(v.R * 255)
                    styleStates[i .. "G"]:set(v.G * 255)
                    styleStates[i .. "B"]:set(v.B * 255)
                elseif typeof(v) == "UDim" then
                    styleStates[i .. "Scale"]:set(v.Scale)
                    styleStates[i .. "Offset"]:set(v.Offset)
                elseif typeof(v) == "Vector2" then
                    styleStates[i .. "X"]:set(v.X)
                    styleStates[i .. "Y"]:set(v.Y)
                elseif typeof(v) == "EnumItem" then
                    styleStates[i]:set(v.Name)
                else
                    styleStates[i]:set(v)
                end
            end
        end

        local function InputVector2(name)
            Iris.PushConfig({ContentWidth = UDim.new(0, 100 - Iris._config.ItemInnerSpacing.X)})
                Iris.SameLine()
                    local X = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "X"]}
                    )
                    local Y = Iris.InputNum(
                        {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Y"]}
                    )
                    if X.numberChanged() or Y.numberChanged() then
                        Iris.UpdateGlobalConfig({[name] = Vector2.new(X.number.value, Y.number.value)})
                    end
                Iris.End()
            Iris.PopConfig()
        end

        local function InputUDim(name)
            Iris.PushConfig({ContentWidth = UDim.new(0, 100 - Iris._config.ItemInnerSpacing.X)})
                Iris.SameLine()
                    local Scale = Iris.InputNum(
                        {"", [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Scale"]}
                    )
                    local Offset = Iris.InputNum(
                        {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                        {number = styleStates[name .. "Offset"]}
                    )
                    if Scale.numberChanged() or Offset.numberChanged() then
                        Iris.UpdateGlobalConfig({[name] = UDim.new(Scale.number.value, Offset.number.value)})
                    end
                Iris.End()
            Iris.PopConfig()
        end

        local function InputColor4(name, transparencyName)
            Iris.PushConfig({ContentWidth = UDim.new(0, 50 - Iris._config.ItemInnerSpacing.X)})
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
                    if R.numberChanged() or G.numberChanged() or B.numberChanged() or A.numberChanged() then
                        Iris.UpdateGlobalConfig({[name] = Color3.fromRGB(R.number.value, G.number.value, B.number.value), [transparencyName] = A.number.value})
                    end
                Iris.End()
            Iris.PopConfig()
        end

        local function InputInt(name)
            Iris.PushConfig({ContentWidth = UDim.new(0, 200)})
                local I = Iris.InputNum(
                    {name, [Iris.Args.InputNum.NoButtons] = true, [Iris.Args.InputNum.Format] = "%d"},
                    {number = styleStates[name]}
                )
                if I.numberChanged() then
                    Iris.UpdateGlobalConfig({[name] = I.number.value})
                end
            Iris.PopConfig()
        end

        local function InputEnum(name, enumType, default)
            Iris.PushConfig({ContentWidth = UDim.new(0, 200)})
                local EnumInputText = Iris.InputText(
                    {name},
                    {text = styleStates[name]}
                )
                if EnumInputText.textChanged() then
                    local isValidEnum = false
                    for _, _enumItem in ipairs(enumType:GetEnumItems()) do
                        if _enumItem.Name == EnumInputText.text.value then
                            isValidEnum = true
                            break
                        end
                    end
                    if isValidEnum then
                        Iris.UpdateGlobalConfig({[name] = enumType[EnumInputText.text.value]})
                    else
                        Iris.UpdateGlobalConfig({[name] = default})
                        styleStates[name]:set(tostring(default))
                    end
                end
            Iris.PopConfig()
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

                    Iris.Text({"Widths"})
                    InputUDim("ItemWidth")
                    InputUDim("ContentWidth")
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
            local selectedPanel = Iris.State(1)
    
            Iris.Window({"Style Editor"}, {isOpened = showStyleEditor})
                Iris.Text({"Customize the look of Iris in realtime."})
                Iris.SameLine()
                    if Iris.SmallButton({"Light Theme"}).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
                        refreshStyleStates()
                    end
                    if Iris.SmallButton({"Dark Theme"}).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                        refreshStyleStates()
                    end
                Iris.End()
                Iris.SameLine()
                    if Iris.SmallButton({"Classic Size"}).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                        refreshStyleStates()
                    end
                    if Iris.SmallButton({"Larger Size"}).clicked() then
                        Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
                        refreshStyleStates()
                    end
                Iris.End()
                if Iris.SmallButton({"Reset Everything"}).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                    refreshStyleStates()
                end
                Iris.Separator()
                Iris.SameLine()
                    for i, v in ipairs(styleList) do
                        Iris.RadioButton({v[0], i}, {value = selectedPanel})
                    end
                Iris.End()
                styleList[selectedPanel:get()][1]()
            Iris.End()
        end
    end

    -- showcases how events can be used
    local function widgetEventInteractivity()
        Iris.CollapsingHeader({"Widget Event Interactivity"})
            local clickCount = Iris.State(0)
            if Iris.Button({"Click to increase Number"}).clicked() then
                clickCount:set(clickCount:get() + 1)
            end
            Iris.Text({"The Number is: " .. clickCount:get()})
            local showTextTimer = Iris.State(0)
            Iris.SameLine()
                if Iris.Button({"Click to show text for 20 frames"}).clicked() then
                    showTextTimer:set(20)
                end
                if showTextTimer:get() > 0 then
                    Iris.Text({"Here i am!"})
                end
            Iris.End()
            showTextTimer:set(math.max(0, showTextTimer:get() - 1))
            Iris.Text({"Text Timer: " .. showTextTimer:get()})

            local checkbox0 = Iris.Checkbox({"Event-tracked checkbox"})
            Iris.Indent()
                Iris.Text({"unchecked: " .. tostring(checkbox0.unchecked())})
                Iris.Text({"checked: " .. tostring(checkbox0.checked())})
            Iris.End()
            Iris.SameLine()
            if Iris.Button({"Hover over me"}).hovered() then
                Iris.Text({"The button is hovered"})
            end
            Iris.End()
        Iris.End()
    end

    -- showcases how state can be used
    local function widgetStateInteractivity()
        Iris.CollapsingHeader({"Widget State Interactivity"})
            local checkbox0 = Iris.Checkbox({"Widget-Generated State"})
            Iris.Text({`isChecked: {checkbox0.state.isChecked.value}\n`})
            
            local checkboxState0 = Iris.State(false)
            local checkbox1 = Iris.Checkbox({"User-Generated State"}, {isChecked = checkboxState0})
            Iris.Text({`isChecked: {checkbox1.state.isChecked.value}\n`})

            local checkbox2 = Iris.Checkbox({"Widget Coupled State"})
            local checkbox3 = Iris.Checkbox({"Coupled to above Checkbox"}, {isChecked = checkbox2.state.isChecked})
            Iris.Text({`isChecked: {checkbox3.state.isChecked.value}\n`})

            local checkboxState1 = Iris.State(false)
            local checkbox4 = Iris.Checkbox({"Widget and Code Coupled State"}, {isChecked = checkboxState1})
            local Button0 = Iris.Button({"Click to toggle above checkbox"})
            if Button0.clicked() then
                checkboxState1:set(not checkboxState1:get())
            end
            Iris.Text({`isChecked: {checkboxState1.value}\n`})

            local checkboxState2 = Iris.State(true)
            local checkboxState3 = Iris.ComputedState(checkboxState2, function(newValue)
                return not newValue
            end)
            local checkbox5 = Iris.Checkbox({"ComputedState (dynamic coupling)"}, {isChecked = checkboxState2})
            local checkbox5 = Iris.Checkbox({"Inverted of above checkbox"}, {isChecked = checkboxState3})
            Iris.Text({`isChecked: {checkboxState3.value}\n`})


        Iris.End()
    end

    -- showcases how dynamic styles can be used
    local function dynamicStyle()
        Iris.CollapsingHeader({"Dynamic Styles"})
            local colorH = Iris.State(0)
            Iris.SameLine()
            if Iris.Button({"Change Color"}).clicked() then
                colorH:set(math.random())
            end
            Iris.Text({"Hue: " .. math.floor(colorH:get() * 255)})
            Iris.End()
            Iris.PushConfig({TextColor = Color3.fromHSV(colorH:get(), 1, 1)})
                Iris.Text({"Text with a unique and changable color"})
            Iris.PopConfig()
        Iris.End()
    end

    -- showcases how tables can be used
    local function tablesDemo()
        local showTablesTree = Iris.State(false)

        Iris.CollapsingHeader({"Tables & Columns"}, {isUncollapsed = showTablesTree})
        if showTablesTree.value == false then
            -- optimization to skip code which draws GUI which wont be seen.
            -- its a trade off because when the tree becomes opened widgets will all have to be generated again.
            -- Dear ImGui utilizes the same trick, but its less useful here because the Retained mode Backend
        Iris.End()
        else
            Iris.Text({"Table using NextRow and NextColumn syntax:"})
            Iris.Table({3})
                for i = 1, 4 do
                    Iris.NextRow()
                    for i2 = 1, 3 do
                        Iris.NextColumn()
                        Iris.Text({`Row: {i}, Column: {i2}`})
                    end
                end
            Iris.End()

            Iris.Text({""})
            Iris.Text({"Table using NextColumn only syntax:"})

            Iris.Table({2})
                for i = 1, 4 do
                    for i2 = 1, 2 do
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
            local TableNumRows = Iris.State(3)

            Iris.Text({"Table with Customizable Arguments"})
            Iris.Table({
                4,
                [Iris.Args.Table.RowBg] = TableRowBg.value,
                [Iris.Args.Table.BordersOuter] = TableBordersOuter.value,
                [Iris.Args.Table.BordersInner] = TableBordersInner.value
            })
                for i = 1, TableNumRows:get() do
                    for i2 = 1, 4 do
                        Iris.NextColumn();
                        if TableUseButtons.value then
                            Iris.Button({`Month: {i}, Week: {i2}`})
                        else
                            Iris.Text({`Month: {i}, Week: {i2}`})
                        end
                    end
                end
            Iris.End()

            Iris.Checkbox({"RowBg"}, {isChecked = TableRowBg})
            Iris.Checkbox({"BordersOuter"}, {isChecked = TableBordersOuter})
            Iris.Checkbox({"BordersInner"}, {isChecked = TableBordersInner})
            Iris.SameLine()
                Iris.RadioButton({"Buttons", true}, {value = TableUseButtons})
                Iris.RadioButton({"Text", false}, {value = TableUseButtons})
            Iris.End()
            Iris.InputNum({"Number of rows", [Iris.Args.InputNum.Min] = 0, [Iris.Args.InputNum.Max] = 100, [Iris.Args.InputNum.Format] = "%d"}, {number = TableNumRows})

        Iris.End()
        end
    end

    -- showcases how widgets placed outside of a window are placed inside root
    local function windowlessDemo()
        Iris.PushConfig({ItemWidth = UDim.new(0, 150)})
            Iris.TextWrapped({"Widgets which are placed outside of a window will appear on the top left side of the screen."})
            Iris.Button()
            Iris.Tree()
                Iris.InputText()
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
                Iris.NextColumn()
                Iris.Checkbox({"Windowless"}, {isChecked = showWindowlessDemo})
            Iris.End()

            Iris.Separator()

            Iris.CollapsingHeader({"Window Options"})
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

			Iris.CollapsingHeader({"Recursive Tree"})
            	recursiveTree()
			Iris.End()

            dynamicStyle()

            Iris.Separator()

            Iris.CollapsingHeader({"Widgets"})
                for _, name in widgetDemosOrder do
                    widgetDemos[name]()
                end
            Iris.End()

            tablesDemo()
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
        if showWindowlessDemo.value then
            windowlessDemo()
        end
    end
end