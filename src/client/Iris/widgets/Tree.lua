return function(Iris, widgets)
    local abstractTree = {
        hasState = true,
        hasChildren = true,
        Events = {
            ["collasped"] = {
                ["Init"] = function(thisWidget)
    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastCollapsedTick == Iris._cycleTick
                end
            },
            ["uncollapsed"] = {
                ["Init"] = function(thisWidget)
    
                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastUncollaspedTick == Iris._cycleTick
                end
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        ChildAdded = function(thisWidget)
            local ChildContainer = thisWidget.Instance.ChildContainer
            local isUncollapsed = thisWidget.state.isUncollapsed.value
    
            thisWidget.hasChildren = true
            ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren
    
            return thisWidget.Instance.ChildContainer
        end,
        UpdateState = function(thisWidget)
            local isUncollapsed = thisWidget.state.isUncollapsed.value
            local Arrow = thisWidget.ArrowInstance
            local ChildContainer = thisWidget.Instance.ChildContainer
            Arrow.Text = (isUncollapsed and widgets.ICONS.DOWN_POINTING_TRIANGLE or widgets.ICONS.RIGHT_POINTING_TRIANGLE)
    
            if isUncollapsed then
                thisWidget.lastUncollaspedTick = Iris._cycleTick + 1
            else
                thisWidget.lastCollapsedTick = Iris._cycleTick + 1
            end
    
            ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", false)
            end
        end
    }

    Iris.WidgetConstructor("Tree", widgets.extend(abstractTree, {
        Args = {
            ["Text"] = 1,
            ["SpanAvailWidth"] = 2,
            ["NoIndent"] = 3
        },
        Generate = function(thisWidget)
            local Tree = Instance.new("Frame")
            Tree.Name = "Iris_Tree"
            Tree.BackgroundTransparency = 1
            Tree.BorderSizePixel = 0
            Tree.ZIndex = thisWidget.ZIndex
            Tree.LayoutOrder = thisWidget.ZIndex
            Tree.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
            Tree.AutomaticSize = Enum.AutomaticSize.Y
    
            thisWidget.hasChildren = false
    
            widgets.UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))
    
            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0
            ChildContainer.ZIndex = thisWidget.ZIndex + 1
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Visible = false
            ChildContainer.ClipsDescendants = true
            ChildContainer.Parent = Tree
    
            widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            
            local ChildContainerPadding = widgets.UIPadding(ChildContainer, Vector2.new(0, 0))
            ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)
    
            local Header = Instance.new("Frame")
            Header.Name = "Header"
            Header.BackgroundTransparency = 1
            Header.BorderSizePixel = 0
            Header.ZIndex = thisWidget.ZIndex
            Header.LayoutOrder = thisWidget.ZIndex
            Header.Size = UDim2.fromScale(1, 0)
            Header.AutomaticSize = Enum.AutomaticSize.Y
            Header.Parent = Tree
    
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.BackgroundTransparency = 1
            Button.BorderSizePixel = 0
            Button.ZIndex = thisWidget.ZIndex
            Button.LayoutOrder = thisWidget.ZIndex
            Button.AutoButtonColor = false
            Button.Text = ""
            Button.Parent = Header
    
            widgets.applyInteractionHighlights(Button, Header, {
                ButtonColor = Color3.fromRGB(0, 0, 0),
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderActiveColor,
                ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
            })
    
            local uiPadding = widgets.UIPadding(Button, Vector2.zero)
            uiPadding.PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
            local ButtonUIListLayout = widgets.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.FramePadding.X))
            ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
            local Arrow = Instance.new("TextLabel")
            Arrow.Name = "Arrow"
            Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.BorderSizePixel = 0
            Arrow.ZIndex = thisWidget.ZIndex
            Arrow.LayoutOrder = thisWidget.ZIndex
            Arrow.AutomaticSize = Enum.AutomaticSize.Y
    
            widgets.applyTextStyle(Arrow)
            Arrow.TextXAlignment = Enum.TextXAlignment.Center
            Arrow.TextSize = Iris._config.TextSize - 4
    
            Arrow.Parent = Button
            thisWidget.ArrowInstance = Arrow
    
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex
            TextLabel.LayoutOrder = thisWidget.ZIndex
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.Parent = Button
            local TextPadding = widgets.UIPadding(TextLabel,Vector2.new(0, 0))
            TextPadding.PaddingRight = UDim.new(0, 21)
    
            widgets.applyTextStyle(TextLabel)
    
            Button.MouseButton1Click:Connect(function()
                thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
            end)
    
            return Tree
        end,
        Update = function(thisWidget)
            local Button = thisWidget.Instance.Header.Button
            local ChildContainer = thisWidget.Instance.ChildContainer
            Button.TextLabel.Text = thisWidget.arguments.Text or "Tree"
            if thisWidget.arguments.SpanAvailWidth then
                Button.AutomaticSize = Enum.AutomaticSize.Y
                Button.Size = UDim2.fromScale(1, 0)
            else
                Button.AutomaticSize = Enum.AutomaticSize.XY
                Button.Size = UDim2.fromScale(0, 0)
            end
    
            if thisWidget.arguments.NoIndent then
                ChildContainer.UIPadding.PaddingLeft = UDim.new(0, 0)
            else
                ChildContainer.UIPadding.PaddingLeft = UDim.new(0, Iris._config.IndentSpacing)
            end
    
        end
    }))
    
    Iris.WidgetConstructor("CollapsingHeader", widgets.extend(abstractTree, {
        Args = {
            ["Text"] = 1,
        },
        Generate = function(thisWidget)
            local CollapsingHeader = Instance.new("Frame")
            CollapsingHeader.Name = "Iris_CollapsingHeader"
            CollapsingHeader.BackgroundTransparency = 1
            CollapsingHeader.BorderSizePixel = 0
            CollapsingHeader.ZIndex = thisWidget.ZIndex
            CollapsingHeader.LayoutOrder = thisWidget.ZIndex
            CollapsingHeader.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
            CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y
    
            thisWidget.hasChildren = false
    
            widgets.UIListLayout(CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))
    
            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0
            ChildContainer.ZIndex = thisWidget.ZIndex + 1
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Visible = false
            ChildContainer.ClipsDescendants = true
            ChildContainer.Parent = CollapsingHeader
    
            widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            
            local ChildContainerPadding = widgets.UIPadding(ChildContainer, Vector2.new(0, 0))
            ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)
    
            local Header = Instance.new("Frame")
            Header.Name = "Header"
            Header.BackgroundTransparency = 1
            Header.BorderSizePixel = 0
            Header.ZIndex = thisWidget.ZIndex
            Header.LayoutOrder = thisWidget.ZIndex
            Header.Size = UDim2.fromScale(1, 0)
            Header.AutomaticSize = Enum.AutomaticSize.Y
            Header.Parent = CollapsingHeader
    
            local Collapse = Instance.new("TextButton")
            Collapse.Name = "Collapse"
            Collapse.BackgroundColor3 = Iris._config.HeaderColor
            Collapse.BackgroundTransparency = Iris._config.HeaderTransparency
            Collapse.BorderSizePixel = 0
            Collapse.ZIndex = thisWidget.ZIndex
            Collapse.LayoutOrder = thisWidget.ZIndex
            Collapse.Size = UDim2.new(1, 2 * Iris._config.FramePadding.X, 0, 0)
            Collapse.Position = UDim2.fromOffset(-4, 0)
            Collapse.AutomaticSize = Enum.AutomaticSize.Y
            Collapse.Text = ""
            Collapse.AutoButtonColor = false
            Collapse.ClipsDescendants = true
            Collapse.Parent = Header
    
            widgets.UIPadding(Collapse, Vector2.new(2 * Iris._config.FramePadding.X, Iris._config.FramePadding.Y)) -- we add a custom padding because it extends on both sides
            widgets.applyFrameStyle(Collapse, true, true)
    
            widgets.applyInteractionHighlights(Collapse, Collapse, {
                ButtonColor = Iris._config.HeaderColor,
                ButtonTransparency = Iris._config.HeaderTransparency,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderActiveColor,
                ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
            })
    
            local ButtonUIListLayout = widgets.UIListLayout(Collapse, Enum.FillDirection.Horizontal, UDim.new(0, 2 * Iris._config.FramePadding.X))
            ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
            local Arrow = Instance.new("TextLabel")
            Arrow.Name = "Arrow"
            Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.BorderSizePixel = 0
            Arrow.ZIndex = thisWidget.ZIndex
            Arrow.LayoutOrder = thisWidget.ZIndex
            Arrow.AutomaticSize = Enum.AutomaticSize.Y
    
            widgets.applyTextStyle(Arrow)
            Arrow.TextXAlignment = Enum.TextXAlignment.Center
            Arrow.TextSize = Iris._config.TextSize - 4

            Arrow.Parent = Collapse
            thisWidget.ArrowInstance = Arrow
    
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex
            TextLabel.LayoutOrder = thisWidget.ZIndex
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.Parent = Collapse
            local TextPadding = widgets.UIPadding(TextLabel,Vector2.new(0, 0))
            TextPadding.PaddingRight = UDim.new(0, 21)
    
            widgets.applyTextStyle(TextLabel)
    
            Collapse.MouseButton1Click:Connect(function()
                thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
            end)
    
            return CollapsingHeader
        end,
        Update = function(thisWidget)
            local Collapse = thisWidget.Instance.Header.Collapse
            Collapse.TextLabel.Text = thisWidget.arguments.Text or "Collapsing Header"
        end
    }))
end
