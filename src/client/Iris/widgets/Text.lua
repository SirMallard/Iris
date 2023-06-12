return function(Iris, widgets)
    local abstractText = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            local Text = Instance.new("TextLabel")
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
        Update = function(thisWidget)
            local Text = thisWidget.Instance
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            Text.Text = thisWidget.arguments.Text
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end
    }

    Iris.WidgetConstructor("Text", widgets.extend(abstractText, {
        Generate = function(thisWidget)
            local Text = abstractText.Generate(thisWidget)
            Text.Name = "Iris_Text"

            return Text
        end
    }))

    Iris.WidgetConstructor("TextColored", widgets.extend(abstractText, {
        Args = {
            ["Text"] = 1,
            ["Color"] = 2
        },
        Generate = function(thisWidget)
            local Text = abstractText.Generate(thisWidget)
            Text.Name = "Iris_TextColored"

            return Text
        end,
        Update = function(thisWidget)
            local Text = thisWidget.Instance
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            Text.Text = thisWidget.arguments.Text
            if thisWidget.arguments.Color == nil then
                error("Iris.TextColored Color argument is required", 5)
            end 
            Text.TextColor3 = thisWidget.arguments.Color
        end
    }))

    Iris.WidgetConstructor("TextWrapped", widgets.extend(abstractText, {
        Generate = function(thisWidget)
            local TextWrapped = abstractText.Generate(thisWidget)
            TextWrapped.Name = "Iris_TextWrapped"
            TextWrapped.TextWrapped = true

            return TextWrapped
        end
    }))
end