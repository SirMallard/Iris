local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

export type Tree = CollapsingHeader & {
    arguments: {
        Text: string,
        Flags: number,
    },
}

export type CollapsingHeader = Types.ParentWidget & {
    arguments: {
        Text: string?,
        Flags: number,
    },

    state: {
        open: Types.State<boolean>,
    },
} & Types.Opened & Types.Closed & Types.Hovered

local TreeFlags = {
    SpanAvailWidth = 1,
    NoIndent = 2,
    DefaultOpen = 4,
}

local abstractTree = {
    hasState = true,
    hasChildren = true,
    numArguments = 2,
    Arguments = { "Text", "Flags", "open" },
    Events = {
        ["opened"] = {
            ["Init"] = function(_thisWidget: CollapsingHeader) end,
            ["Get"] = function(thisWidget: CollapsingHeader)
                return thisWidget.lastClosedTick == Internal._cycleTick
            end,
        },
        ["closed"] = {
            ["Init"] = function(_thisWidget: CollapsingHeader) end,
            ["Get"] = function(thisWidget: CollapsingHeader)
                return thisWidget.lastOpenedTick == Internal._cycleTick
            end,
        },
        ["hovered"] = Utility.EVENTS.hover(function(thisWidget)
            return thisWidget.instance
        end),
    },
    GenerateState = function(thisWidget: CollapsingHeader)
        if thisWidget.state.open == nil then
            thisWidget.state.open = Internal._widgetState(thisWidget, "open", btest(TreeFlags.DefaultOpen, thisWidget.arguments.Flags))
        end
    end,
    UpdateState = function(thisWidget: CollapsingHeader)
        local open = thisWidget.state.open._value
        local Tree = thisWidget.instance :: Frame
        local ChildContainer = thisWidget.childContainer :: Frame
        local Header = Tree.Header :: Frame
        local Button = Header.Button :: TextButton
        local Arrow: ImageLabel = Button.Arrow

        Arrow.Image = (if open then Utility.ICONS.DOWN_POINTING_TRIANGLE else Utility.ICONS.RIGHT_POINTING_TRIANGLE)
        if open then
            thisWidget.lastOpenedTick = Internal._cycleTick + 1
        else
            thisWidget.lastClosedTick = Internal._cycleTick + 1
        end

        ChildContainer.Visible = open
    end,
    ChildAdded = function(thisWidget: CollapsingHeader, _thisChild: Types.Widget)
        local ChildContainer = thisWidget.childContainer :: Frame

        ChildContainer.Visible = thisWidget.state.open._value

        return ChildContainer
    end,
    Discard = function(thisWidget: CollapsingHeader)
        thisWidget.instance:Destroy()
        Utility.discardState(thisWidget)
    end,
} :: Types.WidgetClass

----------
-- Tree
----------

Internal._widgetConstructor(
    "Tree",
    Utility.extend(
        abstractTree,
        {
            Generate = function(thisWidget: Tree)
                local Tree = Instance.new("Frame")
                Tree.Name = "Iris_Tree"
                Tree.AutomaticSize = Enum.AutomaticSize.Y
                Tree.Size = UDim2.new(Internal._config.ItemWidth, UDim.new(0, 0))
                Tree.BackgroundTransparency = 1
                Tree.BorderSizePixel = 0

                Utility.UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer = Instance.new("Frame")
                ChildContainer.Name = "TreeContainer"
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                -- ChildContainer.ClipsDescendants = true

                Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))
                Utility.UIPadding(ChildContainer, Vector2.zero).PaddingTop = UDim.new(0, Internal._config.ItemSpacing.Y)

                ChildContainer.Parent = Tree

                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.Size = UDim2.fromScale(1, 0)
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = Tree

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.BackgroundTransparency = 1
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false

                Utility.applyInteractionHighlights("Background", Button, Header, {
                    Color = Color3.fromRGB(0, 0, 0),
                    Transparency = 1,
                    HoveredColor = Internal._config.HeaderHoveredColor,
                    HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                    ActiveColor = Internal._config.HeaderActiveColor,
                    ActiveTransparency = Internal._config.HeaderActiveTransparency,
                })

                Utility.UIPadding(Button, Vector2.zero).PaddingLeft = UDim.new(0, Internal._config.FramePadding.X)
                Utility.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.FramePadding.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                Button.Parent = Header

                local Arrow = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.Size = UDim2.fromOffset(Internal._config.TextSize, math.floor(Internal._config.TextSize * 0.7))
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Internal._config.TextColor
                Arrow.ImageTransparency = Internal._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = Button

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                Utility.UIPadding(TextLabel, Vector2.zero).PaddingRight = UDim.new(0, 21)
                Utility.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                Utility.applyButtonClick(Button, function()
                    thisWidget.state.open:set(not thisWidget.state.open._value)
                end)

                thisWidget.childContainer = ChildContainer
                return Tree
            end,
            Update = function(thisWidget: Tree)
                local Tree = thisWidget.instance :: Frame
                local ChildContainer = thisWidget.childContainer :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel
                local Padding: UIPadding = ChildContainer.UIPadding

                TextLabel.Text = thisWidget.arguments.Text or "Tree"
                if btest(TreeFlags.SpanAvailWidth, thisWidget.arguments.Flags) then
                    Button.AutomaticSize = Enum.AutomaticSize.Y
                    Button.Size = UDim2.fromScale(1, 0)
                else
                    Button.AutomaticSize = Enum.AutomaticSize.XY
                    Button.Size = UDim2.fromScale(0, 0)
                end

                if btest(TreeFlags.NoIndent, thisWidget.arguments.Flags) then
                    Padding.PaddingLeft = UDim.new(0, 0)
                else
                    Padding.PaddingLeft = UDim.new(0, Internal._config.IndentSpacing)
                end
            end,
        } :: Types.WidgetClass
    )
)

