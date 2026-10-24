const Internal = require("../Internal")
const Utility = require("../Widgets")

const Types = require("../Types")

--[=[
    @class Basic
    Basic Widget API
]=]

export type Button = Types.Widget & {
    instance: Types.UIInstance<TextButton>,

    arguments: {
        Label: string?, --
        Size: UDim2?, -- minimum button size (default: UDim2.new())
    },
} & Types.Clicked & Types.RightClicked & Types.DoubleClicked & Types.CtrlClicked & Types.Hovered

Utility.abstractButton = {
    hasState = false,
    hasChildren = false,
    numArguments = 2,
    Arguments = { "Label", "Size" },
    Events = {
        ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
            return thisWidget.instance :: GuiButton
        end),
        ["rightClicked"] = Utility.EVENTS.rightClick(function(thisWidget: Types.Widget)
            return thisWidget.instance :: GuiButton
        end),
        ["doubleClicked"] = Utility.EVENTS.doubleClick(function(thisWidget: Types.Widget)
            return thisWidget.instance :: GuiButton
        end),
        ["ctrlClicked"] = Utility.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
            return thisWidget.instance :: GuiButton
        end),
        ["hovered"] = Utility.EVENTS.hover(function(thisWidget)
            return thisWidget.instance
        end),
    },
    Generate = function(_thisWidget: Button)
        local Button = Instance.new("TextButton")
        Button.AutomaticSize = Enum.AutomaticSize.XY
        Button.Size = UDim2.fromOffset(0, 0)
        Button.BackgroundColor3 = Internal._config.ButtonColor
        Button.BackgroundTransparency = Internal._config.ButtonTransparency
        Button.AutoButtonColor = false

        Utility.applyTextStyle(Button)
        Button.TextXAlignment = Enum.TextXAlignment.Center

        Utility.applyFrameStyle(Button)

        Utility.applyInteractionHighlights("Background", Button, Button, {
            Color = Internal._config.ButtonColor,
            Transparency = Internal._config.ButtonTransparency,
            HoveredColor = Internal._config.ButtonHoveredColor,
            HoveredTransparency = Internal._config.ButtonHoveredTransparency,
            ActiveColor = Internal._config.ButtonActiveColor,
            ActiveTransparency = Internal._config.ButtonActiveTransparency,
        })

        return Button
    end,
    Update = function(thisWidget: Button)
        local Button = thisWidget.instance
        Button.Text = thisWidget.arguments.Label or "Button"
        Button.Size = thisWidget.arguments.Size or UDim2.new()
    end,
    Discard = function(thisWidget: Button)
        thisWidget.instance:Destroy()
    end,
} :: Types.WidgetClass

------------
-- Button
------------

--[=[
    A pressable button the size of the label with padding. Can be given a minmum size using the `Size` argument.

    Use the `clicked()` event to check if the button was pressed.
]=]
Internal._widgetConstructor(
    "Button",
    Utility.extend(
        Utility.abstractButton,
        {
            Generate = function(thisWidget: Button)
                local Button = Utility.abstractButton.Generate(thisWidget)
                Button.Name = "Iris_Button"

                return Button
            end,
        } :: Types.WidgetClass
    )
)

-----------------
-- SmallButton
-----------------

--[=[
    The same as [Iris.Button](Basic#Button) but without any padding.

    Use the `clicked()` event to check if the button was pressed.
]=]
Internal._widgetConstructor(
    "SmallButton",
    Utility.extend(
        Utility.abstractButton,
        {
            Generate = function(thisWidget: Button)
                local SmallButton = Utility.abstractButton.Generate(thisWidget) :: Types.UIInstance<TextButton>
                SmallButton.Name = "Iris_SmallButton"

                local uiPadding = SmallButton.UIPadding
                uiPadding.PaddingLeft = UDim.new(0, 2)
                uiPadding.PaddingRight = UDim.new(0, 2)
                uiPadding.PaddingTop = UDim.new(0, 0)
                uiPadding.PaddingBottom = UDim.new(0, 0)

                return SmallButton
            end,
        } :: Types.WidgetClass
    )
)
