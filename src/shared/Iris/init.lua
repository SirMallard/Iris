--!optimize 2
local Iris = {}

local started = false -- has Iris.connect been called yet
local refreshRequested = false -- refresh means that all GUI is destroyed and regenerated, usually because a style change was made and needed to be propogated to all UI

local widgets = {} -- table of generatedWidgets, not runtime widgets
Iris.widgets = widgets

local rootStyle = {} -- root style which all widgets derive from
Iris._style = rootStyle

local rootInstance

local rootWidget = {
    ID = "R",
    type = "Root",
    Instance = rootInstance,
    ZIndex = 0,
}

local States = {} -- Iris.States

local IDStack = {"R"}
Iris._IDStack = IDStack
local UsedIDs = {} -- hash of IDs which are already used in a cycle, value is the # of occurances so that GetID can assign a unique ID for each occurance
Iris._stackIndex = 1 -- Points to the index that IDStack is currently in, when computing cycle

local cycleTick = 0 -- increments for each call to Cycle, used to determine the relative age and freshness of generated widgets
local widgetCount = 0 -- only used to compute ZIndex, resets to 0 for every cycle

Iris._PostCycleCallbacks = {}

Iris.TemplateStyles = {
    colorDark = {
        TextColor = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0,
        TextDisabledColor = Color3.fromRGB(128, 128, 128),
        TextDisabledTransparency = 0,

        BorderColor = Color3.fromRGB(110, 110, 125), 
        -- Dear ImGui uses 110, 110, 125
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(160, 160, 175), -- does not exist in Dear ImGui

        BorderTransparency = 0, 
        BorderActiveTransparency = 0,
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- is not implimented because of this

        WindowBgColor = Color3.fromRGB(15, 15, 15),
        WindowBgTransparency = 0.072,

        ScrollbarGrabColor = Color3.fromRGB(128, 128, 128),
        ScrollbarGrabTransparency = 0,

        TitleBgColor = Color3.fromRGB(10, 10, 10),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(41, 74, 122),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(0, 0, 0),
        TitleBgCollapsedTransparency = 0.5,

        FrameBgColor = Color3.fromRGB(41, 74, 122),
        FrameBgTransparency = 0.46,
        FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
        FrameBgHoveredTransparency = 0.46,
        FrameBgActiveColor = Color3.fromRGB(66, 150, 250),
        FrameBgActiveTransparency = 0.33,

        ButtonColor = Color3.fromRGB(66, 150, 250),
        ButtonTransparency = 0.6,
        ButtonHoveredColor = Color3.fromRGB(66, 150, 250),
        ButtonHoveredTransparency = 0,
        ButtonActiveColor = Color3.fromRGB(15, 135, 250),
        ButtonActiveTransparency = 0,

        HeaderColor = Color3.fromRGB(66, 150, 250),
        HeaderTransparency = 0.31,
        HeaderHoveredColor = Color3.fromRGB(66, 150, 250),
        HeaderHoveredTransparency = 0.2,
        HeaderActiveColor = Color3.fromRGB(66, 150, 250),
        HeaderActiveTransparency = 0,

        SelectionImageObjectColor = Color3.fromRGB(255, 255, 255),
        SelectionImageObjectTransparency = 0.8,
        SelectionImageObjectBorderColor = Color3.fromRGB(255, 255, 255),
        SelectionImageObjectBorderTransparency = 0,

        TableBorderStrongColor = Color3.fromRGB(79, 79, 89),
        TableBorderStrongTransparency = 0,
        TableBorderLightColor = Color3.fromRGB(59, 59, 64),
        TableBorderLightTransparency = 0,
        TableRowBgColor = Color3.fromRGB(0, 0, 0),
        TableRowBgTransparency = 1,
        TableRowBgAltColor = Color3.fromRGB(255, 255, 255),
        TableRowBgAltTransparency = 0.94,

        NavWindowingHighlightColor = Color3.fromRGB(255, 255, 255),
        NavWindowingHighlightTransparency = 0.3,
        NavWindowingDimBgColor = Color3.fromRGB(204, 204, 204),
        NavWindowingDimBgTransparency = 0.65,

        SeparatorColor = Color3.fromRGB(110, 110, 128),
        SeparatorTransparency = 0.5,

        CheckMarkColor = Color3.fromRGB(66, 150, 250),
        CheckMarkTransparency = 0
    },
    colorLight = {
        TextColor = Color3.fromRGB(0, 0, 0),
        TextTransparency = 0,
        TextDisabledColor = Color3.fromRGB(153, 153, 153),
        TextDisabledTransparency = 0,

        BorderColor = Color3.fromRGB(64, 64, 64),
        -- Dear ImGui uses 0, 0, 0, 77
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(64, 64, 64), -- does not exist in Dear ImGui

        -- BorderTransparency = 0.5,
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- will not be implimented because of this

        WindowBgColor = Color3.fromRGB(240, 240, 240),
        WindowBgTransparency = 0,

        TitleBgColor = Color3.fromRGB(245, 245, 245),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(209, 209, 209),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(255, 255, 255),
        TitleBgCollapsedTransparency = 0.5,

        ScrollbarGrabColor = Color3.fromRGB(96, 96, 96),
        ScrollbarGrabTransparency = 0,

        FrameBgColor = Color3.fromRGB(255, 255, 255),
        FrameBgTransparency = 0.6,
        FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
        FrameBgHoveredTransparency = 0.6,
        FrameBgActiveColor = Color3.fromRGB(66, 150, 250),
        FrameBgActiveTransparency = 0.33,

        ButtonColor = Color3.fromRGB(66, 150, 250),
        ButtonTransparency = 0.6,
        ButtonHoveredColor = Color3.fromRGB(66, 150, 250),
        ButtonHoveredTransparency = 0,
        ButtonActiveColor = Color3.fromRGB(15, 135, 250),
        ButtonActiveTransparency = 0,

        HeaderColor = Color3.fromRGB(66, 150, 250),
        HeaderTransparency = 0.31,
        HeaderHoveredColor = Color3.fromRGB(66, 150, 250),
        HeaderHoveredTransparency = 0.2,
        HeaderActiveColor = Color3.fromRGB(66, 150, 250),
        HeaderActiveTransparency = 0,

        SelectionImageObjectColor = Color3.fromRGB(0, 0, 0),
        SelectionImageObjectTransparency = 0.8,
        SelectionImageObjectBorderColor = Color3.fromRGB(0, 0, 0),
        SelectionImageObjectBorderTransparency = 0,

        TableBorderStrongColor = Color3.fromRGB(145, 145, 163),
        TableBorderStrongTransparency = 0,
        TableBorderLightColor = Color3.fromRGB(173, 173, 189),
        TableBorderLightTransparency = 0,
        TableRowBgColor = Color3.fromRGB(0, 0, 0),
        TableRowBgTransparency = 1,
        TableRowBgAltColor = Color3.fromRGB(77, 77, 77),
        TableRowBgAltTransparency = 0.91,

        NavWindowingHighlightColor = Color3.fromRGB(179, 179, 179),
        NavWindowingHighlightTransparency = 0.3,
        NavWindowingDimBgColor = Color3.fromRGB(51, 51, 51),
        NavWindowingDimBgTransparency = 0.8,

        SeparatorColor = Color3.fromRGB(99, 99, 99),
        SeparatorTransparency = 0.38,
        
        CheckMarkColor = Color3.fromRGB(66, 150, 250),
        CheckMarkTransparency = 0
    },
    sizeClassic = {
        ItemWidth = UDim.new(1, 0),

        WindowPadding = Vector2.new(8, 8),
        WindowResizePadding = Vector2.new(6, 6),
        FramePadding = Vector2.new(4, 3),
        ItemSpacing = Vector2.new(8, 4),
        ItemInnerSpacing = Vector2.new(4, 4),
        CellPadding = Vector2.new(4, 2),
        IndentSpacing = 21,

        TextFont = Enum.Font.Code,
        TextSize = 13,
        FrameBorderSize = 0,
        FrameRounding = 0,
        WindowBorderSize = 1,
        WindowTitleAlign = Enum.LeftRight.Left,
        ScrollbarSize = 7, -- Dear ImGui is 14 but these are equal because ScrollbarSize property is doubled by roblox
    }
}

