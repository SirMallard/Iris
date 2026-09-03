---
sidebar_position: 2
---

# Getting Started

## Installing Iris

Iris is available to download using Wally, use the release from GitHub, or build
yourself. It is best to place Iris somewhere on the client, such as under
`StarterPlayerScripts` or `ReplicatedStorage`. Once Iris is installed, you can
`require(path.to.Iris)` the module from any client script. To start Iris, you
will need to call `Iris.Init()` before using Iris anywhere else. This can be
difficult when you have multiple scripts running at the same time, so it is best
to organise your code with a single entry point to initialise Iris from.

# Checking Iris Works

We can first test Iris works properly by using the DemoWindow, to display all
the widgets in Iris. First we'll create a client script under
`StarterPlayer.StarterPlayerScipts`, and put this into it:
```lua
local Iris = require(path.to.Iris)
local DemoWindow = require(path.to.Iris.DemoWindow)

Iris.Init()
Iris:Connect(DemoWindow)
```
If we then run the game, we should see the Iris Demo Window appear on the
screen. This shows that Iris is working properly and we can start writing our
own code. Check [here](./intro.md) for some example code, read through the
[`DemoWindow.lua`](https://github.com/SirMallard/Iris/blob/main/lib/DemoWindow.lua)
file to see how the demo window works, or check the rest of the documentation
for each widget.

## Understanding the API

The Iris API is about calling functions to return widget objects. Each widget
has a set of arguments, some which are optional. Optional arguments are
indicated by a `?` at the end.

We will use a `Window` as an example because it best demonstrates all widget options and is used in every Iris project:
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
1. is a widget - must be called every frame
1. has children - any call to `Iris.Windw()` must end with a `Iris.End()`
2. has state - each state will have default values, if not given

In order to create a widget, we must call the function, as specified by the
function type. A function is called with a selction of arugments and states and
returns our widget object.

### Using Arguments

Arguments control the settings or behaviour of a widget. They may control how
the widget looks, what features it has and what values a state tied to the
widget can take. Some of the arguments are required, and others are optional.

For a `Window`, the `title` is a required string, but the `flags` and `State<>`
are optional.

#### Flags

The `flags` is a selection of boolean options, stored in a number (each bit is a
different option). Our flags are shown in the `WindowFlags` interface as well.
We can construct a selection of flags using either the `bit32.bor` or with
`+` addition.

For example, to create `WindowFlags` of  `NoClose`, `NoResize` and `NoMenu`, we
can use:
```lua
local flags = bit32.bor(Iris.WindowFlags.NoClose, Iris.WindowFlags.NoResize, Iris.WindowFlags.NoMenu)
-- or
local flags = Iris.WindowFlags.NoClose + Iris.WindowFlags.NoResize + Iris.WindowFlags.NoMenu
```

:::info
Using `bit32.bor` is the safer option, because addition will overflow to the
next bit if not used properly.
:::

### Using State

State is used to send and recieve values to and from a widget. Unlike arguments,
which affect the behaviour of the widget, the state determine the values. States
are passed after all the arguments for a widget. For most widgets, states are
optional and will come with default values if not specified.

For a `Window`, we have `size`, `position` as `Vector2` states, `open` and
`shown` as `boolean` states and `scrollDistance` as a `number` state.

:::info
States in Iris take the place of pointers in C++ that Dear ImGui uses. We use
tables because Luau passed the fully object.
:::

Providing a state in Iris is very easy. We first create it and then pass it into
the function:
```lua
local positionState = Iris.State(Vector2.new(100, 100))

Iris.Window("Positioned Window", nil, nil, positionState)
```

:::info
Notice how we pass nil values for the the `flags` argument and `size` state. The
order of parameters is very important.
:::

We now have access to the window position state which we can set or read from
anywhere else in our code. When first created, the window will be positioned at
(100, 100) on the screen, but can still be moved around.

#### Default

If we do not pass a state, the widget will create one. We can then modify this
state by taking it from the widget:
```lua
local window = Iris.Window("Positioned Window")

local positionState = window.state.position
```

### Using Events

Events are functions we call to check for a change in the widget. Each widget
will have a series of events, such as hovering, clicking, changing, etc.

To listen to any event, we can just call the function on the widget like this:

```lua
local window = Iris.Window("Window")
-- the window has shown and opened events, which return booleans
if window.shown() and window.opened() then
    -- run the window code only if the window is actually open and uncollapsed,
    -- which is more efficient.

    -- the button has a clicked event, returning true when it is pressed
    if Iris.Button({"Click me"}).clicked() then
        -- run code if we click the button
    end
end
Iris.End()
```

Here, we are listening to events which are just functions that return a boolean
if the condition is true. We can refer to the API to find all the events, and
they should be fairly self-explanatory in what they do. Some events will only
happen once when the user interacts with the widget, others will depend on the
state of the widget, such as if it is open.
