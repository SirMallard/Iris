local RunService = game:GetService("RunService")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Iris = require(StarterPlayerScripts.Client.Iris)

Iris.Connect(PlayerGui, RunService.Heartbeat, function()
    Iris.ShowDemoWindow()
end)