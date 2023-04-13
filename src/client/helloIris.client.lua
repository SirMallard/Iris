local RunService = game:GetService("RunService")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local PlayerGui = Player:WaitForChild("PlayerGui")

local Iris = require(StarterPlayerScripts.Client.Iris)

--Iris.UpdateGlobalConfig({UseScreenGUIs = false})

Iris.Connect(PlayerGui, RunService.Heartbeat, function()
    Iris.ShowDemoWindow()
end)