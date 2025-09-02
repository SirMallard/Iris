local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

type InputDataTypes = "Num" | "Vector2" | "Vector3" | "UDim" | "UDim2" | "Color3" | "Color4" | "Rect" | "Enum" | "" | string
type InputDataType = number | Vector2 | Vector3 | UDim | UDim2 | Color3 | Rect | Enum
type InputType = "Input" | "Drag" | "Slider"

export type Input<T> = Types.Widget & {
    lastClickedTime: number,
    lastClickedPosition: Vector2,

    arguments: {
        Text: string?,
        Increment: T,
        Min: T,
        Max: T,
        Format: { string },
        Prefix: { string },
        Flags: number,
    },

    state: {
        number: Types.State<T>,
        editing: Types.State<number>,
    },
} & Types.NumberChanged & Types.Hovered

export type InputColor3 = Input<{ number }> & {
    state: {
        color: Types.State<Color3>,
        editing: Types.State<boolean>,
    },
} & Types.NumberChanged & Types.Hovered

export type InputColor4 = InputColor3 & {
    state: {
        transparency: Types.State<number>,
    },
}

export type InputEnum = Input<number> & {
    state: {
        enum: Types.State<EnumItem>,
    },
}

export type InputText = Types.Widget & {
    arguments: {
        Text: string?,
        TextHint: string?,
        Flags: number,
    },

    state: {
        text: Types.State<string>,
    },
} & Types.TextChanged & Types.Hovered

local InputTextFlags = {
    ReadOnly = 1,
    MultiLine = 2,
}

local InputFlags = {
    UseFloats = 1,
    UseHSV = 2,
}

---------------
-- Constants
---------------

local numberChanged = {
    ["Init"] = function(_thisWidget: Types.Widget) end,
    ["Get"] = function(thisWidget: Input<any>)
        return thisWidget.lastNumberChangedTick == Internal._cycleTick
    end,
}

local defaultIncrements: { [InputDataTypes]: { number } } = {
    Num = { 1 },
    Vector2 = { 1, 1 },
    Vector3 = { 1, 1, 1 },
    UDim = { 0.01, 1 },
    UDim2 = { 0.01, 1, 0.01, 1 },
    Color3 = { 1, 1, 1 },
    Color4 = { 1, 1, 1, 1 },
    Rect = { 1, 1, 1, 1 },
}

local defaultMin: { [InputDataTypes]: { number } } = {
    Num = { 0 },
    Vector2 = { 0, 0 },
    Vector3 = { 0, 0, 0 },
    UDim = { 0, 0 },
    UDim2 = { 0, 0, 0, 0 },
    Rect = { 0, 0, 0, 0 },
}

local defaultMax: { [InputDataTypes]: { number } } = {
    Num = { 100 },
    Vector2 = { 100, 100 },
    Vector3 = { 100, 100, 100 },
    UDim = { 1, 960 },
    UDim2 = { 1, 960, 1, 960 },
    Rect = { 960, 960, 960, 960 },
}

local defaultPrefx: { [InputDataTypes]: { string } } = {
    Num = { "" },
    Vector2 = { "X: ", "Y: " },
    Vector3 = { "X: ", "Y: ", "Z: " },
    UDim = { "", "" },
    UDim2 = { "", "", "", "" },
    Color3_RGB = { "R: ", "G: ", "B: " },
    Color3_HSV = { "H: ", "S: ", "V: " },
    Color4_RGB = { "R: ", "G: ", "B: ", "T: " },
    Color4_HSV = { "H: ", "S: ", "V: ", "T: " },
    Rect = { "X: ", "Y: ", "X: ", "Y: " },
}

local defaultSigFigs: { [InputDataTypes]: { number } } = {
    Num = { 0 },
    Vector2 = { 0, 0 },
    Vector3 = { 0, 0, 0 },
    UDim = { 3, 0 },
    UDim2 = { 3, 0, 3, 0 },
    Color3 = { 0, 0, 0 },
    Color4 = { 0, 0, 0, 0 },
    Rect = { 0, 0, 0, 0 },
}

---------------
-- Functions
---------------

local function getValueByIndex<T>(value: T, index: number, arguments: any)
    local val = value :: unknown
    if typeof(val) == "number" then
        return val
    elseif typeof(val) == "Vector2" then
        if index == 1 then
            return val.X
        elseif index == 2 then
            return val.Y
        end
    elseif typeof(val) == "Vector3" then
        if index == 1 then
            return val.X
        elseif index == 2 then
            return val.Y
        elseif index == 3 then
            return val.Z
        end
    elseif typeof(val) == "UDim" then
        if index == 1 then
            return val.Scale
        elseif index == 2 then
            return val.Offset
        end
    elseif typeof(val) == "UDim2" then
        if index == 1 then
            return val.X.Scale
        elseif index == 2 then
            return val.X.Offset
        elseif index == 3 then
            return val.Y.Scale
        elseif index == 4 then
            return val.Y.Offset
        end
    elseif typeof(val) == "Color3" then
        local color = if btest(InputFlags.UseHSV, arguments) then { val:ToHSV() } else { val.R, val.G, val.B }
        if index == 1 then
            return color[1]
        elseif index == 2 then
            return color[2]
        elseif index == 3 then
            return color[3]
        end
    elseif typeof(val) == "Rect" then
        if index == 1 then
            return val.Min.X
        elseif index == 2 then
            return val.Min.Y
        elseif index == 3 then
            return val.Max.X
        elseif index == 4 then
            return val.Max.Y
        end
    elseif typeof(val) == "table" then
        return val[index]
    end

    error(`Incorrect datatype or value: {value} {typeof(value)} {index}.`)
end

