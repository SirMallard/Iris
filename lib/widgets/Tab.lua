local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

export type TabBar = Types.ParentWidget & {
    Tabs: { Tab },

    state: {
        index: Types.State<number>,
    },
}

export type Tab = Types.ParentWidget & {
    parentWidget: TabBar,
    Index: number,
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string,
        Flags: number,
    },

    state: {
        index: Types.State<number>,
        open: Types.State<boolean>,
    },
} & Types.Clicked & Types.Opened & Types.Selected & Types.Unselected & Types.Active & Types.Closed & Types.Hovered

local TabFlags = {
    Hideable = 1,
}

---------------
-- Functions
---------------

local function openTab(TabBar: TabBar, Index: number)
    if TabBar.state.index._value > 0 then
        return
    end

    TabBar.state.index:set(Index)
end

local function closeTab(TabBar: TabBar, Index: number)
    if TabBar.state.index._value ~= Index then
        return
    end

    -- search left for open tabs
    for i = Index - 1, 1, -1 do
        if TabBar.Tabs[i].state.open._value == true then
            TabBar.state.index:set(i)
            return
        end
    end

    -- search right for open tabs
    for i = Index, #TabBar.Tabs do
        if TabBar.Tabs[i].state.open._value == true then
            TabBar.state.index:set(i)
            return
        end
    end

    -- no open tabs, so wait for one
    TabBar.state.index:set(0)
end

------------
-- TabBar
------------

Internal._widgetConstructor(
    "TabBar",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 0,
        Arguments = { "index" },
        Events = {},
        Generate = function(thisWidget: TabBar)
            local TabBar = Instance.new("Frame")
            TabBar.Name = "Iris_TabBar"
            TabBar.AutomaticSize = Enum.AutomaticSize.Y
            TabBar.Size = UDim2.fromScale(1, 0)
            TabBar.BackgroundTransparency = 1
            TabBar.BorderSizePixel = 0

            Utility.UIListLayout(TabBar, Enum.FillDirection.Vertical, UDim.new()).VerticalAlignment = Enum.VerticalAlignment.Bottom

            local Bar = Instance.new("Frame")
            Bar.Name = "Bar"
            Bar.AutomaticSize = Enum.AutomaticSize.Y
            Bar.Size = UDim2.fromScale(1, 0)
            Bar.BackgroundTransparency = 1
            Bar.BorderSizePixel = 0

            Utility.UIListLayout(Bar, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X))

            Bar.Parent = TabBar

            local Underline = Instance.new("Frame")
            Underline.Name = "Underline"
            Underline.Size = UDim2.new(1, 0, 0, 1)
            Underline.BackgroundColor3 = Internal._config.TabActiveColor
            Underline.BackgroundTransparency = Internal._config.TabActiveTransparency
            Underline.BorderSizePixel = 0
            Underline.LayoutOrder = 1

            Underline.Parent = TabBar

            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "TabContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0
            ChildContainer.LayoutOrder = 2
            ChildContainer.ClipsDescendants = true

            ChildContainer.Parent = TabBar

            thisWidget.childContainer = ChildContainer
            thisWidget.Tabs = {}

            return TabBar
        end,
        Update = function(_thisWidget: TabBar) end,
        ChildAdded = function(thisWidget: TabBar, thisChild: Tab)
            assert(thisChild.type == "Tab", "Only Iris.Tab can be parented to Iris.TabBar.")
            local TabBar = thisWidget.instance :: Frame
            thisChild.childContainer.Parent = thisWidget.childContainer
            thisChild.Index = #thisWidget.Tabs + 1
            thisWidget.state.index._connectedWidgets[thisChild.ID] = thisChild
            table.insert(thisWidget.Tabs, thisChild)

            return TabBar.Bar
        end,
        ChildDiscarded = function(thisWidget: TabBar, thisChild: Tab)
            local Index = thisChild.Index
            table.remove(thisWidget.Tabs, Index)

            for i = Index, #thisWidget.Tabs do
                thisWidget.Tabs[i].Index = i
            end

            closeTab(thisWidget, Index)
        end,
        GenerateState = function(thisWidget: Tab)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Internal._widgetState(thisWidget, "index", 1)
            end
        end,
        UpdateState = function(_thisWidget: Tab) end,
        Discard = function(thisWidget: TabBar)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

