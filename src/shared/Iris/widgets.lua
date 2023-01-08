--[[
    deciding to not write these widgets with support of ImGui TouchExtraPadding in mind. too much overhead to be worth it.

    CanvasGroup is useless. They dont even have a clipsDescendants property.

    TODO, gradients are cool, add gradient styles and a style flag to enable or disable usage.
        why? instances like buttons with text will have their text affected by gradients, so if gradients are enabled the button needs to have a separate textlabel.
        thats a lot of configuration to do but gradients look so good, its worth it.
]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ICONS = {
    RIGHT_POINTING_TRIANGLE = "\u{25BA}",
    DOWN_POINTING_TRIANGLE = "\u{25BC}",
    MULTIPLICATION_SIGN = "\u{00D7}", -- best approximation for a close X which roblox supports, needs to be scaled about 2x
    BOTTOM_RIGHT_CORNER = "\u{25E2}", -- used in window resize icon in bottom right
    CHECK_MARK = "\u{2713}"
}

local function UIPadding(Parent, PxPadding)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, PxPadding.X)
    UIPadding.PaddingRight = UDim.new(0, PxPadding.X)
    UIPadding.PaddingTop = UDim.new(0, PxPadding.Y)
    UIPadding.PaddingBottom = UDim.new(0, PxPadding.Y)
    UIPadding.Parent = Parent
    return UIPadding
end

local function Folder(Parent)
    local ThisFolder = Instance.new("Folder")
    ThisFolder.Parent = Parent
    return ThisFolder
end

local function UISizeConstraint(Parent, MinSize, MaxSize)
    local UISizeConstraint = Instance.new("UISizeConstraint")
    UISizeConstraint.MinSize = MinSize
    UISizeConstraint.MaxSize = MaxSize
    UISizeConstraint.Parent = Parent
    return UISizeConstraint
end

local function UIListLayout(Parent, FillDirection, Padding)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = Padding
    UIListLayout.FillDirection = FillDirection
    UIListLayout.Parent = Parent
    return UIListLayout
end

local function UICorner(Parent, PxRounding)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, PxRounding)
    UICorner.Parent = Parent
    return UICorner
end

return function(Iris)

local function applyTextStyle(thisInstance)
    thisInstance.Font = Iris._style.TextFont
    thisInstance.TextSize = Iris._style.TextSize
    thisInstance.TextColor3 = Iris._style.TextColor
    thisInstance.TextTransparency = Iris._style.TextTransparency
    thisInstance.TextXAlignment = Enum.TextXAlignment.Left

    thisInstance.AutoLocalize = false
    thisInstance.RichText = false
end

local function applyInteractionHighlights(Button, Highlightee, Colors, Mode: "Text" | "Background" | nil)
    local exitedButton = false
    Button.MouseEnter:Connect(function()
        if Mode == "Text" then
            Highlightee.TextColor3 = Colors.ButtonHoveredColor
            Highlightee.TextTransparency = Colors.ButtonHoveredTransparency
        else
            Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
            Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
        end
        exitedButton = false
    end)

    Button.MouseLeave:Connect(function()
        if Mode == "Text" then
            Highlightee.TextColor3 = Colors.ButtonColor
            Highlightee.TextTransparency = Colors.ButtonTransparency
        else
            Highlightee.BackgroundColor3 = Colors.ButtonColor
            Highlightee.BackgroundTransparency = Colors.ButtonTransparency
        end
        exitedButton = true
    end)

    Button.InputBegan:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        if Mode == "Text" then
            Highlightee.TextColor3 = Colors.ButtonActiveColor
            Highlightee.TextTransparency = Colors.ButtonActiveTransparency
        else
            Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
            Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
        end
    end)

    Button.InputEnded:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Mode == "Text" then
                Highlightee.TextColor3 = Colors.ButtonHoveredColor
                Highlightee.TextTransparency = Colors.ButtonHoveredTransparency
            else
                Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
                Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
            end
        end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            if Mode == "Text" then
                Highlightee.TextColor3 = Colors.ButtonColor
                Highlightee.TextTransparency = Colors.ButtonTransparency
            else
                Highlightee.BackgroundColor3 = Colors.ButtonColor
                Highlightee.BackgroundTransparency = Colors.ButtonTransparency
            end
        end
    end)
    
    Button.SelectionImageObject = Iris.SelectionImageObject
end

local function applyFrameStyle(thisInstance, forceNoPadding)
    -- padding, border, and rounding
    local FramePadding = Iris._style.FramePadding
    local FrameBorderTransparency = Iris._style.ButtonTransparency
    local FrameBorderSize = Iris._style.FrameBorderSize
    local FrameBorderColor = Iris._style.BorderColor
    local FrameRounding = Iris._style.FrameRounding
    

    if FrameBorderSize > 0 and FrameRounding > 0 then
        thisInstance.BorderSizePixel = 0

        local UIStroke = Instance.new("UIStroke")
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round
        UIStroke.Transparency = FrameBorderTransparency
        UIStroke.Thickness = FrameBorderSize
        UIStroke.Color = FrameBorderColor

        UICorner(thisInstance, FrameRounding)
        UIStroke.Parent = thisInstance

        if not forceNoPadding then
            UIPadding(thisInstance, Iris._style.FramePadding)
        end
    elseif FrameBorderSize < 1 and FrameRounding > 0 then
        thisInstance.BorderSizePixel = 0

        UICorner(thisInstance, FrameRounding)
        if not forceNoPadding then
            UIPadding(thisInstance, Iris._style.FramePadding)
        end
    elseif FrameRounding < 1 then
        thisInstance.BorderSizePixel = FrameBorderSize
        thisInstance.BorderColor3 = FrameBorderColor
        thisInstance.BorderMode = Enum.BorderMode.Inset

        if not forceNoPadding then
            UIPadding(thisInstance, FramePadding - Vector2.new(FrameBorderSize, FrameBorderSize))
        else
            UIPadding(thisInstance, -Vector2.new(FrameBorderSize, FrameBorderSize))
        end
    end
end

local function commonButton()
    local Button = Instance.new("TextButton")
    Button.Name = "Iris_Button"
    Button.Size = UDim2.fromOffset(0, 0)
    Button.BackgroundColor3 = Iris._style.ButtonColor
    Button.BackgroundTransparency = Iris._style.ButtonTransparency
    Button.AutoButtonColor = false

    applyTextStyle(Button)
    Button.AutomaticSize = Enum.AutomaticSize.XY

    applyFrameStyle(Button)

    applyInteractionHighlights(Button, Button, {
        ButtonColor = Iris._style.ButtonColor,
        ButtonTransparency = Iris._style.ButtonTransparency,
        ButtonHoveredColor = Iris._style.ButtonHoveredColor,
        ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
        ButtonActiveColor = Iris._style.ButtonActiveColor,
        ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
    })
    return Button
