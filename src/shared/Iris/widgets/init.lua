--[[
    an elegant optimization to aide in the refactoring and quick recreating of widgets is to:
    instead of Destroying them in the Discard function, simply parent them to nil, and place them in a designated cache array in Iris._CachedWidgets or something.
    Then, when a call to Generate is made, first check the cache for old widgets and if one exists, use it.
    We can store these in cache for any designated amount of time, and then dynamically or periodically "garbage collect" them.

    Im holding off on implimenting this because its pretty complex and might be changed in the future.


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

local function RoundInstance(RoundParent, PxRounding)
    local Rounding = Instance.new("UICorner")
    Rounding.CornerRadius = UDim.new(0, PxRounding)
    Rounding.Parent = RoundParent
    return Rounding
end

local function ApplyTextStyle(Iris, TextParent)
    TextParent.Font = Iris._Style.Font
    TextParent.TextSize = Iris._Style.FontSize
    TextParent.TextColor3 = Iris._Style.TextColor
    TextParent.TextTransparency = Iris._Style.TextTransparency

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

local function TitleBarButton(Iris, ButtonParent)
    local TitleBarButton = Instance.new("TextButton")
    TitleBarButton.AutoButtonColor = false
    TitleBarButton.BorderSizePixel = 0
    TitleBarButton.BackgroundTransparency = 1
    TitleBarButton.Position = UDim2.fromScale(.5, .5)
    TitleBarButton.AnchorPoint = Vector2.new(.5,.5)
    local TitleBarButtonSize = Iris._Style.FontSize + (Iris._Style.FramePadding.Y-1) * 2 -- this is bigger than Dear ImGui's. Intentionally.
    TitleBarButton.Size = UDim2.fromOffset(TitleBarButtonSize, TitleBarButtonSize)
    TitleBarButton.ZIndex = Iris._WidgetsThisCycle + 2
    TitleBarButton.SelectionOrder = Iris._WidgetsThisCycle + 2
    TitleBarButton.Text = ""
    TitleBarButton.Parent = ButtonParent

    RoundInstance(TitleBarButton, 100)

    ApplyInteractionHighlights(Iris, TitleBarButton, TitleBarButton, {
        ButtonColor = Iris._Style.ButtonColor,
        ButtonTransparency = 1,
        ButtonHoveredColor = Iris._Style.ButtonHoveredColor,
        ButtonHoveredTransparency = Iris._Style.ButtonHoveredTransparency,
        ButtonActiveColor = Iris._Style.ButtonActiveColor,
        ButtonActiveTransparency = Iris._Style.ButtonActiveTransparency,
    })
    return TitleBarButton
end

local Icons = {
    RightPointingTriangle = "\u{25BA}",
    DownPointingTriangle = "\u{25BC}",
    MultiplicationSign = "\u{00D7}" -- best approximation for a close X which roblox supports, needs to be scaled about 2x
}

local widgets = {}

do widgets.Root = {}
    widgets.Root.Generate = function(Iris, ThisWidget)
        local Root = Instance.new("Folder")
        Root.Name = "Iris:Root"

        local PseudoWindow = Instance.new("Frame")
        PseudoWindow.Name = "Root-PseudoWindow"
        PseudoWindow.Size = UDim2.new(1,0,1,0)
        PseudoWindow.Position = UDim2.fromOffset(0,0)
        -- PseudoWindow.BorderMode = Enum.BorderMode.Inset
        PseudoWindow.BorderSizePixel = 0 -- Iris._Style.WindowBorderSize
        -- PseudoWindow.BorderColor3 = Iris._Style.BorderColor
        -- PseudoWindow.BackgroundColor3 = Iris._Style.WindowBgColor
        PseudoWindow.BackgroundTransparency = 1 -- Iris._Style.WindowBgTransparency

        PadInstance(PseudoWindow, Iris._Style.WindowPadding)

        local UiList = Instance.new("UIListLayout")
        UiList.SortOrder = Enum.SortOrder.LayoutOrder
        UiList.Padding = UDim.new(0,Iris._Style.ItemSpacing.Y)
        UiList.Parent = PseudoWindow
        PseudoWindow.Parent = Root
        
        return Root
    end
    
    widgets.Root.GetParentableInstance = function(thisWidget, ChildWidget)
        if ChildWidget.Id == "Window" then
            return thisWidget.Instance["Iris:Root"]
        else
            return thisWidget.Instance["Iris:Root"]["Root-PseudoWindow"]
        end
    end

    widgets.Root.Discard = function(Iris, ThisWidget)
        ThisWidget.Instance:Destroy()
    end
end

do widgets.Text = {}
    widgets.Text.Generate = function(Iris, ThisWidget)
        local Text = Instance.new("TextLabel")
        Text.Name = "Iris:Text"
        Text.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Text.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Text.BorderSizePixel = 0
        Text.ZIndex = Iris._WidgetsThisCycle
        Text.SelectionOrder = Iris._WidgetsThisCycle
        Text.LayoutOrder = Iris._WidgetsThisCycle
        Text.AutomaticSize = Enum.AutomaticSize.XY

        ApplyTextStyle(Iris, Text)
        PadInstance(Text, Vector2.new(0,2)) -- it dosent appear that this is controlled by any style properties in DearImGui. could change?

        return Text
    end

    widgets.Text.Update = function(Iris, ThisWidget)
        local Frame = ThisWidget.Instance
        Frame.Text = ThisWidget.Arguments.Text
    end

    widgets.Text.Discard = function(Iris, ThisWidget)
        ThisWidget.Instance:Destroy()
    end
end

do widgets.Button = {}
    widgets.Button.Generate = function(Iris, ThisWidget)
        local Button = Instance.new("TextButton")
        Button.Name = "Iris:Button"
        Button.Size = UDim2.fromOffset(0,0)
        Button.BackgroundColor3 = Iris._Style.ButtonColor
        Button.BackgroundTransparency = Iris._Style.ButtonTransparency
        Button.BorderMode = Enum.BorderMode.Inset
        Button.BorderColor3 = Iris._Style.BorderColor
        Button.BorderSizePixel = Iris._Style.FrameBorderSize
        Button.ZIndex = Iris._WidgetsThisCycle
        Button.SelectionOrder = Iris._WidgetsThisCycle
        Button.LayoutOrder = Iris._WidgetsThisCycle
        Button.AutoButtonColor = false

        ApplyTextStyle(Iris, Button)
        Button.AutomaticSize = Enum.AutomaticSize.XY
        PadInstance(Button, Iris._Style.FramePadding)

        Button.MouseButton1Click:Connect(function()
            ThisWidget.EventBin.Clicked = true
        end)

        ApplyInteractionHighlights(Iris, Button, Button, {
            ButtonColor = Iris._Style.ButtonColor,
            ButtonTransparency = Iris._Style.ButtonTransparency,
            ButtonHoveredColor = Iris._Style.ButtonHoveredColor,
            ButtonHoveredTransparency = Iris._Style.ButtonHoveredTransparency,
            ButtonActiveColor = Iris._Style.ButtonActiveColor,
            ButtonActiveTransparency = Iris._Style.ButtonActiveTransparency,
        })

        return Button
    end

    widgets.Button.Update = function(Iris, ThisWidget)
        local Button = ThisWidget.Instance

        Button.Text = ThisWidget.Arguments.Text
    end

    widgets.Button.Discard = function(Iris, ThisWidget)
        ThisWidget.Instance:Destroy()
    end
end

do widgets.Tree = {}
    widgets.Tree.ReflectState = function(Iris, ThisWidget)
        local CollapseArrow = ThisWidget.Instance["Tree-Header"]["Header-Button"]["Button-Arrow"]
        local CollapseArrowPadding = CollapseArrow["UIPadding"]
        local ChildContainer = ThisWidget.Instance["Tree-ChildContainer"]
        CollapseArrow.Text = (ThisWidget.State.Collapsed and Icons.RightPointingTriangle or Icons.DownPointingTriangle)
        CollapseArrowPadding.PaddingRight = UDim.new(0,Iris._Style.FramePadding.X + (ThisWidget.State.Collapsed and 3 or 4)) -- TODO this will break for diff font size
        CollapseArrowPadding.PaddingLeft = UDim.new(0,Iris._Style.FramePadding.X + (ThisWidget.State.Collapsed and 3 or 4))

        ChildContainer.Visible = not ThisWidget.State.Collapsed
    end

    widgets.Tree.Generate = function(Iris, ThisWidget)

        local Tree = Instance.new("Frame")
        Tree.Name = "Iris:Tree"
        Tree.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Tree.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Tree.BorderSizePixel = 0
        Tree.ZIndex = Iris._WidgetsThisCycle
        Tree.SelectionOrder = Iris._WidgetsThisCycle
        Tree.LayoutOrder = Iris._WidgetsThisCycle
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
        --ChildContainer.BackgroundColor3 = Iris._Style.
        ChildContainer.BackgroundTransparency = 1
        --ChildContainer.BorderMode = Enum.BorderMode.Inset
        --ChildContainer.BorderColor3 = Iris._Style.BorderColor
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = Iris._WidgetsThisCycle + 1
        ChildContainer.SelectionOrder = Iris._WidgetsThisCycle + 1
        ChildContainer.LayoutOrder = Iris._WidgetsThisCycle + 1
        ChildContainer.Size = UDim2.fromScale(1,0)
        ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
        ChildContainer.Visible = false
        ChildContainer.Parent = Tree

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, Iris._Style.ItemSpacing.Y)
        UIList.Parent = ChildContainer
        
        local ChildContainerPadding = PadInstance(ChildContainer, Vector2.new(0,0))
        ChildContainerPadding.PaddingTop = UDim.new(0, Iris._Style.ItemSpacing.Y)
        ChildContainerPadding.PaddingLeft = UDim.new(0,Iris._Style.IndentSpacing)

        local Highlight = Instance.new("Frame")
        Highlight.Name = "Tree-Header"
        Highlight.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Highlight.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Highlight.BorderSizePixel = 0
        Highlight.ZIndex = Iris._WidgetsThisCycle
        Highlight.SelectionOrder = Iris._WidgetsThisCycle
        Highlight.LayoutOrder = Iris._WidgetsThisCycle
        Highlight.Size = UDim2.fromScale(1,0)
        Highlight.AutomaticSize = Enum.AutomaticSize.Y
        Highlight.Parent = Tree

        local Button = Instance.new("TextButton")
        Button.Name = "Header-Button"
        --Button.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Button.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Button.BorderSizePixel = 0
        Button.ZIndex = Iris._WidgetsThisCycle
        Button.SelectionOrder = Iris._WidgetsThisCycle
        Button.LayoutOrder = Iris._WidgetsThisCycle
        --Button.AutomaticSize = Enum.AutomaticSize.XY
        Button.AutoButtonColor = false
        Button.Text = ""
        Button.Parent = Highlight

        ApplyInteractionHighlights(Iris, Button, Highlight, {
            ButtonColor = Color3.fromRGB(0,0,0),
            ButtonTransparency = 1,
            ButtonHoveredColor = Iris._Style.HeaderHoveredColor,
            ButtonHoveredTransparency = Iris._Style.HeaderHoveredTransparency,
            ButtonActiveColor = Iris._Style.HeaderActiveColor,
            ButtonActiveTransparency = Iris._Style.HeaderActiveTransparency,
        })

        local UIList = Instance.new("UIListLayout")
        UIList.FillDirection = Enum.FillDirection.Horizontal
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Parent = Button

        local CollapseArrow = Instance.new("TextLabel")
        CollapseArrow.Name = "Button-Arrow"
        CollapseArrow.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        CollapseArrow.BackgroundTransparency = 1
        --CollapseArrow.BorderMode = Enum.BorderMode.Inset
        --CollapseArrow.BorderColor3 = Iris._Style.BorderColor
        CollapseArrow.BorderSizePixel = 0
        CollapseArrow.ZIndex = Iris._WidgetsThisCycle
        CollapseArrow.SelectionOrder = Iris._WidgetsThisCycle
        CollapseArrow.LayoutOrder = Iris._WidgetsThisCycle
        CollapseArrow.AutomaticSize = Enum.AutomaticSize.XY

        ApplyTextStyle(Iris, CollapseArrow)
        CollapseArrow.TextSize = Iris._Style.FontSize - 4
        CollapseArrow.Text = Icons.RightPointingTriangle

        PadInstance(CollapseArrow, Vector2.new(Iris._Style.FramePadding.X + 3,2)) -- it dosent appear that this is controlled by any style properties in DearIris. could change?
        CollapseArrow.Parent = Button

        local Text = Instance.new("TextLabel")
        Text.Name = "Button-Text"
        Text.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Text.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Text.BorderSizePixel = 0
        Text.ZIndex = Iris._WidgetsThisCycle
        Text.SelectionOrder = Iris._WidgetsThisCycle
        Text.LayoutOrder = Iris._WidgetsThisCycle
        Text.AutomaticSize = Enum.AutomaticSize.XY
        Text.Parent = Button
        local TextPadding = PadInstance(Text,Vector2.new(0,0))
        TextPadding.PaddingRight = UDim.new(0,21)

        ApplyTextStyle(Iris, Text)

        Button.MouseButton1Click:Connect(function()
            ThisWidget.State.Collapsed = not ThisWidget.State.Collapsed
            if ThisWidget.State.Collapsed then
                ThisWidget.EventBin.Collapsed = true
            else
                ThisWidget.EventBin.Opened = true
            end
            widgets.Tree.ReflectState(Iris, ThisWidget)
        end)

        return Tree
    end

    widgets.Tree.Update = function(Iris, ThisWidget)
        local Button = ThisWidget.Instance["Tree-Header"]["Header-Button"]
        Button["Button-Text"].Text = ThisWidget.Arguments.Text
        if ThisWidget.Arguments.Collapsed ~= nil then
            ThisWidget.State.Collapsed = ThisWidget.Arguments.Collapsed
        end
        if ThisWidget.Arguments.SpanAvailWidth then
            Button.AutomaticSize = Enum.AutomaticSize.Y
            Button.Size = UDim2.fromScale(1,0)
        else
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromScale(0,0)
        end
        widgets.Tree.ReflectState(Iris, ThisWidget) -- not inside if because if it was loaded then unloaded its state will be retrived but not put into arguments. possible optimization to change this.. idk
    end

    widgets.Tree.Discard = function(Iris, ThisWidget)
        ThisWidget.Instance:Destroy()
    end

    widgets.Tree.GetParentableInstance = function(ThisWidget)
        return ThisWidget.Instance["Tree-ChildContainer"]
    end

    widgets.Tree.GenerateNewState = function(Iris, ThisWidget)
        return {Collapsed = true}
    end
end

do widgets.Window = {}
    widgets.Window.ReflectState = function(Iris, ThisWidget)
        ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.State.Size.X, ThisWidget.State.Size.Y)
        ThisWidget.Instance.Position = UDim2.fromOffset(ThisWidget.State.Position.X, ThisWidget.State.Position.Y)

        local TitleBar = ThisWidget.Instance["Window-TitleBar"]
        local TitleBarColor
        local TitleBarTransparency

        if ThisWidget.State.Closed then
            ThisWidget.Instance.Visible = false
        else
            ThisWidget.Instance.Visible = true
        end

        if ThisWidget.State.Collapsed then
            TitleBarColor = Iris._Style.TitleBgCollapsedColor
            TitleBarTransparency = Iris._Style.TitleBgCollapsedTransparency

            TitleBar["TitleBar-CollapseArrow"].Text = Icons.RightPointingTriangle

            ThisWidget.Instance["Window-ChildContainer"].Visible = false
            ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.State.Size.X,0)
            ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.Y
        else

            ThisWidget.Instance["Window-ChildContainer"].Visible = true
            ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.None

            TitleBar["TitleBar-CollapseArrow"].Text = Icons.DownPointingTriangle

            if ThisWidget.State.Focused then
                TitleBarColor = Iris._Style.TitleBgActiveColor
                TitleBarTransparency = Iris._Style.TitleBgActiveTransparency
            else
                TitleBarColor = Iris._Style.TitleBgColor
                TitleBarTransparency = Iris._Style.TitleBgTransparency

            end
        end
        TitleBar.BackgroundColor3 = TitleBarColor
        TitleBar.BackgroundTransparency = TitleBarTransparency
    end

    widgets.Window.Generate = function(Iris, ThisWidget)
        local Window = Instance.new("Frame")
        Window.Name = "Iris:Window"
        Window.Size = UDim2.fromOffset(0,0)
        --Frame.BackgroundColor3 = Iris._Style.
        Window.BackgroundTransparency = 1
        --Text.BorderMode = Enum.BorderMode.Inset
        --Text.BorderColor3 = Iris._Style.BorderColor
        Window.BorderSizePixel = 0
        Window.ZIndex = Iris._WidgetsThisCycle
        Window.SelectionOrder = Iris._WidgetsThisCycle
        Window.LayoutOrder = Iris._WidgetsThisCycle
        Window.Size = UDim2.fromOffset(0,0)
        Window.AutomaticSize = Enum.AutomaticSize.None

        local UIStroke = Instance.new("UIStroke")
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
        UIStroke.Color = Iris._Style.BorderColor
        UIStroke.Thickness = Iris._Style.WindowBorderSize

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
        ChildContainer.ZIndex = Iris._WidgetsThisCycle + 1
        ChildContainer.SelectionOrder = Iris._WidgetsThisCycle + 1
        ChildContainer.LayoutOrder = Iris._WidgetsThisCycle + 1
        ChildContainer.AutomaticSize = Enum.AutomaticSize.XY
        ChildContainer.Size = UDim2.fromScale(1,1)
        
        ChildContainer.BackgroundColor3 = Iris._Style.WindowBgColor
        ChildContainer.BackgroundTransparency = Iris._Style.WindowBgTransparency
        ChildContainer.Parent = Window

        PadInstance(ChildContainer, Iris._Style.WindowPadding)

        local UIList = Instance.new("UIListLayout")
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.FillDirection = Enum.FillDirection.Vertical
        UIList.VerticalAlignment = Enum.VerticalAlignment.Top
        UIList.Padding = UDim.new(0, Iris._Style.ItemSpacing.Y)
        UIList.Parent = ChildContainer

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "Window-TitleBar"
        TitleBar.BorderSizePixel = 0
        TitleBar.ZIndex = Iris._WidgetsThisCycle
        TitleBar.SelectionOrder = Iris._WidgetsThisCycle
        TitleBar.LayoutOrder = Iris._WidgetsThisCycle
        TitleBar.AutomaticSize = Enum.AutomaticSize.Y
        TitleBar.Size = UDim2.fromScale(1,0)
        TitleBar.Parent = Window

        local CollapseArrow = Instance.new("TextLabel")
        CollapseArrow.Name = "TitleBar-CollapseArrow"
        CollapseArrow.Size = UDim2.fromScale(0,0)
        CollapseArrow.Position = UDim2.fromScale(0,0.5)
        --Frame.BackgroundColor3 = Iris._Style.
        CollapseArrow.BackgroundTransparency = 1
        --CollapseArrow.BorderMode = Enum.BorderMode.Inset
        --CollapseArrow.BorderColor3 = Iris._Style.BorderColor
        CollapseArrow.BorderSizePixel = 0
        CollapseArrow.ZIndex = Iris._WidgetsThisCycle + 3
        CollapseArrow.AutomaticSize = Enum.AutomaticSize.X
        ApplyTextStyle(Iris, CollapseArrow)
        CollapseArrow.TextSize = Iris._Style.FontSize
        --CollapseArrow.Text = Icons.DownPointingTriangle
        PadInstance(CollapseArrow, Vector2.new(Iris._Style.FramePadding.X + 3,0))
        CollapseArrow.Parent = TitleBar

        local ArrowButton = TitleBarButton(Iris, CollapseArrow)
        ArrowButton.Name = "CollapseArrow-ArrowButton"

        ArrowButton.MouseButton1Click:Connect(function()
            ThisWidget.State.Collapsed = not ThisWidget.State.Collapsed
            if ThisWidget.State.Collapsed then
                ThisWidget.EventBin.Collapsed = true
            else
                ThisWidget.EventBin.Opened = true
            end
            widgets.Window.ReflectState(Iris, ThisWidget)
        end)

        local CloseIcon = Instance.new("TextLabel")
        CloseIcon.Name = "TitleBar-CloseIcon"
        CloseIcon.Size = UDim2.fromScale(0,0)
        CloseIcon.Position = UDim2.fromScale(1,0.5)
        CloseIcon.AnchorPoint = Vector2.new(1,0)
        --Frame.BackgroundColor3 = Iris._Style.
        CloseIcon.BackgroundTransparency = 1
        --CloseIcon.BorderMode = Enum.BorderMode.Inset
        --CloseIcon.BorderColor3 = Iris._Style.BorderColor
        CloseIcon.BorderSizePixel = 0
        CloseIcon.ZIndex = Iris._WidgetsThisCycle + 3
        CloseIcon.AutomaticSize = Enum.AutomaticSize.X
        ApplyTextStyle(Iris, CloseIcon)
        CloseIcon.Font = Enum.Font.Code -- fuck this shitty fix
        CloseIcon.TextSize = Iris._Style.FontSize * 2
        CloseIcon.Text = Icons.MultiplicationSign
        PadInstance(CloseIcon, Vector2.new(Iris._Style.FramePadding.X + 3,0))
        CloseIcon.Parent = TitleBar

        local IconButton = TitleBarButton(Iris, CloseIcon)
        IconButton.Name = "CloseIcon-IconButton"

        IconButton.MouseButton1Click:Connect(function()
            ThisWidget.State.Closed = true
            ThisWidget.EventBin.Closed = true
            widgets.Window.ReflectState(Iris, ThisWidget)
        end)

        -- omitting some style functionality in this implimentation.
        -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.
        -- choosing which side to place the collapse icon may be useful, but implimenting it "elegantly" adds 4 more instances.

        local Title = Instance.new("TextLabel")
        Title.Name = "TitleBar-Title"
        Title.Text = "hello"
        Title.BorderSizePixel = 0
        Title.BackgroundTransparency = 1
        Title.ZIndex = Iris._WidgetsThisCycle + 2
        Title.AutomaticSize = Enum.AutomaticSize.XY
        ApplyTextStyle(Iris, Title)
        Title.Parent = TitleBar
        local TitleAlign = Iris._Style.WindowTitleAlign == Enum.LeftRight.Left and 0 or Iris._Style.WindowTitleAlign == Enum.LeftRight.Center and .5 or 1
        Title.Position = UDim2.fromScale(TitleAlign, 0)
        Title.AnchorPoint = Vector2.new(TitleAlign, 0)
        --Title.LineHeight = .99 -- makes it 1 pixel shorter on the bottom. stupid fix.

        PadInstance(Title, Iris._Style.FramePadding)

        return Window
    end

    widgets.Window.Update = function(Iris, ThisWidget)
        local TitleBar = ThisWidget.Instance["Window-TitleBar"]
        if ThisWidget.Arguments.Size then
            ThisWidget.State.Size = ThisWidget.Arguments.Size
        end
        if ThisWidget.Arguments.Position then
            ThisWidget.State.Position = ThisWidget.Arguments.Position
        end
        
        -- simplifing these ifs may obscure the possibility that an argument is nil. watch out for bugs from that
        if ThisWidget.Arguments.NoTitleBar then
            TitleBar.Visible = false
        else
            TitleBar.Visible = true
        end
        if ThisWidget.Arguments.NoBackground then
            ThisWidget.Instance["Window-ChildContainer"].BackgroundTransparency = 1
        else
            ThisWidget.Instance["Window-ChildContainer"].BackgroundTransparency = Iris._Style.WindowBgTransparency
        end
        if ThisWidget.Arguments.NoCollapse then
            TitleBar["TitleBar-CollapseArrow"].Visible = false
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0,Iris._Style.FramePadding.X)
        else
            TitleBar["TitleBar-CollapseArrow"].Visible = true
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0,TitleBar["TitleBar-CollapseArrow"].AbsoluteSize.X)
        end
        if ThisWidget.Arguments.NoClose then
            TitleBar["TitleBar-CloseIcon"].Visible = false
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0,Iris._Style.FramePadding.X)
        else
            TitleBar["TitleBar-CloseIcon"].Visible = true
            TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0,TitleBar["TitleBar-CloseIcon"].AbsoluteSize.X)
        end
        local Title = ThisWidget.Instance["Window-TitleBar"]["TitleBar-Title"]
        Title.Text = ThisWidget.Arguments.Title or ""

        if ThisWidget.Arguments.Closed ~= nil then
            ThisWidget.State.Closed = ThisWidget.Arguments.Closed
        end
        
        widgets.Window.ReflectState(Iris, ThisWidget)
    end

    widgets.Window.Discard = function(Iris, ThisWidget)
        ThisWidget.Instance:Destroy()
    end

    widgets.Window.GetParentableInstance = function(ThisWidget)
        return ThisWidget.Instance["Window-ChildContainer"]
    end

    widgets.Window.GenerateNewState = function(Iris, ThisWidget)
        return {
            Title = "",
            Size = Vector2.new(250,300),
            Positon = Vector2.new(16,16),
            Collapsed = false,
            Focused = true,
            Closed = false
        }
    end
