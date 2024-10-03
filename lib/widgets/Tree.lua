local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local abstractTree = {
        hasState = true,
        hasChildren = true,
        Events = {
            ["collapsed"] = {
                ["Init"] = function(_thisWidget: Types.CollapsingHeader) end,
                ["Get"] = function(thisWidget: Types.CollapsingHeader)
                    return thisWidget.lastCollapsedTick == Iris._cycleTick
                end,
            },
            ["uncollapsed"] = {
                ["Init"] = function(_thisWidget: Types.CollapsingHeader) end,
                ["Get"] = function(thisWidget: Types.CollapsingHeader)
                    return thisWidget.lastUncollapsedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end),
        },
        Discard = function(thisWidget: Types.CollapsingHeader)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        ChildAdded = function(thisWidget: Types.CollapsingHeader, _thisChild: Types.Widget)
            local ChildContainer: Frame = thisWidget.ChildContainer :: Frame

            ChildContainer.Visible = thisWidget.state.isUncollapsed.value

            return ChildContainer
        end,
        UpdateState = function(thisWidget: Types.CollapsingHeader)
            local isUncollapsed: boolean = thisWidget.state.isUncollapsed.value
            local Tree = thisWidget.Instance :: Frame
            local ChildContainer = thisWidget.ChildContainer :: Frame
            local Header = Tree.Header :: Frame
            local Button = Header.Button :: TextButton
            local Arrow: ImageLabel = Button.Arrow

            Arrow.Image = (isUncollapsed and widgets.ICONS.DOWN_POINTING_TRIANGLE or widgets.ICONS.RIGHT_POINTING_TRIANGLE)
            if isUncollapsed then
                thisWidget.lastUncollapsedTick = Iris._cycleTick + 1
            else
                thisWidget.lastCollapsedTick = Iris._cycleTick + 1
            end

            ChildContainer.Visible = isUncollapsed
        end,
        GenerateState = function(thisWidget: Types.CollapsingHeader)
            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", false)
            end
        end,
    } :: Types.WidgetClass

    --stylua: ignore
    Iris.WidgetConstructor(
        "Tree",
        widgets.extend(abstractTree, {
            Args = {
                ["Text"] = 1,
                ["SpanAvailWidth"] = 2,
                ["NoIndent"] = 3,
            },
            Generate = function(thisWidget: Types.Tree)
                local Tree: Frame = Instance.new("Frame")
                Tree.Name = "Iris_Tree"
                Tree.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
                Tree.AutomaticSize = Enum.AutomaticSize.Y
                Tree.BackgroundTransparency = 1
                Tree.BorderSizePixel = 0
                Tree.LayoutOrder = thisWidget.ZIndex

                widgets.UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer: Frame = Instance.new("Frame")
                ChildContainer.Name = "TreeContainer"
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                -- ChildContainer.ClipsDescendants = true

                widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
                local ChildContainerPadding: UIPadding = widgets.UIPadding(ChildContainer, Vector2.zero)
                ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

                ChildContainer.Parent = Tree

                local Header: Frame = Instance.new("Frame")
                Header.Name = "Header"
                Header.Size = UDim2.fromScale(1, 0)
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = Tree

                local Button: TextButton = Instance.new("TextButton")
                Button.Name = "Button"
                Button.BackgroundTransparency = 1
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false

                widgets.applyInteractionHighlights("Background", Button, Header, {
                    Color = Color3.fromRGB(0, 0, 0),
                    Transparency = 1,
                    HoveredColor = Iris._config.HeaderHoveredColor,
                    HoveredTransparency = Iris._config.HeaderHoveredTransparency,
                    ActiveColor = Iris._config.HeaderActiveColor,
                    ActiveTransparency = Iris._config.HeaderActiveTransparency,
                })

                local ButtonPadding: UIPadding = widgets.UIPadding(Button, Vector2.zero)
                ButtonPadding.PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
                local ButtonUIListLayout: UIListLayout = widgets.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.FramePadding.X))
                ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                Button.Parent = Header

                local Arrow: ImageLabel = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, math.floor(Iris._config.TextSize * 0.7))
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Iris._config.TextColor
                Arrow.ImageTransparency = Iris._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = Button

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                local TextPadding: UIPadding = widgets.UIPadding(TextLabel, Vector2.zero)
                TextPadding.PaddingRight = UDim.new(0, 21)
                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                widgets.applyButtonClick(Button, function()
                    thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
                end)

                thisWidget.ChildContainer = ChildContainer
                return Tree
            end,
            Update = function(thisWidget: Types.Tree)
                local Tree = thisWidget.Instance :: Frame
                local ChildContainer = thisWidget.ChildContainer :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel
                local Padding: UIPadding = ChildContainer.UIPadding

                TextLabel.Text = thisWidget.arguments.Text or "Tree"
                if thisWidget.arguments.SpanAvailWidth then
                    Button.AutomaticSize = Enum.AutomaticSize.Y
                    Button.Size = UDim2.fromScale(1, 0)
                else
                    Button.AutomaticSize = Enum.AutomaticSize.XY
                    Button.Size = UDim2.fromScale(0, 0)
                end

                if thisWidget.arguments.NoIndent then
                    Padding.PaddingLeft = UDim.new(0, 0)
                else
                    Padding.PaddingLeft = UDim.new(0, Iris._config.IndentSpacing)
                end
            end,
        })
    )

    --stylua: ignore
    Iris.WidgetConstructor(
        "CollapsingHeader",
        widgets.extend(abstractTree, {
            Args = {
                ["Text"] = 1,
            },
            Generate = function(thisWidget: Types.CollapsingHeader)
                local CollapsingHeader: Frame = Instance.new("Frame")
                CollapsingHeader.Name = "Iris_CollapsingHeader"
                CollapsingHeader.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
                CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y
                CollapsingHeader.BackgroundTransparency = 1
                CollapsingHeader.BorderSizePixel = 0
                CollapsingHeader.LayoutOrder = thisWidget.ZIndex

                widgets.UIListLayout(CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer: Frame = Instance.new("Frame")
                ChildContainer.Name = "CollapsingHeaderContainer"
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                -- ChildContainer.ClipsDescendants = true

                widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
                local ChildContainerPadding: UIPadding = widgets.UIPadding(ChildContainer, Vector2.zero)
                ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

                ChildContainer.Parent = CollapsingHeader

                local Header: Frame = Instance.new("Frame")
                Header.Name = "Header"
                Header.Size = UDim2.fromScale(1, 0)
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = CollapsingHeader

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Size = UDim2.new(1, 0, 0, 0)
                Button.AutomaticSize = Enum.AutomaticSize.Y
                Button.BackgroundColor3 = Iris._config.HeaderColor
                Button.BackgroundTransparency = Iris._config.HeaderTransparency
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.ClipsDescendants = true

                widgets.UIPadding(Button, Iris._config.FramePadding) -- we add a custom padding because it extends on both sides
                widgets.applyFrameStyle(Button, true)
                local ButtonUIListLayout: UIListLayout = widgets.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, 2 * Iris._config.FramePadding.X))
                ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                widgets.applyInteractionHighlights("Background", Button, Button, {
                    Color = Iris._config.HeaderColor,
                    Transparency = Iris._config.HeaderTransparency,
                    HoveredColor = Iris._config.HeaderHoveredColor,
                    HoveredTransparency = Iris._config.HeaderHoveredTransparency,
                    ActiveColor = Iris._config.HeaderActiveColor,
                    ActiveTransparency = Iris._config.HeaderActiveTransparency,
                })

                Button.Parent = Header

                local Arrow: ImageLabel = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, math.ceil(Iris._config.TextSize * 0.8))
                Arrow.AutomaticSize = Enum.AutomaticSize.Y
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Iris._config.TextColor
                Arrow.ImageTransparency = Iris._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = Button

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                local TextPadding: UIPadding = widgets.UIPadding(TextLabel, Vector2.zero)
                TextPadding.PaddingRight = UDim.new(0, 21)
                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                widgets.applyButtonClick(Button, function()
                    thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
                end)

                thisWidget.ChildContainer = ChildContainer
                return CollapsingHeader
            end,
            Update = function(thisWidget: Types.CollapsingHeader)
                local Tree = thisWidget.Instance :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel

                TextLabel.Text = thisWidget.arguments.Text or "Collapsing Header"
            end,
        })
    )
end
