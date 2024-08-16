local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
	--stylua: ignore
    Iris.WidgetConstructor("TabBar", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(thisWidget: Types.Widget)
			local TabBar: Frame = Instance.new("Frame")
			TabBar.Name = "Iris_TabBar"
			TabBar.AutomaticSize = Enum.AutomaticSize.Y
			TabBar.Size = UDim2.fromScale(1, 0)
			TabBar.BackgroundTransparency = 1
			TabBar.BorderSizePixel = 0
			TabBar.LayoutOrder = thisWidget.ZIndex

			widgets.UIListLayout(TabBar, Enum.FillDirection.Vertical, UDim.new()).VerticalAlignment = Enum.VerticalAlignment.Bottom
			
			local Bar: Frame = Instance.new("Frame")
			Bar.Name = "Bar"
			Bar.AutomaticSize = Enum.AutomaticSize.Y
			Bar.Size = UDim2.fromScale(1, 0)
			Bar.BackgroundTransparency = 1
			Bar.BorderSizePixel = 0
			
			widgets.UIListLayout(Bar, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

			Bar.Parent = TabBar

			local Underline: Frame = Instance.new("Frame")
			Underline.Name = "Underline"
			Underline.Size = UDim2.new(1, 0, 0, 1)
			Underline.BackgroundColor3 = Iris._config.TabActiveColor
			Underline.BackgroundTransparency = Iris._config.TabActiveTransparency
			Underline.BorderSizePixel = 0
			Underline.LayoutOrder = 1

			Underline.Parent = TabBar

			local ChildContainer: Frame = Instance.new("Frame")
			ChildContainer.Name = "TabContainer"
			ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
			ChildContainer.Size = UDim2.fromScale(1, 0)
			ChildContainer.BackgroundTransparency = 1
			ChildContainer.BorderSizePixel = 0
			ChildContainer.LayoutOrder = 2
			ChildContainer.ClipsDescendants = true

			ChildContainer.Parent = TabBar

			thisWidget.ChildContainer = ChildContainer

			return TabBar
		end,
		Update = function(_thisWidget: Types.Widget) end,
		ChildAdded = function(thisWidget: Types.Widget, thisChild: Types.Widget)
			assert(thisChild.type == "Tab", "Only Iris.Tab can be parented to Iris.TabBar.")
			local TabBar = thisWidget.Instance :: Frame
			if thisChild.type == "Tab" then
				thisChild.ChildContainer.Parent = thisWidget.ChildContainer
			end
			return TabBar.Bar
		end,
		ChildDiscarded = function(thisWidget: Types.Widget, thisChild: Types.Widget) end,
		Discard = function(thisWidget: Types.Widget)
			thisWidget.Instance:Destroy()
		end,
	} :: Types.WidgetClass)

	--stylua: ignore
	Iris.WidgetConstructor("Tab", {
		hasState = true,
		hasChildren = true,
		Args = {
			["Text"] = 1,
			["Index"] = 2,
			["Hideable"] = 3,
		},
		Events = {},
		Generate = function(thisWidget: Types.Widget)
			local Tab = Instance.new("TextButton")
			Tab.Name = "Iris_Tab"
			Tab.AutomaticSize = Enum.AutomaticSize.XY
			Tab.BackgroundColor3 = Iris._config.TabColor
			Tab.BackgroundTransparency = Iris._config.TabTransparency
			Tab.BorderSizePixel = 0
			Tab.Text = ""
			Tab.AutoButtonColor = false

			thisWidget.ButtonColors = {
                ButtonColor = Iris._config.TabColor,
                ButtonTransparency = Iris._config.TabTransparency,
                ButtonHoveredColor = Iris._config.TabHoveredColor,
                ButtonHoveredTransparency = Iris._config.TabHoveredTransparency,
                ButtonActiveColor = Iris._config.TabActiveColor,
                ButtonActiveTransparency = Iris._config.TabActiveTransparency,
            }

			widgets.UIPadding(Tab, Vector2.new(Iris._config.FramePadding.X, 0))
			widgets.applyFrameStyle(Tab, true, true)
			widgets.UIListLayout(Tab, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center
			widgets.applyInteractionHighlights(thisWidget, Tab, Tab, thisWidget.ButtonColors)
			widgets.applyButtonClick(thisWidget, Tab, function()
				thisWidget.state.index:set(thisWidget.arguments.Index)
			end)

			local TextLabel = Instance.new("TextLabel")
			TextLabel.Name = "TextLabel"
			TextLabel.AutomaticSize = Enum.AutomaticSize.XY
			TextLabel.BackgroundTransparency = 1
			TextLabel.BorderSizePixel = 0

			widgets.applyTextStyle(TextLabel)
			widgets.UIPadding(TextLabel, Vector2.new(0, Iris._config.FramePadding.Y))

			TextLabel.Parent = Tab

			local ButtonSize: number = Iris._config.TextSize + ((Iris._config.FramePadding.Y - 1) * 2)

			local CloseButton = Instance.new("TextButton")
			CloseButton.Name = "CloseButton"
			CloseButton.BackgroundTransparency = 1
			CloseButton.BorderSizePixel = 0
			CloseButton.LayoutOrder = 1
			CloseButton.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
			CloseButton.Text = ""
			CloseButton.AutoButtonColor = false

			widgets.UICorner(CloseButton)
			widgets.applyButtonClick(thisWidget, CloseButton, function()
				if thisWidget.state.index.value == thisWidget.arguments.Index then
					thisWidget.state.index:set(nil)
				end
				thisWidget.state.isOpened:set(false)
			end)

			widgets.applyInteractionHighlights(CloseButton, CloseButton, CloseButton, {
                ButtonColor = Iris._config.TabColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
			})


			CloseButton.Parent = Tab

			local Icon = Instance.new("ImageLabel")
			Icon.Name = "Icon"
			Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon.BackgroundTransparency = 1
			Icon.BorderSizePixel = 0
			Icon.Image = widgets.ICONS.MULTIPLICATION_SIGN
			Icon.Position = UDim2.fromScale(0.5, 0.5)
			Icon.Size = UDim2.fromOffset(math.floor(0.7 * ButtonSize), math.floor(0.7 * ButtonSize))

			widgets.applyImageInteractionHighlights(thisWidget, Tab, Icon, {
                ButtonColor = Iris._config.TextColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.TextColor,
                ButtonHoveredTransparency = Iris._config.TextTransparency,
                ButtonActiveColor = Iris._config.TextColor,
                ButtonActiveTransparency = Iris._config.TextTransparency,
			})
			Icon.Parent = CloseButton

			local ChildContainer: Frame = Instance.new("Frame")
            ChildContainer.Name = "TabContainer"
			ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0

            ChildContainer.ClipsDescendants = true

			thisWidget.ChildContainer = ChildContainer

			return Tab
		end,
		Update = function(thisWidget: Types.Widget)
			local Tab = thisWidget.Instance :: TextButton
			local TextLabel: TextLabel = Tab.TextLabel
			local CloseButton: TextButton = Tab.CloseButton

			assert(thisWidget.arguments.Index ~= nil, "An index argument must be provided to Iris.Tab.")

			TextLabel.Text = thisWidget.arguments.Text
			CloseButton.Visible = if thisWidget.arguments.NoClose == true then false else true
		end,
		ChildAdded = function(thisWidget: Types.Widget, thisChild: Types.Widget)
			return thisWidget.ChildContainer
		end,
		GenerateState = function(thisWidget: Types.Widget)
			if thisWidget.state.index == nil then
				thisWidget.state.index = Iris._widgetState(thisWidget, "index", nil)
			end
			if thisWidget.state.isOpened == nil then
				thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", true)
			end
		end,
		UpdateState = function(thisWidget: Types.Widget)
			local Tab = thisWidget.Instance :: TextButton
			local Container = thisWidget.ChildContainer :: Frame

			if thisWidget.state.isOpened.value == true then
				Tab.Visible = true
			else
				Tab.Visible = false
			end

			if thisWidget.state.index.value == thisWidget.arguments.Index then
				thisWidget.ButtonColors.ButtonColor = Iris._config.TabActiveColor
				thisWidget.ButtonColors.ButtonTransparency = Iris._config.TabActiveTransparency
				Tab.BackgroundColor3 = Iris._config.TabActiveColor
				Tab.BackgroundTransparency = Iris._config.TabActiveTransparency
				Container.Visible = true
			else
				thisWidget.ButtonColors.ButtonColor = Iris._config.TabColor
				thisWidget.ButtonColors.ButtonTransparency = Iris._config.TabTransparency
				Tab.BackgroundColor3 = Iris._config.TabColor
				Tab.BackgroundTransparency = Iris._config.TabTransparency
				Container.Visible = false
			end
		end,
		Discard = function(thisWidget: Types.Widget)
			thisWidget.Instance:Destroy()
		end
	} :: Types.WidgetClass)
end