local function generateSelectionImageObject()
    if Iris.SelectionImageObject then
        Iris.SelectionImageObject:Destroy()
    end
    local SelectionImageObject = Instance.new("Frame")
    Iris.SelectionImageObject = SelectionImageObject
    SelectionImageObject.BackgroundColor3 = Iris._style.SelectionImageObjectColor
    SelectionImageObject.BackgroundTransparency = Iris._style.SelectionImageObjectTransparency
    SelectionImageObject.Position = UDim2.fromOffset(-1, -1)
    SelectionImageObject.Size = UDim2.new(1, 2, 1, 2)
    SelectionImageObject.BorderSizePixel = 0

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Iris._style.SelectionImageObjectBorderColor
    UIStroke.Transparency = Iris._style.SelectionImageObjectBorderColor
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = SelectionImageObject

    local Rounding = Instance.new("UICorner")
    Rounding.CornerRadius = UDim.new(0, 2)
    Rounding.Parent = SelectionImageObject
end

local function generateEmptyVDOM()
    return {
        ["R"] = rootWidget
    }
end

local lastVDOM = generateEmptyVDOM()
local VDOM = generateEmptyVDOM()

local function generateRootInstance()
    -- unsafe to call before Iris.connect
    rootInstance = widgets["Root"].Generate()
    rootInstance.Parent = Iris.parentInstance
    rootWidget.Instance = rootInstance
