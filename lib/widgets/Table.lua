local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

--[=[
    @class Table
    Table Widget API

    Example usage for creating a simple table:
    ```lua
    Iris.Table({ 4, true })
    do
        Iris.SetHeaderColumnIndex(1)

        -- for each row
        for i = 0, 10 do

            -- for each column
            for j = 1, 4 do
                if i == 0 then
                    --
                    Iris.Text({ `H: {j}` })
                else
                    Iris.Text({ `R: {i}, C: {j}` })
                end

                -- move the next column (and row when necessary)
                Iris.NextColumn()
            end
        end
    ```
]=]

--[=[
    @within Table
    @interface Table
    .& ParentWidget
    .changed () -> boolean -- fires when the widths of the table changes
    .hovered () -> boolean -- fires when the mouse hovers over any of the table

    .arguments { NumColumns: number, Flags: number }
    .state { widths: State<{ number }> }
]=]
export type Table = Types.ParentWidget & {
    _columnIndex: number,
    _rowIndex: number,
    _rowContainer: Frame,
    _rowInstances: { Frame },
    _cellInstances: { { Frame } },
    _rowBorders: { Frame },
    _columnBorders: { GuiButton },
    _rowCycles: { number },
    _widths: { UDim },
    _minWidths: { number },

    arguments: {
        NumColumns: number,
        Flags: number,
    },

    state: {
        widths: Types.State<{ number }>,
    },
} & Types.Changed & Types.Hovered

--[=[
    @within Table
    @interface TableFlags
    .Header 1 -- display a header row for each column
    .RowBackground 2 -- alternating row background colours
    .OuterBorders 4 -- outer border on the entire table
    .InnerBorders 8 -- inner bordres on the entire table
    .Resizable 16 -- the columns can be resized by dragging or state
    .FixedWidth 32 -- columns takes up a fixed pixel width, rather than a functionortion
    .ProportionalWidth 64 -- minimises the width of each column individually
    .LimitTableWidth 128 -- when a fixed width, cut of any unused space
]=]
local TableFlags = {
    Header = 1,
    RowBackground = 2,
    OuterBorders = 4,
    InnerBorders = 8,
    Resizable = 16,
    FixedWidth = 32,
    ProportionalWidth = 64,
    LimitTableWidth = 128,
}

---------------
-- Functions
---------------

local Tables: { [Types.ID]: Table } = {}
local TableMinWidths: { [Table]: { boolean } } = {}
local AnyActiveTable = false
local ActiveTable: Table? = nil
local ActiveColumn = 0
local ActiveLeftWidth = -1
local ActiveRightWidth = -1
local MousePositionX = 0

local function CalculateMinColumnWidth(thisWidget: Table, index: number)
    local width = 0
    for _, row in thisWidget._cellInstances do
        local cell = row[index]
        for _, child in cell:GetChildren() do
            if child:IsA("GuiObject") then
                width = math.max(width, child.AbsoluteSize.X)
            end
        end
    end

    thisWidget._minWidths[index] = width + 2 * Internal._config.CellPadding.X
end

