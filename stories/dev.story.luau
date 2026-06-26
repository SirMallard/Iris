local function render(Iris)
    Iris.Window("Dev")
    do
        Iris.Table(4, Iris.TableFlags.Header + Iris.TableFlags.RowBackground + Iris.TableFlags.Borders)
        do
            Iris.SetHeaderColumnIndex(1)
            for i = 1, 4 do
                Iris.Text(`Column: {i}`)
                Iris.NextHeaderColumn()
            end

            Iris.NextRow()
            for j = 1, 10 do
                for i = 1, 4 do
                    Iris.Button(`Cell ({i}, {j})`)
                    Iris.NextColumn()
                end
            end
        end
        Iris.End()
    end
    Iris.End()
end

return function(parent: GuiObject)
    local Iris = require("@game/ReplicatedStorage/Iris")
    local Input = require("./UserInputService")

    Input.SinkFrame.Parent = parent

    Iris._utility.UserInputService = Input
    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
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
