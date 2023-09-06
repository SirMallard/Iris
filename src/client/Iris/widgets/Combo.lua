local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
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
            ["NoClick"] = 3,
        },
        Events = {
            ["selected"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastSelectedTick == Iris._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastUnselectedTick == Iris._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.state.index.value == thisWidget.arguments.Index
                end,
            },
            ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.Instance :: Frame
                return Selectable.SelectableButton
            end),
            ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.Instance :: Frame
                return Selectable.SelectableButton
            end),
            ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.Instance :: Frame
                return Selectable.SelectableButton
            end),
            ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.Instance :: Frame
                return Selectable.SelectableButton
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.Instance :: Frame
                return Selectable.SelectableButton
            end),
        },
        Generate = function(thisWidget: Types.Widget): Frame
            local Selectable: Frame = Instance.new("Frame")
            Selectable.Name = "Iris_Selectable"
            Selectable.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, Iris._config.TextSize))
            Selectable.AutomaticSize = Enum.AutomaticSize.None
            Selectable.BackgroundTransparency = 1
            Selectable.BorderSizePixel = 0
            Selectable.ZIndex = thisWidget.ZIndex
            Selectable.LayoutOrder = thisWidget.ZIndex

            local SelectableButton: TextButton = Instance.new("TextButton")
            SelectableButton.Name = "SelectableButton"
            SelectableButton.Size = UDim2.new(1, 0, 1, Iris._config.ItemSpacing.Y - 1)
            SelectableButton.Position = UDim2.fromOffset(0, -bit32.rshift(Iris._config.ItemSpacing.Y, 1))
            SelectableButton.BackgroundColor3 = Iris._config.HeaderColor
            SelectableButton.ZIndex = thisWidget.ZIndex + 1
            SelectableButton.LayoutOrder = thisWidget.ZIndex + 1

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

            widgets.applyInteractionHighlights(SelectableButton, SelectableButton, thisWidget.ButtonColors)

            SelectableButton.MouseButton1Click:Connect(function()
                if thisWidget.arguments.NoClick ~= true then
                    onSelectionChange(thisWidget)
                end
            end)

            SelectableButton.Parent = Selectable

            return Selectable
        end,
        Update = function(thisWidget: Types.Widget)
            local Selectable = thisWidget.Instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton
            SelectableButton.Text = thisWidget.arguments.Text or "Selectable"
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.index == nil then
                if thisWidget.arguments.Index ~= nil then
                    error("a shared state index is required for Selectables with an Index argument", 5)
                end
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", false)
            end
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local Selectable = thisWidget.Instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton
            if thisWidget.state.index.value == (thisWidget.arguments.Index or true) then
                thisWidget.ButtonColors.ButtonTransparency = Iris._config.HeaderTransparency
                SelectableButton.BackgroundTransparency = Iris._config.HeaderTransparency
                thisWidget.lastSelectedTick = Iris._cycleTick + 1
            else
                thisWidget.ButtonColors.ButtonTransparency = 1
                SelectableButton.BackgroundTransparency = 1
                thisWidget.lastUnselectedTick = Iris._cycleTick + 1
            end
        end,
    } :: Types.WidgetClass)

    local AnyOpenedCombo = false
    local ComboOpenedTick = -1
    local OpenedCombo

    local function UpdateChildContainerTransform(thisWidget: Types.Widget)
        local Iris_Combo = thisWidget.Instance :: Frame
        local PreviewContainer = Iris_Combo.PreviewContainer :: TextButton
        local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
        local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame

        local labelHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

        local borderWidth: number = Iris._config.PopupBorderSize
        local ChildContainerHeight: number = (labelHeight * math.min(thisWidget.ComboChildrenHeight, 8) - 2 * borderWidth) + (3 * Iris._config.FramePadding.Y)
        local ChildContainerWidth: UDim = UDim.new(0, PreviewContainer.AbsoluteSize.X - 2 * borderWidth)
        ChildContainer.Size = UDim2.new(ChildContainerWidth, UDim.new(0, ChildContainerHeight))

        local ScreenSize: Vector2 = ChildContainer.Parent.AbsoluteSize

        if PreviewLabel.AbsolutePosition.Y + labelHeight + ChildContainerHeight > ScreenSize.Y then
            -- too large to fit below the Combo, so is placed above
            ChildContainer.Position = UDim2.new(0, PreviewLabel.AbsolutePosition.X + borderWidth, 0, PreviewLabel.AbsolutePosition.Y - borderWidth - ChildContainerHeight)
        else
            ChildContainer.Position = UDim2.new(0, PreviewLabel.AbsolutePosition.X + borderWidth, 0, PreviewLabel.AbsolutePosition.Y + labelHeight + borderWidth)
        end
    end

    widgets.UserInputService.InputBegan:Connect(function(inputObject: InputObject)
        if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 and inputObject.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if AnyOpenedCombo == false then
            return
        end
        if ComboOpenedTick == Iris._cycleTick then
            return
        end
        local MouseLocation: Vector2 = widgets.getMouseLocation()
        local ChildContainer = OpenedCombo.ChildContainer
        local rectMin: Vector2 = ChildContainer.AbsolutePosition - Vector2.new(0, OpenedCombo.LabelHeight)
        local rectMax: Vector2 = ChildContainer.AbsolutePosition + ChildContainer.AbsoluteSize
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
            ["opened"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end,
            },
            ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local frameHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
            thisWidget.ComboChildrenHeight = 0

            local Combo: Frame = Instance.new("Frame")
            Combo.Name = "Iris_Combo"
            Combo.Size = UDim2.fromScale(1, 0)
            Combo.AutomaticSize = Enum.AutomaticSize.Y
            Combo.BackgroundTransparency = 1
            Combo.BorderSizePixel = 0
            Combo.ZIndex = thisWidget.ZIndex
            Combo.LayoutOrder = thisWidget.ZIndex

            widgets.UIListLayout(Combo, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.Y + 1))

            local PreviewContainer: TextButton = Instance.new("TextButton")
            PreviewContainer.Name = "PreviewContainer"
            PreviewContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            PreviewContainer.BackgroundTransparency = 1
            PreviewContainer.Text = ""
            PreviewContainer.ZIndex = thisWidget.ZIndex + 2
            PreviewContainer.LayoutOrder = thisWidget.ZIndex + 2
            PreviewContainer.AutoButtonColor = false

            widgets.applyFrameStyle(PreviewContainer, true, true)
            widgets.UIListLayout(PreviewContainer, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            PreviewContainer.Parent = Combo

            local PreviewLabel: TextLabel = Instance.new("TextLabel")
            PreviewLabel.Name = "PreviewLabel"
            PreviewLabel.Size = UDim2.new(1, 0, 0, 0)
            PreviewLabel.AutomaticSize = Enum.AutomaticSize.Y
            PreviewLabel.BackgroundColor3 = Iris._config.FrameBgColor
            PreviewLabel.BackgroundTransparency = Iris._config.FrameBgTransparency
            PreviewLabel.BorderSizePixel = 0
            PreviewLabel.ZIndex = thisWidget.ZIndex + 3
            PreviewLabel.LayoutOrder = thisWidget.ZIndex + 3

            widgets.applyTextStyle(PreviewLabel)
            widgets.UIPadding(PreviewLabel, Iris._config.FramePadding)

            PreviewLabel.Parent = PreviewContainer

            local DropdownButton: TextLabel = Instance.new("TextLabel")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Size = UDim2.new(0, frameHeight, 0, frameHeight)
            DropdownButton.BorderSizePixel = 0
            DropdownButton.BackgroundColor3 = Iris._config.ButtonColor
            DropdownButton.BackgroundTransparency = Iris._config.ButtonTransparency
            DropdownButton.Text = ""
            DropdownButton.ZIndex = thisWidget.ZIndex + 4
            DropdownButton.LayoutOrder = thisWidget.ZIndex + 4

            local padding: number = math.round(frameHeight * 0.2)
            local dropdownSize: number = frameHeight - 2 * padding

            local Dropdown: ImageLabel = Instance.new("ImageLabel")
            Dropdown.Name = "Dropdown"
            Dropdown.Size = UDim2.fromOffset(dropdownSize, dropdownSize)
            Dropdown.Position = UDim2.fromOffset(padding, padding)
            Dropdown.BackgroundTransparency = 1
            Dropdown.BorderSizePixel = 0
            Dropdown.ImageColor3 = Iris._config.TextColor
            Dropdown.ImageTransparency = Iris._config.TextTransparency
            Dropdown.ZIndex = thisWidget.ZIndex + 5
            Dropdown.LayoutOrder = thisWidget.ZIndex + 5

            Dropdown.Parent = DropdownButton
            DropdownButton.Parent = PreviewContainer

            -- for some reason ImGui Combo has no highlights for Active, only hovered.
            -- so this deviates from ImGui, but its a good UX change
            widgets.applyInteractionHighlightsWithMultiHighlightee(PreviewContainer, {
                {
                    PreviewLabel,
                    {
                        ButtonColor = Iris._config.FrameBgColor,
                        ButtonTransparency = Iris._config.FrameBgTransparency,
                        ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                        ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                        ButtonActiveColor = Iris._config.FrameBgActiveColor,
                        ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                    },
                },
                {
                    DropdownButton,
                    {
                        ButtonColor = Iris._config.ButtonColor,
                        ButtonTransparency = Iris._config.ButtonTransparency,
                        ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                        ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                        -- Use hovered for active
                        ButtonActiveColor = Iris._config.ButtonHoveredColor,
                        ButtonActiveTransparency = Iris._config.ButtonHoveredColor,
                    },
                },
            })

            PreviewContainer.InputBegan:Connect(function(inputObject)
                if AnyOpenedCombo and OpenedCombo ~= thisWidget then
                    return
                end
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                    thisWidget.state.isOpened:set(not thisWidget.state.isOpened.value)
                end
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, frameHeight)
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 5
            TextLabel.LayoutOrder = thisWidget.ZIndex + 5

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = Combo

            local ChildContainer: ScrollingFrame = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

            -- appear over everything else
            ChildContainer.ZIndex = thisWidget.ZIndex + 6
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 6
            ChildContainer.ClipsDescendants = true

            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Iris._config.PopupRounding > 0 then
            --     widgets.UICorner(ChildContainer, Iris._config.PopupRounding)
            -- end

            widgets.UIStroke(ChildContainer, Iris._config.WindowBorderSize, Iris._config.BorderColor, Iris._config.BorderTransparency)
            widgets.UIPadding(ChildContainer, Vector2.new(2, 2 * Iris._config.FramePadding.Y))

            local ChildContainerUIListLayout: UIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Iris._rootInstance and Iris._rootInstance:WaitForChild("PopupScreenGui") :: GuiObject
            ChildContainer.Parent = RootPopupScreenGui
            thisWidget.ChildContainer = ChildContainer

            return Combo
        end,
        Update = function(thisWidget: Types.Widget)
            local Iris_Combo = thisWidget.Instance :: Frame
            local PreviewContainer = Iris_Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton: TextLabel = PreviewContainer.DropdownButton
            local TextLabel: TextLabel = Iris_Combo.TextLabel

            TextLabel.Text = thisWidget.arguments.Text or "Combo"

            if thisWidget.arguments.NoButton then
                DropdownButton.Visible = false
                PreviewLabel.Size = UDim2.new(1, 0, 0, 0)
            else
                DropdownButton.Visible = true
                local DropdownButtonSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
                PreviewLabel.Size = UDim2.new(1, -DropdownButtonSize, 0, 0)
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
        ChildAdded = function(thisWidget: Types.Widget, thisChild: Types.Widget)
            -- default to largest size if there are widgets other than selectables inside the combo
            if thisChild.type ~= "Selectable" then
                thisWidget.ComboChildrenHeight += 10
            else
                thisWidget.ComboChildrenHeight += 1
            end
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.ChildContainer
        end,
        ChildDiscarded = function(thisWidget: Types.Widget, thisChild: Types.Widget)
            if thisChild.type ~= "Selectable" then
                thisWidget.ComboChildrenHeight -= 10
            else
                thisWidget.ComboChildrenHeight -= 1
            end
        end,
        GenerateState = function(thisWidget: Types.Widget)
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
        UpdateState = function(thisWidget: Types.Widget)
            local Iris_Combo = thisWidget.Instance :: Frame
            local PreviewContainer = Iris_Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton = PreviewContainer.DropdownButton :: TextLabel
            local Dropdown: ImageLabel = DropdownButton.Dropdown
            local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame

            if thisWidget.state.isOpened.value then
                AnyOpenedCombo = true
                OpenedCombo = thisWidget
                ComboOpenedTick = Iris._cycleTick
                thisWidget.lastOpenedTick = Iris._cycleTick + 1

                -- ImGui also does not do this, and the Arrow is always facing down
                Dropdown.Image = widgets.ICONS.RIGHT_POINTING_TRIANGLE
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                if AnyOpenedCombo then
                    AnyOpenedCombo = false
                    OpenedCombo = nil
                    thisWidget.lastClosedTick = Iris._cycleTick + 1
                end
                Dropdown.Image = widgets.ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = false
            end

            local stateIndex: any = thisWidget.state.index.value
            PreviewLabel.Text = if typeof(stateIndex) == "EnumItem" then stateIndex.Name else tostring(stateIndex)
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)
end
