--[[
    Making a concious decision to not write these widgets with support of ImGui TouchExtraPadding in mind. too much overhead to be worth it atm.

    TODO, all of these widgets need to have .SelectionOrder and .Selectable configured at some point

    TODO, once CanvasGroup instance is out of beta, consider its use in optimizing several of these widget structures, i think they will make Window rounding viable

    TODO, gradients are cool as shit, add gradient styles and a style flag to enable or disable usage.
        why? instances like buttons with text will have their text affected by gradients, so if gradients are enabled the button needs to have a separate textlabel.
        thats a lot of configuration to do but holy shit gradients look good, its worth it.
]]

local function PadInstance(PadParent, PxPadding)
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0,PxPadding.X)
    Padding.PaddingRight = UDim.new(0,PxPadding.X)
    Padding.PaddingTop = UDim.new(0,PxPadding.Y)
    Padding.PaddingBottom = UDim.new(0,PxPadding.Y)
    Padding.Parent = PadParent
    return Padding
end

local function SizeConstraint(Parent, MinSize, MaxSize)
    local UISizeConstraint = Instance.new("UISizeConstraint")
    UISizeConstraint.MinSize = MinSize
    UISizeConstraint.MaxSize = MaxSize
    UISizeConstraint.Parent = Parent
    return UISizeConstraint
end

local function RoundInstance(RoundParent, PxRounding)
    local Rounding = Instance.new("UICorner")
    Rounding.CornerRadius = UDim.new(0, PxRounding)
    Rounding.Parent = RoundParent
    return Rounding
end

local function ApplyTextStyle(Iris, TextParent)
    TextParent.Font = Iris._style.Font
    TextParent.TextSize = Iris._style.FontSize
    TextParent.TextColor3 = Iris._style.TextColor
    TextParent.TextTransparency = Iris._style.TextTransparency

    TextParent.AutoLocalize = false
    TextParent.RichText = false
end

local function ApplyInteractionHighlights(Iris, Button, Highlightee, Colors)
    Button.MouseEnter:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
        Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
    end)

    Button.MouseLeave:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonColor
        Highlightee.BackgroundTransparency = Colors.ButtonTransparency
    end)

    Button.MouseButton1Down:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
        Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
    end)

    Button.MouseButton1Up:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
        Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
    end)
end

local function TitleBarButton(Iris, ThisWidget, ButtonParent)
    local TitleBarButton = Instance.new("TextButton")
    TitleBarButton.AutoButtonColor = false
    TitleBarButton.BorderSizePixel = 0
    TitleBarButton.BackgroundTransparency = 1
    TitleBarButton.Position = UDim2.fromScale(.5, .5)
    TitleBarButton.AnchorPoint = Vector2.new(.5,.5)
    local TitleBarButtonSize = Iris._style.FontSize + (Iris._style.FramePadding.Y-1) * 2 -- this is bigger than Dear ImGui's. Intentionally.
    TitleBarButton.Size = UDim2.fromOffset(TitleBarButtonSize, TitleBarButtonSize)
    TitleBarButton.ZIndex = ThisWidget.ZIndex + 2
    TitleBarButton.Text = ""
    TitleBarButton.Parent = ButtonParent

    RoundInstance(TitleBarButton, 100)

    ApplyInteractionHighlights(Iris, TitleBarButton, TitleBarButton, {
        ButtonColor = Iris._style.ButtonColor,
        ButtonTransparency = 1,
        ButtonHoveredColor = Iris._style.ButtonHoveredColor,
        ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
        ButtonActiveColor = Iris._style.ButtonActiveColor,
        ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
    })
    return TitleBarButton
end

local Icons = {
    RightPointingTriangle = "\u{25BA}",
    DownPointingTriangle = "\u{25BC}",
    MultiplicationSign = "\u{00D7}" -- best approximation for a close X which roblox supports, needs to be scaled about 2x
}

return function(Iris)

