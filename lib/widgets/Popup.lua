local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    --stylua: ignore
    Iris.WidgetConstructor("Popup", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Modal"] = 1,
            ["NoMove"] = 2,
        },
        Events = {},
        Generate = function(thisWidget: Types.Popup)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent

            local Popup = Instance.new("Frame")
            Popup.Name = "Iris_Popup"
            Popup.Size = UDim2.fromScale(0, 0)
            Popup.AutomaticSize = Enum.AutomaticSize.XY
            Popup.BackgroundTransparency = Iris._config.PopupBgColor
            Popup.BackgroundTransparency = Iris._config.PopupBgTransparency
            Popup.BorderSizePixel = 0
            Popup.ZIndex = 1

            local ModalBackground = Instance.new("Frame")
            ModalBackground.Name = "Iris_ModalBackground"
            ModalBackground.Size = UDim2.fromScale(1, 1)
            ModalBackground.BackgroundColor3 = Iris._config.ModalDimBgColor
            ModalBackground.BackgroundTransparency = Iris._config.ModalDimBgTransparency
            ModalBackground.BorderSizePixel = 0
            ModalBackground.ZIndex = 1

            ModalBackground.Visible = false

            widgets.UIPadding(Popup, Iris._config.WindowPadding)
            widgets.UIStroke(Popup, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)

            if Iris._config.PopupRounding > 0 then
                widgets.UICorner(Popup, Iris._config.PopupRounding)
            end

            thisWidget._modal = ModalBackground
            return Popup
        end,
        GenerateState = function(thisWidget: Types.Popup)
            if thisWidget.state.anchor == nil then
                thisWidget.state.anchor = Iris._widgetState(thisWidget, "anchor", Vector2.zero)
            end
            if thisWidget.state.isOpen == nil then
                thisWidget.state.isOpen = Iris._widgetState(thisWidget, "isOpen", false)
            end
        end,
        Update = function(thisWidget: Types.Popup)
            local Popup = thisWidget.Instance :: Frame

        end,
        UpdateState = function(thisWidget: Types.Popup)
            thisWidget.Instance.AnchorPoint = thisWidget.state.anchor.value

            if thisWidget.state.isOpen.value then
                thisWidget.Instance.Visible = true
                if thisWidget.arguments.Modal then
                    thisWidget._modal.Visible = true
                end
            else
                thisWidget.Instance.Visible = false
                thisWidget._modal.Visible = false
            end
        end,
        Discard = function(thisWidget: Types.Popup)
            thisWidget._modal:Destroy()
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)
end
