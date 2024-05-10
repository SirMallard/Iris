local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local tableWidgets: { [Types.ID]: Types.Widget } = {}

    -- reset the cell index every frame.
    table.insert(Iris._postCycleCallbacks, function()
        for _, thisWidget: Types.Widget in tableWidgets do
            thisWidget.RowColumnIndex = 0
        end
    end)

    --stylua: ignore
    Iris.WidgetConstructor("Table", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["NumColumns"] = 1,
            ["RowBg"] = 2,
            ["BordersOuter"] = 3,
            ["BordersInner"] = 4,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            tableWidgets[thisWidget.ID] = thisWidget

            thisWidget.InitialNumColumns = -1
            thisWidget.RowColumnIndex = 0
            -- reference to these is stored as an optimization
            thisWidget.ColumnInstances = {}
            thisWidget.CellInstances = {}
            thisWidget.postCycleCallbackIDs = {}

            local Table: Frame = Instance.new("Frame")
            Table.Name = "Iris_Table"
            Table.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
            Table.AutomaticSize = Enum.AutomaticSize.Y
            Table.BackgroundTransparency = 1
            Table.BorderSizePixel = 0
            Table.ZIndex = thisWidget.ZIndex + 1024 -- allocate room for 1024 cells, because Table UIStroke has to appear above cell UIStroke
            Table.LayoutOrder = thisWidget.ZIndex
            Table.ClipsDescendants = true

            widgets.UIListLayout(Table, Enum.FillDirection.Horizontal, UDim.new(0, 0))
            widgets.UIStroke(Table, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)

            return Table
        end,
        Update = function(thisWidget: Types.Widget)
            local Table = thisWidget.Instance :: Frame

            if thisWidget.arguments.BordersOuter == false then
                Table.UIStroke.Thickness = 0
            else
                Table.UIStroke.Thickness = 1
            end

            if thisWidget.InitialNumColumns == -1 then
                if thisWidget.arguments.NumColumns == nil then
                    error("Iris.Table NumColumns argument is required", 5)
                end
                thisWidget.InitialNumColumns = thisWidget.arguments.NumColumns

                for index = 1, thisWidget.InitialNumColumns do
                    local zindex: number = thisWidget.ZIndex + 1 + index

                    local Column: Frame = Instance.new("Frame")
                    Column.Name = `Column_{index}`
                    Column.Size = UDim2.new(1 / thisWidget.InitialNumColumns, 0, 0, 0)
                    Column.AutomaticSize = Enum.AutomaticSize.Y
                    Column.BackgroundTransparency = 1
                    Column.BorderSizePixel = 0
                    Column.ZIndex = zindex
                    Column.LayoutOrder = zindex
                    Column.ClipsDescendants = true

                    task.defer(function()
                        debug.profilebegin("Iris/PrepareUpdateCellSizes")

                        -- idk if this is the best way to do it, but it works so...
                        local allLayoutOrders = {}
                        for _, v in Column:GetChildren() do
                            if v:IsA("Frame") then
                                table.insert(allLayoutOrders, v.LayoutOrder)
                            end
                        end

                        table.sort(allLayoutOrders)

                        local cellsOnThisRow = {}
                        
                        for _, v in Column:GetChildren() do
                            if not v:IsA("Frame") then
                                continue
                            end

                            local layoutOrder = v.LayoutOrder
                            local index = table.find(allLayoutOrders, layoutOrder)
                            local otherColumns = thisWidget.ColumnInstances

                            cellsOnThisRow[v] = {}

                            v.Size = UDim2.new(1, 0, 0, 0)
                            
                            for _, otherColumn in otherColumns do
                                if otherColumn == Column then
                                    continue
                                end

                                local otherColumnLayoutOrders = {}
                                for _, v in otherColumn:GetChildren() do
                                    if v:IsA("Frame") then
                                        table.insert(otherColumnLayoutOrders, v.LayoutOrder)
                                    end
                                end

                                table.sort(otherColumnLayoutOrders)

                                for _, v2 in otherColumn:GetChildren() do
                                    if not v2:IsA("Frame") then
                                        continue
                                    end

                                    local otherLayoutOrder = v2.LayoutOrder
                                    local otherIndex = table.find(otherColumnLayoutOrders, otherLayoutOrder)

                                    if index == otherIndex then
                                        table.insert(cellsOnThisRow[v], v2)
                                    end
                                end
                            end
                        end

                        local function UpdateCellSizes()
                            debug.profilebegin("Iris/EarlyUpdateCellSizes")
                            for _, v in Column:GetChildren() do
                                if not v:IsA("Frame") then
                                    continue
                                end

                                v.Size = UDim2.new(1, 0, 0, 0)
    
                                task.defer(function()
                                    debug.profilebegin("Iris/UpdateCellSizes")
                                    for _, cell in cellsOnThisRow[v] do
                                        if v.AbsoluteSize.Y > cell.AbsoluteSize.Y then
                                            cell.Size = UDim2.new(1, 0, 0, v.AbsoluteSize.Y)
                                        end
                                    end
                                    debug.profileend()
                                end)
                            end
                            debug.profileend()
                        end

                        task.defer(UpdateCellSizes)

                        local id = #Iris._postCycleCallbacks + 1
                        table.insert(thisWidget.postCycleCallbackIDs, id)
                        Iris._postCycleCallbacks[id] = UpdateCellSizes

                        debug.profileend()
                    end)                    

                    widgets.UIListLayout(Column, Enum.FillDirection.Vertical, UDim.new(0, 0))

                    thisWidget.ColumnInstances[index] = Column
                    Column.Parent = Table
                end
            elseif thisWidget.arguments.NumColumns ~= thisWidget.InitialNumColumns then
                -- its possible to make it so that the NumColumns can increase,
                -- but decreasing it would interfere with child widget instances
                error("Iris.Table NumColumns Argument must be static")
            end

            if thisWidget.arguments.RowBg == false then
                for _, Cell: Frame in thisWidget.CellInstances do
                    Cell.BackgroundTransparency = 1
                end
            else
                for index: number, Cell: Frame in thisWidget.CellInstances do
                    local currentRow: number = math.ceil(index / thisWidget.InitialNumColumns)
                    Cell.BackgroundTransparency = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency
                end
            end

            -- wooo, I love lua types. Especially on an object and child based system like Roblox! I never have to do anything
            -- annoying or dumb to make it like me!
            if thisWidget.arguments.BordersInner == false then
                for _, Cell: Frame & { UIStroke: UIStroke } in thisWidget.CellInstances :: any do
                    Cell.UIStroke.Thickness = 0
                end
            else
                for _, Cell: Frame & { UIStroke: UIStroke } in thisWidget.CellInstances :: any do
                    Cell.UIStroke.Thickness = 0.5
                end
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            tableWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()

            for _, id in thisWidget.postCycleCallbackIDs do
                Iris._postCycleCallbacks[id] = nil
            end
        end,
        ChildAdded = function(thisWidget: Types.Widget)
            if thisWidget.RowColumnIndex == 0 then
                thisWidget.RowColumnIndex = 1
            end
            local potentialCellParent: Frame = thisWidget.CellInstances[thisWidget.RowColumnIndex]
            if potentialCellParent then
                return potentialCellParent
            end

            local selectedParent: Frame = thisWidget.ColumnInstances[((thisWidget.RowColumnIndex - 1) % thisWidget.InitialNumColumns) + 1]
            local zindex: number = selectedParent.ZIndex + thisWidget.RowColumnIndex

            local Cell: Frame = Instance.new("Frame")
            Cell.Name = `Cell_{thisWidget.RowColumnIndex}`
            Cell.Size = UDim2.new(1, 0, 0, 0)
            Cell.AutomaticSize = Enum.AutomaticSize.Y
            Cell.BackgroundTransparency = 1
            Cell.BorderSizePixel = 0
            Cell.ZIndex = zindex
            Cell.LayoutOrder = zindex
            Cell.ClipsDescendants = true

            widgets.UIPadding(Cell, Iris._config.CellPadding)
            widgets.UIListLayout(Cell, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            if thisWidget.arguments.BordersInner == false then
                widgets.UIStroke(Cell, 0, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
            else
                widgets.UIStroke(Cell, 0.5, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
                -- this takes advantage of unintended behavior when UIStroke is set to 0.5 to render cell borders,
                -- at 0.5, only the top and left side of the cell will be rendered with a border.
            end

            if thisWidget.arguments.RowBg ~= false then
                local currentRow: number = math.ceil(thisWidget.RowColumnIndex / thisWidget.InitialNumColumns)
                local color: Color3 = if currentRow % 2 == 0 then Iris._config.TableRowBgAltColor else Iris._config.TableRowBgColor
                local transparency: number = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency

                Cell.BackgroundColor3 = color
                Cell.BackgroundTransparency = transparency
            end

            thisWidget.CellInstances[thisWidget.RowColumnIndex] = Cell
            Cell.Parent = selectedParent
            return Cell
        end,
    } :: Types.WidgetClass)
end