Iris.WidgetConstructor("Root", false, true){
    ArgNames = {},

    Args = {},

    Generate = function(ThisWidget)
        local Root = Instance.new("Folder")
        Root.Name = "Iris:Root"

        local PseudoWindow = Instance.new("Frame")
        PseudoWindow.Name = "Root-PseudoWindow"
        PseudoWindow.Size = UDim2.new(0,0,0,0)
        PseudoWindow.Position = UDim2.fromOffset(0,22)
        PseudoWindow.BorderSizePixel = Iris._style.WindowBorderSize
        PseudoWindow.BorderColor3 = Iris._style.BorderColor
        PseudoWindow.BackgroundTransparency = Iris._style.WindowBgTransparency
        PseudoWindow.BackgroundColor3 = Iris._style.WindowBgColor
        PseudoWindow.AutomaticSize = Enum.AutomaticSize.XY

        PseudoWindow.Visible = false
        PadInstance(PseudoWindow, Iris._style.WindowPadding)

        local UiList = Instance.new("UIListLayout")
        UiList.SortOrder = Enum.SortOrder.LayoutOrder
        UiList.Padding = UDim.new(0,Iris._style.ItemSpacing.Y)
        UiList.Parent = PseudoWindow

        PseudoWindow.Parent = Root
        
        return Root
    end,

    Update = function()

    end,

    Discard = function(ThisWidget)
        ThisWidget.Instance:Destroy()
    end,

    GetParentInstance = function(thisWidget, ChildWidget)
        if ChildWidget.type == "Window" then
            return thisWidget.Instance
        else
            -- ick solution
            thisWidget.Instance["Root-PseudoWindow"].Visible = true
            
            return thisWidget.Instance["Root-PseudoWindow"]
        end
    end,
}    

Iris.WidgetConstructor("Text", false, false){
    ArgNames = {[1] = "Text"},

    Args = {
        ["Text"] = function(_Text: string)
            return table.freeze({1, _Text})
        end
    },

    Generate = function(ThisWidget)
        local Text = Instance.new("TextLabel")
        Text.Name = "Iris:Text"
        Text.Size = UDim2.fromOffset(0,0)
        Text.BackgroundTransparency = 1
        Text.BorderSizePixel = 0
        Text.ZIndex = ThisWidget.ZIndex
        Text.LayoutOrder = ThisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY

        ApplyTextStyle(Iris, Text)
        PadInstance(Text, Vector2.new(0,2)) -- it appears as if this padding is not controlled by any style properties in DearImGui. could change?

        return Text
    end,

    Update = function(ThisWidget)
        local Frame = ThisWidget.Instance
        Frame.Text = ThisWidget.arguments.Text
    end,

    Discard = function(ThisWidget)
        ThisWidget.Instance:Destroy()
    end
}

Iris.Text = function(...)
    return Iris._Insert("Text", ...)
end

Iris.WidgetConstructor("Button", false, false){
    ArgNames = {[1] = "Text"},

    Args = {
        ["Text"] = function(_Text: string)
            return table.freeze({1, _Text})
        end
    },
    
    Generate = function(ThisWidget)
        local Button = Instance.new("TextButton")
        Button.Name = "Iris:Button"
        Button.Size = UDim2.fromOffset(0,0)
        Button.BackgroundColor3 = Iris._style.ButtonColor
        Button.BackgroundTransparency = Iris._style.ButtonTransparency
        Button.BorderMode = Enum.BorderMode.Inset
        Button.BorderColor3 = Iris._style.BorderColor
        Button.BorderSizePixel = Iris._style.FrameBorderSize
        Button.ZIndex = ThisWidget.ZIndex
        Button.LayoutOrder = ThisWidget.ZIndex
        Button.AutoButtonColor = false

        ApplyTextStyle(Iris, Button)
        Button.AutomaticSize = Enum.AutomaticSize.XY
        PadInstance(Button, Iris._style.FramePadding)

        Button.MouseButton1Click:Connect(function()
            ThisWidget.events.Clicked = true
        end)

        ApplyInteractionHighlights(Iris, Button, Button, {
            ButtonColor = Iris._style.ButtonColor,
            ButtonTransparency = Iris._style.ButtonTransparency,
            ButtonHoveredColor = Iris._style.ButtonHoveredColor,
            ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
            ButtonActiveColor = Iris._style.ButtonActiveColor,
            ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
        })

        return Button
    end,

    Update = function(ThisWidget)
        local Button = ThisWidget.Instance
        Button.Text = ThisWidget.arguments.Text or "Button"
    end,

    Discard = function(ThisWidget)
        ThisWidget.Instance:Destroy()
    end
}

