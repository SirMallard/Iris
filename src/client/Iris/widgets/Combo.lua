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
            SelectableButton.Size = UDim2.new(1, 0, 1, Iris._config.ItemSpacing.Y - 1)
            SelectableButton.Position = UDim2.fromOffset(0, -bit32.rshift(Iris._config.ItemSpacing.Y, 1))
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
            widgets.discardState(thisWidget)
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

    local AnyOpenedCombo = false
    local ComboOpenedTick = -1
    local OpenedCombo

    local function UpdateChildContainerTransform(thisWidget)
        local Iris_Combo = thisWidget.Instance
        local PreviewContainer = Iris_Combo.PreviewContainer
        local PreviewLabel = PreviewContainer.PreviewLabel
        local ChildContainer = thisWidget.ChildContainer

        local ChildContainerBorderSize = Iris._config.PopupBorderSize
        local ChildContainerHeight = thisWidget.LabelHeight * math.min(thisWidget.NumChildrenForSize, 8) - 2 * ChildContainerBorderSize
        local ChildContainerWidth = UDim.new(0, PreviewContainer.AbsoluteSize.X - 2 * ChildContainerBorderSize)
        ChildContainer.Size = UDim2.new(ChildContainerWidth, UDim.new(0, ChildContainerHeight))

        local ScreenSize = ChildContainer.Parent.AbsoluteSize

        if PreviewLabel.AbsolutePosition.Y + thisWidget.LabelHeight + ChildContainerHeight > ScreenSize.Y then
            -- too large to fit below the Combo, so is placed above
            ChildContainer.Position = UDim2.new(0, PreviewLabel.AbsolutePosition.X + ChildContainerBorderSize, 0, PreviewLabel.AbsolutePosition.Y - ChildContainerBorderSize - ChildContainerHeight)
        else
            ChildContainer.Position = UDim2.new(0, PreviewLabel.AbsolutePosition.X + ChildContainerBorderSize, 0, PreviewLabel.AbsolutePosition.Y + thisWidget.LabelHeight + ChildContainerBorderSize)
        end
    end

    widgets.UserInputService.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 and inputObject.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if AnyOpenedCombo == false then
            return
        end
        if ComboOpenedTick == Iris._cycleTick then
            return
        end
        local MouseLocation = widgets.UserInputService:GetMouseLocation() - Vector2.new(0, 36)
        local ChildContainer = OpenedCombo.ChildContainer
        local rectMin = ChildContainer.AbsolutePosition - Vector2.new(0, OpenedCombo.LabelHeight)
        local rectMax = ChildContainer.AbsolutePosition + ChildContainer.AbsoluteSize
        if not widgets.isPosInsideRect(MouseLocation, rectMin, rectMax) then
            OpenedCombo.state.isOpened:set(false)
        end
    end)
    
    Iris.WidgetConstructor("Combo", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Text"] = 1,
            ["NoButton"] = 2,
            ["NoPreview"] = 3,
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end),
            ["opened"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end
            },
            ["closed"] = {
                ["Init"] = function(thisWidget)
                    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end
            }
        },
        Generate = function(thisWidget)
            thisWidget.ContentWidth = Iris._config.ContentWidth
            thisWidget.LabelHeight = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
            thisWidget.NumChildrenForSize = 0

            local Combo = Instance.new("Frame")
            Combo.Name = "Iris_Combo"
            Combo.Size = UDim2.fromScale(1, 0)
            Combo.AutomaticSize = Enum.AutomaticSize.Y
            Combo.BackgroundTransparency = 1
            Combo.BorderSizePixel = 0
            Combo.ZIndex = thisWidget.ZIndex
            Combo.LayoutOrder = thisWidget.ZIndex
            widgets.UIListLayout(Combo, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.Y))

            local PreviewContainer = Instance.new("TextButton")
            PreviewContainer.Name = "PreviewContainer"
            PreviewContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            widgets.applyFrameStyle(PreviewContainer, true, true)
            PreviewContainer.BackgroundTransparency = 1
            PreviewContainer.ZIndex = thisWidget.ZIndex + 2
            PreviewContainer.LayoutOrder = thisWidget.ZIndex + 2
			PreviewContainer.Text = ""
            PreviewContainer.AutoButtonColor = false
            widgets.UIListLayout(PreviewContainer, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            PreviewContainer.Parent = Combo

            local PreviewLabel = Instance.new("TextLabel")
            PreviewLabel.Name = "PreviewLabel"
            PreviewLabel.Size = UDim2.new(1, 0, 0, 0)
            PreviewLabel.BackgroundColor3 = Iris._config.FrameBgColor
            PreviewLabel.BackgroundTransparency = Iris._config.FrameBgTransparency
            PreviewLabel.BorderSizePixel = 0
            PreviewLabel.ZIndex = thisWidget.ZIndex + 3
            PreviewLabel.LayoutOrder = thisWidget.ZIndex + 3
            PreviewLabel.AutomaticSize = Enum.AutomaticSize.Y
            widgets.applyTextStyle(PreviewLabel)
            widgets.UIPadding(PreviewLabel, Iris._config.FramePadding)

            PreviewLabel.Parent = PreviewContainer

            local DropdownButtonSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
            local DropdownButton = Instance.new("TextLabel")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Size = UDim2.new(0, DropdownButtonSize, 0, DropdownButtonSize)
            DropdownButton.BackgroundColor3 = Iris._config.ButtonColor
            DropdownButton.BackgroundTransparency = Iris._config.ButtonTransparency
            DropdownButton.BorderSizePixel = 0
            DropdownButton.ZIndex = thisWidget.ZIndex + 4
            DropdownButton.LayoutOrder = thisWidget.ZIndex + 4
            widgets.applyTextStyle(DropdownButton)
            DropdownButton.TextXAlignment = Enum.TextXAlignment.Center

            DropdownButton.Parent = PreviewContainer

            local textLabelHeight = Iris._config.TextSize + Iris._config.FramePadding.Y * 2

            -- for some reason ImGui Combo has no highlights for Active, only hovered.
            -- so this deviates from ImGui, but its a good UX change
            widgets.applyInteractionHighlightsWithMultiHighlightee(PreviewContainer, {
                {
                    PreviewLabel, {
                        ButtonColor = Iris._config.FrameBgColor,
                        ButtonTransparency = Iris._config.FrameBgTransparency,
                        ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                        ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                        ButtonActiveColor = Iris._config.FrameBgActiveColor,
                        ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                    }
                },
                {
                    DropdownButton, {
                        ButtonColor = Iris._config.ButtonColor,
                        ButtonTransparency = Iris._config.ButtonTransparency,
                        ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                        ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                        -- Use hovered for active
                        ButtonActiveColor = Iris._config.ButtonHoveredColor,
                        ButtonActiveTransparency = Iris._config.ButtonHoveredColor,
                    }
                }
            })

            PreviewContainer.InputBegan:Connect(function(inputObject)
                if AnyOpenedCombo and OpenedCombo ~= thisWidget then
                    return
                end
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                    thisWidget.state.isOpened:set(not thisWidget.state.isOpened.value)
                end
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 5
            TextLabel.LayoutOrder = thisWidget.ZIndex + 5
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = Combo

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
            
            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0
            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Iris._config.PopupRounding > 0 then
            --     widgets.UICorner(ChildContainer, Iris._config.PopupRounding)
            -- end

            local uiStroke = Instance.new("UIStroke")
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.LineJoinMode = Enum.LineJoinMode.Round
            uiStroke.Thickness = Iris._config.WindowBorderSize
            uiStroke.Color = Iris._config.BorderColor
            uiStroke.Parent = ChildContainer
            widgets.UIPadding(ChildContainer, Vector2.new(2, Iris._config.WindowPadding.Y - Iris._config.ItemSpacing.Y))
            -- appear over everything else
            ChildContainer.ZIndex = thisWidget.ZIndex + 6
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 6
			ChildContainer.ClipsDescendants = true

            local ChildContainerUIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Iris._rootInstance.PopupScreenGui
            ChildContainer.Parent = RootPopupScreenGui
            thisWidget.ChildContainer = ChildContainer

            return Combo
        end,
        Update = function(thisWidget)
            local Iris_Combo = thisWidget.Instance
            local PreviewContainer = Iris_Combo.PreviewContainer
            local PreviewLabel = PreviewContainer.PreviewLabel
            local DropdownButton = PreviewContainer.DropdownButton
            local TextLabel = Iris_Combo.TextLabel

            TextLabel.Text = thisWidget.arguments.Text or "Combo"
            
            if thisWidget.arguments.NoButton then
                DropdownButton.Visible = false
                PreviewLabel.Size = UDim2.new(1, 0, 0, 0)
            else
                DropdownButton.Visible = true
                local DropdownButtonSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
                PreviewLabel.Size = UDim2.new(1, - DropdownButtonSize, 0, 0)
            end

            if thisWidget.arguments.NoPreview then
                PreviewLabel.Visible = false
				PreviewContainer.Size = UDim2.new(0, 0, 0, 0)
				PreviewContainer.AutomaticSize = Enum.AutomaticSize.X
            else
                PreviewLabel.Visible = true
				PreviewContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
				PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            end
        end,
        ChildAdded = function(thisWidget, thisChild)
            -- default to largest size if there are widgets other than selectables inside the combo
            if thisChild.type ~= "Selectable" then
                thisWidget.NumChildrenForSize += 10
            else
                thisWidget.NumChildrenForSize += 1
            end
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.ChildContainer
        end,
        ChildDiscarded = function(thisWidget, thisChild)
            if thisChild.type ~= "Selectable" then
                thisWidget.NumChildrenForSize -= 10
            else
                thisWidget.NumChildrenForSize -= 1
            end  
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", "No Selection")
            end
            thisWidget.state.index:onChange(function()
                if thisWidget.state.isOpened.value then
                    thisWidget.state.isOpened:set(false)
                end
            end)
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", false)
            end
        end,
        UpdateState = function(thisWidget)
            local Iris_Combo = thisWidget.Instance
            local PreviewContainer = Iris_Combo.PreviewContainer
            local PreviewLabel = PreviewContainer.PreviewLabel
            local DropdownButton = PreviewContainer.DropdownButton
            local ChildContainer = thisWidget.ChildContainer

            if thisWidget.state.isOpened.value then
                AnyOpenedCombo = true
                OpenedCombo = thisWidget
                ComboOpenedTick = Iris._cycleTick
                thisWidget.lastOpenedTick = Iris._cycleTick + 1

                -- ImGui also does not do this, and the Arrow is always facing down
                DropdownButton.Text = widgets.ICONS.RIGHT_POINTING_TRIANGLE
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                if AnyOpenedCombo then
                    AnyOpenedCombo = false
                    OpenedCombo = nil
                    thisWidget.lastClosedTick = Iris._cycleTick + 1
                end
                DropdownButton.Text = widgets.ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = false
            end

            local stateIndex = thisWidget.state.index.value
            PreviewLabel.Text = if (typeof(stateIndex) == "EnumItem") then stateIndex.Name else tostring(stateIndex)
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end
    })

    Iris.ComboArray = function(args, state, SelectionArray)
        local defaultState
        if state == nil then
            defaultState = Iris.State(SelectionArray[1])
        else
            defaultState = state
        end
        local thisWidget = Iris._Insert("Combo", args, defaultState)
        local sharedIndex = thisWidget.state.index
        for _, Selection in SelectionArray do
            Iris._Insert("Selectable", {Selection, Selection}, {index = sharedIndex})
        end
        Iris.End()

        return thisWidget
    end

    Iris.InputEnum = function(args, state, enumType)
        local defaultState
        if state == nil then
            defaultState = Iris.State(enumType[1])
        else
            defaultState = state
        end
        local thisWidget = Iris._Insert("Combo", args, defaultState)
        local sharedIndex = thisWidget.state.index
        for _, Selection in enumType:GetEnumItems() do
            Iris._Insert("Selectable", {Selection.Name, Selection}, {index = sharedIndex})
        end 
        Iris.End()

        return thisWidget
    end
end