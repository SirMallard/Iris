local Types = require(script.Parent.Parent.Types)

-- Tables need an overhaul.

--[[
	Iris.Table(
		{
			NumColumns,
			Header,
			RowBackground,
			OuterBorders,
			InnerBorders
		}
	)

	Config = {
		CellPadding: Vector2,
		CellSize: UDim2,
	}

	Iris.NextColumn()
	Iris.NextRow()
	Iris.SetColumnIndex(index: number)
	Iris.SetRowIndex(index: number)

	Iris.NextHeaderColumn()
	Iris.SetHeaderColumnIndex(index: number)

	Iris.SetColumnWidth(index: number, width: number | UDim)
]]

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local Tables: { Types.Table } = {}

    table.insert(Iris._postCycleCallbacks, function()
        for _, thisWidget: Types.Table in Tables do
            thisWidget.RowIndex = 1
            thisWidget.ColumnIndex = 1
        end
    end)

    local function GenerateCell(thisWidget: Types.Table, index: number, width: UDim)
        local Cell: Frame = Instance.new("Frame")
        Cell.Name = `Cell_{index}`
        Cell.AutomaticSize = Enum.AutomaticSize.Y
        Cell.Size = UDim2.new(width, UDim.new())
        Cell.BackgroundTransparency = 1
        Cell.ZIndex = index
        Cell.LayoutOrder = index
        Cell.ClipsDescendants = true

        widgets.UIPadding(Cell, Iris._config.FramePadding)
        widgets.UIListLayout(Cell, Enum.FillDirection.Vertical, UDim.new())

        return Cell
    end

    -- creates a new row and all columns, and adds all to the table's row and cell instance tables, but does not parent
    local function GenerateRow(thisWidget: Types.Table, index: number)
        local Row: Frame = Instance.new("Frame")
        Row.Name = `Row_{index}`
        Row.AutomaticSize = Enum.AutomaticSize.Y
        Row.Size = UDim2.fromScale(1, 0)
        if index == 0 then
            Row.BackgroundColor3 = Iris._config.TableHeaderColor
            Row.BackgroundTransparency = Iris._config.TableHeaderTransparency
        elseif thisWidget.arguments.RowBackground == true then
            if (index % 2) == 0 then
                Row.BackgroundColor3 = Iris._config.TableRowBgAltColor
                Row.BackgroundTransparency = Iris._config.TableRowBgAltTransparency
            else
                Row.BackgroundColor3 = Iris._config.TableRowBgColor
                Row.BackgroundTransparency = Iris._config.TableRowBgTransparency
            end
        else
            Row.BackgroundTransparency = 1
        end
        Row.BorderSizePixel = 0
        Row.ZIndex = index
        Row.LayoutOrder = index
        Row.ClipsDescendants = true

        widgets.UIListLayout(Row, Enum.FillDirection.Horizontal, UDim.new())

        thisWidget.CellInstances[index] = table.create(thisWidget.arguments.NumColumns)
        for columnIndex = 1, thisWidget.arguments.NumColumns do
            local Cell = GenerateCell(thisWidget, columnIndex, thisWidget.state.widths.value[columnIndex])
            Cell.Parent = Row
            thisWidget.CellInstances[index][columnIndex] = Cell
        end

        thisWidget.RowInstances[index] = Row

        return Row
    end

    --stylua: ignore
    Iris.WidgetConstructor("Table", {
        hasState = true,
        hasChildren = true,
        Args = {
            NumColumns = 1,
            Header = 2,
            RowBackground = 3,
            OuterBorders = 4,
            InnerBorders = 5
        },
        Events = {},
        Generate = function(thisWidget: Types.Table)
            local Table: Frame = Instance.new("Frame")
            Table.Name = "Iris_Table"
            Table.AutomaticSize = Enum.AutomaticSize.Y
            Table.Size = UDim2.fromScale(1, 0)
            Table.BackgroundTransparency = 1
            Table.ZIndex = thisWidget.ZIndex
            Table.LayoutOrder = thisWidget.ZIndex

            local RowContainer: Frame = Instance.new("Frame")
            RowContainer.Name = "RowContainer"
            RowContainer.AutomaticSize = Enum.AutomaticSize.Y
            RowContainer.Size = UDim2.fromScale(1, 0)
            RowContainer.BackgroundTransparency = 1
            RowContainer.ZIndex = 1

            widgets.UIListLayout(RowContainer, Enum.FillDirection.Vertical, UDim.new())
            widgets.UIStroke(RowContainer, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)

            RowContainer.Parent = Table
			thisWidget.RowContainer = RowContainer

            local BorderContainer: Frame = Instance.new("Frame")
            BorderContainer.Name = "BorderContainer"
            BorderContainer.Size = UDim2.fromScale(1, 1)
            BorderContainer.BackgroundTransparency = 1
            BorderContainer.ZIndex = 2

            BorderContainer.Parent = Table

            thisWidget.ColumnIndex = 1
            thisWidget.RowIndex = 1
            thisWidget.RowInstances = {}
            thisWidget.CellInstances = {}

            return Table
        end,
        GenerateState = function(thisWidget: Types.Table)
            if thisWidget.state.widths == nil then
                local Widths: { UDim } = table.create(thisWidget.arguments.NumColumns, UDim.new(1 / thisWidget.arguments.NumColumns, 0))
                thisWidget.state.widths = Iris._widgetState(thisWidget, "widths", Widths)
            end
        end,
        Update = function(thisWidget: Types.Table)
            assert(thisWidget.arguments.NumColumns >= 1, "Iris.Table must have at least one column.")

            for rowIndex: number, row: Frame in thisWidget.RowInstances do
                if rowIndex == 0 then
                    row.BackgroundColor3 = Iris._config.TableHeaderColor
                    row.BackgroundTransparency = Iris._config.TableHeaderTransparency
                elseif thisWidget.arguments.RowBackground == true then
                    if (rowIndex % 2) == 0 then
                        row.BackgroundColor3 = Iris._config.TableRowBgAltColor
                        row.BackgroundTransparency = Iris._config.TableRowBgAltTransparency
                    else
                        row.BackgroundColor3 = Iris._config.TableRowBgColor
                        row.BackgroundTransparency = Iris._config.TableRowBgTransparency
                    end
                else
                    row.BackgroundTransparency = 1
                end
            end

            local HeaderRow: Frame? = thisWidget.RowInstances[0]
            if HeaderRow then
                HeaderRow.Visible = thisWidget.arguments.Header
            end
        end,
        UpdateState = function(thisWidget: Types.Table)
            for rowIndex: number, row: { Frame } in thisWidget.CellInstances do
                for columnIndex: number, cell: Frame in row do
                    cell.Size = UDim2.new(thisWidget.state.widths.value[columnIndex], UDim.new())
                end
            end
        end,
        ChildAdded = function(thisWidget: Types.Table, thisChild: Types.Widget)
            local rowIndex: number = thisWidget.RowIndex
            local columnIndex: number = thisWidget.ColumnIndex
            -- determine if the row exists yet
            local Row: Frame = thisWidget.RowInstances[rowIndex]

            if Row ~= nil then
                return thisWidget.CellInstances[rowIndex][columnIndex]
            end

            Row = GenerateRow(thisWidget, rowIndex)
            if rowIndex == 0 then
                Row.Visible = thisWidget.arguments.Header
            end
            Row.Parent = thisWidget.RowContainer

            return thisWidget.CellInstances[rowIndex][columnIndex]
        end,
        Discard = function(thisWidget: Types.Table)
            thisWidget.Instance:Destroy()     
            widgets.discardState(thisWidget)       
        end
    } :: Types.WidgetClass)
end
