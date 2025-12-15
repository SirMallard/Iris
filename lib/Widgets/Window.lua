local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

--[=[
    @class Window

    Windows are the fundamental widget for Iris. Every other widget must be a descendant of a window.

    ```lua
    Iris.Window("Example Window")
        Iris.Text("This is an example window!")
    Iris.End()
    ```

    ![Example window](/Iris/assets/api/window/basicWindow.png)

    If you do not want the code inside a window to run unless it is open then you can use the following:
    ```lua
    local window = Iris.Window("Many Widgets Window")

    if window.state.shown:get() and window.state.open:get() then
        Iris.Text("I will only be created when the window is open.")
    end
    Iris.End() -- must always call Iris.End(), regardless of whether the window is shown or not.
    ```
]=]

--[=[
    @within Window
    @interface Window
    .& ParentWidget
    .opened () -> boolean -- once when opened
    .closed () -> boolean -- once when closed
    .shown () -> boolean -- once when shown
    .hidden () -> boolean -- once when hidden
    .hovered () -> boolean -- fires when the mouse hovers over any of the window

    .arguments { Title: string?, Flags: number }
    .state { size: State<Vector>, position: State<Vector2>, open: State<boolean>, shown: State<boolean>, scrollDistance: State<number> }
]=]
export type Window = Types.ParentWidget & {
    _usesScreenGuis: boolean,

    arguments: {
        Title: string?,
        Flags: number,
    },

    state: {
        size: Types.State<Vector2>,
        position: Types.State<Vector2>,
        open: Types.State<boolean>,
        shown: Types.State<boolean>,
        scrollDistance: Types.State<number>,
    },
} & Types.Opened & Types.Closed & Types.Shown & Types.Hidden & Types.Hovered

--[=[
    @within Window
    @interface Tooltip
    .& Widget
    .arguments { Text: string }
]=]
export type Tooltip = Types.Widget & {
    arguments: {
        Text: string,
    },
}

--[=[
    @within Window
    @interface WindowFlags
    .NoTitleBar 1 -- hide title bar
    .NoBackground 2 -- hide background colour
    .NoCollapse 4 -- hide collapsing button
    .NoClose 8 -- hide close button
    .NoMove 16 -- disable drag-to-move functionality
    .NoScrollbar 32 -- disable scrollbar
    .NoResize 64 -- disable drag-to-resize functionality
    .NoNav 128 -- unused
    .NoMenu 256 -- hide the menubar
]=]
local WindowFlags = {
    NoTitleBar = 1,
    NoBackground = 2,
    NoCollapse = 4,
    NoClose = 8,
    NoMove = 16,
    NoScrollbar = 32,
    NoResize = 64,
    NoNav = 128,
    NoMenu = 256,
}

---------------
-- Variables
---------------

local windowDisplayOrder = 0 -- incremental count which is used for determining focused windows ZIndex
local dragWindow: Window? -- window being dragged, may be nil
local isDragging = false
local moveDeltaCursorPosition: Vector2 -- cursor offset from drag origin (top left of window)

local resizeWindow: Window? -- window being resized, may be nil
local isResizing = false
local isInsideResize = false -- is cursor inside of the focused window resize outer padding
local isInsideWindow = false -- is cursor inside of the focused window
local resizeFromTopBottom = Enum.TopBottom.Top
local resizeFromLeftRight = Enum.LeftRight.Left

local lastCursorPosition: Vector2

local focusedWindow: Window? -- window with focus, may be nil
local anyFocusedWindow = false -- is there any focused window?

local windowWidgets: { [Types.ID]: Window } = {} -- array of widget objects of type window

---------------
-- Functions
---------------

local function relocateTooltips()
    if Internal._rootInstance == nil then
        return
    end
    local PopupScreenGui = Internal._rootInstance:FindFirstChild("PopupScreenGui")
    local TooltipContainer: Frame = PopupScreenGui.TooltipContainer
    local mouseLocation = Utility.getMouseLocation()
    local newPosition = Utility.findBestWindowPosForPopup(mouseLocation, TooltipContainer.AbsoluteSize, Internal._config.DisplaySafeAreaPadding, PopupScreenGui.AbsoluteSize)
    TooltipContainer.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
end

local function fitSizeToWindowBounds(thisWidget: Window, intentedSize: Vector2)
    local windowSize = Vector2.new(thisWidget.state.position._value.X, thisWidget.state.position._value.Y)
    local minWindowSize = (Internal._config.TextSize + 2 * Internal._config.FramePadding.Y) * 2
    local usableSize = Utility.getScreenSizeForWindow(thisWidget)
    local safeAreaPadding = Vector2.new(Internal._config.WindowBorderSize + Internal._config.DisplaySafeAreaPadding.X, Internal._config.WindowBorderSize + Internal._config.DisplaySafeAreaPadding.Y)

    local maxWindowSize = (usableSize - windowSize - safeAreaPadding)
    return Vector2.new(math.clamp(intentedSize.X, minWindowSize, math.max(maxWindowSize.X, minWindowSize)), math.clamp(intentedSize.Y, minWindowSize, math.max(maxWindowSize.Y, minWindowSize)))
end

local function fitPositionToWindowBounds(thisWidget: Window, intendedPosition: Vector2)
    local thisWidgetInstance = thisWidget.instance
    local usableSize = Utility.getScreenSizeForWindow(thisWidget)
    local safeAreaPadding = Vector2.new(Internal._config.WindowBorderSize + Internal._config.DisplaySafeAreaPadding.X, Internal._config.WindowBorderSize + Internal._config.DisplaySafeAreaPadding.Y)

    return Vector2.new(
        math.clamp(intendedPosition.X, safeAreaPadding.X, math.max(safeAreaPadding.X, usableSize.X - thisWidgetInstance.WindowButton.AbsoluteSize.X - safeAreaPadding.X)),
        math.clamp(intendedPosition.Y, safeAreaPadding.Y, math.max(safeAreaPadding.Y, usableSize.Y - thisWidgetInstance.WindowButton.AbsoluteSize.Y - safeAreaPadding.Y))
    )
