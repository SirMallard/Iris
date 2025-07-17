--!strict
local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local dragPopup: Types.Popup? = nil
    local isDragging = false
    local mouseDragOffset = Vector2.zero

    local function clampPositionToBounds(thisWidget: Types.Popup, intendedPosition: Vector2)
        local thisWidgetInstance = thisWidget.Instance
        local usableSize = (thisWidgetInstance.Parent :: GuiBase2d).AbsoluteSize
        local safeAreaPadding = Vector2.new(Iris._config.PopupBorderSize + Iris._config.DisplaySafeAreaPadding.X, Iris._config.PopupBorderSize + Iris._config.DisplaySafeAreaPadding.Y)

        return Vector2.new(
            math.clamp(intendedPosition.X, safeAreaPadding.X, math.max(safeAreaPadding.X, usableSize.X - thisWidgetInstance.AbsoluteSize.X - safeAreaPadding.X)),
            math.clamp(intendedPosition.Y, safeAreaPadding.Y, math.max(safeAreaPadding.Y, usableSize.Y - thisWidgetInstance.AbsoluteSize.Y - safeAreaPadding.Y))
        )
    end

    local popupWidgets: { [Types.ID]: Types.Popup } = {}
    local anyPopupOpen = false
    local activePopup: Types.Popup? = nil
    local popupStack: { Types.Popup } = {}

    local function emptyPopupStack(stackIndex: number?)
        for index = #popupStack, stackIndex and stackIndex + 1 or 1, -1 do
            local thisWidget = popupStack[index]
            thisWidget.state.isOpen:set(false)
            table.remove(popupStack, index)
        end

        if #popupStack == 0 then
            anyPopupOpen = false
            activePopup = nil
        else
            activePopup = popupStack[#popupStack]
        end
    end

    local function updateModalBackgrounds()
        local found = false
        for index = #popupStack, 1, -1 do
            local thisWidget = popupStack[index]
            if thisWidget.arguments.Modal then
                thisWidget.Modal.Visible = not found
                found = true
            end
        end
    end

    widgets.registerEvent("InputBegan", function(inputObject: InputObject)
        if not Iris._started then
            return
        end
        if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 then
            return
        end
        if anyPopupOpen == false then
            return
        end
        if activePopup == nil then
            return
        end

        -- this only checks if we clicked outside all the menus. If we clicked in any menu, then the hover function handles this.
        local isInPopup = false
        local mouseLocation = widgets.getMouseLocation()
        for index = #popupStack, 1, -1 do
            local popup = popupStack[index]
            for _, container in { popup.ChildContainer, popup.Instance } do
                local rectMin = container.AbsolutePosition - widgets.GuiOffset
                local rectMax = rectMin + container.AbsoluteSize
                if widgets.isPosInsideRect(mouseLocation, rectMin, rectMax) then
                    isInPopup = true
                    break
                end
            end
            if popup.Modal.Visible == true then
                isInPopup = true
            end
            if isInPopup then
                emptyPopupStack(index)
                break
            end
        end

        if not isInPopup then
            emptyPopupStack()
        end
        updateModalBackgrounds()
    end)

    widgets.registerEvent("InputChanged", function(input: InputObject)
        if not Iris._started then
            return
        end
        if isDragging and dragPopup then
            local mouseLocation
            if input.UserInputType == Enum.UserInputType.Touch then
                local location = input.Position
                mouseLocation = Vector2.new(location.X, location.Y)
            else
                mouseLocation = widgets.getMouseLocation()
            end

            local Popup = dragPopup.Instance
            local intendedPosition = mouseLocation - mouseDragOffset
            local position = clampPositionToBounds(dragPopup, intendedPosition)
            Popup.Position = UDim2.fromOffset(position.X, position.Y)
        end
    end)

    widgets.registerEvent("InputEnded", function(input: InputObject)
        if not Iris._started then
            return
        end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging and dragPopup then
            isDragging = false
        end
    end)

    --stylua: ignore
    Iris.WidgetConstructor("Popup", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Modal"] = 1,
            ["Menu"] = 2,
            ["NoMove"] = 3,
        },
        Events = {},
        Generate = function(thisWidget: Types.Popup)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent
            popupWidgets[thisWidget.ID] = thisWidget

            local Popup = Instance.new("TextButton")
            Popup.Name = "Iris_Popup"
            Popup.AutomaticSize = Enum.AutomaticSize.XY
            Popup.Size = UDim2.fromScale(0, 0)
            Popup.BackgroundColor3 = Iris._config.PopupBgColor
            Popup.BackgroundTransparency = Iris._config.PopupBgTransparency
            Popup.BorderSizePixel = 0
            Popup.Text = ""
            Popup.AutoButtonColor = false

            widgets.applyInputBegan(Popup, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
                    return
                end
                if not thisWidget.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    dragPopup = thisWidget
                    mouseDragOffset = widgets.getMouseLocation() - Popup.AbsolutePosition + widgets.GuiOffset
                end
            end)

            local ModalBackground = Instance.new("ImageButton")
            ModalBackground.Name = "IrisModalBackground"
            ModalBackground.Size = UDim2.fromScale(1, 1)
            ModalBackground.BackgroundColor3 = Iris._config.ModalDimBgColor
            ModalBackground.BackgroundTransparency = Iris._config.ModalDimBgTransparency
            ModalBackground.BorderSizePixel = 0
            ModalBackground.Image = ""
            ModalBackground.Active = true
            ModalBackground.AutoButtonColor = false

            ModalBackground.Visible = false

            ModalBackground.Parent = Iris._rootWidget.Instance:FindFirstChild("PopupScreenGui")

            widgets.UIStroke(Popup, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)

            if Iris._config.PopupRounding > 0 then
                widgets.UICorner(Popup, Iris._config.PopupRounding)
            end

            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.XY
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.Parent = Popup

            widgets.UIPadding(ChildContainer, Iris._config.WindowPadding)
            widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y)).VerticalAlignment = Enum.VerticalAlignment.Top

            thisWidget.ChildContainer = ChildContainer
            thisWidget.Modal = ModalBackground
            return Popup
        end,
        GenerateState = function(thisWidget: Types.Popup)
            if thisWidget.state.isOpen == nil then
                thisWidget.state.isOpen = Iris._widgetState(thisWidget, "isOpen", false)
            end
        end,
        Update = function(thisWidget: Types.Popup)
            local _Popup = thisWidget.Instance :: Frame
        end,
        UpdateState = function(thisWidget: Types.Popup)
            if thisWidget.state.isOpen.value then
                thisWidget.Instance.Visible = true
                if thisWidget.arguments.Modal then
                    thisWidget.Modal.Visible = true
                end
            else
                thisWidget.Instance.Visible = false
                thisWidget.Modal.Visible = false
            end
        end,
        ChildAdded = function(thisWidget: Types.Popup, _thisChild: Types.Widget)
            return thisWidget.ChildContainer
        end,
        Discard = function(thisWidget: Types.Popup)
            popupWidgets[thisWidget.ID] = nil
            thisWidget.Modal:Destroy()
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    function Iris.OpenPopup(id: Types.ID)
        local thisWidget: Types.Popup? = popupWidgets[id]
        if thisWidget == nil then
            return
        end
        if thisWidget.state.isOpen.value == true then
            return
        end

        if thisWidget.arguments.Modal then
            local size = thisWidget.Instance.AbsoluteSize
            local usableSize = (thisWidget.Instance.Parent :: GuiBase2d).AbsoluteSize
            local centre = (usableSize - size) / 2
            thisWidget.Instance.Position = UDim2.fromOffset(centre.X, centre.Y)
        else
            local position = clampPositionToBounds(thisWidget, widgets.getMouseLocation())
            thisWidget.Instance.Position = UDim2.fromOffset(position.X, position.Y)
        end
        thisWidget.Instance.ZIndex = 2 * #popupStack + 2
        thisWidget.Modal.ZIndex = 2 * #popupStack + 1
        thisWidget.state.isOpen:set(true)
        anyPopupOpen = true
        activePopup = thisWidget
        table.insert(popupStack, thisWidget)
        updateModalBackgrounds()
    end

    function Iris.ClosePopup(id: Types.ID)
        local thisWidget: Types.Popup? = popupWidgets[id]
        if thisWidget == nil then
            return
        end
        if thisWidget.state.isOpen.value == false then
            return
        end

        local index = table.find(popupStack, thisWidget)
        emptyPopupStack(index and index - 1 or 1)
        updateModalBackgrounds()
    end
end