Iris.Button = function(...)
    return Iris._Insert("Button", ...)
end

Iris.WidgetConstructor("Tree", true, true){
    ArgNames = {[1] = "Text", [2] = "SpanAvailWidth"},

    Args = {
        ["Text"] = function(_Text: string)
            return table.freeze({1, _Text})
        end,
        ["SpanAvailWidth"] = function(_SpanAvailWidth: boolean)
            return table.freeze({2, _SpanAvailWidth})
        end
    },

    UpdateState = function(ThisWidget)
        local CollapseArrow = ThisWidget.Instance["Tree-Header"]["Header-Button"]["Button-Arrow"]
        local ChildContainer = ThisWidget.Instance["Tree-ChildContainer"]
        CollapseArrow.Text = (ThisWidget.state.Collapsed and Icons.RightPointingTriangle or Icons.DownPointingTriangle)

        ChildContainer.Visible = not ThisWidget.state.Collapsed
    end,

    Generate = function(ThisWidget)

        local Tree = Instance.new("Frame")
        Tree.Name = "Iris:Tree"
        Tree.Size = UDim2.fromOffset(0,0)
        Tree.BackgroundTransparency = 1
        Tree.BorderSizePixel = 0
        Tree.ZIndex = ThisWidget.ZIndex
        Tree.LayoutOrder = ThisWidget.ZIndex
        Tree.Size = UDim2.fromScale(1,0)
        Tree.AutomaticSize = Enum.AutomaticSize.Y

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0,0)
        UIList.Parent = Tree

        local ChildContainer = Instance.new("Frame")
        ChildContainer.Name = "Tree-ChildContainer"
        ChildContainer.Size = UDim2.fromOffset(0,0)
        ChildContainer.BackgroundTransparency = 1
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = ThisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = ThisWidget.ZIndex + 1
        ChildContainer.Size = UDim2.fromScale(1,0)
        ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
        ChildContainer.Visible = false
        ChildContainer.Parent = Tree

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, Iris._style.ItemSpacing.Y)
        UIList.Parent = ChildContainer
        
        local ChildContainerPadding = PadInstance(ChildContainer, Vector2.new(0,0))
        ChildContainerPadding.PaddingTop = UDim.new(0, Iris._style.ItemSpacing.Y)
        ChildContainerPadding.PaddingLeft = UDim.new(0,Iris._style.IndentSpacing)

        local Highlight = Instance.new("Frame")
        Highlight.Name = "Tree-Header"
        Highlight.Size = UDim2.fromOffset(0,0)
        Highlight.BackgroundTransparency = 1
        Highlight.BorderSizePixel = 0
        Highlight.ZIndex = ThisWidget.ZIndex
        Highlight.LayoutOrder = ThisWidget.ZIndex
        Highlight.Size = UDim2.fromScale(1,0)
        Highlight.AutomaticSize = Enum.AutomaticSize.Y
        Highlight.Parent = Tree

        local Button = Instance.new("TextButton")
        Button.Name = "Header-Button"
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.ZIndex = ThisWidget.ZIndex
        Button.LayoutOrder = ThisWidget.ZIndex
        Button.AutoButtonColor = false
        Button.Text = ""
        Button.Parent = Highlight

        ApplyInteractionHighlights(Iris, Button, Highlight, {
            ButtonColor = Color3.fromRGB(0,0,0),
            ButtonTransparency = 1,
            ButtonHoveredColor = Iris._style.HeaderHoveredColor,
            ButtonHoveredTransparency = Iris._style.HeaderHoveredTransparency,
            ButtonActiveColor = Iris._style.HeaderActiveColor,
            ButtonActiveTransparency = Iris._style.HeaderActiveTransparency,
        })

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Horizontal
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Parent = Button
        UIList.VerticalAlignment = Enum.VerticalAlignment.Center

        local CollapseArrow = Instance.new("TextLabel")
        CollapseArrow.Name = "Button-Arrow"
        CollapseArrow.Size = UDim2.fromOffset(Iris._style.FontSize,0)
        CollapseArrow.BackgroundTransparency = 1
        CollapseArrow.BorderSizePixel = 0
        CollapseArrow.ZIndex = ThisWidget.ZIndex
        CollapseArrow.LayoutOrder = ThisWidget.ZIndex
        CollapseArrow.AutomaticSize = Enum.AutomaticSize.Y

        ApplyTextStyle(Iris, CollapseArrow)
        CollapseArrow.TextSize = Iris._style.FontSize - 4
        CollapseArrow.Text = Icons.RightPointingTriangle

        CollapseArrow.Parent = Button

        local Text = Instance.new("TextLabel")
        Text.Name = "Button-Text"
        Text.Size = UDim2.fromOffset(0,0)
        Text.BackgroundTransparency = 1
        Text.BorderSizePixel = 0
        Text.ZIndex = ThisWidget.ZIndex
        Text.LayoutOrder = ThisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY
        Text.Parent = Button
        local TextPadding = PadInstance(Text,Vector2.new(0,0))
        TextPadding.PaddingRight = UDim.new(0,21)

        ApplyTextStyle(Iris, Text)

        Button.MouseButton1Click:Connect(function()
            ThisWidget.state.Collapsed = not ThisWidget.state.Collapsed
            if ThisWidget.state.Collapsed then
                ThisWidget.events.Collapsed = true
            else
                ThisWidget.events.Opened = true
            end
            Iris.widgets.Tree.UpdateState(ThisWidget)
        end)

        return Tree
    end,

    Update = function(ThisWidget)
        local Button = ThisWidget.Instance["Tree-Header"]["Header-Button"]
        Button["Button-Text"].Text = ThisWidget.arguments.Text or "Tree"
        if ThisWidget.arguments.SpanAvailWidth then
            Button.AutomaticSize = Enum.AutomaticSize.Y
            Button.Size = UDim2.fromScale(1,0)
        else
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromScale(0,0)
        end
    end,

    Discard = function(ThisWidget)
        ThisWidget.Instance:Destroy()
    end,

    GetParentInstance = function(ThisWidget)
        return ThisWidget.Instance["Tree-ChildContainer"]
    end,

    GenerateState = function(ThisWidget)
        return {
            Collapsed = true
        }
    end
}

