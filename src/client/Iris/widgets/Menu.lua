local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Iris, widgets: Types.WidgetUtility)
    local AnyMenuOpen: boolean = false
    local MenuOpenTick: number = 0
    local ActiveMenu: Types.Widget
    local MenuStack: { Types.Widget } = {}

    local function UpdateChildContainerTransform(thisWidget: Types.Widget)
        local Menu = thisWidget.Instance :: Frame
        local ChildContainer = thisWidget.ChildContainer :: Frame

        local ChildContainerBorderSize: number = Iris._config.PopupBorderSize
        local ChildContainerHeight: number = ChildContainer.AbsoluteSize.Y

        local ScreenSize: Vector2 = ChildContainer.Parent.AbsoluteSize

        if Menu.AbsolutePosition.Y + thisWidget.LabelHeight + ChildContainerHeight > ScreenSize.Y then
            -- too large to fit below the Combo, so is placed above
            ChildContainer.Position = UDim2.new(0, Menu.AbsolutePosition.X + ChildContainerBorderSize, 0, Menu.AbsolutePosition.Y - ChildContainerBorderSize - ChildContainerHeight)
        else
            ChildContainer.Position = UDim2.new(0, Menu.AbsolutePosition.X + ChildContainerBorderSize, 0, Menu.AbsolutePosition.Y + thisWidget.LabelHeight + ChildContainerBorderSize)
        end
    end

    widgets.UserInputService.InputBegan:Connect(function(inputObject: InputObject)
        if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 then
            return
        end
        if AnyMenuOpen == false then
            return
        end
        if MenuOpenTick == Iris._cycleTick then
            return
        end

        local MouseLocation: Vector2 = widgets.UserInputService:GetMouseLocation() - widgets.GuiInset
        for _, menu: Types.Widget in MenuStack do
            local Container: GuiObject = menu.ChildContainer
            local rectMin: Vector2 = Container.AbsolutePosition
            local rectMax: Vector2 = rectMin + Container.AbsoluteSize
            if not widgets.isPosInsideRect(MouseLocation, rectMin, rectMax) then
            end
        end
    end)

    Iris.WidgetConstructor("Menu", {
        hasState = false,
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
                ["Init"] = function(thisWidget) end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(thisWidget) end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end,
            },
        },
        Generate = function(thisWidget: Types.Widget)
            local Menu: TextButton = Instance.new("TextButton")
            Menu.Name = "Menu"
            Menu.Size = UDim2.new()
            Menu.AutomaticSize = Enum.AutomaticSize.XY
            Menu.LayoutOrder = thisWidget.ZIndex
            Menu.ZIndex = thisWidget.ZIndex
            Menu.AutoButtonColor = false
            Menu.ClipsDescendants = true
            widgets.applyTextStyle(Menu)
            widgets.UIPadding(Menu, Vector2.new(Iris._config.ItemSpacing.X, Iris._config.FramePadding.Y - 1))

            widgets.applyInteractionHighlights(Menu, Menu, {
                ButtonColor = Color3.fromRGB(255, 255, 255),
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.HeaderHoveredColor,
                ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
                ButtonActiveColor = Iris._config.HeaderActiveColor,
                ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
            })

            Menu.InputBegan:Connect(function(inputObject: InputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    thisWidget.state.isOpened:set(not thisWidget.state.isOpened.value)
                    AnyMenuOpen = true
                    ActiveMenu = Menu
                end
            end)
            Menu.MouseEnter:Connect(function()
                if AnyMenuOpen then
                    ActiveMenu = Menu
                end
            end)

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.BorderSizePixel = 0
            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Iris._config.PopupRounding > 0 then
            --     widgets.UICorner(ChildContainer, Iris._config.PopupRounding)
            -- end

            local uiStroke = Instance.new("UIStroke")
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.LineJoinMode = Enum.LineJoinMode.Round
            uiStroke.Thickness = Iris._config.WindowBorderSize
            uiStroke.Color = Iris._config.BorderColor
            uiStroke.Parent = ChildContainer
            widgets.UIPadding(ChildContainer, Vector2.new(2, Iris._config.WindowPadding.Y - Iris._config.ItemSpacing.Y))
            -- appear over everything else
            ChildContainer.ZIndex = thisWidget.ZIndex + 6
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 6
            ChildContainer.ClipsDescendants = true

            local ChildContainerUIListLayout = widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Iris._rootInstance.PopupScreenGui
            ChildContainer.Parent = RootPopupScreenGui
            thisWidget.ChildContainer = ChildContainer

            return Menu
        end,
        Update = function(thisWidget: Types.Widget)
            local Menu = thisWidget.Instance :: TextButton
            Menu.Text = thisWidget.arguments.Text or "Menu"
        end,
        ChildDiscarded = function(thisWidget: Types.Widget, otherWidget: Types.Widget)
            return thisWidget.ChildContainer
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", false)
            end
        end,
        UpdateState = function(thisWidget)
            local ChildContainer = thisWidget.ChildContainer

            if thisWidget.state.isOpened.value then
                thisWidget.lastOpenedTick = Iris._cycleTick + 1
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                thisWidget.lastClosedTick = Iris._cycleTick + 1
                ChildContainer.Visible = false
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)
end