end

local function discardState(thisWidget)
    for i,state in thisWidget.state do
        state.ConnectedWidgets[thisWidget.ID] = nil
    end
end

-- widgets

Iris.WidgetConstructor("Root", false, true){
    Args = {},
    Generate = function(thisWidget)
        local Root = Instance.new("Folder")
        Root.Name = "Iris_Root"

        local PseudoWindowScreenGui = Instance.new("ScreenGui")
        PseudoWindowScreenGui.Name = "PseudoWindowScreenGui"
        PseudoWindowScreenGui.Parent = Root
        PseudoWindowScreenGui.ResetOnSpawn = false

        local PseudoWindow = Instance.new("Frame")
        PseudoWindow.Name = "PseudoWindow"
        PseudoWindow.Size = UDim2.new(0, 0, 0, 0)
        PseudoWindow.Position = UDim2.fromOffset(0, 22)
        PseudoWindow.BorderSizePixel = Iris._style.WindowBorderSize
        PseudoWindow.BorderColor3 = Iris._style.BorderColor
        PseudoWindow.BackgroundTransparency = Iris._style.WindowBgTransparency
        PseudoWindow.BackgroundColor3 = Iris._style.WindowBgColor
        PseudoWindow.AutomaticSize = Enum.AutomaticSize.XY

        PseudoWindow.Selectable = false
        PseudoWindow.SelectionGroup = true
        PseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

        PseudoWindow.Visible = false
        UIPadding(PseudoWindow, Iris._style.WindowPadding)

        UIListLayout(PseudoWindow, Enum.FillDirection.Vertical, UDim.new(0, Iris._style.ItemSpacing.Y))

        PseudoWindow.Parent = PseudoWindowScreenGui
        
        return Root
    end,
    Update = function(thisWidget)
        if thisWidget.shouldExist then
            thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    GetParentInstance = function(thisWidget, childWidget)
        if childWidget.type == "Window" then
            return thisWidget.Instance
        else
            thisWidget.shouldExist = true
            Iris.widgets["Root"].Update(thisWidget)    
            return thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow
        end
    end
}

Iris.WidgetConstructor("Text", false, false){
    Args = {
        ["Text"] = 1
    },
    Generate = function(thisWidget)
        local Text = Instance.new("TextLabel")
        Text.Name = "Iris_Text"
        Text.Size = UDim2.fromOffset(0, 0)
        Text.BackgroundTransparency = 1
        Text.BorderSizePixel = 0
        Text.ZIndex = thisWidget.ZIndex
        Text.LayoutOrder = thisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY

        applyTextStyle(Text)
        UIPadding(Text, Vector2.new(0, 2)) -- it appears as if this padding is not controlled by any style properties in DearImGui. could change?

        return Text
    end,
    Update = function(thisWidget)
        local Text = thisWidget.Instance
        Text.Text = thisWidget.arguments.Text
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}
Iris.Text = function(args)
    return Iris._Insert("Text", args)
end

Iris.WidgetConstructor("TextWrapped", false, false){
    Args = {
        ["Text"] = 1
    },
    Generate = function(thisWidget)
        local TextWrapped = Instance.new("TextLabel")
        TextWrapped.Name = "Iris_Text"
        TextWrapped.Size = UDim2.new(Iris._style.ItemWidth, UDim.new(0, 0))
        TextWrapped.BackgroundTransparency = 1
        TextWrapped.BorderSizePixel = 0
        TextWrapped.ZIndex = thisWidget.ZIndex
        TextWrapped.LayoutOrder = thisWidget.ZIndex
        TextWrapped.AutomaticSize = Enum.AutomaticSize.Y
        TextWrapped.TextWrapped = true

        applyTextStyle(TextWrapped)
        UIPadding(TextWrapped, Vector2.new(0, 2)) -- it appears as if this padding is not controlled by any style properties in DearImGui. could change?

        return TextWrapped
    end,
    Update = function(thisWidget)
        local TextWrapped = thisWidget.Instance
        TextWrapped.Text = thisWidget.arguments.Text
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}
Iris.TextWrapped = function(args)
    return Iris._Insert("TextWrapped", args)
end

Iris.WidgetConstructor("Button", false, false){
    Args = {
        ["Text"] = 1
    },
    Generate = function(thisWidget)
        local Button = commonButton()
        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex

        Button.MouseButton1Click:Connect(function()
            thisWidget.events.clicked = true
        end)

        return Button
    end,
    Update = function(thisWidget)
        local Button = thisWidget.Instance
        Button.Text = thisWidget.arguments.Text or "Button"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}
Iris.Button = function(args)
    return Iris._Insert("Button", args)
end

Iris.WidgetConstructor("SmallButton", false, false){
    Args = {
        ["Text"] = 1
    },
    Generate = function(thisWidget)
        local SmallButton = commonButton()
        SmallButton.Name = "Iris_SmallButton"
        SmallButton.ZIndex = thisWidget.ZIndex
        SmallButton.LayoutOrder = thisWidget.ZIndex

        SmallButton.MouseButton1Click:Connect(function()
            thisWidget.events.clicked = true
        end)
        local UIPadding = SmallButton.UIPadding
        UIPadding.PaddingLeft = UDim.new(0, 2)
        UIPadding.PaddingRight = UDim.new(0, 2)
        UIPadding.PaddingTop = UDim.new(0, 0)
        UIPadding.PaddingBottom = UDim.new(0, 0)

        return SmallButton
    end,
    Update = function(thisWidget)
        local SmallButton = thisWidget.Instance
        SmallButton.Text = thisWidget.arguments.Text or "SmallButton"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}
Iris.SmallButton = function(args)
    return Iris._Insert("SmallButton", args)
end

Iris.WidgetConstructor("Separator", false, false){
    Args = {},
    Generate = function(thisWidget)
        local Separator = Instance.new("Frame")
        Separator.Name = "Iris_Separator"
        Separator.BorderSizePixel = 0
        if thisWidget.parentWidget.type == "SameLine" then
            Separator.Size = UDim2.new(0, 1, 1, 0)
        else
            Separator.Size = UDim2.new(1, 0, 0, 1)
        end
        Separator.ZIndex = thisWidget.ZIndex
        Separator.LayoutOrder = thisWidget.ZIndex

        Separator.BackgroundColor3 = Iris._style.SeparatorColor
        Separator.BackgroundTransparency = Iris._style.SeparatorTransparency

        UIListLayout(Separator, Enum.FillDirection.Vertical, UDim.new(0,0))
        -- this is to prevent a bug of AutomaticLayout edge case when its parent has automaticLayout enabled

        return Separator
    end,
    Update = function(thisWidget)

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}
Iris.Separator = function(args)
    return Iris._Insert("Separator", args)
