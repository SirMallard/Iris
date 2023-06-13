return function(Iris, widgets)
    local function onSelectionChange(thisWidget)
        if type(thisWidget.state.index.value) == "boolean" then
            thisWidget.state.index:set(not thisWidget.state.index.value)
        else
            thisWidget.state.index:set(thisWidget.arguments.Index)
        end
    end

    Iris.WidgetConstructor("Selectable", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Index"] = 2,
            ["NoClick"] = 3
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
                    return thisWidget.lastUnselected == Iris._cycleTick
                end            
            },
            ["active"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.state.index.value == thisWidget.arguments.Index
                end
            },
            ["clicked"] = widgets.EVENTS.click(function(thisWidget)
                return thisWidget.Instance.SelectableButton
            end),
            ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget)
                return thisWidget.Instance.SelectableButton
            end),
            ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget)
                return thisWidget.Instance.SelectableButton
            end),
            ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget)
                return thisWidget.Instance.SelectableButton
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance.SelectableButton
            end)
        },
        Generate = function(thisWidget)
            local Selectable = Instance.new("Frame")
            Selectable.Name = "Iris_Selectable"
            Selectable.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, Iris._config.TextSize))
            Selectable.BackgroundTransparency = 1
            Selectable.BorderSizePixel = 0
            Selectable.ZIndex = thisWidget.ZIndex
            Selectable.LayoutOrder = thisWidget.ZIndex
            Selectable.AutomaticSize = Enum.AutomaticSize.None

            local SelectableButton = Instance.new("TextButton")
            SelectableButton.Name = "SelectableButton"
            SelectableButton.Size = UDim2.new(1, 0, 1, Iris._config.ItemSpacing.Y)
            SelectableButton.ZIndex = thisWidget.ZIndex + 1
            SelectableButton.LayoutOrder = thisWidget.ZIndex + 1
            SelectableButton.BackgroundColor3 = Iris._config.HeaderColor
            widgets.applyFrameStyle(SelectableButton)
            widgets.applyTextStyle(SelectableButton)

            thisWidget.ButtonColors = {
                ButtonColor = Iris._config.HeaderColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderActiveColor,
                ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
            }

            SelectableButton.MouseButton1Down:Connect(function()
                if thisWidget.arguments.NoClick ~= true then
                    onSelectionChange(thisWidget)
                end
            end)

            widgets.applyInteractionHighlights(SelectableButton, SelectableButton, thisWidget.ButtonColors)

            SelectableButton.Parent = Selectable
    
            return Selectable
        end,
        Update = function(thisWidget)
            local SelectableButton = thisWidget.Instance.SelectableButton
            SelectableButton.Text = thisWidget.arguments.Text or "Selectable"
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.index == nil then
                if thisWidget.arguments.Index ~= nil then
                    error("a shared state index is required for Selectables with an Index argument", 5)
                end
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", false)
            end
        end,
        UpdateState = function(thisWidget)
            local SelectableButton = thisWidget.Instance.SelectableButton
            if thisWidget.state.index.value == (thisWidget.arguments.Index or true) then
                thisWidget.ButtonColors.ButtonTransparency = Iris._config.HeaderTransparency
                SelectableButton.BackgroundTransparency = Iris._config.HeaderTransparency
                thisWidget.lastSelectedTick = Iris._cycleTick + 1
            else
                thisWidget.ButtonColors.ButtonTransparency = 1
                SelectableButton.BackgroundTransparency = 1
                thisWidget.lastUnselectedTick = Iris._cycleTick + 1
            end
        end
    })
    
end