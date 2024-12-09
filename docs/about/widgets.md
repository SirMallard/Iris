---
sidebar_position: 2
---

# Understanding Widgets

An Iris widget is simply a table (or struct) of data. At its most basic, a widget contains only its
ID, type, tick, events, arguments, zindex, parent widget and gui instance. None of the functionality
of a widget is contained in the widget object. Instead, Iris uses a factory pattern for a widget
class whereby the changes are applied onto any widget passed to the function.

## Creating a Widget Class

To declare or construct a widget we create a 'widget class', that is, the functions which take in a
widget and make changes to it. This widget class is where all the functionality of a a widget is
added and therefore needs to be declared or constucted in advance. The class widget is itself a table
of data and functions but conforming to a specification which includes the necessary functions for
operation.

To create a widget class, use the `WidgetConstructor: (type: string, widgetClass: WidgetClass) -> ()`
function in `Iris.Internal`. This takes two arguments, a type for the widget, such as Text, InputVector2
or SameLine, and a widget class table, containing the functions. This WidgetClass is defined as:
```lua
export type WidgetClass = {
    -- Required
    Generate: (thisWidget: Widget) -> GuiObject,
    Discard: (thisWidget: Widget) -> (),
    Update: (thisWidget: Widget, ...any) -> (),

    Args: { [string]: number },
    Events: Events,
    hasChildren: boolean,
    hasState: boolean,

    -- Generated on construction
    ArgNames: { [number]: string },

    -- Required for widgets with state
    GenerateState: (thisWidget: Widget) -> (),
    UpdateState: (thisWidget: Widget) -> (),

    -- Required for widgets with children
    ChildAdded: (thisWidget: Widget, thisChild: Widget) -> GuiObject,
    -- Optional for widgets with children
    ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}
```

Here, some of the functions are required for all widgets, which define what to do when the widget is
first created, when it is destroyed or discarded because it is no longer called and when any arguments
provided to it are updated. And others are only needed if the widget has state or has children.

## Understanding the Widget Lifecycle

When a widget is called, Iris will try to find the widget from the preivous frame using a VDOM table
and an ID dependent on the line it was called from. If the widget was called for the first time, then
Iris must generate a new widget. It does this by firstly generating the widget structure, being a table
with a few properties. It then generates the UI instances, by calling the `Generate` function of the
widget class. Iris will then use the parent of the widget and call the `ChildAdded` function of the
parent widget class which tells Iris where to parent the UI instances to. At this point, the new widget
looks the same as a pre-existing one.

Iris then checks the arguments provided to determine if they have changed. If they have, then Iris will
call 'Update' from the widget class which handles any UI changes needed. At this point, the widget is
ready, with a functioning UI and can be placed correctly. And that is the end of the call.

At the end of the frame, if Iris finds any widgets which were not called in that frame, it will call
the `Discard` function which is essentially designed to destroy the UI instances.

## Required

Every widget class must have a `Generate`, `Discard` and `Update` function, an `Args` and `Events`
table and `hasChildren` and `hasState` value.

Generally we define whether the widget will have children or have state first since this affects any
other functions needed for the class.

### Args

Args is a string-indexed table where each possible argument for a widget is given an index, which
corresponds to the index when calling the widget. Therefore, we specify every argument, but do not give
a type, or default value.

An example for Window and Button are shown below:
<div style={{"width": "100%", "display": "flex", "flex-direction": "row", "justify-content": "center"}}>
<div style={{"width": "50%"}}>

```lua
-- Button arguments
Args = {
    ["Text"] = 1,
    ["Size"] = 2,
}








```
</div>
<div style={{"width": "50%"}}>

```lua
-- Window arguments
Args = {
    ["Title"] = 1,
    ["NoTitleBar"] = 2,
    ["NoBackground"] = 3,
    ["NoCollapse"] = 4,
    ["NoClose"] = 5,
    ["NoMove"] = 6,
    ["NoScrollbar"] = 7,
    ["NoResize"] = 8,
    ["NoNav"] = 9,
    ["NoMenu"] = 10,
}
```
</div>
</div>

### Events

