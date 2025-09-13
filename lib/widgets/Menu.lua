local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

--[=[
    @class Menu
    Menu API
]=]

--[=[
    @within Menu
    @interface MenuBar
    .& ParentWidget
]=]
export type MenuBar = Types.ParentWidget

--[=[
    @within Menu
    @interface Menu
    .& ParentWidget
    
    .clicked () -> boolean -- fires when a button is clicked
    .opened () -> boolean -- once when opened
    .closed () -> boolean -- once when closed
    .hovered () -> boolean -- fires when the mouse hovers over any of the window

    .arguments { Text: string? }
    .state { open: State<boolean> }
]=]
export type Menu = Types.ParentWidget & {
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string?,
    },

    state: {
        open: Types.State<boolean>,
    },
} & Types.Clicked & Types.Opened & Types.Closed & Types.Hovered

--[=[
    @within Menu
    @interface MenuItem
    .& Widget
    
    .clicked () -> boolean -- fires when a button is clicked
    .hovered () -> boolean -- fires when the mouse hovers over any of the window

    .arguments { Text: string, KeyCode: Enum.KeyCode?, ModifierKey: Enum.ModifierKey? }
]=]
export type MenuItem = Types.Widget & {
    arguments: {
        Text: string,
        KeyCode: Enum.KeyCode?,
        ModifierKey: Enum.ModifierKey?,
    },
} & Types.Clicked & Types.Hovered

--[=[
    @within Menu
    @interface MenuToggle
    .& Widget
    
    .checked () -> boolean -- once when checked
    .unchecked () -> boolean -- once when unchecked
    .hovered () -> boolean -- fires when the mouse hovers over any of the window
    
    .arguments { Text: string, KeyCode: Enum.KeyCode?, ModifierKey: Enum.ModifierKey? }
    .state { checked: Types.State<boolean> }
]=]
export type MenuToggle = Types.Widget & {
    arguments: {
        Text: string,
        KeyCode: Enum.KeyCode?,
        ModifierKey: Enum.ModifierKey?,
    },

    state: {
        checked: Types.State<boolean>,
    },
} & Types.Checked & Types.Unchecked & Types.Hovered

local AnyMenuOpen = false
local ActiveMenu: Menu? = nil
local MenuStack: { Menu } = {}

local function EmptyMenuStack(menuIndex: number?)
    for index = #MenuStack, menuIndex and menuIndex + 1 or 1, -1 do
        local widget = MenuStack[index]
        widget.state.isOpened:set(false)

        widget.instance.BackgroundColor3 = Internal._config.HeaderColor
        widget.instance.BackgroundTransparency = 1

        table.remove(MenuStack, index)
    end

    if #MenuStack == 0 then
        AnyMenuOpen = false
        ActiveMenu = nil
    end
end

local function UpdateChildContainerTransform(thisWidget: Menu)
    local submenu = thisWidget.parentWidget.type == "Menu"

    local Menu = thisWidget.instance :: Frame
    local ChildContainer = thisWidget.childContainer :: ScrollingFrame
    ChildContainer.Size = UDim2.fromOffset(Menu.AbsoluteSize.X, 0)
    if ChildContainer.Parent == nil then
        return
    end

    local menuPosition = Menu.AbsolutePosition - Utility.guiOffset
    local menuSize = Menu.AbsoluteSize
    local containerSize = ChildContainer.AbsoluteSize
    local borderSize = Internal._config.PopupBorderSize
    local screenSize: Vector2 = (ChildContainer.Parent :: GuiObject).AbsoluteSize

    local x = menuPosition.X
    local y
    local anchor = Vector2.zero

    if submenu then
        if menuPosition.X + containerSize.X > screenSize.X then
            anchor = Vector2.xAxis
        else
            x = menuPosition.X + menuSize.X
        end
    end

    if menuPosition.Y + containerSize.Y > screenSize.Y then
        -- too low.
        y = menuPosition.Y - borderSize + (submenu and menuSize.Y or 0)
        anchor += Vector2.yAxis
    else
        y = menuPosition.Y + borderSize + (submenu and 0 or menuSize.Y)
    end

    ChildContainer.Position = UDim2.fromOffset(x, y)
    ChildContainer.AnchorPoint = anchor
