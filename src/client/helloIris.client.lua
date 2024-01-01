local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Iris).Init()

-- Iris:Connect(Iris.ShowDemoWindow)

Iris:Connect(function()
    local Window = Iris.Window({ 'You won <stroke color="#00A2FF" joins="miter" thickness="2" transparency="0.25">25 gems</stroke>.' })
    Iris.Text({ "Hello, I am a dummy window for testing." })
    Iris.End()

    Iris.Window({ "Widget Testing" })
    do
        Iris.SeparatorText({ "Window States" })
        Iris.DragVector2({ "Size", Vector2.one, Vector2.zero, nil, "%d Pixels" }, { number = Window.size })
    end
    Iris.End()
end)
