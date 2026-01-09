local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(parent: GuiObject)
    local Iris = require(ReplicatedStorage.Iris)
    local DemoWindow = require(ReplicatedStorage.Iris.DemoWindow)
    local Input = require(script.Parent.UserInputService)

    Input.SinkFrame.Parent = parent

    Iris._utility.UserInputService = Input
    Iris.UpdateGlobalConfig({
        UseScreenGUIs = false,
    })
    Iris._utility.guiOffset = Input.SinkFrame.AbsolutePosition
    Iris._utility.mouseOffset = Input.SinkFrame.AbsolutePosition
    Input.SinkFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        Iris._utility.guiOffset = Input.SinkFrame.AbsolutePosition
        Iris._utility.mouseOffset = Input.SinkFrame.AbsolutePosition
    end)

    Iris.Init(parent)

    -- Actual Iris code here:
    Iris:Connect(DemoWindow)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
