local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Iris).Init()
local DemoWindow = require(ReplicatedStorage.Iris.DemoWindow)

Iris:Connect(DemoWindow)