---------
-- Tab
---------

Internal._widgetConstructor(
    "Tab",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 2,
        Arguments = { "Text", "Flags", "open" },
        Events = {
            ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
            ["selected"] = {
                ["Init"] = function(_thisWidget: Tab) end,
                ["Get"] = function(thisWidget: Tab)
                    return thisWidget._lastSelectedTick == Internal._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: Tab) end,
                ["Get"] = function(thisWidget: Tab)
                    return thisWidget._lastUnselectedTick == Internal._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: Tab) end,
                ["Get"] = function(thisWidget: Tab)
                    return thisWidget.state.index._value == thisWidget.Index
                end,
            },
            ["opened"] = {
                ["Init"] = function(_thisWidget: Tab) end,
                ["Get"] = function(thisWidget: Tab)
                    return thisWidget._lastOpenedTick == Internal._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Tab) end,
                ["Get"] = function(thisWidget: Tab)
                    return thisWidget._lastClosedTick == Internal._cycleTick
                end,
            },
        },
        Generate = function(thisWidget: Tab)
            local Tab = Instance.new("TextButton")
            Tab.Name = "Iris_Tab"
            Tab.AutomaticSize = Enum.AutomaticSize.XY
            Tab.BackgroundColor3 = Internal._config.TabColor
            Tab.BackgroundTransparency = Internal._config.TabTransparency
            Tab.BorderSizePixel = 0
            Tab.Text = ""
            Tab.AutoButtonColor = false

            thisWidget.ButtonColors = {
                Color = Internal._config.TabColor,
                Transparency = Internal._config.TabTransparency,
                HoveredColor = Internal._config.TabHoveredColor,
                HoveredTransparency = Internal._config.TabHoveredTransparency,
                ActiveColor = Internal._config.TabActiveColor,
                ActiveTransparency = Internal._config.TabActiveTransparency,
            }

            Utility.UIPadding(Tab, Vector2.new(Internal._config.FramePadding.X, 0))
            Utility.applyFrameStyle(Tab, true, true)
            Utility.UIListLayout(Tab, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center
            Utility.applyInteractionHighlights("Background", Tab, Tab, thisWidget.ButtonColors)
            Utility.applyButtonClick(Tab, function()
                thisWidget.state.index:set(thisWidget.Index)
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            Utility.applyTextStyle(TextLabel)
            Utility.UIPadding(TextLabel, Vector2.new(0, Internal._config.FramePadding.Y))

            TextLabel.Parent = Tab

            local ButtonSize = Internal._config.TextSize + ((Internal._config.FramePadding.Y - 1) * 2)

            local CloseButton = Instance.new("TextButton")
            CloseButton.Name = "CloseButton"
            CloseButton.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
            CloseButton.BackgroundTransparency = 1
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = ""
            CloseButton.AutoButtonColor = false
            CloseButton.LayoutOrder = 1

            Utility.UICorner(CloseButton)
            Utility.applyButtonClick(CloseButton, function()
                thisWidget.state.open:set(false)
                closeTab(thisWidget.parentWidget, thisWidget.Index)
            end)

            Utility.applyInteractionHighlights("Background", CloseButton, CloseButton, {
                Color = Internal._config.TabColor,
                Transparency = 1,
                HoveredColor = Internal._config.ButtonHoveredColor,
                HoveredTransparency = Internal._config.ButtonHoveredTransparency,
                ActiveColor = Internal._config.ButtonActiveColor,
                ActiveTransparency = Internal._config.ButtonActiveTransparency,
            })

            CloseButton.Parent = Tab

            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.AnchorPoint = Vector2.new(0.5, 0.5)
            Icon.Position = UDim2.fromScale(0.5, 0.5)
            Icon.Size = UDim2.fromOffset(math.floor(0.7 * ButtonSize), math.floor(0.7 * ButtonSize))
            Icon.BackgroundTransparency = 1
            Icon.BorderSizePixel = 0
            Icon.Image = Utility.ICONS.MULTIPLICATION_SIGN
            Icon.ImageTransparency = 1

            Utility.applyInteractionHighlights("Image", Tab, Icon, {
                Color = Internal._config.TextColor,
                Transparency = 1,
                HoveredColor = Internal._config.TextColor,
                HoveredTransparency = Internal._config.TextTransparency,
                ActiveColor = Internal._config.TextColor,
                ActiveTransparency = Internal._config.TextTransparency,
            })
            Icon.Parent = CloseButton

            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "TabContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0

            ChildContainer.ClipsDescendants = true
            Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))
            Utility.UIPadding(ChildContainer, Vector2.new(0, Internal._config.ItemSpacing.Y)).PaddingBottom = UDim.new()

            thisWidget.childContainer = ChildContainer

            return Tab
        end,
        Update = function(thisWidget: Tab)
            local Tab = thisWidget.instance :: TextButton
            local TextLabel: TextLabel = Tab.TextLabel
            local CloseButton: TextButton = Tab.CloseButton

            TextLabel.Text = thisWidget.arguments.Text
            CloseButton.Visible = btest(TabFlags.Hideable, thisWidget.arguments.Flags)
        end,
        ChildAdded = function(thisWidget: Tab, _thisChild: Types.Widget)
            return thisWidget.childContainer
        end,
        GenerateState = function(thisWidget: Tab)
            thisWidget.state.index = thisWidget.parentWidget.state.index
            thisWidget.state.index._connectedWidgets[thisWidget.ID] = thisWidget

            if thisWidget.state.open == nil then
                thisWidget.state.open = Internal._widgetState(thisWidget, "open", true)
            end
        end,
        UpdateState = function(thisWidget: Tab)
            local Tab = thisWidget.instance :: TextButton
            local Container = thisWidget.childContainer :: Frame

            if thisWidget.state.open._lastChangeTick == Internal._cycleTick then
                if thisWidget.state.open._value == true then
                    thisWidget._lastOpenedTick = Internal._cycleTick + 1
                    openTab(thisWidget.parentWidget, thisWidget.Index)
                    Tab.Visible = true
                else
                    thisWidget._lastClosedTick = Internal._cycleTick + 1
                    closeTab(thisWidget.parentWidget, thisWidget.Index)
                    Tab.Visible = false
                end
            end

            if thisWidget.state.index._lastChangeTick == Internal._cycleTick then
                if thisWidget.state.index._value == thisWidget.Index then
                    thisWidget.ButtonColors.Color = Internal._config.TabActiveColor
                    thisWidget.ButtonColors.Transparency = Internal._config.TabActiveTransparency
                    Tab.BackgroundColor3 = Internal._config.TabActiveColor
                    Tab.BackgroundTransparency = Internal._config.TabActiveTransparency
                    Container.Visible = true
                    thisWidget._lastSelectedTick = Internal._cycleTick + 1
                else
                    thisWidget.ButtonColors.Color = Internal._config.TabColor
                    thisWidget.ButtonColors.Transparency = Internal._config.TabTransparency
                    Tab.BackgroundColor3 = Internal._config.TabColor
                    Tab.BackgroundTransparency = Internal._config.TabTransparency
                    Container.Visible = false
                    thisWidget._lastUnselectedTick = Internal._cycleTick + 1
                end
            end
        end,
        Discard = function(thisWidget: Tab)
            if thisWidget.state.open._value == true then
                closeTab(thisWidget.parentWidget, thisWidget.Index)
            end

            thisWidget.instance:Destroy()
            thisWidget.childContainer:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

return {
    TabFlags = TabFlags,
}