end

Iris.WidgetConstructor("Indent", false, true){
    Args = {
        ["Width"] = 1,
    },
    Generate = function(thisWidget)
        local Indent = Instance.new("Frame")
        Indent.Name = "Iris_Indent"
        Indent.BackgroundTransparency = 1
        Indent.BorderSizePixel = 0
        Indent.ZIndex = thisWidget.ZIndex
        Indent.LayoutOrder = thisWidget.ZIndex
        Indent.Size = UDim2.fromScale(1, 0)
        Indent.AutomaticSize = Enum.AutomaticSize.Y

        UIListLayout(Indent, Enum.FillDirection.Vertical, UDim.new(0, Iris._style.ItemSpacing.Y))
        UIPadding(Indent, Vector2.new(0, 0))

        return Indent
    end,
    Update = function(thisWidget)
        local indentWidth
        if thisWidget.arguments.Width then
            indentWidth = thisWidget.arguments.Width
        else
            indentWidth = Iris._style.IndentSpacing
        end
        thisWidget.Instance.UIPadding.PaddingLeft = UDim.new(0, indentWidth)
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    GetParentInstance = function(thisWidget)
        return thisWidget.Instance
    end
}
Iris.Indent = function(args)
    return Iris._Insert("Indent", args)
end

Iris.WidgetConstructor("SameLine", false, true){
    Args = {
        ["Width"] = 1,
        ["VerticalAlignment"] = 2
    },
    Generate = function(thisWidget)
        local SameLine = Instance.new("Frame")
        SameLine.Name = "Iris_SameLine"
        SameLine.BackgroundTransparency = 1
        SameLine.BorderSizePixel = 0
        SameLine.ZIndex = thisWidget.ZIndex
        SameLine.LayoutOrder = thisWidget.ZIndex
        SameLine.Size = UDim2.fromScale(1, 0)
        SameLine.AutomaticSize = Enum.AutomaticSize.Y

        UIListLayout(SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))

        return SameLine
    end,
    Update = function(thisWidget)
        local itemWidth
        local UIListLayout = thisWidget.Instance.UIListLayout
        if thisWidget.arguments.Width then
            itemWidth = thisWidget.arguments.Width
        else
            itemWidth = Iris._style.ItemSpacing.X
        end
        UIListLayout.Padding = UDim.new(0, itemWidth)
        if thisWidget.arguments.VerticalAlignment then
            UIListLayout.VerticalAlignment = thisWidget.arguments.VerticalAlignment
        else
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    GetParentInstance = function(thisWidget)
        return thisWidget.Instance
    end
}
Iris.SameLine = function(args)
    return Iris._Insert("SameLine", args)
end

Iris.WidgetConstructor("Group", false, true){
    Args = {},
    Generate = function(thisWidget)
        local Group = Instance.new("Frame")
        Group.Name = "Iris_Group"
        Group.Size = UDim2.fromOffset(0, 0)
        Group.BackgroundTransparency = 1
        Group.BorderSizePixel = 0
        Group.ZIndex = thisWidget.ZIndex
        Group.LayoutOrder = thisWidget.ZIndex
        Group.AutomaticSize = Enum.AutomaticSize.XY

        local UIListLayout = UIListLayout(Group, Enum.FillDirection.Vertical, UDim.new(0, Iris._style.ItemSpacing.X))

        return Group
    end,
    Update = function(thisWidget)

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    GetParentInstance = function(thisWidget)
        return thisWidget.Instance
    end
}
Iris.Group = function(args)
    return Iris._Insert("Group", args)
end

Iris.WidgetConstructor("Checkbox", true, false){
    Args = {
        ["Text"] = 1
    },
    Generate = function(thisWidget)
        local Checkbox = Instance.new("TextButton")
        Checkbox.Name = "Iris_Checkbox"
        Checkbox.BackgroundTransparency = 1
        Checkbox.BorderSizePixel = 0
        Checkbox.Size = UDim2.fromOffset(0, 0)
        Checkbox.Text = ""
        Checkbox.AutomaticSize = Enum.AutomaticSize.XY
        Checkbox.ZIndex = thisWidget.ZIndex
        Checkbox.AutoButtonColor = false
        Checkbox.LayoutOrder = thisWidget.ZIndex

        local CheckboxBox = Instance.new("TextLabel")
        CheckboxBox.Name = "CheckboxBox"
        CheckboxBox.AutomaticSize = Enum.AutomaticSize.None
        local checkboxSize = Iris._style.TextSize + 2 * Iris._style.FramePadding.Y
        CheckboxBox.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
        CheckboxBox.TextSize = checkboxSize
        CheckboxBox.LineHeight = 1.1
        CheckboxBox.ZIndex = thisWidget.ZIndex + 1
        CheckboxBox.LayoutOrder = thisWidget.ZIndex + 1
        CheckboxBox.Parent = Checkbox
        CheckboxBox.TextColor3 = Iris._style.CheckMarkColor
        CheckboxBox.TextTransparency = Iris._style.CheckMarkTransparency
        CheckboxBox.BackgroundColor3 = Iris._style.FrameBgColor
        CheckboxBox.BackgroundTransparency = Iris._style.FrameBgTransparency
        applyFrameStyle(CheckboxBox, true)

        applyInteractionHighlights(Checkbox, CheckboxBox, {
            ButtonColor = Iris._style.FrameBgColor,
            ButtonTransparency = Iris._style.FrameBgTransparency,
            ButtonHoveredColor = Iris._style.FrameBgHoveredColor,
            ButtonHoveredTransparency = Iris._style.FrameBgHoveredTransparency,
            ButtonActiveColor = Iris._style.FrameBgActiveColor,
            ButtonActiveTransparency = Iris._style.FrameBgActiveTransparency,
        })

        Checkbox.MouseButton1Click:Connect(function()
            local wasChecked = thisWidget.state.isChecked.value
            thisWidget.state.isChecked:Set(not wasChecked)
        end)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        applyTextStyle(TextLabel)
        TextLabel.Position = UDim2.new(0,checkboxSize + Iris._style.ItemInnerSpacing.X, 0.5, 0)
        TextLabel.ZIndex = thisWidget.ZIndex + 1
        TextLabel.LayoutOrder = thisWidget.ZIndex + 1
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.Parent = Checkbox

        return Checkbox
    end,
    Update = function(thisWidget)
        thisWidget.Instance.TextLabel.Text = thisWidget.arguments.Text or "Checkbox"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.isChecked == nil then
            thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
        end
    end,
    UpdateState = function(thisWidget)
        local Checkbox = thisWidget.Instance.CheckboxBox
        if thisWidget.state.isChecked.value then
            Checkbox.Text = ICONS.CHECK_MARK
            thisWidget.events.checked = true
        else
            Checkbox.Text = ""
            thisWidget.events.unchecked = true
        end
    end
}
Iris.Checkbox = function(args, state)
    return Iris._Insert("Checkbox", args, state)
