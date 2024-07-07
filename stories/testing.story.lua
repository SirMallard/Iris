local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Iris.Types)

function main(Iris: Types.Iris)
    Iris:Connect(function()
        Iris.Window({ "Testing" })
        do
            Iris.SeparatorText({ "Image Widgets" })

            local Icon = Iris.State(nil)
            local Size = Iris.State(Vector2.one * 100)

            Iris.Combo({ "Icon" }, { index = Icon })
            do
                for name: string, value: string in Iris.Internal._utility.ICONS :: { [string]: string } do
                    Iris.Selectable({ name, value }, { index = Icon })
                end
                Iris.Selectable({ "None", nil }, { index = Icon })
            end
            Iris.End()

            Iris.SliderVector2({ "Size" }, { number = Size })

            Iris.Image({ Icon:get(), Size:get() })
            Iris.Image({ Icon:get(), Size:get(), nil, Enum.ResamplerMode.Pixelated })

            Iris.End()
        end
    end)
end

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
    main(Iris)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
