local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local abstractImage = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Image"] = 1,
            ["Size"] = 2,
            ["Rect"] = 3,
            ["ScaleType"] = 4,
            ["ResampleMode"] = 5,
            ["TileSize"] = 6,
            ["SliceCenter"] = 7,
            ["SliceScale"] = 8,
        },
        Update = function(thisWidget: Types.Widget)
            local Image = thisWidget.Instance :: ImageLabel

            Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
            Image.Size = thisWidget.arguments.Size
            if thisWidget.arguments.ScaleType then
                Image.ScaleType = thisWidget.arguments.ScaleType
                if thisWidget.arguments.ScaleType == Enum.ScaleType.Tile and thisWidget.arguments.TileSize then
                    Image.TileSize = thisWidget.arguments.TileSize
                elseif thisWidget.arguments.ScaleType == Enum.ScaleType.Slice then
                    if thisWidget.arguments.SliceCenter then
                        Image.SliceCenter = thisWidget.arguments.SliceCenter
                    end
                    if thisWidget.arguments.SliceScale then
                        Image.SliceScale = thisWidget.arguments.SliceScale
                    end
                end
            end

            if thisWidget.arguments.Rect then
                Image.ImageRectOffset = thisWidget.arguments.Rect.Min
                Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
            end

            if thisWidget.arguments.ResampleMode then
                Image.ResampleMode = thisWidget.arguments.ResampleMode
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass

	--stylua: ignore
	Iris.WidgetConstructor("Image", widgets.extend(abstractImage, {
            Events = {
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
            },
            Generate = function(thisWidget: Types.Widget)
                local Image: ImageLabel = Instance.new("ImageLabel")
                Image.Name = "Iris_Image"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Iris._config.ImageColor
                Image.ImageTransparency = Iris._config.ImageTransparency
                Image.ZIndex = thisWidget.ZIndex
                Image.LayoutOrder = thisWidget.ZIndex

                widgets.applyFrameStyle(Image, true, true)

                return Image
            end,
		} :: Types.WidgetClass)
	)

    --stylua: ignore
    Iris.WidgetConstructor("ImageButton", widgets.extend(abstractImage, {
            Events = {
                ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
                ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
                ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
                ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
            },
            Generate = function(thisWidget: Types.Widget)
                local Image: ImageButton = Instance.new("ImageButton")
                Image.Name = "Iris_ImageButton"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Iris._config.ImageColor
                Image.ImageTransparency = Iris._config.ImageTransparency
                Image.ZIndex = thisWidget.ZIndex
                Image.LayoutOrder = thisWidget.ZIndex
                Image.AutoButtonColor = false

                widgets.applyFrameStyle(Image, true, true)

                return Image
            end
        } :: Types.WidgetClass)
    )
end
