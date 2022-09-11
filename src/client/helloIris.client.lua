local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = false
screenGui.Name = "IrisDemo"
screenGui.Parent = PlayerGui

local Iris = require(ReplicatedStorage.Common.Iris)(screenGui)

local NumericIndex = 0
local ShowText = false
local NumberOfTexts = 4

local fonts = Enum.Font:GetEnumItems()
local fontIndex = 1
local windowOptions = {
    NoBackground = false,
    NoClose = false,
    NoCollapse = false,
    NoTitleBar = false,
    Closed = false
}

local function DemoWindow()
    Iris:Text("Hello from Iris!")
    Iris:Tree("Window Options")
        if Iris:Button("NoBackground").Clicked then
            windowOptions.NoBackground = not windowOptions.NoBackground
        end
        if Iris:Button("NoClose").Clicked then
            windowOptions.NoClose = not windowOptions.NoClose
        end
        if Iris:Button("NoCollapse").Clicked then
            windowOptions.NoCollapse = not windowOptions.NoCollapse
        end
        if Iris:Button("NoTitleBar").Clicked then
            windowOptions.NoTitleBar = not windowOptions.NoTitleBar
        end
        if Iris:Button("Closed").Clicked then
            windowOptions.Closed = not windowOptions.Closed
        end
    Iris:End()

    local CoolWindow = Iris:Window(
        "Iris Demo",
        Iris.Args.Window.Position(200, 150),
        Iris.Args.Window.Size(500,600),
        Iris.Args.Window.NoBackground(windowOptions.NoBackground),
        Iris.Args.Window.NoClose(windowOptions.NoClose),
        Iris.Args.Window.NoCollapse(windowOptions.NoCollapse),
        Iris.Args.Window.NoTitleBar(windowOptions.NoTitleBar),
        Iris.Args.Window.Closed(windowOptions.Closed)
    )
        if CoolWindow.Closed then windowOptions.Closed = not windowOptions.Clsoed end
    
        Iris:Tree("Basic!")
            Iris:Text("This is some useful text.")
            if Iris:Button("Button").Clicked then
                NumericIndex += 1
            end
            if Iris:Button("Click to cycle font").Clicked then
                fontIndex += 1
                fontIndex %= #fonts
                Iris:SetStyle({
                    Font = fonts[fontIndex],
                    FontSize = math.random(10,23)
                })
            end
            if Iris:Button("Click to cycle padding").Clicked then
                Iris:SetStyle({
                    WindowPadding = Vector2.new(math.random(0,16), math.random(0,16)),
                    FramePadding = Vector2.new(math.random(0,8),math.random(0,8))
                })
            end
            Iris:Text(string.format("Counter = %d", NumericIndex))
            local ShowTextButtonChanged = Iris:Button("Click to toggle text").Clicked
            if ShowTextButtonChanged then
                ShowText = not ShowText
            end
            if Iris:Button("Click to add another text").Clicked then
                NumberOfTexts += 1
                NumberOfTexts %= 10
            end

            local CoolTree = Iris:Tree("This is a tree", ShowTextButtonChanged and not ShowText)
                for i = 1,NumberOfTexts do
                    Iris:Text(string.format("Look at me! %d", i))
                end
            Iris:End()

            if CoolTree.Opened then 
                ShowText = true
            elseif CoolTree.Collapsed then
                ShowText = false
            end
        Iris:End()

        Iris:Tree("Trees")
            Iris:Tree("Basic Trees")
                for i = 0,4 do
                    Iris:UseId(tostring(i))
                    Iris:Tree(string.format("Child %d", i))
                        Iris:Text("blah blah ")
                        Iris:Button("button")
                    Iris:End()
                end
            Iris:End()

            Iris:Tree("Advanced, with Selectable nodes")
                Iris:Tree("Spans available width", Iris.Args.Tree.SpanAvailWidth(true))
                Iris:End()
            Iris:End()
        Iris:End()

        Iris:Tree("Bullets")
        Iris:End()
    Iris:End()

    Iris:Tree("Window Events", Iris.Args.Tree.Collapsed(false))
    for i,v in CoolWindow do
        Iris:Text(string.format("%s, %s", i, tostring(v)))
    end
    Iris:End()

    Iris:Text(string.format("# of widgets now: %d", Iris._WidgetsThisCycle))
    --Iris:Text(string.format("# of instances now: %d", #Iris.root:GetDescendants()))
end

local function SingleButton()
    Iris:Button("Button")
end

Iris:Connect(RunService.Heartbeat, DemoWindow)