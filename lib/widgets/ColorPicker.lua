local Types = require(script.Parent.Parent.Types)

function UpdateHuePicker(thisWidget: Types.ColorPicker, container: any)
    container.HueHandle.Position = UDim2.fromScale(0.5, thisWidget.Hue)
end

function UpdateValuesPicker(thisWidget: Types.ColorPicker, container: any)
    container.BackgroundColor3 = Color3.fromHSV(thisWidget.Hue, 1, 1)
    container.ValuesHandle.Position = UDim2.fromScale(thisWidget.Saturation, 1 - thisWidget.Value)
    container.ValuesHandle.BackgroundColor3 = Color3.fromHSV(thisWidget.Hue, thisWidget.Saturation, thisWidget.Value)
    container.ValuesHandle.UIStroke.Color = Color3.fromHSV(1, 0, 1 - thisWidget.Value)
end

function UpdateComparer(thisWidget: Types.ColorPicker, container: any)
    container.OriginalCompare.BackgroundColor3 = thisWidget.arguments.Compare or Color3.new(0, 0, 0)
    container.CurrentCompare.BackgroundColor3 = (thisWidget.state and thisWidget.state.color.value) or Color3.new(0, 0, 0)
end

function GenerateValuesPicker(widgets: Types.WidgetUtility, container: any)
    local ValuesPicker: Frame = Instance.new("Frame")
    ValuesPicker.Name = "ValuesPicker"
    ValuesPicker.BackgroundTransparency = 0
    ValuesPicker.Size = UDim2.fromScale(1, 1)
    ValuesPicker.SizeConstraint = Enum.SizeConstraint.RelativeYY
    ValuesPicker.BorderSizePixel = 0
    ValuesPicker.Parent = container

    local SaturationInner: Frame = Instance.new("Frame")
    SaturationInner.Name = "ValueInner"
    SaturationInner.BorderSizePixel = 0
    SaturationInner.Size = UDim2.fromScale(1, 1)
    SaturationInner.BackgroundColor3 = Color3.new(1, 1, 1)
    SaturationInner.Parent = ValuesPicker

    local SaturationGradient: UIGradient = Instance.new("UIGradient")
    SaturationGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    SaturationGradient.Parent = SaturationInner

    local ValueInner: Frame = Instance.new("Frame")
    ValueInner.Name = "ValueInner"
    ValueInner.BorderSizePixel = 0
    ValueInner.Size = UDim2.fromScale(1, 1)
    ValueInner.BackgroundColor3 = Color3.new(0, 0, 0)
    ValueInner.Parent = ValuesPicker

    local ValueGradient: UIGradient = Instance.new("UIGradient")
    ValueGradient.Rotation = 90
    ValueGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    ValueGradient.Parent = ValueInner

    local ValuesHandle: Frame = Instance.new("Frame")
    ValuesHandle.Name = "ValuesHandle"
    ValuesHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    ValuesHandle.Size = UDim2.fromOffset(12, 12)
    ValuesHandle.BackgroundTransparency = 0
    ValuesHandle.BorderSizePixel = 0
    ValuesHandle.Parent = ValuesPicker

    local ValuesHandleStroke: UIStroke = Instance.new("UIStroke")
    ValuesHandleStroke.Thickness = 1
    ValuesHandleStroke.Parent = ValuesHandle

    local ValuesHandleRounder: UICorner = Instance.new("UICorner")
    ValuesHandleRounder.CornerRadius = UDim.new(0.5, 0)
    ValuesHandleRounder.Parent = ValuesHandle

    local ValuesPickerDetector: TextButton = Instance.new("TextButton")
    ValuesPickerDetector.Name = "ValuesPickerDetector"
    ValuesPickerDetector.Size = UDim2.fromScale(1, 1)
    ValuesPickerDetector.BackgroundTransparency = 1
    ValuesPickerDetector.BorderSizePixel = 0
    ValuesPickerDetector.Text = ""
    ValuesPickerDetector.TextTransparency = 1
    ValuesPickerDetector.Parent = ValuesPicker

    return ValuesPickerDetector
end