end

Iris.WidgetConstructor("Tree", true, true){
    Args = {
        ["Text"] = 1,
        ["SpanAvailWidth"] = 2
    },
    Generate = function(thisWidget)
        local Tree = Instance.new("Frame")
        Tree.Name = "Iris_Tree"
        Tree.BackgroundTransparency = 1
        Tree.BorderSizePixel = 0
        Tree.ZIndex = thisWidget.ZIndex
        Tree.LayoutOrder = thisWidget.ZIndex
        Tree.Size = UDim2.new(Iris._style.ItemWidth, UDim.new(0, 0))
        Tree.AutomaticSize = Enum.AutomaticSize.Y

        UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

        local ChildContainer = Instance.new("Frame")
        ChildContainer.Name = "ChildContainer"
        ChildContainer.BackgroundTransparency = 1
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = thisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
        ChildContainer.Size = UDim2.fromScale(1, 0)
        ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
        ChildContainer.Visible = false
        ChildContainer.Parent = Tree

        UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._style.ItemSpacing.Y))
        
        local ChildContainerPadding = UIPadding(ChildContainer, Vector2.new(0, 0))
        ChildContainerPadding.PaddingTop = UDim.new(0, Iris._style.ItemSpacing.Y)
        ChildContainerPadding.PaddingLeft = UDim.new(0, Iris._style.IndentSpacing)

        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.BackgroundTransparency = 1
        Header.BorderSizePixel = 0
        Header.ZIndex = thisWidget.ZIndex
        Header.LayoutOrder = thisWidget.ZIndex
        Header.Size = UDim2.fromScale(1, 0)
        Header.AutomaticSize = Enum.AutomaticSize.Y
        Header.Parent = Tree

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex
        Button.AutoButtonColor = false
        Button.Text = ""
        Button.Parent = Header

        applyInteractionHighlights(Button, Header, {
            ButtonColor = Color3.fromRGB(0, 0, 0),
            ButtonTransparency = 1,
            ButtonHoveredColor = Iris._style.HeaderHoveredColor,
            ButtonHoveredTransparency = Iris._style.HeaderHoveredTransparency,
            ButtonActiveColor = Iris._style.HeaderActiveColor,
            ButtonActiveTransparency = Iris._style.HeaderActiveTransparency,
        })

        local ButtonUIListLayout = UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, 0))
        ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local Arrow = Instance.new("TextLabel")
        Arrow.Name = "Arrow"
        Arrow.Size = UDim2.fromOffset(Iris._style.TextSize, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.BorderSizePixel = 0
        Arrow.ZIndex = thisWidget.ZIndex
        Arrow.LayoutOrder = thisWidget.ZIndex
        Arrow.AutomaticSize = Enum.AutomaticSize.Y

        applyTextStyle(Arrow)
        Arrow.TextXAlignment = Enum.TextXAlignment.Center
        Arrow.TextSize = Iris._style.TextSize - 4
        Arrow.Text = ICONS.RIGHT_POINTING_TRIANGLE

        Arrow.Parent = Button

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex
        TextLabel.LayoutOrder = thisWidget.ZIndex
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.Parent = Button
        local TextPadding = UIPadding(TextLabel,Vector2.new(0, 0))
        TextPadding.PaddingRight = UDim.new(0, 21)

        applyTextStyle(TextLabel)

        Button.MouseButton1Click:Connect(function()
            thisWidget.state.isUncollapsed:Set(not thisWidget.state.isUncollapsed.value)
        end)

        return Tree
    end,
    Update = function(thisWidget)
        local Button = thisWidget.Instance.Header.Button
        Button.TextLabel.Text = thisWidget.arguments.Text or "Tree"
        if thisWidget.arguments.SpanAvailWidth then
            Button.AutomaticSize = Enum.AutomaticSize.Y
            Button.Size = UDim2.fromScale(1, 0)
        else
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromScale(0, 0)
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GetParentInstance = function(thisWidget)
        return thisWidget.Instance.ChildContainer
    end,
    UpdateState = function(thisWidget)
        local isUncollapsed = thisWidget.state.isUncollapsed.value
        local Arrow = thisWidget.Instance.Header.Button.Arrow
        local ChildContainer = thisWidget.Instance.ChildContainer
        Arrow.Text = (isUncollapsed and ICONS.DOWN_POINTING_TRIANGLE or ICONS.RIGHT_POINTING_TRIANGLE)

        if isUncollapsed then
            thisWidget.events.uncollapsed = true
        else
            thisWidget.events.collapsed = true
        end

        ChildContainer.Visible = isUncollapsed
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.isUncollapsed == nil then
            thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", false)
        end
    end
}
Iris.Tree = function(args, state)
    return Iris._Insert("Tree", args, state)
end

