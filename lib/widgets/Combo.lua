local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

local btest = bit32.btest

export type Selectable = Types.Widget & {
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string?,
        Index: any?,
        Flags: number,
    },

    state: {
        index: Types.State<any>,
    },
} & Types.Selected & Types.Unselected & Types.Clicked & Types.RightClicked & Types.DoubleClicked & Types.CtrlClicked & Types.Hovered

export type Combo = Types.ParentWidget & {
    arguments: {
        Text: string?,
        Flags: number,
    },

    state: {
        index: Types.State<any>,
        open: Types.State<boolean>,
    },

    UIListLayout: UIListLayout,
} & Types.Opened & Types.Closed & Types.Changed & Types.Clicked & Types.Hovered

local ComboFlags = {
    NoClick = 1,
    NoButton = 2,
    NoPreview = 4,
}

local AnyOpenedCombo = false
local ComboOpenedTick = -1
local OpenedCombo: Combo? = nil
local CachedContentSize = 0

local function UpdateChildContainerTransform(thisWidget: Combo)
    local Combo = thisWidget.instance :: Frame
    local PreviewContainer = Combo.PreviewContainer :: TextButton
    local ChildContainer = thisWidget.childContainer :: ScrollingFrame

    local previewPosition = PreviewContainer.AbsolutePosition - Utility.guiOffset
    local previewSize = PreviewContainer.AbsoluteSize
    local borderSize = Internal._config.PopupBorderSize
    local screenSize: Vector2 = ChildContainer.Parent.AbsoluteSize

    local absoluteContentSize = thisWidget.UIListLayout.AbsoluteContentSize.Y
    CachedContentSize = absoluteContentSize

    local contentsSize = absoluteContentSize + 2 * Internal._config.WindowPadding.Y

    local x = previewPosition.X
    local y = previewPosition.Y + previewSize.Y + borderSize
    local anchor = Vector2.zero
    local distanceToScreen = screenSize.Y - y

    -- Only extend upwards if we cannot fully extend downwards, and we are on the bottom half of the screen.
    --  i.e. there is more space upwards than there is downwards.
    if contentsSize > distanceToScreen and y > (screenSize.Y / 2) then
        y = previewPosition.Y - borderSize
        anchor = Vector2.yAxis
        distanceToScreen = y -- from 0 to the current position
    end

    ChildContainer.AnchorPoint = anchor
    ChildContainer.Position = UDim2.fromOffset(x, y)

    local height = math.min(contentsSize, distanceToScreen)
    ChildContainer.Size = UDim2.fromOffset(PreviewContainer.AbsoluteSize.X, height)
end

local function UpdateComboState(input: InputObject)
    if not Internal._started then
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseWheel then
        return
    end
    if AnyOpenedCombo == false or not OpenedCombo then
        return
    end
    if ComboOpenedTick == Internal._cycleTick then
        return
    end

    local MouseLocation = Utility.getMouseLocation()
    local Combo = OpenedCombo.instance :: Frame
    local PreviewContainer: TextButton = Combo.PreviewContainer
    local ChildContainer = OpenedCombo.childContainer
    local rectMin = PreviewContainer.AbsolutePosition - Utility.guiOffset
    local rectMax = PreviewContainer.AbsolutePosition - Utility.guiOffset + PreviewContainer.AbsoluteSize
    if Utility.isPosInsideRect(MouseLocation, rectMin, rectMax) then
        return
    end

    rectMin = ChildContainer.AbsolutePosition - Utility.guiOffset
    rectMax = ChildContainer.AbsolutePosition - Utility.guiOffset + ChildContainer.AbsoluteSize
    if Utility.isPosInsideRect(MouseLocation, rectMin, rectMax) then
        return
    end

    OpenedCombo.state.open:set(false)
end

table.insert(Internal._postCycleCallbacks, function()
    if AnyOpenedCombo and OpenedCombo then
        local contentSize = OpenedCombo.UIListLayout.AbsoluteContentSize.Y
        if contentSize ~= CachedContentSize then
            UpdateChildContainerTransform(OpenedCombo)
        end
    end
end)