function GenerateHuePicker(widgets: Types.WidgetUtility, container: any)
    local HuePicker: Frame = Instance.new("Frame")
    HuePicker.Name = "HuePicker"
    HuePicker.Size = UDim2.new(0, 28, 1, 0)
    HuePicker.BackgroundTransparency = 1
    HuePicker.Parent = container

    widgets.UIPadding(HuePicker, Vector2.new(6, 0))

    local HueGradient: ImageLabel = Instance.new("ImageLabel")
    HueGradient.Name = "HueGradient"
    HueGradient.ImageColor3 = Color3.new(1, 1, 1)
    HueGradient.Size = UDim2.fromScale(1, 1)
    HueGradient.Image = "rbxassetid://71681907403574"
    HueGradient.BorderSizePixel = 0
    HueGradient.Parent = HuePicker

    local HueHandle = Instance.new("ImageLabel")
    HueHandle.Name = "HueHandle"
    HueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    HueHandle.BackgroundTransparency = 1
    HueHandle.BorderSizePixel = 0
    HueHandle.Image = "rbxassetid://118877065467257"
    HueHandle.Position = UDim2.fromScale(0.5, 0)
    HueHandle.ScaleType = Enum.ScaleType.Slice
    HueHandle.Size = UDim2.new(1, 4, 0, 8)
    HueHandle.SliceCenter = Rect.new(25, 12, 35, 12)
    HueHandle.Parent = HuePicker

    local HueDetector: TextButton = Instance.new("TextButton")
    HueDetector.Name = "HueDetector"
    HueDetector.Size = UDim2.fromScale(1, 1)
    HueDetector.Text = ""
    HueDetector.BackgroundTransparency = 1
    HueDetector.BorderSizePixel = 0
    HueDetector.TextTransparency = 1
    HueDetector.Parent = HuePicker

    return HueDetector
end

function GenerateComparer(Iris: Types.Internal, widgets: Types.WidgetUtility, container: any)
    local Comparer: Frame = Instance.new("Frame")
    Comparer.Name = "ColorComparer"
    Comparer.BackgroundTransparency = 1
    Comparer.BorderSizePixel = 0
    Comparer.Size = UDim2.new(0, 65, 1, 0)
    Comparer.Parent = container

    widgets.UIListLayout(Comparer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemInnerSpacing.Y))

    local Text: TextLabel = Instance.new("TextLabel")
    Text.Name = "Iris_Text"
    Text.Text = "Current"
    Text.Size = UDim2.fromScale(1, 0)
    Text.BackgroundTransparency = 1
    Text.BorderSizePixel = 0
    Text.AutomaticSize = Enum.AutomaticSize.Y
    Text.Parent = Comparer

    local CurrentCompare = Instance.new("Frame")
    CurrentCompare.Name = "CurrentCompare"
    CurrentCompare.Size = UDim2.new(1, 0, 0, 36)
    CurrentCompare.BorderSizePixel = 0
    CurrentCompare.Parent = Comparer

    local Text2: TextLabel = Instance.new("TextLabel")
    Text2.Name = "Iris_Text"
    Text2.Text = "Original"
    Text2.Size = UDim2.fromScale(1, 0)
    Text2.BackgroundTransparency = 1
    Text2.BorderSizePixel = 0
    Text2.AutomaticSize = Enum.AutomaticSize.Y
    Text2.Parent = Comparer

    local OriginalCompare = Instance.new("Frame")
    OriginalCompare.Name = "OriginalCompare"
    OriginalCompare.Size = UDim2.new(1, 0, 0, 36)
    OriginalCompare.BorderSizePixel = 0
    OriginalCompare.Parent = Comparer

    widgets.applyTextStyle(Text)
    widgets.applyTextStyle(Text2)

    return Comparer
