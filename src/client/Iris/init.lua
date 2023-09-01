--!optimize 2
local Types = require(script.Types)

--[=[
    @class Iris
---
    Iris; contains the library.
]=]
local Iris = {} :: Types.Iris

--[=[
    @prop Disabled boolean
    @within Iris
    While Iris.Disabled is true, Execution of Iris and connected functions will be paused
]=]
Iris.Disabled = false

--[=[
    @prop Args table
    @within Iris
    Provides a list of every possible Argument for each type of widget.
    For instance, `Iris.Args.Window.NoResize`.
    The Args table is useful for using widget Arguments without remembering their order.
    ```lua
    Iris.Window({"My Window", [Iris.Args.Window.NoResize] = true})
    ```
]=]
Iris.Args = {}

Iris.Events = {}

--[=[
    @function ForceRefresh
    @within Iris
    Destroys and regenerates all instances used by Iris. useful if you want to propogate state changes.
    :::caution Caution: Performance
    Because this function Deletes and Initializes many instances, it may cause **performance issues** when used with many widgets.
    In **no** case should it be called every frame.
    :::
]=]
function Iris.ForceRefresh()
    Iris._globalRefreshRequested = true
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
function Iris.UpdateGlobalConfig(deltaStyle: { [any]: any })
    for index, style in deltaStyle do
        Iris._rootConfig[index] = style
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
        if Iris._deepCompare(ID:get(), deltaStyle) == false then
            -- refresh local
            Iris._localRefreshActive = true
            ID:set(deltaStyle)
        end
    end
    Iris._config = setmetatable(deltaStyle, {
        __index = Iris._config,
    })
end

--[=[
    @function PopConfig
    @within Iris
    Ends a PushConfig style.
    Each call to [Iris.PushConfig] must be paired with a call to Iris.PopConfig.
]=]
function Iris.PopConfig()
    Iris._localRefreshActive = false
    Iris._config = getmetatable(Iris._config).__index
end

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
    local ID: Types.ID = Iris._getID(2)
    if Iris._states[ID] then
        return Iris._states[ID]
    end
    Iris._states[ID] = {
        value = initialValue,
        ConnectedWidgets = {},
        ConnectedFunctions = {},
    }
    setmetatable(Iris._states[ID], StateClass)
    return Iris._states[ID]
end

--[=[
    @function State
    @within Iris
    @param initialValue any -- The initial value for the state
    Constructs a new state object, subsequent ID calls will return the same object, except all widgets connected to the state are discarded, the state reverts to the passed initialValue
]=]
function Iris.WeakState(initialValue: any): Types.State
    local ID: Types.ID = Iris._getID(2)
    if Iris._states[ID] then
        if #Iris._states[ID].ConnectedWidgets == 0 then
            Iris._states[ID] = nil
        else
            return Iris._states[ID]
        end
    end
    Iris._states[ID] = {
        value = initialValue,
        ConnectedWidgets = {},
        ConnectedFunctions = {},
    }
    setmetatable(Iris._states[ID], StateClass)
    return Iris._states[ID]
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
    local ID: Types.ID = Iris._getID(2)

    if Iris._states[ID] then
        return Iris._states[ID]
    else
        Iris._states[ID] = {
            value = onChangeCallback(firstState.value),
            ConnectedWidgets = {},
            ConnectedFunctions = {},
        }
        firstState:onChange(function(newValue: any)
            Iris._states[ID]:set(onChangeCallback(newValue))
        end)
        setmetatable(Iris._states[ID], StateClass)
        return Iris._states[ID]
    end
end
-- constructor which uses ID derived from a widget object

--[=[
    @within Iris
    @function Init
    @param parentInstance Instance | nil -- instance which Iris will place UI in. defaults to [PlayerGui] if unspecified
    @param eventConnection RBXScriptSignal | () -> {} | nil
    @return Iris
    Initializes Iris. May only be called once.
]=]
function Iris.Init(parentInstance: BasePlayerGui?, eventConnection: (RBXScriptSignal | () -> {})?): Types.Iris
    if parentInstance == nil then
        -- coalesce to playerGui
        parentInstance = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    if eventConnection == nil then
        -- coalesce to Heartbeat
        eventConnection = game:GetService("RunService").Heartbeat
    end
    Iris.parentInstance = parentInstance
    assert(Iris._started == false, "Iris.Init can only be called once.")
    Iris._started = true

    Iris._generateRootInstance()
    Iris._generateSelectionImageObject()
    Iris._generateHoverOverlay()

    task.spawn(function()
        if typeof(eventConnection) == "function" then
            while true do
                eventConnection()
                Iris._cycle()
            end
        elseif eventConnection ~= nil then
            eventConnection:Connect(function()
                Iris._cycle()
            end)
        end
    end)

    return Iris
end

--[=[
    @within Iris
    @method Connect
    @param callback function -- allows users to connect a function which will execute every Iris cycle, (cycle is determined by the callback or event passed to Iris.Init)
]=]
function Iris:Connect(callback: () -> {}) -- this uses method syntax for no reason.
    if Iris._started == false then
        warn("Iris:Connect() was called before calling Iris.Init(), the connected function will never run")
    end
    table.insert(Iris._connectedFunctions, callback)
end

--[=[
    @within Iris
    @function Append
    Allows the caller to insert any Roblox Instance into the current parent Widget.
]=]
function Iris.Append(userInstance: GuiObject)
    local parentWidget: Types.Widget = Iris._GetParentWidget()
    local widgetInstanceParent: GuiObject
    if Iris._config.Parent then
        widgetInstanceParent = Iris._config.Parent
    else
        widgetInstanceParent = Iris._widgets[parentWidget.type].ChildAdded(parentWidget, { type = "userInstance" })
    end
    userInstance.Parent = widgetInstanceParent
end

--[=[
    @within Iris
    @function End
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
    if Iris._stackIndex == 1 then
        error("Callback has too many calls to Iris.End()", 2)
    end
    Iris._IDStack[Iris._stackIndex] = nil
    Iris._stackIndex -= 1
end

--[=[
    @within Iris
    @prop TemplateConfig table
    TemplateConfig provides a table of default styles and configurations which you may apply to your UI.
]=]
Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark) -- use colorDark and sizeDefault themes by default
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
Iris._globalRefreshRequested = false -- UpdatingGlobalConfig changes this to true, leads to Root being generated twice.

--[=[
    @within Iris
    @function ShowDemoWindow
    ShowDemoWindow is a function which creates a Demonstration window. this window contains many useful utilities for coders, and serves as a refrence for using each part of the library.
    Ideally, the DemoWindow should always be available in your UI.
]=]
Iris.ShowDemoWindow = require(script.demoWindow)(Iris)

require(script.widgets)(Iris)

require(script.API)(Iris)

return Iris
