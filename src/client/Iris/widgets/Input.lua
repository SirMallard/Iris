local UserInputService = game:GetService("UserInputService")
return function(Iris, widgets)

    local numberChanged = {
        ["Init"] = function(thisWidget)

        end,
        ["Get"] = function(thisWidget)
            return thisWidget.lastNumchangeTick == Iris._cycleTick
        end
    }

    local function GenerateRootFrame(thisWidget, name)
        local Frame = Instance.new("Frame")
        Frame.Name = name
        Frame.Size = UDim2.fromScale(1, 0)
        Frame.BackgroundTransparency = 1
        Frame.BorderSizePixel = 0
        Frame.ZIndex = thisWidget.ZIndex
        Frame.LayoutOrder = thisWidget.ZIndex
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        widgets.UIListLayout(Frame, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

        return Frame
    end

    local function GenerateInputField(thisWidget)
        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        widgets.applyFrameStyle(InputField, true)
        widgets.applyTextStyle(InputField)
        InputField.ZIndex = thisWidget.ZIndex + 2
        InputField.LayoutOrder = thisWidget.ZIndex + 2
        InputField.Size = UDim2.new(1, 0, 1, 0)
        InputField.BackgroundTransparency = 1
        InputField.ClearTextOnFocus = false
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.Visible = false

        return InputField
    end

    local function GenerateTextLabel(thisWidget)
        local textLabelHeight = Iris._config.TextSize + Iris._config.FramePadding.Y * 2

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex + 4
        TextLabel.LayoutOrder = thisWidget.ZIndex + 4
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        widgets.applyTextStyle(TextLabel)

        return TextLabel
    end

    local abstractInputVector3 = {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Increment"] = 2,
            ["Min"] = 3,
            ["Max"] = 4,
            ["Format"] = 5,
        },
        Events = {
            ["numberChanged"] = numberChanged,
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function()
            
        end,
        Update = function(thisWidget)
            if thisWidget.arguments.Increment and typeof(thisWidget.arguments.Increment) ~= "Vector2" then
                error("Iris.InputVector2 'Increment' Argument must be a Vector2", 5)
            end
            if thisWidget.arguments.Min and typeof(thisWidget.arguments.Min) ~= "Vector2" then
                error("Iris.InputVector2 'Min' Argument must be a Vector2", 5)
            end
            if thisWidget.arguments.Max and typeof(thisWidget.arguments.Max) ~= "Vector2" then
                error("Iris.InputVector2 'Max' Argument must be a Vector2", 5)
            end
            local TextLabel = thisWidget.Instance.TextLabel
            TextLabel.Text = thisWidget.arguments.Text or "Input Vector3"
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.number == nil then
                local Min = thisWidget.arguments.Min or Vector3.zero
                local Max = thisWidget.arguments.Max or (Vector3.one * 100)
                thisWidget.state.number = Iris._widgetState(thisWidget, "number", Vector3.new(math.clamp(0, Min.X, Max.X), math.clamp(0, Min.Y, Max.Y), math.clamp(0, Min.Z, Max.Z)))
            end
        end,
        UpdateState = function(thisWidget)
            local InputFieldX = thisWidget.Instance.InputFieldX
            local InputFieldY = thisWidget.Instance.InputFieldY
            local InputFieldZ = thisWidget.Instance.InputFieldZ

            local newTextX = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value.X)
            local newTextY = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value.Y)
            local newTextZ = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value.Z)

            InputFieldX.Text = newTextX
            InputFieldY.Text = newTextY
            InputFieldZ.Text = newTextZ
        end
    }

    local abstractInputVector2 = {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Increment"] = 2,
            ["Min"] = 3,
            ["Max"] = 4,
            ["Format"] = 5,
        },
        Events = {
            ["numberChanged"] = numberChanged,
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)

        end,
        Update = function(thisWidget)
            if thisWidget.arguments.Increment and typeof(thisWidget.arguments.Increment) ~= "Vector2" then
                error("Iris.InputVector2 'Increment' Argument must be a Vector2", 5)
            end
            if thisWidget.arguments.Min and typeof(thisWidget.arguments.Min) ~= "Vector2" then
                error("Iris.InputVector2 'Min' Argument must be a Vector2", 5)
            end
            if thisWidget.arguments.Max and typeof(thisWidget.arguments.Max) ~= "Vector2" then
                error("Iris.InputVector2 'Max' Argument must be a Vector2", 5)
            end
            local TextLabel = thisWidget.Instance.TextLabel
            TextLabel.Text = thisWidget.arguments.Text or "Input Vector2"
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.number == nil then
                local Min = thisWidget.arguments.Min or Vector2.zero
                local Max = thisWidget.arguments.Max or (Vector2.one * 100)
                thisWidget.state.number = Iris._widgetState(thisWidget, "number", Vector2.new(math.clamp(0, Min.X, Max.X), math.clamp(0, Min.Y, Max.Y)))
            end
        end,
        UpdateState = function(thisWidget)
            local InputFieldX = thisWidget.Instance.InputFieldX
            local InputFieldY = thisWidget.Instance.InputFieldY
            local newTextX = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value.X)
            local newTextY = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value.Y)
            InputFieldX.Text = newTextX
            InputFieldY.Text = newTextY
        end
    }

    do -- Iris.DragNum
        local AnyActiveDragNum = false
        local LastMouseXPos = 0
        local ActiveDragNum
    
        widgets.UserInputService.InputEnded:Connect(function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveDragNum then
                AnyActiveDragNum = false
                ActiveDragNum = nil
            end
        end)
    
        local function updateActiveDrag()
            local currentMouseX = widgets.UserInputService:GetMouseLocation().X
            local mouseXDelta = currentMouseX - LastMouseXPos
            LastMouseXPos = currentMouseX
            if AnyActiveDragNum == false then
                return
            end
    
            local oldNum = ActiveDragNum.state.number.value
    
            local Min = ActiveDragNum.arguments.Min or -1e5
            local Max = ActiveDragNum.arguments.Max or 1e5
    
            local Increment = (ActiveDragNum.arguments.Increment or 1)
            Increment *= (widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1
            Increment *= (widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1
    
            local newNum = math.clamp(oldNum + (mouseXDelta * Increment), Min, Max)
            ActiveDragNum.state.number:set(newNum)
        end
    
        local function InputFieldContainerOnClick(thisWidget, x, y)
    
            local currentTime = time()
            local isTimeValid = currentTime - thisWidget.lastClickedTime < Iris._config.MouseDoubleClickTime
            local isCtrlHeld = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            if (isTimeValid and (Vector2.new(x, y) - thisWidget.lastClickedPosition).Magnitude < Iris._config.MouseDoubleClickMaxDist) or isCtrlHeld then
                thisWidget.state.editingText:set(true)
            else
                thisWidget.lastClickedTime = currentTime
                thisWidget.lastClickedPosition = Vector2.new(x, y)
    
                AnyActiveDragNum = true
                ActiveDragNum = thisWidget
                updateActiveDrag()
            end
        end
    
        widgets.UserInputService.InputChanged:Connect(updateActiveDrag)
    
        Iris.WidgetConstructor("DragNum", {
            hasState = true,
            hasChildren = false,
            Args = {
                ["Text"] = 1,
                ["Increment"] = 2,
                ["Min"] = 3,
                ["Max"] = 4,
                ["Format"] = 5,
            },
            Events = {
                ["numberChanged"] = numberChanged,
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                    return thisWidget.Instance
                end)
            },
            Generate = function(thisWidget)
                local DragNum = GenerateRootFrame(thisWidget, "Iris_DragNum")
    
                local InputFieldContainer = Instance.new("TextButton")
                InputFieldContainer.Name = "InputFieldContainer"
                widgets.applyFrameStyle(InputFieldContainer)
                widgets.applyTextStyle(InputFieldContainer)
                widgets.UISizeConstraint(InputFieldContainer, Vector2.new(1, 0))
                InputFieldContainer.TextXAlignment = Enum.TextXAlignment.Center
                InputFieldContainer.ZIndex = thisWidget.ZIndex + 1
                InputFieldContainer.LayoutOrder = thisWidget.ZIndex + 1
                InputFieldContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
                InputFieldContainer.AutomaticSize = Enum.AutomaticSize.Y
                InputFieldContainer.AutoButtonColor = false
                InputFieldContainer.Text = ""
                InputFieldContainer.BackgroundColor3 = Iris._config.FrameBgColor
                InputFieldContainer.BackgroundTransparency = Iris._config.FrameBgTransparency
                InputFieldContainer.Parent = DragNum
                InputFieldContainer.ClipsDescendants = true
    
                widgets.applyInteractionHighlights(InputFieldContainer, InputFieldContainer, {
                    ButtonColor = Iris._config.FrameBgColor,
                    ButtonTransparency = Iris._config.FrameBgTransparency,
                    ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                    ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                    ButtonActiveColor = Iris._config.FrameBgActiveColor,
                    ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                })
    
                local InputField = GenerateInputField(thisWidget)
                InputField.Parent = InputFieldContainer
    
                InputField.FocusLost:Connect(function()
                    local newValue = tonumber(InputField.Text)
                    if newValue ~= nil then
                        newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                        thisWidget.state.number:set(newValue)
                        thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                    else
                        InputField.Text = thisWidget.state.number.value
                    end
    
                    thisWidget.state.editingText:set(false)
    
                    InputField:ReleaseFocus(true)
                    -- there is a very strange roblox UI bug where for some reason InputFieldContainer will stop sinking input unless this line is here
                    -- it only starts sinking input again once a different UI is interacted with
                end)
    
                InputField.Focused:Connect(function()
                    InputField.SelectionStart = 1
                end)
    
                thisWidget.lastClickedTime = -1
                thisWidget.lastClickedPosition = Vector2.zero
    
                InputFieldContainer.MouseButton1Down:Connect(function(x, y)
                    InputFieldContainerOnClick(thisWidget, x, y)
                end)
    
                local TextLabel = GenerateTextLabel(thisWidget)
                TextLabel.Parent = DragNum
    
                return DragNum
            end,
            Update = function(thisWidget)
                local TextLabel = thisWidget.Instance.TextLabel
                TextLabel.Text = thisWidget.arguments.Text or "Input Slider"
            end,
            Discard = function(thisWidget)
                thisWidget.Instance:Destroy()
                widgets.discardState(thisWidget)
            end,
            GenerateState = function(thisWidget)
                if thisWidget.state.number == nil then
                    local Min = thisWidget.arguments.Min or 0
                    local Max = thisWidget.arguments.Max or 100
                    thisWidget.state.number = Iris._widgetState(thisWidget, "number", math.clamp(0, Min, Max))
                end
                if thisWidget.state.editingText == nil then
                    thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                end
            end,
            UpdateState = function(thisWidget)
                local InputFieldContainer = thisWidget.Instance.InputFieldContainer
                local InputField = InputFieldContainer.InputField
                local newText = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value)
                InputFieldContainer.Text = newText
                InputField.Text = tostring(thisWidget.state.number.value)
    
                if thisWidget.state.editingText.value then
                    InputField.Visible = true
                    InputField:CaptureFocus()
                    InputFieldContainer.TextTransparency = 1
                else
                    InputField.Visible = false
                    InputFieldContainer.TextTransparency = 0
                end
            end
        })
    end

    do -- Iris.SliderNum
        local AnyActiveSliderNum = false
        local ActiveSliderNum

        widgets.UserInputService.InputEnded:Connect(function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveSliderNum then
                AnyActiveSliderNum = false
                ActiveSliderNum = nil
            end
        end)
        local function updateActiveSlider()
            if AnyActiveSliderNum == false then
                return
            end

            local InputFieldContainer = ActiveSliderNum.Instance.InputFieldContainer
            local GrabBar = InputFieldContainer.GrabBar

            local Increment = ActiveSliderNum.arguments.Increment or 1
            local Min = ActiveSliderNum.arguments.Min or 0
            local Max = ActiveSliderNum.arguments.Max or 100

            local GrabPadding = Iris._config.FramePadding.X
            local decimalFix = Increment < 1 and 0 or 1 -- ??? ?? ??? ?
            local GrabNumPossiblePositions = math.floor((decimalFix + Max - Min) / Increment)
            local PositionRatio = (widgets.UserInputService:GetMouseLocation().X - (InputFieldContainer.AbsolutePosition.X + GrabPadding)) / (InputFieldContainer.AbsoluteSize.X - 2 * GrabPadding)

            local NewNumber = math.clamp(math.floor(PositionRatio * GrabNumPossiblePositions) * Increment + Min, Min, Max)
            if ActiveSliderNum.state.number.value ~= NewNumber then
                ActiveSliderNum.state.number:set(NewNumber)
            end
        end
        widgets.UserInputService.InputChanged:Connect(updateActiveSlider)

        local function InputFieldContainerOnClick(thisWidget)
            local isCtrlHeld = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            if isCtrlHeld then
                thisWidget.state.editingText:set(true)
            else
                AnyActiveSliderNum = true
                ActiveSliderNum = thisWidget
                updateActiveSlider()
            end
        end

        Iris.WidgetConstructor("SliderNum", {
            hasState = true,
            hasChildren = false,
            Args = {
                ["Text"] = 1,
                ["Increment"] = 2,
                ["Min"] = 3,
                ["Max"] = 4,
                ["Format"] = 5,
            },
            Events = {
                ["numberChanged"] = numberChanged,
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                    return thisWidget.Instance
                end)
            },
            Generate = function(thisWidget)
                local SliderNum = GenerateRootFrame(thisWidget, "Iris_SliderNum")

                local InputFieldContainer = Instance.new("TextButton")
                InputFieldContainer.Name = "InputFieldContainer"
                widgets.applyFrameStyle(InputFieldContainer)
                widgets.applyTextStyle(InputFieldContainer)
                widgets.UISizeConstraint(InputFieldContainer, Vector2.new(1, 0))
                InputFieldContainer.TextXAlignment = Enum.TextXAlignment.Center
                InputFieldContainer.ZIndex = thisWidget.ZIndex + 1
                InputFieldContainer.LayoutOrder = thisWidget.ZIndex + 1
                InputFieldContainer.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
                InputFieldContainer.AutomaticSize = Enum.AutomaticSize.Y
                InputFieldContainer.AutoButtonColor = false
                InputFieldContainer.Text = ""
                InputFieldContainer.BackgroundColor3 = Iris._config.FrameBgColor
                InputFieldContainer.BackgroundTransparency = Iris._config.FrameBgTransparency
                InputFieldContainer.Parent = SliderNum
                InputFieldContainer.ClipsDescendants = true

                local OverlayText = Instance.new("TextLabel")
                OverlayText.Name = "OverlayText"
                OverlayText.Size = UDim2.fromScale(1, 1)
                OverlayText.BackgroundTransparency = 1
                OverlayText.BorderSizePixel = 0
                OverlayText.ZIndex = thisWidget.ZIndex + 10
                widgets.applyTextStyle(OverlayText)
                OverlayText.TextXAlignment = Enum.TextXAlignment.Center
                OverlayText.Parent = InputFieldContainer
                OverlayText.ClipsDescendants = true

                widgets.applyInteractionHighlights(InputFieldContainer, InputFieldContainer, {
                    ButtonColor = Iris._config.FrameBgColor,
                    ButtonTransparency = Iris._config.FrameBgTransparency,
                    ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                    ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                    ButtonActiveColor = Iris._config.FrameBgActiveColor,
                    ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                })

                local InputField = GenerateInputField(thisWidget)
                InputField.Parent = InputFieldContainer

                InputField.FocusLost:Connect(function()
                    local newValue = tonumber(InputField.Text)
                    if newValue ~= nil then
                        newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                        thisWidget.state.number:set(newValue)
                        thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                    else
                        InputField.Text = thisWidget.state.number.value
                    end

                    thisWidget.state.editingText:set(false)

                    InputField:ReleaseFocus(true)
                    -- there is a very strange roblox UI bug where for some reason InputFieldContainer will stop sinking input unless this line is here
                    -- it only starts sinking input again once a different UI is interacted with
                end)

                InputField.Focused:Connect(function()
                    InputField.SelectionStart = 1
                end)

                InputFieldContainer.MouseButton1Down:Connect(function()
                    InputFieldContainerOnClick(thisWidget)
                end)

                local GrabBar = Instance.new("Frame")
                GrabBar.Name = "GrabBar"
                GrabBar.ZIndex = thisWidget.ZIndex + 3
                GrabBar.LayoutOrder = thisWidget.ZIndex + 3
                --GrabBar.Size = UDim2.new(0, 0, 1, 0)
                GrabBar.AnchorPoint = Vector2.new(0, 0.5)
                GrabBar.Position = UDim2.new(0, 0, 0.5, 0)
                GrabBar.BorderSizePixel = 0
                GrabBar.BackgroundColor3 = Iris._config.SliderGrabColor
                GrabBar.Transparency = Iris._config.SliderGrabTransparency
                if Iris._config.GrabRounding > 0 then
                    widgets.UICorner(GrabBar, Iris._config.GrabRounding)
                end
                GrabBar.Parent = InputFieldContainer

                local TextLabel = GenerateTextLabel(thisWidget)
                TextLabel.Parent = SliderNum

                return SliderNum
            end,
            Update = function(thisWidget)
                local TextLabel = thisWidget.Instance.TextLabel
                local InputFieldContainer = thisWidget.Instance.InputFieldContainer
                local GrabBar = InputFieldContainer.GrabBar
                TextLabel.Text = thisWidget.arguments.Text or "Input Slider"

                local Increment = thisWidget.arguments.Increment or 1
                local Min = thisWidget.arguments.Min or 0
                local Max = thisWidget.arguments.Max or 100

                local grabScaleSize = math.max(1 / math.floor((1 + Max - Min) / Increment), Iris._config.GrabMinSize / InputFieldContainer.AbsoluteSize.X)
                
                GrabBar.Size = UDim2.new(grabScaleSize, 0, 1, 0)
            end,
            Discard = function(thisWidget)
                thisWidget.Instance:Destroy()
                widgets.discardState(thisWidget)
            end,
            GenerateState = function(thisWidget)
                if thisWidget.state.number == nil then
                    local Min = thisWidget.arguments.Min or 0
                    local Max = thisWidget.arguments.Max or 100
                    thisWidget.state.number = Iris._widgetState(thisWidget, "number", math.clamp(0, Min, Max))
                end
                if thisWidget.state.editingText == nil then
                    thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                end
            end,
            UpdateState = function(thisWidget)
                local InputFieldContainer = thisWidget.Instance.InputFieldContainer
                local GrabBar = InputFieldContainer.GrabBar
                local InputField = InputFieldContainer.InputField
                local newText = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value)
                local OverlayText = InputFieldContainer.OverlayText
                OverlayText.Text = newText
                InputField.Text = tostring(thisWidget.state.number.value)

                local Increment = thisWidget.arguments.Increment or 1
                local Min = thisWidget.arguments.Min or 0
                local Max = thisWidget.arguments.Max or 100
        
                local GrabPadding = Iris._config.FramePadding.X
                local decimalFix = Increment < 1 and 0 or 1 -- ??? ?? ??? ?
                local GrabNumPossiblePositions = math.floor((decimalFix + Max - Min) / Increment)
                local PositionRatio = (thisWidget.state.number.value - Min) / (Max - Min)
                local MaxScaleSize = 1 - (GrabBar.AbsoluteSize.X / (InputFieldContainer.AbsoluteSize.X - 2 * GrabPadding))
                local GrabBarPos = math.clamp(math.floor(PositionRatio * GrabNumPossiblePositions) / GrabNumPossiblePositions, 0, MaxScaleSize)
                GrabBar.Position = UDim2.new(GrabBarPos, 0, 0.5, 0)

                if thisWidget.state.editingText.value then
                    InputField.Visible = true
                    OverlayText.Visible = false
                    GrabBar.Visible = false
                    InputField:CaptureFocus()
                    InputFieldContainer.TextTransparency = 1
                else
                    InputField.Visible = false
                    OverlayText.Visible = true
                    GrabBar.Visible = true
                    InputFieldContainer.TextTransparency = 0
                end
            end
        })
    end

    Iris.WidgetConstructor("InputNum", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Increment"] = 2,
            ["Min"] = 3,
            ["Max"] = 4,
            ["Format"] = 5,
            ["NoButtons"] = 6,
            ["NoField"] = 7
        },
        Events = {
            ["numberChanged"] = numberChanged,
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local InputNum = GenerateRootFrame(thisWidget, "Iris_InputNum")
    
            local inputButtonsWidth = Iris._config.TextSize
    
            local InputField = Instance.new("TextBox")
            InputField.Name = "InputField"
            widgets.applyFrameStyle(InputField)
            widgets.applyTextStyle(InputField)
			widgets.UISizeConstraint(InputField, Vector2.new(1, 0))
            InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputField.ZIndex = thisWidget.ZIndex + 1
            InputField.LayoutOrder = thisWidget.ZIndex + 1
			InputField.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputField.AutomaticSize = Enum.AutomaticSize.Y
            InputField.BackgroundColor3 = Iris._config.FrameBgColor
            InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputField.ClearTextOnFocus = false
            InputField.TextTruncate = Enum.TextTruncate.AtEnd
            InputField.Parent = InputNum
			InputField.ClipsDescendants = true
    
            InputField.FocusLost:Connect(function()
                local newValue = tonumber(InputField.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(newValue)
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputField.Text = thisWidget.state.number.value
                end
            end)
    
            InputField.Focused:Connect(function()
                InputField.SelectionStart = 1
            end)
    
            local SubButton = widgets.abstractButton.Generate(thisWidget)
            SubButton.Name = "SubButton"
            SubButton.ZIndex = thisWidget.ZIndex + 2
            SubButton.LayoutOrder = thisWidget.ZIndex + 2
            SubButton.TextXAlignment = Enum.TextXAlignment.Center
            SubButton.Text = "-"
            SubButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
            SubButton.Parent = InputNum
    
            SubButton.MouseButton1Click:Connect(function()
                local isCtrlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                local changeValue = (thisWidget.arguments.Increment or 1) * (isCtrlHeld and 100 or 1)
                local newValue = thisWidget.state.number.value - changeValue
                newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumchangeTick = Iris._cycleTick + 1
            end)
    
            local AddButton = widgets.abstractButton.Generate(thisWidget)
            AddButton.Name = "AddButton"
            AddButton.ZIndex = thisWidget.ZIndex + 3
            AddButton.LayoutOrder = thisWidget.ZIndex + 3
            AddButton.TextXAlignment = Enum.TextXAlignment.Center
            AddButton.Text = "+"
            AddButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
            AddButton.Parent = InputNum
    
            AddButton.MouseButton1Click:Connect(function()
                local isCtrlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                local changeValue = (thisWidget.arguments.Increment or 1) * (isCtrlHeld and 100 or 1)
                local newValue = thisWidget.state.number.value + changeValue
                newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumchangeTick = Iris._cycleTick + 1
            end)
    
            local TextLabel = GenerateTextLabel(thisWidget)
            TextLabel.Parent = InputNum
    
            return InputNum
        end,
        Update = function(thisWidget)
            local TextLabel = thisWidget.Instance.TextLabel
            TextLabel.Text = thisWidget.arguments.Text or "Input Num"
    
            thisWidget.Instance.SubButton.Visible = not thisWidget.arguments.NoButtons
            thisWidget.Instance.AddButton.Visible = not thisWidget.arguments.NoButtons
            local InputField = thisWidget.Instance.InputField
            InputField.Visible = not thisWidget.arguments.NoField
    
            local inputButtonsTotalWidth = Iris._config.TextSize * 2 + Iris._config.ItemInnerSpacing.X * 2 + Iris._config.WindowPadding.X + 4
            if thisWidget.arguments.NoButtons then
                InputField.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            else
                InputField.Size = UDim2.new(Iris._config.ContentWidth + UDim.new(0, -inputButtonsTotalWidth), UDim.new(0, 0))
            end
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.number == nil then
                local Min = thisWidget.arguments.Min or 0
                local Max = thisWidget.arguments.Max or 100
                thisWidget.state.number = Iris._widgetState(thisWidget, "number", math.clamp(0, Min, Max))
            end
        end,
        UpdateState = function(thisWidget)
            local InputField = thisWidget.Instance.InputField
            InputField.Text = string.format(thisWidget.arguments.Format or ((thisWidget.arguments.Increment or 1) >= 1 and "%d" or "%f"), thisWidget.state.number.value)
        end
    })

    Iris.WidgetConstructor("InputVector2", widgets.extend(abstractInputVector2, {
        Generate = function(thisWidget)
            local InputNum = GenerateRootFrame(thisWidget, "Iris_InputVector2")

            local InputWidth = UDim.new(Iris._config.ContentWidth.Scale / 2, (Iris._config.ContentWidth.Offset - Iris._config.ItemInnerSpacing.X) / 2)
        
            local InputFieldX = Instance.new("TextBox")
            InputFieldX.Name = "InputFieldX"
            widgets.applyFrameStyle(InputFieldX)
            widgets.applyTextStyle(InputFieldX)
			widgets.UISizeConstraint(InputFieldX, Vector2.new(1, 0))
            InputFieldX.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputFieldX.ZIndex = thisWidget.ZIndex + 1
            InputFieldX.LayoutOrder = thisWidget.ZIndex + 1
			InputFieldX.Size = UDim2.new(InputWidth, UDim.new(0, 0))
            InputFieldX.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldX.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldX.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldX.ClearTextOnFocus = false
            InputFieldX.TextTruncate = Enum.TextTruncate.AtEnd
			InputFieldX.ClipsDescendants = true
            InputFieldX.Parent = InputNum
    
            InputFieldX.FocusLost:Connect(function()
                local newValue = tonumber(InputFieldX.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(Vector2.new(newValue, thisWidget.state.number.value.Y))
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputFieldX.Text = thisWidget.state.number.value.X
                end
            end)
    
            InputFieldX.Focused:Connect(function()
                InputFieldX.SelectionStart = 1
            end)

            local InputFieldY = Instance.new("TextBox")
            InputFieldY.Name = "InputFieldY"
            widgets.applyFrameStyle(InputFieldY)
            widgets.applyTextStyle(InputFieldY)
			widgets.UISizeConstraint(InputFieldY, Vector2.new(1, 0))
            InputFieldY.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputFieldY.ZIndex = thisWidget.ZIndex + 2
            InputFieldY.LayoutOrder = thisWidget.ZIndex + 2
			InputFieldY.Size = UDim2.new(InputWidth, UDim.new(0, 0))
            InputFieldY.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldY.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldY.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldY.ClearTextOnFocus = false
            InputFieldY.TextTruncate = Enum.TextTruncate.AtEnd
			InputFieldY.ClipsDescendants = true
            InputFieldY.Parent = InputNum
    
            InputFieldY.FocusLost:Connect(function()
                local newValue = tonumber(InputFieldY.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(Vector2.new(thisWidget.state.number.value.X, newValue))
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputFieldY.Text = thisWidget.state.number.value.Y
                end
            end)
    
            InputFieldY.Focused:Connect(function()
                InputFieldY.SelectionStart = 1
            end)
    
            local TextLabel = GenerateTextLabel(thisWidget)
            TextLabel.Parent = InputNum
    
            return InputNum
        end
    }))
    
    Iris.WidgetConstructor("InputVector3", widgets.extend(abstractInputVector3, {
        Generate = function(thisWidget)
            local InputNum = GenerateRootFrame(thisWidget, "Iris_InputVector3")

            local InputWidth = UDim.new(Iris._config.ContentWidth.Scale / 3, Iris._config.ContentWidth.Offset / 3 - math.round(Iris._config.ItemInnerSpacing.X * (2/3)))
        
            local InputFieldX = Instance.new("TextBox")
            InputFieldX.Name = "InputFieldX"
            widgets.applyFrameStyle(InputFieldX)
            widgets.applyTextStyle(InputFieldX)
			widgets.UISizeConstraint(InputFieldX, Vector2.new(1, 0))
            InputFieldX.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputFieldX.ZIndex = thisWidget.ZIndex + 1
            InputFieldX.LayoutOrder = thisWidget.ZIndex + 1
			InputFieldX.Size = UDim2.new(InputWidth, UDim.new(0, 0))
            InputFieldX.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldX.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldX.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldX.ClearTextOnFocus = false
            InputFieldX.TextTruncate = Enum.TextTruncate.AtEnd
			InputFieldX.ClipsDescendants = true
            InputFieldX.Parent = InputNum
    
            InputFieldX.FocusLost:Connect(function()
                local newValue = tonumber(InputFieldX.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(Vector3.new(newValue, thisWidget.state.number.value.Y, thisWidget.state.number.value.Z))
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputFieldX.Text = thisWidget.state.number.value.X
                end
            end)
    
            InputFieldX.Focused:Connect(function()
                InputFieldX.SelectionStart = 1
            end)

            local InputFieldY = Instance.new("TextBox")
            InputFieldY.Name = "InputFieldY"
            widgets.applyFrameStyle(InputFieldY)
            widgets.applyTextStyle(InputFieldY)
			widgets.UISizeConstraint(InputFieldY, Vector2.new(1, 0))
            InputFieldY.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputFieldY.ZIndex = thisWidget.ZIndex + 2
            InputFieldY.LayoutOrder = thisWidget.ZIndex + 2
			InputFieldY.Size = UDim2.new(InputWidth, UDim.new(0, 0))
            InputFieldY.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldY.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldY.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldY.ClearTextOnFocus = false
            InputFieldY.TextTruncate = Enum.TextTruncate.AtEnd
			InputFieldY.ClipsDescendants = true
            InputFieldY.Parent = InputNum
    
            InputFieldY.FocusLost:Connect(function()
                local newValue = tonumber(InputFieldY.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(Vector3.new(thisWidget.state.number.value.X, newValue, thisWidget.state.number.value.Z))
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputFieldY.Text = thisWidget.state.number.value.Y
                end
            end)
    
            InputFieldY.Focused:Connect(function()
                InputFieldY.SelectionStart = 1
            end)

            local InputFieldZ = Instance.new("TextBox")
            InputFieldZ.Name = "InputFieldZ"
            widgets.applyFrameStyle(InputFieldZ)
            widgets.applyTextStyle(InputFieldZ)
			widgets.UISizeConstraint(InputFieldZ, Vector2.new(1, 0))
            InputFieldZ.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputFieldZ.ZIndex = thisWidget.ZIndex + 3
            InputFieldZ.LayoutOrder = thisWidget.ZIndex + 3
			InputFieldZ.Size = UDim2.new(InputWidth, UDim.new(0, 0))
            InputFieldZ.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldZ.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldZ.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldZ.ClearTextOnFocus = false
            InputFieldZ.TextTruncate = Enum.TextTruncate.AtEnd
			InputFieldZ.ClipsDescendants = true
            InputFieldZ.Parent = InputNum
    
            InputFieldZ.FocusLost:Connect(function()
                local newValue = tonumber(InputFieldZ.Text)
                if newValue ~= nil then
                    newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                    thisWidget.state.number:set(Vector3.new(thisWidget.state.number.value.X, thisWidget.state.number.value.Y, newValue))
                    thisWidget.lastNumchangeTick = Iris._cycleTick + 1
                else
                    InputFieldZ.Text = thisWidget.state.number.value.Z
                end
            end)
    
            InputFieldZ.Focused:Connect(function()
                InputFieldZ.SelectionStart = 1
            end)
    
            local TextLabel = GenerateTextLabel(thisWidget)
            TextLabel.Parent = InputNum
    
            return InputNum
        end
    }))
    
    Iris.WidgetConstructor("InputText", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["TextHint"] = 2
        },
        Events = {
            ["textChanged"] = {
                ["Init"] = function(thisWidget)
					thisWidget.lastTextchangeTick = 0    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastTextchangeTick == Iris._cycleTick
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local textLabelHeight = Iris._config.TextSize
    
            local InputText = GenerateRootFrame(thisWidget, "Iris_InputText")
    
            local InputField = Instance.new("TextBox")
            InputField.Name = "InputField"
            widgets.applyFrameStyle(InputField)
            widgets.applyTextStyle(InputField)
			widgets.UISizeConstraint(InputField, Vector2.new(1, 0)) -- prevents sizes beaking when getting too small.
            InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputField.UIPadding.PaddingRight = UDim.new(0, 0)
            InputField.ZIndex = thisWidget.ZIndex + 1
            InputField.LayoutOrder = thisWidget.ZIndex + 1
            InputField.AutomaticSize = Enum.AutomaticSize.Y
            InputField.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputField.BackgroundColor3 = Iris._config.FrameBgColor
            InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputField.ClearTextOnFocus = false
            InputField.Text = ""
            InputField.PlaceholderColor3 = Iris._config.TextDisabledColor
            InputField.TextTruncate = Enum.TextTruncate.AtEnd
			InputField.ClipsDescendants = true
    
            InputField.FocusLost:Connect(function()
                thisWidget.state.text:set(InputField.Text)
                thisWidget.lastTextchangeTick = Iris._cycleTick + 1
            end)
    
            InputField.Parent = InputText
    
            local TextLabel = GenerateTextLabel(thisWidget)
            TextLabel.Parent = InputText
    
            return InputText
        end,
        Update = function(thisWidget)
            local TextLabel = thisWidget.Instance.TextLabel
            TextLabel.Text = thisWidget.arguments.Text or "Input Text"
    
            thisWidget.Instance.InputField.PlaceholderText = thisWidget.arguments.TextHint or ""
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.text == nil then
                thisWidget.state.text = Iris._widgetState(thisWidget, "text", "")
            end
        end,
        UpdateState = function(thisWidget)
            thisWidget.Instance.InputField.Text = thisWidget.state.text.value
        end
    })
end