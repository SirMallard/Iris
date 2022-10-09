--[[
    Making a concious decision to not write these widgets with support of ImGui TouchExtraPadding in mind. too much overhead to be worth it atm.

    CanvasGroup is useless. They dont even have a clipsDescendants property.

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

local function ApplyTextStyle(Iris, TextParent)
    TextParent.Font = Iris._style.Font
    TextParent.TextSize = Iris._style.FontSize
    TextParent.TextColor3 = Iris._style.TextColor
    TextParent.TextTransparency = Iris._style.TextTransparency

    TextParent.AutoLocalize = false
    TextParent.RichText = false
end

local function ApplyInteractionHighlights(Iris, Button, Highlightee, Colors, Mode: "Text" | "Background" | nil)
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

local function ApplyFrameStyle(Iris, thisInstance)
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

        RoundInstance(thisInstance, FrameRounding)
        UIStroke.Parent = thisInstance

        PadInstance(thisInstance, Iris._style.FramePadding)

    elseif FrameBorderSize < 1 and FrameRounding > 0 then
        thisInstance.BorderSizePixel = 0

        RoundInstance(thisInstance, FrameRounding)
        PadInstance(thisInstance, Iris._style.FramePadding)
    elseif FrameRounding < 1 then
        thisInstance.BorderSizePixel = FrameBorderSize
        thisInstance.BorderColor3 = FrameBorderColor
        thisInstance.BorderMode = Enum.BorderMode.Inset

        PadInstance(thisInstance, FramePadding - Vector2.new(FrameBorderSize, FrameBorderSize))
    end
end

local Icons = {
    RightPointingTriangle = "\u{25BA}",
    DownPointingTriangle = "\u{25BC}",
    MultiplicationSign = "\u{00D7}", -- best approximation for a close X which roblox supports, needs to be scaled about 2x
    BottomRightCorner = "\u{25E2}", -- used in window resize icon in bottom right
}

return function(Iris)

Iris.WidgetConstructor("Root", false, true){
    ArgNames = {},

    Args = {},

    Generate = function(thisWidget)
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

        PseudoWindow.Selectable = false
        PseudoWindow.SelectionGroup = true
        PseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
        PseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

        PseudoWindow.Visible = false
        PadInstance(PseudoWindow, Iris._style.WindowPadding)

        local UiList = Instance.new("UIListLayout")
        UiList.SortOrder = Enum.SortOrder.LayoutOrder
        UiList.Padding = UDim.new(0,Iris._style.ItemSpacing.Y)
        UiList.Parent = PseudoWindow

        PseudoWindow.Parent = Root
        
        return Root
    end,

    Update = function(thisWidget)
        if thisWidget.shouldExist then
            thisWidget.Instance["Root-PseudoWindow"].Visible = true
        end
    end,

    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,

    GetParentInstance = function(thisWidget, ChildWidget)
        if ChildWidget.type == "Window" then
            return thisWidget.Instance
        else
            thisWidget.shouldExist = true
            Iris.widgets["Root"].Update(thisWidget)
            
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

    Generate = function(thisWidget)
        local Text = Instance.new("TextLabel")
        Text.Name = "Iris:Text"
        Text.Size = UDim2.fromOffset(0,0)
        Text.BackgroundTransparency = 1
        Text.BorderSizePixel = 0
        Text.ZIndex = thisWidget.ZIndex
        Text.LayoutOrder = thisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY

        ApplyTextStyle(Iris, Text)
        PadInstance(Text, Vector2.new(0,2)) -- it appears as if this padding is not controlled by any style properties in DearImGui. could change?

        return Text
    end,

    Update = function(thisWidget)
        local Frame = thisWidget.Instance
        Frame.Text = thisWidget.arguments.Text
    end,

    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
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
    
    Generate = function(thisWidget)
        local Button = Instance.new("TextButton")
        Button.Name = "Iris:Button"
        Button.Size = UDim2.fromOffset(0,0)
        Button.BackgroundColor3 = Iris._style.ButtonColor
        Button.BackgroundTransparency = Iris._style.ButtonTransparency
        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex
        Button.AutoButtonColor = false

        ApplyTextStyle(Iris, Button)
        Button.AutomaticSize = Enum.AutomaticSize.XY

        ApplyFrameStyle(Iris, Button)

        Button.MouseButton1Click:Connect(function()
            thisWidget.events.Clicked = true
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

    Update = function(thisWidget)
        local Button = thisWidget.Instance
        Button.Text = thisWidget.arguments.Text or "Button"
    end,

    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
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

    UpdateState = function(thisWidget)
        local CollapseArrow = thisWidget.Instance["Tree-Header"]["Header-Button"]["Button-Arrow"]
        local ChildContainer = thisWidget.Instance["Tree-ChildContainer"]
        CollapseArrow.Text = (thisWidget.state.Collapsed and Icons.RightPointingTriangle or Icons.DownPointingTriangle)

        ChildContainer.Visible = not thisWidget.state.Collapsed
    end,

    Generate = function(thisWidget)

        local Tree = Instance.new("Frame")
        Tree.Name = "Iris:Tree"
        Tree.Size = UDim2.fromOffset(0,0)
        Tree.BackgroundTransparency = 1
        Tree.BorderSizePixel = 0
        Tree.ZIndex = thisWidget.ZIndex
        Tree.LayoutOrder = thisWidget.ZIndex
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
        ChildContainer.ZIndex = thisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
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
        Highlight.ZIndex = thisWidget.ZIndex
        Highlight.LayoutOrder = thisWidget.ZIndex
        Highlight.Size = UDim2.fromScale(1,0)
        Highlight.AutomaticSize = Enum.AutomaticSize.Y
        Highlight.Parent = Tree

        local Button = Instance.new("TextButton")
        Button.Name = "Header-Button"
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex
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
        CollapseArrow.ZIndex = thisWidget.ZIndex
        CollapseArrow.LayoutOrder = thisWidget.ZIndex
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
        Text.ZIndex = thisWidget.ZIndex
        Text.LayoutOrder = thisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY
        Text.Parent = Button
        local TextPadding = PadInstance(Text,Vector2.new(0,0))
        TextPadding.PaddingRight = UDim.new(0,21)

        ApplyTextStyle(Iris, Text)

        Button.MouseButton1Click:Connect(function()
            thisWidget.state.Collapsed = not thisWidget.state.Collapsed
            if thisWidget.state.Collapsed then
                thisWidget.events.Collapsed = true
            else
                thisWidget.events.Opened = true
            end
            Iris.widgets.Tree.UpdateState(thisWidget)
        end)

        return Tree
    end,

    Update = function(thisWidget)
        local Button = thisWidget.Instance["Tree-Header"]["Header-Button"]
        Button["Button-Text"].Text = thisWidget.arguments.Text or "Tree"
        if thisWidget.arguments.SpanAvailWidth then
            Button.AutomaticSize = Enum.AutomaticSize.Y
            Button.Size = UDim2.fromScale(1,0)
        else
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromScale(0,0)
        end
    end,

    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,

    GetParentInstance = function(thisWidget)
        return thisWidget.Instance["Tree-ChildContainer"]
    end,

    GenerateState = function(thisWidget)
        return {
            Collapsed = true
        }
    end
}

Iris.Tree = function(...)
    return Iris._Insert("Tree", ...)
end

-- THINGS TODO:
-- Window Resizing and Mouse icons for resizing             | done... no icons
-- global window sortOrder                                  | done
-- somehow sync instance ZIndex to window sortOrder         | done
-- Ctrl+Tab window focus hotkey                             | Roblox eats Ctrl+Tab input in studio... ick
-- Window Dragging                                          | done!
-- Gamepad support for Window Resizing and window dragging  |

do -- Window
    local anyFocusedWindow = false
    local focusedWindow = nil
    local ZIndexSortLayer = 0

    local dragWindow = nil
    local isDragging = false
    local resizeWindow = nil
    local isResizing = false
    local deltaCursorPosition = nil
    local resizeDeltaCursorPosition = nil

    local GAMEPAD_MENU_START_HOLD_TIME = 0.2
    local gamepadMenuStartEnded = false
    local gamepadMenuStartOpenedDelta = 0
    local gamepadMenu = nil
    local gamepadMenuOpened = false
    local navWindowingBorder = nil

    local function gamepadSelectWindow(selectedWindow)
        local firstSelectedObject = GuiService.SelectedObject
        if firstSelectedObject then
            GuiService:Select(selectedWindow.Instance["Window-ChildContainer"])
        end
    end

    local function gamepadMenuBehavior(opened: boolean)
        if not gamepadMenu then
            gamepadMenu = Instance.new("Frame")
            gamepadMenu.Name = "Iris:NavGamepadMenu"
            gamepadMenu.Size = UDim2.fromScale(1,1)
            gamepadMenu.Position = UDim2.fromScale(0,0)
            gamepadMenu.BackgroundColor3 = Iris._style.NavWindowingDimBgColor
            gamepadMenu.BackgroundTransparency = Iris._style.NavWindowingDimBgTransparency
            gamepadMenu.BorderSizePixel = 0
            gamepadMenu.ZIndex = (ZIndexSortLayer - .5) * 0xFFFFF
            gamepadMenu.Parent = Iris.parentInstance
            
            local menuModal = Instance.new("Frame")
            menuModal.Name = "NavGamepadMenu-MenuModal"
            menuModal.AnchorPoint = Vector2.new(.5, .5)
            menuModal.Position = UDim2.fromScale(.5, .5)
            menuModal.Size = UDim2.fromOffset(250, 0)
            menuModal.BorderSizePixel = Iris._style.WindowBorderSize
            menuModal.BorderColor3 = Iris._style.BorderActiveColor
            menuModal.BackgroundColor3 = Iris._style.WindowBgColor
            menuModal.BackgroundTransparency = Iris._style.WindowBgTransparency

            SizeConstraint(menuModal, Vector2.new(0,150), Vector2.new(1e9, 1e9))

            menuModal.Parent = gamepadMenu
        end
        if not navWindowingBorder then
            local BORDER_DISTANCE = 12
            navWindowingBorder = Instance.new("Frame")
            navWindowingBorder.Name = "Iris:NavWindowingBorder"
            navWindowingBorder.Position = UDim2.new(0,-BORDER_DISTANCE, 0,-BORDER_DISTANCE)
            navWindowingBorder.Size = UDim2.new(1, 2 * BORDER_DISTANCE, 1, 2 * BORDER_DISTANCE)
            navWindowingBorder.BorderSizePixel = 0
            navWindowingBorder.BackgroundTransparency = 1

            local UIStroke = Instance.new("UIStroke")
            UIStroke.Parent = navWindowingBorder
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
            UIStroke.Thickness = 4
            UIStroke.Color = Iris._style.NavWindowingHighlightColor
            UIStroke.Transparency = Iris._style.NavWindowingHighlightTransparency
            UIStroke.Parent = navWindowingBorder
        end
        
        gamepadMenuOpened = opened
        if opened then
            local baseZIndex = (ZIndexSortLayer - .5) * 0xFFFFF
            local basePeakZIndex = 0x80000000 - 0xFF
            gamepadMenu.ZIndex = baseZIndex
            gamepadMenu["NavGamepadMenu-MenuModal"].ZIndex = basePeakZIndex
            gamepadMenu.Visible = true

            if anyFocusedWindow then
                navWindowingBorder.Parent = focusedWindow.Instance["Window-UnlistedChildFolder"]
                navWindowingBorder.ZIndex = focusedWindow.ZIndex + 0xFF
            end

            GuiService.SelectedObject = nil
        else
            gamepadMenu.Visible = false
            navWindowingBorder.Parent = nil
        end
    end

    local gamepadMenuCoroutine = coroutine.create(function()
        while true do
            gamepadMenuStartOpenedDelta = os.clock()
            gamepadMenuStartEnded = false
            task.wait(GAMEPAD_MENU_START_HOLD_TIME)
            if not gamepadMenuStartEnded then
                gamepadMenuBehavior(true)
            end
            coroutine.yield()
        end
    end)

    local MAX_SORT_LAYER = 0x400
    local MAX_NUM_WINDOWS = 0x200 -- should be less than MAX_SORT_LAYER

    local function getWindows()
        -- optimization here to cache windows when they are generated and discarded, but that sounds like hell to code and debug.
        local Windows = {}
        local VDOM = Iris._GetVDOM()

        for i,v in VDOM do
            if v.type == "Window" then
                table.insert(Windows, v)
            end
        end

        return Windows
    end

    local function IncrementSortLayer()
        ZIndexSortLayer += 1
        if ZIndexSortLayer > MAX_SORT_LAYER then
            -- this code takes all windows, readjusts the sort order to start from 0. 
            -- then if there are too many windows to comfortably handle with ZIndex, error out
            local Windows = getWindows()

            if #Windows > MAX_NUM_WINDOWS then
                error("you have too many Iris windows.")
            end

            table.sort(Windows,function(a,b)
                return a.SortLayer < b.SortLayer
            end)
            
            ZIndexSortLayer = 1
            for i,v in Windows do
                Iris.SetFocusedWindow(v)
            end

            warn("Window Layer rewritten")
            return true
        end
        return false
    end

    Iris.SetFocusedWindow = function(thisWidget: table | nil)
        if focusedWindow == thisWidget then return end

        if anyFocusedWindow then
            -- update appearance to unfocus
            local TitleBar = focusedWindow.Instance["Window-TitleBar"]
            if focusedWindow.state.Collapsed then
                TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
            else
                TitleBar.BackgroundColor3 = Iris._style.TitleBgColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgTransparency
            end
            focusedWindow.Instance["UIStroke"].Color = Iris._style.BorderColor

            anyFocusedWindow = false
            focusedWindow = nil
        end

        if thisWidget ~= nil then
            anyFocusedWindow = true
            focusedWindow = thisWidget
            -- update appearance to focus
            local TitleBar = focusedWindow.Instance["Window-TitleBar"]
            TitleBar.BackgroundColor3 = Iris._style.TitleBgActiveColor
            TitleBar.BackgroundTransparency = Iris._style.TitleBgActiveTransparency
            focusedWindow.Instance["UIStroke"].Color = Iris._style.BorderActiveColor

            local reallocated = IncrementSortLayer()
            if reallocated then
                Iris.SetFocusedWindow(thisWidget)
            end

            local OldZIndex = thisWidget.ZIndex
            local NewZIndex = thisWidget.ZIndex - (thisWidget.SortLayer * 0xFFFFF) + (ZIndexSortLayer * 0xFFFFF)
            thisWidget.Instance.ZIndex = NewZIndex
            thisWidget.ZIndex = NewZIndex
            thisWidget.SortLayer = ZIndexSortLayer
            for i,v in thisWidget.Instance:GetDescendants() do
                if v:IsA("GuiObject") then
                    v.ZIndex = (v.ZIndex - OldZIndex) + NewZIndex
                end
            end
        end
    end

    local function quickSwapWindows()
        -- quick swapping, the kind of way that you might alt+tab or ctrl+tab.
        -- does not show any UI. also picking last ordered window instead of second to first.
        if gamepadMenuOpened then return end

        local oldWindows = getWindows()
        local Windows = {}
        for i,v in oldWindows do
            if (v.state.Closed == false) and (v.arguments.NoNav == false) then
                table.insert(Windows, oldWindows[i])
            end
        end
        table.sort(Windows,function(a,b)
            return a.SortLayer < b.SortLayer
        end)
        local SelectedWindow = Windows[1]

        if SelectedWindow.state.Collapsed then
            SelectedWindow.state.Collapsed = false
            Iris.widgets["Window"].UpdateState(SelectedWindow)
        end
        Iris.SetFocusedWindow(SelectedWindow)

        gamepadSelectWindow(SelectedWindow)
    end

    Iris.WidgetConstructor("Window", true, true){
        ArgNames = {
            [1] = "Title",
            [2] = "NoTitleBar",
            [3] = "NoBackground",
            [4] = "NoCollapse",
            [5] = "NoClose",
            [6] = "NoMove",
            [7] = "NoScrollbar",
            [8] = "NoResize",
            [9] = "NoNav"
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
            end,
            ["NoMove"] = function(_NoMove: boolean)
                return table.freeze({6, _NoMove})
            end,
            ["NoScrollbar"] = function(_NoScrollbar: boolean)
                return table.freeze({7, _NoScrollbar})
            end,
            ["NoResize"] = function(_NoResize: boolean)
                return table.freeze({8, _NoResize})
            end,
            ["NoNav"] = function(_NoNav: boolean)
                return table.freeze({9, _NoNav})
            end
        },

        UpdateState = function(thisWidget)
            thisWidget.Instance.Size = UDim2.fromOffset(thisWidget.state.Size.X, thisWidget.state.Size.Y)
            thisWidget.Instance.Position = UDim2.fromOffset(thisWidget.state.Position.X, thisWidget.state.Position.Y)

            local TitleBar = thisWidget.Instance["Window-TitleBar"]
            local ChildContainer = thisWidget.Instance["Window-ChildContainer"]
            local ResizeGrip = thisWidget.Instance["Window-UnlistedChildFolder"]["UnlistedChildFolder-ResizeGrip"]

            if thisWidget.state.Closed then
                thisWidget.Instance.Visible = false
            else
                thisWidget.Instance.Visible = true
            end

            if thisWidget.state.Collapsed then
                TitleBar["TitleBar-CollapseArrow"].Text = Icons.RightPointingTriangle

                ChildContainer.Visible = false
                ResizeGrip.Visible = false
                thisWidget.Instance.Size = UDim2.fromOffset(thisWidget.state.Size.X,0)
                thisWidget.Instance.AutomaticSize = Enum.AutomaticSize.Y
            else
                ChildContainer.Visible = true
                if thisWidget.arguments.NoResize == false then
                    ResizeGrip.Visible = true
                end
                thisWidget.Instance.AutomaticSize = Enum.AutomaticSize.None

                TitleBar["TitleBar-CollapseArrow"].Text = Icons.DownPointingTriangle
            end

            if not thisWidget.state.Closed and not thisWidget.state.Collapsed then
                Iris.SetFocusedWindow(thisWidget)
            else
                TitleBar.BackgroundColor3 = Iris._style.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._style.TitleBgCollapsedTransparency
                thisWidget.Instance["UIStroke"].Color = Iris._style.BorderColor

                Iris.SetFocusedWindow(nil)
            end
        end,

        Generate = function(thisWidget)
            IncrementSortLayer()
            thisWidget.ZIndex += ZIndexSortLayer * 0xFFFFF
            thisWidget.SortLayer = ZIndexSortLayer

            local Window = Instance.new("TextButton")
            Window.Name = "Iris:Window"
            Window.Size = UDim2.fromOffset(0,0)
            Window.BackgroundTransparency = 1
            Window.BorderSizePixel = 0
            Window.ZIndex = thisWidget.ZIndex
            Window.LayoutOrder = thisWidget.ZIndex
            Window.Size = UDim2.fromOffset(0,0)
            Window.AutomaticSize = Enum.AutomaticSize.None
            Window.ClipsDescendants = false
            Window.Text = ""
            Window.AutoButtonColor = false
            Window.Active = false
            Window.Selectable = false
            Window.SelectionImageObject = Iris.SelectionImageObject

            Window.SelectionGroup = true
            Window.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            Window.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            Window.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            Window.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
            
            Window.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then return end
                if not thisWidget.state.Collapsed then
                    Iris.SetFocusedWindow(thisWidget)
                end
                if not thisWidget.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragWindow = thisWidget
                    isDragging = true
                    deltaCursorPosition = UserInputService:GetMouseLocation() - thisWidget.state.Position
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
            ChildContainer.ZIndex = thisWidget.ZIndex + 1
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
            ChildContainer.AutomaticSize = Enum.AutomaticSize.None
            ChildContainer.Size = UDim2.fromScale(1,1)
            ChildContainer.Selectable = false

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._style.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._style.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0,1)
            
            ChildContainer.BackgroundColor3 = Iris._style.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
            ChildContainer.Parent = Window

            PadInstance(ChildContainer, Iris._style.WindowPadding)

            local TerminatingFrame = Instance.new("Frame")
            TerminatingFrame.Name = "ChildContainer-TerminatingFrame"
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0
            TerminatingFrame.Size = UDim2.fromOffset(0,0)
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.Size = UDim2.fromOffset(0,Iris._style.WindowPadding.Y + Iris._style.FramePadding.Y)
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
            TitleBar.ZIndex = thisWidget.ZIndex
            TitleBar.LayoutOrder = thisWidget.ZIndex
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
            CollapseArrow.ZIndex = thisWidget.ZIndex + 3
            CollapseArrow.AutomaticSize = Enum.AutomaticSize.None
            ApplyTextStyle(Iris, CollapseArrow)
            CollapseArrow.TextSize = Iris._style.FontSize
            CollapseArrow.Parent = TitleBar

            CollapseArrow.MouseButton1Click:Connect(function()
                thisWidget.state.Collapsed = not thisWidget.state.Collapsed
                if thisWidget.state.Collapsed then
                    thisWidget.events.Collapsed = true
                else
                    thisWidget.events.Opened = true
                end
                Iris.widgets.Window.UpdateState(thisWidget)
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
            CloseIcon.ZIndex = thisWidget.ZIndex + 3
            CloseIcon.AutomaticSize = Enum.AutomaticSize.None
            ApplyTextStyle(Iris, CloseIcon)
            CloseIcon.Font = Enum.Font.Code
            CloseIcon.TextSize = Iris._style.FontSize * 2
            CloseIcon.Text = Icons.MultiplicationSign
            CloseIcon.Parent = TitleBar

            RoundInstance(CloseIcon, 1e9)

            CloseIcon.MouseButton1Click:Connect(function()
                thisWidget.state.Closed = true
                thisWidget.events.Closed = true
                Iris.widgets.Window.UpdateState(thisWidget)
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
            Title.ZIndex = thisWidget.ZIndex + 2
            Title.AutomaticSize = Enum.AutomaticSize.XY
            ApplyTextStyle(Iris, Title)
            Title.Parent = TitleBar
            local TitleAlign = Iris._style.WindowTitleAlign == Enum.LeftRight.Left and 0 or Iris._style.WindowTitleAlign == Enum.LeftRight.Center and .5 or 1
            Title.Position = UDim2.fromScale(TitleAlign, 0)
            Title.AnchorPoint = Vector2.new(TitleAlign, 0)

            PadInstance(Title, Iris._style.FramePadding)

            local UnlistedChildFolder = Folder(Window)
            UnlistedChildFolder.Name = "Window-UnlistedChildFolder"

            local ResizeButtonSize = Iris._style.FontSize + Iris._style.FramePadding.X

            local ResizeGrip = Instance.new("TextButton")
            ResizeGrip.Name = "UnlistedChildFolder-ResizeGrip"
            ResizeGrip.AnchorPoint = Vector2.new(1,1)
            ResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            ResizeGrip.AutoButtonColor = false
            ResizeGrip.BorderSizePixel = 0
            ResizeGrip.BackgroundTransparency = 1
            ResizeGrip.Text = Icons.BottomRightCorner
            ResizeGrip.ZIndex = thisWidget.ZIndex + 2
            ResizeGrip.Position = UDim2.fromScale(1,1)
            ResizeGrip.TextSize = ResizeButtonSize
            ResizeGrip.TextColor3 = Iris._style.ButtonColor
            ResizeGrip.TextTransparency = Iris._style.ButtonTransparency
            ResizeGrip.LineHeight = 1.10 -- fix mild rendering issue
            ResizeGrip.Selectable = false
            
            ApplyInteractionHighlights(Iris, ResizeGrip, ResizeGrip, {
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
                     -- mitigating innacurate focus
                end
                isResizing = true
                resizeWindow = thisWidget
                resizeDeltaCursorPosition = UserInputService:GetMouseLocation() - thisWidget.state.Position - thisWidget.state.Size - Vector2.new(0,36)
            end)

            ResizeGrip.Parent = UnlistedChildFolder

            return Window
        end,

        Update = function(thisWidget)
            local TitleBar = thisWidget.Instance["Window-TitleBar"]
            local ChildContainer = thisWidget.Instance["Window-ChildContainer"]
            local ResizeGrip = thisWidget.Instance["Window-UnlistedChildFolder"]["UnlistedChildFolder-ResizeGrip"]
            local TitleBarWidth = Iris._style.FontSize + Iris._style.FramePadding.Y * 2
            if thisWidget.arguments.NoResize then
                ResizeGrip.Visible = false
            else
                ResizeGrip.Visible = true
            end
            if thisWidget.arguments.NoScrollbar then
                ChildContainer.ScrollBarThickness = 0
            else
                ChildContainer.ScrollBarThickness = Iris._style.ScrollbarSize
            end
            if thisWidget.arguments.NoTitleBar then
                TitleBar.Visible = false
                ChildContainer.Size = UDim2.new(1,0,1,0)
                ChildContainer.CanvasSize = UDim2.new(0,0,1,0)
            else
                TitleBar.Visible = true
                ChildContainer.Size = UDim2.new(1,0,1,-TitleBarWidth)
                ChildContainer.CanvasSize = UDim2.new(0,0,1,-TitleBarWidth)
            end
            if thisWidget.arguments.NoBackground then
                ChildContainer.BackgroundTransparency = 1
            else
                ChildContainer.BackgroundTransparency = Iris._style.WindowBgTransparency
            end
            local TitleButtonPaddingSize = Iris._style.FramePadding.X + Iris._style.FontSize + Iris._style.FramePadding.X * 2
            if thisWidget.arguments.NoCollapse then
                TitleBar["TitleBar-CollapseArrow"].Visible = false
                TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0, Iris._style.FramePadding.X)
            else
                TitleBar["TitleBar-CollapseArrow"].Visible = true
                TitleBar["TitleBar-Title"]["UIPadding"].PaddingLeft = UDim.new(0, TitleButtonPaddingSize)
            end
            if thisWidget.arguments.NoClose then
                TitleBar["TitleBar-CloseIcon"].Visible = false
                TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0, Iris._style.FramePadding.X)
            else
                TitleBar["TitleBar-CloseIcon"].Visible = true
                TitleBar["TitleBar-Title"]["UIPadding"].PaddingRight = UDim.new(0, TitleButtonPaddingSize)
            end

            local Title = thisWidget.Instance["Window-TitleBar"]["TitleBar-Title"]
            Title.Text = thisWidget.arguments.Title or ""
        end,

        Discard = function(thisWidget)
            if focusedWindow == thisWidget then
                focusedWindow = nil
                anyFocusedWindow = false
            end
            thisWidget.Instance:Destroy()
        end,

        GetParentInstance = function(thisWidget)
            return thisWidget.Instance["Window-ChildContainer"]
        end,

        GenerateState = function(thisWidget)
            return {
                Size = Vector2.new(400,300),
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
        if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 then
            Iris.SetFocusedWindow(nil)
        end
        if input.KeyCode == Enum.KeyCode.ButtonX then
            coroutine.resume(gamepadMenuCoroutine)
        end

        if input.KeyCode == Enum.KeyCode.Tab and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            quickSwapWindows()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging then
            local mouseLocation = UserInputService:GetMouseLocation()
            local newPosX, newPosY = 
            math.min(
                math.max(mouseLocation.X - deltaCursorPosition.X, Iris._style.WindowBorderSize),
                Iris.parentInstance.AbsoluteSize.X - dragWindow.Instance.AbsoluteSize.X - Iris._style.WindowBorderSize
            ),
            math.min(
                math.max(mouseLocation.Y - deltaCursorPosition.Y, Iris._style.WindowBorderSize),
                Iris.parentInstance.AbsoluteSize.Y - dragWindow.Instance.AbsoluteSize.Y - Iris._style.WindowBorderSize
            )

            dragWindow.Instance.Position = UDim2.fromOffset(newPosX, newPosY)
            dragWindow.state.Position = Vector2.new(newPosX, newPosY)
        end
        if isResizing then
            local MinWindowSize = (Iris._style.FontSize + Iris._style.FramePadding.Y * 2) * 2
            local MaxWindowSize = (Iris.parentInstance.AbsoluteSize -
            Vector2.new(resizeWindow.Instance.Position.X.Offset, resizeWindow.Instance.Position.Y.Offset) -
            Vector2.new(Iris._style.WindowBorderSize, Iris._style.WindowBorderSize))

            local mouseLocation = UserInputService:GetMouseLocation()
            local newSize = (mouseLocation - resizeWindow.state.Position) - Vector2.new(0,36) - resizeDeltaCursorPosition
            newSize = Vector2.new(
                math.min(math.max(MinWindowSize, newSize.X), MaxWindowSize.X),
                math.min(math.max(MinWindowSize, newSize.Y), MaxWindowSize.Y)
            )
            resizeWindow.Instance.Size = UDim2.fromOffset(newSize.X, newSize.Y)
            resizeWindow.state.Size = newSize
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            dragWindow.state.Position = Vector2.new(dragWindow.Instance.Position.X.Offset, dragWindow.Instance.Position.Y.Offset)
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
            isResizing = false
            resizeWindow.state.Size = resizeWindow.Instance.AbsoluteSize
        end

        if input.KeyCode == Enum.KeyCode.ButtonX then
            gamepadMenuStartEnded = true
            if os.clock() - gamepadMenuStartOpenedDelta <= GAMEPAD_MENU_START_HOLD_TIME then
                quickSwapWindows()
            else
                gamepadMenuBehavior(false)
            end
        end
    end)
end

end