end

local function setFocusedWindow(thisWidget: Window?)
    if focusedWindow == thisWidget then
        return
    end

    if anyFocusedWindow and focusedWindow ~= nil then
        if windowWidgets[focusedWindow.ID] then
            local Window = focusedWindow.instance :: Frame
            local WindowButton = Window.WindowButton :: TextButton
            local Content = WindowButton.Content :: Frame
            local TitleBar: Frame = Content.TitleBar
            -- update appearance to unfocus
            if focusedWindow.state.open._value then
                TitleBar.BackgroundColor3 = Internal._config.TitleBgColor
                TitleBar.BackgroundTransparency = Internal._config.TitleBgTransparency
            else
                TitleBar.BackgroundColor3 = Internal._config.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Internal._config.TitleBgCollapsedTransparency
            end
            WindowButton.UIStroke.Color = Internal._config.BorderColor
        end

        anyFocusedWindow = false
        focusedWindow = nil
    end

    if thisWidget ~= nil then
        -- update appearance to focus
        anyFocusedWindow = true
        focusedWindow = thisWidget
        local Window = thisWidget.instance :: Frame
        local WindowButton = Window.WindowButton :: TextButton
        local Content = WindowButton.Content :: Frame
        local TitleBar: Frame = Content.TitleBar

        TitleBar.BackgroundColor3 = Internal._config.TitleBgActiveColor
        TitleBar.BackgroundTransparency = Internal._config.TitleBgActiveTransparency
        WindowButton.UIStroke.Color = Internal._config.BorderActiveColor

        windowDisplayOrder += 1
        if thisWidget._usesScreenGuis then
            Window.DisplayOrder = windowDisplayOrder + Internal._config.DisplayOrderOffset
        else
            Window.ZIndex = windowDisplayOrder + Internal._config.DisplayOrderOffset
        end

        if thisWidget.state.open._value == false then
            thisWidget.state.open:set(true)
        end

        local firstSelectedObject: GuiObject? = Utility.GuiService.SelectedObject
        if firstSelectedObject then
            if TitleBar.Visible then
                Utility.GuiService:Select(TitleBar)
            else
                Utility.GuiService:Select(thisWidget.childContainer)
            end
        end
    end
end

local function quickSwapWindows()
    -- ctrl + tab swapping functionality
    if Internal._config.UseScreenGUIs == false then
        return
    end

    local lowest = 0xFFFF
    local lowestWidget: Window

    for _, widget in windowWidgets do
        if widget.state.isOpened._value and not btest(WindowFlags.NoNav, widget.arguments.Flags) then
            if widget.instance:IsA("ScreenGui") then
                local value = widget.instance.DisplayOrder
                if value < lowest then
                    lowest = value
                    lowestWidget = widget
                end
            end
        end
    end

    if not lowestWidget then
        return
    end

    if lowestWidget.state.open._value == false then
        lowestWidget.state.open:set(true)
    end
    setFocusedWindow(lowestWidget)
end

