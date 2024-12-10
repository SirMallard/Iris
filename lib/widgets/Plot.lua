local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    -- stylua: ignore
    Iris.WidgetConstructor("ProgressBar", {
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
    } :: Types.WidgetClass)

    local function createLine(parent: Frame, index: number): Frame
        local Block: Frame = Instance.new("Frame")
        Block.Name = tostring(index)
        Block.AnchorPoint = Vector2.new(0.5, 0.5)
        Block.BackgroundColor3 = Iris._config.PlotLinesColor
        Block.BackgroundTransparency = Iris._config.PlotLinesTransparency
        Block.BorderSizePixel = 0

        Block.Parent = parent

        return Block
    end

    local function clearLine(thisWidget: Types.PlotLines)
        if thisWidget.HoveredLine then
            thisWidget.HoveredLine.BackgroundColor3 = Iris._config.PlotLinesColor
            thisWidget.HoveredLine.BackgroundTransparency = Iris._config.PlotLinesTransparency
            thisWidget.HoveredLine = false
            thisWidget.state.hovered:set(nil)
        end
    end

    local function updateLine(thisWidget: Types.PlotLines)
        local PlotLines = thisWidget.Instance :: Frame
        local Background = PlotLines.Background :: Frame
        local Plot = Background.Plot :: Frame

        local mousePosition: Vector2 = widgets.getMouseLocation()

        local position: Vector2 = Plot.AbsolutePosition - widgets.GuiOffset
        local scale: number = (mousePosition.X - position.X) / Plot.AbsoluteSize.X
        local index: number = math.ceil(scale * #thisWidget.Lines)
        local line: Frame? = thisWidget.Lines[index]

        if line then
            if line ~= thisWidget.HoveredLine then
                clearLine(thisWidget)
            end
            local start: number? = thisWidget.state.values.value[index]
            local stop: number? = thisWidget.state.values.value[index + 1]
            if start and stop then
                if math.floor(start) == start and math.floor(stop) == stop then
                    thisWidget.Tooltip.Text = ("%d: %d\n%d: %d"):format(index, start, index + 1, stop)
                else
                    thisWidget.Tooltip.Text = ("%d: %.3f\n%d: %.3f"):format(index, start, index + 1, stop)
                end
            end
            thisWidget.HoveredLine = line
            line.BackgroundColor3 = Iris._config.PlotLinesHoveredColor
            line.BackgroundTransparency = Iris._config.PlotLinesHoveredTransparency
            thisWidget.state.hovered:set({ start, stop })
        end
    end

    -- stylua: ignore
    Iris.WidgetConstructor("PlotLines", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Height"] = 2,
            ["Min"] = 3,
            ["Max"] = 4,
            ["TextOverlay"] = 5,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.PlotLines)
            local PlotLines: Frame = Instance.new("Frame")
            PlotLines.Name = "Iris_PlotLines"
            PlotLines.Size = UDim2.fromScale(1, 0)
            PlotLines.BackgroundTransparency = 1
            PlotLines.BorderSizePixel = 0
            PlotLines.ZIndex = thisWidget.ZIndex
            PlotLines.LayoutOrder = thisWidget.ZIndex

            local UIListLayout: UIListLayout = widgets.UIListLayout(PlotLines, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local Background: Frame = Instance.new("Frame")
            Background.Name = "Background"
            Background.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(1, 0))
            Background.BackgroundColor3 = Iris._config.FrameBgColor
            Background.BackgroundTransparency = Iris._config.FrameBgTransparency
            widgets.applyFrameStyle(Background)

            Background.Parent = PlotLines

            local Plot: Frame = Instance.new("Frame")
            Plot.Name = "Plot"
            Plot.Size = UDim2.fromScale(1, 1)
            Plot.BackgroundTransparency = 1
            Plot.BorderSizePixel = 0
            Plot.ClipsDescendants = true

            Plot:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                thisWidget.state.values.lastChangeTick = Iris._cycleTick
                Iris._widgets.PlotLines.UpdateState(thisWidget)
            end)

            local OverlayText: TextLabel = Instance.new("TextLabel")
            OverlayText.Name = "OverlayText"
            OverlayText.AutomaticSize = Enum.AutomaticSize.XY
            OverlayText.AnchorPoint = Vector2.new(0.5, 0)
            OverlayText.Size = UDim2.fromOffset(0, 0)
            OverlayText.Position = UDim2.fromScale(0.5, 0)
            OverlayText.BackgroundTransparency = 1
            OverlayText.BorderSizePixel = 0
            OverlayText.ZIndex = 2
            
            widgets.applyTextStyle(OverlayText)

            OverlayText.Parent = Plot

            local Tooltip: TextLabel = Instance.new("TextLabel")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.AutomaticSize = Enum.AutomaticSize.XY
            Tooltip.Size = UDim2.fromOffset(0, 0)
            Tooltip.BackgroundColor3 = Iris._config.PopupBgColor
            Tooltip.BackgroundTransparency = Iris._config.PopupBgTransparency
            Tooltip.BorderSizePixel = 0
            Tooltip.Visible = false

            widgets.applyTextStyle(Tooltip)
            widgets.UIStroke(Tooltip, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
            widgets.UIPadding(Tooltip, Iris._config.WindowPadding)
            if Iris._config.PopupRounding > 0 then
                widgets.UICorner(Tooltip, Iris._config.PopupRounding)
            end

            local popup: Instance? = Iris._rootInstance and Iris._rootInstance:FindFirstChild("PopupScreenGui")
            Tooltip.Parent = popup and popup:FindFirstChild("TooltipContainer")

            thisWidget.Tooltip = Tooltip

            widgets.applyMouseMoved(Plot, function()
                updateLine(thisWidget)
            end)

            widgets.applyMouseLeave(Plot, function()
                clearLine(thisWidget)
            end)

            Plot.Parent = Background

            thisWidget.Lines = {}
            thisWidget.HoveredLine = false

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
        GenerateState = function(thisWidget: Types.PlotLines)
            if thisWidget.state.values == nil then
                thisWidget.state.values = Iris._widgetState(thisWidget, "values", { 0, 1 })
            end
            if thisWidget.state.hovered == nil then
                thisWidget.state.hovered = Iris._widgetState(thisWidget, "hovered", nil)
            end
        end,
        Update = function(thisWidget: Types.PlotLines)
            local PlotLines = thisWidget.Instance :: Frame
            local TextLabel: TextLabel = PlotLines.TextLabel
            local Background = PlotLines.Background :: Frame
            local Plot = Background.Plot :: Frame
            local OverlayText: TextLabel = Plot.OverlayText

            TextLabel.Text = thisWidget.arguments.Text or "Plot Lines"
            OverlayText.Text = thisWidget.arguments.TextOverlay or ""
            PlotLines.Size = UDim2.new(1, 0, 0, thisWidget.arguments.Height or 0)
        end,
        UpdateState = function(thisWidget: Types.PlotLines)
            if thisWidget.state.hovered.lastChangeTick == Iris._cycleTick then
                if thisWidget.state.hovered.value then
                    thisWidget.Tooltip.Visible = true
                else
                    thisWidget.Tooltip.Visible = false
                end
            end

            if thisWidget.state.values.lastChangeTick == Iris._cycleTick then
                local PlotLines = thisWidget.Instance :: Frame
                local Background = PlotLines.Background :: Frame
                local Plot = Background.Plot :: Frame

                local values: { number } = thisWidget.state.values.value
                local count: number = #values - 1
                local numLines: number = #thisWidget.Lines

                local min: number = thisWidget.arguments.Min
                local max: number = thisWidget.arguments.Max

                if min == nil or max == nil then
                    for _, value: number in values do
                        min = math.min(min or value, value)
                        max = math.max(max or value, value)
                    end
                end

                -- add or remove blocks depending on how many are needed
                if numLines < count then
                    for index = numLines + 1, count do
                        table.insert(thisWidget.Lines, createLine(Plot, index))
                    end
                elseif numLines > count then
                    for _ = count + 1, numLines do
                        local line: Frame? = table.remove(thisWidget.Lines)
                        if line then
                            line:Destroy()
                        end
                    end
                end

                local range: number = max - min
                local size: Vector2 = Plot.AbsoluteSize
                
                for index = 1, count do
                    local start: number = values[index]
                    local stop: number = values[index + 1]
                    local a: Vector2 = size * Vector2.new((index - 1) / count, (max - start) / range)
                    local b: Vector2 = size * Vector2.new(index / count, (max - stop) / range)
                    local position: Vector2 = (a + b) / 2

                    thisWidget.Lines[index].Size = UDim2.fromOffset((b - a).Magnitude + 1, 1)
                    thisWidget.Lines[index].Position = UDim2.fromOffset(position.X, position.Y)
                    thisWidget.Lines[index].Rotation = math.atan2(b.Y - a.Y, b.X - a.X) * (180 / math.pi)
                end

                -- only update the hovered block if it exists.
                -- if thisWidget.HoveredLine then
                --     updateLine(thisWidget)
                -- end
            end
        end,
        Discard = function(thisWidget: Types.PlotLines)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
    } :: Types.WidgetClass)

    local function createBlock(parent: Frame, index: number): Frame
        local Block: Frame = Instance.new("Frame")
        Block.Name = tostring(index)
        Block.BackgroundColor3 = Iris._config.PlotHistogramColor
        Block.BackgroundTransparency = Iris._config.PlotHistogramTransparency
        Block.BorderSizePixel = 0

        Block.Parent = parent

        return Block
    end

    local function clearBlock(thisWidget: Types.PlotHistogram)
        if thisWidget.HoveredBlock then
            thisWidget.HoveredBlock.BackgroundColor3 = Iris._config.PlotHistogramColor
            thisWidget.HoveredBlock.BackgroundTransparency = Iris._config.PlotHistogramTransparency
            thisWidget.HoveredBlock = false
            thisWidget.state.hovered:set(nil)
        end
    end

    local function updateBlock(thisWidget: Types.PlotHistogram)
        local PlotHistogram = thisWidget.Instance :: Frame
        local Background = PlotHistogram.Background :: Frame
        local Plot = Background.Plot :: Frame

        local mousePosition: Vector2 = widgets.getMouseLocation()

        local position: Vector2 = Plot.AbsolutePosition - widgets.GuiOffset
        local scale: number = (mousePosition.X - position.X) / Plot.AbsoluteSize.X
        local index: number = math.ceil(scale * #thisWidget.Blocks)
        local block: Frame? = thisWidget.Blocks[index]

        if block then
            if block ~= thisWidget.HoveredBlock then
                clearBlock(thisWidget)
            end
            local value: number? = thisWidget.state.values.value[index]
            if value then
                thisWidget.Tooltip.Text = if math.floor(value) == value then ("%d: %d"):format(index, value) else ("%d: %.3f"):format(index, value)
            end
            thisWidget.HoveredBlock = block
            block.BackgroundColor3 = Iris._config.PlotHistogramHoveredColor
            block.BackgroundTransparency = Iris._config.PlotHistogramHoveredTransparency
            thisWidget.state.hovered:set(value)
        end
    end

    -- stylua: ignore
    Iris.WidgetConstructor("PlotHistogram", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Height"] = 2,
            ["Min"] = 3,
            ["Max"] = 4,
            ["TextOverlay"] = 5,
            ["BaseLine"] = 6,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.PlotHistogram)
            local PlotHistogram: Frame = Instance.new("Frame")
            PlotHistogram.Name = "Iris_PlotHistogram"
            PlotHistogram.Size = UDim2.fromScale(1, 0)
            PlotHistogram.BackgroundTransparency = 1
            PlotHistogram.BorderSizePixel = 0
            PlotHistogram.ZIndex = thisWidget.ZIndex
            PlotHistogram.LayoutOrder = thisWidget.ZIndex

            local UIListLayout: UIListLayout = widgets.UIListLayout(PlotHistogram, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local Background: Frame = Instance.new("Frame")
            Background.Name = "Background"
            Background.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(1, 0))
            Background.BackgroundColor3 = Iris._config.FrameBgColor
            Background.BackgroundTransparency = Iris._config.FrameBgTransparency
            widgets.applyFrameStyle(Background)
            
            local UIPadding: UIPadding = (Background :: any).UIPadding
            UIPadding.PaddingRight = UDim.new(0, Iris._config.FramePadding.X - 1)

            Background.Parent = PlotHistogram

            local Plot: Frame = Instance.new("Frame")
            Plot.Name = "Plot"
            Plot.Size = UDim2.fromScale(1, 1)
            Plot.BackgroundTransparency = 1
            Plot.BorderSizePixel = 0
            Plot.ClipsDescendants = true

            local OverlayText: TextLabel = Instance.new("TextLabel")
            OverlayText.Name = "OverlayText"
            OverlayText.AutomaticSize = Enum.AutomaticSize.XY
            OverlayText.AnchorPoint = Vector2.new(0.5, 0)
            OverlayText.Size = UDim2.fromOffset(0, 0)
            OverlayText.Position = UDim2.fromScale(0.5, 0)
            OverlayText.BackgroundTransparency = 1
            OverlayText.BorderSizePixel = 0
            OverlayText.ZIndex = 2
            
            widgets.applyTextStyle(OverlayText)

            OverlayText.Parent = Plot

            local Tooltip: TextLabel = Instance.new("TextLabel")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.AutomaticSize = Enum.AutomaticSize.XY
            Tooltip.Size = UDim2.fromOffset(0, 0)
            Tooltip.BackgroundColor3 = Iris._config.PopupBgColor
            Tooltip.BackgroundTransparency = Iris._config.PopupBgTransparency
            Tooltip.BorderSizePixel = 0
            Tooltip.Visible = false

            widgets.applyTextStyle(Tooltip)
            widgets.UIStroke(Tooltip, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
            widgets.UIPadding(Tooltip, Iris._config.WindowPadding)
            if Iris._config.PopupRounding > 0 then
                widgets.UICorner(Tooltip, Iris._config.PopupRounding)
            end

            local popup: Instance? = Iris._rootInstance and Iris._rootInstance:FindFirstChild("PopupScreenGui")
            Tooltip.Parent = popup and popup:FindFirstChild("TooltipContainer")

            thisWidget.Tooltip = Tooltip

            widgets.applyMouseMoved(Plot, function()
                updateBlock(thisWidget)
            end)

            widgets.applyMouseLeave(Plot, function()
                clearBlock(thisWidget)
            end)

            Plot.Parent = Background

            thisWidget.Blocks = {}
            thisWidget.HoveredBlock = false

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.Size = UDim2.fromOffset(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 3
            TextLabel.LayoutOrder = thisWidget.ZIndex + 3

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = PlotHistogram

            return PlotHistogram
        end,
        GenerateState = function(thisWidget: Types.PlotHistogram)
            if thisWidget.state.values == nil then
                thisWidget.state.values = Iris._widgetState(thisWidget, "values", { 1 })
            end     
            if thisWidget.state.hovered == nil then
                thisWidget.state.hovered = Iris._widgetState(thisWidget, "hovered", nil)
            end     
        end,
        Update = function(thisWidget: Types.PlotHistogram)
            local PlotLines = thisWidget.Instance :: Frame
            local TextLabel: TextLabel = PlotLines.TextLabel
            local Background = PlotLines.Background :: Frame
            local Plot = Background.Plot :: Frame
            local OverlayText: TextLabel = Plot.OverlayText

            TextLabel.Text = thisWidget.arguments.Text or "Plot Histogram"
            OverlayText.Text = thisWidget.arguments.TextOverlay or ""
            PlotLines.Size = UDim2.new(1, 0, 0, thisWidget.arguments.Height or 0)
        end,
        UpdateState = function(thisWidget: Types.PlotHistogram)
            if thisWidget.state.hovered.lastChangeTick == Iris._cycleTick then
                if thisWidget.state.hovered.value then
                    thisWidget.Tooltip.Visible = true
                else
                    thisWidget.Tooltip.Visible = false
                end
            end

            if thisWidget.state.values.lastChangeTick == Iris._cycleTick then
                local PlotHistogram = thisWidget.Instance :: Frame
                local Background = PlotHistogram.Background :: Frame
                local Plot = Background.Plot :: Frame

                local values: { number } = thisWidget.state.values.value
                local count: number = #values
                local numBlocks: number = #thisWidget.Blocks

                local min: number = thisWidget.arguments.Min
                local max: number = thisWidget.arguments.Max
                local baseline: number = thisWidget.arguments.BaseLine or 0

                if min == nil or max == nil then
                    for _, value: number in values do
                        min = math.min(min or value, value)
                        max = math.max(max or value, value)
                    end
                end

                -- add or remove blocks depending on how many are needed
                if numBlocks < count then
                    for index = numBlocks + 1, count do
                        table.insert(thisWidget.Blocks, createBlock(Plot, index))                    
                    end
                elseif numBlocks > count then
                    for _ = count + 1, numBlocks do
                        local block: Frame? = table.remove(thisWidget.Blocks)
                        if block then
                            block:Destroy()
                        end
                    end
                end
                
                local range: number = max - min
                local width: UDim = UDim.new(1 / count, -1)
                for index = 1, count do
                    local num: number = values[index]
                    if num >= 0 then
                        thisWidget.Blocks[index].Size = UDim2.new(width, UDim.new((num - baseline) / range))
                        thisWidget.Blocks[index].Position = UDim2.fromScale((index - 1) / count, (max - num) / range)
                    else
                        thisWidget.Blocks[index].Size = UDim2.new(width, UDim.new((baseline - num) / range))
                        thisWidget.Blocks[index].Position = UDim2.fromScale((index - 1) / count, (max - baseline) / range)
                    end
                end

                -- only update the hovered block if it exists.
                if thisWidget.HoveredBlock then
                    updateBlock(thisWidget)
                end
            end
        end,
        Discard = function(thisWidget: Types.PlotHistogram)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)            
        end,
    } :: Types.WidgetClass)
end
