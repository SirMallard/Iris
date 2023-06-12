return function(Iris, widgets)
    local NumNonWindowChildren = 0
    Iris.WidgetConstructor("Root", {
        hasState = false,
        hasChildren = true,
        Args = {

        },
        Events = {
        
        },
        Generate = function(thisWidget)
            local Root = Instance.new("Folder")
            Root.Name = "Iris_Root"

            local PseudoWindowScreenGui
            if Iris._config.UseScreenGUIs then
                PseudoWindowScreenGui = Instance.new("ScreenGui")
                PseudoWindowScreenGui.ResetOnSpawn = false
                PseudoWindowScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset
            else
                PseudoWindowScreenGui = Instance.new("Folder")
            end
            PseudoWindowScreenGui.Name = "PseudoWindowScreenGui"
            PseudoWindowScreenGui.Parent = Root

            local PopupScreenGui
            if Iris._config.UseScreenGUIs then
                PopupScreenGui = Instance.new("ScreenGui")
                PopupScreenGui.ResetOnSpawn = false
                PopupScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset + 1024 -- room for 1024 regular windows before overlap

                local TooltipContainer = Instance.new("Frame")
                TooltipContainer.Name = "TooltipContainer"
                TooltipContainer.AutomaticSize = Enum.AutomaticSize.XY
                TooltipContainer.Size = UDim2.fromOffset(0, 0)
                TooltipContainer.BackgroundTransparency = 1
                TooltipContainer.BorderSizePixel = 0

                widgets.UIListLayout(TooltipContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.FrameBorderSize))

                TooltipContainer.Parent = PopupScreenGui
            else
                PopupScreenGui = Instance.new("Folder")
            end
            PopupScreenGui.Name = "PopupScreenGui"
            PopupScreenGui.Parent = Root
            
            local PseudoWindow = Instance.new("Frame")
            PseudoWindow.Name = "PseudoWindow"
            PseudoWindow.Size = UDim2.new(0, 0, 0, 0)
            PseudoWindow.Position = UDim2.fromOffset(0, 22)
            PseudoWindow.BorderSizePixel = Iris._config.WindowBorderSize
            PseudoWindow.BorderColor3 = Iris._config.BorderColor
            PseudoWindow.BackgroundTransparency = Iris._config.WindowBgTransparency
            PseudoWindow.BackgroundColor3 = Iris._config.WindowBgColor
            PseudoWindow.AutomaticSize = Enum.AutomaticSize.XY

            PseudoWindow.Selectable = false
            PseudoWindow.SelectionGroup = true
            PseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

            PseudoWindow.Visible = false
            widgets.UIPadding(PseudoWindow, Iris._config.WindowPadding)

            widgets.UIListLayout(PseudoWindow, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            PseudoWindow.Parent = PseudoWindowScreenGui
            
            return Root
        end,
        Update = function(thisWidget)
            if NumNonWindowChildren > 0 then
                thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true
            end
        end,
        Discard = function(thisWidget)
            NumNonWindowChildren = 0
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget, childWidget)
            if childWidget.type == "Window" then
                return thisWidget.Instance
            elseif childWidget.type == "Tooltip" then
                return thisWidget.Instance.PopupScreenGui.TooltipContainer
            else
                NumNonWindowChildren += 1
                thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true

                return thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow
            end
        end,
        ChildDiscarded = function(thisWidget, childWidget)
            if childWidget.type ~= "Window" then
                NumNonWindowChildren -= 1
                if NumNonWindowChildren == 0 then
                    thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = false
                end
            end
        end
    })
end