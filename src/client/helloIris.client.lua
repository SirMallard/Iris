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

function showDemoWindow(Index)
    local styleEditor = Iris.Window{"Style Editor",
        [Iris.Args.Window.NoCollapse] = true,
    }
        Iris.Text{"Configure the appearance of Iris in realtime"}
        if Iris.Button{"Use light mode"}.Clicked then
            Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorLight)
            Iris.ForceRefresh()
        end
        if Iris.Button{"Use dark mode"}.Clicked then
            Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
            Iris.ForceRefresh()
        end
        Iris.Separator{}
        Iris.Text{string.format("FontSize: %d", Iris._style.FontSize)}
        if Iris.Button{"Increase FontSize"}.Clicked then
            Iris.UpdateGlobalStyle({FontSize = Iris._style.FontSize + 1})
            Iris.ForceRefresh()
        end
        if Iris.Button{"Decrease FontSize"}.Clicked then
            Iris.UpdateGlobalStyle({FontSize = Iris._style.FontSize - 1})
            Iris.ForceRefresh()
        end
        Iris.Separator{}
        Iris.Text{string.format("FrameRounding: %d", Iris._style.FrameRounding)}
        if Iris.Button{"Increase FrameRounding"}.Clicked then
            Iris.UpdateGlobalStyle({FrameRounding = Iris._style.FrameRounding + 1})
            Iris.ForceRefresh()
        end
        if Iris.Button{"Decrease FrameRounding"}.Clicked then
            Iris.UpdateGlobalStyle({FrameRounding = Iris._style.FrameRounding - 1})
            Iris.ForceRefresh()
        end
        Iris.Separator{}
        Iris.Text{string.format("BorderSize: %d", Iris._style.FrameBorderSize)}
        if Iris.Button{"Increase BorderSize"}.Clicked then
            Iris.UpdateGlobalStyle({FrameBorderSize = Iris._style.FrameBorderSize + 1})
            Iris.ForceRefresh()
        end
        if Iris.Button{"Decrease BorderSize"}.Clicked then
            Iris.UpdateGlobalStyle({FrameBorderSize = Iris._style.FrameBorderSize - 1})
            Iris.ForceRefresh()
        end
    Iris.End()
    if new then
        Iris.SetState(styleEditor, {
            closed = true,
            size = Vector2.new(250,400)
        })
    end

    if not TextCounts[Index] then
        TextCounts[Index] = 0
    end
    Iris.UseId(Index)
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
            local tree1 = Iris.Tree{"first tree"}
                Iris.Text{"Im inside the first tree!"}
                Iris.Button{"Im a button inside the first tree!"}
                Iris.Tree{"Im a tree inside the first tree!"}
                    Iris.Text{"I am the innermost text"}
                Iris.End()
            Iris.End()

            if Iris.Button{"Change the collapsed state of the above tree"}.Clicked then
                Iris.SetState(tree1, {
                    collapsed = not tree1.state.collapsed
                })
            end

            Iris.SmallButton{"Im a small button!"}

            Iris.Indent{}
                Iris.Text{"I am indented text"}
                Iris.Indent{13}
                    Iris.Text{"I am indented by 13 more pixels"}
                Iris.End()
            Iris.End()

            Iris.Separator{}

            if Iris.Button{"Add a text"}.Clicked then
                TextCounts[Index] = (TextCounts[Index] + 1) % 21
            end

            Iris.Tree{"List of text"}
                for i = 1,TextCounts[Index] or 0 do
                    Iris.UseId(i)
                        Iris.Text{string.format("Text #%d", i)}
                    Iris.End()
                end
            Iris.End()

            if Iris.Button{"Style Editor"}.Clicked then
                Iris.SetState(styleEditor, {closed = false})
            end
        Iris.End()
    Iris.End()

    return thisWindow
end

Iris.Connect(ScreenGui, RunService.Heartbeat, function()
    Iris.Text{"This is some useful text."}

    if Iris.Button{}.Clicked then
        count += 1
    end
    Iris.Text{string.format("counter = %d", count)}

    local t = os.clock()
    local dt = t - lastT
    rollingDT += (dt - rollingDT) * 0.2
    lastT = t
    Iris.Text{string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT*1000, 1/rollingDT)}

    local demoWindow = showDemoWindow(1)

    Iris.Separator{}

    if Iris.Button{"Open demo window"}.Clicked then
        Iris.SetState(demoWindow, {closed = false, collapsed = false})
    end

    if Iris.Button{"Collapse demo window"}.Clicked then
        Iris.SetState(demoWindow, {collapsed = true})
    end
    
    Iris.Tree{"demo window arguments"}
        for i, v in DemoWindowArguments do
            Iris.UseId(i)
            DemoWindowArguments[i] = Iris.Checkbox{i}.state.checked
            Iris.End()
        end
    Iris.End()

    Iris.Separator{}

    Iris.Text{string.format("Demo window Position: (%d, %d)", demoWindow.state.position.X, demoWindow.state.position.Y)}
    Iris.Text{string.format("Demo window Size: (%d, %d)", demoWindow.state.size.X, demoWindow.state.size.Y)}

    new = false
end)