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
    local function CreateColumn(thisWidget: Types.Table, index: number)
        local Column: Frame = Instance.new("Frame")
        Column.Name = `Column_{index}`
        Column.AutomaticSize = Enum.AutomaticSize.Y
        Column.Size = UDim2.fromScale(0, 0)
        Column.BackgroundTransparency = 1
        Column.LayoutOrder = index
        Column.ZIndex = index

        widgets.UIListLayout(Column, Enum.FillDirection.Vertical, UDim.new())

        return Column
    end

    local function CreateCell(thisWidget: Types.Table, index: number)
        local Cell: Frame = Instance.new("Frame")
        Cell.Name = `Cell_{index}`
        Cell.AutomaticSize = Enum.AutomaticSize.Y
        Cell.Size = UDim2.fromScale(1, 0)
        Cell.ZIndex = index
        Cell.LayoutOrder = index

        widgets.UIPadding(Cell, Iris._config.FramePadding)

        return Cell
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

            local CellContainer: Frame = Instance.new("Frame")
            CellContainer.Name = "CellContainer"
            CellContainer.AutomaticSize = Enum.AutomaticSize.Y
            CellContainer.Size = UDim2.fromScale(1, 0)
            CellContainer.BackgroundTransparency = 1
            CellContainer.ZIndex = 1

            widgets.UIListLayout(CellContainer, Enum.FillDirection.Horizontal, UDim.new())

            CellContainer.Parent = Table

            local BorderContainer: Frame = Instance.new("Frame")
            BorderContainer.Name = "BorderContainer"
            BorderContainer.Size = UDim2.fromScale(1, 1)
            BorderContainer.BackgroundTransparency = 1
            BorderContainer.ZIndex = 2

            widgets.UIStroke(BorderContainer, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)

            BorderContainer.Parent = Table

            thisWidget.ColumnIndex = -1
            thisWidget.RowIndex = 1
            thisWidget.ColumnInstances = {}
            thisWidget.CellInstances = {}

            return Table
        end,
        Update = function(thisWidget: Types.Table)
            assert(thisWidget.arguments.NumColumns >= 1, "Iris.Table must have at least one column.")
            local Table = thisWidget.Instance :: Frame
            local CellContainer: Frame = Table.CellContainer

            if thisWidget.ColumnIndex == -1 then
                local Size: UDim2 = UDim2.fromScale(1 / thisWidget.arguments.NumColumns, 0)
                for i = 1, thisWidget.arguments.NumColumns do
                    local Column: Frame = CreateColumn(thisWidget, i)
                    Column.Size = Size
                    table.insert(thisWidget.ColumnInstances, Column)
                    Column.Parent = CellContainer
                end
                thisWidget.ColumnIndex = 1

                if thisWidget.arguments.Header == true then
                    thisWidget.RowIndex = 0
                end
            end
        end,
        ChildAdded = function(thisWidget: Types.Table, thisChild: Types.Widget)
            
        end,
        Discard = function(thisWidget: Types.Table)
            thisWidget.Instance:Destroy()            
        end
    } :: Types.WidgetClass)
end
