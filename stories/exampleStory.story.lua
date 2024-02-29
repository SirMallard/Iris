local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(parent: GuiObject)
    local Iris = require(ReplicatedStorage.Iris)
    local Input = require(script.Parent.UserInputService)

    Input.SinkFrame.Parent = parent

    Iris.Internal._utility.UserInputService = Input
    Iris.UpdateGlobalConfig({
        UseScreenGUIs = false,
    })

    Iris.Init(parent)

    -- Actual Iris code here:
    Iris:Connect(Iris.ShowDemoWindow)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
