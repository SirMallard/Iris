local Iris = {}

local started = false

local widgets = {}
Iris.widgets = widgets

local rootStyle = {}
Iris._style = rootStyle

local rootInstance

local rootWidget = {
    ID = "R",
    type = "Root",
    Instance = rootInstance,
    ZIndex = 0
}

local function GenerateEmptyVDOM()
    return {
        ["R"] = rootWidget
    }
end

local lastVDOM = GenerateEmptyVDOM()
local VDOM = GenerateEmptyVDOM()

local storedStates = {}

local IDStack = {"R"}
local stackIndex = 1

local tick = 0
local widgetCount = 0

function deepcompare(t1,t2)
    -- unoptimized
    for i,v1 in t1 do
        local v2 = t2[i]
        if type(v1) == "table" then
            if v2 and type(v2) == "table" then
                if deepcompare(v1,v2) == false then
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

local Cycle = function(callback)
    tick += 1
    widgetCount = 0
    rootWidget.lastTick = tick

    debug.profilebegin("Iris")
    callback()
    debug.profileend()

    for _,v in lastVDOM do
        if v.lastTick ~= tick then
            widgets[v.type].Discard(v)
        end
    end
    
    lastVDOM = VDOM
    VDOM = GenerateEmptyVDOM()
end

Iris.templateStyles = {
    classic = {
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
}

Iris.Args = {}

function Iris.WidgetConstructor(type: string, hasState: boolean, hasChildren: boolean)
    local requiredFields = {
        "Generate",
        "Update",
        "Discard",
        "ArgNames", -- not a function !
        "Args" -- also not a function !
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
        for _,v in requiredFields do
            assert(widgetFunctions[v], v .. " is required for all widgets")
            thisWidget[v] = widgetFunctions[v]
        end
        if hasState then
            for _,v in requiredFieldsIfState do
                assert(widgetFunctions[v], v .. " is required for all widgets with state")
                thisWidget[v] = widgetFunctions[v]
            end
        end
        if hasChildren then
            for _,v in requiredFieldsIfChildren do
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
    end
end

function Iris.UpdateGlobalStyle(deltaStyle: table)
    for i,v in deltaStyle do
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
    assert(not started, "Iris.Connect should only be called once.")
    started = true

    rootInstance = widgets["Root"].Generate()
    rootInstance.Parent = parentInstance
    VDOM["R"].Instance = rootInstance
    lastVDOM["R"].Instance = rootInstance
    
    task.spawn(function()
        if eventConnection.Connect then
            eventConnection:Connect(function()
                Cycle(callback)
            end)
        else
            while eventConnection() do
                Cycle(callback)
            end
        end
    end)
end

function Iris._Insert(type, ...)
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

    assert(not VDOM[ID], "Multiple widgets cannot occupy the same ID.")

    local arguments = {}
    for i,v in {...} do
        if typeof(v) == "table" and table.isfrozen(v) then
            -- isfrozen is technically the fastest way to store a boolean metadata parameter for a table.
            -- its faster than indexing an arbitrary index, like 0
            -- its also faster than getmetatable()

            -- in this case isfrozen signifies that the table was returned by an Iris.Args function
            -- meaning its index position in the table is irrelivant for knowing what its parameter is
            arguments[thisWidgetClass.ArgNames[v[1]]] = v[2]
            continue
        end
        arguments[thisWidgetClass.ArgNames[i]] = v
    end

    if lastVDOM[ID] then
        -- found a matching widget from last frame!
        assert(type == lastVDOM[ID].type, "ID type mismatch.")

        thisWidget = lastVDOM[ID]
    else
        -- didnt find a match, lets generate a new one.
        thisWidget = {}
        thisWidget.ID = ID
        thisWidget.type = type
        thisWidget.events = {}
        thisWidget.ZIndex = parentWidget.ZIndex + 0xFFFFF + (widgetCount * 0x40)
        -- ZIndex (and LayoutOrder) limit is 2^31-1
        -- this configuration means ZIndex can handle children 2^11-1 deep and can handle 2^14-1 widgets
        -- (and each widget gets 63 ZIndex to handle individual instances)
    
        thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
        thisWidget.Instance.Parent = widgets[parentWidget.type].GetParentInstance(parentWidget, thisWidget)

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
        -- the widgets arguments have changed; the widget should update to reflect changes.
        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)
    end

    local events = thisWidget.events
    thisWidget.events = {}
    thisWidget.lastTick = tick

    if widgets[type].hasChildren then
        stackIndex += 1
        IDStack[stackIndex] = thisWidget.ID
    end

    VDOM[ID] = thisWidget
    Iris.LastWidget = thisWidget

    return setmetatable(thisWidget, {__index = events}) -- not optimal
end

function Iris.End()
    IDStack[stackIndex] = nil
    stackIndex -= 1
end

function Iris.SetState(ThisWidget, deltaState: {})
    for i,v in deltaState do
        ThisWidget.state[i] = v
    end
    Iris.widgets[ThisWidget.type].UpdateState(ThisWidget)
end

function Iris.PushId(ID: string | number)
    local ParentId = IDStack[stackIndex]
    ID = ParentId .. "-" .. tostring(ID)

    stackIndex += 1
    IDStack[stackIndex] = ID
    
    -- this is elegant
    VDOM[ID] = VDOM[ParentId]
end

require(script.widgets)(Iris)
Iris.UpdateGlobalStyle(Iris.templateStyles.classic)

return Iris