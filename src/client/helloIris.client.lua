local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Common.Iris)

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui

-- local Frame = Instance.new("Frame")
-- Frame.Size = UDim2.fromScale(.75,.75)
-- Frame.Position = UDim2.fromScale(.125,.125)
-- Frame.Parent = ScreenGui

local count = 0
local lastT = os.clock()
local rollingDT = 0
local TextCounts = {}
local new = true

local DemoWindowArguments = {
    ["NoTitleBar"] = false,
    ["NoBackground"] = false,
    ["NoCollapse"] = false,
    ["NoClose"] = false,
    ["NoMove"] = false,
    ["NoScrollbar"] = false,
    ["NoResize"] = false,
    ["NoNav"] = false
}

local InputNumArguments = {
    ["NoField"] = false,
    ["NoButtons"] = false,
    ["Min"] = 0,
    ["Max"] = 100,
    ["Increment"] = 1
}

function showDemoWindow(Index)
    local styleEditor = Iris.Window{"Style Editor",
        [Iris.Args.Window.NoCollapse] = true,
    }
        Iris.TextWrapped{"Configure the appearance of Iris in realtime"}
        Iris.SameLine{}
            if Iris.Button{"Light Theme"}.Clicked then
                Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorLight)
                Iris.ForceRefresh()
            end
            if Iris.Button{"Dark Theme"}.Clicked then
                Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
                Iris.ForceRefresh()
            end
            if Iris.Button{"Revert Sizes"}.Clicked then
                Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
                Iris.ForceRefresh()
            end
            if Iris.Button{"Revert All"}.Clicked then
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
                    local thisNum = Iris.InputNum{i, math.min(v/10, 1) + 0.05, math.max(0, v-(2*v)), (2*v) + 0.1}
                Iris.PopStyle()

                if thisNum.ValueChanged then
                    Iris.UpdateGlobalStyle({[i] = thisNum.state.value})
                    Iris.ForceRefresh()
                end
                if new then
                    Iris.SetState(thisNum, {value = v})
                end
            elseif typeof(v) == "Vector2" then
                Iris.PushStyle{ItemWidth = UDim.new(0, 60)}
                    Iris.SameLine{}
                        local thisNumX = Iris.InputNum{"X", 1, 0, 100, [Iris.Args.InputNum.NoField] = true}
                        local thisNumY = Iris.InputNum{"Y "..i, 1, 0, 100, [Iris.Args.InputNum.NoField] = true}
                    Iris.End()
                Iris.PopStyle()

                if thisNumX.ValueChanged or thisNumY.ValueChanged then
                    Iris.UpdateGlobalStyle({[i] = Vector2.new(thisNumX.state.value, thisNumY.state.value)})
                    Iris.ForceRefresh()
                end
                if new then
                    Iris.SetState(thisNumX, {value = v.X})
                    Iris.SetState(thisNumY, {value = v.Y})
                end
            elseif typeof(v) == "Color3" then
                Iris.PushStyle{ItemWidth = UDim.new(0, 60)}
                    Iris.SameLine{}
                        local thisNumR = Iris.InputNum{"R",  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                        local thisNumG = Iris.InputNum{"G",  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                        local thisNumB = Iris.InputNum{"B "..i,  5, 0, 255, [Iris.Args.InputNum.NoField] = true}
                    Iris.End()
                Iris.PopStyle()

                if thisNumR.ValueChanged or thisNumG.ValueChanged or thisNumB.ValueChanged then
                    Iris.UpdateGlobalStyle({[i] = Color3.fromRGB(thisNumR.state.value, thisNumG.state.value, thisNumB.state.value)})
                    Iris.ForceRefresh()
                end
                if new then
                    Iris.SetState(thisNumR, {value = v.R})
                    Iris.SetState(thisNumG, {value = v.G})
                    Iris.SetState(thisNumB, {value = v.B})
                end
            end
            Iris.End()
        end

    Iris.End()

    if new then
        Iris.SetState(styleEditor, {
            closed = true,
            size = Vector2.new(400,600)
        })
    end

    if not TextCounts[Index] then
        TextCounts[Index] = 0
    end

    local thisWindow = Iris.Window {"Iris Demo - " .. Index,
        [Iris.Args.Window.NoTitleBar] = DemoWindowArguments.NoTitleBar,
        [Iris.Args.Window.NoBackground] = DemoWindowArguments.NoBackground,
        [Iris.Args.Window.NoCollapse] = DemoWindowArguments.NoCollapse,
        [Iris.Args.Window.NoClose] = DemoWindowArguments.NoClose,
        [Iris.Args.Window.NoMove] = DemoWindowArguments.NoMove,
        [Iris.Args.Window.NoScrollbar] = DemoWindowArguments.NoScrollbar,
        [Iris.Args.Window.NoResize] = DemoWindowArguments.NoResize,
        [Iris.Args.Window.NoNav] = DemoWindowArguments.NoNav
    }
    
        Iris.Text{"Iris says hello!"}
        
        Iris.Tree{"Trees"}
            Iris.Tree{"Tree using SpanAvailWidth", [Iris.Args.Tree.SpanAvailWidth] = true}
            Iris.End()

            local tree1 = Iris.Tree{"Tree with Children"}
                Iris.Text{"Im inside the first tree!"}
                Iris.Button{"Im a button inside the first tree!"}
                Iris.Tree{"Im a tree inside the first tree!"}
                    Iris.Text{"I am the innermost text!!!"}
                Iris.End()
            Iris.End()

            local collapseCheckbox = Iris.Checkbox{"make above tree collapsed"}
            if collapseCheckbox.Checked or collapseCheckbox.Unchecked then
                Iris.SetState(tree1, {
                    collapsed = not collapseCheckbox.state.checked
                })
            end
            if tree1.Collapsed or tree1.Opened then
                Iris.SetState(collapseCheckbox, {
                    checked = not tree1.state.collapsed
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

        Iris.Tree{"InputNum"}
            Iris.PushStyle{ItemWidth = UDim.new(0.66, 0)}
                InputNumArguments.NoField = Iris.Checkbox{"NoField"}.state.checked
                InputNumArguments.NoButtons = Iris.Checkbox{"NoButtons"}.state.checked
                local MinInput = Iris.InputNum{"Min"}
                local MaxInput = Iris.InputNum{"Max"}
                local IncrementInput = Iris.InputNum{"Increment"}
                if new then
                    Iris.SetState(MinInput, {value = InputNumArguments.Min})
                    Iris.SetState(MaxInput, {value = InputNumArguments.Max})
                    Iris.SetState(IncrementInput, {value = InputNumArguments.Increment})
                end
                InputNumArguments.Min = MinInput.state.value
                InputNumArguments.Max = MaxInput.state.value
                InputNumArguments.Increment = IncrementInput.state.value
                Iris.Separator{}
                Iris.InputNum{"Input Number",
                    [Iris.Args.InputNum.NoField] = InputNumArguments.NoField,
                    [Iris.Args.InputNum.NoButtons] = InputNumArguments.NoButtons,
                    [Iris.Args.InputNum.Min] = InputNumArguments.Min,
                    [Iris.Args.InputNum.Max] = InputNumArguments.Max,
                    [Iris.Args.InputNum.Increment] = InputNumArguments.Increment
                }
            Iris.PopStyle()
        Iris.End()

        Iris.Separator{}

        Iris.SameLine{}
            Iris.PushStyle{ItemWidth = UDim.new(0, 100)}
                Iris.Tree{"List of text"}
                    for i = 1,TextCounts[Index] or 0 do
                        Iris.UseId(i)
                            Iris.Text{string.format("Text #%d", i)}
                        Iris.End()
                    end
                Iris.End()
            Iris.PopStyle()
            if Iris.SmallButton{"Add"}.Clicked then
                TextCounts[Index] = (TextCounts[Index] + 1) % 21
            end
            if Iris.SmallButton{"Remove"}.Clicked then
                TextCounts[Index] = (TextCounts[Index] - 1) % 21
            end
        Iris.End()

        if Iris.Button{"Style Editor"}.Clicked then
            Iris.SetState(styleEditor, {closed = false})
        end
    Iris.End()

    return thisWindow
end

Iris.Connect(ScreenGui, RunService.Heartbeat, function()
    Iris.Text{"This is some useful text."}

    Iris.SameLine{}
        if Iris.Button{}.Clicked then
            count += 1
        end
        Iris.Separator{}
        Iris.Text{string.format("counter = %d", count)}
    Iris.End()

    local t = os.clock()
    local dt = t - lastT
    rollingDT += (dt - rollingDT) * 0.2
    lastT = t
    Iris.Text{string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT*1000, 1/rollingDT)}

    local demoWindow = showDemoWindow(1)

    Iris.Separator{}

    Iris.Tree{"Demo Window", [Iris.Args.Tree.SpanAvailWidth] = true}
        Iris.SameLine{}
            if Iris.Button{"Open"}.Clicked then
                Iris.SetState(demoWindow, {closed = false, collapsed = false})
            end
            if Iris.Button{"Collapse"}.Clicked then
                Iris.SetState(demoWindow, {collapsed = true})
            end
        Iris.End()

        Iris.Tree{"Options", [Iris.Args.Tree.SpanAvailWidth] = true}
            for i, v in DemoWindowArguments do
                Iris.UseId(i)
                DemoWindowArguments[i] = Iris.Checkbox{i}.state.checked
                Iris.End()
            end
        Iris.End()

        Iris.Text{string.format("Window Position: (%d, %d)", demoWindow.state.position.X, demoWindow.state.position.Y)}
        Iris.Text{string.format("Window Size: (%d, %d)", demoWindow.state.size.X, demoWindow.state.size.Y)}
    Iris.End()

    new = false
end)