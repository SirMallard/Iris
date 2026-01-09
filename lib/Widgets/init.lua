--!strict

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Internal)

local Utility = {}

Utility.GuiService = game:GetService("GuiService")
Utility.RunService = game:GetService("RunService")
Utility.UserInputService = game:GetService("UserInputService")
Utility.ContextActionService = game:GetService("ContextActionService")
Utility.TextService = game:GetService("TextService")

Utility.IS_STUDIO = Utility.RunService:IsStudio()

Utility.abstractButton = {} :: Types.WidgetClass
Utility.guiOffset = if Internal._config.IgnoreGuiInset then -Utility.GuiService:GetGuiInset() else Vector2.zero -- acts as an offset where the absolute position of the base frame is not zero, such as IgnoreGuiInset or for stories
Utility.mouseOffset = if Internal._config.IgnoreGuiInset then Vector2.zero else Utility.GuiService:GetGuiInset() -- the registered mouse position always ignores the topbar, so needs a separate variable offset

---------------
-- Functions
---------------

function Utility.setupOffsets()
    -- the topbar inset changes updates a frame later.
    local connection: RBXScriptConnection
    connection = Utility.GuiService:GetPropertyChangedSignal("TopbarInset"):Once(function()
        Utility.mouseOffset = if Internal._config.IgnoreGuiInset then Vector2.zero else Utility.GuiService:GetGuiInset()
        Utility.guiOffset = if Internal._config.IgnoreGuiInset then -Utility.GuiService:GetGuiInset() else Vector2.zero
        connection:Disconnect()
    end)

    -- in case the topbar doesn't change, we cancel the event.
    task.delay(5, function()
        connection:Disconnect()
    end)
end

function Utility.getTime(): number
    -- time() always returns 0 in the context of plugins
    if Utility.IS_STUDIO then
        return os.clock()
    else
        return time()
    end
end

function Utility.getMouseLocation()
    return Utility.UserInputService:GetMouseLocation() - Utility.mouseOffset
end

function Utility.isPosInsideRect(pos: Vector2, rectMin: Vector2, rectMax: Vector2)
    return pos.X >= rectMin.X and pos.X <= rectMax.X and pos.Y >= rectMin.Y and pos.Y <= rectMax.Y
end

function Utility.findBestWindowPosForPopup(refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2)
    local CURSOR_OFFSET_DIST = 20

    if refPos.X + size.X + CURSOR_OFFSET_DIST > outerMax.X then
        if refPos.Y + size.Y + CURSOR_OFFSET_DIST > outerMax.Y then
            -- placed to the top
            refPos += Vector2.new(0, -(CURSOR_OFFSET_DIST + size.Y))
        else
            -- placed to the bottom
            refPos += Vector2.new(0, CURSOR_OFFSET_DIST)
        end
    else
        -- placed to the right
        refPos += Vector2.new(CURSOR_OFFSET_DIST)
    end

    return Vector2.new(math.max(math.min(refPos.X + size.X, outerMax.X) - size.X, outerMin.X), math.max(math.min(refPos.Y + size.Y, outerMax.Y) - size.Y, outerMin.Y))
end

function Utility.getScreenSizeForWindow(thisWidget: Types.Widget) -- possible parents are GuiBase2d, CoreGui, PlayerGui
    if thisWidget.instance:IsA("GuiBase2d") then
        return thisWidget.instance.AbsoluteSize
    else
        local rootParent = thisWidget.instance.Parent
        if rootParent:IsA("GuiBase2d") then
            return rootParent.AbsoluteSize
        else
            if rootParent.Parent:IsA("GuiBase2d") then
                return rootParent.AbsoluteSize
            else
                return workspace.CurrentCamera.ViewportSize
            end
        end
    end
end

function Utility.extend(superClass: Types.WidgetClass, subClass: Types.WidgetClass): Types.WidgetClass
    local newClass = table.clone(superClass)
    for index, value in subClass do
        newClass[index] = value
    end
    return newClass
end

function Utility.UIPadding(parent: GuiObject, padding: Vector2)
    local UIPaddingInstance = Instance.new("UIPadding")
    UIPaddingInstance.PaddingLeft = UDim.new(0, padding.X)
    UIPaddingInstance.PaddingRight = UDim.new(0, padding.X)
    UIPaddingInstance.PaddingTop = UDim.new(0, padding.Y)
    UIPaddingInstance.PaddingBottom = UDim.new(0, padding.Y)
    UIPaddingInstance.Parent = parent
    return UIPaddingInstance
end

