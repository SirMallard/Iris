local Types = require(script.Parent.Types)

local widgets = {} :: Types.WidgetUtility

return function(Iris: Types.Internal)
    widgets.GuiService = game:GetService("GuiService")
    widgets.RunService = game:GetService("RunService")
    widgets.UserInputService = game:GetService("UserInputService")
    widgets.ContextActionService = game:GetService("ContextActionService")
    widgets.TextService = game:GetService("TextService")

    widgets.ICONS = {
        RIGHT_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_right.png",
        DOWN_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_down.png",
        MULTIPLICATION_SIGN = "rbxasset://textures/AnimationEditor/icon_close.png", -- best approximation for a close X which roblox supports, needs to be scaled about 2x
        BOTTOM_RIGHT_CORNER = "rbxasset://textures/ui/InspectMenu/gr-item-selector-triangle.png", -- used in window resize icon in bottom right
        CHECK_MARK = "rbxasset://textures/AnimationEditor/icon_checkmark.png",
        BORDER = "rbxasset://textures/ui/InspectMenu/gr-item-selector.png",
        ALPHA_BACKGROUND_TEXTURE = "rbxasset://textures/meshPartFallback.png", -- used for color4 alpha
        UNKNOWN_TEXTURE = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    }

    widgets.IS_STUDIO = widgets.RunService:IsStudio()
    function widgets.getTime(): number
        -- time() always returns 0 in the context of plugins
        if widgets.IS_STUDIO then
            return os.clock()
        else
            return time()
        end
    end

    -- acts as an offset where the absolute position of the base frame is not zero, such as IgnoreGuiInset or for stories
    widgets.GuiOffset = if Iris._config.IgnoreGuiInset then -widgets.GuiService:GetGuiInset() else Vector2.zero
    -- the registered mouse position always ignores the topbar, so needs a separate variable offset
    widgets.MouseOffset = if Iris._config.IgnoreGuiInset then Vector2.zero else widgets.GuiService:GetGuiInset()

    -- the topbar inset changes updates a frame later.
    local connection: RBXScriptConnection
    connection = widgets.GuiService:GetPropertyChangedSignal("TopbarInset"):Once(function()
        widgets.MouseOffset = if Iris._config.IgnoreGuiInset then Vector2.zero else widgets.GuiService:GetGuiInset()
        widgets.GuiOffset = if Iris._config.IgnoreGuiInset then -widgets.GuiService:GetGuiInset() else Vector2.zero
        connection:Disconnect()
    end)
    -- in case the topbar doesn't change, we cancel the event.
    task.delay(5, function()
        connection:Disconnect()
    end)

    function widgets.getMouseLocation(): Vector2
        return widgets.UserInputService:GetMouseLocation() - widgets.MouseOffset
    end

    function widgets.isPosInsideRect(pos: Vector2, rectMin: Vector2, rectMax: Vector2): boolean
        return pos.X >= rectMin.X and pos.X <= rectMax.X and pos.Y >= rectMin.Y and pos.Y <= rectMax.Y
    end

    function widgets.findBestWindowPosForPopup(refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2): Vector2
        local CURSOR_OFFSET_DIST: number = 20

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

        local clampedPos: Vector2 = Vector2.new(math.max(math.min(refPos.X + size.X, outerMax.X) - size.X, outerMin.X), math.max(math.min(refPos.Y + size.Y, outerMax.Y) - size.Y, outerMin.Y))
        return clampedPos
    end

    function widgets.getScreenSizeForWindow(thisWidget: Types.Widget): Vector2 -- possible parents are GuiBase2d, CoreGui, PlayerGui
        if thisWidget.Instance:IsA("GuiBase2d") then
            return thisWidget.Instance.AbsoluteSize
        else
            local rootParent = thisWidget.Instance.Parent
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

    function widgets.extend(superClass: Types.WidgetClass, subClass: Types.WidgetClass): Types.WidgetClass
        local newClass: Types.WidgetClass = table.clone(superClass)
        for index: unknown, value: any in subClass do
            newClass[index] = value
        end
        return newClass
    end

    function widgets.UIPadding(Parent: GuiObject, PxPadding: Vector2): UIPadding
        local UIPaddingInstance: UIPadding = Instance.new("UIPadding")
        UIPaddingInstance.PaddingLeft = UDim.new(0, PxPadding.X)
        UIPaddingInstance.PaddingRight = UDim.new(0, PxPadding.X)
        UIPaddingInstance.PaddingTop = UDim.new(0, PxPadding.Y)
        UIPaddingInstance.PaddingBottom = UDim.new(0, PxPadding.Y)
        UIPaddingInstance.Parent = Parent
        return UIPaddingInstance
    end

    function widgets.UIListLayout(Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim): UIListLayout
        local UIListLayoutInstance: UIListLayout = Instance.new("UIListLayout")
        UIListLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayoutInstance.Padding = Padding
        UIListLayoutInstance.FillDirection = FillDirection
        UIListLayoutInstance.Parent = Parent
        return UIListLayoutInstance
    end

    function widgets.UIStroke(Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number): UIStroke
        local UIStrokeInstance: UIStroke = Instance.new("UIStroke")
        UIStrokeInstance.Thickness = Thickness
        UIStrokeInstance.Color = Color
        UIStrokeInstance.Transparency = Transparency
        UIStrokeInstance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStrokeInstance.LineJoinMode = Enum.LineJoinMode.Round
        UIStrokeInstance.Parent = Parent
        return UIStrokeInstance
    end

    function widgets.UICorner(Parent: GuiObject, PxRounding: number?): UICorner
        local UICornerInstance: UICorner = Instance.new("UICorner")
        UICornerInstance.CornerRadius = UDim.new(PxRounding and 0 or 1, PxRounding or 0)
        UICornerInstance.Parent = Parent
        return UICornerInstance
    end

    function widgets.UISizeConstraint(Parent: GuiObject, MinSize: Vector2?, MaxSize: Vector2?): UISizeConstraint
        local UISizeConstraintInstance: UISizeConstraint = Instance.new("UISizeConstraint")
        UISizeConstraintInstance.MinSize = MinSize or UISizeConstraintInstance.MinSize -- made these optional
        UISizeConstraintInstance.MaxSize = MaxSize or UISizeConstraintInstance.MaxSize
        UISizeConstraintInstance.Parent = Parent
        return UISizeConstraintInstance
    end

    -- below uses Iris

    function widgets.applyTextStyle(thisInstance: TextLabel & TextButton & TextBox)
        thisInstance.FontFace = Iris._config.TextFont
        thisInstance.TextSize = Iris._config.TextSize
        thisInstance.TextColor3 = Iris._config.TextColor
        thisInstance.TextTransparency = Iris._config.TextTransparency
        thisInstance.TextXAlignment = Enum.TextXAlignment.Left
        thisInstance.TextYAlignment = Enum.TextYAlignment.Center
        thisInstance.RichText = Iris._config.RichText
        thisInstance.TextWrapped = Iris._config.TextWrapped

        thisInstance.AutoLocalize = false
    end

    function widgets.applyInteractionHighlights(Property: string, Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any })
        local exitedButton: boolean = false
        widgets.applyMouseEnter(Button, function()
            Highlightee[Property .. "Color3"] = Colors.HoveredColor
            Highlightee[Property .. "Transparency"] = Colors.HoveredTransparency

            exitedButton = false
        end)

        widgets.applyMouseLeave(Button, function()
            Highlightee[Property .. "Color3"] = Colors.Color
            Highlightee[Property .. "Transparency"] = Colors.Transparency

            exitedButton = true
        end)

        widgets.applyInputBegan(Button, function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            Highlightee[Property .. "Color3"] = Colors.ActiveColor
            Highlightee[Property .. "Transparency"] = Colors.ActiveTransparency
        end)

        widgets.applyInputEnded(Button, function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Highlightee[Property .. "Color3"] = Colors.HoveredColor
                Highlightee[Property .. "Transparency"] = Colors.HoveredTransparency
            end
            if input.UserInputType == Enum.UserInputType.Gamepad1 then
                Highlightee[Property .. "Color3"] = Colors.Color
                Highlightee[Property .. "Transparency"] = Colors.Transparency
            end
        end)

        Button.SelectionImageObject = Iris.SelectionImageObject
    end

    function widgets.applyInteractionHighlightsWithMultiHighlightee(Property: string, Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number } } })
        local exitedButton: boolean = false
        widgets.applyMouseEnter(Button, function()
            for _, Highlightee in Highlightees do
                Highlightee[1][Property .. "Color3"] = Highlightee[2].HoveredColor
                Highlightee[1][Property .. "Transparency"] = Highlightee[2].HoveredTransparency

                exitedButton = false
            end
        end)

        widgets.applyMouseLeave(Button, function()
            for _, Highlightee in Highlightees do
                Highlightee[1][Property .. "Color3"] = Highlightee[2].Color
                Highlightee[1][Property .. "Transparency"] = Highlightee[2].Transparency

                exitedButton = true
            end
        end)

        widgets.applyInputBegan(Button, function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            for _, Highlightee in Highlightees do
                Highlightee[1][Property .. "Color3"] = Highlightee[2].ActiveColor
                Highlightee[1][Property .. "Transparency"] = Highlightee[2].ActiveTransparency
            end
        end)

        widgets.applyInputEnded(Button, function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
                return
            end
            for _, Highlightee in Highlightees do
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Highlightee[1][Property .. "Color3"] = Highlightee[2].HoveredColor
                    Highlightee[1][Property .. "Transparency"] = Highlightee[2].HoveredTransparency
                end
                if input.UserInputType == Enum.UserInputType.Gamepad1 then
                    Highlightee[1][Property .. "Color3"] = Highlightee[2].Color
                    Highlightee[1][Property .. "Transparency"] = Highlightee[2].Transparency
                end
            end
        end)

        Button.SelectionImageObject = Iris.SelectionImageObject
    end

    function widgets.applyFrameStyle(thisInstance: GuiObject, noPadding: boolean?, noCorner: boolean?)
        -- padding, border, and rounding
        -- optimized to only use what instances are needed, based on style
        local FrameBorderSize: number = Iris._config.FrameBorderSize
        local FrameRounding: number = Iris._config.FrameRounding
        thisInstance.BorderSizePixel = 0

        if FrameBorderSize > 0 then
            widgets.UIStroke(thisInstance, FrameBorderSize, Iris._config.BorderColor, Iris._config.BorderTransparency)
        end
        if FrameRounding > 0 and not noCorner then
            widgets.UICorner(thisInstance, FrameRounding)
        end
        if not noPadding then
            widgets.UIPadding(thisInstance, Iris._config.FramePadding)
        end
    end

    function widgets.applyButtonClick(thisInstance: GuiButton, callback: () -> ())
        thisInstance.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    function widgets.applyButtonDown(thisInstance: GuiButton, callback: (x: number, y: number) -> ())
        thisInstance.MouseButton1Down:Connect(function(x: number, y: number)
            local position: Vector2 = Vector2.new(x, y) - widgets.MouseOffset
            callback(position.X, position.Y)
        end)
    end

    function widgets.applyMouseEnter(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
        thisInstance.MouseEnter:Connect(function(x: number, y: number)
            local position: Vector2 = Vector2.new(x, y) - widgets.MouseOffset
            callback(position.X, position.Y)
        end)
    end

    function widgets.applyMouseMoved(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
        thisInstance.MouseMoved:Connect(function(x: number, y: number)
            local position: Vector2 = Vector2.new(x, y) - widgets.MouseOffset
            callback(position.X, position.Y)
        end)
    end

    function widgets.applyMouseLeave(thisInstance: GuiObject, callback: (x: number, y: number) -> ())
        thisInstance.MouseLeave:Connect(function(x: number, y: number)
            local position: Vector2 = Vector2.new(x, y) - widgets.MouseOffset
            callback(position.X, position.Y)
        end)
    end

    function widgets.applyInputBegan(thisInstance: GuiButton, callback: (input: InputObject) -> ())
        thisInstance.InputBegan:Connect(function(...)
            callback(...)
        end)
    end

    function widgets.applyInputEnded(thisInstance: GuiButton, callback: (input: InputObject) -> ())
        thisInstance.InputEnded:Connect(function(...)
            callback(...)
        end)
    end

    function widgets.discardState(thisWidget: Types.StateWidget)
        for _, state: Types.State<any> in thisWidget.state do
            state.ConnectedWidgets[thisWidget.ID] = nil
        end
    end

    function widgets.registerEvent(event: string, callback: (...any) -> ())
        table.insert(Iris._initFunctions, function()
            table.insert(Iris._connections, widgets.UserInputService[event]:Connect(callback))
        end)
    end

    widgets.EVENTS = {
        hover = function(pathToHovered: (thisWidget: Types.Widget) -> GuiObject)
            return {
                ["Init"] = function(thisWidget: Types.Widget & Types.Hovered)
                    local hoveredGuiObject: GuiObject = pathToHovered(thisWidget)
                    widgets.applyMouseEnter(hoveredGuiObject, function()
                        thisWidget.isHoveredEvent = true
                    end)
                    widgets.applyMouseLeave(hoveredGuiObject, function()
                        thisWidget.isHoveredEvent = false
                    end)
                    thisWidget.isHoveredEvent = false
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.Hovered): boolean
                    return thisWidget.isHoveredEvent
                end,
            }
        end,

        click = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget & Types.Clicked)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastClickedTick = -1

                    widgets.applyButtonClick(clickedGuiObject, function()
                        thisWidget.lastClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.Clicked): boolean
                    return thisWidget.lastClickedTick == Iris._cycleTick
                end,
            }
        end,

        rightClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget & Types.RightClicked)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastRightClickedTick = -1

                    clickedGuiObject.MouseButton2Click:Connect(function()
                        thisWidget.lastRightClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.RightClicked): boolean
                    return thisWidget.lastRightClickedTick == Iris._cycleTick
                end,
            }
        end,

        doubleClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget & Types.DoubleClicked)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastClickedTime = -1
                    thisWidget.lastClickedPosition = Vector2.zero
                    thisWidget.lastDoubleClickedTick = -1

                    widgets.applyButtonDown(clickedGuiObject, function(x: number, y: number)
                        local currentTime: number = widgets.getTime()
                        local isTimeValid: boolean = currentTime - thisWidget.lastClickedTime < Iris._config.MouseDoubleClickTime
                        if isTimeValid and (Vector2.new(x, y) - thisWidget.lastClickedPosition).Magnitude < Iris._config.MouseDoubleClickMaxDist then
                            thisWidget.lastDoubleClickedTick = Iris._cycleTick + 1
                        else
                            thisWidget.lastClickedTime = currentTime
                            thisWidget.lastClickedPosition = Vector2.new(x, y)
                        end
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.DoubleClicked): boolean
                    return thisWidget.lastDoubleClickedTick == Iris._cycleTick
                end,
            }
        end,

        ctrlClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget & Types.CtrlClicked)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastCtrlClickedTick = -1

                    widgets.applyButtonClick(clickedGuiObject, function()
                        if widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                            thisWidget.lastCtrlClickedTick = Iris._cycleTick + 1
                        end
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.CtrlClicked): boolean
                    return thisWidget.lastCtrlClickedTick == Iris._cycleTick
                end,
            }
        end,
    }

    Iris._utility = widgets

    require(script.Root)(Iris, widgets)
    require(script.Window)(Iris, widgets)

    require(script.Menu)(Iris, widgets)

    require(script.Format)(Iris, widgets)

    require(script.Text)(Iris, widgets)
    require(script.Button)(Iris, widgets)
    require(script.Checkbox)(Iris, widgets)
    require(script.RadioButton)(Iris, widgets)
    require(script.Image)(Iris, widgets)

    require(script.Tree)(Iris, widgets)
    require(script.Tab)(Iris, widgets)

    require(script.Input)(Iris, widgets)
    require(script.Combo)(Iris, widgets)
    require(script.Plot)(Iris, widgets)

    require(script.Table)(Iris, widgets)
end
