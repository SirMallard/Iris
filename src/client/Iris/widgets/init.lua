local widgets = {}

return function(Iris)

    widgets.GuiService = game:GetService("GuiService")
    widgets.UserInputService = game:GetService("UserInputService")

    widgets.ICONS = {
        RIGHT_POINTING_TRIANGLE = "\u{25BA}",
        DOWN_POINTING_TRIANGLE = "\u{25BC}",
        MULTIPLICATION_SIGN = "\u{00D7}", -- best approximation for a close X which roblox supports, needs to be scaled about 2x
        BOTTOM_RIGHT_CORNER = "\u{25E2}", -- used in window resize icon in bottom right
        CHECK_MARK = "\u{2713}" -- curved shape, closest we can get to ImGui Checkmarks
    }

    function widgets.findBestWindowPosForPopup(refPos, size, outerMin, outerMax)
        local CURSOR_OFFSET_DIST = 20
        
        if refPos.X + size.X + CURSOR_OFFSET_DIST > outerMax.X then
            if refPos.Y + size.Y + CURSOR_OFFSET_DIST > outerMax.Y then
                -- placed to the top
                refPos += Vector2.new(0, - (CURSOR_OFFSET_DIST + size.Y))
            else
                -- placed to the bottom
                refPos += Vector2.new(0, CURSOR_OFFSET_DIST)
            end
        else
            -- placed to the right
            refPos += Vector2.new(CURSOR_OFFSET_DIST, 0)
        end

        local clampedPos = Vector2.new(
            math.max(math.min(refPos.X + size.X, outerMax.X) - size.X, outerMin.X),
            math.max(math.min(refPos.Y + size.Y, outerMax.Y) - size.Y, outerMin.Y)
        )
        return clampedPos
    end

    function widgets.extend(superClass, subClass)
        local newClass = table.clone(superClass)
        for i, v in subClass do
            newClass[i] = v
        end
        return newClass
    end

    function widgets.UIPadding(Parent, PxPadding)
        local UIPaddingInstance = Instance.new("UIPadding")
        UIPaddingInstance.PaddingLeft = UDim.new(0, PxPadding.X)
        UIPaddingInstance.PaddingRight = UDim.new(0, PxPadding.X)
        UIPaddingInstance.PaddingTop = UDim.new(0, PxPadding.Y)
        UIPaddingInstance.PaddingBottom = UDim.new(0, PxPadding.Y)
        UIPaddingInstance.Parent = Parent
        return UIPaddingInstance
    end

    function widgets.UIListLayout(Parent, FillDirection, Padding)
        local UIListLayoutInstance = Instance.new("UIListLayout")
        UIListLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayoutInstance.Padding = Padding
        UIListLayoutInstance.FillDirection = FillDirection
        UIListLayoutInstance.Parent = Parent
        return UIListLayoutInstance
    end

    function widgets.UIStroke(Parent, Thickness, Color, Transparency)
        local UIStrokeInstance = Instance.new("UIStroke")
        UIStrokeInstance.Thickness = Thickness
        UIStrokeInstance.Color = Color
        UIStrokeInstance.Transparency = Transparency
        UIStrokeInstance.Parent = Parent
        return UIStrokeInstance
    end

    function widgets.UICorner(Parent, PxRounding)
        local UICornerInstance = Instance.new("UICorner")
        UICornerInstance.CornerRadius = UDim.new(PxRounding ~= nil and 0 or 1, PxRounding or 0)
        UICornerInstance.Parent = Parent
        return UICornerInstance
    end

    function widgets.UISizeConstraint(Parent, MinSize, MaxSize)
        local UISizeConstraintInstance = Instance.new("UISizeConstraint")
        UISizeConstraintInstance.MinSize = MinSize
        UISizeConstraintInstance.MaxSize = MaxSize
        UISizeConstraintInstance.Parent = Parent
        return UISizeConstraintInstance
    end

    -- below uses Iris

    function widgets.applyTextStyle(thisInstance)
        thisInstance.Font = Iris._config.TextFont
        thisInstance.TextSize = Iris._config.TextSize
        thisInstance.TextColor3 = Iris._config.TextColor
        thisInstance.TextTransparency = Iris._config.TextTransparency
        thisInstance.TextXAlignment = Enum.TextXAlignment.Left

        thisInstance.AutoLocalize = false
        thisInstance.RichText = false
    end

    function widgets.applyInteractionHighlights(Button, Highlightee, Colors)
        local exitedButton = false
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

        Button.InputBegan:Connect(function(input)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
            Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
        end)

        Button.InputEnded:Connect(function(input)
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

    function widgets.applyTextInteractionHighlights(Button, Highlightee, Colors)
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

        Button.InputBegan:Connect(function(input)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                return
            end
            Highlightee.TextColor3 = Colors.ButtonActiveColor
            Highlightee.TextTransparency = Colors.ButtonActiveTransparency
        end)

        Button.InputEnded:Connect(function(input)
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

    function widgets.applyFrameStyle(thisInstance, forceNoPadding, doubleyNoPadding)
        -- padding, border, and rounding
        -- optimized to only use what instances are needed, based on style
        local FramePadding = Iris._config.FramePadding
        local FrameBorderTransparency = Iris._config.ButtonTransparency
        local FrameBorderSize = Iris._config.FrameBorderSize
        local FrameBorderColor = Iris._config.BorderColor
        local FrameRounding = Iris._config.FrameRounding
        
        if FrameBorderSize > 0 and FrameRounding > 0 then
            thisInstance.BorderSizePixel = 0

            local uiStroke = Instance.new("UIStroke")
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

    widgets.EVENTS = {
        hover = function(pathToHovered)
            return {
                ["Init"] = function(thisWidget)
                    local hoveredGuiObject = pathToHovered(thisWidget)
                    hoveredGuiObject.MouseEnter:Connect(function()
                        thisWidget.isHoveredEvent = true
                    end)
                    hoveredGuiObject.MouseLeave:Connect(function()
                        thisWidget.isHoveredEvent = false
                    end)
                    thisWidget.isHoveredEvent = false
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.isHoveredEvent
                end
            }
        end,

        click = function(pathToClicked)
            return {
                ["Init"] = function(thisWidget)
                    local clickedGuiObject = pathToClicked(thisWidget)
                    thisWidget.lastClickedTick = -1

                    clickedGuiObject.MouseButton1Click:Connect(function()
                        thisWidget.lastClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastClickedTick == Iris._cycleTick
                end
            }
        end,

        rightClick = function(pathToClicked)
            return {
                ["Init"] = function(thisWidget)
                    local clickedGuiObject = pathToClicked(thisWidget)
                    thisWidget.lastRightClickedTick = -1

                    clickedGuiObject.MouseButton2Click:Connect(function()
                        thisWidget.lastRightClickedTick = Iris._cycleTick + 1
                    end)
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastRightClickedTick == Iris._cycleTick
                end
            }
        end,

        doubleClick = function(pathToClicked)
            return {
                ["Init"] = function(thisWidget)
                    local clickedGuiObject = pathToClicked(thisWidget)
                    thisWidget.lastClickedTime = -1
                    thisWidget.lastClickedPosition = Vector2.zero
                    thisWidget.lastDoubleClickedTick = -1

                    clickedGuiObject.MouseButton1Down:Connect(function(x, y)
                        local currentTime = time()
                        local isTimeValid = currentTime - thisWidget.lastClickedTime < Iris._config.MouseDoubleClickTime
                        if isTimeValid and (Vector2.new(x, y) - thisWidget.lastClickedPosition).Magnitude < Iris._config.MouseDoubleClickMaxDist then
                            thisWidget.lastDoubleClickedTick = Iris._cycleTick + 1
                        else
                            thisWidget.lastClickedTime = currentTime
                            thisWidget.lastClickedPosition = Vector2.new(x, y)
                        end
                    end)
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastDoubleClickedTick == Iris._cycleTick
                end
            }
        end,

        ctrlClick = function(pathToClicked)
            return {
                ["Init"] = function(thisWidget)
                    local clickedGuiObject = pathToClicked(thisWidget)
                    thisWidget.lastCtrlClickedTick = -1

                    clickedGuiObject.MouseButton1Click:Connect(function()
                        if widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                            thisWidget.lastCtrlClickedTick = Iris._cycleTick + 1
                        end
                    end)
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastCtrlClickedTick == Iris._cycleTick
                end
            }
        end
    }

    function widgets.discardState(thisWidget)
        for _, state in thisWidget.state do
            state.ConnectedWidgets[thisWidget.ID] = nil
        end
    end

    require(script.Root)       (Iris, widgets)
    require(script.Text)       (Iris, widgets)
    require(script.Button)     (Iris, widgets)
    require(script.Format)     (Iris, widgets)
    require(script.Checkbox)   (Iris, widgets)
    require(script.RadioButton)(Iris, widgets)
    require(script.Tree)       (Iris, widgets)
    require(script.Input)      (Iris, widgets)
    require(script.Combo)      (Iris, widgets)
    require(script.Table)      (Iris, widgets)
    require(script.Window)     (Iris, widgets)
end