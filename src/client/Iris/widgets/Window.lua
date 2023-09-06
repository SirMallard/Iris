local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local function relocateTooltips()
        if Iris._rootInstance == nil then
            return
        end
        local PopupScreenGui = Iris._rootInstance:FindFirstChild("PopupScreenGui")
        local TooltipContainer = PopupScreenGui.TooltipContainer
        local mouseLocation = widgets.getMouseLocation()
        local newPosition = widgets.findBestWindowPosForPopup(mouseLocation, TooltipContainer.AbsoluteSize, Iris._config.DisplaySafeAreaPadding, PopupScreenGui.AbsoluteSize)
        TooltipContainer.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
    end

    widgets.UserInputService.InputChanged:Connect(relocateTooltips)

    Iris.WidgetConstructor("Tooltip", {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
        },
        Events = {},
        Generate = function(thisWidget: Types.Widget)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent

            local Tooltip: Frame = Instance.new("Frame")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            Tooltip.AutomaticSize = Enum.AutomaticSize.Y
            Tooltip.BorderSizePixel = 0
            Tooltip.BackgroundTransparency = 1
            Tooltip.ZIndex = thisWidget.ZIndex + 1
            Tooltip.LayoutOrder = thisWidget.ZIndex + 1

            local TooltipText: TextLabel = Instance.new("TextLabel")
            TooltipText.Name = "TooltipText"
            TooltipText.Size = UDim2.fromOffset(0, 0)
            TooltipText.AutomaticSize = Enum.AutomaticSize.XY
            TooltipText.BackgroundColor3 = Iris._config.WindowBgColor
            TooltipText.BackgroundTransparency = Iris._config.WindowBgTransparency
            TooltipText.BorderSizePixel = Iris._config.PopupBorderSize
            TooltipText.TextWrapped = true
            TooltipText.ZIndex = thisWidget.ZIndex + 1
            TooltipText.LayoutOrder = thisWidget.ZIndex + 1

            widgets.applyTextStyle(TooltipText)
            widgets.UIStroke(TooltipText, Iris._config.WindowBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
            widgets.UIPadding(TooltipText, Iris._config.WindowPadding)
            if Iris._config.PopupRounding > 0 then
                widgets.UICorner(TooltipText, Iris._config.PopupRounding)
            end

            TooltipText.Parent = Tooltip

            return Tooltip
        end,
        Update = function(thisWidget: Types.Widget)
            local Tooltip = thisWidget.Instance :: Frame
            local TooltipText: TextLabel = Tooltip.TooltipText
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            TooltipText.Text = thisWidget.arguments.Text
            relocateTooltips()
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    local windowDisplayOrder: number = 0 -- incremental count which is used for determining focused windows ZIndex
    local dragWindow: Types.Widget? -- window being dragged, may be nil
    local isDragging: boolean = false
    local moveDeltaCursorPosition: Vector2 -- cursor offset from drag origin (top left of window)

    local resizeWindow: Types.Widget? -- window being resized, may be nil
    local isResizing = false
    local isInsideResize = false -- is cursor inside of the focused window resize outer padding
    local isInsideWindow = false -- is cursor inside of the focused window
    local resizeFromTopBottom: Enum.TopBottom = Enum.TopBottom.Top
    local resizeFromLeftRight: Enum.LeftRight = Enum.LeftRight.Left

    local lastCursorPosition: Vector2

    local focusedWindow: Types.Widget? -- window with focus, may be nil
    local anyFocusedWindow: boolean = false -- is there any focused window?

    local windowWidgets: { [Types.ID]: Types.Widget } = {} -- array of widget objects of type window

    local function quickSwapWindows()
        -- ctrl + tab swapping functionality
        if Iris._config.UseScreenGUIs == false then
            return
        end

        local lowest: number = 0xFFFF
        local lowestWidget: Types.Widget

        for _, widget: Types.Widget in windowWidgets do
            if widget.state.isOpened.value and not widget.arguments.NoNav then
                if widget.Instance:IsA("ScreenGui") then
                    local value: number = widget.Instance.DisplayOrder
                    if value < lowest then
                        lowest = value
                        lowestWidget = widget
                    end
                end
            end
        end

        if lowestWidget.state.isUncollapsed.value == false then
            lowestWidget.state.isUncollapsed:set(true)
        end
        Iris.SetFocusedWindow(lowestWidget)
    end

    local function fitSizeToWindowBounds(thisWidget: Types.Widget, intentedSize: Vector2): Vector2
        local windowSize: Vector2 = Vector2.new(thisWidget.state.position.value.X, thisWidget.state.position.value.Y)
        local minWindowSize: number = (Iris._config.TextSize + Iris._config.FramePadding.Y * 2) * 2
        local usableSize: Vector2 = widgets.getScreenSizeForWindow(thisWidget)
        local safeAreaPadding: Vector2 = Vector2.new(Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.X, Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.Y)

        local maxWindowSize: Vector2 = (usableSize - windowSize - safeAreaPadding)
        return Vector2.new(math.clamp(intentedSize.X, minWindowSize, math.max(maxWindowSize.X, minWindowSize)), math.clamp(intentedSize.Y, minWindowSize, math.max(maxWindowSize.Y, minWindowSize)))
    end

    local function fitPositionToWindowBounds(thisWidget: Types.Widget, intendedPosition: Vector2): Vector2
        local thisWidgetInstance = thisWidget.Instance
        local usableSize: Vector2 = widgets.getScreenSizeForWindow(thisWidget)
        local safeAreaPadding: Vector2 = Vector2.new(Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.X, Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.Y)

        return Vector2.new(
            math.clamp(intendedPosition.X, safeAreaPadding.X, math.max(safeAreaPadding.X, usableSize.X - thisWidgetInstance.WindowButton.AbsoluteSize.X - safeAreaPadding.X)),
            math.clamp(intendedPosition.Y, safeAreaPadding.Y, math.max(safeAreaPadding.Y, usableSize.Y - thisWidgetInstance.WindowButton.AbsoluteSize.Y - safeAreaPadding.Y))
        )
    end

    Iris.SetFocusedWindow = function(thisWidget: Types.Widget?)
        if focusedWindow == thisWidget then
            return
        end

        if anyFocusedWindow and focusedWindow ~= nil then
            if windowWidgets[focusedWindow.ID] then
                local Window = focusedWindow.Instance :: Frame
                local WindowButton = Window.WindowButton :: TextButton
                local TitleBar: Frame = WindowButton.TitleBar
                -- update appearance to unfocus
                if focusedWindow.state.isUncollapsed.value then
                    TitleBar.BackgroundColor3 = Iris._config.TitleBgColor
                    TitleBar.BackgroundTransparency = Iris._config.TitleBgTransparency
                else
                    TitleBar.BackgroundColor3 = Iris._config.TitleBgCollapsedColor
                    TitleBar.BackgroundTransparency = Iris._config.TitleBgCollapsedTransparency
                end
                WindowButton.UIStroke.Color = Iris._config.BorderColor
            end

            anyFocusedWindow = false
            focusedWindow = nil
        end

        if thisWidget ~= nil then
            -- update appearance to focus
            anyFocusedWindow = true
            focusedWindow = thisWidget
            local Window = thisWidget.Instance :: Frame
            local WindowButton = Window.WindowButton :: TextButton
            local TitleBar: Frame = WindowButton.TitleBar

            TitleBar.BackgroundColor3 = Iris._config.TitleBgActiveColor
            TitleBar.BackgroundTransparency = Iris._config.TitleBgActiveTransparency
            WindowButton.UIStroke.Color = Iris._config.BorderActiveColor

            windowDisplayOrder += 1
            if thisWidget.usesScreenGUI then
                Window.DisplayOrder = windowDisplayOrder + Iris._config.DisplayOrderOffset
            end

            if thisWidget.state.isUncollapsed.value == false then
                thisWidget.state.isUncollapsed:set(true)
            end

            local firstSelectedObject: GuiObject? = widgets.GuiService.SelectedObject
            if firstSelectedObject then
                if TitleBar.Visible then
                    widgets.GuiService:Select(TitleBar)
                else
                    widgets.GuiService:Select(Window.ChildContainer)
                end
            end
        end
    end

    widgets.UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 then
            Iris.SetFocusedWindow(nil)
        end

        if input.KeyCode == Enum.KeyCode.Tab and (widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            quickSwapWindows()
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isInsideResize and not isInsideWindow and anyFocusedWindow and focusedWindow then
                local midWindow: Vector2 = focusedWindow.state.position.value + (focusedWindow.state.size.value / 2)
                local cursorPosition: Vector2 = widgets.getMouseLocation() - midWindow

                -- check which axis its closest to, then check which side is closest with math.sign
                if math.abs(cursorPosition.X) * focusedWindow.state.size.value.Y >= math.abs(cursorPosition.Y) * focusedWindow.state.size.value.X then
                    resizeFromTopBottom = Enum.TopBottom.Center
                    resizeFromLeftRight = if math.sign(cursorPosition.X) == -1 then Enum.LeftRight.Left else Enum.LeftRight.Right
                else
                    resizeFromLeftRight = Enum.LeftRight.Center
                    resizeFromTopBottom = if math.sign(cursorPosition.Y) == -1 then Enum.TopBottom.Top else Enum.TopBottom.Bottom
                end
                isResizing = true
                resizeWindow = focusedWindow
            end
        end
    end)

    widgets.UserInputService.TouchTapInWorld:Connect(function(_, gameProcessedEvent: boolean)
        if not gameProcessedEvent then
            Iris.SetFocusedWindow(nil)
        end
    end)

    widgets.UserInputService.InputChanged:Connect(function(input: InputObject)
        if isDragging and dragWindow then
            local mouseLocation: Vector2
            if input.UserInputType == Enum.UserInputType.Touch then
                local location: Vector3 = input.Position
                mouseLocation = Vector2.new(location.X, location.Y)
            else
                mouseLocation = widgets.getMouseLocation()
            end
            local Window = dragWindow.Instance :: Frame
            local dragInstance: TextButton = Window.WindowButton
            local intendedPosition: Vector2 = mouseLocation - moveDeltaCursorPosition
            local newPos: Vector2 = fitPositionToWindowBounds(dragWindow, intendedPosition)

            -- state shouldnt be used like this, but calling :set would run the entire UpdateState function for the window, which is slow.
            dragInstance.Position = UDim2.fromOffset(newPos.X, newPos.Y)
            dragWindow.state.position.value = newPos
        end
        if isResizing and resizeWindow and resizeWindow.arguments.NoResize ~= true then
            local Window = resizeWindow.Instance :: Frame
            local resizeInstance: TextButton = Window.WindowButton
            local windowPosition: Vector2 = Vector2.new(resizeInstance.Position.X.Offset, resizeInstance.Position.Y.Offset)
            local windowSize: Vector2 = Vector2.new(resizeInstance.Size.X.Offset, resizeInstance.Size.Y.Offset)

            local mouseDelta: Vector2 | Vector3
            if input.UserInputType == Enum.UserInputType.Touch then
                mouseDelta = input.Delta
            else
                mouseDelta = widgets.getMouseLocation() - lastCursorPosition
            end

            local intendedPosition: Vector2 = windowPosition + Vector2.new(if resizeFromLeftRight == Enum.LeftRight.Left then mouseDelta.X else 0, if resizeFromTopBottom == Enum.TopBottom.Top then mouseDelta.Y else 0)

            local intendedSize: Vector2 = windowSize
                + Vector2.new(
                    if resizeFromLeftRight == Enum.LeftRight.Left then -mouseDelta.X elseif resizeFromLeftRight == Enum.LeftRight.Right then mouseDelta.X else 0,
                    if resizeFromTopBottom == Enum.TopBottom.Top then -mouseDelta.Y elseif resizeFromTopBottom == Enum.TopBottom.Bottom then mouseDelta.Y else 0
                )

            local newSize: Vector2 = fitSizeToWindowBounds(resizeWindow, intendedSize)
            local newPosition: Vector2 = fitPositionToWindowBounds(resizeWindow, intendedPosition)

            resizeInstance.Size = UDim2.fromOffset(newSize.X, newSize.Y)
            resizeWindow.state.size.value = newSize
            resizeInstance.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
            resizeWindow.state.position.value = newPosition
        end

        lastCursorPosition = widgets.getMouseLocation()
    end)

    widgets.UserInputService.InputEnded:Connect(function(input, _)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging and dragWindow then
            local Window = dragWindow.Instance :: Frame
            local dragInstance: TextButton = Window.WindowButton
            isDragging = false
            dragWindow.state.position:set(Vector2.new(dragInstance.Position.X.Offset, dragInstance.Position.Y.Offset))
        end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isResizing and resizeWindow then
            local Window = resizeWindow.Instance :: Frame
            isResizing = false
            resizeWindow.state.size:set(Window.WindowButton.AbsoluteSize)
        end

        if input.KeyCode == Enum.KeyCode.ButtonX then
            quickSwapWindows()
        end
    end)

    Iris.WidgetConstructor("Window", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Title"] = 1,
            ["NoTitleBar"] = 2,
            ["NoBackground"] = 3,
            ["NoCollapse"] = 4,
            ["NoClose"] = 5,
            ["NoMove"] = 6,
            ["NoScrollbar"] = 7,
            ["NoResize"] = 8,
            ["NoNav"] = 9,
            ["NoMenu"] = 10,
        },
        Events = {
            ["closed"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end,
            },
            ["opened"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["collapsed"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastCollapsedTick == Iris._cycleTick
                end,
            },
            ["uncollapsed"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastUncollapsedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                local Window = thisWidget.Instance :: Frame
                return Window.WindowButton
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent

            thisWidget.usesScreenGUI = Iris._config.UseScreenGUIs
            windowWidgets[thisWidget.ID] = thisWidget

            local Window
            if thisWidget.usesScreenGUI then
                Window = Instance.new("ScreenGui")
                Window.ResetOnSpawn = false
                Window.DisplayOrder = Iris._config.DisplayOrderOffset
                Window.IgnoreGuiInset = Iris._config.IgnoreGuiInset
            else
                Window = Instance.new("Folder")
            end
            Window.Name = "Iris_Window"

            local WindowButton: TextButton = Instance.new("TextButton")
            WindowButton.Name = "WindowButton"
            WindowButton.Size = UDim2.fromOffset(0, 0)
            WindowButton.BackgroundTransparency = 1
            WindowButton.BorderSizePixel = 0
            WindowButton.Text = ""
            WindowButton.ClipsDescendants = false
            WindowButton.AutoButtonColor = false
            WindowButton.Selectable = false
            WindowButton.SelectionImageObject = Iris.SelectionImageObject
            WindowButton.ZIndex = thisWidget.ZIndex + 1
            WindowButton.LayoutOrder = thisWidget.ZIndex + 1

            WindowButton.SelectionGroup = true
            WindowButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

            widgets.UIStroke(WindowButton, Iris._config.WindowBorderSize, Iris._config.BorderColor, Iris._config.BorderTransparency)

            WindowButton.Parent = Window

            WindowButton.InputBegan:Connect(function(input: InputObject)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if thisWidget.state.isUncollapsed.value then
                    Iris.SetFocusedWindow(thisWidget)
                end
                if not thisWidget.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragWindow = thisWidget
                    isDragging = true
                    moveDeltaCursorPosition = widgets.getMouseLocation() - thisWidget.state.position.value
                end
            end)

            local ChildContainer: ScrollingFrame = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.Size = UDim2.fromScale(1, 1)
            ChildContainer.Position = UDim2.fromOffset(0, 0)
            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0, 1)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

            ChildContainer.ZIndex = thisWidget.ZIndex + 3
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 3
            ChildContainer.ClipsDescendants = true

            widgets.UIPadding(ChildContainer, Iris._config.WindowPadding)

            ChildContainer.Parent = WindowButton

            ChildContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                -- "wrong" use of state here, for optimization
                thisWidget.state.scrollDistance.value = ChildContainer.CanvasPosition.Y
            end)

            ChildContainer.InputBegan:Connect(function(input: InputObject)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if thisWidget.state.isUncollapsed.value then
                    Iris.SetFocusedWindow(thisWidget)
                end
            end)

            local TerminatingFrame: Frame = Instance.new("Frame")
            TerminatingFrame.Name = "TerminatingFrame"
            TerminatingFrame.Size = UDim2.fromOffset(0, Iris._config.WindowPadding.Y + Iris._config.FramePadding.Y)
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0

            local ChildContainerUIListLayout: UIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            TerminatingFrame.Parent = ChildContainer

            local TitleBar: Frame = Instance.new("Frame")
            TitleBar.Name = "TitleBar"
            TitleBar.Size = UDim2.fromScale(1, 0)
            TitleBar.AutomaticSize = Enum.AutomaticSize.Y
            TitleBar.BorderSizePixel = 0
            TitleBar.ZIndex = thisWidget.ZIndex + 1
            TitleBar.LayoutOrder = thisWidget.ZIndex + 1
            TitleBar.ClipsDescendants = true

            TitleBar.Parent = WindowButton

            TitleBar.InputBegan:Connect(function(input: InputObject)
                if input.UserInputType == Enum.UserInputType.Touch then
                    if not thisWidget.arguments.NoMove then
                        dragWindow = thisWidget
                        isDragging = true
                        local location: Vector3 = input.Position
                        moveDeltaCursorPosition = Vector2.new(location.X, location.Y) - thisWidget.state.position.value
                    end
                end
            end)

            local TitleButtonSize: number = Iris._config.TextSize + ((Iris._config.FramePadding.Y - 1) * 2)

            local CollapseButton: TextButton = Instance.new("TextButton")
            CollapseButton.Name = "CollapseButton"
            CollapseButton.AnchorPoint = Vector2.new(0, 0.5)
            CollapseButton.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CollapseButton.Position = UDim2.new(0, Iris._config.FramePadding.X + 1, 0.5, 0)
            CollapseButton.AutomaticSize = Enum.AutomaticSize.None
            CollapseButton.BackgroundTransparency = 1
            CollapseButton.BorderSizePixel = 0
            CollapseButton.AutoButtonColor = false
            CollapseButton.Text = ""
            CollapseButton.ZIndex = thisWidget.ZIndex + 4

            widgets.UICorner(CollapseButton)

            CollapseButton.Parent = TitleBar

            CollapseButton.MouseButton1Click:Connect(function()
                thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
            end)

            widgets.applyInteractionHighlights(CollapseButton, CollapseButton, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            local CollapseArrow: ImageLabel = Instance.new("ImageLabel")
            CollapseArrow.Name = "Arrow"
            CollapseArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            CollapseArrow.Size = UDim2.fromOffset(math.floor(0.7 * TitleButtonSize), math.floor(0.7 * TitleButtonSize))
            CollapseArrow.Position = UDim2.fromScale(0.5, 0.5)
            CollapseArrow.BackgroundTransparency = 1
            CollapseArrow.BorderSizePixel = 0
            CollapseArrow.Image = widgets.ICONS.MULTIPLICATION_SIGN
            CollapseArrow.ImageColor3 = Iris._config.TextColor
            CollapseArrow.ImageTransparency = Iris._config.TextTransparency
            CollapseArrow.ZIndex = thisWidget.ZIndex + 5
            CollapseArrow.Parent = CollapseButton

            local CloseButton: TextButton = Instance.new("TextButton")
            CloseButton.Name = "CloseButton"
            CloseButton.AnchorPoint = Vector2.new(1, 0.5)
            CloseButton.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CloseButton.Position = UDim2.new(1, -(Iris._config.FramePadding.X + 1), 0.5, 0)
            CloseButton.AutomaticSize = Enum.AutomaticSize.None
            CloseButton.BackgroundTransparency = 1
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = ""

            CloseButton.ZIndex = thisWidget.ZIndex + 4
            CloseButton.AutoButtonColor = false

            widgets.UICorner(CloseButton)

            CloseButton.MouseButton1Click:Connect(function()
                thisWidget.state.isOpened:set(false)
            end)

            widgets.applyInteractionHighlights(CloseButton, CloseButton, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            CloseButton.Parent = TitleBar

            local CloseIcon: ImageLabel = Instance.new("ImageLabel")
            CloseIcon.Name = "Icon"
            CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            CloseIcon.Size = UDim2.fromOffset(math.floor(0.7 * TitleButtonSize), math.floor(0.7 * TitleButtonSize))
            CloseIcon.Position = UDim2.fromScale(0.5, 0.5)
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.BorderSizePixel = 0
            CloseIcon.Image = widgets.ICONS.MULTIPLICATION_SIGN
            CloseIcon.ImageColor3 = Iris._config.TextColor
            CloseIcon.ImageTransparency = Iris._config.TextTransparency
            CloseIcon.ZIndex = thisWidget.ZIndex + 5
            CloseIcon.Parent = CloseButton

            -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.

            local titleAlign: number
            if Iris._config.WindowTitleAlign == Enum.LeftRight.Left then
                titleAlign = 0
            elseif Iris._config.WindowTitleAlign == Enum.LeftRight.Center then
                titleAlign = 0.5
            else
                titleAlign = 1
            end

            local Title: TextLabel = Instance.new("TextLabel")
            Title.Name = "Title"
            Title.AnchorPoint = Vector2.new(titleAlign, 0)
            Title.Position = UDim2.fromScale(titleAlign, 0)
            Title.AutomaticSize = Enum.AutomaticSize.XY
            Title.BorderSizePixel = 0
            Title.BackgroundTransparency = 1
            Title.ZIndex = thisWidget.ZIndex + 3

            widgets.applyTextStyle(Title)
            widgets.UIPadding(Title, Iris._config.FramePadding)

            Title.Parent = TitleBar

            local ResizeButtonSize: number = Iris._config.TextSize + Iris._config.FramePadding.X

            local ResizeGrip = Instance.new("TextButton")
            ResizeGrip.Name = "ResizeGrip"
            ResizeGrip.AnchorPoint = Vector2.new(1, 1)
            ResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            ResizeGrip.Position = UDim2.fromScale(1, 1)
            ResizeGrip.AutoButtonColor = false
            ResizeGrip.BorderSizePixel = 0
            ResizeGrip.BackgroundTransparency = 1
            ResizeGrip.Text = widgets.ICONS.BOTTOM_RIGHT_CORNER
            ResizeGrip.TextSize = ResizeButtonSize
            ResizeGrip.TextColor3 = Iris._config.ButtonColor
            ResizeGrip.TextTransparency = Iris._config.ButtonTransparency
            ResizeGrip.LineHeight = 1.10 -- fix mild rendering issue
            ResizeGrip.Selectable = false
            ResizeGrip.ZIndex = thisWidget.ZIndex + 3
            ResizeGrip.Parent = WindowButton

            widgets.applyTextInteractionHighlights(ResizeGrip, ResizeGrip, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = Iris._config.ButtonTransparency,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            ResizeGrip.MouseButton1Down:Connect(function()
                if not anyFocusedWindow or not (focusedWindow == thisWidget) then
                    Iris.SetFocusedWindow(thisWidget)
                    -- mitigating wrong focus when clicking on buttons inside of a window without clicking the window itself
                end
                isResizing = true
                resizeFromTopBottom = Enum.TopBottom.Bottom
                resizeFromLeftRight = Enum.LeftRight.Right
                resizeWindow = thisWidget
            end)

            local ResizeBorder: TextButton = Instance.new("TextButton")
            ResizeBorder.Name = "ResizeBorder"
            ResizeBorder.Size = UDim2.new(1, Iris._config.WindowResizePadding.X * 2, 1, Iris._config.WindowResizePadding.Y * 2)
            ResizeBorder.Position = UDim2.fromOffset(-Iris._config.WindowResizePadding.X, -Iris._config.WindowResizePadding.Y)
            ResizeBorder.BackgroundTransparency = 1
            ResizeBorder.BorderSizePixel = 0
            ResizeBorder.Text = ""
            ResizeBorder.AutoButtonColor = false
            ResizeBorder.Active = true
            ResizeBorder.Selectable = false
            ResizeBorder.ZIndex = thisWidget.ZIndex
            ResizeBorder.LayoutOrder = thisWidget.ZIndex
            ResizeBorder.ClipsDescendants = false
            ResizeBorder.Parent = WindowButton

            ResizeBorder.MouseEnter:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideResize = true
                end
            end)
            ResizeBorder.MouseLeave:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideResize = false
                end
            end)

            WindowButton.MouseEnter:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideWindow = true
                end
            end)
            WindowButton.MouseLeave:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideWindow = false
                end
            end)

            return Window
        end,
        Update = function(thisWidget: Types.Widget)
            local WindowGui = thisWidget.Instance :: GuiObject
            local WindowButton = WindowGui.WindowButton :: TextButton
            local TitleBar = WindowButton.TitleBar :: Frame
            local Title: TextLabel = TitleBar.Title
            local MenuBar: Frame? = WindowButton:FindFirstChild("MenuBar")
            local ChildContainer: ScrollingFrame = WindowButton.ChildContainer
            local ResizeGrip: TextButton = WindowButton.ResizeGrip

            local containerHeight: number = 0
            local menuHeight: number = 0

            if thisWidget.arguments.NoResize ~= true then
                ResizeGrip.Visible = true
            else
                ResizeGrip.Visible = false
            end
            if thisWidget.arguments.NoScrollbar then
                ChildContainer.ScrollBarThickness = 0
            else
                ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            end
            if thisWidget.arguments.NoTitleBar then
                TitleBar.Visible = false
            else
                TitleBar.Visible = true
                --local titlebarSize: number = widgets.calculateTextSize(thisWidget.arguments.Title or "").Y + 2 * Iris._config.FramePadding.Y
                local titlebarSize: number = TitleBar.AbsoluteSize.Y
                containerHeight += titlebarSize
                menuHeight += titlebarSize
            end
            if MenuBar then
                if thisWidget.arguments.NoMenu then
                    MenuBar.Visible = false
                else
                    MenuBar.Visible = true
                    containerHeight += MenuBar.AbsoluteSize.Y
                end
                -- we move the menu bar to the correct position.
                MenuBar.Position = UDim2.fromOffset(0, menuHeight)
            end
            if thisWidget.arguments.NoBackground then
                ChildContainer.BackgroundTransparency = 1
            else
                ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            end

            -- TitleBar buttons
            local TitleButtonPaddingSize = Iris._config.FramePadding.X + Iris._config.TextSize + Iris._config.FramePadding.X * 2
            if thisWidget.arguments.NoCollapse then
                TitleBar.CollapseButton.Visible = false
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
            else
                TitleBar.CollapseButton.Visible = true
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, TitleButtonPaddingSize)
            end
            if thisWidget.arguments.NoClose then
                TitleBar.CloseButton.Visible = false
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, Iris._config.FramePadding.X)
            else
                TitleBar.CloseButton.Visible = true
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, TitleButtonPaddingSize)
            end

            ChildContainer.Size = UDim2.new(1, 0, 1, -containerHeight)
            ChildContainer.CanvasSize = UDim2.new(0, 0, 1, -containerHeight)
            ChildContainer.Position = UDim2.fromOffset(0, containerHeight)

            Title.Text = thisWidget.arguments.Title or ""
        end,
        Discard = function(thisWidget: Types.Widget)
            if focusedWindow == thisWidget then
                focusedWindow = nil
                anyFocusedWindow = false
            end
            if dragWindow == thisWidget then
                dragWindow = nil
                isDragging = false
            end
            if resizeWindow == thisWidget then
                resizeWindow = nil
                isResizing = false
            end
            windowWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        ChildAdded = function(thisWidget: Types.Widget)
            local Window = thisWidget.Instance :: Frame
            local WindowButton = Window.WindowButton :: TextButton
            return WindowButton.ChildContainer
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local stateSize: Vector2 = thisWidget.state.size.value
            local statePosition: Vector2 = thisWidget.state.position.value
            local stateIsUncollapsed: boolean = thisWidget.state.isUncollapsed.value
            local stateIsOpened: boolean = thisWidget.state.isOpened.value
            local stateScrollDistance: number = thisWidget.state.scrollDistance.value

            local Window = thisWidget.Instance :: Frame
            local WindowButton = Window.WindowButton :: TextButton
            local TitleBar = WindowButton.TitleBar :: Frame
            local ChildContainer: ScrollingFrame = WindowButton.ChildContainer
            local ResizeGrip: TextButton = WindowButton.ResizeGrip

            WindowButton.Size = UDim2.fromOffset(stateSize.X, stateSize.Y)
            WindowButton.Position = UDim2.fromOffset(statePosition.X, statePosition.Y)

            if stateIsOpened then
                if thisWidget.usesScreenGUI then
                    Window.Enabled = true
                    WindowButton.Visible = true
                else
                    WindowButton.Visible = true
                end
                thisWidget.lastOpenedTick = Iris._cycleTick + 1
            else
                if thisWidget.usesScreenGUI then
                    Window.Enabled = false
                    WindowButton.Visible = false
                else
                    WindowButton.Visible = false
                end
                thisWidget.lastClosedTick = Iris._cycleTick + 1
            end

            if stateIsUncollapsed then
                TitleBar.CollapseButton.Arrow.Image = widgets.ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = true
                if thisWidget.arguments.NoResize ~= true then
                    ResizeGrip.Visible = true
                end
                WindowButton.AutomaticSize = Enum.AutomaticSize.None
                thisWidget.lastUncollapsedTick = Iris._cycleTick + 1
            else
                local collapsedHeight: number = TitleBar.AbsoluteSize.Y -- Iris._config.TextSize + Iris._config.FramePadding.Y * 2
                TitleBar.CollapseButton.Arrow.Image = widgets.ICONS.RIGHT_POINTING_TRIANGLE

                ChildContainer.Visible = false
                ResizeGrip.Visible = false
                WindowButton.Size = UDim2.fromOffset(stateSize.X, collapsedHeight)
                thisWidget.lastCollapsedTick = Iris._cycleTick + 1
            end

            if stateIsOpened and stateIsUncollapsed then
                Iris.SetFocusedWindow(thisWidget)
            else
                TitleBar.BackgroundColor3 = Iris._config.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._config.TitleBgCollapsedTransparency
                WindowButton.UIStroke.Color = Iris._config.BorderColor

                Iris.SetFocusedWindow(nil)
            end

            -- cant update canvasPosition in this cycle because scrollingframe isint ready to be changed
            if stateScrollDistance and stateScrollDistance ~= 0 then
                local callbackIndex: number = #Iris._postCycleCallbacks + 1
                local desiredCycleTick: number = Iris._cycleTick + 1
                Iris._postCycleCallbacks[callbackIndex] = function()
                    if Iris._cycleTick == desiredCycleTick then
                        ChildContainer.CanvasPosition = Vector2.new(0, stateScrollDistance)
                        Iris._postCycleCallbacks[callbackIndex] = nil
                    end
                end
            end
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.size == nil then
                thisWidget.state.size = Iris._widgetState(thisWidget, "size", Vector2.new(400, 300))
            end
            if thisWidget.state.position == nil then
                thisWidget.state.position = Iris._widgetState(thisWidget, "position", if anyFocusedWindow and focusedWindow then focusedWindow.state.position.value + Vector2.new(15, 45) else Vector2.new(150, 250))
            end
            thisWidget.state.position.value = fitPositionToWindowBounds(thisWidget, thisWidget.state.position.value)
            thisWidget.state.size.value = fitSizeToWindowBounds(thisWidget, thisWidget.state.size.value)

            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", true)
            end
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", true)
            end
            if thisWidget.state.scrollDistance == nil then
                thisWidget.state.scrollDistance = Iris._widgetState(thisWidget, "scrollDistance", 0)
            end
        end,
    } :: Types.WidgetClass)
end