local function updateValueByIndex<T>(value: T, index: number, newValue: number, arguments: any): T
    local val = value :: unknown
    if typeof(val) == "number" then
        return newValue :: any
    elseif typeof(val) == "Vector2" then
        if index == 1 then
            return Vector2.new(newValue, val.Y) :: any
        elseif index == 2 then
            return Vector2.new(val.X, newValue) :: any
        end
    elseif typeof(val) == "Vector3" then
        if index == 1 then
            return Vector3.new(newValue, val.Y, val.Z) :: any
        elseif index == 2 then
            return Vector3.new(val.X, newValue, val.Z) :: any
        elseif index == 3 then
            return Vector3.new(val.X, val.Y, newValue) :: any
        end
    elseif typeof(val) == "UDim" then
        if index == 1 then
            return UDim.new(newValue, val.Offset) :: any
        elseif index == 2 then
            return UDim.new(val.Scale, newValue) :: any
        end
    elseif typeof(val) == "UDim2" then
        if index == 1 then
            return UDim2.new(UDim.new(newValue, val.X.Offset), val.Y) :: any
        elseif index == 2 then
            return UDim2.new(UDim.new(val.X.Scale, newValue), val.Y) :: any
        elseif index == 3 then
            return UDim2.new(val.X, UDim.new(newValue, val.Y.Offset)) :: any
        elseif index == 4 then
            return UDim2.new(val.X, UDim.new(val.Y.Scale, newValue)) :: any
        end
    elseif typeof(val) == "Rect" then
        if index == 1 then
            return Rect.new(Vector2.new(newValue, val.Min.Y), val.Max) :: any
        elseif index == 2 then
            return Rect.new(Vector2.new(val.Min.X, newValue), val.Max) :: any
        elseif index == 3 then
            return Rect.new(val.Min, Vector2.new(newValue, val.Max.Y)) :: any
        elseif index == 4 then
            return Rect.new(val.Min, Vector2.new(val.Max.X, newValue)) :: any
        end
    elseif typeof(val) == "Color3" then
        if btest(InputFlags.UseHSV, arguments) then
            local h: number, s: number, v: number = val:ToHSV()
            if index == 1 then
                return Color3.fromHSV(newValue, s, v) :: any
            elseif index == 2 then
                return Color3.fromHSV(h, newValue, v) :: any
            elseif index == 3 then
                return Color3.fromHSV(h, s, newValue) :: any
            end
        end
        if index == 1 then
            return Color3.new(newValue, val.G, val.B) :: any
        elseif index == 2 then
            return Color3.new(val.R, newValue, val.B) :: any
        elseif index == 3 then
            return Color3.new(val.R, val.G, newValue) :: any
        end
    end

    error(`Incorrect datatype or value {value} {typeof(value)} {index}.`)
end

local function generateAbstract<T>(inputType: InputType, dataType: InputDataTypes, components: number, defaultValue: T): Types.WidgetClass
    return {
        hasState = true,
        hasChildren = false,
        numArguments = 5,
        Arguments = { "Text", "Increment", "Min", "Max", "Format", "number", "editing" },
        Events = {
            ["numberChanged"] = numberChanged,
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        GenerateState = function(thisWidget: Input<T>)
            if thisWidget.state.number == nil then
                thisWidget.state.number = Internal._widgetState(thisWidget, "number", defaultValue)
            end
            if thisWidget.state.editing == nil then
                thisWidget.state.editing = Internal._widgetState(thisWidget, "editing", 0)
            end
        end,
        Update = function(thisWidget: Input<T>)
            local Input = thisWidget.instance :: GuiObject
            local TextLabel: TextLabel = Input.TextLabel
            TextLabel.Text = thisWidget.arguments.Text or `Input {dataType}`

            if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                thisWidget.arguments.Format = { thisWidget.arguments.Format }
            elseif not thisWidget.arguments.Format then
                -- we calculate the format for the s.f. using the max, min and increment arguments.
                local format = {}
                for index = 1, components do
                    local sigfigs = defaultSigFigs[dataType][index]

                    if thisWidget.arguments.Increment then
                        local value = getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                        sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                    end

                    if thisWidget.arguments.Max then
                        local value = getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments)
                        sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                    end

                    if thisWidget.arguments.Min then
                        local value = getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments)
                        sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                    end

                    if sigfigs > 0 then
                        -- we know it's a float.
                        format[index] = `%.{sigfigs}f`
                    else
                        format[index] = "%d"
                    end
                end

                thisWidget.arguments.Format = format
                thisWidget.arguments.Prefix = defaultPrefx[dataType]
            end

            if inputType == "Input" and dataType == "Num" then
                Input.SubButton.Visible = not thisWidget.arguments.NoButtons
                Input.AddButton.Visible = not thisWidget.arguments.NoButtons
                local InputField: TextBox = Input.InputField1
                local rightPadding = if thisWidget.arguments.NoButtons then 0 else (2 * Internal._config.ItemInnerSpacing.X) + (2 * (Internal._config.TextSize + 2 * Internal._config.FramePadding.Y))
                InputField.Size = UDim2.new(UDim.new(Internal._config.ContentWidth.Scale, Internal._config.ContentWidth.Offset - rightPadding), Internal._config.ContentHeight)
            end

            if inputType == "Slider" then
                for index = 1, components do
                    local SliderField = Input:FindFirstChild("SliderField" .. tostring(index)) :: TextButton
                    local GrabBar: Frame = SliderField.GrabBar

                    local increment = thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments) or defaultIncrements[dataType][index]
                    local min = thisWidget.arguments.Min and getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments) or defaultMin[dataType][index]
                    local max = thisWidget.arguments.Max and getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments) or defaultMax[dataType][index]

                    local grabScaleSize = 1 / math.floor((1 + max - min) / increment)

                    GrabBar.Size = UDim2.fromScale(grabScaleSize, 1)
                end

                local callbackIndex = #Internal._postCycleCallbacks + 1
                local desiredCycleTick = Internal._cycleTick + 1
                Internal._postCycleCallbacks[callbackIndex] = function()
                    if Internal._cycleTick >= desiredCycleTick then
                        if thisWidget._lastCycleTick ~= -1 then
                            thisWidget.state.number._lastChangeTick = Internal._cycleTick
                            Internal._widgets[`Slider{dataType}`].UpdateState(thisWidget)
                        end
                        Internal._postCycleCallbacks[callbackIndex] = nil
                    end
                end
            end
        end,
        Discard = function(thisWidget: Input<T>)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
end

