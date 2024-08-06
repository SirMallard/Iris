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
            Checkbox.AutomaticSize = Enum.AutomaticSize.XY
            Checkbox.Size = UDim2.fromOffset(0, 0)
            Checkbox.BackgroundTransparency = 1
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.AutoButtonColor = false
            Checkbox.ZIndex = thisWidget.ZIndex
            Checkbox.LayoutOrder = thisWidget.ZIndex
            
            local UIListLayout: UIListLayout = widgets.UIListLayout(Checkbox, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local checkboxSize: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

            local Box: Frame = Instance.new("Frame")
            Box.Name = "Box"
            Box.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
            Box.BackgroundColor3 = Iris._config.FrameBgColor
            Box.BackgroundTransparency = Iris._config.FrameBgTransparency
            
            widgets.applyFrameStyle(Box, true)
            widgets.UIPadding(Box, (checkboxSize // 10) * Vector2.one)

            widgets.applyInteractionHighlights(thisWidget, Checkbox, Box, {
                ButtonColor = Iris._config.FrameBgColor,
                ButtonTransparency = Iris._config.FrameBgTransparency,
                ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ButtonActiveColor = Iris._config.FrameBgActiveColor,
                ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })

            Box.Parent = Checkbox

            local Checkmark: ImageLabel = Instance.new("ImageLabel")
            Checkmark.Name = "Checkmark"
            Checkmark.Size = UDim2.fromScale(1, 1)
            Checkmark.BackgroundTransparency = 1
            Checkmark.ImageColor3 = Iris._config.CheckMarkColor
            Checkmark.ImageTransparency = Iris._config.CheckMarkTransparency
            Checkmark.ScaleType = Enum.ScaleType.Fit

            Checkmark.Parent = Box

            widgets.applyButtonClick(thisWidget, Checkbox, function()
                local wasChecked: boolean = thisWidget.state.isChecked.value
                thisWidget.state.isChecked:set(not wasChecked)
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.LayoutOrder = 1

            widgets.applyTextStyle(TextLabel)
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
            local Box = Checkbox.Box :: Frame
            local Checkmark: ImageLabel = Box.Checkmark
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
