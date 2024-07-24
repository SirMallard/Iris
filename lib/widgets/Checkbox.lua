local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    --stylua: ignore
    Iris.WidgetConstructor("Checkbox", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
        },
        Events = {
            ["checked"] = {
                ["Init"] = function(_thisWidget: Types.Checkbox) end,
                ["Get"] = function(thisWidget: Types.Checkbox): boolean
                    return thisWidget.lastCheckedTick == Iris._cycleTick
                end,
            },
            ["unchecked"] = {
                ["Init"] = function(_thisWidget: Types.Checkbox) end,
                ["Get"] = function(thisWidget: Types.Checkbox): boolean
                    return thisWidget.lastUncheckedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Checkbox)
            local Checkbox: TextButton = Instance.new("TextButton")
            Checkbox.Name = "Iris_Checkbox"
            Checkbox.BackgroundTransparency = 1
            Checkbox.BorderSizePixel = 0
            Checkbox.Size = UDim2.fromOffset(0, 0)
            Checkbox.Text = ""
            Checkbox.AutomaticSize = Enum.AutomaticSize.XY
            Checkbox.LayoutOrder = thisWidget.ZIndex
            Checkbox.AutoButtonColor = false

            local checkboxSize: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

            local CheckboxBox: Frame = Instance.new("Frame")
            CheckboxBox.Name = "CheckboxBox"
            CheckboxBox.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
            CheckboxBox.BackgroundColor3 = Iris._config.FrameBgColor
            CheckboxBox.BackgroundTransparency = Iris._config.FrameBgTransparency
            widgets.applyFrameStyle(CheckboxBox, true)

            widgets.applyInteractionHighlights(thisWidget, "Background", Checkbox, CheckboxBox, {
                Color = Iris._config.FrameBgColor,
                Transparency = Iris._config.FrameBgTransparency,
                HoveredColor = Iris._config.FrameBgHoveredColor,
                HoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ActiveColor = Iris._config.FrameBgActiveColor,
                ActiveTransparency = Iris._config.FrameBgActiveTransparency,
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
            Checkmark.ZIndex = 2

            Checkmark.Parent = Checkbox

            widgets.applyButtonClick(thisWidget, Checkbox, function()
                local wasChecked: boolean = thisWidget.state.isChecked.value
                thisWidget.state.isChecked:set(not wasChecked)
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            widgets.applyTextStyle(TextLabel)
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.Position = UDim2.new(0, checkboxSize + Iris._config.ItemInnerSpacing.X, 0.5, 0)
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.Parent = Checkbox

            return Checkbox
        end,
        Update = function(thisWidget: Types.Checkbox)
            local Checkbox = thisWidget.Instance :: TextButton
            Checkbox.TextLabel.Text = thisWidget.arguments.Text or "Checkbox"
        end,
        Discard = function(thisWidget: Types.Checkbox)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Checkbox)
            if thisWidget.state.isChecked == nil then
                thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
            end
        end,
        UpdateState = function(thisWidget: Types.Checkbox)
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
