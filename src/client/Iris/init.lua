--!optimize 2

--- @class Iris
--- 
--- Iris is the base class which contains everything you need to use the library.
local Iris = {}

Iris._started = false -- has Iris.connect been called yet
Iris._globalRefreshRequested = false -- refresh means that all GUI is destroyed and regenerated, usually because a style change was made and needed to be propogated to all UI
Iris._localRefreshActive = false -- if true, when _Insert is called, the widget called will be regenerated
Iris._widgets = {}
Iris._rootConfig = {} -- root style which all widgets derive from
Iris._config = Iris._rootConfig
Iris._rootWidget = {
    ID = "R",
    type = "Root",
    Instance = Iris._rootInstance,
    ZIndex = 0,
}
Iris._states = {} -- Iris.States
Iris._postCycleCallbacks = {}
Iris._connectedFunctions = {} -- functions which run each Iris cycle, connected by the user
-- these following variables aid in computing Iris._cycle, they are variable while the code to render widgets is being caleld
Iris._IDStack = {"R"}
Iris._usedIDs = {} -- hash of IDs which are already used in a cycle, value is the # of occurances so that getID can assign a unique ID for each occurance
Iris._stackIndex = 1 -- Points to the index that IDStack is currently in, when computing cycle
Iris._cycleTick = 0 -- increments for each call to Cycle, used to determine the relative age and freshness of generated widgets
Iris._widgetCount = 0 -- only used to compute ZIndex, resets to 0 for every cycle
Iris._lastWidget = Iris._rootWidget -- widget which was most recently rendered

function Iris._generateSelectionImageObject()
    if Iris.SelectionImageObject then
        Iris.SelectionImageObject:Destroy()
    end
    local SelectionImageObject = Instance.new("Frame")
    Iris.SelectionImageObject = SelectionImageObject
    SelectionImageObject.BackgroundColor3 = Iris._config.SelectionImageObjectColor
    SelectionImageObject.BackgroundTransparency = Iris._config.SelectionImageObjectTransparency
    SelectionImageObject.Position = UDim2.fromOffset(-1, -1)
    SelectionImageObject.Size = UDim2.new(1, 2, 1, 2)
    SelectionImageObject.BorderSizePixel = 0

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Iris._config.SelectionImageObjectBorderColor
    UIStroke.Transparency = Iris._config.SelectionImageObjectBorderColor
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = SelectionImageObject

    local Rounding = Instance.new("UICorner")
    Rounding.CornerRadius = UDim.new(0, 2)
    Rounding.Parent = SelectionImageObject
end

function Iris._generateRootInstance()
    -- unsafe to call before Iris.connect
    Iris._rootInstance = Iris._widgets["Root"].Generate(Iris._widgets["Root"])
    Iris._rootInstance.Parent = Iris.parentInstance
    Iris._rootWidget.Instance = Iris._rootInstance
end

function Iris._deepCompare(t1: table, t2: table)
    -- unoptimized ?
    for i, v1 in t1 do
        local v2 = t2[i]
        if type(v1) == "table" then
            if v2 and type(v2) == "table" then
                if Iris._deepCompare(v1, v2) == false then
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

function Iris._getID(levelsToIgnore: number)
	local i = 1 + (levelsToIgnore or 1)
	local ID = ""
	local levelInfo = debug.info(i, "l")
	while levelInfo ~= -1 and levelInfo ~= nil do
		ID ..= "+" .. levelInfo
		i += 1
		levelInfo = debug.info(i, "l")
	end
	if Iris._usedIDs[ID] then
		Iris._usedIDs[ID] += 1
	else
		Iris._usedIDs[ID] = 1
	end

	return ID .. ":" .. Iris._usedIDs[ID]
end

function Iris._generateEmptyVDOM()
    return {
        ["R"] = Iris._rootWidget
    }
end

