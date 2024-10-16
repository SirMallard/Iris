local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    --stylua: ignore
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
                ["Init"] = function(_thisWidget: Types.Selectable) end,
                ["Get"] = function(thisWidget: Types.Selectable)
                    return thisWidget.lastSelectedTick == Iris._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: Types.Selectable) end,
                ["Get"] = function(thisWidget: Types.Selectable)
                    return thisWidget.lastUnselectedTick == Iris._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: Types.Selectable) end,
                ["Get"] = function(thisWidget: Types.Selectable)
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
        Generate = function(thisWidget: Types.Selectable)
            local Selectable: Frame = Instance.new("Frame")
            Selectable.Name = "Iris_Selectable"
            Selectable.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, Iris._config.TextSize + 2 * Iris._config.FramePadding.Y - Iris._config.ItemSpacing.Y))
            Selectable.BackgroundTransparency = 1
            Selectable.BorderSizePixel = 0
            Selectable.ZIndex = 0
            Selectable.LayoutOrder = thisWidget.ZIndex

            local SelectableButton: TextButton = Instance.new("TextButton")
            SelectableButton.Name = "SelectableButton"
            SelectableButton.Size = UDim2.new(1, 0, 0, Iris._config.TextSize + 2 * Iris._config.FramePadding.Y)
            SelectableButton.Position = UDim2.fromOffset(0, -bit32.rshift(Iris._config.ItemSpacing.Y, 1)) -- divide by 2
            SelectableButton.BackgroundColor3 = Iris._config.HeaderColor
            SelectableButton.ClipsDescendants = true

            widgets.applyFrameStyle(SelectableButton)
            widgets.applyTextStyle(SelectableButton)
            widgets.UISizeConstraint(SelectableButton, Vector2.xAxis)

            thisWidget.ButtonColors = {
                Color = Iris._config.HeaderColor,
                Transparency = 1,
                HoveredColor = Iris._config.HeaderHoveredColor,
                HoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ActiveColor = Iris._config.HeaderActiveColor,
                ActiveTransparency = Iris._config.HeaderActiveTransparency,
            }

            widgets.applyInteractionHighlights("Background", SelectableButton, SelectableButton, thisWidget.ButtonColors)

            widgets.applyButtonClick(SelectableButton, function()
                if thisWidget.arguments.NoClick ~= true then
                    if type(thisWidget.state.index.value) == "boolean" then
                        thisWidget.state.index:set(not thisWidget.state.index.value)
                    else
                        thisWidget.state.index:set(thisWidget.arguments.Index)
                    end
                end
            end)

            SelectableButton.Parent = Selectable

            return Selectable
        end,
        Update = function(thisWidget: Types.Selectable)
            local Selectable = thisWidget.Instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton
            SelectableButton.Text = thisWidget.arguments.Text or "Selectable"
        end,
        Discard = function(thisWidget: Types.Selectable)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Selectable)
            if thisWidget.state.index == nil then
                if thisWidget.arguments.Index ~= nil then
                    error("A shared state index is required for Iris.Selectables() with an Index argument.", 5)
                end
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", false)
            end
        end,
        UpdateState = function(thisWidget: Types.Selectable)
            local Selectable = thisWidget.Instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton
            if thisWidget.state.index.value == (thisWidget.arguments.Index or true) then
                thisWidget.ButtonColors.Transparency = Iris._config.HeaderTransparency
                SelectableButton.BackgroundTransparency = Iris._config.HeaderTransparency
                thisWidget.lastSelectedTick = Iris._cycleTick + 1
            else
                thisWidget.ButtonColors.Transparency = 1
                SelectableButton.BackgroundTransparency = 1
                thisWidget.lastUnselectedTick = Iris._cycleTick + 1
            end
        end,
    } :: Types.WidgetClass)

    local AnyOpenedCombo: boolean = false
    local ComboOpenedTick: number = -1
    local OpenedCombo: Types.Combo? = nil

    local function UpdateChildContainerTransform(thisWidget: Types.Combo)
        local Combo = thisWidget.Instance :: Frame
        local PreviewContainer = Combo.PreviewContainer :: TextButton
        local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame

        ChildContainer.Size = UDim2.fromOffset(PreviewContainer.AbsoluteSize.X, 0)

        local previewPosition: Vector2 = PreviewContainer.AbsolutePosition - widgets.GuiOffset
        local previewSize: Vector2 = PreviewContainer.AbsoluteSize
        local containerSize: Vector2 = ChildContainer.AbsoluteSize
        local borderSize: number = Iris._config.PopupBorderSize
        local screenSize: Vector2 = ChildContainer.Parent.AbsoluteSize

        local x: number = previewPosition.X
        local y: number
        local anchor: Vector2 = Vector2.zero

        if previewPosition.Y + containerSize.Y > screenSize.Y then
            y = previewPosition.Y - borderSize
            anchor = Vector2.yAxis
        else
            y = previewPosition.Y + previewSize.Y + borderSize
        end
        ChildContainer.AnchorPoint = anchor
        ChildContainer.Position = UDim2.fromOffset(x, y)
    end

    widgets.registerEvent("InputBegan", function(inputObject: InputObject)
        if not Iris._started then
            return
        end
        if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 and inputObject.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if AnyOpenedCombo == false or not OpenedCombo then
            return
        end
        if ComboOpenedTick == Iris._cycleTick then
            return
        end

        local MouseLocation: Vector2 = widgets.getMouseLocation()
        local Combo = OpenedCombo.Instance :: Frame
        local PreviewContainer: TextButton = Combo.PreviewContainer
        local ChildContainer = OpenedCombo.ChildContainer
        local rectMin: Vector2 = PreviewContainer.AbsolutePosition - widgets.GuiOffset
        local rectMax: Vector2 = PreviewContainer.AbsolutePosition - widgets.GuiOffset + PreviewContainer.AbsoluteSize
        if widgets.isPosInsideRect(MouseLocation, rectMin, rectMax) then
            return
        end

        rectMin = ChildContainer.AbsolutePosition - widgets.GuiOffset
        rectMax = ChildContainer.AbsolutePosition - widgets.GuiOffset + ChildContainer.AbsoluteSize
        if widgets.isPosInsideRect(MouseLocation, rectMin, rectMax) then
            return
        end

        OpenedCombo.state.isOpened:set(false)
    end)

    --stylua: ignore
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
                ["Init"] = function(_thisWidget: Types.Combo) end,
                ["Get"] = function(thisWidget: Types.Combo)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Types.Combo) end,
                ["Get"] = function(thisWidget: Types.Combo)
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
        Generate = function(thisWidget: Types.Combo)
            local frameHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

            local Combo: Frame = Instance.new("Frame")
            Combo.Name = "Iris_Combo"
            Combo.Size = UDim2.fromScale(1, 0)
            Combo.AutomaticSize = Enum.AutomaticSize.Y
            Combo.BackgroundTransparency = 1
            Combo.BorderSizePixel = 0
            Combo.LayoutOrder = thisWidget.ZIndex

            local UIListLayout: UIListLayout = widgets.UIListLayout(Combo, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local PreviewContainer: TextButton = Instance.new("TextButton")
            PreviewContainer.Name = "PreviewContainer"
            PreviewContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            PreviewContainer.BackgroundTransparency = 1
            PreviewContainer.Text = ""
            PreviewContainer.ZIndex = thisWidget.ZIndex + 2
            PreviewContainer.AutoButtonColor = false

            widgets.applyFrameStyle(PreviewContainer, true)
            widgets.UIListLayout(PreviewContainer, Enum.FillDirection.Horizontal, UDim.new(0, 0))
            widgets.UISizeConstraint(PreviewContainer, Vector2.new(frameHeight + 1))

            PreviewContainer.Parent = Combo

            local PreviewLabel: TextLabel = Instance.new("TextLabel")
            PreviewLabel.Name = "PreviewLabel"
            PreviewLabel.Size = UDim2.new(UDim.new(1, 0), Iris._config.ContentHeight)
            PreviewLabel.AutomaticSize = Enum.AutomaticSize.Y
            PreviewLabel.BackgroundColor3 = Iris._config.FrameBgColor
            PreviewLabel.BackgroundTransparency = Iris._config.FrameBgTransparency
            PreviewLabel.BorderSizePixel = 0
            PreviewLabel.ClipsDescendants = true

            widgets.applyTextStyle(PreviewLabel)
            widgets.UIPadding(PreviewLabel, Iris._config.FramePadding)

            PreviewLabel.Parent = PreviewContainer

            local DropdownButton: TextLabel = Instance.new("TextLabel")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Size = UDim2.new(0, frameHeight, Iris._config.ContentHeight.Scale, math.max(Iris._config.ContentHeight.Offset, frameHeight))
            DropdownButton.BorderSizePixel = 0
            DropdownButton.BackgroundColor3 = Iris._config.ButtonColor
            DropdownButton.BackgroundTransparency = Iris._config.ButtonTransparency
            DropdownButton.Text = ""

            local padding: number = math.round(frameHeight * 0.2)
            local dropdownSize: number = frameHeight - 2 * padding

            local Dropdown: ImageLabel = Instance.new("ImageLabel")
            Dropdown.Name = "Dropdown"
            Dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
            Dropdown.Size = UDim2.fromOffset(dropdownSize, dropdownSize)
            Dropdown.Position = UDim2.fromScale(0.5, 0.5)
            Dropdown.BackgroundTransparency = 1
            Dropdown.BorderSizePixel = 0
            Dropdown.ImageColor3 = Iris._config.TextColor
            Dropdown.ImageTransparency = Iris._config.TextTransparency

            Dropdown.Parent = DropdownButton

            DropdownButton.Parent = PreviewContainer

            -- for some reason ImGui Combo has no highlights for Active, only hovered.
            -- so this deviates from ImGui, but its a good UX change
            widgets.applyInteractionHighlightsWithMultiHighlightee("Background", PreviewContainer, {
                {
                    PreviewLabel,
                    {
                        Color = Iris._config.FrameBgColor,
                        Transparency = Iris._config.FrameBgTransparency,
                        HoveredColor = Iris._config.FrameBgHoveredColor,
                        HoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                        ActiveColor = Iris._config.FrameBgActiveColor,
                        ActiveTransparency = Iris._config.FrameBgActiveTransparency,
                    },
                },
                {
                    DropdownButton,
                    {
                        Color = Iris._config.ButtonColor,
                        Transparency = Iris._config.ButtonTransparency,
                        HoveredColor = Iris._config.ButtonHoveredColor,
                        HoveredTransparency = Iris._config.ButtonHoveredTransparency,
                        -- Use hovered for active
                        ActiveColor = Iris._config.ButtonHoveredColor,
                        ActiveTransparency = Iris._config.ButtonHoveredTransparency,
                    },
                },
            })

            widgets.applyButtonClick(PreviewContainer, function()
                if AnyOpenedCombo and OpenedCombo ~= thisWidget then
                    return
                end
                thisWidget.state.isOpened:set(not thisWidget.state.isOpened.value)
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, frameHeight)
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = Combo

            local ChildContainer: ScrollingFrame = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ComboContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.BackgroundColor3 = Iris._config.PopupBgColor
            ChildContainer.BackgroundTransparency = Iris._config.PopupBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

            -- appear over everything else
            ChildContainer.ClipsDescendants = true

            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Iris._config.PopupRounding > 0 then
            --     widgets.UICorner(ChildContainer, Iris._config.PopupRounding)
            -- end

            widgets.UIStroke(ChildContainer, Iris._config.WindowBorderSize, Iris._config.BorderColor, Iris._config.BorderTransparency)
            widgets.UIPadding(ChildContainer, Vector2.new(2, Iris._config.WindowPadding.Y))
            widgets.UISizeConstraint(ChildContainer, Vector2.new(100))

            local ChildContainerUIListLayout: UIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Iris._rootInstance and Iris._rootInstance:WaitForChild("PopupScreenGui") :: GuiObject
            ChildContainer.Parent = RootPopupScreenGui

            thisWidget.ChildContainer = ChildContainer
            return Combo
        end,
        Update = function(thisWidget: Types.Combo)
            local Iris_Combo = thisWidget.Instance :: Frame
            local PreviewContainer = Iris_Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton: TextLabel = PreviewContainer.DropdownButton
            local TextLabel: TextLabel = Iris_Combo.TextLabel

            TextLabel.Text = thisWidget.arguments.Text or "Combo"

            if thisWidget.arguments.NoButton then
                DropdownButton.Visible = false
                PreviewLabel.Size = UDim2.new(UDim.new(1, 0), PreviewLabel.Size.Height)
            else
                DropdownButton.Visible = true
                local DropdownButtonSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
                PreviewLabel.Size = UDim2.new(UDim.new(1, -DropdownButtonSize), PreviewLabel.Size.Height)
            end

            if thisWidget.arguments.NoPreview then
                PreviewLabel.Visible = false
                PreviewContainer.Size = UDim2.new(0, 0, 0, 0)
                PreviewContainer.AutomaticSize = Enum.AutomaticSize.XY
            else
                PreviewLabel.Visible = true
                PreviewContainer.Size = UDim2.new(Iris._config.ContentWidth, Iris._config.ContentHeight)
                PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            end
        end,
        ChildAdded = function(thisWidget: Types.Combo, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.ChildContainer
        end,
        GenerateState = function(thisWidget: Types.Combo)
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
        UpdateState = function(thisWidget: Types.Combo)
            local Combo = thisWidget.Instance :: Frame
            local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame
            local PreviewContainer = Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton = PreviewContainer.DropdownButton :: TextLabel
            local Dropdown: ImageLabel = DropdownButton.Dropdown

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
        Discard = function(thisWidget: Types.Combo)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)
end
