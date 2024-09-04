local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    Iris.WidgetConstructor(
        "ProgressBar",
        {
            hasState = true,
            hasChildren = false,
            Args = {
                ["Text"] = 1,
                ["Format"] = 2,
            },
            Events = {
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
                ["changed"] = {
                    ["Init"] = function(_thisWidget: Types.ProgressBar) end,
                    ["Get"] = function(thisWidget: Types.ProgressBar)
                        return thisWidget.lastChangedTick == Iris._cycleTick
                    end,
                },
            },
            Generate = function(thisWidget: Types.ProgressBar)
                local ProgressBar: Frame = Instance.new("Frame")
                ProgressBar.Name = "Iris_ProgressBar"
                ProgressBar.Size = UDim2.new(Iris._config.ItemWidth, UDim.new())
                ProgressBar.BackgroundTransparency = 1
                ProgressBar.AutomaticSize = Enum.AutomaticSize.Y
                ProgressBar.LayoutOrder = thisWidget.ZIndex

                local UIListLayout: UIListLayout = widgets.UIListLayout(ProgressBar, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                local Bar: Frame = Instance.new("Frame")
                Bar.Name = "Bar"
                Bar.Size = UDim2.new(Iris._config.ContentWidth, Iris._config.ContentHeight)
                Bar.BackgroundColor3 = Iris._config.FrameBgColor
                Bar.BackgroundTransparency = Iris._config.FrameBgTransparency
                Bar.BorderSizePixel = 0
                Bar.AutomaticSize = Enum.AutomaticSize.Y
                Bar.ClipsDescendants = true

                widgets.applyFrameStyle(Bar, true)

                Bar.Parent = ProgressBar

                local Progress: TextLabel = Instance.new("TextLabel")
                Progress.Name = "Progress"
                Progress.AutomaticSize = Enum.AutomaticSize.Y
                Progress.Size = UDim2.new(UDim.new(0, 0), Iris._config.ContentHeight)
                Progress.BackgroundColor3 = Iris._config.PlotHistogramColor
                Progress.BackgroundTransparency = Iris._config.PlotHistogramTransparency
                Progress.BorderSizePixel = 0

                widgets.applyTextStyle(Progress)
                widgets.UIPadding(Progress, Iris._config.FramePadding)
                widgets.UICorner(Progress, Iris._config.FrameRounding)

                Progress.Text = ""
                Progress.Parent = Bar

                local Value: TextLabel = Instance.new("TextLabel")
                Value.Name = "Value"
                Value.AutomaticSize = Enum.AutomaticSize.XY
                Value.Size = UDim2.new(UDim.new(0, 0), Iris._config.ContentHeight)
                Value.BackgroundTransparency = 1
                Value.BorderSizePixel = 0
                Value.ZIndex = 1

                widgets.applyTextStyle(Value)
                widgets.UIPadding(Value, Iris._config.FramePadding)

                Value.Parent = Bar

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.AnchorPoint = Vector2.new(0, 0.5)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.LayoutOrder = 1

                widgets.applyTextStyle(TextLabel)
                widgets.UIPadding(Value, Iris._config.FramePadding)

                TextLabel.Parent = ProgressBar

                return ProgressBar
            end,
            GenerateState = function(thisWidget: Types.ProgressBar)
                if thisWidget.state.progress == nil then
                    thisWidget.state.progress = Iris._widgetState(thisWidget, "Progress", 0)
                end
            end,
            Update = function(thisWidget: Types.ProgressBar)
                local Progress = thisWidget.Instance :: Frame
                local TextLabel: TextLabel = Progress.TextLabel
                local Bar = Progress.Bar :: Frame
                local Value: TextLabel = Bar.Value

                if thisWidget.arguments.Format ~= nil and typeof(thisWidget.arguments.Format) == "string" then
                    Value.Text = thisWidget.arguments.Format
                end

                TextLabel.Text = thisWidget.arguments.Text or "Progress Bar"
            end,
            UpdateState = function(thisWidget: Types.ProgressBar)
                local ProgressBar = thisWidget.Instance :: Frame
                local Bar = ProgressBar.Bar :: Frame
                local Progress: TextLabel = Bar.Progress
                local Value: TextLabel = Bar.Value

                local progress: number = thisWidget.state.progress.value
                progress = math.clamp(progress, 0, 1)
                local totalWidth: number = Bar.AbsoluteSize.X
                local textWidth: number = Value.AbsoluteSize.X
                if totalWidth * (1 - progress) < textWidth then
                    Value.AnchorPoint = Vector2.xAxis
                    Value.Position = UDim2.fromScale(1, 0)
                else
                    Value.AnchorPoint = Vector2.zero
                    Value.Position = UDim2.new(progress, 0, 0, 0)
                end

                Progress.Size = UDim2.new(UDim.new(progress, 0), Progress.Size.Height)
                if thisWidget.arguments.Format ~= nil and typeof(thisWidget.arguments.Format) == "string" then
                    Value.Text = thisWidget.arguments.Format
                else
                    Value.Text = string.format("%d%%", progress * 100)
                end
                thisWidget.lastChangedTick = Iris._cycleTick + 1
            end,
            Discard = function(thisWidget: Types.ProgressBar)
                thisWidget.Instance:Destroy()
                widgets.discardState(thisWidget)
            end,
        } :: Types.WidgetClass
    )

    Iris.WidgetConstructor(
        "PlotLines",
        {
            hasState = true,
            hasChildren = false,
            Args = {
                ["Text"] = 1,
                ["Min"] = 2,
                ["Max"] = 3,
                ["Height"] = 4,
            },
            Events = {},
            Generate = function(thisWidget: Types.Widget)
                local PlotLines: Frame = Instance.new("Frame")
                PlotLines.Name = "Iris_PlotLines"
                PlotLines.AutomaticSize = Enum.AutomaticSize.Y
                PlotLines.Size = UDim2.fromScale(1, 0)
                PlotLines.BackgroundTransparency = 1
                PlotLines.BorderSizePixel = 0
                PlotLines.ZIndex = thisWidget.ZIndex
                PlotLines.LayoutOrder = thisWidget.ZIndex

                local UIListLayout: UIListLayout = widgets.UIListLayout(PlotLines, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                local Background: Frame = Instance.new("Frame")
                Background.Name = "Background"
                Background.AutomaticSize = Enum.AutomaticSize.Y
                Background.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
                Background.BackgroundColor3 = Iris._config.FrameBgColor
                Background.BackgroundTransparency = Iris._config.FrameBgTransparency
                Background.ZIndex = thisWidget.ZIndex + 1
                Background.LayoutOrder = thisWidget.ZIndex + 1
                widgets.applyFrameStyle(Background)

                Background.Parent = PlotLines

                local Plot: ImageLabel = Instance.new("ImageLabel")
                Plot.Name = "Plot"
                Plot.Size = UDim2.fromScale(1, 1)
                Plot.BackgroundTransparency = 1
                Plot.BorderSizePixel = 0
                Plot.ZIndex = thisWidget.ZIndex + 2
                Plot.LayoutOrder = thisWidget.ZIndex + 2

                Plot.Parent = Background

                local Canvas: EditableImage = Instance.new("EditableImage")
                Canvas.Name = "Canvas"

                Canvas.Parent = Plot

                local TextLabel: TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.ZIndex = thisWidget.ZIndex + 3
                TextLabel.LayoutOrder = thisWidget.ZIndex + 3

                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = PlotLines

                return PlotLines
            end,
            GenerateState = function(thisWidget: Types.Widget)
                if thisWidget.state.values == nil then
                    thisWidget.state.progress = Iris._widgetState(thisWidget, "Values", { 0 })
                end
            end,
            Update = function(thisWidget: Types.Widget)
                local PlotLines = thisWidget.Instance :: Frame
                local TextLabel: TextLabel = PlotLines.TextLabel
                local Background: Frame = PlotLines.Background

                TextLabel.Text = thisWidget.arguments.Text or "Plot Lines"
                Background.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, thisWidget.arguments.Height or 0))
            end,
            UpdateState = function(thisWidget: Types.Widget)
                local PlotLines = thisWidget.Instance :: Frame
                local Background = PlotLines.Background :: Frame
                local Plot = Background.Plot :: ImageLabel
                local Canvas: EditableImage = Plot.Canvas

                local SizeRatio: number = Background.AbsoluteSize.Y / Background.AbsoluteSize.X
                local Width: number = math.min(Background.AbsoluteSize.X, 512)
                local Height: number = math.floor(Width * SizeRatio)

                Canvas:Resize(Vector2.one)
                Canvas.Size = Vector2.new(Width, Height)

                local values: { number } = thisWidget.state.values.value

                local min = thisWidget.arguments.Min :: number
                local max = thisWidget.arguments.Max :: number
                if min == nil or max == nil then
                    for Value: number in values do
                        min = math.min(min, Value)
                        max = math.max(max, Value)
                    end
                    min = thisWidget.arguments.Min or min
                    max = thisWidget.arguments.Max or max
                end
                local Range: number = max - min
                local ScaleFactor: number = (Height - 1) / Range
                local Distance: number = (Width - 1) / (#values - 1)

                local scaledValues: { Vector2 } = table.create(#values, nil)
                for index = 1, #values do
                    local point: number = values[index]
                    point -= min
                    point *= ScaleFactor
                    point = Height - point
                    scaledValues[index] = Vector2.new(math.floor((index - 1) * Distance), math.floor(point))
                end

                for index = 1, #values - 1 do
                    Canvas:DrawLine(scaledValues[index], scaledValues[index + 1], Iris._config.PlotHistogramColor, Iris._config.PlotHistogramTransparency)
                end
            end,
            Discard = function(thisWidget: Types.Widget)
                thisWidget.Instance:Destroy()
                widgets.discardState(thisWidget)
            end,
        } :: Types.WidgetClass
    )
end