Iris._lastVDOM = Iris._generateEmptyVDOM()
Iris._VDOM = Iris._generateEmptyVDOM()

function Iris._cycle()
    Iris._rootWidget.lastCycleTick = Iris._cycleTick
    if Iris._rootInstance == nil or Iris._rootInstance.Parent == nil then
        Iris.ForceRefresh()
    end

    for _, v in Iris._lastVDOM do
        if v.lastCycleTick ~= Iris._cycleTick then
            -- a widget which used to be rendered was no longer rendered, so we discard
            Iris._DiscardWidget(v)
        end
    end

    Iris._lastVDOM = Iris._VDOM
    Iris._VDOM = Iris._generateEmptyVDOM()

    for i, func in Iris._postCycleCallbacks do
        func()
    end

    if Iris._globalRefreshRequested then
        -- rerender every widget
        --debug.profilebegin("Iris Refresh")
        Iris._generateSelectionImageObject()
        Iris._globalRefreshRequested = false
        for i,v in Iris._lastVDOM do
            Iris._DiscardWidget(v)
        end
        Iris._generateRootInstance()
        Iris._lastVDOM = Iris._generateEmptyVDOM()
        --debug.profileend()
    end
    Iris._cycleTick += 1
    Iris._widgetCount = 0
    table.clear(Iris._usedIDs)

    if Iris.parentInstance:IsA("GuiBase2d") and math.min(Iris.parentInstance.AbsoluteSize.X, Iris.parentInstance.AbsoluteSize.Y) < 100 then
        error("Iris Parent Instance is too small")
    end
    local compatibleParent = (
        Iris.parentInstance:IsA("GuiBase2d") or 
        Iris.parentInstance:IsA("CoreGui") or 
        Iris.parentInstance:IsA("PluginGui") or 
        Iris.parentInstance:IsA("PlayerGui")
    ) 
    if compatibleParent == false then
        error("Iris Parent Instance cant contain GUI")
    end
    --debug.profilebegin("Iris Generate")
    for _, callback in Iris._connectedFunctions do
        local status, _error = pcall(callback)
        if not status then
            Iris._stackIndex = 1
            error(_error, 0)
        end
        if Iris._stackIndex ~= 1 then
            -- has to be larger than 1 because of the check that it isint below 1 in Iris.End
            Iris._stackIndex = 1
            error("Callback has too few calls to Iris.End()", 0)
        end
    end
    --debug.profileend()
end

function Iris._GetParentWidget()
    return Iris._VDOM[Iris._IDStack[Iris._stackIndex]]
end

--- @prop Args table
--- @within Iris
--- Provides a list of every possible Argument for each type of widget.
--- For instance, `Iris.Args.Window.NoResize`.
--- The Args table is useful for using widget Arguments without remembering their order.
--- ```lua
--- Iris.Window({"My Window", [Iris.Args.Window.NoResize] = true})
--- ```
Iris.Args = {}

function Iris._EventCall(thisWidget, eventName)
    local Events = Iris._widgets[thisWidget.type].Events
    local Event = Events[eventName]
    assert(Event ~= nil, `widget {thisWidget.type} has no event of name {Event}`)
    
    if thisWidget.trackedEvents[eventName] == nil then
        Event.Init(thisWidget)
        thisWidget.trackedEvents[eventName] = true
    end
    return Event.Get(thisWidget)
end

Iris.Events = {}

--- @function ForceRefresh
--- @within Iris
--- Destroys and regenerates all instances used by Iris. useful if you want to propogate state changes.
--- :::caution Caution: Performance
--- Because this function Deletes and Initializes many instances, it may cause **performance issues** when used with many widgets.
--- In **no** case should it be called every frame.
--- :::
function Iris.ForceRefresh()
    Iris._globalRefreshRequested = true
end

function Iris._NoOp() -- This is a value of Iris because i am scared of closures

