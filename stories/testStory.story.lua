local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Iris.PubTypes)

return function(parent: GuiObject)
    local Iris: Types.Iris = require(ReplicatedStorage.Iris)
    local Input = require(script.Parent.UserInputService)

    Input.SinkFrame.Parent = parent

    Iris.Internal._utility.UserInputService = Input
    Iris.UpdateGlobalConfig({
        UseScreenGUIs = false,
    })
    Iris.Internal._utility.GuiOffset = Input.SinkFrame.AbsolutePosition
    Iris.Internal._utility.MouseOffset = Input.SinkFrame.AbsolutePosition
    Input.SinkFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        Iris.Internal._utility.GuiOffset = Input.SinkFrame.AbsolutePosition
        Iris.Internal._utility.MouseOffset = Input.SinkFrame.AbsolutePosition
    end)

    Iris.Init(parent)

    -- Actual Iris code here:
    Iris:Connect(function()
        local color = Iris.State(Color3.new(1, 0, 0))
        local compare = Iris.State(false)

        Iris.Window({ "Window" })
        local compareCheck = Iris.Checkbox({ "Compare" }, { isChecked = compare })
        local compared = Iris.InputColor3({ "Compared Color" }, { color = Color3.new(0, 1, 0) })
        Iris.InputColor3({ "Picker Color" }, { color = color })
        Iris.ColorPicker({ compareCheck.state.isChecked.value and compared.state.color:get() or false }, { color = color })
        Iris.End()
    end)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
