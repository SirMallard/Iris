--!optimize 2
local Iris = {}

local started = false
local refreshRequested = false

local widgets = {}
Iris.widgets = widgets

local rootStyle = {}
Iris._style = rootStyle

local rootInstance

local rootWidget = {
    ID = "R",
    type = "Root",
    Instance = rootInstance,
    ZIndex = 0,
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

local storedStates = {}

local IDStack = {"R"}
local stackIndex = 1

local tick = 0
local widgetCount = 0

function deepcompare(t1, t2)
    -- unoptimized
    for i, v1 in t1 do
        local v2 = t2[i]
        if type(v1) == "table" then
            if v2 and type(v2) == "table" then
                if deepcompare(v1, v2) == false then
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

local cycle = function(callback)
    if refreshRequested then
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
    tick += 1
    widgetCount = 0
    rootWidget.lastTick = tick

    debug.profilebegin("Iris Generate")
    local status, _error = pcall(callback)
    debug.profileend()

    for _, v in lastVDOM do
        if v.lastTick ~= tick then
            widgets[v.type].Discard(v)
        end
    end

    lastVDOM = VDOM
    VDOM = generateEmptyVDOM()

    if not status then
        stackIndex = 1
        error(_error, 0)
    end
    if stackIndex ~= 1 then
        stackIndex = 1
        error("Callback is missing an Iris.End()", 0)
    end
end

Iris.TemplateStyles = {
    colorDark = {
        TextColor = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0,

        BorderColor = Color3.fromRGB(110, 110, 125), 
        -- Dear ImGui uses 110, 110, 125
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(160, 160, 175), -- does not exist in Dear ImGui

        -- BorderTransparency = 0.5, 
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- and who really cares about it anyways? we're not implimenting BorderTransparency at all.

        WindowBgColor = Color3.fromRGB(15, 15, 15),
        WindowBgTransparency = 0.072,

        ScrollbarGrabColor = Color3.fromRGB(128, 128, 128),
        ScrollbarGrabTransparency = 0,

        TitleBgColor = Color3.fromRGB(10, 10, 10),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(41, 74, 122),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(0, 0, 0),
        TitleBgCollapsedTransparency = .5,

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
        SelectionImageObjectTransparency = .8,
        SelectionImageObjectBorderColor = Color3.fromRGB(255, 255, 255),
        SelectionImageObjectBorderTransparency = 0,

        NavWindowingHighlightColor = Color3.fromRGB(255, 255, 255),
        NavWindowingHighlightTransparency = .3,
        NavWindowingDimBgColor = Color3.fromRGB(204, 204, 204),
        NavWindowingDimBgTransparency = .65
    },
    colorLight = {
        TextColor = Color3.fromRGB(0, 0, 0),
        TextTransparency = 0,

        BorderColor = Color3.fromRGB(64, 64, 64),
        -- Dear ImGui uses 0, 0, 0, 77
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(64, 64, 64), -- does not exist in Dear ImGui

        -- BorderTransparency = 0.5,
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- and who really cares about it anyways? we're not implimenting BorderTransparency at all.

        WindowBgColor = Color3.fromRGB(240, 240, 240),
        WindowBgTransparency = 0,

        TitleBgColor = Color3.fromRGB(245, 245, 245),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(209, 209, 209),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(255, 255, 255),
        TitleBgCollapsedTransparency = .5,

        ScrollbarGrabColor = Color3.fromRGB(96, 96, 96),
        ScrollbarGrabTransparency = 0,

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
        SelectionImageObjectTransparency = .8,
        SelectionImageObjectBorderColor = Color3.fromRGB(0, 0, 0),
        SelectionImageObjectBorderTransparency = 0,

        NavWindowingHighlightColor = Color3.fromRGB(179, 179, 179),
        NavWindowingHighlightTransparency = .3,
        NavWindowingDimBgColor = Color3.fromRGB(51, 51, 51),
        NavWindowingDimBgTransparency = .8
    },
    sizeClassic = {
        WindowPadding = Vector2.new(8, 8),
        FramePadding = Vector2.new(4, 3),
        ItemSpacing = Vector2.new(8, 4),
        IndentSpacing = 21,
        Font = Enum.Font.Code,
        FontSize = 13,
        FrameBorderSize = 0,
        FrameRounding = 0,
        WindowBorderSize = 1,
        WindowTitleAlign = Enum.LeftRight.Left,

        ScrollbarSize = 7, -- Dear ImGui is 14, but these are equal, due to how ScrollbarSize is digested by roblox
    }
}

Iris.Args = {}

function Iris._GetVDOM()
    return lastVDOM
end

function Iris.ForceRefresh()
    refreshRequested = true
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
        "GetParentInstance"
    }

    return function (widgetFunctions: {})
        local thisWidget = {}
        for _, v in requiredFields do
            assert(widgetFunctions[v], v .. " is required for all widgets")
            thisWidget[v] = widgetFunctions[v]
        end
        if hasState then
            for _, v in requiredFieldsIfState do
                assert(widgetFunctions[v], v .. " is required for all widgets with state")
                thisWidget[v] = widgetFunctions[v]
            end
        end
        if hasChildren then
            for _, v in requiredFieldsIfChildren do
                assert(widgetFunctions[v], v .. " is required for all widgets with children")
                thisWidget[v] = widgetFunctions[v]
            end
        end
        thisWidget.hasState = hasState
        thisWidget.hasChildren = hasChildren
        -- making the decision not to automatically add widget constructors into Iris, because then they would be closures
        -- (bad for performance)
        -- what?
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