local function focusLost<T>(thisWidget: Input<T>, InputField: TextBox, index: number, dataType: InputDataTypes)
    local newValue = tonumber(InputField.Text:match("-?%d*%.?%d*"))
    local state = thisWidget.state.number
    local widget = thisWidget
    if dataType == "Color4" and index == 4 then
        state = widget.state.transparency
    elseif dataType == "Color3" or dataType == "Color4" then
        state = widget.state.color
    end
    if newValue ~= nil then
        if dataType == "Color3" or dataType == "Color4" and not btest(InputFlags.UseFloats, widget.arguments.Flags) then
            newValue = newValue / 255
        end
        if thisWidget.arguments.Min ~= nil then
            newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments))
        end
        if thisWidget.arguments.Max ~= nil then
            newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments))
        end

        if thisWidget.arguments.Increment then
            newValue = math.round(newValue / getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)) * getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
        end

        state:set(updateValueByIndex(state._value, index, newValue, thisWidget.arguments))
        thisWidget.lastNumberChangedTick = Internal._cycleTick + 1
    end

    local value = getValueByIndex(state._value, index, thisWidget.arguments)
    if dataType == "Color3" or dataType == "Color4" and not btest(InputFlags.UseFloats, widget.arguments.Flags) then
        value = math.round(value * 255)
    end

    local Format = thisWidget.arguments.Format
    local Prefix = thisWidget.arguments.Prefix
    local format = Format[index] or Format[1]
    if Prefix then
        format = Prefix[index] .. format
    end
    InputField.Text = string.format(format, value)

    thisWidget.state.editing:set(0)
    InputField:ReleaseFocus(true)
end

--------------
-- Input<T>
--------------

--[[
        Input
    ]]
local generateInputScalar: <T>(dataType: InputDataTypes, components: number, defaultValue: T) -> Types.WidgetClass
do
    local function generateButtons(thisWidget: Input<number>, parent: GuiObject, textHeight: number)
        local SubButton = Utility.abstractButton.Generate(thisWidget) :: TextButton
        SubButton.Name = "SubButton"
        SubButton.Size = UDim2.fromOffset(Internal._config.TextSize + 2 * Internal._config.FramePadding.Y, Internal._config.TextSize)
        SubButton.Text = "-"
        SubButton.TextXAlignment = Enum.TextXAlignment.Center
        SubButton.ZIndex = 5
        SubButton.LayoutOrder = 5
        SubButton.Parent = parent

        Utility.applyButtonClick(SubButton, function()
            local isCtrlHeld = Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            local changeValue = (thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, 1, thisWidget.arguments) or 1) * (isCtrlHeld and 100 or 1)
            local newValue = thisWidget.state.number._value - changeValue
            if thisWidget.arguments.Min ~= nil then
                newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, 1, thisWidget.arguments))
            end
            if thisWidget.arguments.Max ~= nil then
                newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, 1, thisWidget.arguments))
            end
            thisWidget.state.number:set(newValue)
            thisWidget.lastNumberChangedTick = Internal._cycleTick + 1
        end)

        local AddButton = Utility.abstractButton.Generate(thisWidget) :: TextButton
        AddButton.Name = "AddButton"
        AddButton.Size = UDim2.fromOffset(Internal._config.TextSize + 2 * Internal._config.FramePadding.Y, Internal._config.TextSize)
        AddButton.Text = "+"
        AddButton.TextXAlignment = Enum.TextXAlignment.Center
        AddButton.ZIndex = 6
        AddButton.LayoutOrder = 6
        AddButton.Parent = parent

        Utility.applyButtonClick(AddButton, function()
            local isCtrlHeld = Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            local changeValue = (thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, 1, thisWidget.arguments) or 1) * (isCtrlHeld and 100 or 1)
            local newValue = thisWidget.state.number._value + changeValue
            if thisWidget.arguments.Min ~= nil then
                newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, 1, thisWidget.arguments))
            end
            if thisWidget.arguments.Max ~= nil then
                newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, 1, thisWidget.arguments))
            end
            thisWidget.state.number:set(newValue)
            thisWidget.lastNumberChangedTick = Internal._cycleTick + 1
        end)

        return 2 * Internal._config.ItemInnerSpacing.X + 2 * textHeight
    end

    local function generateField<T>(thisWidget: Input<T>, index: number, componentWidth: UDim, dataType: InputDataTypes)
        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField" .. tostring(index)
        InputField.AutomaticSize = Enum.AutomaticSize.Y
        InputField.Size = UDim2.new(componentWidth, Internal._config.ContentHeight)
        InputField.BackgroundColor3 = Internal._config.FrameBgColor
        InputField.BackgroundTransparency = Internal._config.FrameBgTransparency
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.ClearTextOnFocus = false
        InputField.ZIndex = index
        InputField.LayoutOrder = index
        InputField.ClipsDescendants = true

        Utility.applyFrameStyle(InputField)
        Utility.applyTextStyle(InputField)
        Utility.UISizeConstraint(InputField, Vector2.xAxis)

        InputField.FocusLost:Connect(function()
            focusLost(thisWidget, InputField, index, dataType)
        end)

        InputField.Focused:Connect(function()
            -- this highlights the entire field
            InputField.CursorPosition = #InputField.Text + 1
            InputField.SelectionStart = 1

            thisWidget.state.editing:set(index)
        end)

        return InputField
    end

    function generateInputScalar<T>(dataType: InputDataTypes, components: number, defaultValue: T)
        local input = generateAbstract("Input", dataType, components, defaultValue)

        return Utility.extend(
            input,
            {
                Generate = function(thisWidget: Input<T>)
                    local Input = Instance.new("Frame")
                    Input.Name = "Iris_Input" .. dataType
                    Input.AutomaticSize = Enum.AutomaticSize.Y
                    Input.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
                    Input.BackgroundTransparency = 1
                    Input.BorderSizePixel = 0

                    Utility.UIListLayout(Input, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                    -- we add plus and minus buttons if there is only one box. This can be disabled through the argument.
                    local rightPadding = 0
                    local textHeight = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y

                    if components == 1 then
                        rightPadding = generateButtons(thisWidget :: any, Input, textHeight)
                    end

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth = UDim.new(Internal._config.ContentWidth.Scale / components, (Internal._config.ContentWidth.Offset - (Internal._config.ItemInnerSpacing.X * (components - 1)) - rightPadding) / components)
                    local totalWidth = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Internal._config.ItemInnerSpacing.X * (components - 1)) + rightPadding)
                    local lastComponentWidth = Internal._config.ContentWidth - totalWidth

                    -- we handle each component individually since they don't need to interact with each other.
                    for index = 1, components do
                        generateField(thisWidget, index, if index == components then lastComponentWidth else componentWidth, dataType).Parent = Input
                    end

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.LayoutOrder = 7

                    Utility.applyTextStyle(TextLabel)

                    TextLabel.Parent = Input

                    return Input
                end,
                UpdateState = function(thisWidget: Input<T>)
                    local Input = thisWidget.instance :: GuiObject

                    for index = 1, components do
                        local InputField: TextBox = Input:FindFirstChild("InputField" .. tostring(index))
                        local Format = thisWidget.arguments.Format
                        local Prefix = thisWidget.arguments.Prefix
                        local format = Format[index] or Format[1]
                        if Prefix then
                            format = Prefix[index] .. format
                        end
                        InputField.Text = string.format(format, getValueByIndex(thisWidget.state.number._value, index, thisWidget.arguments))
                    end
                end,
            } :: Types.WidgetClass
        )
    end
