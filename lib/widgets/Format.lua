local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

export type Separator = Types.Widget

export type Indent = Types.ParentWidget & {
    arguments: {
        Width: number?,
    },
}

export type SameLine = Types.ParentWidget & {
    arguments: {
        Width: number?,
        VerticalAlignment: Enum.VerticalAlignment?,
        HorizontalAlignment: Enum.HorizontalAlignment?,
    },
}

export type Group = Types.ParentWidget

---------------
-- Separator
---------------

Internal._widgetConstructor(
    "Separator",
    {
        hasState = false,
        hasChildren = false,
        numArguments = 0,
        Arguments = {},
        Events = {},
        Generate = function(thisWidget: Separator)
            local Separator = Instance.new("Frame")
            Separator.Name = "Iris_Separator"
            if thisWidget.parentWidget.type == "SameLine" then
                Separator.Size = UDim2.new(0, 1, Internal._config.ItemWidth.Scale, Internal._config.ItemWidth.Offset)
            else
                Separator.Size = UDim2.new(Internal._config.ItemWidth.Scale, Internal._config.ItemWidth.Offset, 0, 1)
            end
            Separator.BackgroundColor3 = Internal._config.SeparatorColor
            Separator.BackgroundTransparency = Internal._config.SeparatorTransparency
            Separator.BorderSizePixel = 0

            Utility.UIListLayout(Separator, Enum.FillDirection.Vertical, UDim.new(0, 0))
            -- this is to prevent a bug of AutomaticLayout edge case when its parent has automaticLayout enabled

            return Separator
        end,
        Update = function(_thisWidget: Separator) end,
        Discard = function(thisWidget: Separator)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

------------
-- Indent
------------

Internal._widgetConstructor(
    "Indent",
    {
        hasState = false,
        hasChildren = true,
        numArguments = 1,
        Arguments = { "Width" },
        Events = {},
        Generate = function(_thisWidget: Indent)
            local Indent = Instance.new("Frame")
            Indent.Name = "Iris_Indent"
            Indent.AutomaticSize = Enum.AutomaticSize.Y
            Indent.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            Indent.BackgroundTransparency = 1
            Indent.BorderSizePixel = 0

            Utility.UIListLayout(Indent, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))
            Utility.UIPadding(Indent, Vector2.zero)

            return Indent
        end,
        Update = function(thisWidget: Indent)
            local Indent = thisWidget.instance :: Frame

            Indent.UIPadding.PaddingLeft = UDim.new(0, if thisWidget.arguments.Width then thisWidget.arguments.Width else Internal._config.IndentSpacing)
        end,
        ChildAdded = function(thisWidget: Indent, _thisChild: Types.Widget)
            return thisWidget.instance
        end,
        Discard = function(thisWidget: Indent)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

--------------
-- SameLine
--------------

Internal._widgetConstructor(
    "SameLine",
    {
        hasState = false,
        hasChildren = true,
        numArguments = 3,
        Arguments = { "Width", "VerticalAlignment", "HorizontalAlignment" },
        Events = {},
        Generate = function(_thisWidget: SameLine)
            local SameLine = Instance.new("Frame")
            SameLine.Name = "Iris_SameLine"
            SameLine.AutomaticSize = Enum.AutomaticSize.Y
            SameLine.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            SameLine.BackgroundTransparency = 1
            SameLine.BorderSizePixel = 0

            Utility.UIListLayout(SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            return SameLine
        end,
        Update = function(thisWidget: SameLine)
            local Sameline = thisWidget.instance :: Frame
            local UIListLayout: UIListLayout = Sameline.UIListLayout

            UIListLayout.Padding = UDim.new(0, if thisWidget.arguments.Width then thisWidget.arguments.Width else Internal._config.ItemSpacing.X)
            if thisWidget.arguments.VerticalAlignment then
                UIListLayout.VerticalAlignment = thisWidget.arguments.VerticalAlignment
            else
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            end
            if thisWidget.arguments.HorizontalAlignment then
                UIListLayout.HorizontalAlignment = thisWidget.arguments.HorizontalAlignment
            else
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            end
        end,
        ChildAdded = function(thisWidget: SameLine, _thisChild: Types.Widget)
            return thisWidget.instance
        end,
        Discard = function(thisWidget: SameLine)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

-----------
-- Group
-----------

Internal._widgetConstructor(
    "Group",
    {
        hasState = false,
        hasChildren = true,
        numArguments = 0,
        Arguments = {},
        Events = {},
        Generate = function(_thisWidget: Group)
            local Group = Instance.new("Frame")
            Group.Name = "Iris_Group"
            Group.AutomaticSize = Enum.AutomaticSize.XY
            Group.Size = UDim2.fromOffset(0, 0)
            Group.BackgroundTransparency = 1
            Group.BorderSizePixel = 0
            Group.ClipsDescendants = false

            Utility.UIListLayout(Group, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))

            return Group
        end,
        Update = function(_thisWidget: Group) end,
        ChildAdded = function(thisWidget: Group, _thisChild: Types.Widget)
            return thisWidget.instance
        end,
        Discard = function(thisWidget: Group)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

return {}