Iris.Tree = function(...)
    return Iris._Insert("Tree", ...)
end

Iris.WidgetConstructor("Window", true, true){
    ArgNames = {[1] = "Title"},

    Args = {
        ["Title"] = function(_Title: string)
            return table.freeze({1, _Title})
        end
    },

    UpdateState = function(ThisWidget)
        ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.state.Size.X, ThisWidget.state.Size.Y)
        ThisWidget.Instance.Position = UDim2.fromOffset(ThisWidget.state.Position.X, ThisWidget.state.Position.Y)

        local TitleBar = ThisWidget.Instance["Window-TitleBar"]
        local TitleBarColor
        local TitleBarTransparency

        if ThisWidget.state.Closed then
            ThisWidget.Instance.Visible = false
        else
            ThisWidget.Instance.Visible = true
        end

        if ThisWidget.state.Collapsed then
            TitleBarColor = Iris._style.TitleBgCollapsedColor
            TitleBarTransparency = Iris._style.TitleBgCollapsedTransparency

            TitleBar["TitleBar-CollapseArrow"].Text = Icons.RightPointingTriangle

            ThisWidget.Instance["Window-ChildContainer"].Visible = false
            ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.state.Size.X,0)
            ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.Y
        else

            ThisWidget.Instance["Window-ChildContainer"].Visible = true
            ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.None

            TitleBar["TitleBar-CollapseArrow"].Text = Icons.DownPointingTriangle

            if ThisWidget.state.Focused then
                TitleBarColor = Iris._style.TitleBgActiveColor
                TitleBarTransparency = Iris._style.TitleBgActiveTransparency
            else
                TitleBarColor = Iris._style.TitleBgColor
                TitleBarTransparency = Iris._style.TitleBgTransparency

            end
        end
        TitleBar.BackgroundColor3 = TitleBarColor
        TitleBar.BackgroundTransparency = TitleBarTransparency
    end,

    Generate = function(ThisWidget)
        local Window = Instance.new("Frame")
        Window.Name = "Iris:Window"
        Window.Size = UDim2.fromOffset(0,0)
        Window.BackgroundTransparency = 1
        Window.BorderSizePixel = 0
        Window.ZIndex = ThisWidget.ZIndex
        Window.LayoutOrder = ThisWidget.ZIndex
        Window.Size = UDim2.fromOffset(0,0)
        Window.AutomaticSize = Enum.AutomaticSize.None
        Window.ClipsDescendants = true

        local UIStroke = Instance.new("UIStroke")
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
        UIStroke.Color = Iris._style.BorderColor
        UIStroke.Thickness = Iris._style.WindowBorderSize

        UIStroke.Parent = Window

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0,0)
        UIList.Parent = Window

        local ChildContainer = Instance.new("Frame")
        ChildContainer.Name = "Window-ChildContainer"
        ChildContainer.Position = UDim2.fromOffset(0,0)
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = ThisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = ThisWidget.ZIndex + 1
        ChildContainer.AutomaticSize = Enum.AutomaticSize.None
        ChildContainer.Size = UDim2.fromScale(1,1)
        
        ChildContainer.BackgroundColor3 = Iris._style.WindowBgColor
        ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
        ChildContainer.Parent = Window

        PadInstance(ChildContainer, Iris._style.WindowPadding)

        local UIList = Instance.new("UIListLayout")
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.VerticalAlignment = Enum.VerticalAlignment.Top
        UIList.Padding = UDim.new(0, Iris._style.ItemSpacing.Y)
        UIList.Parent = ChildContainer

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "Window-TitleBar"
        TitleBar.BorderSizePixel = 0
        TitleBar.ZIndex = ThisWidget.ZIndex
        TitleBar.LayoutOrder = ThisWidget.ZIndex
        TitleBar.AutomaticSize = Enum.AutomaticSize.Y
        TitleBar.Size = UDim2.fromScale(1,0)
        TitleBar.Parent = Window

        local CollapseArrow = Instance.new("TextLabel")
        CollapseArrow.Name = "TitleBar-CollapseArrow"
        CollapseArrow.Size = UDim2.fromOffset(Iris._style.FontSize,0)
        CollapseArrow.Position = UDim2.new(0, Iris._style.FramePadding.X + 1, 0.5, 0)
        CollapseArrow.BackgroundTransparency = 1
        CollapseArrow.BorderSizePixel = 0
        CollapseArrow.ZIndex = ThisWidget.ZIndex + 3
        CollapseArrow.AutomaticSize = Enum.AutomaticSize.None
        ApplyTextStyle(Iris, CollapseArrow)
        CollapseArrow.TextSize = Iris._style.FontSize
        CollapseArrow.Parent = TitleBar

        local ArrowButton = TitleBarButton(Iris, ThisWidget, CollapseArrow)
        ArrowButton.Name = "CollapseArrow-ArrowButton"

        ArrowButton.MouseButton1Click:Connect(function()
            ThisWidget.state.Collapsed = not ThisWidget.state.Collapsed
            if ThisWidget.state.Collapsed then
                ThisWidget.events.Collapsed = true
            else
                ThisWidget.events.Opened = true
            end
            Iris.widgets.Window.UpdateState(ThisWidget)
        end)

        local CloseIcon = Instance.new("TextLabel")
        CloseIcon.Name = "TitleBar-CloseIcon"
        CloseIcon.Size = UDim2.fromOffset(Iris._style.FontSize,0)
        CloseIcon.Position = UDim2.new(1, -(Iris._style.FramePadding.X + 1), 0.5, 0)
        CloseIcon.AnchorPoint = Vector2.new(1,0)
        CloseIcon.BackgroundTransparency = 1
        CloseIcon.BorderSizePixel = 0
        CloseIcon.ZIndex = ThisWidget.ZIndex + 3
        CloseIcon.AutomaticSize = Enum.AutomaticSize.None
        ApplyTextStyle(Iris, CloseIcon)
        CloseIcon.Font = Enum.Font.Code
        CloseIcon.TextSize = Iris._style.FontSize * 2
        CloseIcon.Text = Icons.MultiplicationSign
        CloseIcon.Parent = TitleBar

        local IconButton = TitleBarButton(Iris, ThisWidget, CloseIcon)
        IconButton.Name = "CloseIcon-IconButton"

        IconButton.MouseButton1Click:Connect(function()
            ThisWidget.state.Closed = true
            ThisWidget.events.Closed = true
            Iris.widgets.Window.UpdateState(ThisWidget)
        end)

        -- omitting some style functionality in this implimentation.
        -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.
        -- choosing which side to place the collapse icon may be useful, but implimenting it "elegantly" adds 4 more instances.

        local Title = Instance.new("TextLabel")
        Title.Name = "TitleBar-Title"
        Title.Text = "hello"
        Title.BorderSizePixel = 0
        Title.BackgroundTransparency = 1
        Title.ZIndex = ThisWidget.ZIndex + 2
        Title.AutomaticSize = Enum.AutomaticSize.XY
        ApplyTextStyle(Iris, Title)
        Title.Parent = TitleBar
        local TitleAlign = Iris._style.WindowTitleAlign == Enum.LeftRight.Left and 0 or Iris._style.WindowTitleAlign == Enum.LeftRight.Center and .5 or 1
        Title.Position = UDim2.fromScale(TitleAlign, 0)
        Title.AnchorPoint = Vector2.new(TitleAlign, 0)

        PadInstance(Title, Iris._style.FramePadding)

        return Window
    end,

    Update = function(ThisWidget)
        local TitleBar = ThisWidget.Instance["Window-TitleBar"]

        if ThisWidget.arguments.NoTitleBar then
            TitleBar.Visible = false
        else
            TitleBar.Visible = true
        end
        if ThisWidget.arguments.NoBackground then
            ThisWidget.Instance["Window-ChildContainer"].BackgroundTransparency = 1
        else
            ThisWidget.Instance["Window-ChildContainer"].BackgroundTransparency = Iris._style.WindowBgTransparency
        end
        local TitleButtonPaddingSize = Iris._style.FramePadding.X + Iris._style.FontSize + Iris._style.FramePadding.X * 2
        if ThisWidget.arguments.NoCollapse then
            TitleBar["TitleBar-CollapseArrow"].Visible = false
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0, Iris._style.FramePadding.X)
        else
            TitleBar["TitleBar-CollapseArrow"].Visible = true
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0, TitleButtonPaddingSize)
        end
        if ThisWidget.arguments.NoClose then
            TitleBar["TitleBar-CloseIcon"].Visible = false
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0, Iris._style.FramePadding.X)
        else
            TitleBar["TitleBar-CloseIcon"].Visible = true
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0, TitleButtonPaddingSize)
        end

        local Title = ThisWidget.Instance["Window-TitleBar"]["TitleBar-Title"]
        Title.Text = ThisWidget.arguments.Title or ""
    end,

    Discard = function(ThisWidget)
        ThisWidget.Instance:Destroy()
    end,

    GetParentInstance = function(ThisWidget)
        return ThisWidget.Instance["Window-ChildContainer"]
    end,

    GenerateState = function(ThisWidget)
        return {
            Title = "",
            Size = Vector2.new(250,300),
            Position = Vector2.new(300,100),
            Collapsed = false,
            Focused = true,
            Closed = false
        }
    end
}

Iris.Window = function(...)
    return Iris._Insert("Window", ...)
end

end;