function Utility.UIListLayout(parent: GuiObject, fillDirection: Enum.FillDirection, padding: UDim)
    local UIListLayoutInstance = Instance.new("UIListLayout")
    UIListLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayoutInstance.Padding = padding
    UIListLayoutInstance.FillDirection = fillDirection
    UIListLayoutInstance.Parent = parent
    return UIListLayoutInstance
end

function Utility.UIStroke(parent: GuiObject, thickness: number, color: Color3, transparency: number)
    local UIStrokeInstance = Instance.new("UIStroke")
    UIStrokeInstance.Thickness = thickness
    UIStrokeInstance.Color = color
    UIStrokeInstance.Transparency = transparency
    UIStrokeInstance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStrokeInstance.LineJoinMode = Enum.LineJoinMode.Round
    UIStrokeInstance.Parent = parent
    return UIStrokeInstance
end

function Utility.UICorner(parent: GuiObject, rounding: number?)
    local UICornerInstance = Instance.new("UICorner")
    UICornerInstance.CornerRadius = UDim.new(rounding and 0 or 1, rounding or 0)
    UICornerInstance.Parent = parent
    return UICornerInstance
end

function Utility.UISizeConstraint(parent: GuiObject, minSize: Vector2?, maxSize: Vector2?)
    local UISizeConstraintInstance = Instance.new("UISizeConstraint")
    UISizeConstraintInstance.MinSize = minSize or UISizeConstraintInstance.MinSize -- made these optional
    UISizeConstraintInstance.MaxSize = maxSize or UISizeConstraintInstance.MaxSize
    UISizeConstraintInstance.Parent = parent
    return UISizeConstraintInstance
end

-- below uses Internal

function Utility.applyTextStyle(thisInstance: TextLabel | TextButton | TextBox)
    local guiObject = thisInstance :: any
    guiObject.FontFace = Internal._config.TextFont
    guiObject.TextSize = Internal._config.TextSize
    guiObject.TextColor3 = Internal._config.TextColor
    guiObject.TextTransparency = Internal._config.TextTransparency
    guiObject.TextXAlignment = Enum.TextXAlignment.Left
    guiObject.TextYAlignment = Enum.TextYAlignment.Center
    guiObject.RichText = Internal._config.RichText
    guiObject.TextWrapped = Internal._config.TextWrapped

    guiObject.AutoLocalize = false
end

function Utility.applyInteractionHighlights(property: "Background" | "Image", button: GuiButton, highlightee: GuiObject, colors: { [string]: any })
    local exitedButton = false
    local guiObject = highlightee :: any
    Utility.applyMouseEnter(button, function()
        guiObject[property .. "Color3"] = colors.HoveredColor
        guiObject[property .. "Transparency"] = colors.HoveredTransparency

        exitedButton = false
    end)

    Utility.applyMouseLeave(button, function()
        guiObject[property .. "Color3"] = colors.Color
        guiObject[property .. "Transparency"] = colors.Transparency

        exitedButton = true
    end)

    Utility.applyInputBegan(button, function(input: InputObject)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        guiObject[property .. "Color3"] = colors.ActiveColor
        guiObject[property .. "Transparency"] = colors.ActiveTransparency
    end)

    Utility.applyInputEnded(button, function(input: InputObject)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            guiObject[property .. "Color3"] = colors.HoveredColor
            guiObject[property .. "Transparency"] = colors.HoveredTransparency
        end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            guiObject[property .. "Color3"] = colors.Color
            guiObject[property .. "Transparency"] = colors.Transparency
        end
    end)

    button.SelectionImageObject = Internal._selectionImageObject :: Frame
end

function Utility.applyInteractionHighlightsWithMultiHighlightee(property: "Background" | "Image", button: GuiButton, highlightees: { { GuiObject | { [string]: Color3 | number } } })
    local exitedButton = false
    local guiObjects = highlightees :: any
    Utility.applyMouseEnter(button, function()
        for _, highlightee in guiObjects do
            highlightee[1][property .. "Color3"] = highlightee[2].HoveredColor
            highlightee[1][property .. "Transparency"] = highlightee[2].HoveredTransparency

            exitedButton = false
        end
    end)

    Utility.applyMouseLeave(button, function()
        for _, highlightee in guiObjects do
            highlightee[1][property .. "Color3"] = highlightee[2].Color
            highlightee[1][property .. "Transparency"] = highlightee[2].Transparency

            exitedButton = true
        end
    end)

    Utility.applyInputBegan(button, function(input: InputObject)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        for _, highlightee in guiObjects do
            highlightee[1][property .. "Color3"] = highlightee[2].ActiveColor
            highlightee[1][property .. "Transparency"] = highlightee[2].ActiveTransparency
        end
    end)

    Utility.applyInputEnded(button, function(input: InputObject)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
            return
        end
        for _, highlightee in guiObjects do
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                highlightee[1][property .. "Color3"] = highlightee[2].HoveredColor
                highlightee[1][property .. "Transparency"] = highlightee[2].HoveredTransparency
            end
            if input.UserInputType == Enum.UserInputType.Gamepad1 then
                highlightee[1][property .. "Color3"] = highlightee[2].Color
                highlightee[1][property .. "Transparency"] = highlightee[2].Transparency
            end
        end
    end)

    button.SelectionImageObject = Internal._selectionImageObject :: Frame
