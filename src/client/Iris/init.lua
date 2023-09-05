--!optimize 2
local Types = require(script.Types)

--[=[
    @class Iris

    Iris; contains the all user-facing functions and properties.
    A set of internal functions can be found in `Iris.Internal` (only use unless you understand).
]=]
local Iris = {} :: Types.Iris
local Internal: Types.Internal = require(script.Internal)(Iris)

--[=[
    @prop Disabled boolean
    @within Iris

    While Iris.Disabled is true, execution of Iris and connected functions will be paused.
    The widgets are not destroyed, they are just frozen so no changes will happen to them.
]=]
Iris.Disabled = false

--[=[
    @prop Args table
    @within Iris

    Provides a list of every possible Argument for each type of widget to it's index.
    For instance, `Iris.Args.Window.NoResize`.
    The Args table is useful for using widget Arguments without remembering their order.
    ```lua
    Iris.Window({"My Window", [Iris.Args.Window.NoResize] = true})
    ```
]=]
Iris.Args = {}

--[=[
    @ignore
    @prop Events table
    @within Iris

    -todo: work out what this is used for.
]=]
Iris.Events = {}

--[=[
    @function Init
    @within Iris
    @param parentInstance Instance | nil -- instance which Iris will place UI in. defaults to [PlayerGui] if unspecified
    @param eventConnection RBXScriptSignal | () -> {} | nil
    @return Iris

    Initializes Iris and begins rendering. May only be called once.
    By default, Iris will create its widgets under the PlayerGui and use the Heartbeat event.
]=]
function Iris.Init(parentInstance: BasePlayerGui?, eventConnection: (RBXScriptSignal | () -> ())?): Types.Iris
    if parentInstance == nil then
        -- coalesce to playerGui
        parentInstance = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    if eventConnection == nil then
        -- coalesce to Heartbeat
        eventConnection = game:GetService("RunService").Heartbeat
    end
    Internal.parentInstance = parentInstance :: BasePlayerGui
    assert(Internal._started == false, "Iris.Init can only be called once.")
    Internal._started = true

    Internal._generateRootInstance()
    Internal._generateSelectionImageObject()

    -- spawns the connection to call `Internal._cycle()` within.
    task.spawn(function()
        if typeof(eventConnection) == "function" then
            while true do
                eventConnection()
                Internal._cycle()
            end
        elseif eventConnection ~= nil then
            eventConnection:Connect(function()
                Internal._cycle()
            end)
        end
    end)

    return Iris
end

--[=[
    @within Iris
    @method Connect
    @param callback function -- the callback containg the Iris code.
    
    Allows users to connect a function which will execute every Iris cycle, (cycle is determined by the callback or event passed to Iris.Init or default to Heartbeat).
    Multiple callbacks can be added to Iris from many different scripts or modules.
]=]
function Iris:Connect(callback: () -> ()) -- this uses method syntax for no reason.
    if Internal._started == false then
        warn("Iris:Connect() was called before calling Iris.Init(), the connected function will never run")
    end
    table.insert(Internal._connectedFunctions, callback)
end

--[=[
    @function Append
    @within Iris

    Allows the caller to insert any Roblox Instance into Iris. The parent can either be determined by the `_config.Parent`
    property or by the current parent widget from the stack.
]=]
function Iris.Append(userInstance: GuiObject)
    local parentWidget: Types.Widget = Internal._GetParentWidget()
    local widgetInstanceParent: GuiObject
    if Internal._config.Parent then
        widgetInstanceParent = Internal._config.Parent :: any
    else
        widgetInstanceParent = Internal._widgets[parentWidget.type].ChildAdded(parentWidget, { type = "userInstance" } :: Types.Widget)
    end
    userInstance.Parent = widgetInstanceParent
end

--[=[
    @function End
    @within Iris

    This function marks the end of any widgets which contain children. For example:
    ```lua
    -- Widgets placed here **will not** be inside the tree
    Iris.Tree({"My First Tree"})
        -- Widgets placed here **will** be inside the tree
    Iris.End()
    -- Widgets placed here **will not** be inside the tree
    ```
    :::caution Caution: Error
    Seeing the error `Callback has too few calls to Iris.End()` or `Callback has too many calls to Iris.End()`?
    Using the wrong amount of `Iris.End()` calls in your code will lead to an error. Each widget called which might have children should be paired with a call to `Iris.End()`, **Even if the Widget doesnt currently have any children**.
    :::
]=]
function Iris.End()
    if Internal._stackIndex == 1 then
        error("Callback has too many calls to Iris.End()", 2)
    end
    Internal._IDStack[Internal._stackIndex] = nil
    Internal._stackIndex -= 1
