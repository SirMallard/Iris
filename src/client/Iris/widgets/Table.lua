return function(Iris, widgets)
    local tableWidgets = {}

    table.insert(Iris._postCycleCallbacks, function()
        for _, v in tableWidgets do
            v.RowColumnIndex = 0
        end
    end)

    Iris.NextColumn = function()
        Iris._GetParentWidget().RowColumnIndex += 1
    end
    Iris.SetColumnIndex = function(ColumnIndex)
        local ParentWidget = Iris._GetParentWidget()
        assert(ColumnIndex >= ParentWidget.InitialNumColumns, "Iris.SetColumnIndex Argument must be in column range")
        ParentWidget.RowColumnIndex = math.floor(ParentWidget.RowColumnIndex / ParentWidget.InitialNumColumns) + (ColumnIndex - 1)
    end
    Iris.NextRow = function()
        -- sets column Index back to 0, increments Row
        local ParentWidget = Iris._GetParentWidget()
        local InitialNumColumns = ParentWidget.InitialNumColumns
        local nextRow = math.floor((ParentWidget.RowColumnIndex + 1) / InitialNumColumns) * InitialNumColumns
        ParentWidget.RowColumnIndex = nextRow
    end

    Iris.WidgetConstructor("Table", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["NumColumns"] = 1,
            ["RowBg"] = 2,
            ["BordersOuter"] = 3,
            ["BordersInner"] = 4
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            tableWidgets[thisWidget.ID] = thisWidget

            thisWidget.InitialNumColumns = -1
            thisWidget.RowColumnIndex = 0
            -- reference to these is stored as an optimization
            thisWidget.ColumnInstances = {}
            thisWidget.CellInstances = {}

            local Table = Instance.new("Frame")
            Table.Name = "Iris_Table"
            Table.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
            Table.BackgroundTransparency = 1
            Table.BorderSizePixel = 0
            Table.ZIndex = thisWidget.ZIndex + 1024 -- allocate room for 1024 cells, because Table UIStroke has to appear above cell UIStroke
            Table.LayoutOrder = thisWidget.ZIndex
            Table.AutomaticSize = Enum.AutomaticSize.Y
            Table.ClipsDescendants = true

            widgets.UIListLayout(Table, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            widgets.UIStroke(Table, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)


            return Table
        end,
        Update = function(thisWidget)
            local thisWidgetInstance = thisWidget.Instance
            local ColumnInstances = thisWidget.ColumnInstances

            if thisWidget.arguments.BordersOuter == false then
                thisWidgetInstance.UIStroke.Thickness = 0
            else
                thisWidget.Instance.UIStroke.Thickness = 1
            end

            if thisWidget.InitialNumColumns == -1 then
                if thisWidget.arguments.NumColumns == nil then
                    error("Iris.Table NumColumns argument is required", 5)
                end
                thisWidget.InitialNumColumns = thisWidget.arguments.NumColumns

                for i = 1, thisWidget.InitialNumColumns do
                    local column = Instance.new("Frame")
                    column.Name = `Column_{i}`
                    column.BackgroundTransparency = 1
                    column.BorderSizePixel = 0
                    local ColumnZIndex = thisWidget.ZIndex + 1 + i
                    column.ZIndex = ColumnZIndex
                    column.LayoutOrder = ColumnZIndex
                    column.AutomaticSize = Enum.AutomaticSize.Y
                    column.Size = UDim2.new(1 / thisWidget.InitialNumColumns, 0, 0, 0)
                    column.ClipsDescendants = true

                    widgets.UIListLayout(column, Enum.FillDirection.Vertical, UDim.new(0, 0))

                    ColumnInstances[i] = column
                    column.Parent = thisWidgetInstance
                end

            elseif thisWidget.arguments.NumColumns ~= thisWidget.InitialNumColumns then
                -- its possible to make it so that the NumColumns can increase,
                -- but decreasing it would interfere with child widget instances
                error("Iris.Table NumColumns Argument must be static")
            end

            if thisWidget.arguments.RowBg == false then
                for _,v in thisWidget.CellInstances do
                    v.BackgroundTransparency = 1
                end
            else
                for rowColumnIndex, v in thisWidget.CellInstances do
                    local currentRow = math.ceil((rowColumnIndex) / thisWidget.InitialNumColumns)
                    v.BackgroundTransparency = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency
                end
            end

            if thisWidget.arguments.BordersInner == false then
                for _,v in thisWidget.CellInstances do
                    v.UIStroke.Thickness = 0
                end
            else
                for _,v in thisWidget.CellInstances do
                    v.UIStroke.Thickness = 0.5
                end
            end
        end,
        Discard = function(thisWidget)
            tableWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget)
            if thisWidget.RowColumnIndex == 0 then
                thisWidget.RowColumnIndex = 1
            end
            local potentialCellParent = thisWidget.CellInstances[thisWidget.RowColumnIndex]
            if potentialCellParent then
                return potentialCellParent
            end
            local cell = Instance.new("Frame")
            cell.AutomaticSize = Enum.AutomaticSize.Y
            cell.Size = UDim2.new(1, 0, 0, 0)
            cell.BackgroundTransparency = 1
            cell.BorderSizePixel = 0
            widgets.UIPadding(cell, Iris._config.CellPadding)
            local selectedParent = thisWidget.ColumnInstances[((thisWidget.RowColumnIndex - 1) % thisWidget.InitialNumColumns) + 1]
            local newZIndex = selectedParent.ZIndex + thisWidget.RowColumnIndex
            cell.ZIndex = newZIndex
            cell.LayoutOrder = newZIndex
            cell.Name = `Cell_{thisWidget.RowColumnIndex}`

            widgets.UIListLayout(cell, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            if thisWidget.arguments.BordersInner == false then
                widgets.UIStroke(cell, 0, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
            else
                widgets.UIStroke(cell, 0.5, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
                -- this takes advantage of unintended behavior when UIStroke is set to 0.5 to render cell borders,
                -- at 0.5, only the top and left side of the cell will be rendered with a border.
            end

            if thisWidget.arguments.RowBg ~= false then
                local currentRow = math.ceil((thisWidget.RowColumnIndex) / thisWidget.InitialNumColumns)
                local color = if currentRow % 2 == 0 then Iris._config.TableRowBgAltColor else Iris._config.TableRowBgColor
                local transparency = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency

                cell.BackgroundColor3 = color
                cell.BackgroundTransparency = transparency
            end

            thisWidget.CellInstances[thisWidget.RowColumnIndex] = cell
            cell.Parent = selectedParent
            return cell
        end
    })
end