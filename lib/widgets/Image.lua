local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local abstractImage = {
        hasState = false,
        hasChildren = false,
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local Image: ImageLabel = Instance.new("ImageLabel")
            Image.Name = "Iris_Image"
            Image.BackgroundTransparency = 1
            Image.BorderSizePixel = 1
            Image.ImageColor3 = Iris._config.TextColor
            Image.ImageTransparency = Iris._config.TextTransparency
            Image.ZIndex = thisWidget.ZIndex
            Image.LayoutOrder = thisWidget.ZIndex

            widgets.applyFrameStyle(Image, true, true)

            return Image
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass

	--stylua: ignore
	Iris.WidgetConstructor("Image", widgets.extend(abstractImage, {
			Args = {
				["Image"] = 1,
				["Size"] = 2,
				["Rect"] = 3,
				["ScaleType"] = 4,
				["ResampleMode"] = 5,
			},
			Update = function(thisWidget: Types.Widget)
				local Image = thisWidget.Instance :: ImageLabel

				Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
				Image.Size = UDim2.fromOffset(thisWidget.arguments.Size.X, thisWidget.arguments.Size.Y)
				if thisWidget.arguments.Rect then
					Image.ImageRectOffset = thisWidget.arguments.Rect.Min
					Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
				end
				if thisWidget.arguments.ScaleType then
					if thisWidget.arguments.ScaleType == Enum.ScaleType.Slice or thisWidget.arguments.ScaleType == Enum.ScaleType.Tile then
						warn("Iris.Image does not support Slice or Tile ImageTypes.")
						Image.ScaleType = Enum.ScaleType.Fit
					else
						Image.ScaleType = thisWidget.arguments.ScaleType
					end
				end
				if thisWidget.arguments.ResampleMode then
					Image.ResampleMode = thisWidget.arguments.ResampleMode
				end
			end,
		} :: Types.WidgetClass)
	)

	--stylua: ignore
    Iris.WidgetConstructor("TiledImage", widgets.extend(abstractImage, {
			Args = {
				["Image"] = 1,
				["Size"] = 2,
				["TileSize"] = 3,
				["ResampleMode"] = 4,
			},
			Update = function(thisWidget: Types.Widget)
				local Image = thisWidget.Instance :: ImageLabel

				Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
				Image.Size = UDim2.fromOffset(thisWidget.arguments.Size.X, thisWidget.arguments.Size.Y)
				Image.ScaleType = Enum.ScaleType.Tile
				if thisWidget.arguments.TileSize then
					Image.TileSize = thisWidget.arguments.TileSize
				end
				if thisWidget.arguments.ResampleMode then
					Image.ResampleMode = thisWidget.arguments.ResampleMode
				end
			end,
		} :: Types.WidgetClass)
	)

	--stylua: ignore
    Iris.WidgetConstructor("SlicedImage", widgets.extend(abstractImage, {
		Args = {
			["Image"] = 1,
			["Size"] = 2,
			["Rect"] = 3,
			["SliceCenter"] = 4,
			["SliceScale"] = 5,
			["ResampleMode"] = 6,
		},
		Update = function(thisWidget: Types.Widget)
			local Image = thisWidget.Instance :: ImageLabel

			Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
			Image.Size = UDim2.fromOffset(thisWidget.arguments.Size.X, thisWidget.arguments.Size.Y)
			Image.ScaleType = Enum.ScaleType.Slice
			if thisWidget.arguments.Rect then
				Image.ImageRectOffset = thisWidget.arguments.Rect.Min
				Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
			end
			if thisWidget.arguments.SliceCenter then
				Image.SliceCenter = thisWidget.arguments.SliceCenter
			end
			if thisWidget.arguments.SliceScale then
				Image.SliceScale = thisWidget.arguments.SliceScale
			end
			if thisWidget.arguments.ResampleMode then
				Image.ResampleMode = thisWidget.arguments.ResampleMode
			end
		end,
	} :: Types.WidgetClass)
)
end