end

--[[
    ------------------------
        [SECTION] Config
    ------------------------
]]

--[=[
    @function ForceRefresh
    @within Iris

    Destroys and regenerates all instances used by Iris. Useful if you want to propogate state changes.
    :::caution Caution: Performance
    Because this function Deletes and Initializes many instances, it may cause **performance issues** when used with many widgets.
    In **no** case should it be called every frame.
    :::
]=]
function Iris.ForceRefresh()
    Internal._globalRefreshRequested = true
end

--[=[
    @function UpdateGlobalConfig
    @within Iris
    @param deltaStyle table -- a table containing the changes in style ex: `{ItemWidth = UDim.new(0, 100)}`

    Allows callers to customize the config which **every** widget will inherit from.
    It can be used along with Iris.TemplateConfig to easily swap styles, ex: ```Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight) -- use light theme```
    :::caution Caution: Performance
    this function internally calls [Iris.ForceRefresh] so that style changes are propogated, it may cause **performance issues** when used with many widgets.
    In **no** case should it be called every frame.
    :::
]=]
function Iris.UpdateGlobalConfig(deltaStyle: { [string]: any })
    for index, style in deltaStyle do
        Internal._rootConfig[index] = style
    end
    Iris.ForceRefresh()
end

--[=[
    @function PushConfig
    @within Iris
    @param deltaStyle table -- a table containing the changes in style ex: `{ItemWidth = UDim.new(0, 100)}`

    Allows callers to cascade a style, meaning that styles may be locally and hierarchically applied.
    Each call to Iris.PushConfig must be paired with a call to [Iris.PopConfig].
    For example:
    ```lua
    Iris.PushConfig({TextColor = Color3.fromRGB(128, 0, 256)})
        Iris.Text({"Colored Text!"})
    Iris.PopConfig()
    ```
]=]
function Iris.PushConfig(deltaStyle: { [string]: any })
    local ID = Iris.State(-1)
    if ID.value == -1 then
        ID:set(deltaStyle)
    else
        -- compare tables
        if Internal._deepCompare(ID:get(), deltaStyle) == false then
            -- refresh local
            Internal._localRefreshActive = true
            ID:set(deltaStyle)
        end
    end

    Internal._config = setmetatable(deltaStyle, {
        __index = Internal._config,
    }) :: any
end

--[=[
    @function PopConfig
    @within Iris

    Ends a PushConfig style.
    Each call to [Iris.PushConfig] must be paired with a call to Iris.PopConfig.
]=]
function Iris.PopConfig()
    Internal._localRefreshActive = false
    Internal._config = getmetatable(Internal._config :: any).__index
end

--[=[
    @prop TemplateConfig table
    @within Iris

    TemplateConfig provides a table of default styles and configurations which you may apply to your UI.
]=]
Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark) -- use colorDark and sizeDefault themes by default
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
Internal._globalRefreshRequested = false -- UpdatingGlobalConfig changes this to true, leads to Root being generated twice.

--[[
    --------------------
        [SECTION] ID
    --------------------
]]

--[=[
    @function PushId
    @within Iris
    @param id Types.ID -- custom id.

    Sets the id discriminator for the next widgets. Use [Iris.PopId] to remove it.
]=]
function Iris.PushId(id: Types.ID)
    assert(typeof(id) == "string", "Iris expected Iris.PushId id to PushId to be a string.")

    Internal._pushedId = tostring(id)
end

--[=[
    @function PopId
    @within Iris

    Removes the id discriminator set by [Iris.PushId].
]=]
function Iris.PopId()
    Internal._pushedId = nil
end

