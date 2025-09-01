local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

export type Button = Types.Widget & {
    arguments: {
        Text: string?,
        Size: UDim2?,
    },
} & Types.Clicked & Types.RightClicked & Types.DoubleClicked & Types.CtrlClicked & Types.Hovered

local abstractButton = {
    hasState = false,
    hasChildren = false,
    numArguments = 2,
    numStates = 0,
    Arguments = { "Text", "Size" },
    Events = {
        ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
            return thisWidget.instance
        end),
        ["rightClicked"] = Utility.EVENTS.rightClick(function(thisWidget: Types.Widget)
            return thisWidget.instance
        end),
        ["doubleClicked"] = Utility.EVENTS.doubleClick(function(thisWidget: Types.Widget)
            return thisWidget.instance
        end),
        ["ctrlClicked"] = Utility.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
            return thisWidget.instance
        end),
        ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
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
        local Button = thisWidget.instance :: TextButton
        Button.Text = thisWidget.arguments.Text or "Button"
        Button.Size = thisWidget.arguments.Size or UDim2.fromOffset(0, 0)
    end,
    Discard = function(thisWidget: Button)
        thisWidget.instance:Destroy()
    end,
} :: Types.WidgetClass

------------
-- Button
------------

Internal._widgetConstructor(
    "Button",
    Utility.extend(
        abstractButton,
        {
            Generate = function(thisWidget: Button)
                local Button = abstractButton.Generate(thisWidget)
                Button.Name = "Iris_Button"

                return Button
            end,
        } :: Types.WidgetClass
    )
)

-----------------
-- SmallButton
-----------------

Internal._widgetConstructor(
    "SmallButton",
    Utility.extend(
        abstractButton,
        {
            Generate = function(thisWidget: Button)
                local SmallButton = abstractButton.Generate(thisWidget)
                SmallButton.Name = "Iris_SmallButton"

                local uiPadding: UIPadding = SmallButton.UIPadding
                uiPadding.PaddingLeft = UDim.new(0, 2)
                uiPadding.PaddingRight = UDim.new(0, 2)
                uiPadding.PaddingTop = UDim.new(0, 0)
                uiPadding.PaddingBottom = UDim.new(0, 0)

                return SmallButton
            end,
        } :: Types.WidgetClass
    )
)