end

local function deepCompare(t1, t2)
    -- unoptimized ?
    for i, v1 in t1 do
        local v2 = t2[i]
        if type(v1) == "table" then
            if v2 and type(v2) == "table" then
                if deepCompare(v1, v2) == false then
                    return false
                end
            else
                return false
            end
        else
            if type(v1) ~= type(v2) or v1 ~= v2 then
                return false
            end
        end
    end

    return true
end

local function GetID(levelsToIgnore: number)
	local i = 1 + (levelsToIgnore or 1)
	local ID = ""
	local levelInfo = debug.info(i, "l")
	while levelInfo ~= -1 and levelInfo ~= nil do
		ID ..= "+" .. levelInfo
		i += 1
		levelInfo = debug.info(i, "l")
	end
	if UsedIDs[ID] then
		UsedIDs[ID] += 1
	else
		UsedIDs[ID] = 1
	end
	return ID .. ":" .. UsedIDs[ID]
end

local function cycle(callback)
    if refreshRequested then
        -- rerender every widget
        debug.profilebegin("Iris Refresh")
        generateSelectionImageObject()
        refreshRequested = false
        for i,v in lastVDOM do
            widgets[v.type].Discard(v)
        end
        generateRootInstance()
        lastVDOM = generateEmptyVDOM()
        debug.profileend()
    end
    cycleTick += 1
    widgetCount = 0
    table.clear(UsedIDs)
    rootWidget.lastcycleTick = cycleTick

    debug.profilebegin("Iris Generate")
    local status, _error = pcall(callback)
    debug.profileend()

    for _, v in lastVDOM do
        if v.lastcycleTick ~= cycleTick then
            -- a widget which used to be rendered was no longer rendered, so we discard
            widgets[v.type].Discard(v)
        end
    end

    lastVDOM = VDOM
    VDOM = generateEmptyVDOM()

    if not status then
        Iris._stackIndex = 1
        error(_error, 0)
    end
    if Iris._stackIndex ~= 1 then
        -- has to be larger than 1 because of the check that it isint below 1 in Iris.End
        Iris._stackIndex = 1
        error("Callback is missing an Iris.End()", 0)
    end

    for i, func in Iris._PostCycleCallbacks do
        func()
    end
end

Iris.Args = {}

function Iris.ForceRefresh()
    refreshRequested = true
end

function Iris._GetVDOM()
    return lastVDOM
end

function Iris._GetParentWidget()
    return VDOM[Iris._IDStack[Iris._stackIndex]]
end

function Iris.WidgetConstructor(type: string, hasState: boolean, hasChildren: boolean)
    local requiredFields = {
        "Generate",
        "Update",
        "Discard",
        "Args", -- not a function !
    }
    local requiredFieldsIfState = {
        "GenerateState",
        "UpdateState"
    }
    local requiredFieldsIfChildren = {
        "ChildAdded"
    }

    return function(widgetFunctions: {})
        local thisWidget = {}
        for _, v in requiredFields do
            assert(widgetFunctions[v], `{v} is required for all widgets`)
            thisWidget[v] = widgetFunctions[v]
        end
        if hasState then
            for _, v in requiredFieldsIfState do
                assert(widgetFunctions[v], `{v} is required for all widgets with state`)
                thisWidget[v] = widgetFunctions[v]
            end
        end
        if hasChildren then
            for _, v in requiredFieldsIfChildren do
                assert(widgetFunctions[v], `{v} is required for all widgets with children`)
                thisWidget[v] = widgetFunctions[v]
            end
        end
        thisWidget.hasState = hasState
        thisWidget.hasChildren = hasChildren

        widgets[type] = thisWidget
        Iris.Args[type] = thisWidget.Args
        local ArgNames = {}
        for i, v in thisWidget.Args do
            ArgNames[v] = i
        end
        thisWidget.ArgNames = ArgNames
    end
end

function Iris.UpdateGlobalStyle(deltaStyle: table)
    for i, v in deltaStyle do
        rootStyle[i] = v
    end
    Iris.ForceRefresh()
end

function Iris.PushStyle(deltaStyle: table)
    Iris._style = setmetatable(deltaStyle, {
        __index = Iris._style,
        __iter = function(t)
            assert(t == rootStyle, "cannot iterate Iris._style in this state.")
            return next, t
        end
    })
end

function Iris.PopStyle()
    Iris._style = getmetatable(Iris._style).__index
end

local StateClass = {}
StateClass.__index = StateClass
function StateClass:Get() -- you can also simply use .value
    return self.value