end
--- @function WidgetConstructor
--- @within Iris
--- @param type string -- Name used to denote the widget
--- @param widgetClass table -- table of methods for the new widget
function Iris.WidgetConstructor(type: string, widgetClass: table)
    local Fields = {
        All = {
            Required = {
                "Generate",
                "Discard",
                "Update",

                -- not methods !
                "Args",
                "Events",
                "hasChildren",
                "hasState"
            },
            Optional = {

            }
        },
        IfState = {
            Required = {
                "GenerateState",
                "UpdateState"
            },
            Optional = {

            }
        },
        IfChildren = {
            Required = {
                "ChildAdded"
            },
            Optional = {
                "ChildDiscarded"
            }
        }
    }

    local thisWidget = {}
    for _, v in Fields.All.Required do
        assert(widgetClass[v] ~= nil, `field {v} is missing from widget {type}, it is required for all widgets`)
        thisWidget[v] = widgetClass[v]
    end
    for _, v in Fields.All.Optional do
        if widgetClass[v] == nil then
            thisWidget[v] = Iris._NoOp
        else
            thisWidget[v] = widgetClass[v]
        end
    end
    if widgetClass.hasState then
        for _, v in Fields.IfState.Required do
            assert(widgetClass[v] ~= nil, `field {v} is missing from widget {type}, it is required for all widgets with state`)
            thisWidget[v] = widgetClass[v]
        end
        for _, v in Fields.IfState.Optional do
            if widgetClass[v] == nil then
                thisWidget[v] = Iris._NoOp
            else
                thisWidget[v] = widgetClass[v]
            end
        end
    end
    if widgetClass.hasChildren then
        for _, v in Fields.IfChildren.Required do
            assert(widgetClass[v] ~= nil, `field {v} is missing from widget {type}, it is required for all widgets with children`)
            thisWidget[v] = widgetClass[v]
        end
        for _, v in Fields.IfChildren.Optional do
            if widgetClass[v] == nil then
                thisWidget[v] = Iris._NoOp
            else
                thisWidget[v] = widgetClass[v]
            end
        end
    end

    Iris._widgets[type] = thisWidget
    Iris.Args[type] = thisWidget.Args
    local ArgNames = {}
    for i, v in thisWidget.Args do
        ArgNames[v] = i
    end
    for i, v in thisWidget.Events do
        if Iris.Events[i] == nil then
            Iris.Events[i] = function()
                return Iris._EventCall(Iris._lastWidget, i)
            end
        end
    end
    thisWidget.ArgNames = ArgNames
end

--- @function UpdateGlobalConfig
--- @within Iris
--- @param deltaStyle table -- a table containing the changes in style ex: `{ItemWidth = UDim.new(0, 100)}`
--- Allows callers to customize the config which **every** widget will inherit from.
--- It can be used along with Iris.TemplateConfig to easily swap styles, ex: ```Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight) -- use light theme```
--- :::caution Caution: Performance
--- this function internally calls [Iris.ForceRefresh] so that style changes are propogated, it may cause **performance issues** when used with many widgets.
--- In **no** case should it be called every frame.
--- :::
function Iris.UpdateGlobalConfig(deltaStyle: table)
    for i, v in deltaStyle do
        Iris._rootConfig[i] = v
    end
    Iris.ForceRefresh()
end

--- @function PushConfig
--- @within Iris
--- @param deltaStyle table -- a table containing the changes in style ex: `{ItemWidth = UDim.new(0, 100)}`
--- Allows callers to cascade a style, meaning that styles may be locally and hierarchically applied.
--- Each call to Iris.PushConfig must be paired with a call to [Iris.PopConfig].
--- For example:
--- ```lua
--- Iris.PushConfig({TextColor = Color3.fromRGB(128, 0, 256)})
---     Iris.Text({"Colored Text!"})
--- Iris.PopConfig()
--- ```
function Iris.PushConfig(deltaStyle: table)
    local ID = Iris.State(-1)
    if ID.value == -1 then
        ID:set(deltaStyle)
    else
        -- compare tables
        if Iris._deepCompare(ID:get(), deltaStyle) == false then
            -- refresh local
            Iris._localRefreshActive = true
            ID:set(deltaStyle)
        end
    end
    Iris._config = setmetatable(deltaStyle, {
        __index = Iris._config
    })