Utility.registerEvent("InputBegan", UpdateComboState)

Utility.registerEvent("InputChanged", UpdateComboState)

----------------
-- Selectable
----------------

Internal._widgetConstructor(
    "Selectable",
    {
        hasState = true,
        hasChildren = false,
        numArguments = 3,
        Arguments = { "Text", "Index", "Flags", "index" },
        Events = {
            ["selected"] = {
                ["Init"] = function(_thisWidget: Selectable) end,
                ["Get"] = function(thisWidget: Selectable)
                    return thisWidget._lastSelectedTick == Internal._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: Selectable) end,
                ["Get"] = function(thisWidget: Selectable)
                    return thisWidget._lastUnselectedTick == Internal._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: Selectable) end,
                ["Get"] = function(thisWidget: Selectable)
                    return thisWidget.state.index._value == thisWidget.arguments.Index
                end,
            },
            ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.instance :: Frame
                return Selectable.SelectableButton
            end),
            ["rightClicked"] = Utility.EVENTS.rightClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.instance :: Frame
                return Selectable.SelectableButton
            end),
            ["doubleClicked"] = Utility.EVENTS.doubleClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.instance :: Frame
                return Selectable.SelectableButton
            end),
            ["ctrlClicked"] = Utility.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.instance :: Frame
                return Selectable.SelectableButton
            end),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                local Selectable = thisWidget.instance :: Frame
                return Selectable.SelectableButton
            end),
        },
        Generate = function(thisWidget: Selectable)
            local Selectable = Instance.new("Frame")
            Selectable.Name = "Iris_Selectable"
            Selectable.Size = UDim2.new(Internal._config.ItemWidth, UDim.new(0, Internal._config.TextSize + 2 * Internal._config.FramePadding.Y - Internal._config.ItemSpacing.Y))
            Selectable.BackgroundTransparency = 1
            Selectable.BorderSizePixel = 0

            local SelectableButton = Instance.new("TextButton")
            SelectableButton.Name = "SelectableButton"
            SelectableButton.Size = UDim2.new(1, 0, 0, Internal._config.TextSize + 2 * Internal._config.FramePadding.Y)
            SelectableButton.Position = UDim2.fromOffset(0, -bit32.rshift(Internal._config.ItemSpacing.Y, 1)) -- divide by 2
            SelectableButton.BackgroundColor3 = Internal._config.HeaderColor
            SelectableButton.ClipsDescendants = true

            Utility.applyFrameStyle(SelectableButton)
            Utility.applyTextStyle(SelectableButton)
            Utility.UISizeConstraint(SelectableButton, Vector2.xAxis)

            thisWidget.ButtonColors = {
                Color = Internal._config.HeaderColor,
                Transparency = 1,
                HoveredColor = Internal._config.HeaderHoveredColor,
                HoveredTransparency = Internal._config.HeaderHoveredTransparency,
                ActiveColor = Internal._config.HeaderActiveColor,
                ActiveTransparency = Internal._config.HeaderActiveTransparency,
            }

            Utility.applyInteractionHighlights("Background", SelectableButton, SelectableButton, thisWidget.ButtonColors)

            Utility.applyButtonClick(SelectableButton, function()
                if not btest(ComboFlags.NoClick, thisWidget.arguments.Flags) then
                    if type(thisWidget.state.index._value) == "boolean" then
                        thisWidget.state.index:set(not thisWidget.state.index._value)
                    else
                        thisWidget.state.index:set(thisWidget.arguments.Index)
                    end
                end
            end)

            SelectableButton.Parent = Selectable

            return Selectable
        end,
        GenerateState = function(thisWidget: Selectable)
            if thisWidget.state.index == nil then
                if thisWidget.arguments.Index ~= nil then
                    error("A shared state index is required for Iris.Selectables() with an Index argument.", 5)
                end
                thisWidget.state.index = Internal._widgetState(thisWidget, "index", false)
            end
        end,
        Update = function(thisWidget: Selectable)
            local Selectable = thisWidget.instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton
            SelectableButton.Text = thisWidget.arguments.Text or "Selectable"
        end,
        UpdateState = function(thisWidget: Selectable)
            local Selectable = thisWidget.instance :: Frame
            local SelectableButton: TextButton = Selectable.SelectableButton

            if thisWidget.state.index._value == thisWidget.arguments.Index or thisWidget.state.index._value == true then
                thisWidget.ButtonColors.Transparency = Internal._config.HeaderTransparency
                SelectableButton.BackgroundTransparency = Internal._config.HeaderTransparency
                thisWidget._lastSelectedTick = Internal._cycleTick + 1
            else
                thisWidget.ButtonColors.Transparency = 1
                SelectableButton.BackgroundTransparency = 1
                thisWidget._lastUnselectedTick = Internal._cycleTick + 1
            end
        end,
        Discard = function(thisWidget: Selectable)
            thisWidget.instance:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

