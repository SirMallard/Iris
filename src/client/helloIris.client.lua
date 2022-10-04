local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Common.Iris)

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Parent = PlayerGui;

local count = 0
local lastT = os.clock()
local rollingDT = 0
local TextCounts = {}
local numDemoWindows = 0
local new = true

local DemoWindowArguments = {
    ["NoTitleBar"] = false,
    ["NoBackground"] = false,
    ["NoCollapse"] = false,
    ["NoClose"] = false
}

function showDemoWindow(Index)
    Iris.PushId(Index)
        local thisWindow = Iris.Window("Iris Demo - " .. Index,
            Iris.Args.Window.NoTitleBar(DemoWindowArguments.NoTitleBar),
            Iris.Args.Window.NoBackground(DemoWindowArguments.NoBackground),
            Iris.Args.Window.NoCollapse(DemoWindowArguments.NoCollapse),
            Iris.Args.Window.NoClose(DemoWindowArguments.NoClose)
        )

            Iris.Text("This is a demo window!")
            local tree1 = Iris.Tree("first tree")
                Iris.Text("Im inside the first tree!")
                Iris.Button("Im a button inside the first tree!")
                Iris.Tree("Im a tree inside the first tree!")
                    Iris.Text("I am the innermost text")
                Iris.End()
            Iris.End()
        
            if Iris.Button("Change the collapsed state of the above tree").Clicked then
                Iris.SetState(tree1, {
                    Collapsed = not tree1.state.Collapsed
                })
            end

            if Iris.Button("Add a text").Clicked then
                if not TextCounts[Index] then
                    TextCounts[Index] = 1
                else
                    TextCounts[Index] = (TextCounts[Index] + 1) % 11
                end
            end

            Iris.Tree("List of text")
                for i = 1,TextCounts[Index] or 0 do
                    Iris.PushId(i)
                        Iris.Text(string.format("Text #%d", i))
                    Iris.End()
                end
            Iris.End()

            Iris.Tree("Style Editor")
                if Iris.Button("Increase FontSize").Clicked then
                    Iris.UpdateGlobalStyle({FontSize = Iris._style.FontSize + 1})
                    Iris.ForceRefresh()
                end
                if Iris.Button("Decrease FontSize").Clicked then
                    Iris.UpdateGlobalStyle({FontSize = Iris._style.FontSize - 1})
                    Iris.ForceRefresh()
                end
            Iris.End()

        Iris.End()
    Iris.End()

    return thisWindow
end

Iris.Connect(ScreenGui, RunService.Heartbeat, function()
    Iris.Text("This is some useful text.")

    if Iris.Button().Clicked then
        count += 1
    end
    Iris.Text(string.format("counter = %d", count))

    local t = os.clock()
    local dt = t-lastT
    rollingDT += (dt - rollingDT) * .2
    lastT = t
    Iris.Text(string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT*1000, 1/rollingDT))

    local demoWindow = showDemoWindow(1)

    Iris.Text("")

    if Iris.Button("Open main demo window").Clicked then
        Iris.SetState(demoWindow, {Closed = false, Collapsed = false})
    end

    local IsNewWindow = Iris.Button("Open a new demo window").Clicked 
    if IsNewWindow then
        numDemoWindows += 1
    end

    for i = 1,numDemoWindows do
        local iWindow = showDemoWindow(i + 1)
        if IsNewWindow and i == numDemoWindows then
            Iris.SetState(iWindow, {
                Size = Vector2.new(400,300),
                Position = Vector2.new(415 + (i * 25), 115 + (i * 25))
            })
        end

    end

    if Iris.Button("Collapse demo window").Clicked then
        Iris.SetState(demoWindow, {Collapsed = true})
    end

    Iris.Tree("demo window arguments")
        for i,v in DemoWindowArguments do
            Iris.PushId(i)
            if Iris.Button(i).Clicked then
                DemoWindowArguments[i] = not DemoWindowArguments[i]
            end
            Iris.End()
        end
    Iris.End()

    Iris.Text(string.format("Demo window Position: (%d, %d)", demoWindow.state.Position.X, demoWindow.state.Position.Y))
    new = false
end)