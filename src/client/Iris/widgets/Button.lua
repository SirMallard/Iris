return function(Iris, widgets)
    local abstractButton = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget)
                return thisWidget.Instance
            end),
            ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.fromOffset(0, 0)
            Button.BackgroundColor3 = Iris._config.ButtonColor
            Button.BackgroundTransparency = Iris._config.ButtonTransparency
            Button.AutoButtonColor = false
        
            widgets.applyTextStyle(Button)
            Button.AutomaticSize = Enum.AutomaticSize.XY
        
            widgets.applyFrameStyle(Button)
        
            widgets.applyInteractionHighlights(Button, Button, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = Iris._config.ButtonTransparency,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })
    
            Button.ZIndex = thisWidget.ZIndex
            Button.LayoutOrder = thisWidget.ZIndex
    
            return Button
        end,
        Update = function(thisWidget)
            local Button = thisWidget.Instance
            Button.Text = thisWidget.arguments.Text or "Button"
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end
    }
    widgets.abstractButton = abstractButton
    
    Iris.WidgetConstructor("Button", widgets.extend(abstractButton, {
        Generate = function(thisWidget)
            local Button = abstractButton.Generate(thisWidget)
            Button.Name = "Iris_Button"
    
            return Button
        end
    }))
    
    Iris.WidgetConstructor("SmallButton", widgets.extend(abstractButton, {
        Generate = function(thisWidget)
            local SmallButton = abstractButton.Generate(thisWidget)
            SmallButton.Name = "Iris_SmallButton"
    
            local uiPadding = SmallButton.UIPadding
            uiPadding.PaddingLeft = UDim.new(0, 2)
            uiPadding.PaddingRight = UDim.new(0, 2)
            uiPadding.PaddingTop = UDim.new(0, 0)
            uiPadding.PaddingBottom = UDim.new(0, 0)
    
            return SmallButton
        end
    }))
end