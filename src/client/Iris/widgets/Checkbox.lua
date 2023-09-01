local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    Iris.WidgetConstructor("Checkbox", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
        },
        Events = {
            ["checked"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastCheckedTick == Iris._cycleTick
                end,
            },
            ["unchecked"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastUncheckedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget): GuiObject
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget): TextButton
            local Checkbox: TextButton = Instance.new("TextButton")
            Checkbox.Name = "Iris_Checkbox"
            Checkbox.BackgroundTransparency = 1
            Checkbox.BorderSizePixel = 0
            Checkbox.Size = UDim2.fromOffset(0, 0)
            Checkbox.Text = ""
            Checkbox.AutomaticSize = Enum.AutomaticSize.XY
            Checkbox.ZIndex = thisWidget.ZIndex
            Checkbox.AutoButtonColor = false
            Checkbox.LayoutOrder = thisWidget.ZIndex

            local checkboxSize: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

            local CheckboxBox: Frame = Instance.new("Frame")
            CheckboxBox.Name = "CheckboxBox"
            CheckboxBox.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
            CheckboxBox.BackgroundColor3 = Iris._config.FrameBgColor
            CheckboxBox.BackgroundTransparency = Iris._config.FrameBgTransparency
            CheckboxBox.ZIndex = thisWidget.ZIndex + 1
            CheckboxBox.LayoutOrder = thisWidget.ZIndex + 1
            widgets.applyFrameStyle(CheckboxBox, true)

            widgets.applyInteractionHighlights(Checkbox, CheckboxBox, {
                ButtonColor = Iris._config.FrameBgColor,
                ButtonTransparency = Iris._config.FrameBgTransparency,
                ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ButtonActiveColor = Iris._config.FrameBgActiveColor,
                ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })

            CheckboxBox.Parent = Checkbox

            local padding: number = math.ceil(checkboxSize * 0.1)
            local checkmarkSize: number = checkboxSize - 2 * padding

            local Checkmark: ImageLabel = Instance.new("ImageLabel")
            Checkmark.Name = "Checkmark"
            Checkmark.Size = UDim2.fromOffset(checkmarkSize, checkmarkSize)
            Checkmark.Position = UDim2.fromOffset(padding, padding)
            Checkmark.BackgroundTransparency = 1
            Checkmark.ImageColor3 = Iris._config.CheckMarkColor
            Checkmark.ImageTransparency = Iris._config.CheckMarkTransparency
            Checkmark.ScaleType = Enum.ScaleType.Fit
            Checkmark.ZIndex = thisWidget.ZIndex + 2
            Checkmark.LayoutOrder = thisWidget.ZIndex + 2

            Checkmark.Parent = Checkbox

            Checkbox.MouseButton1Click:Connect(function()
                local wasChecked: boolean = thisWidget.state.isChecked.value
                thisWidget.state.isChecked:set(not wasChecked)
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            widgets.applyTextStyle(TextLabel)
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.Position = UDim2.new(0, checkboxSize + Iris._config.ItemInnerSpacing.X, 0.5, 0)
            TextLabel.ZIndex = thisWidget.ZIndex + 1
            TextLabel.LayoutOrder = thisWidget.ZIndex + 1
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.Parent = Checkbox

            return Checkbox
        end,
        Update = function(thisWidget: Types.Widget)
            local Checkbox = thisWidget.Instance :: TextButton
            Checkbox.TextLabel.Text = thisWidget.arguments.Text or "Checkbox"
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.isChecked == nil then
                thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
            end
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local Checkbox = thisWidget.Instance :: TextButton
            local Checkmark: ImageLabel = Checkbox.Checkmark
            if thisWidget.state.isChecked.value then
                Checkmark.Image = widgets.ICONS.CHECK_MARK
                thisWidget.lastCheckedTick = Iris._cycleTick + 1
            else
                Checkmark.Image = ""
                thisWidget.lastUncheckedTick = Iris._cycleTick + 1
            end
        end,
    } :: Types.WidgetClass)
end