end

--- @function PopConfig
--- @within Iris
--- Ends a PushConfig style.
--- Each call to [Iris.PushConfig] must be paired with a call to Iris.PopConfig.
function Iris.PopConfig()
    Iris._localRefreshActive = false
    Iris._config = getmetatable(Iris._config).__index
end

--- @class State
--- This class wraps a value in getters and setters, its main purpose is to allow primatives to be passed as objects.
--- Constructors for this class are available in [Iris]
local StateClass = {}
StateClass.__index = StateClass

--- @method get
--- @within State
--- @return any
--- Returns the states current value.
function StateClass:get() -- you can also simply use .value
    return self.value
end

--- @method set
--- @within State
--- allows the caller to assign the state object a new value.
function StateClass:set(newValue)
    self.value = newValue
    for _, thisWidget in self.ConnectedWidgets do
        Iris._widgets[thisWidget.type].UpdateState(thisWidget)
    end
    for _, thisFunc in self.ConnectedFunctions do
        thisFunc(newValue)
    end
    return self.value
end

--- @method onChange
--- @within State
--- Allows the caller to connect a callback which is called when the states value is changed.
function StateClass:onChange(funcToConnect: () -> {})
    table.insert(self.ConnectedFunctions, funcToConnect)
end

--- @function State
--- @within Iris
--- @param initialValue any -- The initial value for the state
--- Constructs a new state object, subsequent ID calls will return the same object
--- :::info
--- Iris.State allows you to create "references" to the same value while inside your UI drawing loop.
--- For example:
--- ```lua
--- Iris:Connect(function()
---     local myNumber = 5;
---     myNumber = myNumber + 1
---     Iris.Text({"The number is: " .. myNumber})
--- end)
--- ```
--- This is problematic. Each time the function is called, a new myNumber is initialized, instead of retrieving the old one.
--- The above code will always display 6.
--- ***
--- Iris.State solves this problem:
--- ```lua
--- Iris:Connect(function()
---     local myNumber = Iris.State(5)
---     myNumber:set(myNumber:get() + 1)
---     Iris.Text({"The number is: " .. myNumber})
--- end)
--- ```
--- In this example, the code will work properly, and increment every frame.
--- :::
function Iris.State(initialValue)
    local ID = Iris._getID(2)
    if Iris._states[ID] then
        return Iris._states[ID]
    else
        Iris._states[ID] = {
            value = initialValue,
            ConnectedWidgets = {},
            ConnectedFunctions = {}
        }
        setmetatable(Iris._states[ID], StateClass)
        return Iris._states[ID]
    end
end

--- @function ComputedState
--- @within Iris
--- @param firstState State -- State to bind to.
--- @param onChangeCallback function -- callback which should return a value transformed from the firstState value
--- Constructs a new State object, but binds its value to the value of another State.
--- :::info
--- A common use case for this constructor is when a boolean State needs to be inverted:
--- ```lua
--- Iris.ComputedState(otherState, function(newValue)
---     return not newValue
--- end)
--- ```
--- :::
function Iris.ComputedState(firstState, onChangeCallback)
    local ID = Iris._getID(2)

    if Iris._states[ID] then
        return Iris._states[ID]
    else
        Iris._states[ID] = {
            value = onChangeCallback(firstState),
            ConnectedWidgets = {},
            ConnectedFunctions = {}
        }
        firstState:onChange(function(newValue)
            Iris._states[ID]:set(onChangeCallback(newValue))
        end)
        setmetatable(Iris._states[ID], StateClass)
        return Iris._states[ID]
    end
