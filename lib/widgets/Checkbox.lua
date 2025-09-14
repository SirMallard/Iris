local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

--[=[
    @within Basic
    @interface Checkbox
    .& Widget
    .checked () -> boolean -- once when checked
    .unchecked () -> boolean -- once when unchecked
    .hovered () -> boolean -- fires when the mouse hovers over any of the widget

    .arguments { Text: string? }
    .state { checked: State<boolean> }
]=]
export type Checkbox = Types.Widget & {
    arguments: {
        Text: string?,
    },

    state: {
        checked: Types.State<boolean>,
    },
} & Types.Unchecked & Types.Checked & Types.Hovered

--------------
-- Checkbox
--------------

Internal._widgetConstructor(
    "Checkbox",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 1,
        Arguments = { "Text", "checked" },
        Events = {
            ["checked"] = {
                ["Init"] = function(_thisWidget: Checkbox) end,
                ["Get"] = function(thisWidget: Checkbox)
                    return thisWidget._lastCheckedTick == Internal._cycleTick
                end,
            },
            ["unchecked"] = {
                ["Init"] = function(_thisWidget: Checkbox) end,
                ["Get"] = function(thisWidget: Checkbox)
                    return thisWidget._lastUncheckedTick == Internal._cycleTick
                end,
            },
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
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
            Checkmark.ImageContent = Utility.ICONS.CHECK_MARK
            Checkmark.ImageColor3 = Internal._config.CheckMarkColor
            Checkmark.ImageTransparency = 1
            Checkmark.ScaleType = Enum.ScaleType.Fit

            Checkmark.Parent = Box

            Utility.applyButtonClick(Checkbox, function()
                thisWidget.state.checked:set(not thisWidget.state.checked._value)
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
        GenerateState = function(thisWidget: Checkbox)
            if thisWidget.state.checked == nil then
                thisWidget.state.checked = Internal._widgetState(thisWidget, "checked", false)
            end
        end,
        Update = function(thisWidget: Checkbox)
            local Checkbox = thisWidget.instance :: TextButton
            Checkbox.TextLabel.Text = thisWidget.arguments.Text or "Checkbox"
        end,
        UpdateState = function(thisWidget: Checkbox)
            local Checkbox = thisWidget.instance :: TextButton
            local Box = Checkbox.Box :: Frame
            local Checkmark: ImageLabel = Box.Checkmark
            if thisWidget.state.checked._value then
                Checkmark.ImageTransparency = Internal._config.CheckMarkTransparency
                thisWidget._lastCheckedTick = Internal._cycleTick + 1
            else
                Checkmark.ImageTransparency = 1
                thisWidget._lastUncheckedTick = Internal._cycleTick + 1
            end
        end,
        Discard = function(thisWidget: Checkbox)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

--[=[
    @within Basic
    @tag Widget
    @tag HasState

    @function Checkbox
    @param text string
    @param checked Types.State<boolean>? -- checkbox state

    @return Checkbox
    
    A checkable box with a visual tick to represent a boolean true or false state.
]=]
local API_Checkbox = function(text: string, checked: Types.State<boolean>?)
    return Internal._insert("Checkbox", text, checked) :: Checkbox
end

return {
    API_Checkbox = API_Checkbox,
}
