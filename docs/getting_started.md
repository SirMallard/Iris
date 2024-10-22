---
sidebar_position: 2
---

# Getting Started

## Understanding the API

The Iris API is fairly unique and can be difficult to understand initially. However, once understood, it becomes much clearer and is consistent between all widgets.

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

The first documentation says that a Window has children, and therefore, we know that calling `Iris.Windw()` must always be followed eventually by `Iris.End()` to exit out of the window. We are then told that a window has state, and the different states, their types and default values are shown in the State table. We are also told that they are all optional, and will be created if not provided.

The next information is the Arguments table. This contains the ordered list of all arguments, the type and default value if optional. For a Window, the Title is a required string, whereas the other arguments are all optional booleans defaulting to false. We will thus need to provide a string as the first argument for any window.

:::info
THe arguments provided to a widget are sent as an array with index 1 as the first argument, index 2 as the second and so on. This means it is possible to provide the arguments in a different order, such as `{ [1] = "Title", [6] = true}` which provides the title and also sets `NoMove` to true. We therefore do not have to provide
:::

We will ignore the Events table for now, since they are not required for calling a widget.

The window API prototype looks like this: () -> ()


```lua
local Iris = require(Iris)

Iris.Window({""})
Iris.Window({"Title", false})
Iris.Window({"Title"}, {})
Iris.Window({"Title"}, {size = Iris.State(Vector2.new(200, 300))})

```