end

local widgetArgumentIndicies = {
    ["Root"] = {},
    ["Text"] = {[1] = "Text"},
    ["Button"] = {[1] = "Text"},
    ["Tree"] = {
        [1] = "Text",
        [2] = "Collapsed",
        [3] = "SpanAvailWidth"
    },
    ["Window"] = {
        [1] = "Title",
        [2] = "Size",
        [3] = "Position",
        [4] = "NoTitleBar",
        [5] = "NoBackground",
        [6] = "NoCollapse",
        [7] = "NoClose",
        [8] = "Closed"
    }
}

local widgetArgumentIndiciesInverse = {}
for currentWidgetIndex, currentWidgetValue in widgetArgumentIndicies do
    widgetArgumentIndiciesInverse[currentWidgetIndex] = {}
    for i,v in currentWidgetValue do
        widgetArgumentIndiciesInverse[currentWidgetIndex][v] = i
    end
end

return {
    widgets = widgets,
    widgetArgumentIndicies = widgetArgumentIndicies,
    widgetArgumentIndiciesInverse = widgetArgumentIndiciesInverse,
    widgetsWhichMayHaveChildren = {
        ["Root"] = true,
        ["Tree"] = true,
        ["Window"] = true
    },
    widgetsWhichHaveState = {
        ["Tree"] = true,
        ["Window"] = true
    },
    -- the goal of .args is to allow users to write properties of widgets without having to memorize their argument index or exact name.
    -- in _InsertIntoTree, the arguments table is serialized.
    -- TODO, this works ok but when theres a table as an argument type there will be an issue.
    Args = {
        ["Root"] = {},
        ["Text"] = {
            Text = function(Text: string)
                return {widgetArgumentIndiciesInverse["Text"]["Text"], Text}
            end,
        },
        ["Button"] = {
            Text = function(Text: string)
                return {widgetArgumentIndiciesInverse["Button"]["Text"], Text}
            end,
        },
        ["Tree"] = {
            Text = function(Text: string)
                return {widgetArgumentIndiciesInverse["Tree"]["Text"], Text}
            end,
            Collapsed = function(Collapsed: boolean)
                return {widgetArgumentIndiciesInverse["Tree"]["Collapsed"], Collapsed}
            end,
            SpanAvailWidth = function(SpansAvailWidth: boolean)
                return {widgetArgumentIndiciesInverse["Tree"]["SpanAvailWidth"], SpansAvailWidth}
            end
        },
        ["Window"] = {
            Title = function(Title: string)
                return {widgetArgumentIndiciesInverse["Window"]["Title"], Title}
            end,
            Size = function(SizeX: number, SizeY: number)
                return {widgetArgumentIndiciesInverse["Window"]["Size"], Vector2.new(SizeX, SizeY)}
            end,
            Position = function(PositionX: number, PositionY: number)
                return {widgetArgumentIndiciesInverse["Window"]["Position"], Vector2.new(PositionX, PositionY)}
            end,
            NoTitleBar = function(NoTitleBar: boolean)
                return {widgetArgumentIndiciesInverse["Window"]["NoTitleBar"], NoTitleBar}
            end,
            NoBackground = function(NoBackground: boolean)
                return {widgetArgumentIndiciesInverse["Window"]["NoBackground"], NoBackground}
            end,
            NoCollapse = function(NoCollapse: boolean)
                return {widgetArgumentIndiciesInverse["Window"]["NoCollapse"], NoCollapse}
            end,
            NoClose = function(NoClose: boolean)
                return {widgetArgumentIndiciesInverse["Window"]["NoClose"], NoClose}
            end,
            Closed = function(Closed: boolean)
                return {widgetArgumentIndiciesInverse["Window"]["Closed"], Closed}
            end
        }
    }
}