Events are used to query the current state of a widget. For a button, it might be the whether it has been
clicked. For a checkbox, whether it is active or for a window whether it is open. All of these are 
defined to be custom in Iris and called like regular functions on a widget. To do this, we specify a table
containing all of the possible events.

Each event is a string index for a table conaining to functions: an `Init` function, to setup any
prerequisites; and a `Get` function, which returns the value when the event is called. Because some events
are so common, such as `hovered()` and `clicked()`, Iris provides shorthands for these, making them easier
to add to any widget.

If we look at the example Window widget events, we'll see the two common ways:
```lua
Events = {
    ["closed"] = {
        ["Init"] = function(_thisWidget: Types.Window) end,
        ["Get"] = function(thisWidget: Types.Window)
            return thisWidget.lastClosedTick == Iris._cycleTick
        end,
    },
    ["opened"] = {
        ["Init"] = function(_thisWidget: Types.Window) end,
        ["Get"] = function(thisWidget: Types.Window)
            return thisWidget.lastOpenedTick == Iris._cycleTick
        end,
    },
    ["collapsed"] = {
        ["Init"] = function(_thisWidget: Types.Window) end,
        ["Get"] = function(thisWidget: Types.Window)
            return thisWidget.lastCollapsedTick == Iris._cycleTick
        end,
    },
    ["uncollapsed"] = {
        ["Init"] = function(_thisWidget: Types.Window) end,
        ["Get"] = function(thisWidget: Types.Window)
            return thisWidget.lastUncollapsedTick == Iris._cycleTick
        end,
    },
    ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
        local Window = thisWidget.Instance :: Frame
        return Window.WindowButton
    end),
}
```

The hovered event here used a macro utility, which takes a function that returns the Instance to check for
hovering on. It then sets up the `MouseHover` events for us, and returns the two functions so that th event
is setup correctly. This is the easiest way, since we only need to provide the UI Instance.

The other events are added manually. They each work by checking whether an event has fired on this tick.
Elsewhere in the code for the Window widget, these tick variables are set when an event happens. For example,
in the code which checks for a click on the window collapse button, it will update the tick variable to the
next cycle, ensuring that the event fires when all of the UI changes.

Most of the time, you can the existing examples from other widgets.

### hasChildren

If your widget is going to be a parent and therefore have other widgets placed within or under it, like
a Window, Tree or SameLine widget, this must be true. If not, it must be specified as false.

### hasState

If your widget will take in valuse and possibliy modify them in the widget and return them back, then
the widget will use state objects and therefore must be set to true. Otherwise it must be sepcified as
false.

### Generate

The `Generate` function is called whenever a widget is first called and is responsible for creating the
actual UI instances that make up the window. It handles all of the styling but does not use the
widget arguments (this is hande=led in the `Update` function). Any widget interactivity such as events
for clicks or hovers, which may also change the style, are setup in here. There area few rules which
the generated UI instances follow:
1. The root instance should be named "Iris_[WIDGET_TYPE]".
2. The ZIndex and LayoutOrder of the root element are taken from the ZIndex property of the widget.
3. Returns the root instance.
4. Widgets are generally sized using AutomaticSize or the config over hard-coded numbers, and therefore
    scale better
5. The arguments are never used to modify any instances because if the arguments change then the widget
    should be able to handle the changes on existing UI rather than creating a new design.