local function UpdateActiveColumn()
    if AnyActiveTable == false or ActiveTable == nil then
        return
    end

    local widths = ActiveTable.state.widths
    local NumColumns = ActiveTable.arguments.NumColumns
    local Table = ActiveTable.instance :: Frame
    local BorderContainer = Table.BorderContainer :: Frame
    local Fixed = btest(TableFlags.FixedWidth, ActiveTable.arguments.Flags)
    local Padding = 2 * Internal._config.CellPadding.X

    if ActiveLeftWidth == -1 then
        ActiveLeftWidth = widths._value[ActiveColumn]
        if ActiveLeftWidth == 0 then
            ActiveLeftWidth = Padding / Table.AbsoluteSize.X
        end
        ActiveRightWidth = widths._value[ActiveColumn + 1] or -1
        if ActiveRightWidth == 0 then
            ActiveRightWidth = Padding / Table.AbsoluteSize.X
        end
    end

    local BorderX = Table.AbsolutePosition.X
    local LeftX: number -- the start of the current column
    -- local CurrentX: number = BorderContainer:FindFirstChild(`Border_{ActiveColumn}`).AbsolutePosition.X + 3 - BorderX -- the current column position
    local RightX: number -- the end of the next column
    if ActiveColumn == 1 then
        LeftX = 0
    else
        LeftX = math.floor(BorderContainer:FindFirstChild(`Border_{ActiveColumn - 1}`).AbsolutePosition.X + 3 - BorderX)
    end
    if ActiveColumn >= NumColumns - 1 then
        RightX = Table.AbsoluteSize.X
    else
        RightX = math.floor(BorderContainer:FindFirstChild(`Border_{ActiveColumn + 1}`).AbsolutePosition.X + 3 - BorderX)
    end

    local TableX: number = BorderX - Utility.guiOffset.X
    local DeltaX: number = math.clamp(Utility.getMouseLocation().X, LeftX + TableX + Padding, RightX + TableX - Padding) - MousePositionX
    local LeftOffset = (MousePositionX - TableX) - LeftX
    local LeftRatio = ActiveLeftWidth / LeftOffset

    if Fixed then
        widths._value[ActiveColumn] = math.clamp(math.round(ActiveLeftWidth + DeltaX), Padding, Table.AbsoluteSize.X - LeftX)
    else
        local Change = LeftRatio * DeltaX
        widths._value[ActiveColumn] = math.clamp(ActiveLeftWidth + Change, 0, (RightX - LeftX - Padding) / Table.AbsoluteSize.X)
        if ActiveColumn < NumColumns then
            widths._value[ActiveColumn + 1] = math.clamp(ActiveRightWidth - Change, 0, 1)
        end
    end

    widths:set(widths._value, true)
end

local function ColumnMouseDown(thisWidget: Table, index: number)
    AnyActiveTable = true
    ActiveTable = thisWidget
    ActiveColumn = index
    ActiveLeftWidth = -1
    ActiveRightWidth = -1
    MousePositionX = Utility.getMouseLocation().X
end

table.insert(Internal._postCycleCallbacks, function()
    for _, thisWidget in Tables do
        for rowIndex, cycleTick in thisWidget._rowCycles do
            if cycleTick < Internal._cycleTick - 1 then
                local Row = thisWidget._rowInstances[rowIndex]
                local RowBorder = thisWidget._rowBorders[rowIndex - 1]
                if Row ~= nil then
                    Row:Destroy()
                end
                if RowBorder ~= nil then
                    RowBorder:Destroy()
                end
                thisWidget._rowInstances[rowIndex] = nil
                thisWidget._rowBorders[rowIndex - 1] = nil
                thisWidget._cellInstances[rowIndex] = nil
                thisWidget._rowCycles[rowIndex] = nil
            end
        end

        thisWidget._rowIndex = 1
        thisWidget._columnIndex = 1

        -- update the border container size to be the same, albeit *every* frame!
        local Table = thisWidget.instance :: Frame
        local BorderContainer: Frame = Table.BorderContainer
        BorderContainer.Size = UDim2.new(1, 0, 0, thisWidget._rowContainer.AbsoluteSize.Y)
        thisWidget._columnBorders[0].Size = UDim2.fromOffset(5, thisWidget._rowContainer.AbsoluteSize.Y)
    end

    for thisWidget, columns in TableMinWidths do
        local refresh = false
        for column, _ in columns do
            CalculateMinColumnWidth(thisWidget, column)
            refresh = true
        end
        if refresh then
            table.clear(columns)
            Internal._widgets["Table"].UpdateState(thisWidget)
        end
    end
end)

Utility.registerEvent("InputChanged", function()
    if not Internal._started then
        return
    end
    UpdateActiveColumn()
end)

Utility.registerEvent("InputEnded", function(inputObject: InputObject)
    if not Internal._started then
        return
    end
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveTable then
        AnyActiveTable = false
        ActiveTable = nil
        ActiveColumn = 0
        ActiveLeftWidth = -1
        ActiveRightWidth = -1
        MousePositionX = 0
    end
end)

