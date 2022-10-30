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

Iris.Connect(ScreenGui, RunService.Heartbeat, function()
    Iris.Text{"This is some useful text."}

    Iris.SameLine{}
        if Iris.Button{}.Clicked then
            count += 1
        end
        Iris.Separator{}
        Iris.Text{string.format("counter = %d", count)}
    Iris.End()

    Iris.ShowDemoWindow()
end)