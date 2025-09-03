local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

export type ProgressBar = Types.Widget & {
    arguments: {
        Text: string?,
        Format: string?,
    },

    state: {
        progress: Types.State<number>,
    },
} & Types.Changed & Types.Hovered

export type PlotLines = Types.Widget & {
    Lines: { Frame },
    HoveredLine: Frame | false,
    Tooltip: TextLabel,

    arguments: {
        Text: string,
        Height: number,
        Min: number,
        Max: number,
        TextOverlay: string,
    },

    state: {
        values: Types.State<{ number }>,
        hovered: Types.State<{ number }?>,
    },
} & Types.Hovered

export type PlotHistogram = Types.Widget & {
    Blocks: { Frame },
    HoveredBlock: Frame | false,
    Tooltip: TextLabel,

    arguments: {
        Text: string,
        Height: number,
        Min: number,
        Max: number,
        TextOverlay: string,
        BaseLine: number,
    },

    state: {
        values: Types.State<{ number }>,
        hovered: Types.State<number?>,
    },
} & Types.Hovered

-----------------
-- ProgressBar
-----------------

Internal._widgetConstructor(
    "ProgressBar",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 2,
        Arguments = { "Text", "Format", "progress" },
        Events = {
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
            ["changed"] = {
                ["Init"] = function(_thisWidget: ProgressBar) end,
                ["Get"] = function(thisWidget: ProgressBar)
                    return thisWidget._lastChangedTick == Internal._cycleTick
                end,
            },
        },
        Generate = function(_thisWidget: ProgressBar)
            local ProgressBar = Instance.new("Frame")
            ProgressBar.Name = "Iris_ProgressBar"
            ProgressBar.AutomaticSize = Enum.AutomaticSize.Y
            ProgressBar.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            ProgressBar.BackgroundTransparency = 1

            Utility.UIListLayout(ProgressBar, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local Bar = Instance.new("Frame")
            Bar.Name = "Bar"
            Bar.AutomaticSize = Enum.AutomaticSize.Y
            Bar.Size = UDim2.new(Internal._config.ContentWidth, Internal._config.ContentHeight)
            Bar.BackgroundColor3 = Internal._config.FrameBgColor
            Bar.BackgroundTransparency = Internal._config.FrameBgTransparency
            Bar.BorderSizePixel = 0
            Bar.ClipsDescendants = true

            Utility.applyFrameStyle(Bar, true)

            Bar.Parent = ProgressBar

            local Progress = Instance.new("TextLabel")
            Progress.Name = "Progress"
            Progress.AutomaticSize = Enum.AutomaticSize.Y
            Progress.Size = UDim2.new(UDim.new(0, 0), Internal._config.ContentHeight)
            Progress.BackgroundColor3 = Internal._config.PlotHistogramColor
            Progress.BackgroundTransparency = Internal._config.PlotHistogramTransparency
            Progress.BorderSizePixel = 0

            Utility.applyTextStyle(Progress)
            Utility.UIPadding(Progress, Internal._config.FramePadding)
            Utility.UICorner(Progress, Internal._config.FrameRounding)

            Progress.Text = ""
            Progress.Parent = Bar

            local Value = Instance.new("TextLabel")
            Value.Name = "Value"
            Value.AutomaticSize = Enum.AutomaticSize.XY
            Value.Size = UDim2.new(UDim.new(0, 0), Internal._config.ContentHeight)
            Value.BackgroundTransparency = 1
            Value.BorderSizePixel = 0
            Value.ZIndex = 1

            Utility.applyTextStyle(Value)
            Utility.UIPadding(Value, Internal._config.FramePadding)

            Value.Parent = Bar

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.LayoutOrder = 1

            Utility.applyTextStyle(TextLabel)
            Utility.UIPadding(Value, Internal._config.FramePadding)

            TextLabel.Parent = ProgressBar

            return ProgressBar
        end,
        GenerateState = function(thisWidget: ProgressBar)
            if thisWidget.state.progress == nil then
                thisWidget.state.progress = Internal._widgetState(thisWidget, "progress", 0)
            end
        end,
        Update = function(thisWidget: ProgressBar)
            local Progress = thisWidget.instance :: Frame
            local TextLabel: TextLabel = Progress.TextLabel
            local Bar = Progress.Bar :: Frame
            local Value: TextLabel = Bar._value

            if thisWidget.arguments.Format ~= nil and typeof(thisWidget.arguments.Format) == "string" then
                Value.Text = thisWidget.arguments.Format
            end

            TextLabel.Text = thisWidget.arguments.Text or "Progress Bar"
        end,
        UpdateState = function(thisWidget: ProgressBar)
            local ProgressBar = thisWidget.instance :: Frame
            local Bar = ProgressBar.Bar :: Frame
            local Progress: TextLabel = Bar.Progress
            local Value: TextLabel = Bar._value

            local progress = math.clamp(thisWidget.state.progress._value, 0, 1)
            local totalWidth = Bar.AbsoluteSize.X
            local textWidth = Value.AbsoluteSize.X
            if totalWidth * (1 - progress) < textWidth then
                Value.AnchorPoint = Vector2.xAxis
                Value.Position = UDim2.fromScale(1, 0)
            else
                Value.AnchorPoint = Vector2.zero
                Value.Position = UDim2.fromScale(progress, 0)
            end

            Progress.Size = UDim2.new(UDim.new(progress, 0), Progress.Size.Height)
            if thisWidget.arguments.Format ~= nil and typeof(thisWidget.arguments.Format) == "string" then
                Value.Text = thisWidget.arguments.Format
            else
                Value.Text = string.format("%d%%", progress * 100)
            end
            thisWidget._lastChangedTick = Internal._cycleTick + 1
        end,
        Discard = function(thisWidget: ProgressBar)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

local function createLine(parent: Frame, index: number)
    local Block = Instance.new("Frame")
    Block.Name = tostring(index)
    Block.AnchorPoint = Vector2.new(0.5, 0.5)
    Block.BackgroundColor3 = Internal._config.PlotLinesColor
    Block.BackgroundTransparency = Internal._config.PlotLinesTransparency
    Block.BorderSizePixel = 0

    Block.Parent = parent

    return Block
end

local function clearLine(thisWidget: PlotLines)
    if thisWidget.HoveredLine then
        thisWidget.HoveredLine.BackgroundColor3 = Internal._config.PlotLinesColor
        thisWidget.HoveredLine.BackgroundTransparency = Internal._config.PlotLinesTransparency
        thisWidget.HoveredLine = false
        thisWidget.state.hovered:set(nil)
    end
end

local function updateLine(thisWidget: PlotLines, silent: true?)
    local PlotLines = thisWidget.instance :: Frame
    local Background = PlotLines.Background :: Frame
    local Plot = Background.Plot :: Frame

    local mousePosition = Utility.getMouseLocation()

    local position = Plot.AbsolutePosition - Utility.guiOffset
    local scale = (mousePosition.X - position.X) / Plot.AbsoluteSize.X
    local index = math.ceil(scale * #thisWidget.Lines)
    local line: Frame? = thisWidget.Lines[index]

    if line then
        if line ~= thisWidget.HoveredLine and not silent then
            clearLine(thisWidget)
        end
        local start: number? = thisWidget.state.values._value[index]
        local stop: number? = thisWidget.state.values._value[index + 1]
        if start and stop then
            if math.floor(start) == start and math.floor(stop) == stop then
                thisWidget.Tooltip.Text = ("%d: %d\n%d: %d"):format(index, start, index + 1, stop)
            else
                thisWidget.Tooltip.Text = ("%d: %.3f\n%d: %.3f"):format(index, start, index + 1, stop)
            end
        end
        thisWidget.HoveredLine = line
        line.BackgroundColor3 = Internal._config.PlotLinesHoveredColor
        line.BackgroundTransparency = Internal._config.PlotLinesHoveredTransparency
        if silent then
            thisWidget.state.hovered._value = { start, stop }
        else
            thisWidget.state.hovered:set({ start, stop })
        end
    end
end

---------------
-- PlotLines
---------------

Internal._widgetConstructor(
    "PlotLines",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 5,
        Arguments = { "Text", "Height", "Min", "Max", "TextOverlay", "values", "hovered" },
        Events = {
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: PlotLines)
            local PlotLines = Instance.new("Frame")
            PlotLines.Name = "Iris_PlotLines"
            PlotLines.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            PlotLines.BackgroundTransparency = 1
            PlotLines.BorderSizePixel = 0

            Utility.UIListLayout(PlotLines, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local Background = Instance.new("Frame")
            Background.Name = "Background"
            Background.Size = UDim2.new(Internal._config.ContentWidth, UDim.new(1, 0))
            Background.BackgroundColor3 = Internal._config.FrameBgColor
            Background.BackgroundTransparency = Internal._config.FrameBgTransparency
            Utility.applyFrameStyle(Background)

            Background.Parent = PlotLines

            local Plot = Instance.new("Frame")
            Plot.Name = "Plot"
            Plot.Size = UDim2.fromScale(1, 1)
            Plot.BackgroundTransparency = 1
            Plot.BorderSizePixel = 0
            Plot.ClipsDescendants = true

            Plot:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                thisWidget.state.values._lastChangeTick = Internal._cycleTick

                -- todo
                Internal._widgets.PlotLines.UpdateState(thisWidget)
            end)

            local OverlayText = Instance.new("TextLabel")
            OverlayText.Name = "OverlayText"
            OverlayText.AutomaticSize = Enum.AutomaticSize.XY
            OverlayText.AnchorPoint = Vector2.new(0.5, 0)
            OverlayText.Size = UDim2.fromOffset(0, 0)
            OverlayText.Position = UDim2.fromScale(0.5, 0)
            OverlayText.BackgroundTransparency = 1
            OverlayText.BorderSizePixel = 0
            OverlayText.ZIndex = 2

            Utility.applyTextStyle(OverlayText)

            OverlayText.Parent = Plot

            local Tooltip = Instance.new("TextLabel")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.AutomaticSize = Enum.AutomaticSize.XY
            Tooltip.Size = UDim2.fromOffset(0, 0)
            Tooltip.BackgroundColor3 = Internal._config.PopupBgColor
            Tooltip.BackgroundTransparency = Internal._config.PopupBgTransparency
            Tooltip.BorderSizePixel = 0
            Tooltip.Visible = false

            Utility.applyTextStyle(Tooltip)
            Utility.UIStroke(Tooltip, Internal._config.PopupBorderSize, Internal._config.BorderActiveColor, Internal._config.BorderActiveTransparency)
            Utility.UIPadding(Tooltip, Internal._config.WindowPadding)
            if Internal._config.PopupRounding > 0 then
                Utility.UICorner(Tooltip, Internal._config.PopupRounding)
            end

            local popup = Internal._rootInstance and Internal._rootInstance:FindFirstChild("PopupScreenGui")
            Tooltip.Parent = popup and popup:FindFirstChild("TooltipContainer")

            thisWidget.Tooltip = Tooltip

            Utility.applyMouseMoved(Plot, function()
                updateLine(thisWidget)
            end)

            Utility.applyMouseLeave(Plot, function()
                clearLine(thisWidget)
            end)

            Plot.Parent = Background

            thisWidget.Lines = {}
            thisWidget.HoveredLine = false

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.Size = UDim2.fromOffset(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = 3
            TextLabel.LayoutOrder = 3

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = PlotLines

            return PlotLines
        end,
        GenerateState = function(thisWidget: PlotLines)
            if thisWidget.state.values == nil then
                thisWidget.state.values = Internal._widgetState(thisWidget, "values", { 0, 1 })
            end
            if thisWidget.state.hovered == nil then
                thisWidget.state.hovered = Internal._widgetState(thisWidget, "hovered", nil)
            end
        end,
        Update = function(thisWidget: PlotLines)
            local PlotLines = thisWidget.instance :: Frame
            local TextLabel: TextLabel = PlotLines.TextLabel
            local Background = PlotLines.Background :: Frame
            local Plot = Background.Plot :: Frame
            local OverlayText: TextLabel = Plot.OverlayText

            TextLabel.Text = thisWidget.arguments.Text or "Plot Lines"
            OverlayText.Text = thisWidget.arguments.TextOverlay or ""
            PlotLines.Size = UDim2.new(1, 0, 0, thisWidget.arguments.Height or 0)
        end,
        UpdateState = function(thisWidget: PlotLines)
            if thisWidget.state.hovered._lastChangeTick == Internal._cycleTick then
                if thisWidget.state.hovered._value then
                    thisWidget.Tooltip.Visible = true
                else
                    thisWidget.Tooltip.Visible = false
                end
            end

            if thisWidget.state.values._lastChangeTick == Internal._cycleTick then
                local PlotLines = thisWidget.instance :: Frame
                local Background = PlotLines.Background :: Frame
                local Plot = Background.Plot :: Frame

                local values = thisWidget.state.values._value
                local count = #values - 1
                local numLines = #thisWidget.Lines

                local min = thisWidget.arguments.Min or math.huge
                local max = thisWidget.arguments.Max or -math.huge

                if min == nil or max == nil then
                    for _, value in values do
                        min = math.min(min, value)
                        max = math.max(max, value)
                    end
                end

                -- add or remove blocks depending on how many are needed
                if numLines < count then
                    for index = numLines + 1, count do
                        table.insert(thisWidget.Lines, createLine(Plot, index))
                    end
                elseif numLines > count then
                    for _ = count + 1, numLines do
                        local line = table.remove(thisWidget.Lines)
                        if line then
                            line:Destroy()
                        end
                    end
                end

                local range = max - min
                local size = Plot.AbsoluteSize

                for index = 1, count do
                    local start = values[index]
                    local stop = values[index + 1]
                    local a = size * Vector2.new((index - 1) / count, (max - start) / range)
                    local b = size * Vector2.new(index / count, (max - stop) / range)
                    local position = (a + b) / 2

                    thisWidget.Lines[index].Size = UDim2.fromOffset((b - a).Magnitude + 1, 1)
                    thisWidget.Lines[index].Position = UDim2.fromOffset(position.X, position.Y)
                    thisWidget.Lines[index].Rotation = math.atan2(b.Y - a.Y, b.X - a.X) * (180 / math.pi)
                end

                -- only update the hovered block if it exists.
                if thisWidget.HoveredLine then
                    updateLine(thisWidget, true)
                end
            end
        end,
        Discard = function(thisWidget: PlotLines)
            thisWidget.instance:Destroy()
            thisWidget.Tooltip:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

local function createBlock(parent: Frame, index: number)
    local Block = Instance.new("Frame")
    Block.Name = tostring(index)
    Block.BackgroundColor3 = Internal._config.PlotHistogramColor
    Block.BackgroundTransparency = Internal._config.PlotHistogramTransparency
    Block.BorderSizePixel = 0

    Block.Parent = parent

    return Block
end

local function clearBlock(thisWidget: PlotHistogram)
    if thisWidget.HoveredBlock then
        thisWidget.HoveredBlock.BackgroundColor3 = Internal._config.PlotHistogramColor
        thisWidget.HoveredBlock.BackgroundTransparency = Internal._config.PlotHistogramTransparency
        thisWidget.HoveredBlock = false
        thisWidget.state.hovered:set(nil)
    end
end

local function updateBlock(thisWidget: PlotHistogram, silent: true?)
    local PlotHistogram = thisWidget.instance :: Frame
    local Background = PlotHistogram.Background :: Frame
    local Plot = Background.Plot :: Frame

    local mousePosition = Utility.getMouseLocation()

    local position = Plot.AbsolutePosition - Utility.guiOffset
    local scale = (mousePosition.X - position.X) / Plot.AbsoluteSize.X
    local index = math.ceil(scale * #thisWidget.Blocks)
    local block: Frame? = thisWidget.Blocks[index]

    if block then
        if block ~= thisWidget.HoveredBlock and not silent then
            clearBlock(thisWidget)
        end
        local value: number? = thisWidget.state.values._value[index]
        if value then
            thisWidget.Tooltip.Text = if math.floor(value) == value then ("%d: %d"):format(index, value) else ("%d: %.3f"):format(index, value)
        end
        thisWidget.HoveredBlock = block
        block.BackgroundColor3 = Internal._config.PlotHistogramHoveredColor
        block.BackgroundTransparency = Internal._config.PlotHistogramHoveredTransparency
        if silent then
            thisWidget.state.hovered._value = value
        else
            thisWidget.state.hovered:set(value)
        end
    end
end

-------------------
-- PlotHistogram
-------------------

Internal._widgetConstructor(
    "PlotHistogram",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 6,
        Arguments = { "Text", "Height", "Min", "Max", "TextOverlay", "BaseLine", "values", "hovered" },
        Events = {
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: PlotHistogram)
            local PlotHistogram = Instance.new("Frame")
            PlotHistogram.Name = "Iris_PlotHistogram"
            PlotHistogram.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            PlotHistogram.BackgroundTransparency = 1
            PlotHistogram.BorderSizePixel = 0

            Utility.UIListLayout(PlotHistogram, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local Background = Instance.new("Frame")
            Background.Name = "Background"
            Background.Size = UDim2.new(Internal._config.ContentWidth, UDim.new(1, 0))
            Background.BackgroundColor3 = Internal._config.FrameBgColor
            Background.BackgroundTransparency = Internal._config.FrameBgTransparency
            Utility.applyFrameStyle(Background)

            local UIPadding = (Background :: any).UIPadding
            UIPadding.PaddingRight = UDim.new(0, Internal._config.FramePadding.X - 1)

            Background.Parent = PlotHistogram

            local Plot = Instance.new("Frame")
            Plot.Name = "Plot"
            Plot.Size = UDim2.fromScale(1, 1)
            Plot.BackgroundTransparency = 1
            Plot.BorderSizePixel = 0
            Plot.ClipsDescendants = true

            local OverlayText = Instance.new("TextLabel")
            OverlayText.Name = "OverlayText"
            OverlayText.AutomaticSize = Enum.AutomaticSize.XY
            OverlayText.AnchorPoint = Vector2.new(0.5, 0)
            OverlayText.Size = UDim2.fromOffset(0, 0)
            OverlayText.Position = UDim2.fromScale(0.5, 0)
            OverlayText.BackgroundTransparency = 1
            OverlayText.BorderSizePixel = 0
            OverlayText.ZIndex = 2

            Utility.applyTextStyle(OverlayText)

            OverlayText.Parent = Plot

            local Tooltip = Instance.new("TextLabel")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.AutomaticSize = Enum.AutomaticSize.XY
            Tooltip.Size = UDim2.fromOffset(0, 0)
            Tooltip.BackgroundColor3 = Internal._config.PopupBgColor
            Tooltip.BackgroundTransparency = Internal._config.PopupBgTransparency
            Tooltip.BorderSizePixel = 0
            Tooltip.Visible = false

            Utility.applyTextStyle(Tooltip)
            Utility.UIStroke(Tooltip, Internal._config.PopupBorderSize, Internal._config.BorderActiveColor, Internal._config.BorderActiveTransparency)
            Utility.UIPadding(Tooltip, Internal._config.WindowPadding)
            if Internal._config.PopupRounding > 0 then
                Utility.UICorner(Tooltip, Internal._config.PopupRounding)
            end

            local popup = Internal._rootInstance and Internal._rootInstance:FindFirstChild("PopupScreenGui")
            Tooltip.Parent = popup and popup:FindFirstChild("TooltipContainer")

            thisWidget.Tooltip = Tooltip

            Utility.applyMouseMoved(Plot, function()
                updateBlock(thisWidget)
            end)

            Utility.applyMouseLeave(Plot, function()
                clearBlock(thisWidget)
            end)

            Plot.Parent = Background

            thisWidget.Blocks = {}
            thisWidget.HoveredBlock = false

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.Size = UDim2.fromOffset(0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = 3
            TextLabel.LayoutOrder = 3

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = PlotHistogram

            return PlotHistogram
        end,
        GenerateState = function(thisWidget: PlotHistogram)
            if thisWidget.state.values == nil then
                thisWidget.state.values = Internal._widgetState(thisWidget, "values", { 1 })
            end
            if thisWidget.state.hovered == nil then
                thisWidget.state.hovered = Internal._widgetState(thisWidget, "hovered", nil)
            end
        end,
        Update = function(thisWidget: PlotHistogram)
            local PlotLines = thisWidget.instance :: Frame
            local TextLabel: TextLabel = PlotLines.TextLabel
            local Background = PlotLines.Background :: Frame
            local Plot = Background.Plot :: Frame
            local OverlayText: TextLabel = Plot.OverlayText

            TextLabel.Text = thisWidget.arguments.Text or "Plot Histogram"
            OverlayText.Text = thisWidget.arguments.TextOverlay or ""
            PlotLines.Size = UDim2.new(1, 0, 0, thisWidget.arguments.Height or 0)
        end,
        UpdateState = function(thisWidget: PlotHistogram)
            if thisWidget.state.hovered._lastChangeTick == Internal._cycleTick then
                if thisWidget.state.hovered._value then
                    thisWidget.Tooltip.Visible = true
                else
                    thisWidget.Tooltip.Visible = false
                end
            end

            if thisWidget.state.values._lastChangeTick == Internal._cycleTick then
                local PlotHistogram = thisWidget.instance :: Frame
                local Background = PlotHistogram.Background :: Frame
                local Plot = Background.Plot :: Frame

                local values = thisWidget.state.values._value
                local count = #values
                local numBlocks = #thisWidget.Blocks

                local min = thisWidget.arguments.Min or math.huge
                local max = thisWidget.arguments.Max or -math.huge
                local baseline = thisWidget.arguments.BaseLine or 0

                if min == nil or max == nil then
                    for _, value in values do
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
                        local block = table.remove(thisWidget.Blocks)
                        if block then
                            block:Destroy()
                        end
                    end
                end

                local range = max - min
                local width = UDim.new(1 / count, -1)
                for index = 1, count do
                    local num = values[index]
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
                    updateBlock(thisWidget, true)
                end
            end
        end,
        Discard = function(thisWidget: PlotHistogram)
            thisWidget.instance:Destroy()
            thisWidget.Tooltip:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

return {}
