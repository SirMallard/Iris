--!strict
--!optimize 2

local Types = require(script.Parent.Types)
local Config = require(script.Parent.Config)

local Internal = {} --:: Types.Internal

Internal._version = [[ 2.5.0 ]]
Internal._started = false -- has Iris.connect been called yet
Internal._paused = false
Internal._shutdown = false
Internal._cycleTick = 0 -- increments for each call to Cycle, used to determine the relative age and freshness of generated widgets
Internal._deltaTime = 0

-- Refresh
Internal._globalRefreshRequested = false -- refresh means that all GUI is destroyed and regenerated, usually because a style change was made and needed to be propogated to all UI
Internal._refreshCounter = 0 -- if true, when _Insert is called, the widget called will be regenerated
Internal._refreshLevel = 1
Internal._refreshStack = table.create(16)

-- Widgets & Instances
Internal._widgets = {}
Internal._rootInstance = nil
Internal._rootWidget = {
    ID = "R",
    type = "Root",
    _lastCycleTick = 0,
    _trackedEvents = {},
    zindex = 0,
    zoffset = 0,
} :: Types.ParentWidget
Internal._lastWidget = Internal._rootWidget :: Types.Widget -- widget which was most recently rendered
Internal._parentInstance = (nil :: any) :: BasePlayerGui | GuiBase2d
Internal._selectionImageObject = nil :: Frame?

-- VDOM
Internal._lastVDOM = {} :: { [Types.ID]: Types.Widget }
Internal._VDOM = {} :: { [Types.ID]: Types.Widget }

Internal._arguments = {} :: { [string]: { string } }
Internal._events = {} :: { [string]: () -> () }

-- Config
Internal._rootConfig = {} :: Config.Config -- root style which all widgets derive from
Internal._config = Internal._rootConfig

-- ID
Internal._IDStack = { "R" } :: { Types.ID }
Internal._usedIDs = {} :: { [Types.ID]: number } -- hash of IDs which are already used in a cycle, value is the # of occurances so that getID can assign a unique ID for each occurance
Internal._pushedIds = {} :: { Types.ID }
Internal._newID = false
Internal._nextWidgetId = nil :: Types.ID?
Internal._stackIndex = 1 -- Points to the index that IDStack is currently in, when computing cycle

-- State
Internal._states = {} :: { [Types.ID]: Types.State<any> } -- Iris.States

-- Callback
Internal._postCycleCallbacks = {} :: { () -> () }
Internal._connectedFunctions = {} :: { () -> () } -- functions which run each Iris cycle, connected by the user
Internal._connections = {} :: { RBXScriptConnection }
Internal._initFunctions = {} :: { () -> () }

-- Error
Internal._eventConnection = nil :: RBXScriptConnection?
Internal._fullErrorTracebacks = game:GetService("RunService"):IsStudio()

--[=[
        @within Internal
        @prop _cycleCoroutine thread

        The thread which handles all connected functions. Each connection is within a pcall statement which prevents
        Iris from crashing and instead stopping at the error.
    ]=]
Internal._cycleCoroutine = coroutine.create(function()
    while Internal._started do
        for _, callback in Internal._connectedFunctions do
            debug.profilebegin("Iris/Connection")
            local status, _error: string = pcall(callback :: any)
            debug.profileend()
            if not status then
                -- any error reserts the _stackIndex for the next frame and yields the error.
                Internal._stackIndex = 1
                coroutine.yield(false, _error)
            end
        end
        -- after all callbacks, we yield so it only runs once a frame.
        coroutine.yield(true)
    end
end)

--[[
        -----------------------
            [SECTION] State
        -----------------------
    ]]

--[=[
        @class State
        This class wraps a value in getters and setters, its main purpose is to allow primatives to be passed as objects.
        Constructors for this class are available in [Iris]

        ```lua
        local state = Iris.State(0) -- we initialise the state with a value of 0

        -- these are equivalent. Ideally you should use `:get()` and ignore `.value`.
        print(state:get())
        print(state.value)

        state:set(state:get() + 1) -- increments the state by getting the current value and adding 1.

        state:onChange(function(newValue)
            print(`The value of the state is now: {newValue}`)
        end)
        ```

        :::caution Caution: Callbacks
        Never call `:set()` on a state when inside the `:onChange()` callback of the same state. This will cause a continous callback.

        Never chain states together so that each state changes the value of another state in a cyclic nature. This will cause a continous callback.
        :::
    ]=]
