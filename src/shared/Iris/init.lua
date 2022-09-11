local Iris = {}
Iris.__index = Iris

local widgets = require(script.widgets)

-- private

-- https://web.archive.org/web/20131225070434/http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
function deepcompare(t1,t2)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    if #t1 ~= #t2 then return false end
    for i = 1, #t1 do
        local v1 = t1[i]
        local v2 = t2[i]
        -- TODO, does this like actually recurse
        if v2 ~= v1 or not deepcompare(v1,v2) then return false end
    end

    return true
end

function Iris:_GenerateRoot()
    return {Id = "Root", Children = {}, Instance = self.root}
end

function Iris:_InsertIntoTree(Widget, ...)
    -- TODO this entire function should be revised.

    self._WidgetsThisCycle += 1
    local indexArguments = {}
    for i,v in pairs({...}) do
        if type(v) == "table" then
            indexArguments[v[1]] = v[2]
        else
            indexArguments[i] = v
        end
    end
    local newArguments = {}
    for i,v in pairs(indexArguments) do
        newArguments[widgets.widgetArgumentIndicies[Widget.Id][i]] = v
    end

    local parentWidget = self._WidgetStack[self._StackPointer]
    local EventBin = {}

    local widgetMayHaveChildren = widgets.widgetsWhichMayHaveChildren[Widget.Id]
    local widgetHasState = widgets.widgetsWhichHaveState[Widget.Id]

    local PointedStackWidget = self._LastWidgetTree

    -- this section attempts to find the widget in the last frame.
    -- it navigates through the stack, aborting if they have deviated.
    for StackIndex = 2, self._StackPointer do
        local PossibleStackChild = PointedStackWidget.Children[self._IndexWidgetStack[StackIndex]]
        if PossibleStackChild then
            PointedStackWidget = PossibleStackChild
        else
            PointedStackWidget = false
            break
        end
    end

    -- if a window is index #3 last frame, but this frame window #2 is not rendered, the window will take the index #2.
    -- the issue is that for state like window position, or isCollapsed, they will inherit from last frames window #2 instead of #3.
    -- the solution for DearImGui is pushID and popID, as well as defining Id based on arguments, like Title or text. it works pretty well so we will do that
    -- in Iris have a table with every Id and the state ascociated with it.

    if widgetHasState then
        Widget.StateId = debug.info(3,"l") .. self._StoredStatePostfixId
    end

    local IsGenerated = false
    if PointedStackWidget then
        local LastFrameWidget = PointedStackWidget.Children[#parentWidget.Children + 1]
        if LastFrameWidget then
            local StateMatches
            if widgetHasState and widgets.widgetsWhichHaveState[LastFrameWidget.Id] and LastFrameWidget.StateId then
                StateMatches = (LastFrameWidget.StateId == Widget.StateId)
            else
                StateMatches = true
            end
    
            if StateMatches and Widget.Id == LastFrameWidget.Id then
                -- checking if widget arguments changed
                local ArgumentsChanged = not deepcompare(LastFrameWidget.IndexArguments, indexArguments)

                Widget.Arguments = newArguments
                Widget.IndexArguments = indexArguments
                if widgetMayHaveChildren then
                    Widget.Children = table.create(#LastFrameWidget.Children)
                end
                Widget.Instance = LastFrameWidget.Instance
                if widgetHasState then
                    Widget.State = LastFrameWidget.State
                end
                if ArgumentsChanged then
                    widgets.widgets[Widget.Id].Update(self, Widget)
                end
                
                -- collecting and emptying the bin
                Widget.EventBin = LastFrameWidget.EventBin -- have to be careful not to override reference to this table. Widget Events will reference it.
                -- TODO: doing some shit with __newindex to maintain reference should be more efficient than cloning
                EventBin = table.clone(Widget.EventBin)
                table.clear(Widget.EventBin)
    
                LastFrameWidget.Fresh = true
    
                IsGenerated = true

            end
        end
    end

    if not IsGenerated then
        Widget.Arguments = newArguments
        Widget.EventBin = {}
        if widgetHasState then
            Widget.State = self._StoredStates[Widget.StateId] or widgets.widgets[Widget.Id].GenerateNewState(Iris, Widget)
        end
        if widgetMayHaveChildren then
            Widget.Children = {}
        end

        Widget.Instance = widgets.widgets[Widget.Id].Generate(self, Widget)
        widgets.widgets[Widget.Id].Update(self, Widget)
        
        Widget.Instance.Parent = widgets.widgets[parentWidget.Id].GetParentableInstance(parentWidget, Widget)
    end

    if widgetHasState then
        self._StoredStates[Widget.StateId] = Widget.State
    end
    table.insert(parentWidget.Children, Widget)

    if widgetMayHaveChildren then
        -- TODO, add an optimization where the widget can say here that its children shouldnt be inserted into the tree.
        -- in cases like if window is collapsed/closed or tree is collapsed.

        -- begin in the context of new GUI scope, where Dear ImGui functions may be prefix with "Begin"
        -- takes last inserted widget and pushes it onto _WidgetStack
        local lastWidgetIndex = #self._WidgetStack[self._StackPointer].Children
        local lastWidget = self._WidgetStack[self._StackPointer].Children[lastWidgetIndex]
        self._WidgetStack[self._StackPointer + 1] = lastWidget
        self._IndexWidgetStack[self._StackPointer + 1] = lastWidgetIndex
        self._StackPointer += 1
    end

    self._StoredStatePostfixId = ""

    return EventBin
end

function Iris:_DiscardOldWidgets()

    local function LoopWidgetTree(ParentWidget)
        for _, currentWidget in pairs(ParentWidget.Children) do
            if widgets.widgetsWhichMayHaveChildren[currentWidget.Id] then
                LoopWidgetTree(currentWidget)
            end
            if not currentWidget.Fresh then
                --print(string.format("a %s was discarded", currentWidget.Id))
                widgets.widgets[currentWidget.Id].Discard(self, currentWidget)
            end
        end
    end
    LoopWidgetTree(self._LastWidgetTree)
end

function Iris:_Cycle(callback)
    debug.profilebegin("Iris Cycle")

    self._StackPointer = 1
    self._WidgetsThisCycle = 0
    self._WidgetStack[self._StackPointer] = self._WidgetTree

    debug.profilebegin("Iris Callback")
    -- TODO, put a pcall or other error handling idiom here to prevent the bug where widgets are generated but never discarded every frame when it errors.
    callback()
    debug.profileend()

    -- checking if last frame widgets arent rendered anymore
    debug.profilebegin("Iris DiscardOldWidgets")
    self:_DiscardOldWidgets()
    debug.profileend()

    assert(self._StackPointer == 1, "wrong amount of Iris:End()")

    self._LastWidgetTree = self._WidgetTree
    self._WidgetTree = self:_GenerateRoot()

    if self._ForceRefresh then
        self._ForceRefresh = false
        self.root:ClearAllChildren()
        widgets.widgets["Root"].Generate(self).Parent = self.root
        self._LastWidgetTree = self:_GenerateRoot()
    end

    debug.profileend()
end

-- public

function Iris:Connect(eventConnection, callback)
    -- TODO, throw an error if Connect is called more than once
    self.root:ClearAllChildren() -- dont get mad when you forget about this line
    widgets.widgets["Root"].Generate(self).Parent = self.root

    task.spawn(function()
        if eventConnection.Connect then
            eventConnection:Connect(function()
                self:_Cycle(callback)
            end)
        else
            while eventConnection() do
                self:_Cycle(callback)
            end
        end
    end)
end

function Iris:SetStyle(NewStyle)
    local NeedsRefresh = false
    for Name, Value in pairs(NewStyle) do
        assert(self._Style[Name], "Invalid Style Property")
        assert(typeof(self._Style[Name]) == typeof(Value), "Invalid Type for Style")
        NeedsRefresh = NeedsRefresh or (self._Style[Name] ~= Value)
        self._Style[Name] = Value
    end
    if NeedsRefresh then
        self._ForceRefresh = true
    end
end

function Iris:Text(...)
    return self:_InsertIntoTree({Id = "Text"}, ...)
end

function Iris:Button(...)
    return self:_InsertIntoTree({Id = "Button"}, ...)
end

function Iris:Tree(...)
    return self:_InsertIntoTree({Id = "Tree"}, ...)
end

function Iris:Window(...)
    return self:_InsertIntoTree({Id = "Window"}, ...)
end

-- TODO, this might need to be changed in favor of the Dear ImGui PopId and PushId system,
-- consider the case where 2 windows are called from the same line, both containing 5 tree nodes called from the same line
function Iris:UseId(StringId)
    self._StoredStatePostfixId = StringId
end

function Iris:End()
    self._StackPointer -= 1
end

Iris.Args = widgets.Args

return function(rootInstance)
    local self = setmetatable({
        root = rootInstance
    }, Iris)

    self._Style = {
        -- TODO, split this into its own static table of template styles, along with a light theme and more, then use the self.SetStyle method to copy it into self._Style
        WindowPadding = Vector2.new(8,8),
        FramePadding = Vector2.new(4,3),
        ItemSpacing = Vector2.new(8,4),
        IndentSpacing = 21,
        Font = Enum.Font.Code,
        FontSize = 13,
        FrameBorderSize = 0,
        WindowBorderSize = 1,
        WindowTitleAlign = Enum.LeftRight.Left,
        
        TextColor = Color3.fromRGB(255,255,255),
        TextTransparency = 0,

        BorderColor = Color3.fromRGB(110, 110, 125), -- 110, 110, 125
        --BorderTransparency = 0.5, --will be problematic for non UIStroke border implimentations, could get around limitation using some color blending with WindowBg or FrameBg

        WindowBgColor = Color3.fromRGB(15,15,15),
        WindowBgTransparency = 0.072,

        TitleBgColor = Color3.fromRGB(10, 10, 10),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(41, 74, 122),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(0, 0, 0),
        TitleBgCollapsedTransparency = .5,

        ButtonColor = Color3.fromRGB(66,150,250),
        ButtonTransparency = 0.6,
        ButtonHoveredColor = Color3.fromRGB(66,150,250),
        ButtonHoveredTransparency = 0,
        ButtonActiveColor = Color3.fromRGB(15,135,250),
        ButtonActiveTransparency = 0,

        HeaderColor = Color3.fromRGB(66,150,250),
        HeaderTransparency = 0.31,
        HeaderHoveredColor = Color3.fromRGB(66,150,250),
        HeaderHoveredTransparency = 0.2,
        HeaderActiveColor = Color3.fromRGB(66,150,250),
        HeaderActiveTransparency = 0,
    }

    self._LastWidgetTree = self:_GenerateRoot()
    self._WidgetTree = self:_GenerateRoot()

    -- for traversing the WidgetTree and for validating that the user manages parent widgets correctly
    self._StackPointer = 1
    
    -- used for counting widgets and for determining z index as widgets generate
    self._WidgetsThisCycle = 0

    -- Stack trace of widgets, used when generating
    self._WidgetStack = {}

    -- Numeric indicies of _WidgetStack
    self._IndexWidgetStack = {}

    -- for widgets which have state, their State object is stored using their stateId in here, for retrival when they are generated
    self._StoredStates = {}

    -- flag which is checked after every cycle, used by SetStyle to reset the widgets according to style
    self._ForceRefresh = false

    -- TODO this should be removed in favor of new method eventually
    -- diy solution to mimic Dear ImGui's PushId and PopId methods
    self._StoredStatePostfixId = ""

    -- root instance
    self.root = rootInstance
    return self
end