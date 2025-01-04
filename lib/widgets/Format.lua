local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    --stylua: ignore
    Iris.WidgetConstructor("Separator", {
        hasState = false,
        hasChildren = false,
        Args = {},
        Events = {},
        Generate = function(thisWidget: Types.Separator)
            local Separator: Frame = Instance.new("Frame")
            Separator.Name = "Iris_Separator"
            Separator.BackgroundColor3 = Iris._config.SeparatorColor
            Separator.BackgroundTransparency = Iris._config.SeparatorTransparency
            Separator.BorderSizePixel = 0
            if thisWidget.parentWidget.type == "SameLine" then
                Separator.Size = UDim2.new(0, 1, 1, 0)
            else
                Separator.Size = UDim2.new(1, 0, 0, 1)
            end
            Separator.LayoutOrder = thisWidget.ZIndex

            widgets.UIListLayout(Separator, Enum.FillDirection.Vertical, UDim.new(0, 0))
            -- this is to prevent a bug of AutomaticLayout edge case when its parent has automaticLayout enabled

            return Separator
        end,
        Update = function(_thisWidget: Types.Separator) end,
        Discard = function(thisWidget: Types.Separator)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    --stylua: ignore
    Iris.WidgetConstructor("Indent", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["Width"] = 1,
        },
        Events = {},
        Generate = function(thisWidget: Types.Indent)
            local Indent: Frame = Instance.new("Frame")
            Indent.Name = "Iris_Indent"
            Indent.BackgroundTransparency = 1
            Indent.BorderSizePixel = 0
            Indent.Size = UDim2.fromScale(1, 0)
            Indent.AutomaticSize = Enum.AutomaticSize.Y
            Indent.LayoutOrder = thisWidget.ZIndex

            widgets.UIListLayout(Indent, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            widgets.UIPadding(Indent, Vector2.zero)

            return Indent
        end,
        Update = function(thisWidget: Types.Indent)
            local Indent = thisWidget.Instance :: Frame

            local indentWidth: number
            if thisWidget.arguments.Width then
                indentWidth = thisWidget.arguments.Width
            else
                indentWidth = Iris._config.IndentSpacing
            end
            Indent.UIPadding.PaddingLeft = UDim.new(0, indentWidth)
        end,
        Discard = function(thisWidget: Types.Indent)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget: Types.Indent, _thisChild: Types.Widget)
            return thisWidget.Instance
        end,
    } :: Types.WidgetClass)

    --stylua: ignore
    Iris.WidgetConstructor("SameLine", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["Width"] = 1,
            ["VerticalAlignment"] = 2,
            ["HorizontalAlignment"] = 3,
        },
        Events = {},
        Generate = function(thisWidget: Types.SameLine)
            local SameLine: Frame = Instance.new("Frame")
            SameLine.Name = "Iris_SameLine"
            SameLine.BackgroundTransparency = 1
            SameLine.BorderSizePixel = 0
            SameLine.Size = UDim2.fromScale(1, 0)
            SameLine.AutomaticSize = Enum.AutomaticSize.Y
            SameLine.LayoutOrder = thisWidget.ZIndex

            widgets.UIListLayout(SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            return SameLine
        end,
        Update = function(thisWidget: Types.SameLine)
            local Sameline = thisWidget.Instance :: Frame
            local uiListLayout: UIListLayout = Sameline.UIListLayout
            local itemWidth: number
            if thisWidget.arguments.Width then
                itemWidth = thisWidget.arguments.Width
            else
                itemWidth = Iris._config.ItemSpacing.X
            end
            uiListLayout.Padding = UDim.new(0, itemWidth)
            if thisWidget.arguments.VerticalAlignment then
                uiListLayout.VerticalAlignment = thisWidget.arguments.VerticalAlignment
            else
                uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            end
            if thisWidget.arguments.HorizontalAlignment then
                uiListLayout.HorizontalAlignment = thisWidget.arguments.HorizontalAlignment
            else
                uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            end
        end,
        Discard = function(thisWidget: Types.SameLine)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget: Types.SameLine, _thisChild: Types.Widget)
            return thisWidget.Instance
        end,
    } :: Types.WidgetClass)

    --stylua: ignore
    Iris.WidgetConstructor("Group", {
        hasState = false,
        hasChildren = true,
        Args = {},
        Events = {},
        Generate = function(thisWidget: Types.Group)
            local Group: Frame = Instance.new("Frame")
            Group.Name = "Iris_Group"
            Group.AutomaticSize = Enum.AutomaticSize.XY
            Group.Size = UDim2.fromOffset(0, 0)
            Group.BackgroundTransparency = 1
            Group.BorderSizePixel = 0
            Group.LayoutOrder = thisWidget.ZIndex
            Group.ClipsDescendants = false

            widgets.UIListLayout(Group, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            return Group
        end,
        Update = function(_thisWidget: Types.Group) end,
        Discard = function(thisWidget: Types.Group)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget: Types.Group, _thisChild: Types.Widget)
            return thisWidget.Instance
        end,
    } :: Types.WidgetClass)
end