--[=[
    @function SetNextWidgetId
    @within Iris
    @param id Types.ID -- custom id.

    Sets the id for the next widget. Useful for using [Iris.Append] on the same widget.
    ```lua
    Iris.SetNextWidgetId("demo_window")
    Iris.Window({ "Window" })
        Iris.Text({ "Text one placed here." })
    Iris.End()

    -- later in the code

    Iris.SetNextWidgetId("demo_window")
    Iris.Window()
        Iris.Text({ "Text two placed here." })
    Iris.End()

    -- both text widgets will be placed under the same window despite being called separately.
    ```
]=]
function Iris.SetNextWidgetID(id: Types.ID)
    Internal._nextWidgetId = id
end

--[[
    -----------------------
        [SECTION] State
    -----------------------
]]

--[=[
    @function State
    @within Iris
    @param initialValue any -- The initial value for the state

    Constructs a new state object, subsequent ID calls will return the same object
    :::info
    Iris.State allows you to create "references" to the same value while inside your UI drawing loop.
    For example:
    ```lua
    Iris:Connect(function()
        local myNumber = 5;
        myNumber = myNumber + 1
        Iris.Text({"The number is: " .. myNumber})
    end)
    ```
    This is problematic. Each time the function is called, a new myNumber is initialized, instead of retrieving the old one.
    The above code will always display 6.
    ***
    Iris.State solves this problem:
    ```lua
    Iris:Connect(function()
        local myNumber = Iris.State(5)
        myNumber:set(myNumber:get() + 1)
        Iris.Text({"The number is: " .. myNumber})
    end)
    ```
    In this example, the code will work properly, and increment every frame.
    :::
]=]
function Iris.State(initialValue: any): Types.State
    local ID: Types.ID = Internal._getID(2)
    if Internal._states[ID] then
        return Internal._states[ID]
    end
    Internal._states[ID] = {
        value = initialValue,
        ConnectedWidgets = {},
        ConnectedFunctions = {},
    } :: any
    setmetatable(Internal._states[ID], Internal.StateClass)
    return Internal._states[ID]
end

--[=[
    @function State
    @within Iris
    @param initialValue any -- The initial value for the state

    Constructs a new state object, subsequent ID calls will return the same object, except all widgets connected to the state are discarded, the state reverts to the passed initialValue
]=]
function Iris.WeakState(initialValue: any): Types.State
    local ID: Types.ID = Internal._getID(2)
    if Internal._states[ID] then
        if #Internal._states[ID].ConnectedWidgets == 0 then
            Internal._states[ID] = nil
        else
            return Internal._states[ID]
        end
    end
    Internal._states[ID] = {
        value = initialValue,
        ConnectedWidgets = {},
        ConnectedFunctions = {},
    } :: any
    setmetatable(Internal._states[ID], Internal.StateClass)
    return Internal._states[ID]
end

--[=[
    @function ComputedState
    @within Iris
    @param firstState State -- State to bind to.
    @param onChangeCallback function -- callback which should return a value transformed from the firstState value
        
    Constructs a new State object, but binds its value to the value of another State.
    :::info
    A common use case for this constructor is when a boolean State needs to be inverted:
    ```lua
    Iris.ComputedState(otherState, function(newValue)
        return not newValue
    end)
    ```
    :::
]=]
function Iris.ComputedState(firstState: Types.State, onChangeCallback: (firstState: any) -> any): Types.State
    local ID: Types.ID = Internal._getID(2)

    if Internal._states[ID] then
        return Internal._states[ID]
    else
        Internal._states[ID] = {
            value = onChangeCallback(firstState.value),
            ConnectedWidgets = {},
            ConnectedFunctions = {},
        } :: any
        firstState:onChange(function(newValue: any)
            Internal._states[ID]:set(onChangeCallback(newValue))
        end)
        setmetatable(Internal._states[ID], Internal.StateClass)
        return Internal._states[ID]
    end
end

--[=[
    @function ShowDemoWindow
    @within Iris

    ShowDemoWindow is a function which creates a Demonstration window. this window contains many useful utilities for coders,
    and serves as a refrence for using each part of the library. Ideally, the DemoWindow should always be available in your UI.
    It is the same as any other callback you would connect to Iris using [Iris.Connect]
    ```lua
    Iris:Connect(Iris.ShowDemoWindow)
    ```
]=]
Iris.ShowDemoWindow = require(script.demoWindow)(Iris)

require(script.widgets)(Internal)
require(script.API)(Iris)

return Iris
