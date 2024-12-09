---
sidebar_position: 4
---

# Understanding Events

Each widget has a number of events connected to it. You can see these events on the [API page](/API/Iris).

Certain events will happen once, such as a window being collapsed or a button being clicked. Other events can be
continuous, such as a widget being hovered. Each event is a function which returns a boolean value for whether the
event has happened that frame or not.

To listen to an event, use the following:
```lua
local button = Iris.Button({ "Please click me!" })
if button.clicked() then
    print("The button was clicked!")
end
```

Events will fire the frame after the initial action happened. This is so that any changes caused by that event can
propogate visually. For example on a checkbox:

- [Frames 1 - 60]
The mouse is elsewhere.

- [Frames 61 - 80]
The user is moving their moues towards the checkbox.

- [Frame 81 - 100]
The mouse enters the checkbox.
The .hovered() event fires because this event will fire on the frame.

- [Frame 101]
The user presses MouseButton1 down on the checkbox.

- [Frame 102]
The user releases the MouseButton1.

- [Frame 103]
The checkbox tick appears.
The .checked() event fires.