end
-- constructor which uses ID derived from a widget object
function Iris._widgetState(thisWidget, stateName, initialValue)
    local ID = thisWidget.ID .. stateName
    if Iris._states[ID] then
        Iris._states[ID].ConnectedWidgets[thisWidget.ID] = thisWidget
        return Iris._states[ID]
    else
        Iris._states[ID] = {
            value = initialValue,
            ConnectedWidgets = {[thisWidget.ID] = thisWidget},
            ConnectedFunctions = {}
        }
        setmetatable(Iris._states[ID], StateClass)
        return Iris._states[ID]
    end
end

--- @within Iris
--- @function Init
--- @param parentInstance Instance | nil -- instance which Iris will place UI in. defaults to [PlayerGui] if unspecified
--- @param eventConnection RBXScriptSignal | () -> {} | nil
--- @return Iris
--- Initializes Iris. May only be called once.
--- :::tip
--- Want to stop Iris from rendering and consuming performance, but keep all the Iris code? simply comment out the `Iris.Init()` line in your codebase.
--- :::
function Iris.Init(parentInstance: Instance?, eventConnection: (RBXScriptSignal | () -> {})?)
    if parentInstance == nil then
        -- coalesce to playerGui
        parentInstance = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    if eventConnection == nil then
        -- coalesce to Heartbeat
        eventConnection = game:GetService("RunService").Heartbeat
    end
    Iris.parentInstance = parentInstance
    assert(not Iris._started, "Iris.Connect can only be called once.")
    Iris._started = true

    Iris._generateRootInstance()
    Iris._generateSelectionImageObject()
    
    task.spawn(function()
        if typeof(eventConnection) == "function" then
            while true do
                eventConnection()
                Iris._cycle()
            end
        else
            eventConnection:Connect(function()
                Iris._cycle()
            end)
        end
    end)

    return Iris
end

--- @within Iris
--- @method Connect
--- @param callback function -- allows users to connect a function which will execute every Iris cycle, (cycle is determined by the callback or event passed to Iris.Init)
function Iris:Connect(callback: () -> {}) -- this uses method syntax for no reason.
    table.insert(Iris._connectedFunctions, callback)
end

function Iris._DiscardWidget(widgetToDiscard)
    local widgetParent = widgetToDiscard.parentWidget
    if widgetParent then
        Iris._widgets[widgetParent.type].ChildDiscarded(widgetParent, widgetToDiscard)
    end
    Iris._widgets[widgetToDiscard.type].Discard(widgetToDiscard)
end

function Iris._GenNewWidget(widgetType, arguments, widgetState, ID)
    local parentId = Iris._IDStack[Iris._stackIndex]
    local thisWidgetClass = Iris._widgets[widgetType]

    local thisWidget = {}
    setmetatable(thisWidget, thisWidget)

    thisWidget.ID = ID
    thisWidget.type = widgetType
    thisWidget.parentWidget = Iris._VDOM[parentId]
    thisWidget.trackedEvents = {}

    thisWidget.ZIndex = thisWidget.parentWidget.ZIndex + (Iris._widgetCount * 0x40) + Iris._config.ZIndexOffset

    thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
    thisWidget.Instance.Parent = if Iris._config.Parent then Iris._config.Parent else Iris._widgets[thisWidget.parentWidget.type].ChildAdded(thisWidget.parentWidget, thisWidget)

    thisWidget.arguments = arguments
    thisWidgetClass.Update(thisWidget)

    local eventMTParent
    if thisWidgetClass.hasState then
        if widgetState then
            for i,v in widgetState do
                if not (type(v) == "table" and getmetatable(v) == StateClass) then
                    widgetState[i] = Iris._widgetState(thisWidget, i, v)
                end
            end
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

        thisWidget.__index = thisWidget.state
        eventMTParent = thisWidget.stateMT
    else
       eventMTParent = thisWidget
    end
    -- im very upset that this function exists.
    eventMTParent.__index = function(t, i)
        return function()
            return Iris._EventCall(thisWidget, i)
        end
    end
    return thisWidget
