local Types = require(script.Parent.Parent.Types)

-- Tables need an overhaul.

--[[
	Iris.Table(
		{
			NumColumns,
			Resizable,
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
    local ActiveTable: Types.Table? = nil

    table.insert(Iris._postCycleCallbacks, function()
        for _, thisWidget: Types.Table in Tables do
            thisWidget.RowIndex = 1
            thisWidget.ColumnIndex = 1
        end
    end)

    local function CreateRow(thisWidget: Types.Table, index: number)
        local Row: Frame = Instance.new("Frame")
        Row.Name = `Row_{index}`
        Row.AutomaticSize = Enum.AutomaticSize.Y
        Row.Size = UDim2.fromScale(1, 0)
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.ZIndex = index
        Row.LayoutOrder = index

        widgets.UIListLayout(Row, Enum.FillDirection.Horizontal, UDim.new())

        return Row
    end

    local function CreateCell(thisWidget: Types.Table, index: number, width: UDim)
        local Cell: Frame = Instance.new("Frame")
        Cell.Name = `Cell_{index}`
        Cell.AutomaticSize = Enum.AutomaticSize.Y
        Cell.Size = UDim2.new(width, UDim.new())
        Cell.BackgroundTransparency = 1
        Cell.ZIndex = index
        Cell.LayoutOrder = index

        widgets.UIPadding(Cell, Iris._config.FramePadding)
        widgets.UIListLayout(Cell, Enum.FillDirection.Vertical, UDim.new())

        return Cell
    end

    local function AppendRow(thisWidget: Types.Table)
        local index = #thisWidget.RowInstances + 1
        local Row = CreateRow(thisWidget, index)
        for columnIndex = 1, thisWidget.arguments.NumColumns do
            local Cell = CreateCell(thisWidget, columnIndex, thisWidget.ColumnWidths[columnIndex])
            Cell.Parent = Row
            table.insert(thisWidget.CellInstances, Cell)
        end

        Row.Parent = thisWidget.RowContainer
        table.insert(thisWidget.RowInstances, Row)
    end

    Iris.NextColumn = function(): number
        assert(ActiveTable ~= nil, "Iris.NextColumn() can only called within a table.")

        local columnIndex = ActiveTable.ColumnIndex
        if columnIndex == ActiveTable.arguments.NumColumns then
            ActiveTable.ColumnIndex = 1
            ActiveTable.RowIndex += 1
        else
            ActiveTable.ColumnIndex += 1
        end
        return ActiveTable.ColumnIndex
    end

    Iris.NextRow = function(): number
        assert(ActiveTable ~= nil, "Iris.NextRow() can only called within a table.")
        ActiveTable.ColumnIndex = 1
        ActiveTable.RowIndex += 1
        return ActiveTable.RowIndex
    end

    Iris.SetColumnIndex = function(index: number): ()
        assert(ActiveTable ~= nil, "Iris.SetColumnIndex() can only called within a table.")
        assert((index >= 1) and (index <= ActiveTable.arguments.NumColumns), `The index must be between 1 and {ActiveTable.arguments.NumColumns}, inclusive.`)
        ActiveTable.ColumnIndex = index
    end

    Iris.SetRowIndex = function(index: number): ()
        assert(ActiveTable ~= nil, "Iris.SetRowIndex() can only called within a table.")
        assert(index >= 1, "The index must be greater or equal to 1.")
        ActiveTable.RowIndex = index
    end

    Iris.NextHeaderColumn = function(): number
        assert(ActiveTable ~= nil, "Iris.NextHeaderColumn() can only called within a table.")

        ActiveTable.RowIndex = 0
        ActiveTable.ColumnIndex += 1

        return ActiveTable.ColumnIndex
    end

    Iris.SetHeaderColumnIndex = function(index: number): ()
        return
    end

    Iris.SetColumnWidth = function(index: number, width: number | UDim): ()
        return
    end

    --stylua: ignore
    Iris.WidgetConstructor("Table", {
        hasState = false,
        hasChildren = true,
        Args = {
            NumColumns = 1,
            Resizable = 2,
            Header = 3,
            RowBackground = 4,
            OuterBorders = 5,
            InnerBorders = 6
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
            thisWidget.RowIndex = -1
            thisWidget.ColumnWidths = {}
            thisWidget.RowInstances = {}
            thisWidget.CellInstances = {}

            return Table
        end,
        Update = function(thisWidget: Types.Table)
            assert(thisWidget.arguments.NumColumns >= 1, "Iris.Table must have at least one column.")
            local Table = thisWidget.Instance :: Frame
            local RowContainer: Frame = Table.RowContainer

            if thisWidget.RowIndex == -1 then
                local Size: UDim = UDim.new(1 / thisWidget.arguments.NumColumns, 0)
                thisWidget.ColumnWidths = table.create(thisWidget.arguments.NumColumns, Size)
                thisWidget.RowIndex = 1
            end
        end,
        ChildAdded = function(thisWidget: Types.Table, thisChild: Types.Widget)
            
        end,
        Discard = function(thisWidget: Types.Table)
            thisWidget.Instance:Destroy()            
        end
    } :: Types.WidgetClass)
end