end

Utility.registerEvent("InputBegan", function(inputObject: InputObject)
    if not Internal._started then
        return
    end
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 then
        return
    end
    if AnyMenuOpen == false then
        return
    end
    if ActiveMenu == nil then
        return
    end

    -- this only checks if we clicked outside all the menus. If we clicked in any menu, then the hover function handles this.
    local isInMenu = false
    local MouseLocation = Utility.getMouseLocation()
    for _, menu in MenuStack do
        for _, container in { menu.childContainer, menu.instance } do
            local rectMin = container.AbsolutePosition - Utility.guiOffset
            local rectMax = rectMin + container.AbsoluteSize
            if Utility.isPosInsideRect(MouseLocation, rectMin, rectMax) then
                isInMenu = true
                break
            end
        end
        if isInMenu then
            break
        end
    end

    if not isInMenu then
        EmptyMenuStack()
    end
end)

-------------
-- MenuBar
-------------

Internal._widgetConstructor(
    "MenuBar",
    {
        hasState = false,
        hasChildren = true,
        numArguments = 0,
        Arguments = {},
        Events = {},
        Generate = function(_thisWidget: MenuBar)
            local MenuBar = Instance.new("Frame")
            MenuBar.Name = "Iris_MenuBar"
            MenuBar.AutomaticSize = Enum.AutomaticSize.Y
            MenuBar.Size = UDim2.fromScale(1, 0)
            MenuBar.BackgroundColor3 = Internal._config.MenubarBgColor
            MenuBar.BackgroundTransparency = Internal._config.MenubarBgTransparency
            MenuBar.BorderSizePixel = 0
            MenuBar.ClipsDescendants = true

            Utility.UIPadding(MenuBar, Vector2.new(Internal._config.WindowPadding.X, 1))
            Utility.UIListLayout(MenuBar, Enum.FillDirection.Horizontal, UDim.new()).VerticalAlignment = Enum.VerticalAlignment.Center
            Utility.applyFrameStyle(MenuBar, true, true)

            return MenuBar
        end,
        Update = function(_thisWidget: Types.Widget) end,
        ChildAdded = function(thisWidget: MenuBar, _thisChild: Types.Widget)
            return thisWidget.instance
        end,
        Discard = function(thisWidget: MenuBar)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

----------
-- Menu
----------

Internal._widgetConstructor(
    "Menu",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 1,
        Arguments = { "Text", "open" },
        Events = {
            ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.instance :: any
            end),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
            ["opened"] = {
                ["Init"] = function(_thisWidget: Menu) end,
                ["Get"] = function(thisWidget: Menu)
                    return thisWidget._lastOpenedTick == Internal._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Menu) end,
                ["Get"] = function(thisWidget: Menu)
                    return thisWidget._lastClosedTick == Internal._cycleTick
                end,
            },
        },
        Generate = function(thisWidget: Menu)
            local Menu: TextButton
            thisWidget.ButtonColors = {
                Color = Internal._config.HeaderColor,
                Transparency = 1,
                HoveredColor = Internal._config.HeaderHoveredColor,
                HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                ActiveColor = Internal._config.HeaderHoveredColor,
                ActiveTransparency = Internal._config.HeaderHoveredTransparency,
            }
            if thisWidget.parentWidget.type == "Menu" then
                -- this Menu is a sub-Menu
                Menu = Instance.new("TextButton")
                Menu.Name = "Menu"
                Menu.AutomaticSize = Enum.AutomaticSize.Y
                Menu.Size = UDim2.fromScale(1, 0)
                Menu.BackgroundColor3 = Internal._config.HeaderColor
                Menu.BackgroundTransparency = 1
                Menu.BorderSizePixel = 0
                Menu.Text = ""
                Menu.AutoButtonColor = false

                local UIPadding = Utility.UIPadding(Menu, Internal._config.FramePadding)
                UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
                Utility.UIListLayout(Menu, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                Utility.applyTextStyle(TextLabel)

                TextLabel.Parent = Menu

                local frameSize = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y
                local padding = math.round(0.2 * frameSize)
                local iconSize = frameSize - 2 * padding

                local Icon = Instance.new("ImageLabel")
                Icon.Name = "Icon"
                Icon.Size = UDim2.fromOffset(iconSize, iconSize)
                Icon.BackgroundTransparency = 1
                Icon.BorderSizePixel = 0
                Icon.ImageColor3 = Internal._config.TextColor
                Icon.ImageTransparency = Internal._config.TextTransparency
                Icon.Image = Utility.ICONS.RIGHT_POINTING_TRIANGLE
                Icon.LayoutOrder = 1

                Icon.Parent = Menu
            else
                Menu = Instance.new("TextButton")
                Menu.Name = "Menu"
                Menu.AutomaticSize = Enum.AutomaticSize.XY
                Menu.Size = UDim2.fromScale(0, 0)
                Menu.BackgroundColor3 = Internal._config.HeaderColor
                Menu.BackgroundTransparency = 1
                Menu.BorderSizePixel = 0
                Menu.Text = ""
                Menu.AutoButtonColor = false
                Menu.ClipsDescendants = true

                Utility.applyTextStyle(Menu)
                Utility.UIPadding(Menu, Vector2.new(Internal._config.ItemSpacing.X, Internal._config.FramePadding.Y))
            end
            Utility.applyInteractionHighlights("Background", Menu, Menu, thisWidget.ButtonColors)

            Utility.applyButtonClick(Menu, function()
                local openMenu = if #MenuStack <= 1 then not thisWidget.state.open._value else true
                thisWidget.state.open:set(openMenu)

                AnyMenuOpen = openMenu
                ActiveMenu = openMenu and thisWidget or nil
                -- the hovering should handle all of the menus after the first one.
                if #MenuStack <= 1 then
                    if openMenu then
                        table.insert(MenuStack, thisWidget)
                    else
                        table.remove(MenuStack)
                    end
                end
            end)

            Utility.applyMouseEnter(Menu, function()
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= thisWidget then
                    local parentMenu = thisWidget.parentWidget :: Menu
                    local parentIndex = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    thisWidget.state.open:set(true)
                    ActiveMenu = thisWidget
                    AnyMenuOpen = true
                    table.insert(MenuStack, thisWidget)
                end
            end)

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "MenuContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.XY
            ChildContainer.Size = UDim2.fromOffset(0, 0)
            ChildContainer.BackgroundColor3 = Internal._config.PopupBgColor
            ChildContainer.BackgroundTransparency = Internal._config.PopupBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Internal._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Internal._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Internal._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
            ChildContainer.TopImage = Utility.ICONS.BLANK_SQUARE
            ChildContainer.MidImage = Utility.ICONS.BLANK_SQUARE
            ChildContainer.BottomImage = Utility.ICONS.BLANK_SQUARE

            ChildContainer.ZIndex = 6
            ChildContainer.LayoutOrder = 6
            ChildContainer.ClipsDescendants = true

            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Internal._config.PopupRounding > 0 then
            --     Utility.UICorner(ChildContainer, Internal._config.PopupRounding)
            -- end

            Utility.UIStroke(ChildContainer, Internal._config.WindowBorderSize, Internal._config.BorderColor, Internal._config.BorderTransparency)
            Utility.UIPadding(ChildContainer, Vector2.new(2, Internal._config.WindowPadding.Y - Internal._config.ItemSpacing.Y))

            Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, 1)).VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Internal._rootInstance and Internal._rootInstance:FindFirstChild("PopupScreenGui") :: GuiObject
            ChildContainer.Parent = RootPopupScreenGui

            thisWidget.childContainer = ChildContainer
            return Menu
        end,
        Update = function(thisWidget: Menu)
            local Menu = thisWidget.instance :: TextButton
            local TextLabel
            if thisWidget.parentWidget.type == "Menu" then
                TextLabel = Menu.TextLabel
            else
                TextLabel = Menu
            end
            TextLabel.Text = thisWidget.arguments.Text or "Menu"
        end,
        ChildAdded = function(thisWidget: Menu, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.childContainer
        end,
        ChildDiscarded = function(thisWidget: Menu, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
        end,
        GenerateState = function(thisWidget: Menu)
            if thisWidget.state.open == nil then
                thisWidget.state.open = Internal._widgetState(thisWidget, "open", false)
            end
        end,
        UpdateState = function(thisWidget: Menu)
            local ChildContainer = thisWidget.childContainer :: ScrollingFrame

            if thisWidget.state.open._value then
                thisWidget._lastOpenedTick = Internal._cycleTick + 1
                thisWidget.ButtonColors.Transparency = Internal._config.HeaderTransparency
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                thisWidget._lastClosedTick = Internal._cycleTick + 1
                thisWidget.ButtonColors.Transparency = 1
                ChildContainer.Visible = false
            end
        end,
        Discard = function(thisWidget: Menu)
            -- properly handle removing a menu if open and deleted
            if AnyMenuOpen then
                local parentMenu = thisWidget.parentWidget :: Menu
                local parentIndex = table.find(MenuStack, parentMenu)
                if parentIndex then
                    EmptyMenuStack(parentIndex)
                    if #MenuStack ~= 0 then
                        ActiveMenu = parentMenu
                        AnyMenuOpen = true
                    end
                end
            end

            thisWidget.instance:Destroy()
            thisWidget.childContainer:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

--------------
-- MenuItem
--------------

Internal._widgetConstructor(
    "MenuItem",
    {
        hasState = false,
        hasChildren = false,
        numArguments = 3,
        Arguments = { "Text", "KeyCode", "ModifierKey" },
        Events = {
            ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: MenuItem)
            local MenuItem = Instance.new("TextButton")
            MenuItem.Name = "Iris_MenuItem"
            MenuItem.AutomaticSize = Enum.AutomaticSize.Y
            MenuItem.Size = UDim2.fromScale(1, 0)
            MenuItem.BackgroundTransparency = 1
            MenuItem.BorderSizePixel = 0
            MenuItem.Text = ""
            MenuItem.AutoButtonColor = false

            local UIPadding = Utility.UIPadding(MenuItem, Internal._config.FramePadding)
            UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
            Utility.UIListLayout(MenuItem, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X))

            Utility.applyInteractionHighlights("Background", MenuItem, MenuItem, {
                Color = Internal._config.HeaderColor,
                Transparency = 1,
                HoveredColor = Internal._config.HeaderHoveredColor,
                HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                ActiveColor = Internal._config.HeaderHoveredColor,
                ActiveTransparency = Internal._config.HeaderHoveredTransparency,
            })

            Utility.applyButtonClick(MenuItem, function()
                EmptyMenuStack()
            end)

            Utility.applyMouseEnter(MenuItem, function()
                local parentMenu = thisWidget.parentWidget :: Menu
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= parentMenu then
                    local parentIndex = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    ActiveMenu = parentMenu
                    AnyMenuOpen = true
                end
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = MenuItem

            local Shortcut = Instance.new("TextLabel")
            Shortcut.Name = "Shortcut"
            Shortcut.AutomaticSize = Enum.AutomaticSize.XY
            Shortcut.BackgroundTransparency = 1
            Shortcut.BorderSizePixel = 0
            Shortcut.LayoutOrder = 1

            Utility.applyTextStyle(Shortcut)

            Shortcut.Text = ""
            Shortcut.TextColor3 = Internal._config.TextDisabledColor
            Shortcut.TextTransparency = Internal._config.TextDisabledTransparency

            Shortcut.Parent = MenuItem

            return MenuItem
        end,
        Update = function(thisWidget: MenuItem)
            local MenuItem = thisWidget.instance :: TextButton
            local TextLabel: TextLabel = MenuItem.TextLabel
            local Shortcut: TextLabel = MenuItem.Shortcut

            TextLabel.Text = thisWidget.arguments.Text
            if thisWidget.arguments.KeyCode then
                if thisWidget.arguments.ModifierKey then
                    Shortcut.Text = thisWidget.arguments.ModifierKey.Name .. " + " .. thisWidget.arguments.KeyCode.Name
                else
                    Shortcut.Text = thisWidget.arguments.KeyCode.Name
                end
            end
        end,
        Discard = function(thisWidget: MenuItem)
            thisWidget.instance:Destroy()
        end,
    } :: Types.WidgetClass
)

----------------
-- MenuToggle
----------------

Internal._widgetConstructor(
    "MenuToggle",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 3,
        Arguments = { "Text", "KeyCode", "ModifierKey", "checked" },
        Events = {
            ["checked"] = {
                ["Init"] = function(_thisWidget: MenuToggle) end,
                ["Get"] = function(thisWidget: MenuToggle): boolean
                    return thisWidget._lastCheckedTick == Internal._cycleTick
                end,
            },
            ["unchecked"] = {
                ["Init"] = function(_thisWidget: MenuToggle) end,
                ["Get"] = function(thisWidget: MenuToggle): boolean
                    return thisWidget._lastUncheckedTick == Internal._cycleTick
                end,
            },
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: MenuToggle)
            local MenuToggle = Instance.new("TextButton")
            MenuToggle.Name = "Iris_MenuToggle"
            MenuToggle.AutomaticSize = Enum.AutomaticSize.Y
            MenuToggle.Size = UDim2.fromScale(1, 0)
            MenuToggle.BackgroundTransparency = 1
            MenuToggle.BorderSizePixel = 0
            MenuToggle.Text = ""
            MenuToggle.AutoButtonColor = false

            local UIPadding = Utility.UIPadding(MenuToggle, Internal._config.FramePadding)
            UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
            Utility.UIListLayout(MenuToggle, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            Utility.applyInteractionHighlights("Background", MenuToggle, MenuToggle, {
                Color = Internal._config.HeaderColor,
                Transparency = 1,
                HoveredColor = Internal._config.HeaderHoveredColor,
                HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                ActiveColor = Internal._config.HeaderHoveredColor,
                ActiveTransparency = Internal._config.HeaderHoveredTransparency,
            })

            Utility.applyButtonClick(MenuToggle, function()
                thisWidget.state.checked:set(not thisWidget.state.checked._value)
                EmptyMenuStack()
            end)

            Utility.applyMouseEnter(MenuToggle, function()
                local parentMenu = thisWidget.parentWidget :: Menu
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= parentMenu then
                    local parentIndex = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    ActiveMenu = parentMenu
                    AnyMenuOpen = true
                end
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = MenuToggle

            local Shortcut = Instance.new("TextLabel")
            Shortcut.Name = "Shortcut"
            Shortcut.AutomaticSize = Enum.AutomaticSize.XY
            Shortcut.BackgroundTransparency = 1
            Shortcut.BorderSizePixel = 0
            Shortcut.LayoutOrder = 1

            Utility.applyTextStyle(Shortcut)

            Shortcut.Text = ""
            Shortcut.TextColor3 = Internal._config.TextDisabledColor
            Shortcut.TextTransparency = Internal._config.TextDisabledTransparency

            Shortcut.Parent = MenuToggle

            local frameSize = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y
            local padding = math.round(0.2 * frameSize)
            local iconSize = frameSize - 2 * padding

            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Size = UDim2.fromOffset(iconSize, iconSize)
            Icon.BackgroundTransparency = 1
            Icon.BorderSizePixel = 0
            Icon.ImageColor3 = Internal._config.TextColor
            Icon.ImageTransparency = Internal._config.TextTransparency
            Icon.Image = Utility.ICONS.CHECK_MARK
            Icon.LayoutOrder = 2

            Icon.Parent = MenuToggle

            return MenuToggle
        end,
        GenerateState = function(thisWidget: MenuToggle)
            if thisWidget.state.checked == nil then
                thisWidget.state.checked = Internal._widgetState(thisWidget, "checked", false)
            end
        end,
        Update = function(thisWidget: MenuToggle)
            local MenuToggle = thisWidget.instance :: TextButton
            local TextLabel: TextLabel = MenuToggle.TextLabel
            local Shortcut: TextLabel = MenuToggle.Shortcut

            TextLabel.Text = thisWidget.arguments.Text
            if thisWidget.arguments.KeyCode then
                if thisWidget.arguments.ModifierKey then
                    Shortcut.Text = thisWidget.arguments.ModifierKey.Name .. " + " .. thisWidget.arguments.KeyCode.Name
                else
                    Shortcut.Text = thisWidget.arguments.KeyCode.Name
                end
            end
        end,
        UpdateState = function(thisWidget: MenuToggle)
            local MenuItem = thisWidget.instance :: TextButton
            local Icon: ImageLabel = MenuItem.Icon

            if thisWidget.state.checked._value then
                Icon.ImageTransparency = Internal._config.TextTransparency
                thisWidget._lastCheckedTick = Internal._cycleTick + 1
            else
                Icon.ImageTransparency = 1
                thisWidget._lastUncheckedTick = Internal._cycleTick + 1
            end
        end,
        Discard = function(thisWidget: MenuToggle)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

--[=[
    @within Menu
    @tag Widget
    @tag HasChildren
    
    @function MenuBar
    
    @return MenuBar
    
    Creates a MenuBar for the current window. Must be called directly under a Window and not within a child widget.
    :::info
        This does not create any menus, just tells the window that we going to add menus within.
    :::
]=]
local API_MenuBar = function()
    return Internal._insert("MenuBar") :: MenuBar
end

--[=[
    @within Menu
    @tag Widget
    @tag HasChildren
    @tag HasState

    @function Menu
    @param text string -- title of the menu
    @param open State<boolean? -- state for whether the menu is open

    @return Menu
    
    Creates an collapsable menu. If the Menu is created directly under a MenuBar, then the widget will
    be placed horizontally below the window title. If the menu Menu is created within another menu, then
    it will be placed vertically alongside MenuItems and display an arrow alongside.

    The opened menu will be a vertically listed box below or next to the button.

    ```lua
        Iris.Window({"Menu Demo"})
            Iris.MenuBar()
                Iris.Menu({"Test Menu"})
                    Iris.Button({"Menu Option 1"})
                    Iris.Button({"Menu Option 2"})
                Iris.End()
            Iris.End()
        Iris.End()
    ```

    ![Example menu](/Iris/assets/api/menu/basicMenu.gif)

    :::info
    There are widgets which are designed for being parented to a menu whilst other happens to work. There is nothing
    preventing you from adding any widget as a child, but the behaviour is unexplained and not intended.
    :::
]=]
local API_Menu = function(text: string, open: Types.State<boolean>?)
    return Internal._insert("Menu", text, open) :: Menu
end

--[=[
    @within Menu
    @tag Widget
    
    @function MenuItem
    @param text string -- title of the item
    @param keyCode Enum.KeyCode? -- optional keycode to show on the right
    @param modifierKey Enum.ModifierKey? -- optional modifier keycode to show on the right

    @return MenuItem
    
    Creates a button within a menu. The optional KeyCode and ModiferKey arguments will show the keys next
    to the title, but **will not** bind any connection to them. You will need to do this yourself.

    ```lua
    Iris.Window({"MenuToggle Demo"})
        Iris.MenuBar()
            Iris.MenuToggle({"Menu Item"})
        Iris.End()
    Iris.End()
    ```

    ![Example Menu Item](/Iris/assets/api/menu/basicMenuItem.gif)
]=]
local API_MenuItem = function(text: string, keyCode: Enum.KeyCode?, modifierKey: Enum.ModifierKey?)
    return Internal._insert("MenuItem", text, keyCode, modifierKey) :: MenuItem
end

--[=[
    @within Menu
    @tag Widget
    @tag HasState
    
    @function MenuToggle

    @param text string -- title of the item
    @param keyCode Enum.KeyCode? -- optional keycode to show on the right
    @param modifierKey Enum.ModifierKey? -- optional modifier keycode to show on the right
    @param checked State<boolean>? -- state for whether the toggle is checked

    @return MenuToggle    
    
    Creates a togglable button within a menu. The optional KeyCode and ModiferKey arguments act the same
    as the MenuItem. It is not visually the same as a checkbox, but has the same functionality.
    
    ```lua
    Iris.Window({"MenuToggle Demo"})
        Iris.MenuBar()
            Iris.MenuToggle({"Menu Toggle"})
        Iris.End()
    Iris.End()
    ```

    ![Example Menu Toggle](/Iris/assets/api/menu/basicMenuToggle.gif)
]=]
local API_MenuToggle = function(text: string, keyCode: Enum.KeyCode?, modifierKey: Enum.ModifierKey?, checked: Types.State<boolean>?)
    return Internal._insert("MenuToggle", text, keyCode, modifierKey, checked) :: MenuToggle
end

return {
    API_MenuBar = API_MenuBar,
    API_Menu = API_Menu,
    API_MenuItem = API_MenuItem,
    API_MenuToggle = API_MenuToggle,
}