end

function Iris._Insert(widgetType: string, args, widgetState)
    local thisWidget
    local ID = Iris._getID(3)
    --debug.profilebegin(ID)

    local thisWidgetClass = Iris._widgets[widgetType]
    Iris._widgetCount += 1

    if Iris._VDOM[ID] then
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
    table.freeze(arguments)

    if Iris._lastVDOM[ID] and widgetType == Iris._lastVDOM[ID].type then
        -- found a matching widget from last frame
        if Iris._localRefreshActive then
            Iris._DiscardWidget(Iris._lastVDOM[ID])
        else
            thisWidget = Iris._lastVDOM[ID]
        end
    end
    if thisWidget == nil then
        -- didnt find a match, generate a new widget
        thisWidget = Iris._GenNewWidget(widgetType, arguments, widgetState, ID)
    end

    if Iris._deepCompare(thisWidget.arguments, arguments) == false then
        -- the widgets arguments have changed, the widget should update to reflect changes.
        thisWidget.arguments = arguments
        thisWidgetClass.Update(thisWidget)
    end

    thisWidget.lastCycleTick = Iris._cycleTick

    if thisWidgetClass.hasChildren then
        Iris._stackIndex += 1
        Iris._IDStack[Iris._stackIndex] = thisWidget.ID
    end

    Iris._VDOM[ID] = thisWidget
    Iris._lastWidget = thisWidget

    --debug.profileend()

    return thisWidget
end

--- @within Iris
--- @function Append
--- Allows the caller to insert any Roblox Instance into the current parent Widget.
function Iris.Append(userInstance)
    local parentWidget = Iris._GetParentWidget()
    local widgetInstanceParent
    if Iris._config.Parent then
        widgetInstanceParent = Iris._config.Parent
    else
        widgetInstanceParent = Iris._widgets[parentWidget.type].ChildAdded(parentWidget, {type = "userInstance"})
    end
    userInstance.Parent = widgetInstanceParent
end

--- @within Iris
--- @function End
--- This function marks the end of any widgets which contain children. For example:
--- ```lua
--- -- Widgets placed here **will not** be inside the tree
--- Iris.Tree({"My First Tree"})
---     -- Widgets placed here **will** be inside the tree
--- Iris.End()
--- -- Widgets placed here **will not** be inside the tree
--- ```
--- :::caution Caution: Error
--- Seeing the error `Callback has too few calls to Iris.End()` or `Callback has too many calls to Iris.End()`?
--- Using the wrong amount of `Iris.End()` calls in your code will lead to an error. Each widget called which might have children should be paired with a call to `Iris.End()`, **Even if the Widget doesnt currently have any children**.
--- :::
function Iris.End()
    if Iris._stackIndex == 1 then
        error("Callback has too many calls to Iris.End()", 2)
    end
    Iris._IDStack[Iris._stackIndex] = nil
    Iris._stackIndex -= 1
end

--- @within Iris
--- @prop TemplateConfig table
--- TemplateConfig provides a table of default styles and configurations which you may apply to your UI.
Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark) -- use colorDark and sizeDefault themes by default
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
Iris._globalRefreshRequested = false -- UpdatingGlobalConfig changes this to true, leads to Root being generated twice.

--- @within Iris
--- @function ShowDemoWindow
--- ShowDemoWindow is a function which creates a Demonstration window. this window contains many useful utilities for coders, and serves as a refrence for using every aspect of the library.
--- Ideally, the DemoWindow should always be available through your UI.
Iris.ShowDemoWindow = require(script.demoWindow)(Iris)

require(script.widgets)(Iris)

--- @class Widgets
--- Each widget is available through Iris.<widget name\>