Iris.WidgetConstructor("InputNum", true, false){
    Args = {
        ["Text"] = 1,
        ["Increment"] = 2,
        ["Min"] = 3,
        ["Max"] = 4,
        ["Format"] = 5,
        ["NoButtons"] = 6,
        ["NoField"] = 7
    },
    Generate = function(thisWidget)
        local InputNum = Instance.new("Frame")
        InputNum.Name = "Iris_InputNum"
        InputNum.Size = UDim2.new(Iris._style.ItemWidth, UDim.new(0, 0))
        InputNum.BackgroundTransparency = 1
        InputNum.BorderSizePixel = 0
        InputNum.ZIndex = thisWidget.ZIndex
        InputNum.LayoutOrder = thisWidget.ZIndex
        InputNum.AutomaticSize = Enum.AutomaticSize.Y
        UIListLayout(InputNum, Enum.FillDirection.Horizontal, UDim.new(0, Iris._style.ItemInnerSpacing.X))

        local inputButtonsWidth = Iris._style.TextSize
        local textLabelHeight = inputButtonsWidth + Iris._style.FramePadding.Y * 2

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        applyFrameStyle(InputField)
        applyTextStyle(InputField)
        InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._style.ItemInnerSpacing.X)
        InputField.ZIndex = thisWidget.ZIndex + 1
        InputField.LayoutOrder = thisWidget.ZIndex + 1
        InputField.AutomaticSize = Enum.AutomaticSize.Y
        InputField.BackgroundColor3 = Iris._style.FrameBgColor
        InputField.BackgroundTransparency = Iris._style.FrameBgTransparency
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.Parent = InputNum

        InputField.FocusLost:Connect(function()
            local newValue = tonumber(InputField.Text)
            if newValue ~= nil then
                newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                thisWidget.state.number:Set(newValue)
                thisWidget.events.numberChanged = true
            else
                InputField.Text = thisWidget.state.number.value
            end
        end)

        local SubButton = commonButton()
        SubButton.Name = "SubButton"
        SubButton.ZIndex = thisWidget.ZIndex + 2
        SubButton.LayoutOrder = thisWidget.ZIndex + 2
        SubButton.TextXAlignment = Enum.TextXAlignment.Center
        SubButton.Text = "-"
        SubButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
        SubButton.Parent = InputNum

        SubButton.MouseButton1Click:Connect(function()
            local newValue = thisWidget.state.number.value - (thisWidget.arguments.Increment or 1)
            newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
            thisWidget.state.number:Set(newValue)
            thisWidget.events.numberChanged = true
        end)

        local AddButton = commonButton()
        AddButton.Name = "AddButton"
        AddButton.ZIndex = thisWidget.ZIndex + 3
        AddButton.LayoutOrder = thisWidget.ZIndex + 3
        AddButton.TextXAlignment = Enum.TextXAlignment.Center
        AddButton.Text = "+"
        AddButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
        AddButton.Parent = InputNum

        AddButton.MouseButton1Click:Connect(function()
            local newValue = thisWidget.state.number.value + (thisWidget.arguments.Increment or 1)
            newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
            thisWidget.state.number:Set(newValue)
            thisWidget.events.numberChanged = true
        end)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex + 4
        TextLabel.LayoutOrder = thisWidget.ZIndex + 4
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        applyTextStyle(TextLabel)
        TextLabel.Parent = InputNum

        return InputNum
    end,
    Update = function(thisWidget)
        local TextLabel = thisWidget.Instance.TextLabel
        TextLabel.Text = thisWidget.arguments.Text or "InputNum"

        thisWidget.Instance.SubButton.Visible = not thisWidget.arguments.NoButtons
        thisWidget.Instance.AddButton.Visible = not thisWidget.arguments.NoButtons
        local InputField = thisWidget.Instance.InputField
        InputField.Visible = not thisWidget.arguments.NoField

        local inputButtonsTotalWidth = Iris._style.TextSize * 2 + Iris._style.ItemInnerSpacing.X * 2 + Iris._style.WindowPadding.X + 4
        if thisWidget.arguments.NoButtons then
            InputField.Size = UDim2.new(1, 0, 0, 0)
        else
            InputField.Size = UDim2.new(1, -inputButtonsTotalWidth, 0, 0)
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.number == nil then
            thisWidget.state.number = Iris._widgetState(thisWidget, "number", 0)
        end
    end,
    UpdateState = function(thisWidget)
        local InputField = thisWidget.Instance.InputField
        InputField.Text = string.format(thisWidget.arguments.Format or "%f", thisWidget.state.number.value)
    end
}
Iris.InputNum = function(args, state)
    return Iris._Insert("InputNum", args, state)
end

Iris.WidgetConstructor("InputText", true, false){
    Args = {
        ["Text"] = 1,
        ["TextHint"] = 2
    },
    Generate = function(thisWidget)
        local textLabelHeight = Iris._style.TextSize

        local InputText = Instance.new("Frame")
        InputText.Name = "Iris_InputText"
        InputText.Size = UDim2.new(Iris._style.ItemWidth, UDim.new(0, 0))
        InputText.BackgroundTransparency = 1
        InputText.BorderSizePixel = 0
        InputText.ZIndex = thisWidget.ZIndex
        InputText.LayoutOrder = thisWidget.ZIndex
        InputText.AutomaticSize = Enum.AutomaticSize.Y
        UIListLayout(InputText, Enum.FillDirection.Horizontal, UDim.new(0, Iris._style.ItemInnerSpacing.X))

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        applyFrameStyle(InputField)
        applyTextStyle(InputField)
        InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._style.ItemInnerSpacing.X)
        InputField.UIPadding.PaddingRight = UDim.new(0, 0)
        InputField.ZIndex = thisWidget.ZIndex + 1
        InputField.LayoutOrder = thisWidget.ZIndex + 1
        InputField.AutomaticSize = Enum.AutomaticSize.Y
        InputField.Size = UDim2.new(Iris._style.ItemWidth, UDim.new(0, 0))
        InputField.BackgroundColor3 = Iris._style.FrameBgColor
        InputField.BackgroundTransparency = Iris._style.FrameBgTransparency
        InputField.ClearTextOnFocus = false
        InputField.Text = ""
        InputField.PlaceholderColor3 = Iris._style.TextDisabledColor
        InputField.TextTruncate = Enum.TextTruncate.AtEnd

        InputField.FocusLost:Connect(function()
            thisWidget.state.text:Set(InputField.Text)
            thisWidget.events.textChanged = true
        end)

        InputField.Parent = InputText

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Position = UDim2.new(1, Iris._style.ItemInnerSpacing.X, 0, 0)
        TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex + 2
        TextLabel.LayoutOrder = thisWidget.ZIndex + 2
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        applyTextStyle(TextLabel)
        TextLabel.Parent = InputText

        return InputText
    end,
    Update = function(thisWidget)
        local TextLabel = thisWidget.Instance.TextLabel
        TextLabel.Text = thisWidget.arguments.Text or "Input Text"

        thisWidget.Instance.InputField.PlaceholderText = thisWidget.arguments.TextHint or ""
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.text == nil then
            thisWidget.state.text = Iris._widgetState(thisWidget, "text", "")
        end
    end,
    UpdateState = function(thisWidget)
        thisWidget.Instance.InputField.Text = thisWidget.state.text.value
    end
}
Iris.InputText = function(args, state)
    return Iris._Insert("InputText", args, state)
end

