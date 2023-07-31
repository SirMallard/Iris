local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Iris, widgets: Types.WidgetUtility)
    local valueChanged = {
        ["Init"] = function(thisWidget) end,
        ["Get"] = function(thisWidget)
            return thisWidget.lastValueChangedTick == Iris._cycleTick
        end,
    }

    --[[
        Widgets:
            Input:
                - Text
                - Number
                - Vector2
                - Vector3
                - UDim
                - UDim2
            Drag:
                - Number
                - Vector2
                - Vector3
                - UDim
                - UDim2
                - Color3
                - Color4
            Slider:
                - Number
                - Vector2
                - Vector3
                - UDim
                - UDim2
                - Angle
                - Enum

        Types:
            InputText:
                - Label: string
                - Hint: string?
            
            InputNum:
                - Label: string
                - Increment: number? = 1
                - Min: number?
                - Max: number?
                - Format: string?
            InputVector2:
                - Label: string
                - Increment: Vector2? = Vector2.new(0.1, 0.1)
                - Min: Vector2?
                - Max: Vector2?
            InputVector3:
                - Label: string
                - Increment: Vector3? = Vector3.new(0.1, 0.1)
                - Min: Vector3?
                - Max: Vector3?
            InputUDim:
                - Label: string
                - Increment: UDim? = UDim.new(0.1, 1)
                - Min: UDim?
                - Max: UDim?
            InputUDim2:
                - Label: string
                - Increment: UDim2? = UDim2.new(0.1, 1, 0.1, 1)
                - Min: UDim2?
                - Max: UDim2?

            DragNum:
                - Label: string
                - Increment: number? = 1
                - Min: number?
                - Max: number?
                - Format: string?
            DragVector2
                - Label: string
                - Increment: Vector2? = Vector2.new(0.1, 0.1)
                - Min: Vector2?
                - Max: Vector2?
                - Format: string?
            DragVector3:
                - Label: string
                - Increment: Vector3? = Vector3.new(0.1, 0.1, 0.1)
                - Min: Vector3?
                - Max: Vector3?
                - Format: string?
            DragUDim:
                - Label: string
                - Increment: UDim? = UDim.new(0.1, 1)
                - Min: UDim?
                - Max: UDim?
                - Format: string?
            DragUDim2:
                - Label: string
                - Increment: UDim2? = UDim2.new(0.1, 1, 0.1, 1)
                - Min: UDim2?
                - Max: UDim2?
                - Format: string?
            
            InputColor3:
                - Label: string
                - UseFloat: boolean? = false
                - UseHSV: boolean? = false
                - Min: number = 0
                - Max: number = if UseFloats then 1 else 255
                - Format: string = nil
            InputColor4:
                - Label: string
                - UseFloat: boolean? = false
                - UseHSV: boolean? = false
                - Min: number = 0
                - Max: number = if UseFloats then 1 else 255
                - Format: string = nil
            
            SliderNum:
                - Label: string
                - Increment: number? = 1
                - Min: number
                - Max: number
                - Format: string?
            SliderVector2:
                - Label: string
                - Increment: Vector2? = 1
                - Min: Vector2
                - Max: Vector2
                - Format: string?
            SliderVector3:
                - Label: string
                - Increment: Vector3? = 1
                - Min: Vector3
                - Max: Vector3
                - Format: string?
            SliderUDim:
                - Label: string
                - Increment: UDim? = 1
                - Min: UDim
                - Max: UDim
                - Format: string?
            SliderUDim2:
                - Label: string
                - Increment: UDim2? = 1
                - Min: UDim2
                - Max: UDim2
                - Format: string?
            SliderEnum:
                - Label: string
                - Increment: mumber = 1
                - Min: number = 0
                - Max: number = #values
                - Format: any = enum[value]

		- DragScalar
        - SliderScalar
        - InputScalar
    ]]

    local function getValueByIndex(value: Types.InputDataType, index: number): number
        if typeof(value) == "number" then
            return value
        elseif typeof(value) == "Vector2" then
            if index == 1 then
                return value.X
            elseif index == 2 then
                return value.Y
            end
        elseif typeof(value) == "Vector3" then
            if index == 1 then
                return value.X
            elseif index == 2 then
                return value.Y
            elseif index == 3 then
                return value.Z
            end
        elseif typeof(value) == "UDim" then
            if index == 1 then
                return value.Scale
            elseif index == 2 then
                return value.Offset
            end
        elseif typeof(value) == "UDim2" then
            if index == 1 then
                return value.X.Scale
            elseif index == 2 then
                return value.X.Offset
            elseif index == 3 then
                return value.Y.Scale
            elseif index == 4 then
                return value.Y.Offset
            end
        elseif typeof(value) == "Color3" then
            if index == 1 then
                return value.R
            elseif index == 2 then
                return value.G
            elseif index == 3 then
                return value.B
            end
        end

        error(`Incorrect datatype or value: {value} {typeof(value)} {index}`)
    end

    local function updateValueByIndex(value: Types.InputDataType, index: number, newValue: number): Types.InputDataType
        if typeof(value) == "number" then
            return newValue
        elseif typeof(value) == "Vector2" then
            if index == 1 then
                return Vector2.new(newValue, value.Y)
            elseif index == 2 then
                return Vector2.new(value.X, newValue)
            end
        elseif typeof(value) == "Vector3" then
            if index == 1 then
                return Vector3.new(newValue, value.Y, value.Z)
            elseif index == 2 then
                return Vector3.new(value.X, newValue, value.Z)
            elseif index == 3 then
                return Vector3.new(value.X, value.Y, newValue)
            end
        elseif typeof(value) == "UDim" then
            if index == 1 then
                return UDim.new(newValue, value.Offset)
            elseif index == 2 then
                return UDim.new(value.Scale, newValue)
            end
        elseif typeof(value) == "UDim2" then
            if index == 1 then
                return UDim2.new(UDim.new(newValue, value.X.Offset), value.Y)
            elseif index == 2 then
                return UDim2.new(UDim.new(value.X.Scale, newValue), value.Y)
            elseif index == 3 then
                return UDim2.new(value.X, UDim.new(newValue, value.Y.Offset))
            elseif index == 4 then
                return UDim2.new(value.X, UDim.new(value.Y.Scale, newValue))
            end
        elseif typeof(value) == "Color3" then
            if index == 1 then
                return Color3.new(newValue, value.G, value.B)
            elseif index == 2 then
                return Color3.new(value.R, newValue, value.B)
            elseif index == 3 then
                return Color3.new(value.R, value.G, newValue)
            end
        end

        error("")
    end

    local function generateInputScalar(dataType: Types.InputDataTypes, components: number, defaultValue: any)
        return {
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
                ["numberChanged"] = valueChanged,
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
            },
            Generate = function(thisWidget: Types.Widget)
                local Input: Frame = Instance.new("Frame")
                Input.Name = "Iris_Input" .. dataType
                Input.Size = UDim2.fromScale(1, 0)
                Input.BackgroundTransparency = 1
                Input.BorderSizePixel = 0
                Input.ZIndex = thisWidget.ZIndex
                Input.LayoutOrder = thisWidget.ZIndex
                Input.AutomaticSize = Enum.AutomaticSize.Y
                widgets.UIListLayout(Input, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

                local componentWidth: UDim2 = UDim2.new(Iris._config.ContentWidth.Scale / components, (Iris._config.ContentWidth.Offset - (Iris._config.ItemInnerSpacing.X * (components - 1))) / components, 0, 0)

                for i = 1, components do
                    local InputField: TextBox = Instance.new("TextBox")
                    InputField.Name = "InputField" .. tostring(i)
                    InputField.ZIndex = thisWidget.ZIndex + 1
                    InputField.LayoutOrder = thisWidget.ZIndex + 1
                    InputField.Size = componentWidth
                    InputField.AutomaticSize = Enum.AutomaticSize.Y
                    InputField.BackgroundColor3 = Iris._config.FrameBgColor
                    InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
                    InputField.ClearTextOnFocus = false
                    InputField.TextTruncate = Enum.TextTruncate.AtEnd
                    InputField.ClipsDescendants = true

                    widgets.applyFrameStyle(InputField)
                    widgets.applyTextStyle(InputField)
                    widgets.UISizeConstraint(InputField, Vector2.new(1, 0))

                    InputField.Parent = Input

                    InputField.FocusLost:Connect(function()
                        local newValue: number? = tonumber(InputField.Text:match("-?%d*%.?%d*"))
                        if newValue ~= nil then
                            if thisWidget.arguments.Min ~= nil then
                                newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, i))
                            end
                            if thisWidget.arguments.Max ~= nil then
                                newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, i))
                            end

                            if thisWidget.arguments.Increment then
                                newValue = math.floor(newValue / getValueByIndex(thisWidget.arguments.Increment, i)) * getValueByIndex(thisWidget.arguments.Increment, i)
                            end

                            thisWidget.state.number:set(updateValueByIndex(thisWidget.state.number.value, i, newValue))
                            thisWidget.lastUncheckedTick = Iris._cycleTick + 1

                            if thisWidget.arguments.Format then
                                InputField.Text = string.format(thisWidget.arguments.Format, getValueByIndex(thisWidget.state.number.value, i))
                            else
                                -- this prevents float values to UDim offsets
                                local value: number = getValueByIndex(thisWidget.state.number.value, i)
                                InputField.Text = string.format(if math.floor(value) == value then "%d" else "%.3f", value)
                            end
                        else
                            if thisWidget.arguments.Format then
                                InputField.Text = string.format(thisWidget.arguments.Format, getValueByIndex(thisWidget.state.number.value, i))
                            else
                                local value: number = getValueByIndex(thisWidget.state.number.value, i)
                                InputField.Text = string.format(if math.floor(value) == value then "%d" else "%.3f", value)
                            end
                        end
                    end)

                    InputField.Focused:Connect(function()
                        -- this highlights the entire field
                        InputField.CursorPosition = #InputField.Text + 1
                        InputField.SelectionStart = 1
                    end)
                end

                local textHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.Size = UDim2.fromOffset(0, textHeight)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.ZIndex = thisWidget.ZIndex + 2
                TextLabel.LayoutOrder = thisWidget.ZIndex + 2
                TextLabel.AutomaticSize = Enum.AutomaticSize.X

                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Input

                return Input
            end,
            Update = function(thisWidget: Types.Widget)
                local Input = thisWidget.Instance :: GuiObject
                local TextLabel: TextLabel = Input.TextLabel

                TextLabel.Text = thisWidget.arguments.Text or "Input " .. dataType
            end,
            Discard = function(thisWidget: Types.Widget)
                thisWidget.Instance:Destroy()
                widgets.discardState(thisWidget)
            end,
            GenerateState = function(thisWidget: Types.Widget)
                if thisWidget.state.number == nil then
                    thisWidget.state.number = Iris._widgetState(thisWidget, "value", defaultValue)
                end
            end,
            UpdateState = function(thisWidget: Types.Widget)
                local Input = thisWidget.Instance :: GuiObject

                for i = 1, components do
                    local InputField: TextBox = Input:FindFirstChild("InputField" .. tostring(i))
                    if thisWidget.arguments.Format then
                        InputField.Text = string.format(thisWidget.arguments.Format, getValueByIndex(thisWidget.state.number.value, i))
                    else
                        InputField.Text = tostring(getValueByIndex(thisWidget.state.number.value, i))
                    end
                end
            end,
        }
    end

    Iris.WidgetConstructor("InputNum", generateInputScalar("Num", 1, 0))
    Iris.WidgetConstructor("InputVector2", generateInputScalar("Vector2", 2, Vector2.zero))
    Iris.WidgetConstructor("InputVector3", generateInputScalar("Vector3", 3, Vector3.zero))
    Iris.WidgetConstructor("InputUDim", generateInputScalar("UDim", 2, UDim.new()))
    Iris.WidgetConstructor("InputUDim2", generateInputScalar("UDim2", 4, UDim2.new()))
end
