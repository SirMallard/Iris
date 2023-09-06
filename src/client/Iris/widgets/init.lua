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
        BOTTOM_RIGHT_CORNER = "\u{25E2}", -- used in window resize icon in bottom right
        CHECK_MARK = "rbxasset://textures/AnimationEditor/icon_checkmark.png",
        ALPHA_BACKGROUND_TEXTURE = "rbxasset://textures/meshPartFallback.png", -- used for color4 alpha
    }

    widgets.GuiInset = widgets.GuiService:GetGuiInset()

    widgets.IS_STUDIO = widgets.RunService:IsStudio()
    function widgets.getTime()
        -- time() always returns 0 in the context of plugins
        if widgets.IS_STUDIO then
            return os.clock()
        else
            return time()
        end
    end

    function widgets.getMouseLocation(): Vector2
        return widgets.UserInputService:GetMouseLocation() - widgets.GuiInset
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
            refPos += Vector2.new(CURSOR_OFFSET_DIST, 0)
        end

        local clampedPos: Vector2 = Vector2.new(math.max(math.min(refPos.X + size.X, outerMax.X) - size.X, outerMin.X), math.max(math.min(refPos.Y + size.Y, outerMax.Y) - size.Y, outerMin.Y))
        return clampedPos
    end

    function widgets.isPosInsideRect(pos: Vector2, rectMin: Vector2, rectMax: Vector2): boolean
        return pos.X > rectMin.X and pos.X < rectMax.X and pos.Y > rectMin.Y and pos.Y < rectMax.Y
    end

    function widgets.extend(superClass: Types.WidgetClass, subClass: Types.WidgetClass): Types.WidgetClass
        local newClass: Types.WidgetClass = table.clone(superClass)
        for index: string, value: any in subClass do
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

    function widgets.UIReference(Parent: GuiObject, Child: GuiObject, Name: string): ObjectValue
        local ObjectValue: ObjectValue = Instance.new("ObjectValue")
        ObjectValue.Name = Name
        ObjectValue.Value = Child
        ObjectValue.Parent = Parent

        return ObjectValue
    end

    function widgets.getScreenSizeForWindow(thisWidget: Types.Widget): Vector2 -- possible parents are GuiBase2d, CoreGui, PlayerGui
        local size: Vector2
        if thisWidget.usesScreenGUI then
            size = thisWidget.Instance.AbsoluteSize
        else
            local rootParent = thisWidget.Instance.Parent
            if rootParent:IsA("GuiBase2d") then
                size = rootParent.AbsoluteSize
            else
                if rootParent.Parent:IsA("GuiBase2d") then
                    size = rootParent.AbsoluteSize
                else
                    size = workspace.CurrentCamera.ViewportSize
                end
            end
        end
        return size
    end

    -- below uses Iris

    local textParams: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
    textParams.Font = Iris._config.TextFont
    textParams.Size = Iris._config.TextSize
    textParams.Width = math.huge
    function widgets.calculateTextSize(text: string, width: number?): Vector2
        if width then
            textParams.Width = width
        end
        textParams.Text = text

        local size: Vector2 = widgets.TextService:GetTextBoundsAsync(textParams)

        if width then
            textParams.Width = math.huge
        end

        return size
    end

    function widgets.applyTextStyle(thisInstance: TextLabel & TextButton & TextBox)
        thisInstance.FontFace = Iris._config.TextFont
        thisInstance.TextSize = Iris._config.TextSize
        thisInstance.TextColor3 = Iris._config.TextColor
        thisInstance.TextTransparency = Iris._config.TextTransparency
        thisInstance.TextXAlignment = Enum.TextXAlignment.Left

        thisInstance.AutoLocalize = false
        thisInstance.RichText = false
    end

    function widgets.applyInteractionHighlights(Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any })
        local exitedButton: boolean = false
        Button.MouseEnter:Connect(function()
            Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
            Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency

            exitedButton = false
        end)

        Button.MouseLeave:Connect(function()
            Highlightee.BackgroundColor3 = Colors.ButtonColor
            Highlightee.BackgroundTransparency = Colors.ButtonTransparency

            exitedButton = true
        end)

        Button.InputBegan:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
            Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
        end)

        Button.InputEnded:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
                Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
            end
            if input.UserInputType == Enum.UserInputType.Gamepad1 then
                Highlightee.BackgroundColor3 = Colors.ButtonColor
                Highlightee.BackgroundTransparency = Colors.ButtonTransparency
            end
        end)

        Button.SelectionImageObject = Iris.SelectionImageObject
    end

    function widgets.applyInteractionHighlightsWithMultiHighlightee(Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number } } })
        local exitedButton: boolean = false
        Button.MouseEnter:Connect(function()
            for _, Highlightee in Highlightees do
                Highlightee[1].BackgroundColor3 = Highlightee[2].ButtonHoveredColor
                Highlightee[1].BackgroundTransparency = Highlightee[2].ButtonHoveredTransparency

                exitedButton = false
            end
        end)

        Button.MouseLeave:Connect(function()
            for _, Highlightee in Highlightees do
                Highlightee[1].BackgroundColor3 = Highlightee[2].ButtonColor
                Highlightee[1].BackgroundTransparency = Highlightee[2].ButtonTransparency

                exitedButton = true
            end
        end)

        Button.InputBegan:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            for _, Highlightee in Highlightees do
                Highlightee[1].BackgroundColor3 = Highlightee[2].ButtonActiveColor
                Highlightee[1].BackgroundTransparency = Highlightee[2].ButtonActiveTransparency
            end
        end)

        Button.InputEnded:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
                return
            end
            for _, Highlightee in Highlightees do
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Highlightee[1].BackgroundColor3 = Highlightee[2].ButtonHoveredColor
                    Highlightee[1].BackgroundTransparency = Highlightee[2].ButtonHoveredTransparency
                end
                if input.UserInputType == Enum.UserInputType.Gamepad1 then
                    Highlightee[1].BackgroundColor3 = Highlightee[2].ButtonColor
                    Highlightee[1].BackgroundTransparency = Highlightee[2].ButtonTransparency
                end
            end
        end)

        Button.SelectionImageObject = Iris.SelectionImageObject
    end

    function widgets.applyTextInteractionHighlights(Button: GuiButton, Highlightee: TextLabel & TextButton & TextBox, Colors: { [string]: any })
        local exitedButton = false
        Button.MouseEnter:Connect(function()
            Highlightee.TextColor3 = Colors.ButtonHoveredColor
            Highlightee.TextTransparency = Colors.ButtonHoveredTransparency

            exitedButton = false
        end)

        Button.MouseLeave:Connect(function()
            Highlightee.TextColor3 = Colors.ButtonColor
            Highlightee.TextTransparency = Colors.ButtonTransparency

            exitedButton = true
        end)

        Button.InputBegan:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            Highlightee.TextColor3 = Colors.ButtonActiveColor
            Highlightee.TextTransparency = Colors.ButtonActiveTransparency
        end)

        Button.InputEnded:Connect(function(input: InputObject)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Highlightee.TextColor3 = Colors.ButtonHoveredColor
                Highlightee.TextTransparency = Colors.ButtonHoveredTransparency
            end
            if input.UserInputType == Enum.UserInputType.Gamepad1 then
                Highlightee.TextColor3 = Colors.ButtonColor
                Highlightee.TextTransparency = Colors.ButtonTransparency
            end
        end)

        Button.SelectionImageObject = Iris.SelectionImageObject
    end

    function widgets.applyFrameStyle(thisInstance: GuiObject, forceNoPadding: boolean?, doubleyNoPadding: boolean?)
        -- padding, border, and rounding
        -- optimized to only use what instances are needed, based on style
        local FramePadding: Vector2 = Iris._config.FramePadding
        local FrameBorderSize: number = Iris._config.FrameBorderSize
        local FrameBorderColor: Color3 = Iris._config.BorderColor
        local FrameBorderTransparency: number = Iris._config.ButtonTransparency
        local FrameRounding: number = Iris._config.FrameRounding

        if FrameBorderSize > 0 and FrameRounding > 0 then
            thisInstance.BorderSizePixel = 0

            local uiStroke: UIStroke = Instance.new("UIStroke")
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.LineJoinMode = Enum.LineJoinMode.Round
            uiStroke.Transparency = FrameBorderTransparency
            uiStroke.Thickness = FrameBorderSize
            uiStroke.Color = FrameBorderColor

            widgets.UICorner(thisInstance, FrameRounding)
            uiStroke.Parent = thisInstance

            if not forceNoPadding then
                widgets.UIPadding(thisInstance, Iris._config.FramePadding)
            end
        elseif FrameBorderSize < 1 and FrameRounding > 0 then
            thisInstance.BorderSizePixel = 0

            widgets.UICorner(thisInstance, FrameRounding)
            if not forceNoPadding then
                widgets.UIPadding(thisInstance, Iris._config.FramePadding)
            end
        elseif FrameRounding < 1 then
            thisInstance.BorderSizePixel = FrameBorderSize
            thisInstance.BorderColor3 = FrameBorderColor
            thisInstance.BorderMode = Enum.BorderMode.Inset

            if not forceNoPadding then
                widgets.UIPadding(thisInstance, FramePadding - Vector2.new(FrameBorderSize, FrameBorderSize))
            elseif not doubleyNoPadding then
                widgets.UIPadding(thisInstance, -Vector2.new(FrameBorderSize, FrameBorderSize))
            end
        end
    end

    function widgets.discardState(thisWidget: Types.Widget)
        for _, state: Types.State in thisWidget.state do
            state.ConnectedWidgets[thisWidget.ID] = nil
        end
    end

    widgets.EVENTS = {
        hover = function(pathToHovered: (thisWidget: Types.Widget) -> GuiObject)
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local hoveredGuiObject: GuiObject = pathToHovered(thisWidget)
                    hoveredGuiObject.MouseEnter:Connect(function()
                        thisWidget.isHoveredEvent = true
                    end)
                    hoveredGuiObject.MouseLeave:Connect(function()
                        thisWidget.isHoveredEvent = false
                    end)
                    thisWidget.isHoveredEvent = false
                end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.isHoveredEvent
                end,
            }
        end,

        click = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastClickedTick = -1

                    clickedGuiObject.MouseButton1Click:Connect(function()
                        thisWidget.lastClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastClickedTick == Iris._cycleTick
                end,
            }
        end,

        rightClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastRightClickedTick = -1

                    clickedGuiObject.MouseButton2Click:Connect(function()
                        thisWidget.lastRightClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastRightClickedTick == Iris._cycleTick
                end,
            }
        end,

        doubleClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastClickedTime = -1
                    thisWidget.lastClickedPosition = Vector2.zero
                    thisWidget.lastDoubleClickedTick = -1

                    clickedGuiObject.MouseButton1Down:Connect(function(x: number, y: number)
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
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastDoubleClickedTick == Iris._cycleTick
                end,
            }
        end,

        ctrlClick = function(pathToClicked: (thisWidget: Types.Widget) -> GuiButton)
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local clickedGuiObject: GuiButton = pathToClicked(thisWidget)
                    thisWidget.lastCtrlClickedTick = -1

                    clickedGuiObject.MouseButton1Click:Connect(function()
                        if widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                            thisWidget.lastCtrlClickedTick = Iris._cycleTick + 1
                        end
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastCtrlClickedTick == Iris._cycleTick
                end,
            }
        end,

        shortcut = function(pathToKeys: (thisWidget: Types.Widget) -> (Enum.KeyCode, Enum.ModifierKey))
            return {
                ["Init"] = function(thisWidget: Types.Widget)
                    local keycode: Enum.KeyCode, modifier: Enum.ModifierKey = pathToKeys(thisWidget)
                    thisWidget.lastShortcutTick = -1

                    widgets.ContextActionService:BindAction(thisWidget.ID, function(_, inputState: Enum.UserInputState, inputObject: InputObject)
                        if inputState == Enum.UserInputState.Begin then
                            if inputObject:IsModifierKeyDown(modifier) then
                                thisWidget.lastShortcutTick = Iris._cycleTick + 1
                            end
                        end
                    end, false, keycode)
                end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastShortcutTick == Iris._cycleTick
                end,
            }
        end,
    }

    require(script.Root)(Iris, widgets)
    require(script.Window)(Iris, widgets)

    require(script.Menu)(Iris, widgets)

    require(script.Format)(Iris, widgets)

    require(script.Text)(Iris, widgets)
    require(script.Button)(Iris, widgets)
    require(script.Checkbox)(Iris, widgets)
    require(script.RadioButton)(Iris, widgets)

    require(script.Tree)(Iris, widgets)

    require(script.Input)(Iris, widgets)
    require(script.Combo)(Iris, widgets)

    require(script.Table)(Iris, widgets)
end
