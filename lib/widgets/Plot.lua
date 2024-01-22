local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgest: Types.WidgetUtility)
    Iris.WidgetConstructor(
        "ProgressBar",
        {
            hasState = true,
            hasChildren = false,
            Args = {
                ["Text"] = 1,
                ["Format"] = 2,
            },
            Events = {},
            Generate = function(thisWidget: Types.Widget)
                local ProgressBar: Frame = Instance.new("Frame")
                ProgressBar.Name = "Iris_ProgressBar"
                ProgressBar.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
                ProgressBar.AutomaticSize = Enum.AutomaticSize.Y
                ProgressBar.BackgroundTransparency = 1
                ProgressBar.BorderSizePixel = 0
                ProgressBar.ZIndex = thisWidget.ZIndex
                ProgressBar.LayoutOrder = thisWidget.ZIndex
                ProgressBar.ClipsDescendants = true

                local Progress: Frame = Instance.new("Frame")
                Progress.Name = "Bar"
                Progress.Size = UDim2.fromScale(0, 1)
                Progress.BackgroundColor3 = Iris._config.PlotHistogramColor
                Progress.BackgroundTransparency = Iris._config.PlotHistogramTransparency
                Progress.ZIndex = thisWidget.ZIndex + 1
                Progress.LayoutOrder = thisWidget.ZIndex + 1

                return ProgressBar
            end,
            GenerateState = function(thisWidget: Types.Widget)
                if thisWidget.state.progress == nil then
                    thisWidget.state.progress = Iris._widgetState(thisWidget, "progress", 0)
                end
            end,
            Update = function(thisWidget: Types.Widget) end,
            UpdateState = function(thisWidget: Types.Widget) end,
            Discard = function(thisWidget: Types.Widget)
                thisWidget.Instance:Destroy()
                widgest.discardState(thisWidget)
            end,
        } :: Types.WidgetClass
    )
end
