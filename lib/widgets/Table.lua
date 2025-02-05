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

    local function CreateColumn(thisWidget: Types.Table, index: number)
        local Column: Frame = Instance.new("Frame")
        Column.Name = `Column_{index}`
        Column.AutomaticSize = Enum.AutomaticSize.Y
        Column.Size = UDim2.fromScale(0.25, 0)
        Column.BackgroundTransparency = 1
        Column.ZIndex = index
        Column.LayoutOrder = index

        widgets.UIPadding(Column, Iris._config.FramePadding)
        widgets.UIListLayout(Column, Enum.FillDirection.Vertical, UDim.new())

        return Column
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

            widgets.UIListLayout(CellContainer, Enum.FillDirection.Vertical, UDim.new())
            widgets.UIStroke(CellContainer, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)

            CellContainer.Parent = Table

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
            local CellContainer: Frame = Table.CellContainer

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
