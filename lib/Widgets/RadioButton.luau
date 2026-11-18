const Internal = require("../Internal")
const Utility = require("../Widgets")

const Types = require("../Types")

export type RadioButton = Types.Widget & {
    arguments: {
        Label: string?, --
        Value: any, -- value of the state when active
    },

    state: {
        value: Types.State<any>, -- global state set to the value of the active button
    },

    instance: TextButton,
} & Types.Selected & Types.Unselected & Types.Active & Types.Clicked & Types.Changed & Types.Hovered

-----------------
-- RadioButton
-----------------

--[=[
    A circular selectable button, changing the value state to its Value
    argument, when clicked.
    
    Used with multiple other RadioButtons sharing the same state to produce
    a list of selectable options.

    ```lua
    Iris.Text("Select a fruit:")
    local state = Iris.State("")
    Iris.RadioButton("Apple", "Apple", state)
    Iris.RadioButton("")
    ```
]=]
Internal._widgetConstructor(
    "RadioButton",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 2,
        Arguments = { "Label", "Value", "value" },
        Events = {
            ["selected"] = Utility.EVENTS.select,
            ["unselected"] = Utility.EVENTS.unselect,
            ["active"] = {
                ["Init"] = function(_thisWidget) end,
                ["Get"] = function(thisWidget: RadioButton)
                    return thisWidget.state.value._value == thisWidget.arguments.Value
                end,
            },
            ["clicked"] = Utility.EVENTS.click(function(thisWidget)
                return thisWidget.instance :: TextButton
            end),
            ["changed"] = Utility.EVENTS.change("value"),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget)
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
                thisWidget.state.value:set(thisWidget.arguments.Value)
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
            local RadioButton = thisWidget.instance
            local TextLabel: TextLabel = (RadioButton :: any).TextLabel

            TextLabel.Text = thisWidget.arguments.Label or "Radio Button"
            if thisWidget.state then
                thisWidget.state.value._lastChangeTick = Internal._cycleTick;
                (Internal._widgets[thisWidget.type] :: any).UpdateState(thisWidget)
            end
        end,
        Discard = function(thisWidget: RadioButton)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget :: any)
        end,
        GenerateState = function(thisWidget: RadioButton)
            if thisWidget.state.value == nil then
                thisWidget.state.value = Internal._widgetState(thisWidget, "value", thisWidget.arguments.Value)
            end
        end,
        UpdateState = function(thisWidget: RadioButton)
            local RadioButton = thisWidget.instance
            local Button: Frame = (RadioButton :: any).Button
            local Circle: Frame = (Button :: any).Circle

            if thisWidget.state.value._value == thisWidget.arguments.Value then
                -- only need to hide the circle
                Circle.BackgroundTransparency = Internal._config.CheckMarkTransparency
            else
                Circle.BackgroundTransparency = 1
            end
        end,
    } :: Types.WidgetClass
)