end

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    --stylua: ignore
    local ActiveDrag: Types.ColorPicker = nil
    local ActiveDragType: ("Values" | "Hue")? = nil

    local function updateActiveDrag()
        if not ActiveDrag then
            return
        end

        local mousePosition = widgets.getMouseLocation()
        local editor = (ActiveDrag :: any).Instance.EditorContainer
        local picker = (ActiveDragType == "Values" and editor.ValuesPicker) or editor.HuePicker
        local pickerPosition: Vector2 = (mousePosition - (picker.AbsolutePosition - widgets.GuiOffset))
        local pickerPercent: Vector2 = pickerPosition / picker.AbsoluteSize

        if ActiveDragType == "Values" then
            ActiveDrag.Saturation = math.clamp(pickerPercent.X, 0, 1)
            ActiveDrag.Value = math.clamp(1 - pickerPercent.Y, 0, 1)
            UpdateValuesPicker(ActiveDrag, editor.ValuesPicker)
        elseif ActiveDragType == "Hue" then
            ActiveDrag.Hue = math.clamp(pickerPercent.Y, 0, 1)
            UpdateHuePicker(ActiveDrag, editor.HuePicker)
            UpdateValuesPicker(ActiveDrag, editor.ValuesPicker)
        end
        ActiveDrag.state.color:set(Color3.fromHSV(ActiveDrag.Hue, ActiveDrag.Saturation, ActiveDrag.Value))
        UpdateComparer(ActiveDrag, editor.ColorComparer)
    end

    local function DragMouseDown(thisWidget: Types.ColorPicker, dragType: "Values" | "Hue")
        ActiveDrag = thisWidget
        ActiveDragType = dragType
        updateActiveDrag()
    end

    widgets.registerEvent("InputEnded", function(inputObject: InputObject)
        if not Iris._started then
            return
        end
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and ActiveDrag then
            ActiveDrag = nil :: any
            ActiveDragType = nil
        end
    end)
    widgets.registerEvent("InputChanged", function(input)
        if not Iris._started then
            return
        end
        updateActiveDrag()
    end)

    Iris.WidgetConstructor("ColorPicker", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Compare"] = 1,
        },
        Events = {},
        Generate = function(thisWidget: Types.ColorPicker)
            local PickerContainer: Frame = Instance.new("Frame")
            PickerContainer.Name = "ColorPickerContainer"
            PickerContainer.BackgroundTransparency = 1
            PickerContainer.BorderSizePixel = 0
            PickerContainer.Size = UDim2.fromOffset(0, 0)
            PickerContainer.AutomaticSize = Enum.AutomaticSize.XY
            PickerContainer.LayoutOrder = thisWidget.ZIndex

            widgets.UIPadding(PickerContainer, Vector2.new(0, Iris._config.WindowPadding.Y))

            local EditorContainer: Frame = Instance.new("Frame")
            EditorContainer.Name = "EditorContainer"
            EditorContainer.BackgroundTransparency = 1
            EditorContainer.BorderSizePixel = 0
            EditorContainer.Size = UDim2.fromOffset(0, 160)
            EditorContainer.AutomaticSize = Enum.AutomaticSize.X
            EditorContainer.Parent = PickerContainer

            widgets.UIListLayout(EditorContainer, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

            local valuesDetector = GenerateValuesPicker(widgets, EditorContainer)
            local hueDetector = GenerateHuePicker(widgets, EditorContainer)
            GenerateComparer(Iris, widgets, EditorContainer)

            widgets.applyButtonDown(valuesDetector, function()
                DragMouseDown(thisWidget, "Values")
            end)
            widgets.applyButtonDown(hueDetector, function()
                DragMouseDown(thisWidget, "Hue")
            end)

            return PickerContainer
        end,
        GenerateState = function(thisWidget: Types.ColorPicker)
            if thisWidget.state.color == nil then
                thisWidget.state.color = Iris._widgetState(thisWidget, "color", Color3.new(1, 0, 0))
            end
        end,
        Update = function(thisWidget: Types.ColorPicker)
            print("UPDATING WITH ARGUMENTS")
            if thisWidget.arguments.Compare then
                (thisWidget :: any).Instance.EditorContainer.ColorComparer.Visible = true
                UpdateComparer(thisWidget, (thisWidget :: any).Instance.EditorContainer.ColorComparer)
            else
                (thisWidget :: any).Instance.EditorContainer.ColorComparer.Visible = false
            end
        end,
        UpdateState = function(thisWidget: Types.ColorPicker)
            if ActiveDrag == thisWidget then
                return -- should already be constantly updating while dragging.
            end

            local Hue, Sat, Value = Color3.toHSV(thisWidget.state.color.value)
            thisWidget.Hue = Hue == 1 and 0 or Hue
            thisWidget.Saturation = Sat
            thisWidget.Value = Value
            UpdateValuesPicker(thisWidget, (thisWidget :: any).Instance.EditorContainer.ValuesPicker)
            UpdateHuePicker(thisWidget, (thisWidget :: any).Instance.EditorContainer.HuePicker)
            UpdateComparer(thisWidget, (thisWidget :: any).Instance.EditorContainer.ColorComparer)
        end,
        Discard = function(thisWidget: Types.ColorPicker)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)
end
