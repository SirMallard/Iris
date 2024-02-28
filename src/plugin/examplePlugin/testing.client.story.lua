function render(Iris)
    Iris:Connect(Iris.ShowDemoWindow)

    Iris:Connect(function()
        Iris.Window({ "Progress Bar Testing" })
        do
            local Progress = Iris.State(0)
            Iris.SliderNum({ "Progress Value", 0.01, 0, 1 }, { number = Progress })
            Iris.Text({ `Value: {Progress.value}` })

            Iris.ProgressBar({ "Progress Bar" }, { progress = Progress })
            Iris.ProgressBar({ "Progress Bar", `{math.floor(Progress:get() * 1753)}/1753` }, { progress = Progress })

            Iris.End()
        end
    end)
end

return function(parent: GuiObject)
    local Iris = require(script.Parent.Parent.Iris)
    local Input = require(script.Parent.UserInputService)

    Input.SinkFrame.Parent = parent

    Iris.Internal._utility.UserInputService = Input
    Iris.UpdateGlobalConfig({
        UseScreenGUIs = false,
    })

    Iris.Init(parent)

    render(Iris)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
