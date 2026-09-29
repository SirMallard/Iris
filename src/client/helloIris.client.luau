local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Iris).Init()

Iris:Connect(Iris.ShowDemoWindow)