function Iris.Connect(parentInstance, eventConnection, callback)
    Iris.parentInstance = parentInstance
    assert(not started, "Iris.Connect should only be called once.")
    started = true

    generateRootInstance()
    generateSelectionImageObject()
    
    task.spawn(function()
        if eventConnection.Connect then
            eventConnection:Connect(function()
                cycle(callback)
            end)
        else
            while eventConnection() do
                cycle(callback)
            end
        end
    end)
end

function Iris._Insert(type, args)
    assert(widgets[type], type .. " is not a valid widget.")
    widgetCount += 1

    local localId = "L" .. debug.info(3,"l")
    -- possible optimization to remove this L, which is mostly for debugging
    -- the L does serve a purpose. there is a very ugly potential glitch in this ID configuration.
    -- if the user sets nextWidgetId to an integer which is already occupied in code by a line which calls a widget,
    -- the localId will be equivalent. "L" adds specificity.

    local thisWidget
    local thisWidgetClass = widgets[type]
    local parentId = IDStack[stackIndex]
    local parentWidget = VDOM[parentId]
    local ID = parentId .. "-" .. localId
    -- approx. 0.2μs for this concatenation

    if VDOM[ID] then
        error("Multiple widgets cannot occupy the same ID", 3)
    end

    local arguments = {}
    for i, v in args do
        arguments[thisWidgetClass.ArgNames[i]] = v
    end

    if lastVDOM[ID] then
        -- found a matching widget from last frame!
        assert(type == lastVDOM[ID].type, "ID type mismatch.")

        thisWidget = lastVDOM[ID]
    else
        -- didnt find a match, lets generate a new one.
        thisWidget = {}
        setmetatable(thisWidget, thisWidget)

        thisWidget.ID = ID
        thisWidget.type = type
        thisWidget.events = {}

        local widgetInstanceParent = widgets[parentWidget.type].GetParentInstance(parentWidget, thisWidget)
        if widgetInstanceParent:IsA("GuiObject") then
            parentWidget.ZIndex = widgetInstanceParent.ZIndex -- this fucking sucks. Instance-authoritative state????
        end
        thisWidget.ZIndex = parentWidget.ZIndex + (widgetCount * 0x40)
        -- ZIndex (and LayoutOrder) limit is 2^31-1
    
        thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
        thisWidget.Instance.Parent = widgetInstanceParent

        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)

        if widgets[type].hasState then
            if storedStates[ID] == nil then
                storedStates[ID] = thisWidgetClass.GenerateState(thisWidget)
            end
            thisWidget.state = storedStates[ID]

            thisWidgetClass.UpdateState(thisWidget)
        end
    end

    if thisWidget.arguments ~= arguments and deepcompare(thisWidget.arguments, arguments) == false then
        -- the widgets arguments have changed, the widget should update to reflect changes.
        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)
    end

    local events = thisWidget.events
    thisWidget.events = {}
    thisWidget.__index = events
    thisWidget.lastTick = tick

    if widgets[type].hasChildren then
        stackIndex += 1
        IDStack[stackIndex] = thisWidget.ID
    end

    VDOM[ID] = thisWidget
    Iris.LastWidget = thisWidget

    return thisWidget -- not optimal
end

function Iris.End()
    if stackIndex == 1 then
        error("Callback has too many Iris.End()", 2)
    end
    IDStack[stackIndex] = nil
    stackIndex -= 1
end

function Iris.SetState(thisWidget, deltaState: {})
    local changesMade = false
    for i, v in deltaState do
        -- no provision againt users adding things to state that dont exist
        changesMade = changesMade or ((not thisWidget.state[i]) or thisWidget.state[i] ~= v)
        thisWidget.state[i] = v
    end
    if changesMade then
        Iris.widgets[thisWidget.type].UpdateState(thisWidget)
    end
end

function Iris.UseId(ID: string | number)
    local parentId = IDStack[stackIndex]
    ID = parentId .. "-" .. tostring(ID)

    stackIndex += 1
    IDStack[stackIndex] = ID
    
    -- this is elegant
    VDOM[ID] = VDOM[parentId]
end

require(script.widgets)(Iris)
Iris.UpdateGlobalStyle(Iris.TemplateStyles.colorDark)
Iris.UpdateGlobalStyle(Iris.TemplateStyles.sizeClassic)

return Iris