do -- Window
    local windowDisplayOrder = 0
    local dragWindow
    local isDragging = false
    local moveDeltaCursorPosition

    local resizeWindow
    local isResizing = false
    local resizeDeltaCursorPosition

    local focusedWindow
    local anyFocusedWindow = false

    local windowWidgets = {}

    local function getWindows()
        return windowWidgets
    end

    local function quickSwapWindows()
        -- ctrl + tab swapping functionality
        local oldWindows = getWindows()

        local highest = -math.huge
        local secondHighest = -math.huge
        local secondHighestWidget = 0

        for i,v in oldWindows do
            if v.state.isOpened.value and (not v.arguments.NoNav) then
                local value = v.Instance.DisplayOrder
                if value > highest then
                    secondHighest = highest
                    highest = value
                elseif value > secondHighest then
                    secondHighest = value
                    secondHighestWidget = v
                end
            end
        end
        local SelectedWindow = secondHighestWidget

        if SelectedWindow.state.isUncollapsed.value == false then
            SelectedWindow.state.isUncollapsed:Set(true)
        end
        Iris.SetFocusedWindow(SelectedWindow)
    end

    Iris.SetFocusedWindow = function(thisWidget: table | nil)
        if focusedWindow == thisWidget then return end

        if anyFocusedWindow then
            if getWindows()[focusedWindow.ID] ~= nil then
                -- update appearance to unfocus
                local TitleBar = focusedWindow.Instance.WindowButton.TitleBar
                if focusedWindow.state.isUncollapsed.value then
                    TitleBar.BackgroundColor3 = Iris._style.TitleBgColor
                    TitleBar.BackgroundTransparency = Iris._style.TitleBgTransparency
                else
                    TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                    TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
                end
                focusedWindow.Instance.WindowButton.UIStroke.Color = Iris._style.BorderColor
            end

            anyFocusedWindow = false
            focusedWindow = nil
        end

        if thisWidget ~= nil then
            -- update appearance to focus
            anyFocusedWindow = true
            focusedWindow = thisWidget
            local TitleBar = focusedWindow.Instance.WindowButton.TitleBar
            TitleBar.BackgroundColor3 = Iris._style.TitleBgActiveColor
            TitleBar.BackgroundTransparency = Iris._style.TitleBgActiveTransparency
            focusedWindow.Instance.WindowButton.UIStroke.Color = Iris._style.BorderActiveColor
            
            windowDisplayOrder += 1
            focusedWindow.Instance.DisplayOrder = windowDisplayOrder

            if thisWidget.state.isUncollapsed.value == false then
                thisWidget.state.isUncollapsed:Set(true)
            end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 then
            Iris.SetFocusedWindow(nil)
        end
        if input.KeyCode == Enum.KeyCode.ButtonX then
            -- gamepadMenuStartOpenedDt = os.clock()
            -- if os.clock() - gamepadMenuLastEndedDt > GAMEPAD_MENU_START_HOLD_TIME then
            --     task.delay(GAMEPAD_MENU_START_HOLD_TIME, function()
            --         if os.clock() - gamepadMenuLastEndedDt > GAMEPAD_MENU_START_HOLD_TIME then
            --             gamepadMenuBehavior(true)
            --         end
            --     end)
            -- end
        end

        if input.KeyCode == Enum.KeyCode.Tab and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            quickSwapWindows()
        end
        if input.KeyCode == Enum.KeyCode.RightShift then
            quickSwapWindows()
        end

        -- if gamepadMenuOpened then
        --     if input.KeyCode == Enum.KeyCode.ButtonL1 then
        --         setGamepadMenuSelectedWindowIndex((gamepadMenuSelectedWindowIndex - 2) % #gamepadMenuWindows + 1)
        --     end
        --     if input.KeyCode == Enum.KeyCode.ButtonR1 then
        --         setGamepadMenuSelectedWindowIndex(gamepadMenuSelectedWindowIndex % #gamepadMenuWindows + 1)
        --     end
        -- end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging then
            local mouseLocation = UserInputService:GetMouseLocation()
            local dragInstance = dragWindow.Instance.WindowButton
            local newPosX, newPosY =
            math.min(
                math.max(mouseLocation.X - moveDeltaCursorPosition.X, Iris._style.WindowBorderSize),
                dragWindow.Instance.AbsoluteSize.X - dragInstance.AbsoluteSize.X - Iris._style.WindowBorderSize
            ),
            math.min(
                math.max(mouseLocation.Y - moveDeltaCursorPosition.Y, Iris._style.WindowBorderSize),
                dragWindow.Instance.AbsoluteSize.Y - dragInstance.AbsoluteSize.Y - Iris._style.WindowBorderSize
            )

            dragInstance.Position = UDim2.fromOffset(newPosX, newPosY)
        end
        if isResizing then
            local resizeInstance = resizeWindow.Instance.WindowButton

            local windowSize = Vector2.new(resizeInstance.Position.X.Offset, resizeInstance.Position.Y.Offset)
            local minWindowSize = (Iris._style.TextSize + Iris._style.FramePadding.Y * 2) * 2
            local maxWindowSize = (
                resizeWindow.Instance.AbsoluteSize -
                windowSize -
                Vector2.new(Iris._style.WindowBorderSize, Iris._style.WindowBorderSize)
            )

            local mouseLocation = UserInputService:GetMouseLocation()
            local newSize = (mouseLocation - windowSize) - Vector2.new(0, 36) - resizeDeltaCursorPosition
            newSize = Vector2.new(
                math.clamp(newSize.X, minWindowSize, maxWindowSize.X),
                math.clamp(newSize.Y, minWindowSize, maxWindowSize.Y)
            )
            resizeInstance.Size = UDim2.fromOffset(newSize.X, newSize.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            local dragInstance = dragWindow.Instance.WindowButton
            isDragging = false
            dragWindow.state.position:Set(Vector2.new(dragInstance.Position.X.Offset, dragInstance.Position.Y.Offset))
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
            isResizing = false
            resizeWindow.state.size:Set(resizeWindow.Instance.WindowButton.AbsoluteSize)
        end

        if input.KeyCode == Enum.KeyCode.ButtonX then
            -- gamepadMenuLastEndedDt = os.clock()
            -- if os.clock() - gamepadMenuStartOpenedDt <= GAMEPAD_MENU_START_HOLD_TIME then
            --     quickSwapWindows()
            -- else
            --     if gamepadMenuOpened then
            --         gamepadMenuBehavior(false)
            --     end
            -- end
        end
    end)

    Iris.WidgetConstructor("Window", true, true){
        Args = {
            ["Title"] = 1,
            ["NoTitleBar"] = 2,
            ["NoBackground"] = 3,
            ["NoCollapse"] = 4,
            ["NoClose"] = 5,
            ["NoMove"] = 6,
            ["NoScrollbar"] = 7,
            ["NoResize"] = 8,
            ["NoNav"] = 9,
        },
        Generate = function(thisWidget)
            windowWidgets[thisWidget.ID] = thisWidget

            local Window = Instance.new("ScreenGui")
            Window.Name = "Iris_Window"
            Window.ResetOnSpawn = false

            local WindowButton = Instance.new("TextButton")
            WindowButton.Name = "WindowButton"
            WindowButton.BackgroundTransparency = 1
            WindowButton.BorderSizePixel = 0
            WindowButton.ZIndex = thisWidget.ZIndex
            WindowButton.LayoutOrder = thisWidget.ZIndex
            WindowButton.Size = UDim2.fromOffset(0, 0)
            WindowButton.AutomaticSize = Enum.AutomaticSize.None
            WindowButton.ClipsDescendants = false
            WindowButton.Text = ""
            WindowButton.AutoButtonColor = false
            WindowButton.Active = false
            WindowButton.Selectable = false
            WindowButton.SelectionImageObject = Iris.SelectionImageObject
            WindowButton.Parent = Window

            WindowButton.SelectionGroup = true
            WindowButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
            
            WindowButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then return end
                if thisWidget.state.isUncollapsed.value then
                    Iris.SetFocusedWindow(thisWidget)
                end
                if not thisWidget.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragWindow = thisWidget
                    isDragging = true
                    moveDeltaCursorPosition = UserInputService:GetMouseLocation() - thisWidget.state.position.value
                end
            end)

            local UIStroke = Instance.new("UIStroke")
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
            UIStroke.Color = Iris._style.BorderColor
            UIStroke.Thickness = Iris._style.WindowBorderSize

            UIStroke.Parent = WindowButton

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.Position = UDim2.fromOffset(0, 0)
            ChildContainer.BorderSizePixel = 0
            ChildContainer.ZIndex = thisWidget.ZIndex + 1
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
            ChildContainer.AutomaticSize = Enum.AutomaticSize.None
            ChildContainer.Size = UDim2.fromScale(1, 1)
            ChildContainer.Selectable = false

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._style.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._style.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0, 1)
            
            ChildContainer.BackgroundColor3 = Iris._style.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
            ChildContainer.Parent = WindowButton

            UIPadding(ChildContainer, Iris._style.WindowPadding)

            local TerminatingFrame = Instance.new("Frame")
            TerminatingFrame.Name = "TerminatingFrame"
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.Size = UDim2.fromOffset(0, Iris._style.WindowPadding.Y + Iris._style.FramePadding.Y)
            TerminatingFrame.Parent = ChildContainer

            local ChildContainerUIListLayout = UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._style.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local TitleBar = Instance.new("Frame")
            TitleBar.Name = "TitleBar"
            TitleBar.BorderSizePixel = 0
            TitleBar.ZIndex = thisWidget.ZIndex
            TitleBar.LayoutOrder = thisWidget.ZIndex
            TitleBar.AutomaticSize = Enum.AutomaticSize.Y
            TitleBar.Size = UDim2.fromScale(1, 0)
            TitleBar.ClipsDescendants = true
            TitleBar.Parent = WindowButton

            local TitleButtonSize = Iris._style.TextSize + ((Iris._style.FramePadding.Y - 1) * 2)

            local CollapseArrow = Instance.new("TextButton")
            CollapseArrow.Name = "CollapseArrow"
            CollapseArrow.Size = UDim2.fromOffset(TitleButtonSize,TitleButtonSize)
            CollapseArrow.Position = UDim2.new(0, Iris._style.FramePadding.X + 1, 0.5, 0)
            CollapseArrow.AnchorPoint = Vector2.new(0, 0.5)
            CollapseArrow.AutoButtonColor = false
            CollapseArrow.BackgroundTransparency = 1
            CollapseArrow.BorderSizePixel = 0
            CollapseArrow.ZIndex = thisWidget.ZIndex + 3
            CollapseArrow.AutomaticSize = Enum.AutomaticSize.None
            applyTextStyle(CollapseArrow)
            CollapseArrow.TextXAlignment = Enum.TextXAlignment.Center
            CollapseArrow.TextSize = Iris._style.TextSize
            CollapseArrow.Parent = TitleBar

            CollapseArrow.MouseButton1Click:Connect(function()
                thisWidget.state.isUncollapsed:Set(not thisWidget.state.isUncollapsed.value)
            end)

            UICorner(CollapseArrow, 1e9)

            applyInteractionHighlights(CollapseArrow, CollapseArrow, {
                ButtonColor = Iris._style.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._style.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._style.ButtonActiveColor,
                ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
            })

            local CloseIcon = Instance.new("TextButton")
            CloseIcon.Name = "CloseIcon"
            CloseIcon.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CloseIcon.Position = UDim2.new(1, -(Iris._style.FramePadding.X + 1), 0.5, 0)
            CloseIcon.AnchorPoint = Vector2.new(1, 0.5)
            CloseIcon.AutoButtonColor = false
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.BorderSizePixel = 0
            CloseIcon.ZIndex = thisWidget.ZIndex + 3
            CloseIcon.AutomaticSize = Enum.AutomaticSize.None
            applyTextStyle(CloseIcon)
            CloseIcon.TextXAlignment = Enum.TextXAlignment.Center
            CloseIcon.Font = Enum.Font.Code
            CloseIcon.TextSize = Iris._style.TextSize * 2
            CloseIcon.Text = ICONS.MULTIPLICATION_SIGN
            CloseIcon.Parent = TitleBar

            UICorner(CloseIcon, 1e9)

            CloseIcon.MouseButton1Click:Connect(function()
                thisWidget.state.isOpened:Set(false)
            end)

            applyInteractionHighlights(CloseIcon, CloseIcon, {
                ButtonColor = Iris._style.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._style.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._style.ButtonActiveColor,
                ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
            })

            -- omitting some style functionality compared to Dear ImGui
            -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.
            -- choosing which side to place the collapse icon may be useful, but implimenting it "elegantly" adds 4 more instances.

            local Title = Instance.new("TextLabel")
            Title.Name = "Title"
            Title.BorderSizePixel = 0
            Title.BackgroundTransparency = 1
            Title.ZIndex = thisWidget.ZIndex + 2
            Title.AutomaticSize = Enum.AutomaticSize.XY
            applyTextStyle(Title)
            Title.Parent = TitleBar
            local TitleAlign
            if Iris._style.WindowTitleAlign == Enum.LeftRight.Left then
                TitleAlign = 0
            elseif Iris._style.WindowTitleAlign == Enum.LeftRight.Center then
                TitleAlign = 0.5
            else
                TitleAlign = 1
            end
            print(TitleAlign)
            print(Iris._style.WindowTitleAlign)
            Title.Position = UDim2.fromScale(TitleAlign, 0)
            Title.AnchorPoint = Vector2.new(TitleAlign, 0)

            UIPadding(Title, Iris._style.FramePadding)

            local ResizeButtonSize = Iris._style.TextSize + Iris._style.FramePadding.X

            local ResizeGrip = Instance.new("TextButton")
            ResizeGrip.Name = "ResizeGrip"
            ResizeGrip.AnchorPoint = Vector2.new(1, 1)
            ResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            ResizeGrip.AutoButtonColor = false
            ResizeGrip.BorderSizePixel = 0
            ResizeGrip.BackgroundTransparency = 1
            ResizeGrip.Text = ICONS.BOTTOM_RIGHT_CORNER
            ResizeGrip.ZIndex = thisWidget.ZIndex + 2
            ResizeGrip.Position = UDim2.fromScale(1, 1)
            ResizeGrip.TextSize = ResizeButtonSize
            ResizeGrip.TextColor3 = Iris._style.ButtonColor
            ResizeGrip.TextTransparency = Iris._style.ButtonTransparency
            ResizeGrip.LineHeight = 1.10 -- fix mild rendering issue
            ResizeGrip.Selectable = false
            
            applyInteractionHighlights(ResizeGrip, ResizeGrip, {
                ButtonColor = Iris._style.ButtonColor,
                ButtonTransparency = Iris._style.ButtonTransparency,
                ButtonHoveredColor = Iris._style.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._style.ButtonActiveColor,
                ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
            }, "Text")

            ResizeGrip.MouseButton1Down:Connect(function()
                if not anyFocusedWindow or not (focusedWindow == thisWidget) then
                    Iris.SetFocusedWindow(thisWidget)
                    -- mitigating wrong focus when clicking on buttons inside of a window without clicking the window itself
                end
                isResizing = true
                resizeWindow = thisWidget
                resizeDeltaCursorPosition = UserInputService:GetMouseLocation() - thisWidget.state.position.value - thisWidget.state.size.value - Vector2.new(0, 36)
            end)

            ResizeGrip.Parent = WindowButton

            return Window
        end,
        Update = function(thisWidget)
            local WindowButton = thisWidget.Instance.WindowButton
            local TitleBar = WindowButton.TitleBar
            local Title = TitleBar.Title
            local ChildContainer = WindowButton.ChildContainer
            local ResizeGrip = WindowButton.ResizeGrip
            local TitleBarWidth = Iris._style.TextSize + Iris._style.FramePadding.Y * 2

            ResizeGrip.Visible = not thisWidget.arguments.NoResize
            if thisWidget.arguments.NoScrollbar then
                ChildContainer.ScrollBarThickness = 0
            else
                ChildContainer.ScrollBarThickness = Iris._style.ScrollbarSize
            end
            if thisWidget.arguments.NoTitleBar then
                TitleBar.Visible = false
                ChildContainer.Size = UDim2.new(1, 0, 1, 0)
                ChildContainer.CanvasSize = UDim2.new(0, 0, 1, 0)
                ChildContainer.Position = UDim2.fromOffset(0, 0)
            else
                TitleBar.Visible = true
                ChildContainer.Size = UDim2.new(1, 0, 1, -TitleBarWidth)
                ChildContainer.CanvasSize = UDim2.new(0, 0, 1, -TitleBarWidth)
                ChildContainer.Position = UDim2.fromOffset(0, TitleBarWidth)
            end
            if thisWidget.arguments.NoBackground then
                ChildContainer.BackgroundTransparency = 1
            else
                ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
            end
            local TitleButtonPaddingSize = Iris._style.FramePadding.X + Iris._style.TextSize + Iris._style.FramePadding.X * 2
            if thisWidget.arguments.NoCollapse then
                TitleBar.CollapseArrow.Visible = false
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, Iris._style.FramePadding.X)
            else
                TitleBar.CollapseArrow.Visible = true
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, TitleButtonPaddingSize)
            end
            if thisWidget.arguments.NoClose then
                TitleBar.CloseIcon.Visible = false
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, Iris._style.FramePadding.X)
            else
                TitleBar.CloseIcon.Visible = true
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, TitleButtonPaddingSize)
            end

            Title.Text = thisWidget.arguments.Title or ""
        end,
        Discard = function(thisWidget)
            if focusedWindow == thisWidget then
                focusedWindow = nil
                anyFocusedWindow = false
            end
            if dragWindow == thisWidget then
                dragWindow = nil
                isDragging = false
            end
            if resizeWindow == thisWidget then
                resizeWindow = nil
                isResizing = false
            end
            windowWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()
            discardState(thisWidget)
        end,
        GetParentInstance = function(thisWidget)
            return thisWidget.Instance.WindowButton.ChildContainer
        end,
        UpdateState = function(thisWidget)
            local stateSize = thisWidget.state.size.value
            local statePosition = thisWidget.state.position.value
            local stateIsUncollapsed = thisWidget.state.isUncollapsed.value
            local stateIsOpened = thisWidget.state.isOpened.value

            local WindowButton = thisWidget.Instance.WindowButton

            WindowButton.Size = UDim2.fromOffset(stateSize.X, stateSize.Y)
            WindowButton.Position = UDim2.fromOffset(statePosition.X, statePosition.Y)

            local TitleBar = WindowButton.TitleBar
            local ChildContainer = WindowButton.ChildContainer
            local ResizeGrip = WindowButton.ResizeGrip

            if stateIsOpened then
                thisWidget.Instance.Enabled = true
                thisWidget.events.opened = true
            else
                thisWidget.Instance.Enabled = false
                thisWidget.events.closed = true
            end

            if stateIsUncollapsed then
                TitleBar.CollapseArrow.Text = ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = true
                if thisWidget.arguments.NoResize == false then
                    ResizeGrip.Visible = true
                end
                WindowButton.AutomaticSize = Enum.AutomaticSize.None
                thisWidget.events.uncollapsed = true
            else
                local collapsedHeight = Iris._style.TextSize + Iris._style.FramePadding.Y * 2
                TitleBar.CollapseArrow.Text = ICONS.RIGHT_POINTING_TRIANGLE

                ChildContainer.Visible = false
                ResizeGrip.Visible = false
                WindowButton.Size = UDim2.fromOffset(stateSize.X, collapsedHeight)
                thisWidget.events.collapsed = true
            end

            if stateIsOpened and stateIsUncollapsed then
                Iris.SetFocusedWindow(thisWidget)
            else
                TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
                WindowButton.UIStroke.Color = Iris._style.BorderColor

                Iris.SetFocusedWindow(nil)
            end
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.size == nil then
                thisWidget.state.size = Iris._widgetState(thisWidget, "size", Vector2.new(400, 300))
            end
            if thisWidget.state.position == nil then
                thisWidget.state.position = Iris._widgetState(
                    thisWidget,
                    "position", 
                    if anyFocusedWindow then focusedWindow.state.position.value + Vector2.new(15, 45) else Vector2.new(150, 250)
                )
            end
            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", true)
            end
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", true)
            end
        end
    }
    Iris.Window = function(args, state)
        return Iris._Insert("Window", args, state)
    end
end

end