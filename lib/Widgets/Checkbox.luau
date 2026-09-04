const Internal = require("../Internal")
const Utility = require("../Widgets")

const Types = require("../Types")

export type Checkbox = Types.Widget & {
    arguments: {
        Label: string?,
    },

    state: {
        value: Types.State<boolean>, -- checkbox state
    },
} & Types.Checked & Types.Unchecked & Types.Hovered

export type CheckboxFlags = Types.Widget & {
    arguments: {
        Label: string?,
        Bit: number, -- bit which the checkbox changes
    },

    state: {
        flags: Types.State<number>, -- bit flags state
    },
} & Types.Checked & Types.Unchecked & Types.Hovered

local abstractCheckbox = {
    hasState = true,
    hasChildren = false,
    numArguments = 1,
    Arguments = { "Label", "checked" },
    Events = {
        ["checked"] = Utility.EVENTS.check,
        ["unchecked"] = Utility.EVENTS.uncheck,
        ["hovered"] = Utility.EVENTS.hover(function(thisWidget)
            return thisWidget.instance
        end),
    },
    Generate = function(thisWidget: Checkbox)
        local Checkbox = Instance.new("TextButton")
        Checkbox.Name = "Iris_Checkbox"
        Checkbox.AutomaticSize = Enum.AutomaticSize.XY
        Checkbox.Size = UDim2.fromOffset(0, 0)
        Checkbox.BackgroundTransparency = 1
        Checkbox.BorderSizePixel = 0
        Checkbox.Text = ""
        Checkbox.AutoButtonColor = false

        Utility.UIListLayout(Checkbox, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

        local checkboxSize = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y

        local Box = Instance.new("Frame")
        Box.Name = "Box"
        Box.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
        Box.BackgroundColor3 = Internal._config.FrameBgColor
        Box.BackgroundTransparency = Internal._config.FrameBgTransparency

        Utility.applyFrameStyle(Box, true)
        Utility.UIPadding(Box, Vector2.new(math.floor(checkboxSize / 10), math.floor(checkboxSize / 10)))

        Utility.applyInteractionHighlights("Background", Checkbox, Box, {
            Color = Internal._config.FrameBgColor,
            Transparency = Internal._config.FrameBgTransparency,
            HoveredColor = Internal._config.FrameBgHoveredColor,
            HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
            ActiveColor = Internal._config.FrameBgActiveColor,
            ActiveTransparency = Internal._config.FrameBgActiveTransparency,
        })

        Box.Parent = Checkbox

        local Checkmark = Instance.new("ImageLabel")
        Checkmark.Name = "Checkmark"
        Checkmark.Size = UDim2.fromScale(1, 1)
        Checkmark.BackgroundTransparency = 1
        Checkmark.ImageContent = Utility.ICONS.CHECKMARK
        Checkmark.ImageColor3 = Internal._config.CheckMarkColor
        Checkmark.ImageTransparency = 1
        Checkmark.ScaleType = Enum.ScaleType.Fit

        Checkmark.Parent = Box

        Utility.applyButtonClick(Checkbox, function()
            if thisWidget.type == "Checkbox" then
                thisWidget.state.value:set(not thisWidget.state.value._value)
            else
                local checkboxFlags: CheckboxFlags = thisWidget :: any
                checkboxFlags.state.flags:set(bit32.bxor(checkboxFlags.state.flags._value, checkboxFlags.arguments.Bit))
            end
        end)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.LayoutOrder = 1

        Utility.applyTextStyle(TextLabel)
        TextLabel.Parent = Checkbox

        return Checkbox
    end,
    Update = function(thisWidget: Checkbox)
        local Checkbox = thisWidget.instance :: TextButton
        (Checkbox :: any).TextLabel.Text = thisWidget.arguments.Label or "Checkbox"
    end,
    UpdateState = function(thisWidget: Checkbox)
        local Checkbox = thisWidget.instance :: TextButton
        local Box = (Checkbox :: any).Box :: Frame
        local Checkmark: ImageLabel = (Box :: any).Checkmark

        local checked = false
        if thisWidget.type == "Checkbox" then
            if thisWidget.state.value._value then
                checked = true
            end
        else
            local checkboxFlags: CheckboxFlags = thisWidget :: any
            if bit32.btest(checkboxFlags.state.flags._value, checkboxFlags.arguments.Bit) then
                checked = true
            end
        end

        if checked then
            Checkmark.ImageTransparency = Internal._config.CheckMarkTransparency
        else
            Checkmark.ImageTransparency = 1
        end
    end,
    Discard = function(thisWidget: Checkbox)
        thisWidget.instance:Destroy()
        Utility.discardState(thisWidget)
    end,
} :: Types.WidgetClass

--------------
-- Checkbox
--------------

--[[
    A checkable box with a visual tick to represent a boolean true or false state.
]]
Internal._widgetConstructor(
    "Checkbox",
    Utility.extend(
        abstractCheckbox,
        {
            numArguments = 1,
            Arguments = { "Label", "check" },
            GenerateState = function(thisWidget: Checkbox)
                if thisWidget.state.value == nil then
                    thisWidget.state.value = Internal._widgetState(thisWidget, "value", false)
                end
            end,
        } :: Types.WidgetClass
    )
)

--[[
    A checkable box with a visual tick to represent a boolean true or false state.
]]
Internal._widgetConstructor(
    "CheckboxFlags",
    Utility.extend(
        abstractCheckbox,
        {
            numArguments = 2,
            Arguments = { "Label", "Bit", "flags" },
            GenerateState = function(thisWidget: CheckboxFlags)
                if thisWidget.state.flags == nil then
                    thisWidget.state.flags = Internal._widgetState(thisWidget, "flags", 0)
                end
            end,
        } :: Types.WidgetClass
    )
)
