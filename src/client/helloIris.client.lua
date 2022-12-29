local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Iris = require(ReplicatedStorage.Common.Iris)

Iris.Connect(PlayerGui, RunService.Heartbeat, function()
    Iris.ShowDemoWindow()
end)