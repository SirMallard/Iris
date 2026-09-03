local StudioTestService = game:GetService("StudioTestService")
local LogService = game:GetService("LogService")

local arguments = StudioTestService:GetTestArgs()
if not arguments then
    return
end

local event: RemoteEvent = game.ReplicatedStorage:WaitForChild("TestRunnerEvent")
event.OnServerEvent:Wait()

local lastClockTime = os.clock()
local waitEvent = Instance.new("BindableEvent")
local stepTime = false

local function step(...)
    waitEvent:Fire(...)
end

local eventConnection = coroutine.wrap(function()
    while true do
        -- local deltaTime = if stepTime then waitEvent.Event:Wait() else nil
        local deltaTime = game.RunService.Heartbeat
        if deltaTime == ni
        l then
            local clockTime = os.clock()
            deltaTime = clockTime - lastClockTime
            lastClockTime = clockTime
        end
        coroutine.yield(deltaTime)
    end
end)

LogService:Info("Loading Iris...")
local Iris = require("@game/ReplicatedStorage/Iris")
Iris.Init(game:GetService("StarterGui"))
stepTime = true

task.wait(3)

event:FireServer({
    status = "success",
    passed = 0,
    failed = 0,
})