Utility.registerEvent("InputBegan", function(input: InputObject)
    if not Internal._started then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local inWindow = false
        local position = Utility.getMouseLocation()
        for _, window in windowWidgets do
            local Window = window.instance
            if not Window then
                continue
            end
            local WindowButton = Window.WindowButton :: TextButton
            local ResizeBorder: TextButton = WindowButton.ResizeBorder
            if ResizeBorder and Utility.isPosInsideRect(position, ResizeBorder.AbsolutePosition - Utility.guiOffset, ResizeBorder.AbsolutePosition - Utility.guiOffset + ResizeBorder.AbsoluteSize) then
                inWindow = true
                break
            end
        end

        if not inWindow then
            setFocusedWindow(nil)
        end
    end

    if input.KeyCode == Enum.KeyCode.Tab and (Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        quickSwapWindows()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and isInsideResize and not isInsideWindow and anyFocusedWindow and focusedWindow then
        local midWindow = focusedWindow.state.position._value + (focusedWindow.state.size._value / 2)
        local cursorPosition = Utility.getMouseLocation() - midWindow

        -- check which axis its closest to, then check which side is closest with math.sign
        if math.abs(cursorPosition.X) * focusedWindow.state.size._value.Y >= math.abs(cursorPosition.Y) * focusedWindow.state.size._value.X then
            resizeFromTopBottom = Enum.TopBottom.Center
            resizeFromLeftRight = if math.sign(cursorPosition.X) == -1 then Enum.LeftRight.Left else Enum.LeftRight.Right
        else
            resizeFromLeftRight = Enum.LeftRight.Center
            resizeFromTopBottom = if math.sign(cursorPosition.Y) == -1 then Enum.TopBottom.Top else Enum.TopBottom.Bottom
        end
        isResizing = true
        resizeWindow = focusedWindow
    end
end)

Utility.registerEvent("TouchTapInWorld", function(_, gameProcessedEvent: boolean)
    if not Internal._started then
        return
    end
    if not gameProcessedEvent then
        setFocusedWindow(nil)
    end
end)

Utility.registerEvent("InputChanged", function(input: InputObject)
    if not Internal._started then
        return
    end

    relocateTooltips()

    if isDragging and dragWindow then
        local mouseLocation
        if input.UserInputType == Enum.UserInputType.Touch then
            local location = input.Position
            mouseLocation = Vector2.new(location.X, location.Y)
        else
            mouseLocation = Utility.getMouseLocation()
        end
        local Window = dragWindow.instance :: Frame
        local dragInstance: TextButton = Window.WindowButton
        local intendedPosition = mouseLocation - moveDeltaCursorPosition
        local newPos = fitPositionToWindowBounds(dragWindow, intendedPosition)

        -- state shouldnt be used like this, but calling :set would run the entire UpdateState function for the window,
        -- which is slow.
        dragInstance.Position = UDim2.fromOffset(newPos.X, newPos.Y)
        dragWindow.state.position._value = newPos
    end
    if isResizing and resizeWindow and btest(WindowFlags.NoResize, resizeWindow.arguments.Flags) ~= true then
        local Window = resizeWindow.instance :: Frame
        local resizeInstance: TextButton = Window.WindowButton
        local windowPosition = Vector2.new(resizeInstance.Position.X.Offset, resizeInstance.Position.Y.Offset)
        local windowSize = Vector2.new(resizeInstance.Size.X.Offset, resizeInstance.Size.Y.Offset)

        local mouseDelta
        if input.UserInputType == Enum.UserInputType.Touch then
            mouseDelta = input.Delta
        else
            mouseDelta = Utility.getMouseLocation() - lastCursorPosition
        end

        local intendedPosition = windowPosition + Vector2.new(if resizeFromLeftRight == Enum.LeftRight.Left then mouseDelta.X else 0, if resizeFromTopBottom == Enum.TopBottom.Top then mouseDelta.Y else 0)

        local intendedSize = windowSize
            + Vector2.new(
                if resizeFromLeftRight == Enum.LeftRight.Left then -mouseDelta.X elseif resizeFromLeftRight == Enum.LeftRight.Right then mouseDelta.X else 0,
                if resizeFromTopBottom == Enum.TopBottom.Top then -mouseDelta.Y elseif resizeFromTopBottom == Enum.TopBottom.Bottom then mouseDelta.Y else 0
            )

        local newSize = fitSizeToWindowBounds(resizeWindow, intendedSize)
        local newPosition = fitPositionToWindowBounds(resizeWindow, intendedPosition)

        resizeInstance.Size = UDim2.fromOffset(newSize.X, newSize.Y)
        resizeWindow.state.size._value = newSize
        resizeInstance.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
        resizeWindow.state.position._value = newPosition
    end

    lastCursorPosition = Utility.getMouseLocation()
end)

Utility.registerEvent("InputEnded", function(input, _)
    if not Internal._started then
        return
    end
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging and dragWindow then
        local Window = dragWindow.instance :: Frame
        local dragInstance: TextButton = Window.WindowButton
        isDragging = false
        dragWindow.state.position:set(Vector2.new(dragInstance.Position.X.Offset, dragInstance.Position.Y.Offset))
    end
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isResizing and resizeWindow then
        local Window = resizeWindow.instance :: Instance
        isResizing = false
        resizeWindow.state.size:set(Window.WindowButton.AbsoluteSize)
    end

    if input.KeyCode == Enum.KeyCode.ButtonX then
        quickSwapWindows()
    end
end)

-------------
-- Tooltip
-------------

Internal._widgetConstructor(
    "Tooltip",
    {
        hasState = false,
        hasChildren = false,
        numArguments = 1,
        Arguments = { "Text" },
        Events = {},
        Generate = function(thisWidget: Tooltip)
            thisWidget.parentWidget = Internal._rootWidget -- only allow root as parent

            local Tooltip = Instance.new("Frame")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.AutomaticSize = Enum.AutomaticSize.Y
            Tooltip.Size = UDim2.new(Internal._config.ContentWidth, UDim.new(0, 0))
            Tooltip.BorderSizePixel = 0
            Tooltip.BackgroundTransparency = 1

            local TooltipText = Instance.new("TextLabel")
            TooltipText.Name = "TooltipText"
            TooltipText.AutomaticSize = Enum.AutomaticSize.XY
            TooltipText.Size = UDim2.fromOffset(0, 0)
            TooltipText.BackgroundColor3 = Internal._config.PopupBgColor
            TooltipText.BackgroundTransparency = Internal._config.PopupBgTransparency

            Utility.applyTextStyle(TooltipText)
            Utility.UIStroke(TooltipText, Internal._config.PopupBorderSize, Internal._config.BorderActiveColor, Internal._config.BorderActiveTransparency)
            Utility.UIPadding(TooltipText, Internal._config.WindowPadding)
            if Internal._config.PopupRounding > 0 then
                Utility.UICorner(TooltipText, Internal._config.PopupRounding)
            end

            TooltipText.Parent = Tooltip

            return Tooltip
        end,
        Update = function(thisWidget: Tooltip)
            local Tooltip = thisWidget.instance :: Frame
            local TooltipText: TextLabel = Tooltip.TooltipText
            if thisWidget.arguments.Text == nil then
                error("Text argument is required for Iris.Tooltip().", 5)
            end
            TooltipText.Text = thisWidget.arguments.Text
            relocateTooltips()
        end,
        Discard = function(thisWidget: Tooltip)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

------------
-- Window
------------

Internal._widgetConstructor(
    "Window",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 2,
        Arguments = { "Title", "Flags", "size", "position", "open", "shown", "scrollDistance" },
        Events = {
            ["opened"] = Utility.EVENTS.open,
            ["closed"] = Utility.EVENTS.close,
            ["shown"] = Utility.EVENTS.show,
            ["hidden"] = Utility.EVENTS.hide,
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget)
                local Window = thisWidget.instance :: Frame
                return Window.WindowButton
            end),
        },
        Generate = function(thisWidget: Window)
            thisWidget.parentWidget = Internal._rootWidget -- only allow root as parent

            thisWidget._usesScreenGuis = Internal._config.UseScreenGUIs
            windowWidgets[thisWidget.ID] = thisWidget

            local Window
            if thisWidget._usesScreenGuis then
                Window = Instance.new("ScreenGui")
                Window.ResetOnSpawn = false
                Window.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                Window.DisplayOrder = Internal._config.DisplayOrderOffset
                Window.ScreenInsets = Internal._config.ScreenInsets
                Window.IgnoreGuiInset = Internal._config.IgnoreGuiInset
            else
                Window = Instance.new("Frame")
                Window.AnchorPoint = Vector2.new(0.5, 0.5)
                Window.Position = UDim2.fromScale(0.5, 0.5)
                Window.Size = UDim2.fromScale(1, 1)
                Window.BackgroundTransparency = 1
                Window.ZIndex = Internal._config.DisplayOrderOffset
            end
            Window.Name = "Iris_Window"

            local WindowButton = Instance.new("TextButton")
            WindowButton.Name = "WindowButton"
            WindowButton.Size = UDim2.fromOffset(0, 0)
            WindowButton.BackgroundTransparency = 1
            WindowButton.BorderSizePixel = 0
            WindowButton.Text = ""
            WindowButton.AutoButtonColor = false
            WindowButton.ClipsDescendants = false
            WindowButton.Selectable = false

            WindowButton.SelectionImageObject = Internal._selectionImageObject
            WindowButton.SelectionGroup = true
            WindowButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

            Utility.UIStroke(WindowButton, Internal._config.WindowBorderSize, Internal._config.BorderColor, Internal._config.BorderTransparency)

            WindowButton.Parent = Window

            Utility.applyInputBegan(WindowButton, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if thisWidget.state.open._value then
                    setFocusedWindow(thisWidget)
                end
                if not btest(WindowFlags.NoMove, thisWidget.arguments.Flags) and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragWindow = thisWidget
                    isDragging = true
                    moveDeltaCursorPosition = Utility.getMouseLocation() - thisWidget.state.position._value
                end
            end)

            local Content = Instance.new("Frame")
            Content.Name = "Content"
            Content.AnchorPoint = Vector2.new(0.5, 0.5)
            Content.Position = UDim2.fromScale(0.5, 0.5)
            Content.Size = UDim2.fromScale(1, 1)
            Content.BackgroundTransparency = 1
            Content.ClipsDescendants = true
            Content.Parent = WindowButton

            local UIListLayout = Utility.UIListLayout(Content, Enum.FillDirection.Vertical, UDim.new(0, 0))
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "WindowContainer"
            ChildContainer.Size = UDim2.fromScale(1, 1)
            ChildContainer.BackgroundColor3 = Internal._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Internal._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Internal._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Internal._config.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
            ChildContainer.TopImageContent = Utility.ICONS.BLANK_SQUARE
            ChildContainer.MidImageContent = Utility.ICONS.BLANK_SQUARE
            ChildContainer.BottomImageContent = Utility.ICONS.BLANK_SQUARE

            ChildContainer.LayoutOrder = thisWidget.zindex + 0xFFFF
            ChildContainer.ClipsDescendants = true

            Utility.UIPadding(ChildContainer, Internal._config.WindowPadding)

            ChildContainer.Parent = Content

            local UIFlexItem = Instance.new("UIFlexItem")
            UIFlexItem.FlexMode = Enum.UIFlexMode.Fill
            UIFlexItem.ItemLineAlignment = Enum.ItemLineAlignment.End
            UIFlexItem.Parent = ChildContainer

            ChildContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                -- "wrong" use of state here, for optimization
                thisWidget.state.scrollDistance._value = ChildContainer.CanvasPosition.Y
            end)

            Utility.applyInputBegan(ChildContainer, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if thisWidget.state.open._value then
                    setFocusedWindow(thisWidget)
                end
            end)

            local TerminatingFrame = Instance.new("Frame")
            TerminatingFrame.Name = "TerminatingFrame"
            TerminatingFrame.Size = UDim2.fromOffset(0, Internal._config.WindowPadding.Y + Internal._config.FramePadding.Y)
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0

            Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y)).VerticalAlignment = Enum.VerticalAlignment.Top

            TerminatingFrame.Parent = ChildContainer

            local TitleBar = Instance.new("Frame")
            TitleBar.Name = "TitleBar"
            TitleBar.AutomaticSize = Enum.AutomaticSize.Y
            TitleBar.Size = UDim2.fromScale(1, 0)
            TitleBar.BorderSizePixel = 0
            TitleBar.ClipsDescendants = true

            TitleBar.Parent = Content

            Utility.UIPadding(TitleBar, Vector2.new(Internal._config.FramePadding.X))
            Utility.UIListLayout(TitleBar, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center
            Utility.applyInputBegan(TitleBar, function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    if not btest(WindowFlags.NoMove, thisWidget.arguments.Flags) then
                        dragWindow = thisWidget
                        isDragging = true
                        local location = input.Position
                        moveDeltaCursorPosition = Vector2.new(location.X, location.Y) - thisWidget.state.position._value
                    end
                end
            end)

            local TitleButtonSize = Internal._config.TextSize + ((Internal._config.FramePadding.Y - 1) * 2)

            local CollapseButton = Instance.new("TextButton")
            CollapseButton.Name = "CollapseButton"
            CollapseButton.AutomaticSize = Enum.AutomaticSize.None
            CollapseButton.AnchorPoint = Vector2.new(0, 0.5)
            CollapseButton.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CollapseButton.Position = UDim2.fromScale(0, 0.5)
            CollapseButton.BackgroundTransparency = 1
            CollapseButton.BorderSizePixel = 0
            CollapseButton.AutoButtonColor = false
            CollapseButton.Text = ""

            Utility.UICorner(CollapseButton)

            CollapseButton.Parent = TitleBar

            Utility.applyButtonClick(CollapseButton, function()
                thisWidget.state.open:set(not thisWidget.state.open._value)
            end)

            Utility.applyInteractionHighlights("Background", CollapseButton, CollapseButton, {
                Color = Internal._config.ButtonColor,
                Transparency = 1,
                HoveredColor = Internal._config.ButtonHoveredColor,
                HoveredTransparency = Internal._config.ButtonHoveredTransparency,
                ActiveColor = Internal._config.ButtonActiveColor,
                ActiveTransparency = Internal._config.ButtonActiveTransparency,
            })

            local CollapseArrow = Instance.new("ImageLabel")
            CollapseArrow.Name = "Arrow"
            CollapseArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            CollapseArrow.Size = UDim2.fromOffset(math.floor(0.7 * TitleButtonSize), math.floor(0.7 * TitleButtonSize))
            CollapseArrow.Position = UDim2.fromScale(0.5, 0.5)
            CollapseArrow.BackgroundTransparency = 1
            CollapseArrow.BorderSizePixel = 0
            CollapseArrow.ImageContent = Utility.ICONS.MULTIPLICATION_SIGN
            CollapseArrow.ImageColor3 = Internal._config.TextColor
            CollapseArrow.ImageTransparency = Internal._config.TextTransparency
            CollapseArrow.Parent = CollapseButton

            local CloseButton = Instance.new("TextButton")
            CloseButton.Name = "CloseButton"
            CloseButton.AutomaticSize = Enum.AutomaticSize.None
            CloseButton.AnchorPoint = Vector2.new(1, 0.5)
            CloseButton.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CloseButton.Position = UDim2.fromScale(1, 0.5)
            CloseButton.BackgroundTransparency = 1
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = ""
            CloseButton.AutoButtonColor = false
            CloseButton.LayoutOrder = 2

            Utility.UICorner(CloseButton)

            Utility.applyButtonClick(CloseButton, function()
                thisWidget.state.shown:set(false)
            end)

            Utility.applyInteractionHighlights("Background", CloseButton, CloseButton, {
                Color = Internal._config.ButtonColor,
                Transparency = 1,
                HoveredColor = Internal._config.ButtonHoveredColor,
                HoveredTransparency = Internal._config.ButtonHoveredTransparency,
                ActiveColor = Internal._config.ButtonActiveColor,
                ActiveTransparency = Internal._config.ButtonActiveTransparency,
            })

            CloseButton.Parent = TitleBar

            local CloseIcon = Instance.new("ImageLabel")
            CloseIcon.Name = "Icon"
            CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            CloseIcon.Size = UDim2.fromOffset(math.floor(0.7 * TitleButtonSize), math.floor(0.7 * TitleButtonSize))
            CloseIcon.Position = UDim2.fromScale(0.5, 0.5)
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.BorderSizePixel = 0
            CloseIcon.ImageContent = Utility.ICONS.MULTIPLICATION_SIGN
            CloseIcon.ImageColor3 = Internal._config.TextColor
            CloseIcon.ImageTransparency = Internal._config.TextTransparency
            CloseIcon.Parent = CloseButton

            -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.

            local Title = Instance.new("TextLabel")
            Title.Name = "Title"
            Title.AutomaticSize = Enum.AutomaticSize.XY
            Title.BorderSizePixel = 0
            Title.BackgroundTransparency = 1
            Title.LayoutOrder = 1
            Title.ClipsDescendants = true

            Utility.UIPadding(Title, Vector2.new(0, Internal._config.FramePadding.Y))
            Utility.applyTextStyle(Title)
            Title.TextXAlignment = Enum.TextXAlignment[Internal._config.WindowTitleAlign.Name] :: Enum.TextXAlignment

            local TitleFlexItem = Instance.new("UIFlexItem")
            TitleFlexItem.FlexMode = Enum.UIFlexMode.Fill
            TitleFlexItem.ItemLineAlignment = Enum.ItemLineAlignment.Center

            TitleFlexItem.Parent = Title

            Title.Parent = TitleBar

            local ResizeButtonSize = Internal._config.TextSize + Internal._config.FramePadding.X

            local LeftResizeGrip = Instance.new("ImageButton")
            LeftResizeGrip.Name = "LeftResizeGrip"
            LeftResizeGrip.AnchorPoint = Vector2.yAxis
            LeftResizeGrip.Rotation = 180
            LeftResizeGrip.Position = UDim2.fromScale(0, 1)
            LeftResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            LeftResizeGrip.BackgroundTransparency = 1
            LeftResizeGrip.BorderSizePixel = 0
            LeftResizeGrip.ImageContent = Utility.ICONS.BOTTOM_RIGHT_CORNER
            LeftResizeGrip.ImageColor3 = Internal._config.ResizeGripColor
            LeftResizeGrip.ImageTransparency = 1
            LeftResizeGrip.AutoButtonColor = false
            LeftResizeGrip.ZIndex = 3
            LeftResizeGrip.Parent = WindowButton

            Utility.applyInteractionHighlights("Image", LeftResizeGrip, LeftResizeGrip, {
                Color = Internal._config.ResizeGripColor,
                Transparency = 1,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            Utility.applyButtonDown(LeftResizeGrip, function()
                if not anyFocusedWindow or not (focusedWindow == thisWidget) then
                    setFocusedWindow(thisWidget)
                    -- mitigating wrong focus when clicking on buttons inside of a window without clicking the window
                    -- itself
                end
                isResizing = true
                resizeFromTopBottom = Enum.TopBottom.Bottom
                resizeFromLeftRight = Enum.LeftRight.Left
                resizeWindow = thisWidget
            end)

            -- each border uses an image, allowing it to have a shown borde which is larger than the UI
            local RightResizeGrip = Instance.new("ImageButton")
            RightResizeGrip.Name = "RightResizeGrip"
            RightResizeGrip.AnchorPoint = Vector2.one
            RightResizeGrip.Rotation = 90
            RightResizeGrip.Position = UDim2.fromScale(1, 1)
            RightResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            RightResizeGrip.BackgroundTransparency = 1
            RightResizeGrip.BorderSizePixel = 0
            RightResizeGrip.ImageContent = Utility.ICONS.BOTTOM_RIGHT_CORNER
            RightResizeGrip.ImageColor3 = Internal._config.ResizeGripColor
            RightResizeGrip.ImageTransparency = Internal._config.ResizeGripTransparency
            RightResizeGrip.AutoButtonColor = false
            RightResizeGrip.ZIndex = 3
            RightResizeGrip.Parent = WindowButton

            Utility.applyInteractionHighlights("Image", RightResizeGrip, RightResizeGrip, {
                Color = Internal._config.ResizeGripColor,
                Transparency = Internal._config.ResizeGripTransparency,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            Utility.applyButtonDown(RightResizeGrip, function()
                if not anyFocusedWindow or not (focusedWindow == thisWidget) then
                    setFocusedWindow(thisWidget)
                    -- mitigating wrong focus when clicking on buttons inside of a window without clicking the window
                    -- itself
                end
                isResizing = true
                resizeFromTopBottom = Enum.TopBottom.Bottom
                resizeFromLeftRight = Enum.LeftRight.Right
                resizeWindow = thisWidget
            end)

            local LeftResizeBorder = Instance.new("ImageButton")
            LeftResizeBorder.Name = "LeftResizeBorder"
            LeftResizeBorder.AnchorPoint = Vector2.new(1, 0.5)
            LeftResizeBorder.Position = UDim2.fromScale(0, 0.5)
            LeftResizeBorder.Size = UDim2.new(0, Internal._config.WindowResizePadding.X, 1, 2 * Internal._config.WindowBorderSize)
            LeftResizeBorder.Transparency = 1
            LeftResizeBorder.ImageContent = Utility.ICONS.BORDER
            LeftResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
            LeftResizeBorder.ScaleType = Enum.ScaleType.Slice
            LeftResizeBorder.SliceCenter = Rect.new(0, 0, 1, 1)
            LeftResizeBorder.ImageRectOffset = Vector2.new(2, 2)
            LeftResizeBorder.ImageRectSize = Vector2.new(2, 1)
            LeftResizeBorder.ImageTransparency = 1
            LeftResizeBorder.AutoButtonColor = false
            LeftResizeBorder.ZIndex = 4

            LeftResizeBorder.Parent = WindowButton

            local RightResizeBorder = Instance.new("ImageButton")
            RightResizeBorder.Name = "RightResizeBorder"
            RightResizeBorder.AnchorPoint = Vector2.new(0, 0.5)
            RightResizeBorder.Position = UDim2.fromScale(1, 0.5)
            RightResizeBorder.Size = UDim2.new(0, Internal._config.WindowResizePadding.X, 1, 2 * Internal._config.WindowBorderSize)
            RightResizeBorder.Transparency = 1
            RightResizeBorder.ImageContent = Utility.ICONS.BORDER
            RightResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
            RightResizeBorder.ScaleType = Enum.ScaleType.Slice
            RightResizeBorder.SliceCenter = Rect.new(1, 0, 2, 1)
            RightResizeBorder.ImageRectOffset = Vector2.new(1, 2)
            RightResizeBorder.ImageRectSize = Vector2.new(2, 1)
            RightResizeBorder.ImageTransparency = 1
            RightResizeBorder.AutoButtonColor = false
            RightResizeBorder.ZIndex = 4

            RightResizeBorder.Parent = WindowButton

            local TopResizeBorder = Instance.new("ImageButton")
            TopResizeBorder.Name = "TopResizeBorder"
            TopResizeBorder.AnchorPoint = Vector2.new(0.5, 1)
            TopResizeBorder.Position = UDim2.fromScale(0.5, 0)
            TopResizeBorder.Size = UDim2.new(1, 2 * Internal._config.WindowBorderSize, 0, Internal._config.WindowResizePadding.Y)
            TopResizeBorder.Transparency = 1
            TopResizeBorder.ImageContent = Utility.ICONS.BORDER
            TopResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
            TopResizeBorder.ScaleType = Enum.ScaleType.Slice
            TopResizeBorder.SliceCenter = Rect.new(0, 0, 1, 1)
            TopResizeBorder.ImageRectOffset = Vector2.new(2, 2)
            TopResizeBorder.ImageRectSize = Vector2.new(1, 2)
            TopResizeBorder.ImageTransparency = 1
            TopResizeBorder.AutoButtonColor = false
            TopResizeBorder.ZIndex = 4

            TopResizeBorder.Parent = WindowButton

            local BottomResizeBorder = Instance.new("ImageButton")
            BottomResizeBorder.Name = "BottomResizeBorder"
            BottomResizeBorder.AnchorPoint = Vector2.new(0.5, 0)
            BottomResizeBorder.Position = UDim2.fromScale(0.5, 1)
            BottomResizeBorder.Size = UDim2.new(1, 2 * Internal._config.WindowBorderSize, 0, Internal._config.WindowResizePadding.Y)
            BottomResizeBorder.Transparency = 1
            BottomResizeBorder.ImageContent = Utility.ICONS.BORDER
            BottomResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
            BottomResizeBorder.ScaleType = Enum.ScaleType.Slice
            BottomResizeBorder.SliceCenter = Rect.new(0, 1, 1, 2)
            BottomResizeBorder.ImageRectOffset = Vector2.new(2, 1)
            BottomResizeBorder.ImageRectSize = Vector2.new(1, 2)
            BottomResizeBorder.ImageTransparency = 1
            BottomResizeBorder.AutoButtonColor = false
            BottomResizeBorder.ZIndex = 4

            BottomResizeBorder.Parent = WindowButton

            Utility.applyInteractionHighlights("Image", LeftResizeBorder, LeftResizeBorder, {
                Color = Internal._config.ResizeGripColor,
                Transparency = 1,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            Utility.applyInteractionHighlights("Image", RightResizeBorder, RightResizeBorder, {
                Color = Internal._config.ResizeGripColor,
                Transparency = 1,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            Utility.applyInteractionHighlights("Image", TopResizeBorder, TopResizeBorder, {
                Color = Internal._config.ResizeGripColor,
                Transparency = 1,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            Utility.applyInteractionHighlights("Image", BottomResizeBorder, BottomResizeBorder, {
                Color = Internal._config.ResizeGripColor,
                Transparency = 1,
                HoveredColor = Internal._config.ResizeGripHoveredColor,
                HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
                ActiveColor = Internal._config.ResizeGripActiveColor,
                ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
            })

            local ResizeBorder = Instance.new("Frame")
            ResizeBorder.Name = "ResizeBorder"
            ResizeBorder.Position = UDim2.fromOffset(-Internal._config.WindowResizePadding.X, -Internal._config.WindowResizePadding.Y)
            ResizeBorder.Size = UDim2.new(1, Internal._config.WindowResizePadding.X * 2, 1, Internal._config.WindowResizePadding.Y * 2)
            ResizeBorder.BackgroundTransparency = 1
            ResizeBorder.BorderSizePixel = 0
            ResizeBorder.Active = false
            ResizeBorder.Selectable = false
            ResizeBorder.ClipsDescendants = false
            ResizeBorder.Parent = WindowButton

            Utility.applyMouseEnter(ResizeBorder, function()
                if focusedWindow == thisWidget then
                    isInsideResize = true
                end
            end)
            Utility.applyMouseLeave(ResizeBorder, function()
                if focusedWindow == thisWidget then
                    isInsideResize = false
                end
            end)
            Utility.applyInputBegan(ResizeBorder, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if thisWidget.state.open._value then
                    setFocusedWindow(thisWidget)
                end
            end)

            Utility.applyMouseEnter(WindowButton, function()
                if focusedWindow == thisWidget then
                    isInsideWindow = true
                end
            end)
            Utility.applyMouseLeave(WindowButton, function()
                if focusedWindow == thisWidget then
                    isInsideWindow = false
                end
            end)

            thisWidget.childContainer = ChildContainer
            return Window
        end,
        GenerateState = function(thisWidget: Window)
            if thisWidget.state.size == nil then
                thisWidget.state.size = Internal._widgetState(thisWidget, "size", Vector2.new(400, 300))
            end
            if thisWidget.state.position == nil then
                thisWidget.state.position = Internal._widgetState(thisWidget, "position", if anyFocusedWindow and focusedWindow then focusedWindow.state.position._value + Vector2.new(15, 45) else Vector2.new(150, 250))
            end
            thisWidget.state.position._value = fitPositionToWindowBounds(thisWidget, thisWidget.state.position._value)
            thisWidget.state.size._value = fitSizeToWindowBounds(thisWidget, thisWidget.state.size._value)

            if thisWidget.state.open == nil then
                thisWidget.state.open = Internal._widgetState(thisWidget, "open", false)
            end
            if thisWidget.state.shown == nil then
                thisWidget.state.shown = Internal._widgetState(thisWidget, "shown", true)
            end
            if thisWidget.state.scrollDistance == nil then
                thisWidget.state.scrollDistance = Internal._widgetState(thisWidget, "scrollDistance", 0)
            end
        end,
        Update = function(thisWidget: Window)
            local Window = thisWidget.instance :: GuiObject
            local ChildContainer = thisWidget.childContainer :: ScrollingFrame
            local WindowButton = Window.WindowButton :: TextButton
            local Content = WindowButton.Content :: Frame
            local TitleBar = Content.TitleBar :: Frame
            local Title: TextLabel = TitleBar.Title
            local MenuBar: Frame? = Content:FindFirstChild("Iris_MenuBar")
            local LeftResizeGrip: TextButton = WindowButton.LeftResizeGrip
            local RightResizeGrip: TextButton = WindowButton.RightResizeGrip
            local LeftResizeBorder: Frame = WindowButton.LeftResizeBorder
            local RightResizeBorder: Frame = WindowButton.RightResizeBorder
            local TopResizeBorder: Frame = WindowButton.TopResizeBorder
            local BottomResizeBorder: Frame = WindowButton.BottomResizeBorder

            if btest(WindowFlags.NoResize, thisWidget.arguments.Flags) ~= true then
                LeftResizeGrip.Visible = true
                RightResizeGrip.Visible = true
                LeftResizeBorder.Visible = true
                RightResizeBorder.Visible = true
                TopResizeBorder.Visible = true
                BottomResizeBorder.Visible = true
            else
                LeftResizeGrip.Visible = false
                RightResizeGrip.Visible = false
                LeftResizeBorder.Visible = false
                RightResizeBorder.Visible = false
                TopResizeBorder.Visible = false
                BottomResizeBorder.Visible = false
            end
            if btest(WindowFlags.NoScrollbar, thisWidget.arguments.Flags) then
                ChildContainer.ScrollBarThickness = 0
            else
                ChildContainer.ScrollBarThickness = Internal._config.ScrollbarSize
            end
            if btest(WindowFlags.NoTitleBar, thisWidget.arguments.Flags) then
                TitleBar.Visible = false
            else
                TitleBar.Visible = true
            end
            if MenuBar then
                if btest(WindowFlags.NoMenu, thisWidget.arguments.Flags) then
                    MenuBar.Visible = false
                else
                    MenuBar.Visible = true
                end
            end
            if btest(WindowFlags.NoBackground, thisWidget.arguments.Flags) then
                ChildContainer.BackgroundTransparency = 1
            else
                ChildContainer.BackgroundTransparency = Internal._config.WindowBgTransparency
            end

            -- TitleBar buttons
            if btest(WindowFlags.NoCollapse, thisWidget.arguments.Flags) then
                TitleBar.CollapseButton.Visible = false
            else
                TitleBar.CollapseButton.Visible = true
            end
            if btest(WindowFlags.NoClose, thisWidget.arguments.Flags) then
                TitleBar.CloseButton.Visible = false
            else
                TitleBar.CloseButton.Visible = true
            end

            Title.Text = thisWidget.arguments.Title or ""
        end,
        UpdateState = function(thisWidget: Window)
            local stateSize = thisWidget.state.size._value
            local statePosition = thisWidget.state.position._value
            local stateOpen = thisWidget.state.open._value
            local stateShown = thisWidget.state.shown._value
            local stateScrollDistance = thisWidget.state.scrollDistance._value

            local Window = thisWidget.instance :: Frame
            local ChildContainer = thisWidget.childContainer :: ScrollingFrame
            local WindowButton = Window.WindowButton :: TextButton
            local Content = WindowButton.Content :: Frame
            local TitleBar = Content.TitleBar :: Frame
            local MenuBar: Frame? = Content:FindFirstChild("Iris_MenuBar")
            local LeftResizeGrip: TextButton = WindowButton.LeftResizeGrip
            local RightResizeGrip: TextButton = WindowButton.RightResizeGrip
            local LeftResizeBorder: Frame = WindowButton.LeftResizeBorder
            local RightResizeBorder: Frame = WindowButton.RightResizeBorder
            local TopResizeBorder: Frame = WindowButton.TopResizeBorder
            local BottomResizeBorder: Frame = WindowButton.BottomResizeBorder

            WindowButton.Size = UDim2.fromOffset(stateSize.X, stateSize.Y)
            WindowButton.Position = UDim2.fromOffset(statePosition.X, statePosition.Y)

            if stateShown then
                if thisWidget._usesScreenGuis then
                    Window.Enabled = true
                    WindowButton.Visible = true
                else
                    Window.Visible = true
                    WindowButton.Visible = true
                end
            else
                if thisWidget._usesScreenGuis then
                    Window.Enabled = false
                    WindowButton.Visible = false
                else
                    Window.Visible = false
                    WindowButton.Visible = false
                end
            end

            if stateOpen then
                TitleBar.CollapseButton.Arrow.ImageContent = Utility.ICONS.DOWN_POINTING_TRIANGLE
                if MenuBar then
                    MenuBar.Visible = not btest(WindowFlags.NoMenu, thisWidget.arguments.Flags)
                end
                ChildContainer.Visible = true
                if btest(WindowFlags.NoResize, thisWidget.arguments.Flags) ~= true then
                    LeftResizeGrip.Visible = true
                    RightResizeGrip.Visible = true
                    LeftResizeBorder.Visible = true
                    RightResizeBorder.Visible = true
                    TopResizeBorder.Visible = true
                    BottomResizeBorder.Visible = true
                end
                WindowButton.AutomaticSize = Enum.AutomaticSize.None
            else
                local collapsedHeight: number = TitleBar.AbsoluteSize.Y -- Internal._config.TextSize + Internal._config.FramePadding.Y * 2
                TitleBar.CollapseButton.Arrow.ImageContent = Utility.ICONS.RIGHT_POINTING_TRIANGLE

                if MenuBar then
                    MenuBar.Visible = false
                end
                ChildContainer.Visible = false
                LeftResizeGrip.Visible = false
                RightResizeGrip.Visible = false
                LeftResizeBorder.Visible = false
                RightResizeBorder.Visible = false
                TopResizeBorder.Visible = false
                BottomResizeBorder.Visible = false
                WindowButton.Size = UDim2.fromOffset(stateSize.X, collapsedHeight)
            end

            if stateShown and stateOpen then
                setFocusedWindow(thisWidget)
            else
                TitleBar.BackgroundColor3 = Internal._config.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Internal._config.TitleBgCollapsedTransparency
                WindowButton.UIStroke.Color = Internal._config.BorderColor

                setFocusedWindow(nil)
            end

            -- cant update canvasPosition in this cycle because scrollingframe isint ready to be changed
            if stateScrollDistance and stateScrollDistance ~= 0 then
                local callbackIndex = #Internal._postCycleCallbacks + 1
                local desiredCycleTick = Internal._cycleTick + 1
                Internal._postCycleCallbacks[callbackIndex] = function()
                    if Internal._cycleTick >= desiredCycleTick then
                        if thisWidget._lastCycleTick ~= -1 then
                            ChildContainer.CanvasPosition = Vector2.new(0, stateScrollDistance)
                        end
                        Internal._postCycleCallbacks[callbackIndex] = nil
                    end
                end
            end
        end,
        ChildAdded = function(thisWidget: Window, thisChid: Types.Widget)
            local Window = thisWidget.instance :: Frame
            local WindowButton = Window.WindowButton :: TextButton
            local Content = WindowButton.Content :: Frame
            if thisChid.type == "MenuBar" then
                local ChildContainer = thisWidget.childContainer :: ScrollingFrame
                thisChid.instance.ZIndex = ChildContainer.ZIndex + 1
                thisChid.instance.LayoutOrder = ChildContainer.LayoutOrder - 1
                return Content
            end
            return thisWidget.childContainer
        end,
        Discard = function(thisWidget: Window)
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
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

--[=[
    @within Window
    @tag Widget
    @tag HasChildren
    @tag HasState

    @function Window
    @param title string -- titlebar text of the window
    @param flags WindowFlags? -- optional bit flags, using Iris.WindowFlags, default is 0
    @param size State<Vector>? -- state size of the entire window, default is Vector2.new(400, 300)
    @param position State<Vector2>? -- state position relative to the top-left corner
    @param open State<boolean>? -- state for the entire window visible, or closed with just the titlebar, default is true
    @param shown State<boolean?> -- state to hide the entire widget, default is true
    @param scrollDistance State<number>? -- state vertical scroll distance down the window

    @return Window

    The top-level widget to contain every other widget within. Made of a titlebar, an optional
    menubar, and a content area for widgets. Can be moved and resized across the screen, and
    closed to hide everything except the titlebar.

    Does not contain embedded windows.
]=]
local API_Window = function(title: string, flags: number?, size: Types.APIState<Vector2>?, position: Types.APIState<Vector2>?, open: Types.APIState<boolean>?, shown: Types.APIState<boolean>?, scrollDistance: Types.APIState<number>?)
    return Internal._insert("Window", title, flags or 0, size, position, open, shown, scrollDistance) :: Window
end

--[=[
    @within Iris

    @function SetFocusedWindow
    @param window Window -- the window to focus

    Sets the focused window to the window provided, which brings it to the front and makes it active.
]=]
local API_SetFocusedWindow = setFocusedWindow

--[=[
    @within Window
    @tag Widget

    @function Tooltip
    @param text string -- tooltip text

    @return Tooltip

    Displays a text label next to the cursor

    ```lua
    Iris.Tooltip("My custom tooltip")
    ```

    ![Basic tooltip example](/Iris/assets/api/window/basicTooltip.png)
]=]
local API_Tooltip = function(text: string)
    return Internal._insert("Tooltip", text) :: Tooltip
end

return {
    WindowFlags = WindowFlags,

    API_Window = API_Window,
    API_Tooltip = API_Tooltip,
    API_SetFocusedWindow = API_SetFocusedWindow,
}