-----------
-- Combo
-----------

Internal._widgetConstructor(
    "Combo",
    {
        hasState = true,
        hasChildren = true,
        numArguments = 2,
        Arguments = { "Text", "Flags", "index", "open" },
        Events = {
            ["opened"] = {
                ["Init"] = function(_thisWidget: Combo) end,
                ["Get"] = function(thisWidget: Combo)
                    return thisWidget._lastOpenedTick == Internal._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Combo) end,
                ["Get"] = function(thisWidget: Combo)
                    return thisWidget._lastClosedTick == Internal._cycleTick
                end,
            },
            ["changed"] = {
                ["Init"] = function(_thisWidget: Combo) end,
                ["Get"] = function(thisWidget: Combo)
                    return thisWidget._lastChangedTick == Internal._cycleTick
                end,
            },
            ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                local Combo = thisWidget.instance :: Frame
                return Combo.PreviewContainer
            end),
            ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.instance
            end),
        },
        Generate = function(thisWidget: Combo)
            local frameHeight = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y

            local Combo = Instance.new("Frame")
            Combo.Name = "Iris_Combo"
            Combo.AutomaticSize = Enum.AutomaticSize.Y
            Combo.Size = UDim2.new(Internal._config.ItemWidth, UDim.new())
            Combo.BackgroundTransparency = 1
            Combo.BorderSizePixel = 0

            Utility.UIListLayout(Combo, Enum.FillDirection.Horizontal, UDim.new(0, Internal._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local PreviewContainer = Instance.new("TextButton")
            PreviewContainer.Name = "PreviewContainer"
            PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            PreviewContainer.Size = UDim2.new(Internal._config.ContentWidth, UDim.new(0, 0))
            PreviewContainer.BackgroundTransparency = 1
            PreviewContainer.Text = ""
            PreviewContainer.AutoButtonColor = false
            PreviewContainer.ZIndex = 2

            Utility.applyFrameStyle(PreviewContainer, true)
            Utility.UIListLayout(PreviewContainer, Enum.FillDirection.Horizontal, UDim.new(0, 0))
            Utility.UISizeConstraint(PreviewContainer, Vector2.new(frameHeight))

            PreviewContainer.Parent = Combo

            local PreviewLabel = Instance.new("TextLabel")
            PreviewLabel.Name = "PreviewLabel"
            PreviewLabel.AutomaticSize = Enum.AutomaticSize.Y
            PreviewLabel.Size = UDim2.new(UDim.new(1, 0), Internal._config.ContentHeight)
            PreviewLabel.BackgroundColor3 = Internal._config.FrameBgColor
            PreviewLabel.BackgroundTransparency = Internal._config.FrameBgTransparency
            PreviewLabel.BorderSizePixel = 0
            PreviewLabel.ClipsDescendants = true

            Utility.applyTextStyle(PreviewLabel)
            Utility.UIPadding(PreviewLabel, Internal._config.FramePadding)

            PreviewLabel.Parent = PreviewContainer

            local DropdownButton = Instance.new("TextLabel")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Size = UDim2.new(0, frameHeight, Internal._config.ContentHeight.Scale, math.max(Internal._config.ContentHeight.Offset, frameHeight))
            DropdownButton.BackgroundColor3 = Internal._config.ButtonColor
            DropdownButton.BackgroundTransparency = Internal._config.ButtonTransparency
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Text = ""

            local padding = math.round(frameHeight * 0.2)
            local dropdownSize = frameHeight - 2 * padding

            local Dropdown = Instance.new("ImageLabel")
            Dropdown.Name = "Dropdown"
            Dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
            Dropdown.Size = UDim2.fromOffset(dropdownSize, dropdownSize)
            Dropdown.Position = UDim2.fromScale(0.5, 0.5)
            Dropdown.BackgroundTransparency = 1
            Dropdown.BorderSizePixel = 0
            Dropdown.ImageColor3 = Internal._config.TextColor
            Dropdown.ImageTransparency = Internal._config.TextTransparency

            Dropdown.Parent = DropdownButton

            DropdownButton.Parent = PreviewContainer

            -- for some reason ImGui Combo has no highlights for Active, only hovered.
            -- so this deviates from ImGui, but its a good UX change
            Utility.applyInteractionHighlightsWithMultiHighlightee("Background", PreviewContainer, {
                {
                    PreviewLabel,
                    {
                        Color = Internal._config.FrameBgColor,
                        Transparency = Internal._config.FrameBgTransparency,
                        HoveredColor = Internal._config.FrameBgHoveredColor,
                        HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
                        ActiveColor = Internal._config.FrameBgActiveColor,
                        ActiveTransparency = Internal._config.FrameBgActiveTransparency,
                    },
                },
                {
                    DropdownButton,
                    {
                        Color = Internal._config.ButtonColor,
                        Transparency = Internal._config.ButtonTransparency,
                        HoveredColor = Internal._config.ButtonHoveredColor,
                        HoveredTransparency = Internal._config.ButtonHoveredTransparency,
                        -- Use hovered for active
                        ActiveColor = Internal._config.ButtonHoveredColor,
                        ActiveTransparency = Internal._config.ButtonHoveredTransparency,
                    },
                },
            })

            Utility.applyButtonClick(PreviewContainer, function()
                if AnyOpenedCombo and OpenedCombo ~= thisWidget then
                    return
                end
                thisWidget.state.open:set(not thisWidget.state.open._value)
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.Size = UDim2.fromOffset(0, frameHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            Utility.applyTextStyle(TextLabel)

            TextLabel.Parent = Combo

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ComboContainer"
            ChildContainer.BackgroundColor3 = Internal._config.PopupBgColor
            ChildContainer.BackgroundTransparency = Internal._config.PopupBgTransparency
            ChildContainer.BorderSizePixel = 0

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Internal._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Internal._config.ScrollbarGrabColor
            ChildContainer.ScrollBarThickness = Internal._config.ScrollbarSize
            ChildContainer.CanvasSize = UDim2.fromScale(0, 0)
            ChildContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
            ChildContainer.TopImage = Utility.ICONS.BLANK_SQUARE
            ChildContainer.MidImage = Utility.ICONS.BLANK_SQUARE
            ChildContainer.BottomImage = Utility.ICONS.BLANK_SQUARE

            -- appear over everything else
            ChildContainer.ClipsDescendants = true

            -- Unfortunatley, ScrollingFrame does not work with UICorner
            -- if Internal._config.PopupRounding > 0 then
            --     Utility.UICorner(ChildContainer, Internal._config.PopupRounding)
            -- end

            Utility.UIStroke(ChildContainer, Internal._config.WindowBorderSize, Internal._config.BorderColor, Internal._config.BorderTransparency)
            Utility.UIPadding(ChildContainer, Vector2.new(2, Internal._config.WindowPadding.Y))
            Utility.UISizeConstraint(ChildContainer, Vector2.new(100))

            local ChildContainerUIListLayout = Utility.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Internal._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local RootPopupScreenGui = Internal._rootInstance and Internal._rootInstance:WaitForChild("PopupScreenGui") :: GuiObject
            ChildContainer.Parent = RootPopupScreenGui

            thisWidget.childContainer = ChildContainer
            thisWidget.UIListLayout = ChildContainerUIListLayout
            return Combo
        end,
        GenerateState = function(thisWidget: Combo)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Internal._widgetState(thisWidget, "index", "No Selection")
            end
            if thisWidget.state.open == nil then
                thisWidget.state.open = Internal._widgetState(thisWidget, "open", false)
            end

            thisWidget.state.index:onChange(function()
                thisWidget._lastChangedTick = Internal._cycleTick + 1
                if thisWidget.state.open._value then
                    thisWidget.state.open:set(false)
                end
            end)
        end,
        Update = function(thisWidget: Combo)
            local Iris_Combo = thisWidget.instance :: Frame
            local PreviewContainer = Iris_Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton: TextLabel = PreviewContainer.DropdownButton
            local TextLabel: TextLabel = Iris_Combo.TextLabel

            TextLabel.Text = thisWidget.arguments.Text or "Combo"

            if btest(ComboFlags.NoButton, thisWidget.arguments.Flags) then
                DropdownButton.Visible = false
                PreviewLabel.Size = UDim2.new(UDim.new(1, 0), PreviewLabel.Size.Height)
            else
                DropdownButton.Visible = true
                local DropdownButtonSize = Internal._config.TextSize + 2 * Internal._config.FramePadding.Y
                PreviewLabel.Size = UDim2.new(UDim.new(1, -DropdownButtonSize), PreviewLabel.Size.Height)
            end

            if btest(ComboFlags.NoPreview, thisWidget.arguments.Flags) then
                PreviewLabel.Visible = false
                PreviewContainer.Size = UDim2.new(0, 0, 0, 0)
                PreviewContainer.AutomaticSize = Enum.AutomaticSize.XY
            else
                PreviewLabel.Visible = true
                PreviewContainer.Size = UDim2.new(Internal._config.ContentWidth, Internal._config.ContentHeight)
                PreviewContainer.AutomaticSize = Enum.AutomaticSize.Y
            end
        end,
        UpdateState = function(thisWidget: Combo)
            local Combo = thisWidget.instance :: Frame
            local ChildContainer = thisWidget.childContainer :: ScrollingFrame
            local PreviewContainer = Combo.PreviewContainer :: TextButton
            local PreviewLabel: TextLabel = PreviewContainer.PreviewLabel
            local DropdownButton = PreviewContainer.DropdownButton :: TextLabel
            local Dropdown: ImageLabel = DropdownButton.Dropdown

            if thisWidget.state.open._value then
                AnyOpenedCombo = true
                OpenedCombo = thisWidget
                ComboOpenedTick = Internal._cycleTick
                thisWidget._lastOpenedTick = Internal._cycleTick + 1

                -- ImGui also does not do this, and the Arrow is always facing down
                Dropdown.Image = Utility.ICONS.RIGHT_POINTING_TRIANGLE
                ChildContainer.Visible = true

                UpdateChildContainerTransform(thisWidget)
            else
                if AnyOpenedCombo then
                    AnyOpenedCombo = false
                    OpenedCombo = nil
                    thisWidget._lastClosedTick = Internal._cycleTick + 1
                end
                Dropdown.Image = Utility.ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = false
            end

            local stateIndex = thisWidget.state.index._value
            PreviewLabel.Text = if typeof(stateIndex) == "EnumItem" then stateIndex.Name else tostring(stateIndex)
        end,
        ChildAdded = function(thisWidget: Combo, _thisChild: Types.Widget)
            UpdateChildContainerTransform(thisWidget)
            return thisWidget.childContainer
        end,
        Discard = function(thisWidget: Combo)
            -- If we are discarding the current combo active, we need to hide it
            if OpenedCombo and OpenedCombo == thisWidget then
                OpenedCombo = nil
                AnyOpenedCombo = false
            end

            thisWidget.instance:Destroy()
            thisWidget.childContainer:Destroy()
            Utility.discardState(thisWidget)
        end,
    } :: Types.WidgetClass
)

return {
    ComboFlags = ComboFlags,
}