end
function StateClass:Set(newValue)
    self.value = newValue
    for _, thisWidget in self.ConnectedWidgets do
        widgets[thisWidget.type].UpdateState(thisWidget)
    end
    for _, thisFunc in self.ConnectedFunctions do
        thisFunc(newValue)
    end
end
function StateClass:Connect(funcToConnect)
    table.insert(self.ConnectedFunctions, funcToConnect)
end
function Iris.State(initialValue)
    local ID = GetID(2)
    if States[ID] then
        return States[ID]
    else
        States[ID] = {
            value = initialValue,
            ConnectedWidgets = {},
            ConnectedFunctions = {}
        }
        setmetatable(States[ID], StateClass)
        return States[ID]
    end
end
-- Generate a state object with ID derived from a widget object
function Iris._widgetState(thisWidget, stateName, initialValue)
    local ID = thisWidget.ID .. stateName
    if States[ID] then
        States[ID].ConnectedWidgets[thisWidget.ID] = thisWidget
        return States[ID]
    else
        States[ID] = {
            value = initialValue,
            ConnectedWidgets = {[thisWidget.ID] = thisWidget},
            ConnectedFunctions = {}
        }
        setmetatable(States[ID], StateClass)
        return States[ID]
    end
end

function Iris.Connect(parentInstance, eventConnection: RBXScriptSignal | () -> {}, callback)
    Iris.parentInstance = parentInstance
    assert(not started, "Iris.Connect can only be called once.")
    started = true

    generateRootInstance()
    generateSelectionImageObject()
    
    task.spawn(function()
        if typeof(eventConnection) == "function" then
            while true do
                eventConnection()
                cycle(callback)
            end
        else
            eventConnection:Connect(function()
                cycle(callback)
            end)
        end
    end)
end

function Iris._Insert(widgetType, args, widgetState)
    local parentId = IDStack[Iris._stackIndex]
    local parentWidget = VDOM[parentId]
    local thisWidget
    local thisWidgetClass = widgets[widgetType]
    local ID = GetID(3)
    widgetCount += 1

    if VDOM[ID] then
        error("Multiple widgets cannot occupy the same ID", 3)
    end

    local arguments = {}
    if args ~= nil then
        if type(args) ~= "table" then
            error("Args must be a table.", 3)
        end
        for i, v in args do
            arguments[thisWidgetClass.ArgNames[i]] = v
        end
    end

    if lastVDOM[ID] then
        -- found a matching widget from last frame
        assert(widgetType == lastVDOM[ID].type, "ID type mismatch.")

        thisWidget = lastVDOM[ID]
    else
        -- didnt find a match, generate a new widget
        thisWidget = {}
        setmetatable(thisWidget, thisWidget)

        thisWidget.ID = ID
        thisWidget.type = widgetType
        thisWidget.parentWidget = parentWidget
        thisWidget.events = {}

        local widgetInstanceParent = widgets[parentWidget.type].ChildAdded(parentWidget, thisWidget)

        thisWidget.ZIndex = parentWidget.ZIndex + (widgetCount * 0x40)
    
        thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
        thisWidget.Instance.Parent = widgetInstanceParent

        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)

        if thisWidgetClass.hasState then
            if widgetState then
                thisWidget.state = widgetState
                for i,v in widgetState do
                    v.ConnectedWidgets[thisWidget.ID] = thisWidget
                end
            else
                thisWidget.state = {}
            end

            thisWidgetClass.GenerateState(thisWidget)
            thisWidgetClass.UpdateState(thisWidget)

            thisWidget.stateMT = {} -- MT cant be itself because state has to explicitly only contain stateClass objects
            setmetatable(thisWidget.state, thisWidget.stateMT)
        end
    end

    if thisWidget.arguments ~= arguments and deepCompare(thisWidget.arguments, arguments) == false then
        -- the widgets arguments have changed, the widget should update to reflect changes.
        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)
    end

    -- strange __index chaining so that .state AND .events are both indexable through thisWidget
    local oldEvents = thisWidget.events
    thisWidget.events = {}
    if thisWidgetClass.hasState then
        thisWidget.__index = thisWidget.state
        thisWidget.stateMT.__index = oldEvents
    else
        thisWidget.__index = oldEvents
    end

    thisWidget.lastcycleTick = cycleTick

    if thisWidgetClass.hasChildren then
        Iris._stackIndex += 1
        IDStack[Iris._stackIndex] = thisWidget.ID
    end

    VDOM[ID] = thisWidget

    return thisWidget
end

function Iris.End()
    if Iris._stackIndex == 1 then
        error("Callback has too many Iris.End()", 2)
    end
    IDStack[Iris._stackIndex] = nil
    Iris._stackIndex -= 1
end

Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark) -- use colorDark and sizeClassic themes by default
Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)
require(script.widgets)(Iris)
Iris.ShowDemoWindow = require(script.demoWindow)(Iris)

return Iris