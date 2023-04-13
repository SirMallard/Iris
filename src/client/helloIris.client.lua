local RunService = game:GetService("RunService")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Iris = require(StarterPlayerScripts.Client.Iris)

Iris.Init(PlayerGui, RunService.Heartbeat)

Iris:Connect(function()
    Iris.Window({"My First Window!"})
        Iris.Text({"Hello world!"})
        Iris.Button({"Save"})
        Iris.InputText({"Input Something!"})
    Iris.End()
end)

Iris:Connect(Iris.ShowDemoWindow)