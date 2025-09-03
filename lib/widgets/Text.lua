local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

export type Text = Types.Widget & {
    arguments: {
        Text: string,
        Flags: number,
        Color: Color3?,
    },
} & Types.Hovered

export type SeparatorText = Types.Widget & {
    arguments: {
        Text: string,
    },
} & Types.Hovered

local TextFlags = {
    Wrapped = 1,
    RichText = 2,
}

----------
-- Text
----------

Internal._widgetConstructor(
    "Text",
    {
        hasState = false,
        hasChildren = false,
        numArguments = 3,
        Arguments = { "Text", "Flags", "Color" },
        Events = {
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(_thisWidget: Text)
            local Text = Instance.new("TextLabel")
            Text.Name = "Iris_Text"
            Text.AutomaticSize = Enum.AutomaticSize.XY
            Text.Size = UDim2.fromOffset(0, 0)
            Text.BackgroundTransparency = 1
            Text.BorderSizePixel = 0

            Utility.applyTextStyle(Text)
            Utility.UIPadding(Text, Vector2.new(0, 2))

            return Text
        end,
        Update = function(thisWidget: Text)
            local Text = thisWidget.instance :: TextLabel
            if thisWidget.arguments.Text == nil then
                error("Text argument is required for Iris.Text().", 5)
            end

            Text.Text = thisWidget.arguments.Text
            Text.TextWrapped = btest(TextFlags.Wrapped, thisWidget.arguments.Flags) or Internal._config.TextWrapped
            Text.RichText = btest(TextFlags.RichText, thisWidget.arguments.Flags) or Internal._config.RichText
            Text.TextColor3 = thisWidget.arguments.Color or Internal._config.TextColor
        end,
        Discard = function(thisWidget: Text)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

-------------------
-- SeparatorText
-------------------

Internal._widgetConstructor(
    "SeparatorText",
    {
        hasState = false,
        hasChildren = false,
        numArguments = 1,
        Arguments = { "Text" },
        Events = {
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(_thisWidget: SeparatorText)
            local SeparatorText = Instance.new("Frame")
            SeparatorText.Name = "Iris_SeparatorText"
            SeparatorText.AutomaticSize = Enum.AutomaticSize.Y
            SeparatorText.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            SeparatorText.BackgroundTransparency = 1
            SeparatorText.BorderSizePixel = 0
            SeparatorText.ClipsDescendants = true

            Utility.UIPadding(SeparatorText, Vector2.new(0, Internal._config.SeparatorTextPadding.Y))
            Utility.UIListLayout(SeparatorText, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemSpacing.X))

            SeparatorText.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.LayoutOrder = 1

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = SeparatorText

            local Left = Instance.new("Frame")
            Left.Name = "Left"
            Left.AnchorPoint = Vector2.new(1, 0.5)
            Left.Size = UDim2.fromOffset(Internal._config.SeparatorTextPadding.X - Internal._config.ItemSpacing.X, Internal._config.SeparatorTextBorderSize)
            Left.BackgroundColor3 = Internal._config.SeparatorColor
            Left.BackgroundTransparency = Internal._config.SeparatorTransparency
            Left.BorderSizePixel = 0

            Left.Parent = SeparatorText

            local Right = Instance.new("Frame")
            Right.Name = "Right"
            Right.AnchorPoint = Vector2.new(1, 0.5)
            Right.Size = UDim2.new(1, 0, 0, Internal._config.SeparatorTextBorderSize)
            Right.BackgroundColor3 = Internal._config.SeparatorColor
            Right.BackgroundTransparency = Internal._config.SeparatorTransparency
            Right.BorderSizePixel = 0
            Right.LayoutOrder = 2

            Right.Parent = SeparatorText

            return SeparatorText
        end,
        Update = function(thisWidget: SeparatorText)
            local SeparatorText = thisWidget.instance :: Frame
            local TextLabel: TextLabel = SeparatorText.TextLabel
            if thisWidget.arguments.Text == nil then
                error("Text argument is required for Iris.SeparatorText().", 5)
            end
            TextLabel.Text = thisWidget.arguments.Text
        end,
        Discard = function(thisWidget: SeparatorText)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

return {
    TextFlags = TextFlags,
}