--- @prop Text Widget
--- @within Widgets
--- A simple Textbox.
---
--- ```json 
--- hasChildren: false,
--- hasState: false,
--- Arguments: {
---     Text: String
--- },
--- Events: {
---     hovered: boolean
--- }
--- ```
Iris.Text = function(args)
    return Iris._Insert("Text", args)
end

--- @prop TextColored Widget
--- @within Widgets
--- A simple Textbox, which has colored text.
---
--- ```json
--- hasChildren: false,
--- hasState: false,
--- Arguments: {
---     Text: String
--- },
--- Events: {
---     hovered: boolean
--- }
--- ```
Iris.TextColored = function(args)
    return Iris._Insert("TextColored", args)
end

--- @prop TextWrapped Widget
--- @within Widgets
--- A simple Textbox, which has wrapped text.
--- The width of the text is determined by the ItemWidth config field.
---
--- ```json 
--- hasChildren: false,
--- hasState: false,
--- Arguments: {
---     Text: String,
---     Color: Color3
--- },
--- Events: {
---     hovered: boolean
--- }
--- ```
Iris.TextWrapped = function(args)
    return Iris._Insert("TextWrapped", args)
end

--- @prop Button Widget
--- @within Widgets
--- A simple button.
---
--- ```json 
--- hasChildren: false,
--- hasState: false,
--- Arguments: {
---     Text: String
--- },
--- Events: {
---     clicked: boolean,
---     hovered: boolean
--- }
--- ```
Iris.Button = function(args)
    return Iris._Insert("Button", args)
end

--- @prop SmallButton Widget
--- @within Widgets
--- A simple button, with reduced padding.
---
--- ```json 
--- hasChildren: false,
--- hasState: false,
--- Arguments: {
---     Text: String
--- },
--- Events: {
---     clicked: boolean,
---     hovered: boolean
--- }
--- ```
Iris.SmallButton = function(args)
    return Iris._Insert("SmallButton", args)
end

--- @prop Separator Widget
--- @within Widgets
--- A vertical or horizonal line, depending on the context, which visually seperates widgets.
---
--- ```json 
--- hasChildren: false,
--- hasState: false
--- ```
Iris.Separator = function(args)
    return Iris._Insert("Separator", args)
end

--- @prop Indent Widget
--- @within Widgets
--- Indents its child widgets.
---
--- ```json 
--- hasChildren: true,
--- hasState: false,
--- Arguments: {
---     Width: Number
--- }
--- ```
Iris.Indent = function(args)
    return Iris._Insert("Indent", args)
end

--- @prop SameLine Widget
--- @within Widgets
--- Positions its children in a row, horizontally
---
--- ```json 
--- hasChildren: true,
--- hasState: false,
--- Arguments: {
---     Width: Number
---     VerticalAlignment: Enum.VerticalAlignment
--- }
--- ```
Iris.SameLine = function(args)
    return Iris._Insert("SameLine", args)
end

--- @prop Group Widget
--- @within Widgets
--- Layout Widget, contains its children as a single group
---
--- ```json 
--- hasChildren: true,
--- hasState: false
--- ```
Iris.Group = function(args)
    return Iris._Insert("Group", args)
end

--- @prop Checkbox Widget
--- @within Widgets
--- A checkbox which can be checked or unchecked.
---
--- ```json 
--- hasChildren: false,
--- hasState: true,
--- Arguments: {
---     Text: string
--- },
--- Events: {
---     checked: boolean,
---     unchecked: boolean,
---     hovered: boolean
--- },
--- States: {
---     isChecked: boolean
--- }
--- ```
Iris.Checkbox = function(args, state)
    return Iris._Insert("Checkbox", args, state)
end

