return function(Iris, widgets)
    Iris.WidgetConstructor("RadioButton", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Index"] = 2
        },
        Events = {
            ["selected"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastSelectedTick == Iris._cycleTick
                end
            },
            ["unselected"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastUnselectedTick == Iris._cycleTick
                end
            },
            ["active"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.state.index.value == thisWidget.arguments.Index
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local RadioButton = Instance.new("TextButton")
            RadioButton.Name = "Iris_RadioButton"
            RadioButton.BackgroundTransparency = 1
            RadioButton.BorderSizePixel = 0
            RadioButton.Size = UDim2.fromOffset(0, 0)
            RadioButton.Text = ""
            RadioButton.AutomaticSize = Enum.AutomaticSize.XY
            RadioButton.ZIndex = thisWidget.ZIndex
            RadioButton.AutoButtonColor = false
            RadioButton.LayoutOrder = thisWidget.ZIndex
    
            local buttonSize = Iris._config.TextSize + 2 * (Iris._config.FramePadding.Y - 1)
            local Button = Instance.new("Frame")
            Button.Name = "Button"
            Button.Size = UDim2.fromOffset(buttonSize, buttonSize)
            Button.ZIndex = thisWidget.ZIndex + 1
            Button.LayoutOrder = thisWidget.ZIndex + 1
            Button.Parent = RadioButton
            Button.BackgroundColor3 = Iris._config.FrameBgColor
            Button.BackgroundTransparency = Iris._config.FrameBgTransparency
    
            widgets.UICorner(Button)
    
            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Position = UDim2.fromOffset(Iris._config.FramePadding.Y, Iris._config.FramePadding.Y)
            Circle.Size = UDim2.fromOffset(Iris._config.TextSize - 2, Iris._config.TextSize - 2 )
            Circle.ZIndex = thisWidget.ZIndex + 1
            Circle.LayoutOrder = thisWidget.ZIndex + 1
            Circle.Parent = Button
            Circle.BackgroundColor3 = Iris._config.CheckMarkColor
            Circle.BackgroundTransparency = Iris._config.CheckMarkTransparency
            widgets.UICorner(Circle)
    
            widgets.applyInteractionHighlights(RadioButton, Button, {
                ButtonColor = Iris._config.FrameBgColor,
                ButtonTransparency = Iris._config.FrameBgTransparency,
                ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ButtonActiveColor = Iris._config.FrameBgActiveColor,
                ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })
    
            RadioButton.MouseButton1Click:Connect(function()
                thisWidget.state.index:set(thisWidget.arguments.Index)
            end)
    
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            widgets.applyTextStyle(TextLabel)
            TextLabel.Position = UDim2.new(0,buttonSize + Iris._config.ItemInnerSpacing.X, 0.5, 0)
            TextLabel.ZIndex = thisWidget.ZIndex + 1
            TextLabel.LayoutOrder = thisWidget.ZIndex + 1
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.Parent = RadioButton
    
            return RadioButton
        end,
        Update = function(thisWidget)
            thisWidget.Instance.TextLabel.Text = thisWidget.arguments.Text or "Radio Button"
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", thisWidget.arguments.Value)
            end
        end,
        UpdateState = function(thisWidget)
            local Circle = thisWidget.Instance.Button.Circle
            if thisWidget.state.index.value == thisWidget.arguments.Index then
                -- only need to hide the circle
                Circle.BackgroundTransparency = Iris._config.CheckMarkTransparency
                thisWidget.lastSelectedTick = Iris._cycleTick + 1
            else
                Circle.BackgroundTransparency = 1
                thisWidget.lastUnselectedTick = Iris._cycleTick + 1
            end
        end
    })
end