local StateClass = {}
StateClass.__index = StateClass

--[=[
        @within State
        @method get<T>
        @return T

        Returns the states current value.
    ]=]
function StateClass.get<T>(self: Types.State<T>) -- you can also simply use .value
    return self._value
end

--[=[
        @within State
        @method set<T>
        @param newValue T
        @param force boolean? -- force an update to all connections
        @return T

        Allows the caller to assign the state object a new value, and returns the new value.
    ]=]
function StateClass.set<T>(self: Types.State<T>, newValue: T, force: true?)
    if newValue == self._value and force ~= true then
        -- no need to update on no change.
        return self._value
    end
    self._value = newValue
    self._lastChangeTick = Internal._cycleTick
    for _, thisWidget: Types.Widget in self._connectedWidgets do
        if thisWidget._lastCycleTick ~= -1 then
            Internal._widgets[thisWidget.type].UpdateState(thisWidget)
        end
    end

    for _, callback in self._connectedFunctions do
        callback(newValue)
    end
    return self._value
end

--[=[
        @within State
        @method onChange<T>
        @param callback (newValue: T) -> ()
        @return () -> ()

        Allows the caller to connect a callback which is called when the states value is changed.

        :::caution Caution: Single
        Calling `:onChange()` every frame will add a new function every frame.
        You must ensure you are only calling `:onChange()` once for each callback for the state's entire lifetime.
        :::
    ]=]
function StateClass.onChange<T>(self: Types.State<T>, callback: (newValue: T) -> ())
    local connectionIndex: number = #self._connectedFunctions + 1
    self._connectedFunctions[connectionIndex] = callback
    return function()
        self._connectedFunctions[connectionIndex] = nil
    end
end

--[=[
        @within State
        @method changed<T>
        @return boolean

        Returns true if the state was changed on this frame.
    ]=]
function StateClass.changed<T>(self: Types.State<T>)
    return self._lastChangeTick + 1 == Internal._cycleTick
end

Internal._stateClass = StateClass

--[[
        ---------------------------
            [SECTION] Functions
        ---------------------------
    ]]

--[=[
        @within Internal
        @function _cycle

        Called every frame to handle all of the widget management. Any previous frame data is ammended and everything updates.
    ]=]
function Internal._cycle(deltaTime: number)
    -- debug.profilebegin("Iris/Cycle")
    if Internal._paused then
        return -- Stops all rendering, effectively freezes the current frame with no interaction.
    end

    Internal._rootWidget._lastCycleTick = Internal._cycleTick
    if Internal._rootInstance == nil or Internal._rootInstance.Parent == nil then
        Internal._globalRefreshRequested = true
    end

    for _, widget in Internal._lastVDOM do
        if widget._lastCycleTick ~= Internal._cycleTick and (widget._lastCycleTick ~= -1) then
            -- a widget which used to be rendered was not called last frame, so we discard it.
            -- if the cycle tick is -1 we have already discarded it.
            Internal._discardWidget(widget)
        end
    end

    -- represents all widgets created last frame. We keep the _lastVDOM to reuse widgets from the previous frame
    -- rather than creating a new instance every frame.
    setmetatable(Internal._lastVDOM, { __mode = "kv" })
    Internal._lastVDOM = Internal._VDOM
    Internal._VDOM = Internal._generateEmptyVDOM()

    -- anything that wnats to run before the frame.
    task.spawn(function()
        -- debug.profilebegin("Iris/PostCycleCallbacks")
        for _, callback in Internal._postCycleCallbacks do
            callback()
        end
        -- debug.profileend()
    end)

    if Internal._globalRefreshRequested then
        -- rerender every widget
        --debug.profilebegin("Iris Refresh")
        Internal._generateSelectionImageObject()
        Internal._globalRefreshRequested = false
        for _, widget in Internal._lastVDOM do
            Internal._discardWidget(widget)
        end
        Internal._generateRootInstance()
        Internal._lastVDOM = Internal._generateEmptyVDOM()
        --debug.profileend()
    end

    -- update counters
    Internal._cycleTick += 1
    Internal._deltaTime = deltaTime
    table.clear(Internal._usedIDs)

    -- if Internal.parentInstance:IsA("GuiBase2d") and math.min(Internal.parentInstance.AbsoluteSize.X, Internal.parentInstance.AbsoluteSize.Y) < 100 then
    --     error("Iris Parent Instance is too small")
    -- end
    local compatibleParent = (Internal._parentInstance:IsA("GuiBase2d") or Internal._parentInstance:IsA("BasePlayerGui"))
    if compatibleParent == false then
        error("The Iris parent instance will not display any GUIs.")
    end

    -- if we are running in Studio, we want full error tracebacks, so we don't have
    -- any pcall to protect from an error.
    if Internal._fullErrorTracebacks then
        -- debug.profilebegin("Iris/Cycle/Callback")
        for _, callback in Internal._connectedFunctions do
            callback()
        end
    else
        -- debug.profilebegin("Iris/Cycle/Coroutine")

        -- each frame we check on our thread status.
        local coroutineStatus = coroutine.status(Internal._cycleCoroutine)
        if coroutineStatus == "suspended" then
            -- suspended means it yielded, either because it was a complete success
            -- or it caught an error in the code. We run it again for this frame.
            local _, success, result = coroutine.resume(Internal._cycleCoroutine)
            if success == false then
                -- Connected function code errored
                error(result, 0)
            end
        elseif coroutineStatus == "running" then
            -- still running (probably because of an asynchronous method inside a connection).
            error("Iris cycleCoroutine took to long to yield. Connected functions should not yield.")
        else
            -- should never reach this (nothing you can do).
            error("unrecoverable state")
        end
        -- debug.profileend()
    end

    if Internal._stackIndex ~= 1 then
        -- has to be larger than 1 because of the check that it isnt below 1 in Iris.End
        Internal._stackIndex = 1
        error("Too few calls to Iris.End().", 0)
    end

    -- Errors if the end user forgot to pop all their ids as they would leak over into the next frame
    -- could also just clear, but that might be confusing behaviour.
    if #Internal._pushedIds ~= 0 then
        error("Too few calls to Iris.PopId().", 0)
    end

    -- debug.profileend()