local function GenerateCell(_thisWidget: Table, index: number, width: UDim, header: boolean)
    local Cell: TextButton
    if header then
        Cell = Instance.new("TextButton")
        Cell.Text = ""
        Cell.AutoButtonColor = false
    else
        Cell = (Instance.new("Frame") :: GuiObject) :: TextButton
    end
    Cell.Name = `Cell_{index}`
    Cell.AutomaticSize = Enum.AutomaticSize.Y
    Cell.Size = UDim2.new(width, UDim.new())
    Cell.BackgroundTransparency = 1
    Cell.ZIndex = index
    Cell.LayoutOrder = index
    Cell.ClipsDescendants = true

    if header then
        Utility.applyInteractionHighlights("Background", Cell, Cell, {
            Color = Internal._config.HeaderColor,
            Transparency = 1,
            HoveredColor = Internal._config.HeaderHoveredColor,
            HoveredTransparency = Internal._config.HeaderHoveredTransparency,
            ActiveColor = Internal._config.HeaderActiveColor,
            ActiveTransparency = Internal._config.HeaderActiveTransparency,
        })
    end

    Utility.UIPadding(Cell, Internal._config.CellPadding)
    Utility.UIListLayout(Cell, Enum.FillDirection.Vertical, UDim.new())
    Utility.UISizeConstraint(Cell, Vector2.new(2 * Internal._config.CellPadding.X, 0))

    return Cell
end

local function GenerateColumnBorder(thisWidget: Table, index: number, style: "Light" | "Strong")
    local Border = Instance.new("ImageButton")
    Border.Name = `Border_{index}`
    Border.Size = UDim2.new(0, 5, 1, 0)
    Border.BackgroundTransparency = 1
    Border.Image = ""
    Border.ImageTransparency = 1
    Border.AutoButtonColor = false
    Border.ZIndex = index
    Border.LayoutOrder = 2 * index

    local offset = if index == thisWidget.arguments.NumColumns then 3 else 2

    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.Size = UDim2.new(0, 1, 1, 0)
    Line.Position = UDim2.fromOffset(offset, 0)
    Line.BackgroundColor3 = Internal._config[`TableBorder{style}Color`]
    Line.BackgroundTransparency = Internal._config[`TableBorder{style}Transparency`]
    Line.BorderSizePixel = 0

    Line.Parent = Border

    local Hover = Instance.new("Frame")
    Hover.Name = "Hover"
    Hover.Position = UDim2.fromOffset(offset, 0)
    Hover.Size = UDim2.new(0, 1, 1, 0)
    Hover.BackgroundColor3 = Internal._config[`TableBorder{style}Color`]
    Hover.BackgroundTransparency = Internal._config[`TableBorder{style}Transparency`]
    Hover.BorderSizePixel = 0

    Hover.Visible = btest(TableFlags.Resizable, thisWidget.arguments.Flags)

    Hover.Parent = Border

    Utility.applyInteractionHighlights("Background", Border, Hover, {
        Color = Internal._config.ResizeGripColor,
        Transparency = 1,
        HoveredColor = Internal._config.ResizeGripHoveredColor,
        HoveredTransparency = Internal._config.ResizeGripHoveredTransparency,
        ActiveColor = Internal._config.ResizeGripActiveColor,
        ActiveTransparency = Internal._config.ResizeGripActiveTransparency,
    })

    Utility.applyButtonDown(Border, function()
        if btest(TableFlags.Resizable, thisWidget.arguments.Flags) then
            ColumnMouseDown(thisWidget, index)
        end
    end)

    return Border
end

