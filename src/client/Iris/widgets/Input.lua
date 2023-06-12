return function(Iris, widgets)
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
            ["numberChanged"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastNumchangeTick == Iris._cycleTick
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local InputSlider = Instance.new("Frame")
            InputSlider.Name = "Iris_InputSlider"
            InputSlider.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputSlider.BackgroundTransparency = 1
            InputSlider.BorderSizePixel = 0
            InputSlider.ZIndex = thisWidget.ZIndex
            InputSlider.LayoutOrder = thisWidget.ZIndex
            InputSlider.AutomaticSize = Enum.AutomaticSize.Y
            widgets.UIListLayout(InputSlider, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

            local inputButtonsWidth = Iris._config.TextSize
            local textLabelHeight = inputButtonsWidth + Iris._config.FramePadding.Y * 2

            local InputFieldContainer = Instance.new("TextButton")
            InputFieldContainer.Name = "InputFieldContainer"
            widgets.applyFrameStyle(InputFieldContainer)
            widgets.applyTextStyle(InputFieldContainer)
            InputFieldContainer.TextXAlignment = Enum.TextXAlignment.Center
            InputFieldContainer.ZIndex = thisWidget.ZIndex + 1
            InputFieldContainer.LayoutOrder = thisWidget.ZIndex + 1
            InputFieldContainer.Size = UDim2.new(1, 0, 0, 0)
            InputFieldContainer.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldContainer.AutoButtonColor = false
            InputFieldContainer.Text = ""
            InputFieldContainer.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldContainer.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldContainer.Parent = InputSlider

            widgets.applyInteractionHighlights(InputFieldContainer, InputFieldContainer, {
                ButtonColor = Iris._config.FrameBgColor,
                ButtonTransparency = Iris._config.FrameBgTransparency,
                ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ButtonActiveColor = Iris._config.FrameBgActiveColor,
                ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })

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

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 4
            TextLabel.LayoutOrder = thisWidget.ZIndex + 4
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            widgets.applyTextStyle(TextLabel)
            TextLabel.Parent = InputSlider

            return InputSlider
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
            ["numberChanged"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastNumchangeTick == Iris._cycleTick
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local InputSlider = Instance.new("Frame")
            InputSlider.Name = "Iris_InputSlider"
            InputSlider.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputSlider.BackgroundTransparency = 1
            InputSlider.BorderSizePixel = 0
            InputSlider.ZIndex = thisWidget.ZIndex
            InputSlider.LayoutOrder = thisWidget.ZIndex
            InputSlider.AutomaticSize = Enum.AutomaticSize.Y
            widgets.UIListLayout(InputSlider, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

            local inputButtonsWidth = Iris._config.TextSize
            local textLabelHeight = inputButtonsWidth + Iris._config.FramePadding.Y * 2

            local InputFieldContainer = Instance.new("TextButton")
            InputFieldContainer.Name = "InputFieldContainer"
            widgets.applyFrameStyle(InputFieldContainer)
            widgets.applyTextStyle(InputFieldContainer)
            InputFieldContainer.TextXAlignment = Enum.TextXAlignment.Center
            InputFieldContainer.ZIndex = thisWidget.ZIndex + 1
            InputFieldContainer.LayoutOrder = thisWidget.ZIndex + 1
            InputFieldContainer.Size = UDim2.new(1, 0, 0, 0)
            InputFieldContainer.AutomaticSize = Enum.AutomaticSize.Y
            InputFieldContainer.AutoButtonColor = false
            InputFieldContainer.Text = ""
            InputFieldContainer.BackgroundColor3 = Iris._config.FrameBgColor
            InputFieldContainer.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputFieldContainer.Parent = InputSlider

            widgets.applyInteractionHighlights(InputFieldContainer, InputFieldContainer, {
                ButtonColor = Iris._config.FrameBgColor,
                ButtonTransparency = Iris._config.FrameBgTransparency,
                ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ButtonActiveColor = Iris._config.FrameBgActiveColor,
                ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })

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


            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 4
            TextLabel.LayoutOrder = thisWidget.ZIndex + 4
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            widgets.applyTextStyle(TextLabel)
            TextLabel.Parent = InputSlider

            return InputSlider
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
            InputFieldContainer.Text = newText
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
                InputField:CaptureFocus()
                InputFieldContainer.TextTransparency = 1
                GrabBar.Visible = false
            else
                InputField.Visible = false
                GrabBar.Visible = true
                InputFieldContainer.TextTransparency = 0
            end
        end
    })

    
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
            ["numberChanged"] = {
                ["Init"] = function(thisWidget)
    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastNumchangeTick == Iris._cycleTick
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local InputNum = Instance.new("Frame")
            InputNum.Name = "Iris_InputNum"
            InputNum.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputNum.BackgroundTransparency = 1
            InputNum.BorderSizePixel = 0
            InputNum.ZIndex = thisWidget.ZIndex
            InputNum.LayoutOrder = thisWidget.ZIndex
            InputNum.AutomaticSize = Enum.AutomaticSize.Y
            widgets.UIListLayout(InputNum, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
    
            local inputButtonsWidth = Iris._config.TextSize
            local textLabelHeight = inputButtonsWidth + Iris._config.FramePadding.Y * 2
    
            local InputField = Instance.new("TextBox")
            InputField.Name = "InputField"
            widgets.applyFrameStyle(InputField)
            widgets.applyTextStyle(InputField)
            InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            InputField.ZIndex = thisWidget.ZIndex + 1
            InputField.LayoutOrder = thisWidget.ZIndex + 1
            InputField.AutomaticSize = Enum.AutomaticSize.Y
            InputField.BackgroundColor3 = Iris._config.FrameBgColor
            InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputField.ClearTextOnFocus = false
            InputField.TextTruncate = Enum.TextTruncate.AtEnd
            InputField.Parent = InputNum
    
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
                local newValue = thisWidget.state.number.value - (thisWidget.arguments.Increment or 1)
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
                local newValue = thisWidget.state.number.value + (thisWidget.arguments.Increment or 1)
                newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumchangeTick = Iris._cycleTick + 1
            end)
    
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 4
            TextLabel.LayoutOrder = thisWidget.ZIndex + 4
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            widgets.applyTextStyle(TextLabel)
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
                InputField.Size = UDim2.new(1, 0, 0, 0)
            else
                InputField.Size = UDim2.new(1, -inputButtonsTotalWidth, 0, 0)
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
    
            local InputText = Instance.new("Frame")
            InputText.Name = "Iris_InputText"
            InputText.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputText.BackgroundTransparency = 1
            InputText.BorderSizePixel = 0
            InputText.ZIndex = thisWidget.ZIndex
            InputText.LayoutOrder = thisWidget.ZIndex
            InputText.AutomaticSize = Enum.AutomaticSize.Y
            widgets.UIListLayout(InputText, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
    
            local InputField = Instance.new("TextBox")
            InputField.Name = "InputField"
            widgets.applyFrameStyle(InputField)
            widgets.applyTextStyle(InputField)
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
    
            InputField.FocusLost:Connect(function()
                thisWidget.state.text:set(InputField.Text)
                thisWidget.lastTextchangeTick = Iris._cycleTick
            end)
    
            InputField.Parent = InputText
    
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Position = UDim2.new(1, Iris._config.ItemInnerSpacing.X, 0, 0)
            TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 2
            TextLabel.LayoutOrder = thisWidget.ZIndex + 2
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            widgets.applyTextStyle(TextLabel)
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