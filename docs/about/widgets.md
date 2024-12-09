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

The other event style uses our own counters. 

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

## State

## Children

:::danger
END OF PAGE

STOP HERE
:::

# Overview

Iris has a widget constructor method to create widgets with. Once a widget has been constructed, you
can than use it like any other widget. Every widget follows a set of guidelines it must follow when
constructed.

To construct a new widget, you can call `Iris.WidgetConstructor()` with the widget name and widget class.
To then use the widget you can call `Iris.Internal._Insert()` with the widget name and then optional
argument and state tables.

# Documentation

## Widget Construction

For Instance, this is the call to `Iris.WidgetConstructor` for the `Iris.Text` widget:
```lua
Iris.WidgetConstructor("Text", {
    hasState = false,
    hasChildren = false,
    Args = {
        ["Text"] = 1
    },
    Events  {
        ["hovered"] = {
            ...
        }
    }
    Generate = function(thisWidget)
        local Text = Instance.new("TextLabel")
        
        ...

        return Text
    end,
    Update = function(thisWidget)
        ...
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
})
```


The first argument, `type: string`, specifies a name for the widget.


The second argument is the widget class. The methods which a widget class has depends on the value of
`hasState` and `hasChildren`. Every widget class should specify if it `hasState` and `hasChildren`. The
example widget, a text label, has no state, and it does not contain other widgets, so both are false.
Every widget must have the following functions:

| All Widgets | Widgets with State | Widgets with Children     |
| ----------- | ------------------ | ------------------------- |
| Generate    | GenerateState      | ChildAdded                |
| Update      | UpdateState        | ChildDiscarded (optional) |
| Discard     |                    |                           |
| Args        |                    |                           |
| Events      |                    |                           |

### Generate
Generate is called when a widget is first instantiated. It should create all the instances and properly
adjust them to fit the config properties. Generate is also called when style properties change.

Generate should return the instance which acts as the root of the widget. (what should be parented to
the parents designated Instance)

### Update
Update is called only after instantiation and when widget arguments have changed. 
For instance, in `Iris.Text`
```lua
Update = function(thisWidget)
    local Text = thisWidget.Instance
    if thisWidget.arguments.Text == nil then
        error("A text argument is requried for Iris.Text().", 5)
    end
    Text.Text = thisWidget.arguments.Text
end
```

### Discard
Discard is called when the widget stops being displayed. In most cases the function body should resemble this:
```lua
Discard = function(thisWidget)
    thisWidget.Instance:Destroy()
end
```

### Events
Events is a table, not a method. It contains all of the possible events which a widget can have. Lets
look at the hovered event as an example.
```lua
["hovered"] = {
    ["Init"] = function(thisWidget)
        local hoveredGuiObject = thisWidget.Instance
        thisWidget.isHoveredEvent = false

        hoveredGuiObject.MouseEnter:Connect(function()
            thisWidget.isHoveredEvent = true
        end)
        hoveredGuiObject.MouseLeave:Connect(function()
            thisWidget.isHoveredEvent = false
        end)
    end,
    ["Get"] = function(thisWidget)
        return thisWidget.isHoveredEvent
    end
}
```
Every event has 2 methods, `Init` and `Get`. 
`Init` is called when a widget first polls the value of an event.
Because of this, you can instantiate events and variables for an event to only widgets which need it.
`Get` is the actual function which is called by the call to an event (like `Button.hovered()`), it should
return the event value.

### Args
Args is a table, not a method. It enumerates all of the possible arguments which may be passed as arguments
into the widget. The order of the tables indicies indicate which position the Argument will be interpreted
as. For instance, in `Iris.Text`:
```lua
Args = {
    ["Text"] = 1
}
```
when a Text widget is generated, the first index of the Arguments table will be interpreted as the 'Text' parameter
```lua
Iris.Text({[1] = "Hello"})
-- same result
Iris.Text({"Hello"})
```
the `Update` function can retrieve arguments from `thisWidget.arguments`, such as `thisWidget.arguments.Text`

### GenerateState
GenerateState is called when the widget is first Instantiated, It should generate any state objects which
weren't passed as a state by the user. For instance, in `Iris.Checkbox`:
```lua
GenerateState = function(thisWidget)
    if thisWidget.state.isChecked == nil then
        thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
    end
end
```

### UpdateState
UpdateState is called whenever ANY state objects are updated, using its :set() method.
For instance, in `Iris.Checkbox`:
```lua
UpdateState = function(thisWidget)
    local Checkbox = thisWidget.Instance.CheckboxBox
    if thisWidget.state.isChecked.value then
        Checkbox.Text = ICONS.CHECK_MARK
        thisWidget.events.checked = true
    else
        Checkbox.Text = ""
        thisWidget.events.unchecked = true
    end
end
```
:::caution
calling :set() to any of a widget's own state objects inside of UpdateState may cause an infinite loop of state updates.
UpdateState should avoid calling :set().
:::

### ChildAdded
ChildAdded is called when a widget is first Initiated and is a child of the widget. ChildAdded should return the
Instance which the Child will be parented to.

### ChildDiscarded
ChildDiscarded is called when a widget is Discarded and is a child of the widget. ChildDiscarded is optional.

## Widget Usage

To use this widget once it has been constructed, you can use:
```lua
Iris.Internal._Insert("Text", {"Sampele text"}, nil) -- "Text" argument and no state
```
This is the same as calling any other widget but requires the widget name as passed to `Iris.WidgetConstructor()` as the first argument.

***

## When does a widget need to have state?
State should only be used by widgets when there are properties which are able to be set by BOTH the widget, and by the user's code.

For Instance, `Iris.Window` has a state, `size`. This field can be changed by the user's code, to adjust or initiate the size, and the widget also changes the size when it is resized.

If the window was never able to change the size property, such as if there were no resize feature, then instead it should be an argument.

This table demonstrates the relation between User / Widget permissions, and where the field should belong inside the widget class.
<div align="Left">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/IrisHelpfulChart.png" alt="Sample Display Output"/>
</div>
