local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Iris.Types)

function main(Iris: Types.Iris)
    Iris:Connect(function()
        Iris.ShowDemoWindow()

        -- Iris.Window({ "Testing" })
        -- do
        --     Iris.SeparatorText({ "Image Widgets" })

        --     local Image = Iris.State(nil)
        --     local Size = Iris.State(Vector2.one * 100)
        --     local ImageRect = Iris.State(Rect.new())
        --     local ScaleType = Iris.State(Enum.ScaleType.Fit)
        --     local ResampleMode = Iris.State(false)
        --     local TileSize = Iris.State(UDim2.new(1, 0, 1, 0))
        --     local SliceCenter = Iris.State(Rect.new())
        --     local SliceScale = Iris.State(1)

        --     Iris.Combo({ "Image" }, { index = Image })
        --     do
        --         for name: string, value: string in Iris.Internal._utility.ICONS :: { [string]: string } do
        --             Iris.Selectable({ name, value }, { index = Image })
        --         end
        --         Iris.Selectable({ "None", nil }, { index = Image })
        --     end
        --     Iris.End()

        --     Iris.SliderVector2({ "Size", 1, 0, 320 }, { number = Size })
        --     Iris.SliderRect({ "Rect" }, { number = ImageRect })
        --     Iris.ComboEnum({ "ScaleType" }, { index = ScaleType }, Enum.ScaleType)
        --     Iris.Checkbox({ "ResampleMode" }, { isChecked = ResampleMode })

        --     Iris.SliderUDim2({ "TileSize" }, { number = TileSize })
        --     Iris.SliderRect({ "SliceCenter" }, { number = SliceCenter })
        --     Iris.SliderNum({ "SliceScale", 0.1, 0, 10 }, { number = SliceScale })

        --     Iris.Image({ Image:get(), Size:get(), ImageRect:get(), ScaleType:get(), ResampleMode:get() and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default, TileSize:get(), SliceCenter:get(), SliceScale:get() })

        --     Iris.End()
        -- end
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