The code of a Button best demonstrates this:
```lua
Generate = function(thisWidget: Types.Button)
    -- a TextButton is the best option here because it has the correct events
    local Button: TextButton = Instance.new("TextButton")
    -- we rely on auomatic size
    Button.Size = UDim2.fromOfset(0, 0)
    -- using the config values
    Button.BackgroundColor3 = Iris._config.ButtonColor
    Button.BackgroundTransparency = Iris._config.ButtonTransparency
    Button.AutoButtonColor = false
    Button.AutomaticSize = Enum.AutomaticSize.XY

    -- utility functions exist such as this one which correctly sets the text
    -- style for the widget
    widgets.applyTextStyle(Button)
    Button.TextXAlignment = Enum.TextXAlignment.Center

    -- another utility function which adds any borders or padding dependent
    -- on the config
    widgets.applyFrameStyle(Button)

    -- an utility event which uses clicks and hovers to colour the button
    -- when the mouse interacts with it: normal, hovered and clicked
    widgets.applyInteractionHighlights("Background", Button, Button, {
        Color = Iris._config.ButtonColor,
        Transparency = Iris._config.ButtonTransparency,
        HoveredColor = Iris._config.ButtonHoveredColor,
        HoveredTransparency = Iris._config.ButtonHoveredTransparency,
        ActiveColor = Iris._config.ButtonActiveColor,
        ActiveTransparency = Iris._config.ButtonActiveTransparency,
    })

    -- set the correct layout order and zindex to ensure it stays in the
    -- correct order. Iris relies heavily on UIListLayouts to automatically
    -- position the UI, and therefore relies on the LayoutOrder property.
    Button.ZIndex = thisWidget.ZIndex
    Button.LayoutOrder = thisWidget.ZIndex

    -- we finally return the instance, which is correctly parented and 
    -- Iris sets the widget.instance property to this root element
    return Button
end,
```

### Discard

Discard is called whenever the widget is about to be destroyed because it has not been called this frame.
It hsould remove any instances used by the widget. Most of the time, it is possible to just destroy the
root Instance of the widget, which will close any connections and remove all child instances. If a widget
has any state objects, you will also need to call the `discardState()` function in the widget utility
library, which removes any connected states from the widget, allowing the widget to be correctly cleaned
up. 

### Update

Update is used to alter the widget dependent on the provided arguments. Since the arguments can change
every frame, Iris will call `Update` whenever these arguments change, and when the widget is first
created. Within Generate, all possible instances that are used by the widget are created. `Update` is
used to determine which ones are visible and the style of them.

For example, the Text argument of a widget can be updated dynamically, by simply changing the Text value
for the UI Instance. 

## State

These functions are both required for any widget which has a state.

### GenerateState

GenerateState will create all of the state objects used by that widget, if they are not provided by
the user. It is called only once, when the widget is first created. Creating a new state is not just 
creating the object, but also linking it to the widget, so that when the state changes, it updates the
widget. We can use an example to demonstrate the macro function that Iris provides to make this easier,
as shown in the Checkbox widget:

```lua
GenerateState = function(thisWidget: Types.Checkbox)
    if thisWidget.state.isChecked == nil then
        thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
    end
end
```

We first check whether the state already exists. If it doesn't we can use the `Iris._widgetState()`
function which will construct a new state for this widget with a given name and default value. We can
therefore give the states their default values here. Within `Iris._widgetState()`, we create a new
state object and add this widget to its internal table of all connected widgets, and then return the
new state.

Since `GenerateState` is called only once, we can also use it to connect any widget states together
using the `:onChange()` connection.

### UpdateState

UpdateState is the equivalent to `Update`, but for state. If any state object connected to this widget
is updated, then this will be called, which handles all of the UI changes. This is also called once at
widget creation, to properly design the UI before it is first shown.

:::note
Any changes to UI due to state should be handled here, and not in the code which updates the state.

For example, if you have a click event within `GenerateState`, such as for a checkbox, which changes 
the state, the code within `UpdateState` should change the UI, such as show a tick, rather than handling
it in `GenerateState`.
:::

## Children

These functions are used if a widget has children. Only `ChildAdded` is required.

### ChildAdded

ChildAdded returns the UI instance which the child widget should be parented to. For most functions,
it just returns this Instance. However, it is also possible to validate that the child widget is a certain
type, such as only Menus under a MenuBar. You can also update any UI behaviour which may depend on the
number of children, such as a container height.

### ChildDiscarded

ChildDiscarded is optional, and is only necessary when the removal of a child needs to update the parent
widget in some way, such as changing the size.

## Calling a Widget

We have constructed our widget class, but need to know how to call it. We use the `_Insert` API under
`Iris.Internal`: `_Insert: (widgetType: string, arguments: WidgetArguments?, states: WidgetStates?) -> Widget`.
We provide the widgetType, as specified in the constructor, and then arguments and states.

For example, we can create a Text widget by calling:
```lua
Iris.Internal._Insert("Text", { "Text label" })
```

We create an alias for these functions under `Iris` directly, which is why the user does not call
this function directly.
