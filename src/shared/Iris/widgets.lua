--[[
    Making a concious decision to not write these widgets with support of ImGui TouchExtraPadding in mind. too much overhead to be worth it atm.

    TODO, all of these widgets need to have .SelectionOrder and .Selectable configured at some point

    TODO, once CanvasGroup instance is out of beta, consider its use in optimizing several of these widget structures, i think they will make Window rounding viable

    TODO, gradients are cool as shit, add gradient styles and a style flag to enable or disable usage.
        why? instances like buttons with text will have their text affected by gradients, so if gradients are enabled the button needs to have a separate textlabel.
        thats a lot of configuration to do but holy shit gradients look good, its worth it.
]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local function PadInstance(PadParent, PxPadding)
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0,PxPadding.X)
    Padding.PaddingRight = UDim.new(0,PxPadding.X)
    Padding.PaddingTop = UDim.new(0,PxPadding.Y)
    Padding.PaddingBottom = UDim.new(0,PxPadding.Y)
    Padding.Parent = PadParent
    return Padding
end

local function Folder(FolderParent)
    local ThisFolder = Instance.new("Folder")
    ThisFolder.Parent = FolderParent
    return ThisFolder
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

local SelectionImageObject
do
    SelectionImageObject = Instance.new("Frame")
    SelectionImageObject.Position = UDim2.fromOffset(-1,-1)
    SelectionImageObject.Size = UDim2.new(1,2,1,2)
    SelectionImageObject.BackgroundTransparency = .8
    SelectionImageObject.BorderSizePixel = 0

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.new(255,255,255)
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = SelectionImageObject

    RoundInstance(SelectionImageObject, 2)
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

    Button.InputBegan:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
        Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
    end)

    Button.InputEnded:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
            Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
        end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            Highlightee.BackgroundColor3 = Colors.ButtonColor
            Highlightee.BackgroundTransparency = Colors.ButtonTransparency
        end
    end)
    
    Button.SelectionImageObject = SelectionImageObject
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

-- THINGS TODO:
-- Window Resizing and Mouse icons for resizing             |
-- global window sortOrder                                  | done
-- somehow sync instance ZIndex to window sortOrder         | half done
-- Ctrl+Tab window focus hotkey                             |
-- Window Dragging                                          | done!
-- Gamepad support for Window Resizing and window dragging  |

