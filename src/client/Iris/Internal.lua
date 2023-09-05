local Types = require(script.Parent.Types)

return function(Iris: Types.Iris): Types.Internal
    --[=[
        @class Internal
        An internal class within Iris containing all the backend data and functions for Iris to operate.
        It is recommended that you don't generally interact with Internal unless you understand what you are doing.
    ]=]
    local Internal = {} :: Types.Internal

    --[[
        ---------------------------------
            [SECTION] Properties
        ---------------------------------
    ]]

    Internal._started = false -- has Iris.connect been called yet
    Internal._cycleTick = 0 -- increments for each call to Cycle, used to determine the relative age and freshness of generated widgets

    -- Refresh
    Internal._globalRefreshRequested = false -- refresh means that all GUI is destroyed and regenerated, usually because a style change was made and needed to be propogated to all UI
    Internal._localRefreshActive = false -- if true, when _Insert is called, the widget called will be regenerated

    -- Widgets & Instances
    Internal._widgets = {}
    Internal._widgetCount = 0 -- only used to compute ZIndex, resets to 0 for every cycle
    Internal._stackIndex = 1 -- Points to the index that IDStack is currently in, when computing cycle
    Internal._rootInstance = nil
    Internal._rootWidget = {
        ID = "R",
        type = "Root",
        Instance = Internal._rootInstance,
        ZIndex = 0,
    }
    Internal._lastWidget = Internal._rootWidget -- widget which was most recently rendered

    -- Config
    Internal._rootConfig = {} -- root style which all widgets derive from
    Internal._config = Internal._rootConfig

    -- ID
    Internal._IDStack = { "R" }
    Internal._usedIDs = {} -- hash of IDs which are already used in a cycle, value is the # of occurances so that getID can assign a unique ID for each occurance
    Internal._pushedId = nil
    Internal._nextWidgetId = nil

    -- State
    Internal._states = {} -- Iris.States

    -- Callback
    Internal._postCycleCallbacks = {}
    Internal._connectedFunctions = {} -- functions which run each Iris cycle, connected by the user

    --[=[
        @prop _cycleCoroutine thread
        @within Internal

        The thread which handles all connected functions. Each connection is within a pcall statement which prevents
        Iris from crashing and instead stopping at the error.
    ]=]
    Internal._cycleCoroutine = coroutine.create(function()
        while true do
            for _, callback: () -> string in Internal._connectedFunctions do
                debug.profilebegin("Iris/Connection")
                local status: boolean, _error: string = pcall(callback)
                debug.profileend()
                if not status then
                    -- any error reserts the _stackIndex for the next frame and yeilds the error.
                    Internal._stackIndex = 1
                    coroutine.yield(false, _error)
                end
                if Internal._stackIndex ~= 1 then
                    -- has to be larger than 1 because of the check that it isint below 1 in Iris.End
                    Internal._stackIndex = 1
                    error("Callback has too few calls to Iris.End()", 0)
                end
            end
            -- after all callbacks, we yeild so it only runs once a frame.
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

        :::caution
        Never call ':set()` on a state when inside the the `:onChange()` callback of the same state. This will cause a continous callback.

        Never chain states together so that each state changes the value of another state in a cyclic nature. This will cause a continous callback.
        :::
    ]=]

    local StateClass = {}
    StateClass.__index = StateClass

    --[=[
        @method get
        @within State
        @return any
        
        Returns the states current value.
    ]=]
    function StateClass:get(): any -- you can also simply use .value
        return self.value
    end

    --[=[
        @method set
        @within State
        
        Allows the caller to assign the state object a new value, and returns the new value.
    ]=]
    function StateClass:set(newValue: any): any
        if newValue == self.value then
            -- no need to update on no change.
            return self.value
        end
        self.value = newValue
        for _, thisWidget: Types.Widget in self.ConnectedWidgets do
            Internal._widgets[thisWidget.type].UpdateState(thisWidget)
        end
        for _, callback in self.ConnectedFunctions do
            callback(newValue)
        end
        return self.value
    end

    --[=[
        @method onChange
        @within State
        
        Allows the caller to connect a callback which is called when the states value is changed.
    ]=]
    function StateClass:onChange(callback: (newValue: any) -> ())
        table.insert(self.ConnectedFunctions, callback)
    end

    Internal.StateClass = StateClass

    --[[
        ---------------------------
            [SECTION] Functions
        ---------------------------
    ]]

    --[=[
        @function _cycle
        @within Internal
        
        Called every frame to handle all of the widget management. Any previous frame data is ammended and everything updates.
    ]=]
    function Internal._cycle()
        --debug.profilebegin("Iris/Cycle")
        if Iris.Disabled then
            return -- Stops all rendering, effectively freezes the current frame with no interaction.
        end

        Internal._rootWidget.lastCycleTick = Internal._cycleTick
        if Internal._rootInstance == nil or Internal._rootInstance.Parent == nil then
            Iris.ForceRefresh()
        end

        for _, widget: Types.Widget in Internal._lastVDOM do
            if widget.lastCycleTick ~= Internal._cycleTick then
                -- a widget which used to be rendered was not called last frame, so we discard it.
                Internal._DiscardWidget(widget)
            end
        end

        -- represents all widgets created last frame. We keep the _lastVDOM to reuse widgets from the previous frame
        -- rather than creating a new instance every frame.
        Internal._lastVDOM = Internal._VDOM
        Internal._VDOM = Internal._generateEmptyVDOM()

        -- anything that wnats to run before the frame.
        task.spawn(function()
            for _, callback: () -> () in Internal._postCycleCallbacks do
                callback()
            end
        end)

        if Internal._globalRefreshRequested then
            -- rerender every widget
            --debug.profilebegin("Iris Refresh")
            Internal._generateSelectionImageObject()
            Internal._globalRefreshRequested = false
            for _, widget: Types.Widget in Internal._lastVDOM do
                Internal._DiscardWidget(widget)
            end
            Internal._generateRootInstance()
            Internal._lastVDOM = Internal._generateEmptyVDOM()
            --debug.profileend()
        end

        -- update counters
        Internal._cycleTick += 1
        Internal._widgetCount = 0
        table.clear(Internal._usedIDs)

        if Internal.parentInstance:IsA("GuiBase2d") and math.min(Internal.parentInstance.AbsoluteSize.X, Internal.parentInstance.AbsoluteSize.Y) < 100 then
            error("Iris Parent Instance is too small")
        end
        local compatibleParent: boolean = (Internal.parentInstance:IsA("GuiBase2d") or Internal.parentInstance:IsA("CoreGui") or Internal.parentInstance:IsA("PluginGui") or Internal.parentInstance:IsA("PlayerGui"))
        if compatibleParent == false then
            error("Iris Parent Instance cant contain GUI")
        end

        -- if we are running in Studio, we want full error tracebacks, so we don't have
        -- any pcall to protect from an error.
        if game:GetService("RunService"):IsStudio() then
            for _, callback: () -> () in Internal._connectedFunctions do
                callback()
            end
        else
            --debug.profilebegin("Iris/Generate")

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
            --debug.profileend()
        end
        --debug.profileend()
    end

    --[=[
        @ignore
        @function _NoOp
        @within Internal

        A dummy function which does nothing. Used as a placeholder for optional methods in a widget class.
        Used in `Internal.WidgetConstructor`
    ]=]
    function Internal._NoOp() end

    --  Widget

    --[=[
        @function WidgetConstructor
        @within Internal
        @param type string -- name used to denote the widget class.
        @param widgetClass Types.WidgetClass -- table of methods for the new widget.

        For each widget, a widget class is created which handles all the operations of a widget. This removes the class nature
        of widgets, and simplifies the available functions which can be applied to any widget. The widgets themselves are
        dumb tables containing all the data but no methods to handle any of the data apart from events.
    ]=]
    function Internal.WidgetConstructor(type: string, widgetClass: Types.WidgetClass)
        local Fields: { [string]: { [string]: { string } } } = {
            All = {
                Required = {
                    "Generate", -- generates the instance.
                    "Discard",
                    "Update",

                    -- not methods !
                    "Args",
                    "Events",
                    "hasChildren",
                    "hasState",
                },
                Optional = {},
            },
            IfState = {
                Required = {
                    "GenerateState",
                    "UpdateState",
                },
                Optional = {},
            },
            IfChildren = {
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
        local thisWidget = {} :: Types.WidgetClass
        for _, field: string in Fields.All.Required do
            assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets`)
            thisWidget[field] = widgetClass[field]
        end

        for _, field: string in Fields.All.Optional do
            if widgetClass[field] == nil then
                -- assign a dummy function which does nothing.
                thisWidget[field] = Internal._NoOp
            else
                thisWidget[field] = widgetClass[field]
            end
        end

        if widgetClass.hasState then
            for _, field: string in Fields.IfState.Required do
                assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with state`)
                thisWidget[field] = widgetClass[field]
            end
            for _, field: string in Fields.IfState.Optional do
                if widgetClass[field] == nil then
                    thisWidget[field] = Internal._NoOp
                else
                    thisWidget[field] = widgetClass[field]
                end
            end
        end

        if widgetClass.hasChildren then
            for _, field: string in Fields.IfChildren.Required do
                assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with children`)
                thisWidget[field] = widgetClass[field]
            end
            for _, field: string in Fields.IfChildren.Optional do
                if widgetClass[field] == nil then
                    thisWidget[field] = Internal._NoOp
                else
                    thisWidget[field] = widgetClass[field]
                end
            end
        end

        -- an internal table of all widgets to the widget class.
        Internal._widgets[type] = thisWidget
        -- allowing access to the index for each widget argument.
        Iris.Args[type] = thisWidget.Args

        local ArgNames: { [number]: string } = {}
        for index: string, argument: number in thisWidget.Args do
            ArgNames[argument] = index
        end
        thisWidget.ArgNames = ArgNames

        for index: string, _ in thisWidget.Events do
            if Iris.Events[index] == nil then
                Iris.Events[index] = function()
                    return Internal._EventCall(Internal._lastWidget, index)
                end
            end
        end
    end

    --[=[
        @function _Insert
        @within Internal
        @param widgetType: string -- name of widget class.
        @param arguments Types.WidgetArguments? -- arguments of the widget.
        @param states Types.States? -- states of the widget.
        @return Types.Widget -- the widget.

        Every widget is created through _Insert. An ID is generated based on the line of the calling code and is used to
        find the previous frame widget if it exists. If no widget exists, a new one is created.
    ]=]
    function Internal._Insert(widgetType: string, args: Types.WidgetArguments?, states: Types.States?): Types.Widget
        local thisWidget: Types.Widget
        local ID: Types.ID = Internal._getID(3)
        --debug.profilebegin(ID)

        -- fetch the widget class which contains all the functions for the widget.
        local thisWidgetClass: Types.WidgetClass = Internal._widgets[widgetType]
        Internal._widgetCount += 1

        if Internal._VDOM[ID] then
            -- widget already created once this frame, so we can append to it.
            return Internal._ContinueWidget(ID, widgetType)
        end

        local arguments: Types.Arguments = {} :: Types.Arguments
        if args ~= nil then
            if type(args) ~= "table" then
                args = { args }
            end

            -- convert the arguments to a key-value dictionary so arguments can be referred to by their name and not index.
            for index: number, argument: Types.Argument in args do
                arguments[thisWidgetClass.ArgNames[index]] = argument
            end
        end
        -- prevents tampering with the arguments which are used to check for changes.
        table.freeze(arguments)

        if Internal._lastVDOM[ID] and widgetType == Internal._lastVDOM[ID].type then
            -- found a matching widget from last frame.
            if Internal._localRefreshActive then
                -- we are redrawing every widget.
                Internal._DiscardWidget(Internal._lastVDOM[ID])
            else
                thisWidget = Internal._lastVDOM[ID]
            end
        end
        if thisWidget == nil then
            -- didnt find a match, generate a new widget.
            thisWidget = Internal._GenNewWidget(widgetType, arguments, states, ID)
        end

        if Internal._deepCompare(thisWidget.providedArguments, arguments) == false then
            -- the widgets arguments have changed, the widget should update to reflect changes.
            -- providedArguments is the frozen table which will not change.
            -- the arguments can be altered internally, which happens for the input widgets.
            thisWidget.arguments = Internal._deepCopy(arguments)
            thisWidget.providedArguments = arguments
            thisWidgetClass.Update(thisWidget)
        end

        thisWidget.lastCycleTick = Internal._cycleTick

        if thisWidgetClass.hasChildren then
            -- a parent widget, so we increase our depth.
            Internal._stackIndex += 1
            Internal._IDStack[Internal._stackIndex] = thisWidget.ID
        end

        Internal._VDOM[ID] = thisWidget
        Internal._lastWidget = thisWidget

        --debug.profileend()

        return thisWidget
    end

    --[=[
        @function _GenNewWidget
        @within Internal
        @param widgetType string
        @param arguments Types.Arguments -- arguments of the widget.
        @param states Types.States? -- states of the widget.
        @param ID Types.ID -- id of the new widget. Determined in `Internal._Insert`
        @return Types.Widget -- the newly created widget.

        All widgets are created as tables with properties. The widget class contains the functions to create the UI instances and
        update the widget or change state.
    ]=]
    function Internal._GenNewWidget(widgetType: string, arguments: Types.Arguments, states: Types.States?, ID: Types.ID): Types.Widget
        local parentId: Types.ID = Internal._IDStack[Internal._stackIndex]
        local thisWidgetClass: Types.WidgetClass = Internal._widgets[widgetType]

        -- widgets are just tables with properties.
        local thisWidget = {} :: Types.Widget
        setmetatable(thisWidget, thisWidget)

        thisWidget.ID = ID
        thisWidget.type = widgetType
        thisWidget.parentWidget = Internal._VDOM[parentId]
        thisWidget.trackedEvents = {}

        -- widgets have lots of space to ensure they are always visible.
        thisWidget.ZIndex = thisWidget.parentWidget.ZIndex + (Internal._widgetCount * 0x40) + Internal._config.ZIndexOffset

        thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
        thisWidget.Instance.Parent = if Internal._config.Parent then Internal._config.Parent else Internal._widgets[thisWidget.parentWidget.type].ChildAdded(thisWidget.parentWidget, thisWidget)

        -- we can modify the arguments table, but keep a frozen copy to compare for user-end changes.
        thisWidget.providedArguments = arguments
        thisWidget.arguments = Internal._deepCopy(arguments)
        thisWidgetClass.Update(thisWidget)

        local eventMTParent
        if thisWidgetClass.hasState then
            if states then
                for index: string, state: Types.State in states do
                    if not (type(state) == "table" and getmetatable(state :: any) == Internal.StateClass) then
                        -- generate a new state.
                        states[index] = Internal._widgetState(thisWidget, index, state)
                    end
                end

                thisWidget.state = states
                for _, state: Types.State in states do
                    state.ConnectedWidgets[thisWidget.ID] = thisWidget
                end
            else
                thisWidget.state = {}
            end

            thisWidgetClass.GenerateState(thisWidget)
            thisWidgetClass.UpdateState(thisWidget)

            -- the state MT can't be itself because state has to explicitly only contain stateClass objects
            thisWidget.stateMT = {}
            setmetatable(thisWidget.state, thisWidget.stateMT)

            thisWidget.__index = thisWidget.state
            eventMTParent = thisWidget.stateMT
        else
            eventMTParent = thisWidget
        end

        eventMTParent.__index = function(_, eventName: string)
            return function()
                return Internal._EventCall(thisWidget, eventName)
            end
        end
        return thisWidget
    end

    --[=[
        @function _ContinueWidget
        @within Internal
        @param ID Types.ID -- id of the widget.
        @param widgetType string
        @return Types.Widget -- the widget.

        Since the widget has already been created this frame, we can just add it back to the stack. There is no checking of
        arguments or states.
        Basically equivalent to the end of `Internal._Insert`.
    ]=]
    function Internal._ContinueWidget(ID: Types.ID, widgetType: string): Types.Widget
        local thisWidgetClass: Types.WidgetClass = Internal._widgets[widgetType]
        local thisWidget: Types.Widget = Internal._VDOM[ID]

        if thisWidgetClass.hasChildren then
            -- a parent widget so we increase our depth.
            Internal._stackIndex += 1
            Internal._IDStack[Internal._stackIndex] = thisWidget.ID
        end

        Internal._lastWidget = thisWidget
        return thisWidget
    end

    --[=[
        @function _DiscardWidget
        @within Internal
        @param widgetToDiscard Types.Widget

        Destroys the widget instance and updates any parent. This happens if the widget was not called in the
        previous frame. There is no code which needs to update any widget tables since they are already reset
        at the start before discarding happens.
    ]=]
    function Internal._DiscardWidget(widgetToDiscard: Types.Widget)
        local widgetParent = widgetToDiscard.parentWidget
        if widgetParent then
            -- if the parent needs to update it's children.
            Internal._widgets[widgetParent.type].ChildDiscarded(widgetParent, widgetToDiscard)
        end

        -- using the widget class discard function.
        Internal._widgets[widgetToDiscard.type].Discard(widgetToDiscard)
    end

    --[=[
        @function _widgetState
        @within Internal
        @param thisWidget Types.Widget -- widget the state belongs to.
        @param stateName string
        @param initialValue any
        @return Types.State -- the state for the widget.

        Connects the state to the widget. If no state exists then a new one is created. Called for every state in every
        widget if the user does not provide a state.
    ]=]
    function Internal._widgetState(thisWidget: Types.Widget, stateName: string, initialValue: any): Types.State
        local ID: Types.ID = thisWidget.ID .. stateName
        if Internal._states[ID] then
            Internal._states[ID].ConnectedWidgets[thisWidget.ID] = thisWidget
            return Internal._states[ID]
        else
            Internal._states[ID] = {
                value = initialValue,
                ConnectedWidgets = { [thisWidget.ID] = thisWidget },
                ConnectedFunctions = {},
            }
            setmetatable(Internal._states[ID], Internal.StateClass)
            return Internal._states[ID]
        end
    end

    --[=[
        @function _EventCall
        @within Internal
        @param thisWidget Types.Widget
        @param evetName string
        @return boolean -- the value of the event.

        A wrapper for any event on any widget. Automatically, Iris does not initialize events unless they are explicitly
        called so in the first frame, the event connections are set up. Every event is a function which returns a boolean.
    ]=]
    function Internal._EventCall(thisWidget: Types.Widget, eventName: string): boolean
        local Events: Types.Events = Internal._widgets[thisWidget.type].Events
        local Event: Types.Event = Events[eventName]
        assert(Event ~= nil, `widget {thisWidget.type} has no event of name {eventName}`)

        if thisWidget.trackedEvents[eventName] == nil then
            Event.Init(thisWidget)
            thisWidget.trackedEvents[eventName] = true
        end
        return Event.Get(thisWidget)
    end

    --[=[
        @function _GetParentWidget
        @within Internal
        @return Types.Widget -- the parent widget

        Returns the parent widget of the currently active widget, based on the stack depth.
    ]=]
    function Internal._GetParentWidget(): Types.Widget
        return Internal._VDOM[Internal._IDStack[Internal._stackIndex]]
    end

    -- Generate

    --[=[
        @ignore
        @function _generateEmptyVDOM
        @within Internal

        Creates the VDOM at the start of each frame containing jsut the root instance.
    ]=]
    function Internal._generateEmptyVDOM(): { [Types.ID]: Types.Widget }
        return {
            ["R"] = Internal._rootWidget,
        }
    end

    --[=[
        @ignore
        @function _generateRootInstance
        @within Internal

        Creates the root instance.
    ]=]
    function Internal._generateRootInstance()
        -- unsafe to call before Internal.connect
        Internal._rootInstance = Internal._widgets["Root"].Generate(Internal._widgets["Root"])
        Internal._rootInstance.Parent = Internal.parentInstance
        Internal._rootWidget.Instance = Internal._rootInstance
    end

    --[=[
        @ignore
        @function _generateSelctionImageObject
        @within Internal

        Creates the selection object for buttons.
    ]=]
    function Internal._generateSelectionImageObject()
        if Internal.SelectionImageObject then
            Internal.SelectionImageObject:Destroy()
        end

        local SelectionImageObject: Frame = Instance.new("Frame")
        SelectionImageObject.Position = UDim2.fromOffset(-1, -1)
        SelectionImageObject.Size = UDim2.new(1, 2, 1, 2)
        SelectionImageObject.BackgroundColor3 = Internal._config.SelectionImageObjectColor
        SelectionImageObject.BackgroundTransparency = Internal._config.SelectionImageObjectTransparency
        SelectionImageObject.BorderSizePixel = 0

        local UIStroke: UIStroke = Instance.new("UIStroke")
        UIStroke.Thickness = 1
        UIStroke.Color = Internal._config.SelectionImageObjectBorderColor
        UIStroke.Transparency = Internal._config.SelectionImageObjectBorderColor
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        UIStroke.Parent = SelectionImageObject

        local Rounding: UICorner = Instance.new("UICorner")
        Rounding.CornerRadius = UDim.new(0, 2)

        Rounding.Parent = SelectionImageObject

        Internal.SelectionImageObject = SelectionImageObject
    end

    -- Utility

    --[=[
        @function _getID
        @within Internal
        @param levelsToIgnore number -- used to skip over internal calls to `_getID`.

        Generates a unique ID for each widget which is based on the line that the widget is
        created from. This ensures that the function is heuristic and always returns the same
        id for the same widget.
    ]=]
    function Internal._getID(levelsToIgnore: number): Types.ID
        if Internal._nextWidgetId then
            local ID: Types.ID = Internal._nextWidgetId
            Internal._nextWidgetId = nil
            return ID
        end

        local i: number = 1 + (levelsToIgnore or 1)
        local ID: Types.ID = ""
        local levelInfo: number = debug.info(i, "l")
        while levelInfo ~= -1 and levelInfo ~= nil do
            ID ..= "+" .. levelInfo
            i += 1
            levelInfo = debug.info(i, "l")
        end

        if Internal._usedIDs[ID] then
            Internal._usedIDs[ID] += 1
        else
            Internal._usedIDs[ID] = 1
        end

        local discriminator = if Internal._pushedId then Internal._pushedId else Internal._usedIDs[ID]

        return ID .. ":" .. discriminator
    end

    --[=[
        @ignore
        @function _deepCompare
        @within Internal
        @param t1 table
        @param t2 table

        Compares two tables to check if they are the same. It uses a recursive iteration through one table
        to compare against the other. Used to determine if the arguments of a widget have changed since last
        frame.
    ]=]
    function Internal._deepCompare(t1: {}, t2: {}): boolean
        -- unoptimized ?
        for i, v1 in t1 do
            local v2 = t2[i]
            if type(v1) == "table" then
                if v2 and type(v2) == "table" then
                    if Internal._deepCompare(v1, v2) == false then
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

    --[=[
        @ignore
        @function _deepCopy
        @within Internal
        @param t table

        Performs a deep copy of a table so that neither table contains a shared reference.
    ]=]
    function Internal._deepCopy(t: {}): {}
        local copy: {} = {}

        for k: any, v: any in pairs(t) do
            if type(v) == "table" then
                v = Internal._deepCopy(v)
            end
            copy[k] = v
        end

        return copy
    end

    -- VDOM
    Internal._lastVDOM = Internal._generateEmptyVDOM()
    Internal._VDOM = Internal._generateEmptyVDOM()

    Iris.Internal = Internal
    Iris._config = Internal._config
    return Internal
end
