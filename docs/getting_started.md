---
sidebar_position: 2
---

# Getting Started

## Understanding the API

The Iris API is fairly unique and can be difficult to understand initially. However, once understood, it
becomes much clearer and is consistent between all widgets.

We will use a Window as an example because it best demonstrates the API and is used in every Iris project.

The API documentation for a window is as follows and contains all the information we need:  
```lua
hasChildren = true
hasState = true
Arguments = {
	Title: string,
	NoTitleBar: boolean? = false,
	NoBackground: boolean? = false, -- the background behind the widget container.
	NoCollapse: boolean? = false,
	NoClose: boolean? = false,
	NoMove: boolean? = false,
	NoScrollbar: boolean? = false, -- the scrollbar if the window is too short for all widgets.
	NoResize: boolean? = false,
	NoNav: boolean? = false, -- unimplemented.
	NoMenu: boolean? = false -- whether the menubar will show if created.
}
Events = {
	opened: () -> boolean, -- once when opened.
	closed: () -> boolean, -- once when closed.
	collapsed: () -> boolean, -- once when collapsed.
	uncollapsed: () -> boolean, -- once when uncollapsed.
	hovered: () -> boolean -- fires when the mouse hovers over any of the window.
}
States = {
	size = State<Vector2>? = Vector2.new(400, 300),
	position = State<Vector2>?,
	isUncollapsed = State<boolean>? = true,
	isOpened = State<boolean>? = true,
	scrollDistance = State<number>? -- vertical scroll distance, if too short.
}
```

The first documentation says that a Window has children, and therefore, we know that calling `Iris.Windw()`
must always be followed eventually by `Iris.End()` to exit out of the window. We are then told that a window
has state, and the different states, their types and default values are shown in the State table. We are also
told that they are all optional, and will be created if not provided.

### Using Arguments

The next information is the Arguments table. This contains the ordered list of all arguments, the type and
default value if optional. For a Window, the Title is a required string, whereas the other arguments are all
optional booleans defaulting to false. We will thus need to provide a string as the first argument for any window.

:::info
THe arguments provided to a widget are sent as an array with index 1 as the first argument, index 2 as the
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
`Iris.Args.Window.Title` = 1
`Iris.Args.Window.NoClose` = 5
`Iris.Args.Window.NoResize` = 8

These are just shorthands, providing `{Title = "Title"}` or any variation of this will not work and will error.
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
the widget instead.
