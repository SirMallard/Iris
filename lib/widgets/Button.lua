local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

--[=[
    @class Basic
    Basic Widget API
]=]

--[=[
    @within Basic
    @interface Button
    .& Widget
    .clicked () -> boolean -- fires when a button is clicked
    .rightClicked () -> boolean -- fires when a button is right clicked
    .doubleClicked () -> boolean -- fires when a button is double clicked
    .ctrlClicked () -> boolean -- fires when a button is ctrl clicked
    .hovered () -> boolean -- fires when the mouse hovers over any of the window
    
    .arguments { Text: string?, Size: UDim2? }
]=]
export type Button = Types.Widget & {
    arguments: {
        Text: string?,
        Size: UDim2?,
    },
} & Types.Clicked & Types.RightClicked & Types.DoubleClicked & Types.CtrlClicked & Types.Hovered

Utility.abstractButton = {
    hasState = false,
    hasChildren = false,
    numArguments = 2,
    Arguments = { "Text", "Size" },
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

Internal._widgetConstructor(
    "SmallButton",
    Utility.extend(
        Utility.abstractButton,
        {
            Generate = function(thisWidget: Button)
                local SmallButton = Utility.abstractButton.Generate(thisWidget)
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

--[=[
    @within Basic
    @tag Widget
    
    @function Button
    @param text string
    @param size UDim2? -- minimum button size, default 0
    
    @return Button
    
    A clickable button the size of the text with padding. Can listen to the `clicked()` event to determine if it was pressed.
]=]
local API_Button = function(text: string, size: UDim2?)
    return Internal._insert("Button", text, size) :: Button
end

--[=[
    @within Basic
    @tag Widget

    @function SmallButton
    @param text string
    @param size UDim2? -- minimum button size, default 0
    
    @return Button
    
    A smaller clickable button, the same as a [Iris.Button](Basic#Button) but without padding. Can listen to the `clicked()` event to determine if it was pressed.
]=]
local API_SmallButton = function(text: string, size: UDim2?)
    return Internal._insert("SmallButton", text, size) :: Button
end

return {
    API_Button = API_Button,
    API_SmallButton = API_SmallButton,
}
