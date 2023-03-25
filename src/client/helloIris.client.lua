local RunService = game:getService("RunService")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Player = game:getService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Iris = require(StarterPlayerScripts.Client.Iris)

Iris.Connect(PlayerGui, RunService.Heartbeat, function()
    Iris.ShowDemoWindow()
end)