--- @prop Tree Widget
--- @within Widgets
--- A collapsable tree which contains children, positioned vertically.
---
--- ```json 
--- hasChildren: true,
--- hasState: true,
--- Arguments: {
---     Text: string,
---     SpanAvailWidth: boolean,
---     NoIndent: boolean
--- },
--- Events: {
---     collapsed: boolean,
---     uncollapsed: boolean,
---     hovered: boolean
--- },
--- States: {
---     isUncollapsed: boolean
--- }
--- ```
Iris.Tree = function(args, state)
    return Iris._Insert("Tree", args, state)
end

--- @prop InputNum Widget
--- @within Widgets
--- A field which allows the user to enter a number.
--- Also has buttons to increment and decrement the number.
---
--- ```json 
--- hasChildren: false,
--- hasState: true,
--- Arguments: {
---     Text: string,
---     Increment: number,
---     Min: number,
---     Max: number,
---     Format: string,
---     NoButtons: boolean,
---     NoField: boolean
--- },
--- Events: {
---     numberChanged: boolean,
---     hovered: boolean
--- },
--- States: {
---     number: number
--- }
--- ```
Iris.InputNum = function(args, state)
    return Iris._Insert("InputNum", args, state)
end

--- @prop InputText Widget
--- @within Widgets
--- A field which allows the user to enter text.
---
--- ```json
--- hasChildren: false,
--- hasState: true,
--- Arguments: {
---     Text: string,
---     TextHint: string
--- },
--- Events:  {
---     textChanged: boolean,
---     hovered: boolean
--- }
--- States: {
---     text: string
--- }
--- ```
Iris.InputText = function(args, state)
    return Iris._Insert("InputText", args, state)
end

--- @prop Tooltip Widget
--- @within Widgets
Iris.Tooltip = function(args)
    return Iris._Insert("Tooltip", args)
end

--- @prop Table Widget
--- @within Widgets
--- A layout widget which allows children to be displayed in configurable columns and rows.
---
--- ```json
--- hasChildren: true,
--- hasState: false,
--- Arguments: {
---     NumColumns: number,
---     RowBg: boolean,
---     BordersOuter: boolean,
---     BordersInner: boolean
--- },
--- Events: {
---     hovered: boolean
--- }
--- ```
Iris.Table = function(args, state)
    return Iris._Insert("Table", args, state)
end

--- @function NextColumn
--- @within Widgets
--- In a table, moves to the next available cell. if the current cell is in the last column,
--- then the next cell will be the first column of the next row.
Iris.NextColumn = Iris.NextColumn

--- @function SetColumnIndex
--- @within Widgets
--- @param index number
--- In a table, directly sets the index of the column
Iris.SetColumnIndex = Iris.SetColumnIndex

--- @function NextRow
--- @within Widgets
--- In a table, moves to the next available row,
--- skipping cells in the previous column if the last cell wasn't in the last column
Iris.NextRow = Iris.NextRow

--- @prop Window Widget
--- @within Widgets
--- A Window. should be used to contain most other Widgets. Cannot be inside other Widgets.
--- 
--- ```json
--- hasChildren: true,
--- hasState: true,
--- Arguments: {
---     Title: string,
---     NoTitleBar: boolean,
---     NoBackground: boolean,
---     NoCollapse: boolean,
---     NoClose: boolean,
---     NoMove: boolean,
---     NoScrollbar: boolean,
---     NoResize: boolean
--- },
--- Events: {
---     closed: boolean,
---     opened: boolean,
---     collapsed: boolean,
---     uncollapsed: boolean,
---     hovered: boolean
--- },
--- States: {
---     size: Vector2,
---     position: Vector2,
---     isUncollapsed: boolean,
---     isOpened: boolean,
---     scrollDistance: number
--- }
--- ```
Iris.Window = function(args, state)
    return Iris._Insert("Window", args, state)
end

--- @function SetFocusedWindow
--- @within Widgets
--- sets the Window widget to be focused
--- @param thisWidget table
Iris.SetFocusedWindow = Iris.SetFocusedWindow


return Iris