----------------------
-- CollapsingHeader
----------------------

Internal._widgetConstructor(
    "CollapsingHeader",
    Utility.extend(
        abstractTree,
        {
            Generate = function(thisWidget: CollapsingHeader)
                local CollapsingHeader = Instance.new("Frame")
                CollapsingHeader.Name = "Iris_CollapsingHeader"
                CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y
                CollapsingHeader.Size = UDim2.new(Internal._config.ItemWidth, UDim.new(0, 0))
                CollapsingHeader.BackgroundTransparency = 1
                CollapsingHeader.BorderSizePixel = 0

                Utility.UIListLayout(CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer = Instance.new("Frame")
                ChildContainer.Name = "CollapsingHeaderContainer"
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                -- ChildContainer.ClipsDescendants = true

                Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))
                Utility.UIPadding(ChildContainer, Vector2.zero).PaddingTop = UDim.new(0, Internal._config.ItemSpacing.Y)

                ChildContainer.Parent = CollapsingHeader

                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.Size = UDim2.fromScale(1, 0)
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = CollapsingHeader

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.AutomaticSize = Enum.AutomaticSize.Y
                Button.Size = UDim2.fromScale(1, 0)
                Button.BackgroundColor3 = Internal._config.HeaderColor
                Button.BackgroundTransparency = Internal._config.HeaderTransparency
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.ClipsDescendants = true

                Utility.UIPadding(Button, Internal._config.FramePadding) -- we add a custom padding because it extends on both sides
                Utility.applyFrameStyle(Button, true)
                Utility.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, 2 * Internal._config.FramePadding.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                Utility.applyInteractionHighlights("Background", Button, Button, {
                    Color = Internal._config.HeaderColor,
                    Transparency = Internal._config.HeaderTransparency,
                    HoveredColor = Internal._config.HeaderHoveredColor,
                    HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                    ActiveColor = Internal._config.HeaderActiveColor,
                    ActiveTransparency = Internal._config.HeaderActiveTransparency,
                })

                Button.Parent = Header

                local Arrow = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.AutomaticSize = Enum.AutomaticSize.Y
                Arrow.Size = UDim2.fromOffset(Internal._config.TextSize, math.ceil(Internal._config.TextSize * 0.8))
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Internal._config.TextColor
                Arrow.ImageTransparency = Internal._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = Button

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                Utility.UIPadding(TextLabel, Vector2.zero).PaddingRight = UDim.new(0, 21)
                Utility.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                Utility.applyButtonClick(Button, function()
                    thisWidget.state.open:set(not thisWidget.state.open._value)
                end)

                thisWidget.childContainer = ChildContainer
                return CollapsingHeader
            end,
            Update = function(thisWidget: CollapsingHeader)
                local Tree = thisWidget.instance :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel

                TextLabel.Text = thisWidget.arguments.Text or "Collapsing Header"
            end,
        } :: Types.WidgetClass
    )
)

return {
    TreeFlags = TreeFlags,
}
