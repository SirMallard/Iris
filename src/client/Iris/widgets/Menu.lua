local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local AnyMenuOpen: boolean = false
    local ActiveMenu: Types.Widget?
    local MenuStack: { Types.Widget } = {}

    local function EmptyMenuStack(menuIndex: number?)
        for index = #MenuStack, menuIndex and menuIndex + 1 or 1, -1 do
            local widget: Types.Widget = MenuStack[index]
            widget.state.isOpened:set(false)

            widget.Instance.BackgroundColor3 = Iris._config.HeaderColor
            widget.Instance.BackgroundTransparency = 1
            
            table.remove(MenuStack, index)
        end

        if #MenuStack == 0 then
            AnyMenuOpen = false
            ActiveMenu = nil
        end
    end

    local function UpdateChildContainerTransform(thisWidget: Types.Widget)
        local submenu: boolean = thisWidget.parentWidget.type == "Menu"

        local Menu = thisWidget.Instance :: Frame
        local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame
        ChildContainer.Size = UDim2.fromOffset(math.max(ChildContainer.AbsoluteSize.X, Menu.AbsoluteSize.X), math.max(ChildContainer.AbsoluteSize.Y, Menu.AbsoluteSize.Y))
        if ChildContainer.Parent == nil then
            return
        end

        local menuPosition: Vector2 = Menu.AbsolutePosition
        local menuSize: Vector2 = Menu.AbsoluteSize
        local containerSize: Vector2 = ChildContainer.AbsoluteSize
        local borderSize: number = Iris._config.PopupBorderSize
        local screenSize: Vector2 = ChildContainer.Parent.AbsoluteSize

        local x: number = menuPosition.X + borderSize
        local y: number

        if thisWidget.parentWidget.type == "Menu" then
            if menuPosition.X + containerSize.X > screenSize.X then
                x = menuPosition.X - borderSize - (submenu and containerSize.X or 0)
            else
                x = menuPosition.X + borderSize + (submenu and menuSize.X or 0)
            end
        end

        if menuPosition.Y + containerSize.Y > screenSize.Y then
            -- too low.
            y = menuPosition.Y - borderSize - containerSize.Y + (submenu and menuSize.Y or 0)
        else
            y = menuPosition.Y + borderSize + (submenu and 0 or menuSize.Y)
        end

        ChildContainer.Position = UDim2.fromOffset(x, y)
    end

    widgets.UserInputService.InputBegan:Connect(function(inputObject: InputObject)
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
        local isInMenu: boolean = false
        local MouseLocation: Vector2 = widgets.getMouseLocation()
        for _, menu: Types.Widget in MenuStack do
            for _, container: GuiObject in { menu.ChildContainer, menu.Instance } do
                local rectMin: Vector2 = container.AbsolutePosition
                local rectMax: Vector2 = rectMin + container.AbsoluteSize
                if widgets.isPosInsideRect(MouseLocation, rectMin, rectMax) then
                    isInMenu = true
                    break
                end
            end
        end

        if not isInMenu then
            EmptyMenuStack()
        end
    end)

    Iris.WidgetConstructor("MenuBar", {
        hasState = false,
        hasChildren = true,
        Args = {},
        Events = {},
        Generate = function(thisWidget: Types.Widget)
            local MenuBar: Frame = Instance.new("Frame")
            MenuBar.Name = "MenuBar"
            MenuBar.Size = UDim2.fromScale(1, 0)
            MenuBar.AutomaticSize = Enum.AutomaticSize.Y
            MenuBar.BackgroundColor3 = Iris._config.MenubarBgColor
            MenuBar.BackgroundTransparency = Iris._config.MenubarBgTransparency
            MenuBar.BorderSizePixel = 0
            MenuBar.ZIndex = thisWidget.ZIndex
            MenuBar.LayoutOrder = thisWidget.ZIndex
            MenuBar.ClipsDescendants = true

            widgets.UIPadding(MenuBar, Vector2.new(Iris._config.ItemSpacing.X, 2))
            widgets.UIListLayout(MenuBar, Enum.FillDirection.Horizontal, UDim.new()).VerticalAlignment = Enum.VerticalAlignment.Center

            return MenuBar
        end,
        Update = function(thisWidget: Types.Widget)
            local parent: Types.Widget = thisWidget.parentWidget
            if parent.type == "Window" then
                local instance = parent.Instance and parent.Instance:FindFirstChild("WindowButton") :: TextButton?
                -- we very sneakily change our parent to the window and then update it.
                if instance then
                    thisWidget.Instance.Parent = instance

                    -- even sneakier trick to update the window the next frame.
                    local callbackIndex: number = #Iris._postCycleCallbacks + 1
                    local desiredCycleTick: number = Iris._cycleTick + 1
                    Iris._postCycleCallbacks[callbackIndex] = function()
                        if Iris._cycleTick == desiredCycleTick then
                            Iris._widgets["Window"].Update(parent)
                            Iris._postCycleCallbacks[callbackIndex] = nil
                        end
                    end
                end
                return
            elseif parent.type == "Root" then
                return
            end
            error("The MenuBar was not created directly under a window or root.")
            -- we tell the window to update and add the menubar, effectively be reparenting and positioning it.
        end,
        ChildAdded = function(thisWidget: Types.Widget)
            return thisWidget.Instance
        end,
        Discard = function(thisWidget: Types.Widget)
            local Window: Types.Widget = thisWidget.parentWidget
            thisWidget.Instance:Destroy()
            -- the window no longer needs to render the menubar.
            Iris._widgets["Window"].Update(Window)
        end,
    } :: Types.WidgetClass)

    Iris.WidgetConstructor("Menu", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Text"] = 1,
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["opened"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end,
            },
        },
        Generate = function(thisWidget: Types.Widget)
            local Menu: TextButton
            thisWidget.ButtonColors = {
                ButtonColor = Iris._config.HeaderColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderHoveredColor,
                ButtonActiveTransparency = Iris._config.HeaderHoveredTransparency,
            }
            if thisWidget.parentWidget.type == "Menu" then
                -- this Menu is a sub-Menu
                Menu = Instance.new("TextButton")
                Menu.Name = "Menu"
                Menu.BackgroundColor3 = Iris._config.HeaderColor
                Menu.BackgroundTransparency = 1
                Menu.BorderSizePixel = 0
                Menu.Size = UDim2.fromScale(1, 0)
                Menu.Text = ""
                Menu.AutomaticSize = Enum.AutomaticSize.Y
                Menu.ZIndex = thisWidget.ZIndex
                Menu.LayoutOrder = thisWidget.ZIndex
                Menu.AutoButtonColor = false

                local UIPadding = widgets.UIPadding(Menu, Iris._config.FramePadding)
                UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
                widgets.UIListLayout(Menu, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AnchorPoint = Vector2.new(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.ZIndex = thisWidget.ZIndex + 2
                TextLabel.LayoutOrder = thisWidget.ZIndex + 2
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY

                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Menu

                local frameSize: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
                local padding: number = math.round(0.2 * frameSize)
                local iconSize: number = frameSize - 2 * padding

                local Icon: ImageLabel = Instance.new("ImageLabel")
                Icon.Name = "Icon"
                Icon.Size = UDim2.fromOffset(iconSize, iconSize)
                Icon.BackgroundTransparency = 1
                Icon.BorderSizePixel = 0
                Icon.ImageColor3 = Iris._config.TextColor
                Icon.ImageTransparency = Iris._config.TextTransparency
                Icon.Image = widgets.ICONS.RIGHT_POINTING_TRIANGLE
                Icon.ZIndex = thisWidget.ZIndex + 3
                Icon.LayoutOrder = thisWidget.ZIndex + 3

                Icon.Parent = Menu
            else
                Menu = Instance.new("TextButton")
                Menu.Name = "Menu"
                Menu.Size = UDim2.fromScale(0, 0)
                Menu.AutomaticSize = Enum.AutomaticSize.XY
                Menu.BackgroundColor3 = Iris._config.HeaderColor
                Menu.BackgroundTransparency = 1
                Menu.BorderSizePixel = 0
                Menu.Text = ""
                Menu.LayoutOrder = thisWidget.ZIndex
                Menu.ZIndex = thisWidget.ZIndex
                Menu.AutoButtonColor = false
                Menu.ClipsDescendants = true

                widgets.applyTextStyle(Menu)
                widgets.UIPadding(Menu, Vector2.new(Iris._config.ItemSpacing.X, Iris._config.FramePadding.Y))
            end
            widgets.applyInteractionHighlights(Menu, Menu, thisWidget.ButtonColors)

            Menu.MouseButton1Click:Connect(function()
                local openMenu: boolean = if #MenuStack <= 1 then not thisWidget.state.isOpened.value else true
                thisWidget.state.isOpened:set(openMenu)

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
            Menu.MouseEnter:Connect(function()
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= thisWidget then
                    local parentMenu: Types.Widget = thisWidget.parentWidget
                    local parentIndex: number? = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    thisWidget.state.isOpened:set(true)
                    ActiveMenu = thisWidget
                    AnyMenuOpen = true
                    table.insert(MenuStack, thisWidget)
                end
            end)

            local ChildContainer: ScrollingFrame = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0
            ChildContainer.Size = UDim2.fromOffset(0, 0)
            ChildContainer.AutomaticSize = Enum.AutomaticSize.XY

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

            ChildContainer.ZIndex = thisWidget.ZIndex + 6
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 6
            ChildContainer.ClipsDescendants = true

            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Iris._config.PopupRounding > 0 then
            --     widgets.UICorner(ChildContainer, Iris._config.PopupRounding)
            -- end

            local ChildContainerUIListLayout: UIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, 1))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Iris._rootInstance and Iris._rootInstance:FindFirstChild("PopupScreenGui") :: GuiObject
            ChildContainer.Parent = RootPopupScreenGui
            thisWidget.ChildContainer = ChildContainer

            widgets.UIStroke(ChildContainer, Iris._config.WindowBorderSize, Iris._config.BorderColor, Iris._config.BorderTransparency)
            widgets.UIPadding(ChildContainer, Vector2.new(2, Iris._config.WindowPadding.Y - Iris._config.ItemSpacing.Y))

            return Menu
        end,
        Update = function(thisWidget: Types.Widget)
            local Menu = thisWidget.Instance :: TextButton
            local TextLabel: TextLabel
            if thisWidget.parentWidget.type == "Menu" then
                TextLabel = Menu.TextLabel
            else
                TextLabel = Menu
            end
            TextLabel.Text = thisWidget.arguments.Text or "Menu"
        end,
        ChildAdded = function(thisWidget: Types.Widget, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.ChildContainer
        end,
        ChildDiscarded = function(thisWidget: Types.Widget, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", false)
            end
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local ChildContainer = thisWidget.ChildContainer :: ScrollingFrame

            if thisWidget.state.isOpened.value then
                thisWidget.lastOpenedTick = Iris._cycleTick + 1
                thisWidget.ButtonColors.ButtonTransparency = Iris._config.HeaderTransparency
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                thisWidget.lastClosedTick = Iris._cycleTick + 1
                thisWidget.ButtonColors.ButtonTransparency = 1
                ChildContainer.Visible = false
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)

    Iris.WidgetConstructor("MenuItem", {
        hasState = false,
        hasChildren = false,
        Args = {
            Text = 1,
            KeyCode = 2,
            ModifierKey = 3,
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local MenuItem: TextButton = Instance.new("TextButton")
            MenuItem.Name = "MenuItem"
            MenuItem.BackgroundTransparency = 1
            MenuItem.BorderSizePixel = 0
            MenuItem.Size = UDim2.fromScale(1, 0)
            MenuItem.Text = ""
            MenuItem.AutomaticSize = Enum.AutomaticSize.Y
            MenuItem.ZIndex = thisWidget.ZIndex
            MenuItem.LayoutOrder = thisWidget.ZIndex
            MenuItem.AutoButtonColor = false

            local UIPadding = widgets.UIPadding(MenuItem, Iris._config.FramePadding)
            UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
            widgets.UIListLayout(MenuItem, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

            widgets.applyInteractionHighlights(MenuItem, MenuItem, {
                ButtonColor = Iris._config.HeaderColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderHoveredColor,
                ButtonActiveTransparency = Iris._config.HeaderHoveredTransparency,
            })

            MenuItem.MouseButton1Click:Connect(function()
                EmptyMenuStack()
            end)

            MenuItem.MouseEnter:Connect(function()
                local parentMenu: Types.Widget = thisWidget.parentWidget
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= parentMenu then
                    local parentIndex: number? = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    ActiveMenu = parentMenu
                    AnyMenuOpen = true
                end
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AnchorPoint = Vector2.new(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 2
            TextLabel.LayoutOrder = thisWidget.ZIndex + 2
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = MenuItem

            local Shortcut: TextLabel = Instance.new("TextLabel")
            Shortcut.Name = "Shortcut"
            Shortcut.AnchorPoint = Vector2.new(0, 0)
            Shortcut.BackgroundTransparency = 1
            Shortcut.BorderSizePixel = 0
            Shortcut.ZIndex = thisWidget.ZIndex + 3
            Shortcut.LayoutOrder = thisWidget.ZIndex + 3
            Shortcut.AutomaticSize = Enum.AutomaticSize.XY

            widgets.applyTextStyle(Shortcut)

            Shortcut.Text = ""
            Shortcut.TextColor3 = Iris._config.TextDisabledColor
            Shortcut.TextTransparency = Iris._config.TextDisabledTransparency

            Shortcut.Parent = MenuItem

            return MenuItem
        end,
        Update = function(thisWidget: Types.Widget)
            local MenuItem = thisWidget.Instance :: TextButton
            local TextLabel: TextLabel = MenuItem.TextLabel
            local Shortcut: TextLabel = MenuItem.Shortcut

            TextLabel.Text = thisWidget.arguments.Text
            if thisWidget.arguments.KeyCode then
                Shortcut.Text = thisWidget.arguments.ModifierKey.Name .. " + " .. thisWidget.arguments.KeyCode.Name
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    Iris.WidgetConstructor("MenuToggle", {
        hasState = true,
        hasChildren = false,
        Args = {
            Text = 1,
            KeyCode = 2,
            ModifierKey = 3,
        },
        Events = {
            ["checked"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastCheckedTick == Iris._cycleTick
                end,
            },
            ["unchecked"] = {
                ["Init"] = function(_thisWidget: Types.Widget) end,
                ["Get"] = function(thisWidget: Types.Widget): boolean
                    return thisWidget.lastUncheckedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local MenuItem: TextButton = Instance.new("TextButton")
            MenuItem.Name = "MenuItem"
            MenuItem.BackgroundTransparency = 1
            MenuItem.BorderSizePixel = 0
            MenuItem.Size = UDim2.fromScale(1, 0)
            MenuItem.Text = ""
            MenuItem.AutomaticSize = Enum.AutomaticSize.Y
            MenuItem.ZIndex = thisWidget.ZIndex
            MenuItem.LayoutOrder = thisWidget.ZIndex
            MenuItem.AutoButtonColor = false

            local UIPadding = widgets.UIPadding(MenuItem, Iris._config.FramePadding)
            UIPadding.PaddingTop = UIPadding.PaddingTop - UDim.new(0, 1)
            widgets.UIListLayout(MenuItem, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            widgets.applyInteractionHighlights(MenuItem, MenuItem, {
                ButtonColor = Iris._config.HeaderColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderHoveredColor,
                ButtonActiveTransparency = Iris._config.HeaderHoveredTransparency,
            })

            MenuItem.MouseButton1Click:Connect(function()
                local wasChecked: boolean = thisWidget.state.isChecked.value
                thisWidget.state.isChecked:set(not wasChecked)
                EmptyMenuStack()
            end)

            MenuItem.MouseEnter:Connect(function()
                local parentMenu: Types.Widget = thisWidget.parentWidget
                if AnyMenuOpen and ActiveMenu and ActiveMenu ~= parentMenu then
                    local parentIndex: number? = table.find(MenuStack, parentMenu)

                    EmptyMenuStack(parentIndex)
                    ActiveMenu = parentMenu
                    AnyMenuOpen = true
                end
            end)

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AnchorPoint = Vector2.new(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 2
            TextLabel.LayoutOrder = thisWidget.ZIndex + 2
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = MenuItem

            local Shortcut: TextLabel = Instance.new("TextLabel")
            Shortcut.Name = "Shortcut"
            Shortcut.AnchorPoint = Vector2.new(0, 0)
            Shortcut.BackgroundTransparency = 1
            Shortcut.BorderSizePixel = 0
            Shortcut.ZIndex = thisWidget.ZIndex + 3
            Shortcut.LayoutOrder = thisWidget.ZIndex + 3
            Shortcut.AutomaticSize = Enum.AutomaticSize.XY

            widgets.applyTextStyle(Shortcut)

            Shortcut.Text = ""
            Shortcut.TextColor3 = Iris._config.TextDisabledColor
            Shortcut.TextTransparency = Iris._config.TextDisabledTransparency

            Shortcut.Parent = MenuItem

            local frameSize: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
            local padding: number = math.round(0.2 * frameSize)
            local iconSize: number = frameSize - 2 * padding

            local Icon: ImageLabel = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Size = UDim2.fromOffset(iconSize, iconSize)
            Icon.BackgroundTransparency = 1
            Icon.BorderSizePixel = 0
            Icon.ImageColor3 = Iris._config.TextColor
            Icon.ImageTransparency = Iris._config.TextTransparency
            Icon.Image = widgets.ICONS.CHECK_MARK
            Icon.ZIndex = thisWidget.ZIndex + 4
            Icon.LayoutOrder = thisWidget.ZIndex + 4

            Icon.Parent = MenuItem

            return MenuItem
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.isChecked == nil then
                thisWidget.state.isChecked = Iris._widgetState(thisWidget, "isChecked", false)
            end
        end,
        Update = function(thisWidget: Types.Widget)
            local MenuItem = thisWidget.Instance :: TextButton
            local TextLabel: TextLabel = MenuItem.TextLabel
            local Shortcut: TextLabel = MenuItem.Shortcut

            TextLabel.Text = thisWidget.arguments.Text
            if thisWidget.arguments.KeyCode then
                Shortcut.Text = thisWidget.arguments.ModifierKey.Name .. " + " .. thisWidget.arguments.KeyCode.Name
            end
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local MenuItem = thisWidget.Instance :: TextButton
            local Icon: ImageLabel = MenuItem.Icon

            if thisWidget.state.isChecked.value then
                Icon.Image = widgets.ICONS.CHECK_MARK
                thisWidget.lastCheckedTick = Iris._cycleTick + 1
            else
                Icon.Image = ""
                thisWidget.lastUncheckedTick = Iris._cycleTick + 1
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)
end