end

--[=[
        @within Internal
        @ignore
        @function _NoOp

        A dummy function which does nothing. Used as a placeholder for optional methods in a widget class.
        Used in `Internal.WidgetConstructor`
    ]=]
function Internal._noOp() end
--  Widget

--[=[
        @within Internal
        @function WidgetConstructor
        @param type string -- name used to denote the widget class.
        @param widgetClass Types.WidgetClass -- table of methods for the new widget.

        For each widget, a widget class is created which handles all the operations of a widget. This removes the class nature
        of widgets, and simplifies the available functions which can be applied to any widget. The widgets themselves are
        dumb tables containing all the data but no methods to handle any of the data apart from events.
    ]=]
function Internal._widgetConstructor(type: string, widgetClass: Types.WidgetClass)
    local Fields = {
        All = {
            Required = {
                "Generate", -- generates the instance.
                "Discard",
                "Update",

                -- not methods !
                "hasChildren",
                "hasState",
                "numArguments",
                "Arguments",
                "Events",
            },
            Optional = {},
        },
        State = {
            Required = {
                "GenerateState",
                "UpdateState",
            },
            Optional = {},
        },
        Children = {
            Required = {
                "ChildAdded", -- returns the parent of the child widget.
            },
            Optional = {
                "ChildDiscarded",
            },
        },
    }

    -- we ensure all essential functions and properties are present, otherwise the code will break later.
    -- some functions will only be needed if the widget has children or has state.
    local thisWidgetClass = {} :: Types.WidgetClass
    for _, field in Fields.All.Required do
        assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets`)
        thisWidgetClass[field] = widgetClass[field]
    end

    for _, field in Fields.All.Optional do
        thisWidgetClass[field] = widgetClass[field] or Internal._noOp
    end

    if widgetClass.hasState then
        for _, field in Fields.State.Required do
            assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with state`)
            thisWidgetClass[field] = widgetClass[field]
        end
        for _, field in Fields.State.Optional do
            thisWidgetClass[field] = widgetClass[field] or Internal._noOp
        end
    end

    if widgetClass.hasChildren then
        for _, field in Fields.Children.Required do
            assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with children`)
            thisWidgetClass[field] = widgetClass[field]
        end
        for _, field in Fields.Children.Optional do
            thisWidgetClass[field] = widgetClass[field] or Internal._noOp
        end
    end

    -- an internal table of all widgets to the widget class.
    Internal._widgets[type] = thisWidgetClass
    -- allowing access to the index for each widget argument.
    Internal._arguments[type] = thisWidgetClass.Arguments

    for index, _ in thisWidgetClass.Events do
        if Internal._events[index] == nil then
            Internal._events[index] = function()
                return Internal._eventCall(Internal._lastWidget, index)
            end
        end
    end
end

--[=[
        @within Internal
        @function _Insert
        @param widgetType: string -- name of widget class.
        @param arguments { [string]: number } -- arguments of the widget.
        @param states { [string]: States<any> }? -- states of the widget.
        @return Widget -- the widget.

        Every widget is created through _Insert. An ID is generated based on the line of the calling code and is used to
        find the previous frame widget if it exists. If no widget exists, a new one is created.
    ]=]
function Internal._insert(widgetType: string, ...: any)
    local ID = Internal._getID(3)
    --debug.profilebegin(ID)

    -- fetch the widget class which contains all the functions for the widget.
    local thisWidgetClass = Internal._widgets[widgetType]

    if Internal._VDOM[ID] then
        -- widget already created once this frame, so we can append to it.
        return Internal._continueWidget(ID, widgetType)
    end

    local lastWidget = Internal._lastVDOM[ID] :: Types.Widget?
    if lastWidget and widgetType == lastWidget.type then
        -- found a matching widget from last frame.
        if Internal._refreshCounter > 0 then
            -- we are redrawing every widget.
            Internal._discardWidget(lastWidget)
            lastWidget = nil
        end
    end
    local thisWidget = if lastWidget == nil then Internal._genNewWidget(widgetType, ID, ...) else lastWidget

    local parentWidget = thisWidget.parentWidget

    if thisWidget.type ~= "Window" and thisWidget.type ~= "Tooltip" then
        if thisWidget.zindex ~= parentWidget.zoffset then
            parentWidget.zupdate = true
        end

        if parentWidget.zupdate then
            thisWidget.zindex = parentWidget.zoffset
            if thisWidget.instance then
                thisWidget.instance.ZIndex = thisWidget.zindex
                thisWidget.instance.LayoutOrder = thisWidget.zindex
            end
        end
    end

    -- since rows are not instances, but will be removed if not updated, we have to add specific table code.
    if parentWidget.type == "Table" then
        local Table = parentWidget :: any --Types.Table
        Table._rowCycles[Table._rowIndex] = Internal._cycleTick
    end

    local update = false
    -- convert the arguments to a key-value dictionary so arguments can be referred to by their name and not index.
    for index, argument in { ... } do
        if index > thisWidgetClass.numArguments then
            break
        end
        local name = thisWidgetClass.Arguments[index]
        local previous = thisWidget.arguments[name]
        if previous ~= argument then
            update = true
        end
        thisWidget.arguments[name] = argument
    end

    if update then
        thisWidgetClass.Update(thisWidget)
    end

    thisWidget._lastCycleTick = Internal._cycleTick
    parentWidget.zoffset += 1

    if thisWidgetClass.hasChildren then
        local thisParent = thisWidget :: Types.ParentWidget
        -- a parent widget, so we increase our depth.
        thisParent.zoffset = 0
        thisParent.zupdate = false
        Internal._stackIndex += 1
        Internal._IDStack[Internal._stackIndex] = thisWidget.ID
    end

    Internal._VDOM[ID] = thisWidget
    Internal._lastWidget = thisWidget

    --debug.profileend()

    return thisWidget
end

--[=[
        @within Internal
        @function _GenNewWidget
        @param widgetType string
        @param arguments { [string]: any } -- arguments of the widget.
        @param states { [string]: State<any> }? -- states of the widget.
        @param ID ID -- id of the new widget. Determined in `Internal._Insert`
        @return Widget -- the newly created widget.

        All widgets are created as tables with properties. The widget class contains the functions to create the UI instances and
        update the widget or change state.
    ]=]
function Internal._genNewWidget(widgetType: string, ID: Types.ID, ...: any)
    local parentId = Internal._IDStack[Internal._stackIndex]
    local parentWidget = Internal._VDOM[parentId] :: Types.ParentWidget
    local thisWidgetClass = Internal._widgets[widgetType]

    -- widgets are just tables with properties.
    local thisWidget = {
        ID = ID,
        type = widgetType,
        _lastCycleTick = Internal._cycleTick,
        _trackedEvents = {},
        parentWidget = parentWidget,

        arguments = {},
    } :: Types.Widget

    -- widgets have lots of space to ensure they are always visible.
    thisWidget.zindex = parentWidget.zoffset

    thisWidget.instance = thisWidgetClass.Generate(thisWidget)
    -- tooltips set their parent in the generation method, so we need to udpate it here
    parentWidget = thisWidget.parentWidget

    thisWidget.instance.Parent = Internal._config.Parent or Internal._widgets[parentWidget.type].ChildAdded(parentWidget, thisWidget)

    -- we can modify the arguments table, but keep a frozen copy to compare for user-end changes.
    for index, argument in { ... } do
        if index > thisWidgetClass.numArguments then
            break
        end
        thisWidget.arguments[thisWidgetClass.Arguments[index]] = argument
    end
    thisWidgetClass.Update(thisWidget)

    if thisWidgetClass.hasState then
        local stateWidget = thisWidget :: Types.StateWidget
        stateWidget.state = {}
        for index, state: Types.State<any> in select(thisWidgetClass.numArguments + 1, ...) or {} do
            state._lastChangeTick = Internal._cycleTick
            state._connectedWidgets[ID] = stateWidget
            stateWidget.state[thisWidgetClass.Arguments[index]] = state
        end

        thisWidgetClass.GenerateState(stateWidget)
        thisWidgetClass.UpdateState(stateWidget)
    end

    -- allowing indexing for event calls
    thisWidget.__index = function(_, eventName)
        return function()
            return Internal._eventCall(thisWidget, eventName)
        end
    end
    setmetatable(thisWidget, thisWidget)

    return thisWidget :: any
end

--[=[
        @within Internal
        @function _ContinueWidget
        @param ID ID -- id of the widget.
        @param widgetType string
        @return Widget -- the widget.

        Since the widget has already been created this frame, we can just add it back to the stack. There is no checking of
        arguments or states.
        Basically equivalent to the end of `Internal._Insert`.
    ]=]
function Internal._continueWidget(ID: Types.ID, widgetType: string)
    local thisWidgetClass = Internal._widgets[widgetType]
    local thisWidget = Internal._VDOM[ID]

    if thisWidgetClass.hasChildren then
        -- a parent widget so we increase our depth.
        Internal._stackIndex += 1
        Internal._IDStack[Internal._stackIndex] = thisWidget.ID
    end

    Internal._lastWidget = thisWidget
    return thisWidget
end

--[=[
        @within Internal
        @function _DiscardWidget
        @param widgetToDiscard Widget

        Destroys the widget instance and updates any parent. This happens if the widget was not called in the
        previous frame. There is no code which needs to update any widget tables since they are already reset
        at the start before discarding happens.
    ]=]
function Internal._discardWidget(widgetToDiscard: Types.Widget)
    local widgetParent = widgetToDiscard.parentWidget
    if widgetParent then
        -- if the parent needs to update it's children.
        Internal._widgets[widgetParent.type].ChildDiscarded(widgetParent, widgetToDiscard)
    end

    -- using the widget class discard function.
    Internal._widgets[widgetToDiscard.type].Discard(widgetToDiscard)

    -- mark as discarded
    widgetToDiscard._lastCycleTick = -1
end

--[=[
        @within Internal
        @function _widgetState
        @param thisWidget Widget -- widget the state belongs to.
        @param stateName string
        @param initialValue any
        @return State<any> -- the state for the widget.

        Connects the state to the widget. If no state exists then a new one is created. Called for every state in every
        widget if the user does not provide a state.
    ]=]
function Internal._widgetState<T>(thisWidget: Types.StateWidget, stateName: string, initialValue: T)
    local ID = thisWidget.ID .. stateName
    if Internal._states[ID] then
        Internal._states[ID]._connectedWidgets[thisWidget.ID] = thisWidget
        Internal._states[ID]._lastChangeTick = Internal._cycleTick
        return Internal._states[ID]
    else
        local newState = {
            ID = ID,
            _value = initialValue,
            _lastChangeTick = Internal._cycleTick,
            _connectedWidgets = { [thisWidget.ID] = thisWidget },
            _connectedFunctions = {},
        } :: Types.State<T>

        Internal._states[ID] = newState
        setmetatable(newState, StateClass)
        return newState :: any
    end
end

--[=[
        @within Internal
        @function _EventCall
        @param thisWidget Widget
        @param evetName string
        @return boolean -- the value of the event.

        A wrapper for any event on any widget. Automatically, Iris does not initialize events unless they are explicitly
        called so in the first frame, the event connections are set up. Every event is a function which returns a boolean.
    ]=]
function Internal._eventCall(thisWidget: Types.Widget, eventName: string)
    local Events = Internal._widgets[thisWidget.type].Events
    local Event = Events[eventName]
    assert(Event ~= nil, `widget {thisWidget.type} has no event of name {eventName}`)

    if thisWidget._trackedEvents[eventName] == nil then
        Event.Init(thisWidget)
        thisWidget._trackedEvents[eventName] = true
    end
    return Event.Get(thisWidget)
end

--[=[
        @within Internal
        @function _GetParentWidget
        @return Widget -- the parent widget

        Returns the parent widget of the currently active widget, based on the stack depth.
    ]=]
function Internal._getParentWidget(): Types.ParentWidget
    return Internal._VDOM[Internal._IDStack[Internal._stackIndex]] :: Types.ParentWidget
end

-- Generate

--[=[
        @ignore
        @within Internal
        @function _generateEmptyVDOM
        @return { [ID]: Widget }

        Creates the VDOM at the start of each frame containing just the root instance.
    ]=]
function Internal._generateEmptyVDOM()
    return {
        ["R"] = Internal._rootWidget,
    }
end

--[=[
        @ignore
        @within Internal
        @function _generateRootInstance

        Creates the root instance.
    ]=]
function Internal._generateRootInstance()
    -- unsafe to call before Internal.connect
    local instance = Internal._widgets["Root"].Generate(Internal._rootWidget)
    instance.Parent = Internal._parentInstance
    Internal._rootWidget.instance = instance
    Internal._rootInstance = instance
end

--[=[
        @ignore
        @within Internal
        @function _generateSelctionImageObject

        Creates the selection object for buttons.
    ]=]
function Internal._generateSelectionImageObject()
    if Internal._selectionImageObject then
        Internal._selectionImageObject:Destroy()
    end

    local SelectionImageObject = Instance.new("Frame")
    SelectionImageObject.Position = UDim2.fromOffset(-1, -1)
    SelectionImageObject.Size = UDim2.new(1, 2, 1, 2)
    SelectionImageObject.BackgroundColor3 = Internal._config.SelectionImageObjectColor
    SelectionImageObject.BackgroundTransparency = Internal._config.SelectionImageObjectTransparency
    SelectionImageObject.BorderSizePixel = 0

    local UIStrokeInstance = Instance.new("UIStroke")
    UIStrokeInstance.Thickness = 1
    UIStrokeInstance.Color = Internal._config.SelectionImageObjectBorderColor
    UIStrokeInstance.Transparency = Internal._config.SelectionImageObjectBorderTransparency
    UIStrokeInstance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStrokeInstance.LineJoinMode = Enum.LineJoinMode.Round
    UIStrokeInstance.Parent = SelectionImageObject

    local UICornerInstance = Instance.new("UICorner")
    UICornerInstance.CornerRadius = UDim.new(0, 2)
    UICornerInstance.Parent = SelectionImageObject

    Internal._selectionImageObject = SelectionImageObject
end

-- Utility

--[=[
        @within Internal
        @function _getID
        @param levelsToIgnore number -- used to skip over internal calls to `_getID`.
        @return ID

        Generates a unique ID for each widget which is based on the line that the widget is
        created from. This ensures that the function is heuristic and always returns the same
        id for the same widget.
    ]=]
function Internal._getID(levelsToIgnore: number)
    if Internal._nextWidgetId then
        local ID = Internal._nextWidgetId
        Internal._nextWidgetId = nil
        return ID
    end

    local i = 1 + (levelsToIgnore or 1)
    local ID = ""
    local levelInfo = debug.info(i, "l")
    while levelInfo ~= -1 and levelInfo ~= nil do
        ID ..= "+" .. levelInfo
        i += 1
        levelInfo = debug.info(i, "l")
    end

    local discriminator = Internal._usedIDs[ID]
    if discriminator then
        Internal._usedIDs[ID] += 1
        discriminator += 1
    else
        Internal._usedIDs[ID] = 1
        discriminator = 1
    end

    if #Internal._pushedIds == 0 then
        return ID .. ":" .. discriminator
    elseif Internal._newID then
        return ID .. "::" .. table.concat(Internal._pushedIds, "\\")
    else
        return ID .. ":" .. discriminator .. ":" .. table.concat(Internal._pushedIds, "\\")
    end
end

-- VDOM
Internal._lastVDOM = Internal._generateEmptyVDOM()
Internal._VDOM = Internal._generateEmptyVDOM()

return Internal