-- creates a new row and all columns, and adds all to the table's row and cell instance tables, but does not parent
local function GenerateRow(thisWidget: Table, index: number)
    local Row: Frame = Instance.new("Frame")
    Row.Name = `Row_{index}`
    Row.AutomaticSize = Enum.AutomaticSize.Y
    Row.Size = UDim2.fromScale(1, 0)
    if index == 0 then
        Row.BackgroundColor3 = Internal._config.TableHeaderColor
        Row.BackgroundTransparency = Internal._config.TableHeaderTransparency
    elseif btest(TableFlags.RowBackground, thisWidget.arguments.Flags) == true then
        if (index % 2) == 0 then
            Row.BackgroundColor3 = Internal._config.TableRowBgAltColor
            Row.BackgroundTransparency = Internal._config.TableRowBgAltTransparency
        else
            Row.BackgroundColor3 = Internal._config.TableRowBgColor
            Row.BackgroundTransparency = Internal._config.TableRowBgTransparency
        end
    else
        Row.BackgroundTransparency = 1
    end
    Row.BorderSizePixel = 0
    Row.ZIndex = 2 * index - 1
    Row.LayoutOrder = 2 * index - 1
    Row.ClipsDescendants = true

    Utility.UIListLayout(Row, Enum.FillDirection.Horizontal, UDim.new())

    thisWidget._cellInstances[index] = table.create(thisWidget.arguments.NumColumns)
    for columnIndex = 1, thisWidget.arguments.NumColumns do
        local Cell = GenerateCell(thisWidget, columnIndex, thisWidget._widths[columnIndex], index == 0)
        Cell.Parent = Row
        thisWidget._cellInstances[index][columnIndex] = Cell
    end

    thisWidget._rowInstances[index] = Row

    return Row
end

local function GenerateRowBorder(_thisWidget: Table, index: number, style: "Light" | "Strong")
    local Border = Instance.new("Frame")
    Border.Name = `Border_{index}`
    Border.Size = UDim2.fromScale(1, 0)
    Border.BackgroundTransparency = 1
    Border.ZIndex = 2 * index
    Border.LayoutOrder = 2 * index

    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.AnchorPoint = Vector2.new(0, 0.5)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.BackgroundColor3 = Internal._config[`TableBorder{style}Color`]
    Line.BackgroundTransparency = Internal._config[`TableBorder{style}Transparency`]
    Line.BorderSizePixel = 0

    Line.Parent = Border

    return Border
end

-----------
-- Table
-----------

