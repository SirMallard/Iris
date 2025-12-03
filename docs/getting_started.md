---
sidebar_position: 2
---

# Getting Started

## Installing Iris

Iris is available to download using Wally, use the release from GitHub, or build yourself. It is best to
place Iris somewhere on the client, such as under `StarterPlayerScripts` or `ReplicatedStorage`. Once
Iris is installed, you can `require(path.to.Iris)` the module from any client script. To start Iris, you
will need to call `Iris.Init()` before using Iris anywhere else. This can be difficult when you have
multiple scripts running at the same time, so it is best to organise your code with a single entry point
to initialise Iris from.

# Checking Iris Works

We can first test Iris works properly by using the DemoWindow, to display all the widgets in Iris.
First we'll create a client script under `StarterPlayer.StarterPlayerScipts`, and put this into it:
```lua
local Iris = require(path.to.Iris)
local DemoWindow = require(path.to.Iris.demoWindow)

Iris.Init()
Iris:Connect(DemoWindow)
```
If we then run the game, we should see the Iris Demo Window appear on the screen. This shows that Iris
is working properly and we can start writing our own code. Check [here](./intro.md) for some example code,
read through the [`demoWindow.lua`](https://github.com/SirMallard/Iris/blob/main/lib/demoWindow.lua)
file to see how the demo window works, or check the rest of the documentation for each widget.

## Understanding the API

The Iris API is about calling functions to return widget objects. Each widget has a set of arguments, some
which are optional. Optional arguments are indicated by a `?` at the end.

We will use a Window as an example because it best demonstrates the API and is used in every Iris project.

The API documentation for a window is as follows and contains all the information we need:  
```
Window <Widget <HasChildren <HasState -- returns a widget, which contains children and uses state objects

Iris.Window(
    title: string, -- titlebar text of the window
    flags: WindowFlags?, -- optional bit flags, using Iris.WindowFlags, default is 0
    size: State<Vector>?, -- state size of the entire window, default is Vector2.new(400, 300)
    position: State<Vector2>?, -- state position relative to the top-left corner
    open: State<boolean>?, -- state for the entire window visible, or closed with just the titlebar, default is true
    shown: State<boolean?>, -- state to hide the entire widget, default is true
    scrollDistance: State<number>? -- state vertical scroll distance down the window
) → Window

interface Window {
    &: ParentWidget -- inherits from the ParentWidget interface
    opened: () → boolean -- once when opened
    closed: () → boolean -- once when closed
    shown: () → boolean -- once when shown
    hidden: () → boolean -- once when hidden
    hovered: () → boolean -- fires when the mouse hovers over any of the window
    
    arguments: {
        Title: string?,
        Flags: number
    }
    state: {
        size: State<Vector>,
        position: State<Vector2>,
        open: State<boolean>,
        shown: State<boolean>,
        scrollDistance: State<number>
    }
}

interface WindowFlags {
    NoTitleBar: 1 -- hide title bar
    NoBackground: 2 -- hide background colour
    NoCollapse: 4 -- hide collapsing button
    NoClose: 8 -- hide close button
    NoMove: 16 -- disable drag-to-move functionality
    NoScrollbar: 32 -- disable scrollbar
    NoResize: 64 -- disable drag-to-resize functionality
    NoNav: 128 -- unused
    NoMenu: 256 -- hide the menubar
}
```

The first documentation says that a Window:
1. has children, so any call to `Iris.Windw()` must end with a `Iris.End()`
2. has state, so each state will have default values, if not given

### Using Arguments

The arguments are provided like any regular function, with a number of defined 


The next information is the Arguments table. This contains the ordered list of all arguments, the type and
default value if optional. For a Window, the Title is a required string, whereas the other arguments are all
optional booleans defaulting to false. We will thus need to provide a string as the first argument for any window.

:::info
The arguments provided to a widget are sent as an array with index 1 as the first argument, index 2 as the
second and so on. This means it is possible to provide the arguments in a different order, such as
`{ [1] = "Title", [6] = true}` which provides the title and also sets `NoMove` to true. We therefore do not
have to provide
:::

We will ignore the Events table for now, since they are not required for calling a widget.

The window API prototype looks like this: `(arguments: { any }, states: { [string]: State<any> }?) -> Window`.
Each widget is a function which takes two parameters, an array of arguments and a string dictionary of States.
Notice how the arguments array is required but the state dictionary is optional, because none of the states
is optional. If the arguments were all optional, then the arguments array would itself also be optional.

Using this, we can now assemble our API call for a window. The arguments for this will be the `TItle`, `NoClose`
and `NoResize`. We will not provide any states, instead Iris will generate them for us. Our final function looks
like this:

```lua
local Iris = require(Iris)

-- These are all equivalent:
Iris.Window({"Title", nil, nil, nil, true, nil, nil, true})
Iris.Window({ [1] = "Title", [5] = true, [8] = true })
Iris.Window({ [Iris.Args.Window.Title] = "Title", [Iris.Args.Window.NoClose] = true, [Iris.Args.Window.NoResize] = true })
```
For the last two, the order no longer matters and the arguments can be placed in any order. The last one uses
`Iris.Args.[WIDGET].[ARGUMENT]` which contains the index or number for each argument position. It makes it clearer
which arguments you are using, but at the cost of longer function calls. This is generally only used for widgets
with rarely used arguments.
:::info
These are what the values actually are.
`Iris.Args.Window.Title` = 1
`Iris.Args.Window.NoClose` = 5
`Iris.Args.Window.NoResize` = 8

These are just shorthands, making it easier for you, if you choose to use them.

Providing `{Title = "Title"}` or any variation of this with a string index will not work and will error.
:::

Iris is designed to mainly use the first example, because it is very similar to Dear ImGui and acts the same way
as if providing the arguments directly to a function, where the order matters. However, because widgets have both
arguments and state, the separation into two tables is required and we cannot use a regular function.

### Using State

If we decided that we wanted to provide a state to the widget, we can use the state table to determine the correct
name and type for each widget. The state is what controls any properties which the user can both send and receive
data from a widget, which may be updated by either the user or by an interaction with the widget. For example,
moving a window around will change the position state. And if the user sets the position state somewhere in the
code, the window will be moved to that position.

:::info
States in Iris take the place of pointers in C++ that Dear ImGui uses. If we have a number and then provide it as
an parameter to a function, the value will be copied over in memory for the function and therefore updating the
number in the function would not update it outside the function. If Lua had pointers, this would work, but instead
we use states which are tables to store all the changes.
:::

Providing a state in Iris is very easy, we first create it and then provide it with the string name to the widget:
```lua
local positionState = Iris.State(Vector2.new(100, 100))

Iris.Window({ "Positioned Window" }, { position = positionState })
```

We now have access to the window position state which we can set or read from anywhere else in our code. When first
created, the window will be positioned at (100, 100) on the screen, but can still be moved around. Notice how we
provide the state number rather than an index for the state table.

We do not need to provide the state to use the widget, we can just grab it from the created widget:
```lua
local window = Iris.Window({ "Positioned Window" })

local positionState = window.state.position
```

### Using Events

We've covered children, arguments and state but not yet events. Events are what make widgets interactive and
allow us run code when we use a widget. Each widget has a set of predefined events which we can check for
every frame.

To listen to any event, we can just call the function on the widget like this:

```lua
local window = Iris.Window({"Window"})
-- the window has opened and uncollapsed events, which return booleans
if window.opened() and window.uncollapsed() then
    -- run the window code only if the window is actually open and uncollapsed,
    -- which is more efficient.

    -- the button has a clicked event, returning true when it is pressed
    if Iris.Button({"Click me"}).clicked() then
        -- run code if we click the button
    end
end
Iris.End()
```

Here, we are listening to events which are just functions that return a boolean if the condition is true.
We can refer to the API to find all the events, and they should be fairly self-explanatory in what they do.
Some events will only happen once when the user interacts with the widget, others will depend on the state of
the widget, such as if it is open.
