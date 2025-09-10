local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

--[=[
    @class Format
    Format API
]=]

--[=[
    @within Format
    @interface Separator
    .& Widget
]=]
export type Separator = Types.Widget

--[=[
    @within Format
    @interface Indent
    .& Widget

    .arugments { Width: number? }
]=]
export type Indent = Types.ParentWidget & {
    arguments: {
        Width: number?,
    },
}
--[=[
    @within Format
    @interface SameLine
    .& Widget

    .arguments { Width: number?, VerticalAlignment: Enum.VerticalAlignment?, HorizontalAlignment: Enum.HorizontalAlignment? }
 }
]=]
export type SameLine = Types.ParentWidget & {
    arguments: {
        Width: number?,
        VerticalAlignment: Enum.VerticalAlignment?,
        HorizontalAlignment: Enum.HorizontalAlignment?,
    },
}
--[=[
    @within Format
    @interface Group
    .& Widget
]=]
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

--[=[
    @within Format
    @prop Separator Iris.Separator
    @tag Widget

    A vertical or horizonal line, depending on the context, which visually seperates widgets.
    
    ```lua
    Iris.Window({"Separator Demo"})
        Iris.Text({"Some text here!"})
        Iris.Separator()
        Iris.Text({"This text has been separated!"})
    Iris.End()
    ```

    ![Example Separator](/Iris/assets/api/format/basicSeparator.png)

    ```lua
    hasChildren = false
    hasState = false
    ```
]=]
local API_Separator = function()
    return Internal._insert("Separator") :: Separator
end

--[=[
    @within Format
    @prop Indent Iris.Indent
    @tag Widget
    @tag HasChildren
    
    Indents its child widgets.

    ```lua
    Iris.Window({"Indent Demo"})
        Iris.Text({"Unindented text!"})
        Iris.Indent()
            Iris.Text({"This text has been indented!"})
        Iris.End()
    Iris.End()
    ```

    ![Example Indent](/Iris/assets/api/format/basicIndent.png)

    ```lua
    hasChildren = true
    hasState = false
    Arguments = {
        Width: number? = Iris._config.IndentSpacing -- indent width ammount.
    }
    ```
]=]
local API_Indent = function(width: number?)
    return Internal._insert("Indent", width) :: Indent
end

--[=[
    @within Format
    @prop SameLine Iris.SameLine
    @tag Widget
    @tag HasChildren
    
    Positions its children in a row, horizontally.

    ```lua
    Iris.Window({"Same Line Demo"})
        Iris.Text({"All of these buttons are on the same line!"})
        Iris.SameLine()
            Iris.Button({"Button 1"})
            Iris.Button({"Button 2"})
            Iris.Button({"Button 3"})
        Iris.End()
    Iris.End()
    ```

    ![Example SameLine](/Iris/assets/api/format/basicSameLine.png)
    
    ```lua
    hasChildren = true
    hasState = false
    Arguments = {
        Width: number? = Iris._config.ItemSpacing.X, -- horizontal spacing between child widgets.
        VerticalAlignment: Enum.VerticalAlignment? = Enum.VerticalAlignment.Center -- how widgets vertically to each other.
        HorizontalAlignment: Enum.HorizontalAlignment? = Enum.HorizontalAlignment.Center -- how widgets are horizontally.
    }
    ```
]=]
local API_SameLine = function(width: number?, verticalAlignment: Enum.VerticalAlignment?, horizontalAlignment: Enum.HorizontalAlignment?)
    return Internal._insert("SameLine", width, verticalAlignment, horizontalAlignment) :: SameLine
end

--[=[
    @within Format
    @prop Group Iris.Group
    @tag Widget
    @tag HasChildren
    
    Layout widget which contains its children as a single group.
    
    ```lua
    hasChildren = true
    hasState = false
    ```
]=]
local API_Group = function()
    return Internal._insert("Group") :: Group
end

return {
    API_Separator = API_Separator,
    API_Indent = API_Indent,
    API_SameLine = API_SameLine,
    API_Group = API_Group,
}