Internal._widgetConstructor(
    "Table",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 2,
        Arguments = { "NumColumns", "Flags", "widths" },
        Events = {
            ["changed"] = Utility.EVENTS.change("widths"),
        },
        Generate = function(thisWidget: Table)
            Tables[thisWidget.ID] = thisWidget
            TableMinWidths[thisWidget] = {}

            local Table = Instance.new("Frame")
            Table.Name = "Iris_Table"
            Table.AutomaticSize = Enum.AutomaticSize.Y
            Table.Size = UDim2.fromScale(1, 0)
            Table.BackgroundTransparency = 1

            local RowContainer = Instance.new("Frame")
            RowContainer.Name = "RowContainer"
            RowContainer.AutomaticSize = Enum.AutomaticSize.Y
            RowContainer.Size = UDim2.fromScale(1, 0)
            RowContainer.BackgroundTransparency = 1
            RowContainer.ZIndex = 1

            Utility.UISizeConstraint(RowContainer)
            Utility.UIListLayout(RowContainer, Enum.FillDirection.Vertical, UDim.new())

            RowContainer.Parent = Table
            thisWidget._rowContainer = RowContainer

            local BorderContainer = Instance.new("Frame")
            BorderContainer.Name = "BorderContainer"
            BorderContainer.Size = UDim2.fromScale(1, 1)
            BorderContainer.BackgroundTransparency = 1
            BorderContainer.ZIndex = 2
            BorderContainer.ClipsDescendants = true

            Utility.UISizeConstraint(BorderContainer)
            Utility.UIListLayout(BorderContainer, Enum.FillDirection.Horizontal, UDim.new())
            Utility.UIStroke(BorderContainer, 1, Internal._config.TableBorderStrongColor, Internal._config.TableBorderStrongTransparency)

            BorderContainer.Parent = Table

            thisWidget._columnIndex = 1
            thisWidget._rowIndex = 1
            thisWidget._rowInstances = {}
            thisWidget._cellInstances = {}
            thisWidget._rowBorders = {}
            thisWidget._columnBorders = {}
            thisWidget._rowCycles = {}

            local callbackIndex = #Internal._postCycleCallbacks + 1
            local desiredCycleTick = Internal._cycleTick + 1
            Internal._postCycleCallbacks[callbackIndex] = function()
                if Internal._cycleTick >= desiredCycleTick then
                    if thisWidget._lastCycleTick ~= -1 then
                        thisWidget.state.widths._lastChangeTick = Internal._cycleTick
                        Internal._widgets["Table"].UpdateState(thisWidget)
                    end
                    Internal._postCycleCallbacks[callbackIndex] = nil
                end
            end

            return Table
        end,
        GenerateState = function(thisWidget: Table)
            local NumColumns = thisWidget.arguments.NumColumns
            if thisWidget.state.widths == nil then
                local Widths: { number } = table.create(NumColumns, 1 / NumColumns)
                thisWidget.state.widths = Internal._widgetState(thisWidget, "widths", Widths)
            end
            thisWidget._widths = table.create(NumColumns, UDim.new())
            thisWidget._minWidths = table.create(NumColumns, 0)

            local Table = thisWidget.instance :: Frame
            local BorderContainer: Frame = Table.BorderContainer

            thisWidget._cellInstances[-1] = table.create(NumColumns)
            for index = 1, NumColumns do
                local Border = GenerateColumnBorder(thisWidget, index, "Light")
                Border.Visible = btest(TableFlags.InnerBorders, thisWidget.arguments.Flags)
                thisWidget._columnBorders[index] = Border
                Border.Parent = BorderContainer

                local Cell = GenerateCell(thisWidget, index, thisWidget._widths[index], false)
                local UISizeConstraint = Cell:FindFirstChild("UISizeConstraint") :: UISizeConstraint
                UISizeConstraint.MinSize = Vector2.new(2 * Internal._config.CellPadding.X + (if index > 1 then -2 else 0) + (if index < NumColumns then -3 else 0), 0)
                Cell.LayoutOrder = 2 * index - 1
                thisWidget._cellInstances[-1][index] = Cell
                Cell.Parent = BorderContainer
            end

            local TableColumnBorder = GenerateColumnBorder(thisWidget, NumColumns, "Strong")
            thisWidget._columnBorders[0] = TableColumnBorder
            TableColumnBorder.Parent = Table
        end,
        Update = function(thisWidget: Table)
            local NumColumns = thisWidget.arguments.NumColumns
            assert(NumColumns >= 1, "Iris.Table must have at least one column.")

            if thisWidget._widths ~= nil and #thisWidget._widths ~= NumColumns then
                -- disallow changing the number of columns. It's too much effort
                thisWidget.arguments.NumColumns = #thisWidget._widths
                warn("NumColumns cannot change once set. See documentation.")
            end

            for rowIndex, row in thisWidget._rowInstances do
                if rowIndex == 0 then
                    row.BackgroundColor3 = Internal._config.TableHeaderColor
                    row.BackgroundTransparency = Internal._config.TableHeaderTransparency
                elseif btest(TableFlags.RowBackground, thisWidget.arguments.Flags) == true then
                    if (rowIndex % 2) == 0 then
                        row.BackgroundColor3 = Internal._config.TableRowBgAltColor
                        row.BackgroundTransparency = Internal._config.TableRowBgAltTransparency
                    else
                        row.BackgroundColor3 = Internal._config.TableRowBgColor
                        row.BackgroundTransparency = Internal._config.TableRowBgTransparency
                    end
                else
                    row.BackgroundTransparency = 1
                end
            end

            for _, Border: Frame in thisWidget._rowBorders do
                Border.Visible = btest(TableFlags.InnerBorders, thisWidget.arguments.Flags)
            end

            for _, Border: GuiButton in thisWidget._columnBorders do
                Border.Visible = btest(TableFlags.InnerBorders, thisWidget.arguments.Flags) or btest(TableFlags.Resizable, thisWidget.arguments.Flags)
            end

            for _, border in thisWidget._columnBorders do
                local hover = border:FindFirstChild("Hover") :: Frame?
                if hover then
                    hover.Visible = btest(TableFlags.Resizable, thisWidget.arguments.Flags)
                end
            end

            if thisWidget._columnBorders[NumColumns] ~= nil then
                thisWidget._columnBorders[NumColumns].Visible = not btest(TableFlags.LimitTableWidth, thisWidget.arguments.Flags)
                    and (btest(TableFlags.Resizable, thisWidget.arguments.Flags) or btest(TableFlags.InnerBorders, thisWidget.arguments.Flags))
                thisWidget._columnBorders[0].Visible = btest(TableFlags.LimitTableWidth, thisWidget.arguments.Flags) and (btest(TableFlags.Resizable, thisWidget.arguments.Flags) or btest(TableFlags.OuterBorders, thisWidget.arguments.Flags))
            end

            -- the header border visibility must be updated after settings all borders
            -- visiblity or not
            local HeaderRow: Frame? = thisWidget._rowInstances[0]
            local HeaderBorder: Frame? = thisWidget._rowBorders[0]
            if HeaderRow ~= nil then
                HeaderRow.Visible = btest(TableFlags.Header, thisWidget.arguments.Flags)
            end
            if HeaderBorder ~= nil then
                HeaderBorder.Visible = btest(TableFlags.Header, thisWidget.arguments.Flags) and btest(TableFlags.InnerBorders, thisWidget.arguments.Flags)
            end

            local Table = thisWidget.instance :: Frame
            local BorderContainer = Table.BorderContainer :: Frame
            BorderContainer.UIStroke.Enabled = btest(TableFlags.OuterBorders, thisWidget.arguments.Flags)

            for index = 1, thisWidget.arguments.NumColumns do
                TableMinWidths[thisWidget][index] = true
            end

            if thisWidget._widths ~= nil then
                Internal._widgets["Table"].UpdateState(thisWidget)
            end
        end,
        UpdateState = function(thisWidget: Table)
            local Table = thisWidget.instance :: Frame
            local BorderContainer = Table.BorderContainer :: Frame
            local RowContainer = Table.RowContainer :: Frame
            local NumColumns = thisWidget.arguments.NumColumns
            local ColumnWidths = thisWidget.state.widths._value
            local MinWidths = thisWidget._minWidths

            local Fixed = btest(TableFlags.FixedWidth, thisWidget.arguments.Flags)
            local Proportional = btest(TableFlags.ProportionalWidth, thisWidget.arguments.Flags)

            if not btest(TableFlags.Resizable, thisWidget.arguments.Flags) then
                if Fixed then
                    if Proportional then
                        for index = 1, NumColumns do
                            ColumnWidths[index] = MinWidths[index]
                        end
                    else
                        local maxWidth = 0
                        for _, width in MinWidths do
                            maxWidth = math.max(maxWidth, width)
                        end
                        for index = 1, NumColumns do
                            ColumnWidths[index] = maxWidth
                        end
                    end
                else
                    if Proportional then
                        local TotalWidth = 0
                        for _, width in MinWidths do
                            TotalWidth += width
                        end
                        local Ratio = 1 / TotalWidth
                        for index = 1, NumColumns do
                            ColumnWidths[index] = Ratio * MinWidths[index]
                        end
                    else
                        local width = 1 / NumColumns
                        for index = 1, NumColumns do
                            ColumnWidths[index] = width
                        end
                    end
                end
            end

            local Position = UDim.new()
            for index = 1, NumColumns do
                local ColumnWidth = ColumnWidths[index]

                local Width = UDim.new(if Fixed then 0 else math.clamp(ColumnWidth, 0, 1), if Fixed then math.max(ColumnWidth, 0) else 0)
                thisWidget._widths[index] = Width
                Position += Width

                for _, row in thisWidget._cellInstances do
                    row[index].Size = UDim2.new(Width, UDim.new())
                end

                thisWidget._cellInstances[-1][index].Size = UDim2.new(Width + UDim.new(0, (if index > 1 then -2 else 0) - 3), UDim.new())
            end

            -- if the table has a fixed width and we want to cap it, we calculate the table width necessary
            local Width = Position.Offset
            if not btest(TableFlags.FixedWidth, thisWidget.arguments.Flags) or not btest(TableFlags.LimitTableWidth, thisWidget.arguments.Flags) then
                Width = math.huge
            end

            BorderContainer.UISizeConstraint.MaxSize = Vector2.new(Width, math.huge)
            RowContainer.UISizeConstraint.MaxSize = Vector2.new(Width, math.huge)
            thisWidget._columnBorders[0].Position = UDim2.fromOffset(Width - 3, 0)
        end,
        ChildAdded = function(thisWidget: Table, _: Types.Widget)
            local rowIndex = thisWidget._rowIndex
            local columnIndex = thisWidget._columnIndex
            -- determine if the row exists yet
            local Row = thisWidget._rowInstances[rowIndex]
            thisWidget._rowCycles[rowIndex] = Internal._cycleTick
            TableMinWidths[thisWidget][columnIndex] = true

            if Row ~= nil then
                return thisWidget._cellInstances[rowIndex][columnIndex]
            end

            Row = GenerateRow(thisWidget, rowIndex)
            if rowIndex == 0 then
                Row.Visible = btest(TableFlags.Header, thisWidget.arguments.Flags)
            end
            Row.Parent = thisWidget._rowContainer

            if rowIndex > 0 then
                local Border = GenerateRowBorder(thisWidget, rowIndex - 1, if rowIndex == 1 then "Strong" else "Light")
                Border.Visible = btest(TableFlags.InnerBorders, thisWidget.arguments.Flags)
                    and (if rowIndex == 1 then (btest(TableFlags.Header, thisWidget.arguments.Flags) and btest(TableFlags.InnerBorders, thisWidget.arguments.Flags)) and (thisWidget._rowInstances[0] ~= nil) else true)
                thisWidget._rowBorders[rowIndex - 1] = Border
                Border.Parent = thisWidget._rowContainer
            end

            return thisWidget._cellInstances[rowIndex][columnIndex]
        end,
        ChildDiscarded = function(thisWidget: Table, thisChild: Types.Widget)
            local Cell = thisChild.instance.Parent

            if Cell ~= nil then
                local columnIndex = tonumber(Cell.Name:sub(6))

                if columnIndex then
                    TableMinWidths[thisWidget][columnIndex] = true
                end
            end
        end,
        Discard = function(thisWidget: Table)
            Tables[thisWidget.ID] = nil
            TableMinWidths[thisWidget] = nil
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

--[=[
    @within Table
    @tag Widget
    @tag HasChildren

    @function Table
    @param numColumns number -- number of columns in the table, cannot be changed
    @param flags TableFlags? -- optional bit flags, using Iris.TableFlags, default is 0
    @param widths State<{ number }>? -- the widths of each column if Resizable

    @return Table

    A layout widget which allows children to be displayed in configurable columns and rows. Highly configurable for many different
    options, with options for custom width columns as configured by the user, or automatically use the best size.

    When Resizable is enabled, the vertical columns can be dragged horizontally to increase or decrease space. This is linked to
    the widths state, which controls the width of each column. This is also dependent on whether the FixedWidth argument is enabled.
    By default, the columns will scale with the width of the table overall, therefore taking up a percentage, and the widths will be
    in the range of 0 to 1 as a float. If FixedWidth is enabled, then the widths will be in pixels and have a value of > 2 as an
    integer.

    ProportionalWidth determines whether each column has the same width, or individual. By default, each column will take up an equal
    functionortion
    meaning wider columns take up a greater share of the total available space. For a fixed width table, by default each column will
    take the max width of all the columns. When true, each column width will the minimum to fit the children within.

    LimitTableWidth is used when FixedWidth is true. It will cut off the table horizontally after the last column.

    :::info
    Once the NumColumns is set, it is not possible to change it without some extra code. The best way to do this is by using
    `Iris.PushConfig()` and `Iris.PopConfig()` which will automatically redraw the widget when the columns change.

    ```lua
    local numColumns = 4
    Iris.PushConfig({ columns = numColumns })
    Iris.Table({ numColumns, ...})
    do
        ...
    end
    Iris.End()
    Iris.PopConfig()
    ```

    :::danger Error: nil
    Always ensure that the number of elements in the widths state is greater or equal to the
    new number of columns when changing the number of columns.
    :::
    :::
]=]
local API_Table = function(numColumns: number, flags: number?, widths: Types.APIState<{ number }>?)
    return Internal._insert("Table", numColumns, flags or 0, widths) :: Table
end

--[=[
    @within Table
    @function NextColumn

    In a table, moves to the next available cell. If the current cell is in the last column,
    then moves to the cell in the first column of the next row.
]=]
local API_NextColumn = function()
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.NextColumn() can only called when directly within a table.")

    local columnIndex = thisWidget._columnIndex
    if columnIndex == thisWidget.arguments.NumColumns then
        thisWidget._columnIndex = 1
        thisWidget._rowIndex += 1
    else
        thisWidget._columnIndex += 1
    end
    return thisWidget._columnIndex
end

--[=[
    @within Table
    @function NextRow

    In a table, moves to the cell in the first column of the next row.
]=]
local API_NextRow = function()
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.NextRow() can only called when directly within a table.")
    thisWidget._columnIndex = 1
    thisWidget._rowIndex += 1
    return thisWidget._rowIndex
end

--[=[
    @within Table
    @function SetColumnIndex
    @param index number

    In a table, moves to the cell in the given column in the same previous row.

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
local API_SetColumnIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.SetColumnIndex() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)
    thisWidget._columnIndex = index
end

--[=[
    @within Table
    @function SetRowIndex
    @param index number

    In a table, moves to the cell in the given row with the same previous column.
]=]
local API_SetRowIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.SetRowIndex() can only called when directly within a table.")
    assert(index >= 1, "The index must be greater or equal to 1.")
    thisWidget._rowIndex = index
end

--[=[
    @within Table
    @function NextHeaderColumn

    In a table, moves to the cell in the next column in the header row (row index 0). Will loop around
    from the last column to the first.
]=]
local API_NextHeaderColumn = function()
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.NextHeaderColumn() can only called when directly within a table.")

    thisWidget._rowIndex = 0
    thisWidget._columnIndex = (thisWidget._columnIndex % thisWidget.arguments.NumColumns) + 1

    return thisWidget._columnIndex
end

--[=[
    @within Table
    @function SetHeaderColumnIndex
    @param index number

    In a table, moves to the cell in the given column in the header row (row index 0).

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
local API_SetHeaderColumnIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.SetHeaderColumnIndex() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)

    thisWidget._rowIndex = 0
    thisWidget._columnIndex = index
end

--[=[
    @within Table
    @function SetColumnWidth
    @param index number
    @param width number

    In a table, sets the width of the given column to the given value by changing the
    Table's widths state. When the FixedWidth argument is true, the width should be in
    pixels >2, otherwise as a float between 0 and 1.

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
local API_SetColumnWidth = function(index: number, width: number)
    local thisWidget = Internal._getParentWidget() :: Table
    assert(thisWidget ~= nil, "Iris.SetColumnWidth() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)

    local oldValue = thisWidget.state.widths.value[index]
    thisWidget.state.widths.value[index] = width
    thisWidget.state.widths:set(thisWidget.state.widths.value, width ~= oldValue)
end

return {
    TableFlags = TableFlags,
    API_Table = API_Table,
    API_NextColumn = API_NextColumn,
    API_NextRow = API_NextRow,
    API_SetColumnIndex = API_SetColumnIndex,
    API_SetRowIndex = API_SetRowIndex,
    API_NextHeaderColumn = API_NextHeaderColumn,
    API_SetHeaderColumnIndex = API_SetHeaderColumnIndex,
    API_SetColumnWidth = API_SetColumnWidth,
}