do -- Window
    local AnyFocusedWindow = false
    local FocusedWindow = nil
    local ZIndexSortLayer = 0

    local DraggedWindow = nil
    local isDragging = false
    local deltaCursorPosition = nil

    local function IncrementSortLayer()
        ZIndexSortLayer += 1
        if ZIndexSortLayer > 0x400 then
            -- what we should do here, is to take every window, get its sort order
            -- and read just the sort order to start from 0. then if there are too
            -- many windows to comfortable handle with ZIndex, error out
            -- TODO
            error("panic")
        end
    end

    Iris.SetFocusedWindow = function(ThisWidget: table | nil)
        if FocusedWindow == ThisWidget then return end

        if AnyFocusedWindow then
            -- update appearance to unfocus
            local TitleBar = FocusedWindow.Instance["Window-TitleBar"]
            if FocusedWindow.state.Collapsed then
                TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
            else
                TitleBar.BackgroundColor3 = Iris._style.TitleBgColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgTransparency
            end
            FocusedWindow.Instance["UIStroke"].Color = Iris._style.BorderColor

            AnyFocusedWindow = false
            FocusedWindow = nil
        end

        if ThisWidget ~= nil then
            AnyFocusedWindow = true
            FocusedWindow = ThisWidget
            -- update appearance to focus
            local TitleBar = FocusedWindow.Instance["Window-TitleBar"]
            TitleBar.BackgroundColor3 = Iris._style.TitleBgActiveColor
            TitleBar.BackgroundTransparency = Iris._style.TitleBgActiveTransparency
            FocusedWindow.Instance["UIStroke"].Color = Iris._style.BorderActiveColor
            if GuiService.SelectedObject ~= nil then
                GuiService.SelectedObject = FocusedWindow.Instance
            end

            IncrementSortLayer()

            local OldZIndex = ThisWidget.ZIndex
            local NewZIndex = ThisWidget.ZIndex - (ThisWidget.SortLayer * 0xFFFFF) + (ZIndexSortLayer * 0xFFFFF)
            ThisWidget.Instance.ZIndex = NewZIndex
            ThisWidget.ZIndex = NewZIndex
            ThisWidget.SortLayer = ZIndexSortLayer
            for i,v in ThisWidget.Instance:GetDescendants() do
                if v:IsA("GuiObject") then
                    v.ZIndex = (v.ZIndex - OldZIndex) + NewZIndex
                end
            end
        end
    end

    Iris.WidgetConstructor("Window", true, true){
        ArgNames = {
            [1] = "Title",
            [2] = "NoTitleBar",
            [3] = "NoBackground",
            [4] = "NoCollapse",
            [5] = "NoClose"
        },

        Args = {
            ["Title"] = function(_Title: string)
                return table.freeze({1, _Title})
            end,
            ["NoTitleBar"] = function(_NoTitleBar: boolean)
                return table.freeze({2, _NoTitleBar})
            end,
            ["NoBackground"] = function(_NoBackground: boolean)
                return table.freeze({3, _NoBackground})
            end,
            ["NoCollapse"] = function(_NoCollapse: boolean)
                return table.freeze({4, _NoCollapse})
            end,
            ["NoClose"] = function(_NoClose: boolean)
                return table.freeze({5, _NoClose})
            end
        },

        UpdateState = function(ThisWidget)
            ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.state.Size.X, ThisWidget.state.Size.Y)
            ThisWidget.Instance.Position = UDim2.fromOffset(ThisWidget.state.Position.X, ThisWidget.state.Position.Y)

            local TitleBar = ThisWidget.Instance["Window-TitleBar"]
            local ChildContainer = ThisWidget.Instance["Window-ChildContainer"]

            if ThisWidget.state.Closed then
                ThisWidget.Instance.Visible = false
            else
                ThisWidget.Instance.Visible = true
            end

            if ThisWidget.state.Collapsed then
                TitleBar["TitleBar-CollapseArrow"].Text = Icons.RightPointingTriangle

                ChildContainer.Visible = false
                ThisWidget.Instance.Size = UDim2.fromOffset(ThisWidget.state.Size.X,0)
                ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.Y
            else
                ChildContainer.Visible = true
                ThisWidget.Instance.AutomaticSize = Enum.AutomaticSize.None

                TitleBar["TitleBar-CollapseArrow"].Text = Icons.DownPointingTriangle
            end

            if not ThisWidget.state.Closed and not ThisWidget.state.Collapsed then
                Iris.SetFocusedWindow(ThisWidget)
            else
                TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
                ThisWidget.Instance["UIStroke"].Color = Iris._style.BorderColor

                Iris.SetFocusedWindow(nil)
            end
        end,

        Generate = function(ThisWidget)
            IncrementSortLayer()
            ThisWidget.ZIndex += ZIndexSortLayer * 0xFFFFF
            ThisWidget.SortLayer = ZIndexSortLayer

            local Window = Instance.new("TextButton")
            Window.Name = "Iris:Window"
            Window.Size = UDim2.fromOffset(0,0)
            Window.BackgroundTransparency = 1
            Window.BorderSizePixel = 0
            Window.ZIndex = ThisWidget.ZIndex
            Window.LayoutOrder = ThisWidget.ZIndex
            Window.Size = UDim2.fromOffset(0,0)
            Window.AutomaticSize = Enum.AutomaticSize.None
            Window.ClipsDescendants = true
            Window.Text = ""
            Window.AutoButtonColor = false
            Window.Selectable = true
            Window.SelectionImageObject = SelectionImageObject
            
            Window.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then return end
                if not ThisWidget.state.Collapsed then
                    Iris.SetFocusedWindow(ThisWidget)
                end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    DraggedWindow = ThisWidget
                    isDragging = true
                    deltaCursorPosition = UserInputService:GetMouseLocation() - ThisWidget.state.Position
                end

                if input.UserInputType == Enum.UserInputType.Gamepad1 then
                    -- this is Dear ImGui doubleClick functionallity aswell
                    ThisWidget.state.Collapsed = not ThisWidget.state.Collapsed
                    Iris.widgets.Window.UpdateState(ThisWidget)
                    if GuiService.SelectedObject ~= nil then
                        GuiService.SelectedObject = ThisWidget.Instance
                    end
                end
            end)


            Window.SelectionGained:Connect(function()
                if not ThisWidget.state.Collapsed then
                    Iris.SetFocusedWindow(ThisWidget)
                end
            end)

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

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "Window-ChildContainer"
            ChildContainer.Position = UDim2.fromOffset(0,0)
            ChildContainer.BorderSizePixel = 0
            ChildContainer.ZIndex = ThisWidget.ZIndex + 1
            ChildContainer.LayoutOrder = ThisWidget.ZIndex + 1
            ChildContainer.AutomaticSize = Enum.AutomaticSize.None
            ChildContainer.Size = UDim2.fromScale(1,1)
            ChildContainer.Selectable = false

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarThickness = Iris._style.ScrollbarSize
            ChildContainer.ScrollBarImageTransparency = Iris._style.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._style.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0,1)
            
            ChildContainer.BackgroundColor3 = Iris._style.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
            ChildContainer.Parent = Window

            PadInstance(ChildContainer, Iris._style.WindowPadding)

            local TerminatingFrame = Instance.new("Frame");
            TerminatingFrame.Name = "ChildContainer-TerminatingFrame"
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0
            TerminatingFrame.Size = UDim2.fromOffset(0,0)
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.Parent = ChildContainer

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

            local TitleButtonSize = Iris._style.FontSize + ((Iris._style.FramePadding.Y - 1) * 2)

            local CollapseArrow = Instance.new("TextButton")
            CollapseArrow.Name = "TitleBar-CollapseArrow"
            CollapseArrow.Size = UDim2.fromOffset(TitleButtonSize,TitleButtonSize)
            CollapseArrow.Position = UDim2.new(0, Iris._style.FramePadding.X + 1, 0.5, 0)
            CollapseArrow.AnchorPoint = Vector2.new(0,.5)
            CollapseArrow.AutoButtonColor = false
            CollapseArrow.BackgroundTransparency = 1
            CollapseArrow.BorderSizePixel = 0
            CollapseArrow.ZIndex = ThisWidget.ZIndex + 3
            CollapseArrow.AutomaticSize = Enum.AutomaticSize.None
            ApplyTextStyle(Iris, CollapseArrow)
            CollapseArrow.TextSize = Iris._style.FontSize
            CollapseArrow.Parent = TitleBar

            CollapseArrow.MouseButton1Click:Connect(function()
                ThisWidget.state.Collapsed = not ThisWidget.state.Collapsed
                if ThisWidget.state.Collapsed then
                    ThisWidget.events.Collapsed = true
                else
                    ThisWidget.events.Opened = true
                end
                Iris.widgets.Window.UpdateState(ThisWidget)
            end)

            RoundInstance(CollapseArrow, 1e9)

            ApplyInteractionHighlights(Iris, CollapseArrow, CollapseArrow, {
                ButtonColor = Iris._style.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._style.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._style.ButtonActiveColor,
                ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
            })

            local CloseIcon = Instance.new("TextButton")
            CloseIcon.Name = "TitleBar-CloseIcon"
            CloseIcon.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CloseIcon.Position = UDim2.new(1, -(Iris._style.FramePadding.X + 1), 0.5, 0)
            CloseIcon.AnchorPoint = Vector2.new(1,.5)
            CloseIcon.AutoButtonColor = false
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.BorderSizePixel = 0
            CloseIcon.ZIndex = ThisWidget.ZIndex + 3
            CloseIcon.AutomaticSize = Enum.AutomaticSize.None
            ApplyTextStyle(Iris, CloseIcon)
            CloseIcon.Font = Enum.Font.Code
            CloseIcon.TextSize = Iris._style.FontSize * 2
            CloseIcon.Text = Icons.MultiplicationSign
            CloseIcon.Parent = TitleBar

            RoundInstance(CloseIcon, 1e9)

            CloseIcon.MouseButton1Click:Connect(function()
                ThisWidget.state.Closed = true
                ThisWidget.events.Closed = true
                Iris.widgets.Window.UpdateState(ThisWidget)
            end)

            ApplyInteractionHighlights(Iris, CloseIcon, CloseIcon, {
                ButtonColor = Iris._style.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._style.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._style.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._style.ButtonActiveColor,
                ButtonActiveTransparency = Iris._style.ButtonActiveTransparency,
            })

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
            local TerminatingFrame = ThisWidget.Instance["Window-ChildContainer"]["ChildContainer-TerminatingFrame"]
            local EndPadding = Iris._style.WindowPadding.Y + Iris._style.FramePadding.Y
            if ThisWidget.arguments.NoTitleBar then
                TitleBar.Visible = false
                TerminatingFrame.Size = UDim2.fromOffset(0,EndPadding)
            else
                TitleBar.Visible = true
                TerminatingFrame.Size = UDim2.fromOffset(0,EndPadding + (Iris._style.FontSize + Iris._style.FramePadding.Y * 2))
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
            if FocusedWindow == ThisWidget then
                FocusedWindow = nil
                AnyFocusedWindow = false
            end
            ThisWidget.Instance:Destroy()
        end,

        GetParentInstance = function(ThisWidget)
            return ThisWidget.Instance["Window-ChildContainer"]
        end,

        GenerateState = function(ThisWidget)
            return {
                Size = Vector2.new(250,300),
                Position = Vector2.new(300,100),
                Collapsed = false,
                Closed = false,
            }
        end
    }

    Iris.Window = function(...)
        return Iris._Insert("Window", ...)
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        local invalid = (gameProcessedEvent
        or input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Focus
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.Keyboard)

        if invalid then return end
        Iris.SetFocusedWindow(nil)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging then
            local mouseLocation = UserInputService:GetMouseLocation()
            local newPosX, newPosY = 
            math.min(
                math.max(mouseLocation.X - deltaCursorPosition.X, Iris._style.WindowBorderSize),
                Iris.parentInstance.AbsoluteSize.X - DraggedWindow.Instance.AbsoluteSize.X - Iris._style.WindowBorderSize
            ),
            math.min(
                math.max(mouseLocation.Y - deltaCursorPosition.Y, Iris._style.WindowBorderSize),
                Iris.parentInstance.AbsoluteSize.Y - DraggedWindow.Instance.AbsoluteSize.Y - Iris._style.WindowBorderSize
            )

            DraggedWindow.Instance.Position = UDim2.fromOffset(newPosX, newPosY)
            DraggedWindow.state.Position = Vector2.new(newPosX, newPosY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if isDragging then
            isDragging = false
            DraggedWindow.state.Position = DraggedWindow.Instance.AbsolutePosition
            DraggedWindow = nil
            deltaCursorPosition = nil
        end
    end)
end

end