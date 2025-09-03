local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

export type RadioButton = Types.Widget & {
    arguments: {
        Text: string?,
        Index: any,
    },

    state: {
        index: Types.State<any>,
    },

    active: () -> boolean,
} & Types.Selected & Types.Unselected & Types.Active & Types.Hovered

-----------------
-- RadioButton
-----------------

Internal._widgetConstructor(
    "RadioButton",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 2,
        Arguments = { "Text", "Index", "index" },
        Events = {
            ["selected"] = {
                ["Init"] = function(_thisWidget: RadioButton) end,
                ["Get"] = function(thisWidget: RadioButton)
                    return thisWidget._lastSelectedTick == Internal._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: RadioButton) end,
                ["Get"] = function(thisWidget: RadioButton)
                    return thisWidget._lastUnselectedTick == Internal._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: RadioButton) end,
                ["Get"] = function(thisWidget: RadioButton)
                    return thisWidget.state.index._value == thisWidget.arguments.Index
                end,
            },
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: RadioButton)
            local RadioButton = Instance.new("TextButton")
            RadioButton.Name = "Iris_RadioButton"
            RadioButton.AutomaticSize = Enum.AutomaticSize.XY
            RadioButton.Size = UDim2.fromOffset(0, 0)
            RadioButton.BackgroundTransparency = 1
            RadioButton.BorderSizePixel = 0
            RadioButton.Text = ""
            RadioButton.AutoButtonColor = false

            Utility.UIListLayout(RadioButton, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local buttonSize = Internal._config.TextSize + 2 * (Internal._config.FramePadding.Y - 1)
            local Button = Instance.new("Frame")
            Button.Name = "Button"
            Button.Size = UDim2.fromOffset(buttonSize, buttonSize)
            Button.BackgroundColor3 = Internal._config.FrameBgColor
            Button.BackgroundTransparency = Internal._config.FrameBgTransparency
            Button.Parent = RadioButton

            Utility.UICorner(Button)
            Utility.UIPadding(Button, Vector2.new(math.max(1, math.floor(buttonSize / 5)), math.max(1, math.floor(buttonSize / 5))))

            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Size = UDim2.fromScale(1, 1)
            Circle.BackgroundColor3 = Internal._config.CheckMarkColor
            Circle.BackgroundTransparency = Internal._config.CheckMarkTransparency
            Utility.UICorner(Circle)

            Circle.Parent = Button

            Utility.applyInteractionHighlights("Background", RadioButton, Button, {
                Color = Internal._config.FrameBgColor,
                Transparency = Internal._config.FrameBgTransparency,
                HoveredColor = Internal._config.FrameBgHoveredColor,
                HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
                ActiveColor = Internal._config.FrameBgActiveColor,
                ActiveTransparency = Internal._config.FrameBgActiveTransparency,
            })

            Utility.applyButtonClick(RadioButton, function()
                thisWidget.state.index:set(thisWidget.arguments.Index)
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.LayoutOrder = 1

            Utility.applyTextStyle(TextLabel)
            TextLabel.Parent = RadioButton

            return RadioButton
        end,
        Update = function(thisWidget: RadioButton)
            local RadioButton = thisWidget.instance :: TextButton
            local TextLabel: TextLabel = RadioButton.TextLabel

            TextLabel.Text = thisWidget.arguments.Text or "Radio Button"
            if thisWidget.state then
                thisWidget.state.index._lastChangeTick = Internal._cycleTick
                Internal._widgets[thisWidget.type].UpdateState(thisWidget)
            end
        end,
        Discard = function(thisWidget: RadioButton)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: RadioButton)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Internal._widgetState(thisWidget, "index", thisWidget.arguments.Index)
            end
        end,
        UpdateState = function(thisWidget: RadioButton)
            local RadioButton = thisWidget.instance :: TextButton
            local Button = RadioButton.Button :: Frame
            local Circle: Frame = Button.Circle

            if thisWidget.state.index._value == thisWidget.arguments.Index then
                -- only need to hide the circle
                Circle.BackgroundTransparency = Internal._config.CheckMarkTransparency
                thisWidget._lastSelectedTick = Internal._cycleTick + 1
            else
                Circle.BackgroundTransparency = 1
                thisWidget._lastUnselectedTick = Internal._cycleTick + 1
            end
        end,
    } :: Types.WidgetClass
)

return {}
