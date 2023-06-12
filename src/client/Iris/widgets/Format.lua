return function(Iris, widgets)
    Iris.WidgetConstructor("Separator", {
        hasState = false,
        hasChildren = false,
        Args = {
    
        },
        Events = {
            
        },
        Generate = function(thisWidget)
            local Separator = Instance.new("Frame")
            Separator.Name = "Iris_Separator"
            Separator.BorderSizePixel = 0
            if thisWidget.parentWidget.type == "SameLine" then
                Separator.Size = UDim2.new(0, 1, 1, 0)
            else
                Separator.Size = UDim2.new(1, 0, 0, 1)
            end
            Separator.ZIndex = thisWidget.ZIndex
            Separator.LayoutOrder = thisWidget.ZIndex
    
            Separator.BackgroundColor3 = Iris._config.SeparatorColor
            Separator.BackgroundTransparency = Iris._config.SeparatorTransparency
    
            widgets.UIListLayout(Separator, Enum.FillDirection.Vertical, UDim.new(0,0))
            -- this is to prevent a bug of AutomaticLayout edge case when its parent has automaticLayout enabled
    
            return Separator
        end,
        Update = function(thisWidget)
    
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end
    })
    
    Iris.WidgetConstructor("Indent", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["Width"] = 1,
        },
        Events = {
            
        },
        Generate = function(thisWidget)
            local Indent = Instance.new("Frame")
            Indent.Name = "Iris_Indent"
            Indent.BackgroundTransparency = 1
            Indent.BorderSizePixel = 0
            Indent.ZIndex = thisWidget.ZIndex
            Indent.LayoutOrder = thisWidget.ZIndex
            Indent.Size = UDim2.fromScale(1, 0)
            Indent.AutomaticSize = Enum.AutomaticSize.Y
    
            widgets.UIListLayout(Indent, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            widgets.UIPadding(Indent, Vector2.new(0, 0))
    
            return Indent
        end,
        Update = function(thisWidget)
            local indentWidth
            if thisWidget.arguments.Width then
                indentWidth = thisWidget.arguments.Width
            else
                indentWidth = Iris._config.IndentSpacing
            end
            thisWidget.Instance.UIPadding.PaddingLeft = UDim.new(0, indentWidth)
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget)
            return thisWidget.Instance
        end
    })
    
    Iris.WidgetConstructor("SameLine", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["Width"] = 1,
            ["VerticalAlignment"] = 2
        },
        Events = {
            
        },
        Generate = function(thisWidget)
            local SameLine = Instance.new("Frame")
            SameLine.Name = "Iris_SameLine"
            SameLine.BackgroundTransparency = 1
            SameLine.BorderSizePixel = 0
            SameLine.ZIndex = thisWidget.ZIndex
            SameLine.LayoutOrder = thisWidget.ZIndex
            SameLine.Size = UDim2.fromScale(1, 0)
            SameLine.AutomaticSize = Enum.AutomaticSize.Y
    
            widgets.UIListLayout(SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))
    
            return SameLine
        end,
        Update = function(thisWidget)
            local itemWidth
            local uiListLayout = thisWidget.Instance.UIListLayout
            if thisWidget.arguments.Width then
                itemWidth = thisWidget.arguments.Width
            else
                itemWidth = Iris._config.ItemSpacing.X
            end
            uiListLayout.Padding = UDim.new(0, itemWidth)
            if thisWidget.arguments.VerticalAlignment then
                uiListLayout.VerticalAlignment = thisWidget.arguments.VerticalAlignment
            else
                uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            end
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget)
            return thisWidget.Instance
        end
    })
    
    Iris.WidgetConstructor("Group", {
        hasState = false,
        hasChildren = true,
        Args = {
    
        },
        Events = {
            
        },
        Generate = function(thisWidget)
            local Group = Instance.new("Frame")
            Group.Name = "Iris_Group"
            Group.Size = UDim2.fromOffset(0, 0)
            Group.BackgroundTransparency = 1
            Group.BorderSizePixel = 0
            Group.ZIndex = thisWidget.ZIndex
            Group.LayoutOrder = thisWidget.ZIndex
            Group.AutomaticSize = Enum.AutomaticSize.XY
            Group.ClipsDescendants = true
    
            local uiListLayout = widgets.UIListLayout(Group, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.X))
    
            return Group
        end,
        Update = function(thisWidget)
    
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget)
            return thisWidget.Instance
        end
    })
end