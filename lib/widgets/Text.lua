local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    Iris.WidgetConstructor("Text", {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Wrapped"] = 2,
            ["Color"] = 3,
            ["RichText"] = 4,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local Text: TextLabel = Instance.new("TextLabel")
            Text.Name = "Iris_Text"
            Text.Size = UDim2.fromOffset(0, 0)
            Text.BackgroundTransparency = 1
            Text.BorderSizePixel = 0
            Text.ZIndex = thisWidget.ZIndex
            Text.LayoutOrder = thisWidget.ZIndex
            Text.AutomaticSize = Enum.AutomaticSize.XY

            widgets.applyTextStyle(Text)
            widgets.UIPadding(Text, Vector2.new(0, 2))

            return Text
        end,
        Update = function(thisWidget: Types.Widget)
            local Text = thisWidget.Instance :: TextLabel
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            if thisWidget.arguments.Wrapped then
                Text.TextWrapped = true
            else
                Text.TextWrapped = false
            end
            if thisWidget.arguments.Color then
                Text.TextColor3 = thisWidget.arguments.Color
            else
                Text.TextColor3 = Iris._config.TextColor
            end
            if thisWidget.arguments.RichText then
                Text.RichText = true
            else
                Text.RichText = false
            end

            Text.Text = thisWidget.arguments.Text
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    Iris.WidgetConstructor("SeparatorText", {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local SeparatorText = Instance.new("Frame")
            SeparatorText.Name = "Iris_SeparatorText"
            SeparatorText.Size = UDim2.fromScale(1, 0)
            SeparatorText.BackgroundTransparency = 1
            SeparatorText.BorderSizePixel = 0
            SeparatorText.AutomaticSize = Enum.AutomaticSize.Y
            SeparatorText.ZIndex = thisWidget.ZIndex
            SeparatorText.LayoutOrder = thisWidget.ZIndex
            SeparatorText.ClipsDescendants = true

            widgets.UIPadding(SeparatorText, Vector2.new(0, Iris._config.SeparatorTextPadding.Y))
            widgets.UIListLayout(SeparatorText, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemSpacing.X))

            SeparatorText.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.ZIndex = thisWidget.ZIndex + 1
            TextLabel.LayoutOrder = thisWidget.ZIndex + 1

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = SeparatorText

            local Left: Frame = Instance.new("Frame")
            Left.Name = "Left"
            Left.AnchorPoint = Vector2.new(1, 0.5)
            Left.BackgroundColor3 = Iris._config.SeparatorColor
            Left.BackgroundTransparency = Iris._config.SeparatorTransparency
            Left.BorderSizePixel = 0
            Left.Size = UDim2.fromOffset(Iris._config.SeparatorTextPadding.X - Iris._config.ItemSpacing.X, Iris._config.SeparatorTextBorderSize)
            Left.ZIndex = thisWidget.ZIndex
            Left.LayoutOrder = thisWidget.ZIndex

            Left.Parent = SeparatorText

            local Right: Frame = Instance.new("Frame")
            Right.Name = "Right"
            Right.AnchorPoint = Vector2.new(1, 0.5)
            Right.BackgroundColor3 = Iris._config.SeparatorColor
            Right.BackgroundTransparency = Iris._config.SeparatorTransparency
            Right.BorderSizePixel = 0
            Right.Size = UDim2.new(1, 0, 0, Iris._config.SeparatorTextBorderSize)
            Right.ZIndex = thisWidget.ZIndex + 2
            Right.LayoutOrder = thisWidget.ZIndex + 2

            Right.Parent = SeparatorText

            return SeparatorText
        end,
        Update = function(thisWidget: Types.Widget)
            local SeparatorText = thisWidget.Instance :: Frame
            local TextLabel: TextLabel = SeparatorText.TextLabel
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            TextLabel.Text = thisWidget.arguments.Text
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)
end