end

function Utility.applyFrameStyle(thisInstance: GuiObject, noPadding: boolean?, noCorner: boolean?)
    -- padding, border, and rounding optimized to only use what instances are needed, based on style
    local FrameBorderSize = Internal._config.FrameBorderSize
    local FrameRounding = Internal._config.FrameRounding
    thisInstance.BorderSizePixel = 0

    if FrameBorderSize > 0 then
        Utility.UIStroke(thisInstance, FrameBorderSize, Internal._config.BorderColor, Internal._config.BorderTransparency)
    end
    if FrameRounding > 0 and not noCorner then
        Utility.UICorner(thisInstance, FrameRounding)
    end
    if not noPadding then
        Utility.UIPadding(thisInstance, Internal._config.FramePadding)
    end
end

function Utility.applyButtonClick(thisInstance: GuiButton, callback: () -> ())
    thisInstance.MouseButton1Click:Connect(function()
        callback()
    end)
end

function Utility.applyButtonDown(thisInstance: GuiButton, callback: (x: number, y: number) -> ())
    thisInstance.MouseButton1Down:Connect(function(x: number, y: number)
        local position = Vector2.new(x, y) - Utility.mouseOffset
        callback(position.X, position.Y)
    end)
end

function Utility.applyMouseEnter(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
    thisInstance.MouseEnter:Connect(function(x: number, y: number)
        local position = Vector2.new(x, y) - Utility.mouseOffset
        callback(position.X, position.Y)
    end)
end

function Utility.applyMouseMoved(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
    thisInstance.MouseMoved:Connect(function(x: number, y: number)
        local position = Vector2.new(x, y) - Utility.mouseOffset
        callback(position.X, position.Y)
    end)
end

function Utility.applyMouseLeave(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
    thisInstance.MouseLeave:Connect(function(x: number, y: number)
        local position = Vector2.new(x, y) - Utility.mouseOffset
        callback(position.X, position.Y)
    end)
end

function Utility.applyInputBegan(thisInstance: GuiButton, callback: (input: InputObject) -> ())
    thisInstance.InputBegan:Connect(function(...)
        callback(...)
    end)
end

function Utility.applyInputEnded(thisInstance: GuiButton, callback: (input: InputObject) -> ())
    thisInstance.InputEnded:Connect(function(...)
        callback(...)
    end)
end

function Utility.discardState(thisWidget: Types.StateWidget)
    for _, state in thisWidget.state do
        state._connectedWidgets[thisWidget.ID] = nil
    end
end

function Utility.registerEvent(event: string, callback: (...any) -> ())
    table.insert(Internal._initFunctions, function()
        table.insert(Internal._connections, Utility.UserInputService[event]:Connect(callback))
    end)
end

Utility.ICONS = {
    BLANK_SQUARE = Content.fromAssetId(83265623867126),
    RIGHT_POINTING_TRIANGLE = Content.fromAssetId(105541346271951),
    DOWN_POINTING_TRIANGLE = Content.fromAssetId(95465797476827),
    MULTIPLICATION_SIGN = Content.fromAssetId(133890060015237), -- best approximation for a close X which roblox supports, needs to be scaled about 2x
    BOTTOM_RIGHT_CORNER = Content.fromAssetId(125737344915000), -- used in window resize icon in bottom right
    CHECKMARK = Content.fromAssetId(109638815494221),
    BORDER = Content.fromAssetId(133803690460269),
    ALPHA_BACKGROUND_TEXTURE = Content.fromAssetId(114090016039876), -- used for color4 alpha
    UNKNOWN_TEXTURE = Content.fromAssetId(95045813476061),
}

Utility.EVENTS = {
    hover = function(pathToHovered: (thisWidget: Types.Widget) -> GuiObject)
        return {
            ["Init"] = function(thisWidget: Types.Widget & Types.Hovered)
                local hoveredGuiObject = pathToHovered(thisWidget)
                Utility.applyMouseEnter(hoveredGuiObject, function()
                    thisWidget._isHoveredEvent = true
                end)
                Utility.applyMouseLeave(hoveredGuiObject, function()
                    thisWidget._isHoveredEvent = false
                end)
                thisWidget._isHoveredEvent = false
            end,
            ["Get"] = function(thisWidget: Types.Widget & Types.Hovered)
                return thisWidget._isHoveredEvent
            end,
        }
    end,

    open = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.open:changed() and thisWidget.state.open._value
        end,
    },

    close = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.open:changed() and not thisWidget.state.open._value
        end,
    },

    show = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.shown:changed() and thisWidget.state.shown._value
        end,
    },

    hide = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.shown:changed() and not thisWidget.state.shown._value
        end,
    },

    check = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.check:changed() and thisWidget.state.check._value
        end,
    },

    uncheck = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget)
            return thisWidget.state.check:changed() and not thisWidget.state.check._value
        end,
    },

    select = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget & Types.Active)
            return thisWidget.state.index:changed() and thisWidget.active()
        end,
    },

    unselect = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.StateWidget & Types.Active)
            return thisWidget.state.index:changed() and not thisWidget.active()
        end,
    },

    change = function(name: string)
        return {
            ["Init"] = function(_thisWidget: Types.Widget) end,
            ["Get"] = function(thisWidget: Types.StateWidget & Types.Active)
                return thisWidget.state[name]:changed()
            end,
        }
    end,

    click = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
        return {
            ["Init"] = function(thisWidget: Types.Widget & Types.Clicked)
                local clickedGuiObject = pathToClicked(thisWidget)
                thisWidget._lastClickedTick = -1

                Utility.applyButtonClick(clickedGuiObject, function()
                    thisWidget._lastClickedTick = Internal._cycleTick + 1
                end)
            end,
            ["Get"] = function(thisWidget: Types.Widget & Types.Clicked)
                return thisWidget._lastClickedTick == Internal._cycleTick
            end,
        }
    end,

    rightClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
        return {
            ["Init"] = function(thisWidget: Types.Widget & Types.RightClicked)
                local clickedGuiObject = pathToClicked(thisWidget)
                thisWidget._lastRightClickedTick = -1

                clickedGuiObject.MouseButton2Click:Connect(function()
                    thisWidget._lastRightClickedTick = Internal._cycleTick + 1
                end)
            end,
            ["Get"] = function(thisWidget: Types.Widget & Types.RightClicked)
                return thisWidget._lastRightClickedTick == Internal._cycleTick
            end,
        }
    end,

    doubleClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
        return {
            ["Init"] = function(thisWidget: Types.Widget & Types.DoubleClicked)
                local clickedGuiObject = pathToClicked(thisWidget)
                thisWidget._lastClickedTime = -1
                thisWidget._lastClickedPosition = Vector2.zero
                thisWidget._lastDoubleClickedTick = -1

                Utility.applyButtonDown(clickedGuiObject, function(x: number, y: number)
                    local currentTime = Utility.getTime()
                    local isTimeValid = currentTime - thisWidget._lastClickedTime < Internal._config.MouseDoubleClickTime
                    if isTimeValid and (Vector2.new(x, y) - thisWidget._lastClickedPosition).Magnitude < Internal._config.MouseDoubleClickMaxDist then
                        thisWidget._lastDoubleClickedTick = Internal._cycleTick + 1
                    else
                        thisWidget._lastClickedTime = currentTime
                        thisWidget._lastClickedPosition = Vector2.new(x, y)
                    end
                end)
            end,
            ["Get"] = function(thisWidget: Types.Widget & Types.DoubleClicked)
                return thisWidget._lastDoubleClickedTick == Internal._cycleTick
            end,
        }
    end,

    ctrlClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
        return {
            ["Init"] = function(thisWidget: Types.Widget & Types.CtrlClicked)
                local clickedGuiObject = pathToClicked(thisWidget)
                thisWidget._lastCtrlClickedTick = -1

                Utility.applyButtonClick(clickedGuiObject, function()
                    if Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                        thisWidget._lastCtrlClickedTick = Internal._cycleTick + 1
                    end
                end)
            end,
            ["Get"] = function(thisWidget: Types.Widget & Types.CtrlClicked)
                return thisWidget._lastCtrlClickedTick == Internal._cycleTick
            end,
        }
    end,
}

Utility.setupOffsets()

return Utility
