local StudioTestService = game:GetService("StudioTestService")
local Players = game:GetService("Players")

local arguments = StudioTestService:GetTestArgs()
if not arguments then
    return
end

game.StarterPlayer.StarterPlayerScripts.helloIris.Enabled = false
script.Runner.Parent = game.ReplicatedStorage
Players.CharacterAutoLoads = false
