---
sidebar_position: 3
---

# Understanding State

An Iris State object is simply a table containg a value, and an array of connected widgets. It provides functions to get
or set the value, the latter of which will update any widgets UI that are dependent on that state. Functions can also be
connected which will be fired whenever the value changes.

A state object ultimately attempts to copy the behaviour that a pointer would do in other languages, but is not possible
in native Luau. A Luau table is the best option, because it is passed by reference.

## Types of State

Iris provides multiple different types of State objects, suited for different needs.

### State

The base and most common state type, which implements the basically functionality of any state object.

### WeakState

A WeakState is very similar to State, except that every time it is called by ID, using `Iris.WeakState()`, all connected
widgets and functions are removed, whilst keeping the value. This is useful if you need to disconnect any widgets from a
state, so that they no longer update, whilst also keeping the existing value.

### VariableState

A VariableState takes both a value, and a function which gives the new value of the state whenever it is changed. This
is designed for when you have a variable within a file, and want to link it to a state object. By default, when the
function is called, if the variable and state are different, it will choose the local variable value. But if the state
is changed, it will use the callback which is designed to update the local variable.

This is best shown with an example:
```lua
local myNumber = 5

local state = Iris.VariableState(myNumber, function(value)
    myNumber = value
end)
Iris.DragNum({ "My number" }, { number = state })
```

Here we create a state for a DragNum. If we update the value of `myNumber` within the code earlier, it will update the
state value. And if we drag the widget, and update the state, it will call our callback, where we update the value of
`myNumber`.

### TableState

A TableState acts like VariableState, but takes a table and index so that whenever the table value changes, the state
changes and vice versa. Because tables are shared, we do not need to provide a function to update the table value, and
is instead handled internally.

We can see this with an example:
```lua
local data = {
    myNumber = 5
}

local state = Iris.TableState(data, "myNumber")
Iris.DragNum({ "My number" }, { number = state })
```

A third argment provides extra functionality, allowing us to call a function before updating the table value, which can
be used when we need to change some other values, for example when enabling or disabling a class.

### ComputedState

ComputedState takes an existing state and a function which will convert the value of one state to a new one. We can use
this to ensure that a state always stays dependent on another state.
