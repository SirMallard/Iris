local DemoWindow = {
    new = true,
    Arguments = {
        NoTitleBar = false,
        NoBackground = false,
        NoCollapse = false,
        NoClose = false,
        NoMove = false,
        NoScrollbar = false,
        NoResize = false,
        NoNav = false
    },
    InputNumArguments = {
        NoField = false,
        NoButtons = false,
        Min = 0,
        Max = 1000,
        Increment = 1,
        Format = "%f"
    },
    InputTextArguments = {
        TextHint = "Text Hint"
    },
    textCount = 0,
    lastT = os.clock(),
    rollingDT = 0
}

return function(Iris)
    return function()
        local function showStyleEditor()
            local styleEditor = Iris.Window{"Style Editor",
                [Iris.Args.Window.NoCollapse] = true,
            }
                if styleEditor.isClosed then
                    -- this optimization is a trade-off
                    -- it means that while the styleEditor is closed, it has a very small performance impact
                    -- but when it is opened, or closed, it will have a large performance impact.
                    -- this is better for cases where the window is often not shown and infrequently opened then closed.
                    Iris.End()
                    return styleEditor
                end
                Iris.TextWrapped{"Configure the appearance of Iris in realtime"}
                Iris.SameLine{}
                    if Iris.Button{"Light Theme"}.clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorLight)
                        Iris.ForceRefresh()
                    end
                    if Iris.Button{"Dark Theme"}.clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                        Iris.ForceRefresh()
                    end
                    if Iris.Button{"Revert Sizes"}.clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                        Iris.ForceRefresh()
                    end
                    if Iris.Button{"Revert All"}.clicked then
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                        Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                        Iris.ForceRefresh()
                    end
                Iris.End()
                Iris.Separator{}
                for i,v in pairs(Iris._style) do
                    Iris.UseId(i)
    
                    if type(v) == "number" then
                        Iris.PushStyle{ItemWidth = UDim.new(.5, 0)}
                            local thisNum = Iris.InputNum{i, math.min(v/10, 1) + 0.05, -math.huge, math.huge}
                        Iris.PopStyle()
    
                        if thisNum.valueChanged then
                            Iris.UpdateGlobalStyle({[i] = thisNum.value})
                            Iris.ForceRefresh()
                        end
                        if DemoWindow.new then
                            Iris.SetState(thisNum, {value = v})
                        end
                    elseif typeof(v) == "Vector2" then
                        Iris.PushStyle{ItemWidth = UDim.new(0, 60)}
                            Iris.SameLine{}
                                local thisNumX = Iris.InputNum{"X"    , 1, 0, 100, [Iris.Args.InputNum.NoField] = true}
                                local thisNumY = Iris.InputNum{"Y "..i, 1, 0, 100, [Iris.Args.InputNum.NoField] = true}
                            Iris.End()
                        Iris.PopStyle()
    
                        if thisNumX.valueChanged or thisNumY.valueChanged then
                            Iris.UpdateGlobalStyle({[i] = Vector2.new(thisNumX.value, thisNumY.value)})
                            Iris.ForceRefresh()
                        end
                        if DemoWindow.new then
                            Iris.SetState(thisNumX, {value = v.X})
                            Iris.SetState(thisNumY, {value = v.Y})
                        end
                    elseif typeof(v) == "Color3" then
                        Iris.PushStyle{ItemWidth = UDim.new(0, 60)}
                            Iris.SameLine{}
                                local thisNumR = Iris.InputNum{"R"    ,  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                                local thisNumG = Iris.InputNum{"G"    ,  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                                local thisNumB = Iris.InputNum{"B "..i,  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                            Iris.End()
                        Iris.PopStyle()
    
                        if thisNumR.valueChanged or thisNumG.valueChanged or thisNumB.valueChanged then
                            Iris.UpdateGlobalStyle({[i] = Color3.fromRGB(thisNumR.value, thisNumG.value, thisNumB.value)})
                            Iris.ForceRefresh()
                        end
                        if DemoWindow.new then
                            Iris.SetState(thisNumR, {value = v.R})
                            Iris.SetState(thisNumG, {value = v.G})
                            Iris.SetState(thisNumB, {value = v.B})
                        end
                    end
                    Iris.End()
                end
            Iris.End()

            return styleEditor
        end
        local styleEditor = showStyleEditor()
    
        local function showRuntimeInformation()
            local widgetStackViewer = Iris.Window{"Runtime Information"}
                if widgetStackViewer.isClosed then
                    Iris.End()
                    return widgetStackViewer
                end
    
                Iris.TextWrapped{"Widgets are stored in memory using a hierarchical Identifier (ID)"}
                Iris.TextWrapped{"when you create a widget, it will actually remember the exact line of code (LOC) that you created it on."}
                Iris.TextWrapped{"Using that, Iris will recognize that it is really the same Widget each frame. In your code, you dont need to keep track of widgets."}
                Iris.TextWrapped{"In the circumstance that you are calling multiple widgets from the same LOC, you can manually define an ID for Iris to remember the widget by."}
                Iris.TextWrapped{"Use Iris.UseId and Iris.End for that."}

                Iris.Separator{}

                local t = os.clock()
                local dt = t - DemoWindow.lastT
                DemoWindow.rollingDT += (dt - DemoWindow.rollingDT) * 0.2
                DemoWindow.lastT = t
                Iris.Text{string.format("Average %.3f ms/frame (%.1f FPS)", DemoWindow.rollingDT*1000, 1/DemoWindow.rollingDT)}

            Iris.End()
    
            return widgetStackViewer
        end
        local widgetStackViewer = showRuntimeInformation()
    
        local function showRecurseWindow(index)
            Iris.UseId(index)
                local rcWindow = Iris.Window{string.format("Hey! - %d", index)}
                    local opened = Iris.Button{"Recurse"}.clicked
                    if opened then
                        rcWindow.hasChild = true
                    end
                Iris.End()
            Iris.End()
    
            if rcWindow.hasChild then
                local child = showRecurseWindow(index + 1)
                if opened then
                    Iris.SetState(child, {
                        isClosed = false,
                        size = Vector2.new(200, 100),
                        position = rcWindow.position + Vector2.new(15, 25)
                    })
                end
                rcWindow.hasChild = not (rcWindow.isClosed or child.isClosed)
            end
    
            return rcWindow
        end
        local recurseWindow = showRecurseWindow(1)
    
        local thisWindow = Iris.Window {"Iris Demo",
            [Iris.Args.Window.NoTitleBar] = DemoWindow.Arguments.NoTitleBar,
            [Iris.Args.Window.NoBackground] = DemoWindow.Arguments.NoBackground,
            [Iris.Args.Window.NoCollapse] = DemoWindow.Arguments.NoCollapse,
            [Iris.Args.Window.NoClose] = DemoWindow.Arguments.NoClose,
            [Iris.Args.Window.NoMove] = DemoWindow.Arguments.NoMove,
            [Iris.Args.Window.NoScrollbar] = DemoWindow.Arguments.NoScrollbar,
            [Iris.Args.Window.NoResize] = DemoWindow.Arguments.NoResize,
            [Iris.Args.Window.NoNav] = DemoWindow.Arguments.NoNav
        }
        
            Iris.Text{"Iris says hello!"}
            Iris.Separator{}
            Iris.SameLine{}
                if Iris.SmallButton{"Style Editor"}.clicked then
                    Iris.SetState(styleEditor, {isClosed = false})
                end
                if Iris.SmallButton{"Runtime Info"}.clicked then
                    Iris.SetState(widgetStackViewer, {isClosed = false})
                end
                if Iris.SmallButton{"Recursive Window"}.clicked then
                    Iris.SetState(recurseWindow, {isClosed = false})
                end
            Iris.End()
            Iris.Separator{}
    
            Iris.Tree{"Window Options"}
                for i, v in DemoWindow.Arguments do
                    Iris.UseId(i)
                    DemoWindow.Arguments[i] = Iris.Checkbox{i}.value
                    Iris.End()
                end
            Iris.End()
            
            Iris.Tree{"Trees"}
                Iris.Tree{"Tree using SpanAvailWidth", [Iris.Args.Tree.SpanAvailWidth] = true}
                Iris.End()
    
                local tree1 = Iris.Tree{"Tree with Children"}
                    Iris.Text{"Im inside the first tree!"}
                    Iris.Button{"Im a button inside the first tree!"}
                    Iris.Tree{"Im a tree inside the first tree!"}
                        Iris.Text{"I am the innermost text!"}
                    Iris.End()
                Iris.End()
    
                local collapseCheckbox = Iris.Checkbox{"make above tree opened"}
                if collapseCheckbox.checked or collapseCheckbox.unchecked then
                    Iris.SetState(tree1, {
                        isCollapsed = not collapseCheckbox.value
                    })
                end
                if tree1.collapsed or tree1.opened then
                    Iris.SetState(collapseCheckbox, {
                        isChecked = not tree1.isCollapsed
                    })
                end
            Iris.End()
    
            Iris.Tree{"Groups"}
                Iris.SameLine{}
                    Iris.Group{}
                        Iris.Text{"I am in group A"}
                        Iris.Button{"Im also in A!"}
                    Iris.End()
                    Iris.Separator{}
                    Iris.Group{}
                        Iris.Text{"I am in group B"}
                        Iris.Button{"Im also in B!"}
                    Iris.End()
                Iris.End()
            Iris.End()
    
            Iris.Tree{"Indents"}
                Iris.Text{"Not Indented"}
                Iris.Indent{}
                    Iris.Text{"Indented"}
                    Iris.Indent{7}
                        Iris.Text{"Indented by 7 more pixels"}
                    Iris.End()
                    Iris.Indent{-7}
                        Iris.Text{"Indented by 7 less pixels"}
                    Iris.End()
                Iris.End()
            Iris.End()
    
            Iris.PushStyle{ItemWidth = UDim.new(0.66, 0)}
                Iris.Tree{"Input Num"}
                    local InputNum = Iris.InputNum{"Input Number",
                        [Iris.Args.InputNum.NoField] = DemoWindow.InputNumArguments.NoField,
                        [Iris.Args.InputNum.NoButtons] = DemoWindow.InputNumArguments.NoButtons,
                        [Iris.Args.InputNum.Min] = DemoWindow.InputNumArguments.Min,
                        [Iris.Args.InputNum.Max] = DemoWindow.InputNumArguments.Max,
                        [Iris.Args.InputNum.Increment] = DemoWindow.InputNumArguments.Increment,
                        [Iris.Args.InputNum.Format] = DemoWindow.InputNumArguments.Format,
                    }
                    Iris.Separator{}
                    Iris.Indent{}
                        DemoWindow.InputNumArguments.NoField = Iris.Checkbox{"NoField"}.value
                        DemoWindow.InputNumArguments.NoButtons = Iris.Checkbox{"NoButtons"}.value
                        local FormatInput = Iris.InputText{"Format"}
                        local MinInput = Iris.InputNum{"Min", [Iris.Args.InputNum.NoButtons] = true}
                        local MaxInput = Iris.InputNum{"Max", [Iris.Args.InputNum.NoButtons] = true}
                        local IncrementInput = Iris.InputNum{"Increment", [Iris.Args.InputNum.NoButtons] = true}
                    Iris.End()
                    if DemoWindow.new then
                        Iris.SetState(MinInput, {value = DemoWindow.InputNumArguments.Min})
                        Iris.SetState(MaxInput, {value = DemoWindow.InputNumArguments.Max})
                        Iris.SetState(IncrementInput, {value = DemoWindow.InputNumArguments.Increment})
                        Iris.SetState(FormatInput, {value = DemoWindow.InputNumArguments.Format})
                    end
                    DemoWindow.InputNumArguments.Min = MinInput.value
                    DemoWindow.InputNumArguments.Max = MaxInput.value
                    DemoWindow.InputNumArguments.Increment = IncrementInput.value
                    DemoWindow.InputNumArguments.Format = FormatInput.value
                    Iris.Text{string.format("The number is: %f", InputNum.value)}
                Iris.End()

                Iris.Tree{"Input Text"}
                    local InputText = Iris.InputText{"Input Text", DemoWindow.InputTextArguments.TextHint}
                    Iris.Separator{}
                    Iris.Indent{}
                        local TextHintInput = Iris.InputText{"TextHint"}
                    Iris.End()
                    if DemoWindow.new then
                        Iris.SetState(TextHintInput, {value = DemoWindow.InputTextArguments.TextHint})
                    end
                    DemoWindow.InputTextArguments.TextHint = TextHintInput.value
                    Iris.Text{string.format("The text is: %s", InputText.value)}
                Iris.End()
            Iris.PopStyle()
    
            Iris.Separator{}
    
            Iris.SameLine{}
                Iris.PushStyle{ItemWidth = UDim.new(0, 100)}
                    Iris.Tree{"List of text"}
                        for i = 1, DemoWindow.textCount do
                            Iris.UseId(i)
                                Iris.Text{string.format("Text #%d", i)}
                            Iris.End()
                        end
                    Iris.End()
                Iris.PopStyle()
                if Iris.SmallButton{"Add"}.clicked then
                    DemoWindow.textCount = (DemoWindow.textCount + 1) % 21
                end
                if Iris.SmallButton{"Remove"}.clicked then
                    DemoWindow.textCount = (DemoWindow.textCount - 1) % 21
                end
            Iris.End()
        Iris.End()
    
        if DemoWindow.new then
            Iris.SetState(styleEditor, {
                isClosed = true,
                size = Vector2.new(400, 600),
                position = Vector2.new(200, 200),
            })
            Iris.SetState(widgetStackViewer, {
                isClosed = true,
                size = Vector2.new(300, 400),
            })
            Iris.SetState(recurseWindow, {
                isClosed = true,
                size = Vector2.new(200, 100),
            })
            DemoWindow.new = false
        end
    
        return thisWindow
    end
end