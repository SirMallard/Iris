local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Iris).Init()

Iris:Connect(Iris.ShowDemoWindow)

Iris:Connect(function()
    Iris.Window({ "Progress Bar Testing" })
    do
        local Progress = Iris.State(0)
        Iris.SliderNum({ "Progress Value", 0.01, 0, 1 }, { number = Progress })
        Iris.Text({ `Value: {Progress.value}` })

        Iris.ProgressBar({ "Progress Bar" }, { progress = Progress })

        Iris.End()
    end
end)
