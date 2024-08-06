local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Iris.Types)

local function render(Iris: Types.Iris)
    Iris.MenuBar()
    do
        Iris.Menu({ "A very long menu name for very little content!" })
        do
            Iris.MenuItem({ "T" })
        end
        Iris.End()
    end
    Iris.End()

    Iris.Window({ "Dev" })
    do
        Iris.ComboArray({ "Array" }, {}, { "abcdefghijklmnopqrstuvwxyz", "1234567890", "i ii iii iv v vi vii viii ix x", "ABCDEFGHIJKLMNOPQSTUVWXYZ", ". .. ... .... ....." })
        Iris.ComboArray({ "Array", true }, {}, { "abcdefghijklmnopqrstuvwxyz", "1234567890", "i ii iii iv v vi vii viii ix x", "ABCDEFGHIJKLMNOPQSTUVWXYZ", ". .. ... .... ....." })
        Iris.ComboArray({ "Array", nil, true }, {}, { "abcdefghijklmnopqrstuvwxyz", "1234567890", "i ii iii iv v vi vii viii ix x", "ABCDEFGHIJKLMNOPQSTUVWXYZ", ". .. ... .... ....." })

        local progress = Iris.State(0)

        -- formula to cycle between 0 and 100 linearly
        local newValue = math.clamp((math.abs((os.clock() * 15) % 100 - 50)) - 7.5, 0, 35) / 35
        progress:set(newValue)

        Iris.InputText({ "Input" })
        Iris.Checkbox({ "Checkbox\nCheckbox\nCheckbox\nCheckbox" })
        Iris.RadioButton({ "Radio\nRadio\nRadio\nRadio" })
        Iris.ProgressBar({ "Progress\nProgress\nProgress\nProgress" }, { progress = progress })
    end
    Iris.End()
end

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
        render(Iris)
    end)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
