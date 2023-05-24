# Creating Custom Widgets

# Overview

Iris comes with the function `Iris.WidgetConstructor`, which allows you to Construct your own widgets. 

For Instance, This is the call to `Iris.WidgetConstructor` for the `Iris.Text` widget:
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

The First argument, `type: string`, specifies a name for the widget


The fourth argument contains the class for the widget. The methods which a widget class may have depend on the value of `hasState` and `hasChildren`.
every widget class should specify if it hasState and hasChildren. In the instance of Iris.Text, It has no state, and it cant contain other widgets, so both are false.

| All Widgets  | Widgets with State | Widgets with Children     |
|--------------|--------------------|---------------------------|
| Generate     | GenerateState      | ChildAdded                |
| Update       | UpdateState        | ChildDiscarded (optional) |
| Discard      |                    |                           |
| Args         |                    |                           |
| Events       |                    |                           |

### Generate
Generate is called when a widget is first instantiated. It should create all the instances and properly adjust them to fit the config properties.
Generate is also called when style properties change.

Generate should return the instance which acts as the root of the widget. (what should be parented to the parents designated Instance)

### Update
Update is called only after instantiation and when widget arguments have changed. 
For instance, in `Iris.Text`
```lua
Update = function(thisWidget)
    local Text = thisWidget.Instance
    if thisWidget.arguments.Text == nil then
        error("Iris.Text Text Argument is required", 5)
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
Events is a table, not a method. It contains all of the possible events which a widget can have. Lets look at the hovered event as an example.
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
`Get` is the actual function which is called by the call to an event (like `Button.hovered()`), it should return the event value.

### Args
Args is a table, not a method. It enumerates all of the possible arguments which may be passed as arguments into the widget.
The order of the tables indicies indicate which position the Argument will be interpreted as. For instance, in `Iris.Text`:
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
GenerateState is called when the widget is first Instantiated, It should generate any state objects which weren't passed as a state by the user.
For Instance, in `Iris.Checkbox`:
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
ChildAdded is called when a widget is first Initiated and is a child of the widget. ChildAdded should return the Instance which the Child will be parented to.

### ChildDiscarded
ChildDiscarded is called when a widget is Discarded and is a child of the widget. ChildDiscarded is optional.

***

## When does a widget need to have state?
State should only be used by widgets when there are properties which are able to be set by BOTH the widget, and by the user's code.

For Instance, `Iris.Window` has a state, `size`. This field can be changed by the user's code, to adjust or initiate the size, and the widget also changes the size when it is resized.

If the window was never able to change the size property, such as if there were no resize feature, then instead it should be an argument.

This table demonstrates the relation between User / Widget permissions, and where the field should belong inside the widget class.
<div align="Left">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/IrisHelpfulChart.png" alt="Sample Display Output"/>
</div>