local StudioTestService = game:GetService("StudioTestService")
local Players = game:GetService("Players")

local arguments = StudioTestService:GetTestArgs()
if not arguments then
    return
end

local event = Instance.new("RemoteEvent")
event.Name = "TestRunnerEvent"
event.Parent = game.ReplicatedStorage

game.StarterPlayer.StarterPlayerScripts.helloIris.Enabled = false
script.Runner.Parent = game.ReplicatedStorage
Players.CharacterAutoLoads = false

event:FireAllClients({
    status = "start",
})

event.OnClientEvent:Connect(function(player: Player, data)
    StudioTestService:EndTest(data)
end)