end

-------------
-- Drag<T>
-------------

--[[
        Drag
    ]]
local generateDragScalar: <T>(dataType: InputDataTypes, components: number, defaultValue: T) -> Types.WidgetClass
local generateColorDragScalar: (dataType: InputDataTypes, ...any) -> Types.WidgetClass
do
    local PreviouseMouseXPosition = 0
    local AnyActiveDrag = false
    local ActiveDrag: Input<InputDataType>? = nil
    local ActiveIndex = 0
    local ActiveDataType: InputDataTypes | "" = ""

    local function updateActiveDrag()
        local currentMouseX = Utility.getMouseLocation().X
        local mouseXDelta = currentMouseX - PreviouseMouseXPosition
        PreviouseMouseXPosition = currentMouseX
        if AnyActiveDrag == false then
            return
        end
        if ActiveDrag == nil then
            return
        end

        local state = ActiveDrag.state.number
        if ActiveDataType == "Color3" or ActiveDataType == "Color4" then
            local Drag = ActiveDrag
            state = Drag.state.color
            if ActiveIndex == 4 then
                state = Drag.state.transparency
            end
        end

        local increment = ActiveDrag.arguments.Increment and getValueByIndex(ActiveDrag.arguments.Increment, ActiveIndex, ActiveDrag.arguments) or defaultIncrements[ActiveDataType][ActiveIndex]
        increment *= (Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1
        increment *= (Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1
        -- we increase the speed for Color3 and Color4 since it's too slow because the increment argument needs to be low.
        increment *= (ActiveDataType == "Color3" or ActiveDataType == "Color4") and 5 or 1

        local value = getValueByIndex(state._value, ActiveIndex, ActiveDrag.arguments)
        local newValue = value + (mouseXDelta * increment)

        if ActiveDrag.arguments.Min ~= nil then
            newValue = math.max(newValue, getValueByIndex(ActiveDrag.arguments.Min, ActiveIndex, ActiveDrag.arguments))
        end
        if ActiveDrag.arguments.Max ~= nil then
            newValue = math.min(newValue, getValueByIndex(ActiveDrag.arguments.Max, ActiveIndex, ActiveDrag.arguments))
        end

        state:set(updateValueByIndex(state._value, ActiveIndex, newValue, ActiveDrag.arguments))
        ActiveDrag.lastNumberChangedTick = Internal._cycleTick + 1
    end

    local function DragMouseDown(thisWidget: Input<InputDataType>, dataTypes: InputDataTypes, index: number, x: number, y: number)
        local currentTime = Utility.getTime()
        local isTimeValid = currentTime - thisWidget.lastClickedTime < Internal._config.MouseDoubleClickTime
        local isCtrlHeld = Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if (isTimeValid and (Vector2.new(x, y) - thisWidget.lastClickedPosition).Magnitude < Internal._config.MouseDoubleClickMaxDist) or isCtrlHeld then
            thisWidget.state.editing:set(index)
        else
            thisWidget.lastClickedTime = currentTime
            thisWidget.lastClickedPosition = Vector2.new(x, y)

            AnyActiveDrag = true
            ActiveDrag = thisWidget
            ActiveIndex = index
            ActiveDataType = dataTypes
            updateActiveDrag()
        end
    end

    Utility.registerEvent("InputChanged", function()
        if not Internal._started then
            return
        end
        updateActiveDrag()
    end)

    Utility.registerEvent("InputEnded", function(inputObject: InputObject)
        if not Internal._started then
            return
        end
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveDrag then
            AnyActiveDrag = false
            ActiveDrag = nil
            ActiveIndex = 0
        end
    end)

    local function generateField<T>(thisWidget: Input<T>, index: number, componentSize: UDim2, dataType: InputDataTypes)
        local DragField = Instance.new("TextButton")
        DragField.Name = "DragField" .. tostring(index)
        DragField.AutomaticSize = Enum.AutomaticSize.Y
        DragField.Size = componentSize
        DragField.BackgroundColor3 = Internal._config.FrameBgColor
        DragField.BackgroundTransparency = Internal._config.FrameBgTransparency
        DragField.Text = ""
        DragField.AutoButtonColor = false
        DragField.LayoutOrder = index
        DragField.ClipsDescendants = true

        Utility.applyFrameStyle(DragField)
        Utility.applyTextStyle(DragField)
        Utility.UISizeConstraint(DragField, Vector2.xAxis)

        DragField.TextXAlignment = Enum.TextXAlignment.Center

        Utility.applyInteractionHighlights("Background", DragField, DragField, {
            Color = Internal._config.FrameBgColor,
            Transparency = Internal._config.FrameBgTransparency,
            HoveredColor = Internal._config.FrameBgHoveredColor,
            HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
            ActiveColor = Internal._config.FrameBgActiveColor,
            ActiveTransparency = Internal._config.FrameBgActiveTransparency,
        })

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        InputField.Size = UDim2.fromScale(1, 1)
        InputField.BackgroundTransparency = 1
        InputField.ClearTextOnFocus = false
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.ClipsDescendants = true
        InputField.Visible = false

        Utility.applyFrameStyle(InputField, true)
        Utility.applyTextStyle(InputField)

        InputField.Parent = DragField

        InputField.FocusLost:Connect(function()
            focusLost(thisWidget, InputField, index, dataType)
        end)

        InputField.Focused:Connect(function()
            -- this highlights the entire field
            InputField.CursorPosition = #InputField.Text + 1
            InputField.SelectionStart = 1

            thisWidget.state.editing:set(index)
        end)

        Utility.applyButtonDown(DragField, function(x: number, y: number)
            DragMouseDown(thisWidget :: any, dataType, index, x, y)
        end)

        return DragField
    end

    function generateDragScalar<T>(dataType: InputDataTypes, components: number, defaultValue: T)
        local input = generateAbstract("Drag", dataType, components, defaultValue)

        return Utility.extend(
            input,
            {
                Generate = function(thisWidget: Input<T>)
                    thisWidget.lastClickedTime = -1
                    thisWidget.lastClickedPosition = Vector2.zero

                    local Drag = Instance.new("Frame")
                    Drag.Name = "Iris_Drag" .. dataType
                    Drag.AutomaticSize = Enum.AutomaticSize.Y
                    Drag.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
                    Drag.BackgroundTransparency = 1
                    Drag.BorderSizePixel = 0

                    Utility.UIListLayout(Drag, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                    -- we add a color box if it is Color3 or Color4.
                    local rightPadding = 0
                    local textHeight = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y

                    if dataType == "Color3" or dataType == "Color4" then
                        rightPadding += Internal._config.ItemInnerSpacing.X + textHeight

                        local ColorBox = Instance.new("ImageLabel")
                        ColorBox.Name = "ColorBox"
                        ColorBox.Size = UDim2.fromOffset(textHeight, textHeight)
                        ColorBox.BorderSizePixel = 0
                        ColorBox.Image = Utility.ICONS.ALPHA_BACKGROUND_TEXTURE
                        ColorBox.ImageTransparency = 1
                        ColorBox.LayoutOrder = 5

                        Utility.applyFrameStyle(ColorBox, true)

                        ColorBox.Parent = Drag
                    end

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth = UDim.new(Internal._config.ContentWidth.Scale / components, (Internal._config.ContentWidth.Offset - (Internal._config.ItemInnerSpacing.X * (components - 1)) - rightPadding) / components)
                    local totalWidth = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Internal._config.ItemInnerSpacing.X * (components - 1)) + rightPadding)
                    local lastComponentWidth = Internal._config.ContentWidth - totalWidth

                    for index = 1, components do
                        generateField(thisWidget, index, if index == components then UDim2.new(lastComponentWidth, Internal._config.ContentHeight) else UDim2.new(componentWidth, Internal._config.ContentHeight), dataType).Parent = Drag
                    end

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.LayoutOrder = 6

                    Utility.applyTextStyle(TextLabel)

                    TextLabel.Parent = Drag

                    return Drag
                end,
                UpdateState = function(thisWidget: Input<T>)
                    local Drag = thisWidget.instance :: Frame

                    local widget = thisWidget :: any
                    for index = 1, components do
                        local state = thisWidget.state.number
                        if dataType == "Color3" or dataType == "Color4" then
                            state = widget.state.color
                            if index == 4 then
                                state = widget.state.transparency
                            end
                        end
                        local DragField = Drag:FindFirstChild("DragField" .. tostring(index)) :: TextButton
                        local InputField: TextBox = DragField.InputField
                        local value = getValueByIndex(state._value, index, thisWidget.arguments)
                        if (dataType == "Color3" or dataType == "Color4") and not btest(InputFlags.UseFloats, widget.arguments.Flags) then
                            value = math.round(value * 255)
                        end

                        local Format = thisWidget.arguments.Format
                        local Prefix = thisWidget.arguments.Prefix

                        local format = Format[index] or Format[1]
                        if Prefix then
                            format = Prefix[index] .. format
                        end
                        DragField.Text = string.format(format, value)
                        InputField.Text = tostring(value)

                        if thisWidget.state.editing._value == index then
                            InputField.Visible = true
                            InputField:CaptureFocus()
                            DragField.TextTransparency = 1
                        else
                            InputField.Visible = false
                            DragField.TextTransparency = Internal._config.TextTransparency
                        end
                    end

                    if dataType == "Color3" or dataType == "Color4" then
                        local ColorBox: ImageLabel = Drag.ColorBox

                        ColorBox.BackgroundColor3 = widget.state.color._value

                        if dataType == "Color4" then
                            ColorBox.ImageTransparency = 1 - widget.state.transparency._value
                        end
                    end
                end,
            } :: Types.WidgetClass
        )
    end

    function generateColorDragScalar(dataType: InputDataTypes, ...: any)
        local defaultValues = { ... }
        local input = generateDragScalar(dataType, dataType == "Color4" and 4 or 3, defaultValues[1])

        local class = Utility.extend(
            input,
            {
                numArguments = 3,
                Arguments = { "Text", "Flags", "Format", "colour", "editing" },
                Update = function(thisWidget: InputColor4)
                    local Input = thisWidget.instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or `Drag {dataType}`

                    if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                        thisWidget.arguments.Format = { thisWidget.arguments.Format }
                    elseif not thisWidget.arguments.Format then
                        if btest(InputFlags.UseFloats, thisWidget.arguments.Flags) then
                            thisWidget.arguments.Format = { "%.3f" }
                        else
                            thisWidget.arguments.Format = { "%d" }
                        end

                        thisWidget.arguments.Prefix = defaultPrefx[dataType .. if btest(InputFlags.UseHSV, thisWidget.arguments.Flags) then "_HSV" else "_RGB"]
                    end

                    thisWidget.arguments.Min = { 0, 0, 0, 0 }
                    thisWidget.arguments.Max = { 1, 1, 1, 1 }
                    thisWidget.arguments.Increment = { 0.001, 0.001, 0.001, 0.001 }

                    -- since the state values have changed display, we call an update. The check is because state is not
                    -- initialised on creation, so it would error otherwise.
                    if thisWidget.state then
                        thisWidget.state.color._lastChangeTick = Internal._cycleTick
                        if dataType == "Color4" then
                            thisWidget.state.transparency._lastChangeTick = Internal._cycleTick
                        end
                        Internal._widgets[thisWidget.type].UpdateState(thisWidget)
                    end
                end,
                GenerateState = function(thisWidget: InputColor4)
                    if thisWidget.state.color == nil then
                        thisWidget.state.color = Internal._widgetState(thisWidget, "color", defaultValues[1])
                    end
                    if dataType == "Color4" then
                        if thisWidget.state.transparency == nil then
                            thisWidget.state.transparency = Internal._widgetState(thisWidget, "transparency", defaultValues[2])
                        end
                    end
                    if thisWidget.state.editing == nil then
                        thisWidget.state.editing = Internal._widgetState(thisWidget, "editing", false)
                    end
                end,
            } :: Types.WidgetClass
        )

        if dataType == "Color4" then
            table.insert(class.Arguments, 5, "transparency")
        end

        return class
    end
end

---------------
-- Slider<T>
---------------

--[[
        Slider
    ]]
local generateSliderScalar: <T>(dataType: InputDataTypes, components: number, defaultValue: T) -> Types.WidgetClass
local generateEnumSliderScalar: (enum: Enum, item: EnumItem) -> Types.WidgetClass
do
    local AnyActiveSlider = false
    local ActiveSlider: Input<InputDataType>? = nil
    local ActiveIndex = 0
    local ActiveDataType: InputDataTypes | "" = ""

    local function updateActiveSlider()
        if AnyActiveSlider == false then
            return
        end
        if ActiveSlider == nil then
            return
        end

        local Slider = ActiveSlider.instance :: Frame
        local SliderField = Slider:FindFirstChild("SliderField" .. tostring(ActiveIndex)) :: TextButton
        local GrabBar: Frame = SliderField.GrabBar

        local increment = ActiveSlider.arguments.Increment and getValueByIndex(ActiveSlider.arguments.Increment, ActiveIndex, ActiveSlider.arguments) or defaultIncrements[ActiveDataType][ActiveIndex]
        local min = ActiveSlider.arguments.Min and getValueByIndex(ActiveSlider.arguments.Min, ActiveIndex, ActiveSlider.arguments) or defaultMin[ActiveDataType][ActiveIndex]
        local max = ActiveSlider.arguments.Max and getValueByIndex(ActiveSlider.arguments.Max, ActiveIndex, ActiveSlider.arguments) or defaultMax[ActiveDataType][ActiveIndex]

        local GrabWidth = GrabBar.AbsoluteSize.X
        local Offset = Utility.getMouseLocation().X - (SliderField.AbsolutePosition.X - Utility.guiOffset.X + GrabWidth / 2)
        local Ratio = Offset / (SliderField.AbsoluteSize.X - GrabWidth)
        local Positions = math.floor((max - min) / increment)
        local newValue = math.clamp(math.round(Ratio * Positions) * increment + min, min, max)

        ActiveSlider.state.number:set(updateValueByIndex(ActiveSlider.state.number._value, ActiveIndex, newValue, ActiveSlider.arguments))
        ActiveSlider.lastNumberChangedTick = Internal._cycleTick + 1
    end

    local function SliderMouseDown(thisWidget: Input<InputDataType>, dataType: InputDataTypes, index: number)
        local isCtrlHeld = Utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if isCtrlHeld then
            thisWidget.state.editing:set(index)
        else
            AnyActiveSlider = true
            ActiveSlider = thisWidget
            ActiveIndex = index
            ActiveDataType = dataType
            updateActiveSlider()
        end
    end

    Utility.registerEvent("InputChanged", function()
        if not Internal._started then
            return
        end
        updateActiveSlider()
    end)

    Utility.registerEvent("InputEnded", function(inputObject: InputObject)
        if not Internal._started then
            return
        end
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveSlider then
            AnyActiveSlider = false
            ActiveSlider = nil
            ActiveIndex = 0
            ActiveDataType = ""
        end
    end)

    local function generateField<T>(thisWidget: Input<T>, index: number, componentSize: UDim2, dataType: InputDataTypes)
        local SliderField = Instance.new("TextButton")
        SliderField.Name = "SliderField" .. tostring(index)
        SliderField.AutomaticSize = Enum.AutomaticSize.Y
        SliderField.Size = componentSize
        SliderField.BackgroundColor3 = Internal._config.FrameBgColor
        SliderField.BackgroundTransparency = Internal._config.FrameBgTransparency
        SliderField.Text = ""
        SliderField.AutoButtonColor = false
        SliderField.LayoutOrder = index
        SliderField.ClipsDescendants = true

        Utility.applyFrameStyle(SliderField)
        Utility.applyTextStyle(SliderField)
        Utility.UISizeConstraint(SliderField, Vector2.xAxis)

        local OverlayText = Instance.new("TextLabel")
        OverlayText.Name = "OverlayText"
        OverlayText.Size = UDim2.fromScale(1, 1)
        OverlayText.BackgroundTransparency = 1
        OverlayText.BorderSizePixel = 0
        OverlayText.ZIndex = 10
        OverlayText.ClipsDescendants = true

        Utility.applyTextStyle(OverlayText)

        OverlayText.TextXAlignment = Enum.TextXAlignment.Center

        OverlayText.Parent = SliderField

        Utility.applyInteractionHighlights("Background", SliderField, SliderField, {
            Color = Internal._config.FrameBgColor,
            Transparency = Internal._config.FrameBgTransparency,
            HoveredColor = Internal._config.FrameBgHoveredColor,
            HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
            ActiveColor = Internal._config.FrameBgActiveColor,
            ActiveTransparency = Internal._config.FrameBgActiveTransparency,
        })

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        InputField.Size = UDim2.fromScale(1, 1)
        InputField.BackgroundTransparency = 1
        InputField.ClearTextOnFocus = false
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.ClipsDescendants = true
        InputField.Visible = false

        Utility.applyFrameStyle(InputField, true)
        Utility.applyTextStyle(InputField)

        InputField.Parent = SliderField

        InputField.FocusLost:Connect(function()
            focusLost(thisWidget, InputField, index, dataType)
        end)

        InputField.Focused:Connect(function()
            -- this highlights the entire field
            InputField.CursorPosition = #InputField.Text + 1
            InputField.SelectionStart = 1

            thisWidget.state.editing:set(index)
        end)

        Utility.applyButtonDown(SliderField, function()
            SliderMouseDown(thisWidget :: any, dataType, index)
        end)

        local GrabBar = Instance.new("Frame")
        GrabBar.Name = "GrabBar"
        GrabBar.AnchorPoint = Vector2.new(0.5, 0.5)
        GrabBar.Position = UDim2.fromScale(0, 0.5)
        GrabBar.BackgroundColor3 = Internal._config.SliderGrabColor
        GrabBar.Transparency = Internal._config.SliderGrabTransparency
        GrabBar.BorderSizePixel = 0
        GrabBar.ZIndex = 5

        Utility.applyInteractionHighlights("Background", SliderField, GrabBar, {
            Color = Internal._config.SliderGrabColor,
            Transparency = Internal._config.SliderGrabTransparency,
            HoveredColor = Internal._config.SliderGrabColor,
            HoveredTransparency = Internal._config.SliderGrabTransparency,
            ActiveColor = Internal._config.SliderGrabActiveColor,
            ActiveTransparency = Internal._config.SliderGrabActiveTransparency,
        })

        if Internal._config.GrabRounding > 0 then
            Utility.UICorner(GrabBar, Internal._config.GrabRounding)
        end

        Utility.UISizeConstraint(GrabBar, Vector2.new(Internal._config.GrabMinSize, 0))

        GrabBar.Parent = SliderField

        return SliderField
    end

    function generateSliderScalar<T>(dataType: InputDataTypes, components: number, defaultValue: T)
        local input = generateAbstract("Slider", dataType, components, defaultValue)

        return Utility.extend(
            input,
            {
                Generate = function(thisWidget: Input<T>)
                    local Slider = Instance.new("Frame")
                    Slider.Name = "Iris_Slider" .. dataType
                    Slider.AutomaticSize = Enum.AutomaticSize.Y
                    Slider.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
                    Slider.BackgroundTransparency = 1
                    Slider.BorderSizePixel = 0

                    Utility.UIListLayout(Slider, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth = UDim.new(Internal._config.ContentWidth.Scale / components, (Internal._config.ContentWidth.Offset - (Internal._config.ItemInnerSpacing.X * (components - 1))) / components)
                    local totalWidth = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Internal._config.ItemInnerSpacing.X * (components - 1)))
                    local lastComponentWidth = Internal._config.ContentWidth - totalWidth

                    for index = 1, components do
                        generateField(thisWidget, index, if index == components then UDim2.new(lastComponentWidth, Internal._config.ContentHeight) else UDim2.new(componentWidth, Internal._config.ContentHeight), dataType).Parent = Slider
                    end

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.LayoutOrder = 5

                    Utility.applyTextStyle(TextLabel)

                    TextLabel.Parent = Slider

                    return Slider
                end,
                UpdateState = function(thisWidget: Input<T>)
                    local Slider = thisWidget.instance :: Frame

                    for index = 1, components do
                        local SliderField = Slider:FindFirstChild("SliderField" .. tostring(index)) :: TextButton
                        local InputField: TextBox = SliderField.InputField
                        local OverlayText: TextLabel = SliderField.OverlayText
                        local GrabBar: Frame = SliderField.GrabBar

                        local value = getValueByIndex(thisWidget.state.number._value, index, thisWidget.arguments)
                        local Format = thisWidget.arguments.Format
                        local Prefix = thisWidget.arguments.Prefix
                        local format = Format[index] or Format[1]
                        if Prefix then
                            format = Prefix[index] .. format
                        end

                        OverlayText.Text = string.format(format, value)
                        InputField.Text = tostring(value)

                        local increment = thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments) or defaultIncrements[dataType][index]
                        local min = thisWidget.arguments.Min and getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments) or defaultMin[dataType][index]
                        local max = thisWidget.arguments.Max and getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments) or defaultMax[dataType][index]

                        local SliderWidth = SliderField.AbsoluteSize.X
                        local PaddedWidth = SliderWidth - GrabBar.AbsoluteSize.X
                        local Ratio = (value - min) / (max - min)
                        local Positions = math.floor((max - min) / increment)
                        local ClampedRatio = math.clamp(math.floor((Ratio * Positions)) / Positions, 0, 1)
                        local PaddedRatio = ((PaddedWidth / SliderWidth) * ClampedRatio) + ((1 - (PaddedWidth / SliderWidth)) / 2)

                        GrabBar.Position = UDim2.fromScale(PaddedRatio, 0.5)

                        if thisWidget.state.editing._value == index then
                            InputField.Visible = true
                            OverlayText.Visible = false
                            GrabBar.Visible = false
                            InputField:CaptureFocus()
                        else
                            InputField.Visible = false
                            OverlayText.Visible = true
                            GrabBar.Visible = true
                        end
                    end
                end,
            } :: Types.WidgetClass
        )
    end

    function generateEnumSliderScalar(enum: Enum, item: EnumItem)
        local input: Types.WidgetClass = generateSliderScalar("Enum", 1, item.Value)
        local valueToName = { string }

        for _, enumItem in enum:GetEnumItems() do
            valueToName[enumItem._value] = enumItem.Name
        end

        return Utility.extend(
            input,
            {
                Arguments = {
                    ["Text"] = 1,
                },
                Update = function(thisWidget: InputEnum)
                    local Input = thisWidget.instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or "Input Enum"

                    thisWidget.arguments.Increment = 1
                    thisWidget.arguments.Min = 0
                    thisWidget.arguments.Max = #enum:GetEnumItems() - 1

                    local SliderField = Input:FindFirstChild("SliderField1") :: TextButton
                    local GrabBar: Frame = SliderField.GrabBar

                    local grabScaleSize = 1 / math.floor(#enum:GetEnumItems())

                    GrabBar.Size = UDim2.fromScale(grabScaleSize, 1)
                end,
                GenerateState = function(thisWidget: InputEnum)
                    if thisWidget.state.number == nil then
                        thisWidget.state.number = Internal._widgetState(thisWidget, "number", item.Value)
                    end
                    if thisWidget.state.enum == nil then
                        thisWidget.state.enum = Internal._widgetState(thisWidget, "enum", item)
                    end
                    if thisWidget.state.editing == nil then
                        thisWidget.state.editing = Internal._widgetState(thisWidget, "editing", false)
                    end
                end,
            } :: Types.WidgetClass
        )
    end
end

---------------
-- Input<T>
-- Drag<T>
-- Slider<T>
---------------

do
    local inputNum: Types.WidgetClass = generateInputScalar("Num", 1, 0)
    table.insert(inputNum.Arguments, 6, "NoButtons")
    Internal._widgetConstructor("InputNum", inputNum)
end
Internal._widgetConstructor("InputVector2", generateInputScalar("Vector2", 2, Vector2.zero))
Internal._widgetConstructor("InputVector3", generateInputScalar("Vector3", 3, Vector3.zero))
Internal._widgetConstructor("InputUDim", generateInputScalar("UDim", 2, UDim.new()))
Internal._widgetConstructor("InputUDim2", generateInputScalar("UDim2", 4, UDim2.new()))
Internal._widgetConstructor("InputRect", generateInputScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

Internal._widgetConstructor("DragNum", generateDragScalar("Num", 1, 0))
Internal._widgetConstructor("DragVector2", generateDragScalar("Vector2", 2, Vector2.zero))
Internal._widgetConstructor("DragVector3", generateDragScalar("Vector3", 3, Vector3.zero))
Internal._widgetConstructor("DragUDim", generateDragScalar("UDim", 2, UDim.new()))
Internal._widgetConstructor("DragUDim2", generateDragScalar("UDim2", 4, UDim2.new()))
Internal._widgetConstructor("DragRect", generateDragScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

Internal._widgetConstructor("InputColor3", generateColorDragScalar("Color3", Color3.fromRGB(0, 0, 0)))
Internal._widgetConstructor("InputColor4", generateColorDragScalar("Color4", Color3.fromRGB(0, 0, 0), 0))

Internal._widgetConstructor("SliderNum", generateSliderScalar("Num", 1, 0))
Internal._widgetConstructor("SliderVector2", generateSliderScalar("Vector2", 2, Vector2.zero))
Internal._widgetConstructor("SliderVector3", generateSliderScalar("Vector3", 3, Vector3.zero))
Internal._widgetConstructor("SliderUDim", generateSliderScalar("UDim", 2, UDim.new()))
Internal._widgetConstructor("SliderUDim2", generateSliderScalar("UDim2", 4, UDim2.new()))
Internal._widgetConstructor("SliderRect", generateSliderScalar("Rect", 4, Rect.new(0, 0, 0, 0)))
-- Internal._widgetConstructor("SliderEnum", generateSliderScalar("Enum", 4, 0))

--------------
-- InpuText
--------------

Internal._widgetConstructor(
    "InputText",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 3,
        Arguments = { "Text", "TextHint", "Flags", "text" },
        Events = {
            ["textChanged"] = {
                ["Init"] = function(thisWidget: InputText)
                    thisWidget.lastTextChangedTick = 0
                end,
                ["Get"] = function(thisWidget: InputText)
                    return thisWidget.lastTextChangedTick == Internal._cycleTick
                end,
            },
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: InputText)
            local InputText: Frame = Instance.new("Frame")
            InputText.Name = "Iris_InputText"
            InputText.AutomaticSize = Enum.AutomaticSize.Y
            InputText.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            InputText.BackgroundTransparency = 1
            InputText.BorderSizePixel = 0
            Utility.UIListLayout(InputText, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local InputField: TextBox = Instance.new("TextBox")
            InputField.Name = "InputField"
            InputField.AutomaticSize = Enum.AutomaticSize.Y
            InputField.Size = UDim2.new(Internal._config.ContentWidth, Internal._config.ContentHeight)
            InputField.BackgroundColor3 = Internal._config.FrameBgColor
            InputField.BackgroundTransparency = Internal._config.FrameBgTransparency
            InputField.Text = ""
            InputField.TextYAlignment = Enum.TextYAlignment.Top
            InputField.PlaceholderColor3 = Internal._config.TextDisabledColor
            InputField.ClearTextOnFocus = false
            InputField.ClipsDescendants = true

            Utility.applyFrameStyle(InputField)
            Utility.applyTextStyle(InputField)
            Utility.UISizeConstraint(InputField, Vector2.xAxis) -- prevents sizes beaking when getting too small.
            -- InputField.UIPadding.PaddingLeft = UDim.new(0, Internal._config.ItemInnerSpacing.X)
            -- InputField.UIPadding.PaddingRight = UDim.new(0, 0)
            InputField.Parent = InputText

            InputField.FocusLost:Connect(function()
                thisWidget.state.text:set(InputField.Text)
                thisWidget.lastTextChangedTick = Internal._cycleTick + 1
            end)

            local frameHeight: number = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.Size = UDim2.fromOffset(0, frameHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.LayoutOrder = 1

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = InputText

            return InputText
        end,
        GenerateState = function(thisWidget: InputText)
            if thisWidget.state.text == nil then
                thisWidget.state.text = Internal._widgetState(thisWidget, "text", "")
            end
        end,
        Update = function(thisWidget: InputText)
            local InputText = thisWidget.instance :: Frame
            local TextLabel: TextLabel = InputText.TextLabel
            local InputField: TextBox = InputText.InputField

            TextLabel.Text = thisWidget.arguments.Text or "Input Text"
            InputField.PlaceholderText = thisWidget.arguments.TextHint or ""
            InputField.TextEditable = not btest(InputTextFlags.ReadOnly, thisWidget.arguments.Flags)
            InputField.MultiLine = btest(InputTextFlags.MultiLine, thisWidget.arguments.Flags)
        end,
        UpdateState = function(thisWidget: InputText)
            local InputText = thisWidget.instance :: Frame
            local InputField: TextBox = InputText.InputField

            InputField.Text = thisWidget.state.text._value
        end,
        Discard = function(thisWidget: InputText)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

return {
    InputFlags = InputFlags,
    InputTextFlags = InputTextFlags,
}
