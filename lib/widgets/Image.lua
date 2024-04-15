local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
	--stylua: ignore
	Iris.WidgetConstructor("Image", {
		hasState = false,
		hasChildren = false,
		Args = {
			["Image"] = 1,
			["Size"] = 2,
			["Rect"] = 3,
		},
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
		Update = function(thisWidget: Types.Widget)
			local Image = thisWidget.Instance :: ImageLabel

			Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
			Image.Size = UDim2.fromOffset(thisWidget.arguments.Size.X, thisWidget.arguments.Size.Y)
			Image.ImageRectOffset = thisWidget.arguments.Rect.Min
			Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
		end,
		Discard = function(thisWidget: Types.Widget)
			thisWidget.Instance:Destroy()
		end
	} :: Types.WidgetClass)
end
