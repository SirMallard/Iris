--!strict

--[=[
    @within Iris
    @type ID string
]=]
export type ID = string

--[=[
    @within State
    @interface State<T>
    .ID ID,
    ._value T
    ._lastChangeTick number
    ._connectedWidgets { [ID]: Widget }
    ._connectedFunctions { (newValue: T) -> () }

    .get (self: State<T>) -> T
    .set (self: State<T>, newValue: T, force: true?) -> ()
    .onChange (self: State<T>, funcToConnect: (newValue: T) -> ()) -> () -> ()
    .changed (self: State<T>) -> boolean
]=]
export type State<T> = {
    ID: ID,
    _value: T,
    _lastChangeTick: number,
    _connectedWidgets: { [ID]: Widget },
    _connectedFunctions: { (newValue: T) -> () },

    get: (self: State<T>) -> T,
    set: (self: State<T>, newValue: T, force: true?) -> (),
    onChange: (self: State<T>, funcToConnect: (newValue: T) -> ()) -> () -> (),
    changed: (self: State<T>) -> boolean,
}

--[=[
    @within Iris
    @interface Widget
    .ID ID -- unique widget ID
    .type string -- type of widget
    ._lastCycleTick number
    ._trackedEvents {}
    .parentWidget ParentWidget -- the current parent, only root has no parent

    .arguments { [string]: any } -- all arguments that affect the widget

    .instance GuiObject -- Roblox instance
    .zindex number
]=]
export type Widget = {
    ID: ID,
    type: string,
    _lastCycleTick: number,
    _trackedEvents: {},
    parentWidget: ParentWidget,

    arguments: { [string]: any },

    instance: GuiObject,
    zindex: number,

    __index: (self: Widget, index: any) -> (),
}

--[=[
    @within Iris
    @interface ParentWidget
    .& Widget
    .childContainer GuiObject -- Instance which all children are placed into
    .zoffset number
    .zupdate boolean
]=]
export type ParentWidget = Widget & {
    childContainer: GuiObject,
    zoffset: number,
    zupdate: boolean,
}

export type StateWidget = Widget & {
    state: {
        [string]: State<any>,
    },
}

-- Events

export type Hovered = {
    _isHoveredEvent: boolean,
    hovered: () -> boolean,
}

export type Clicked = {
    _lastClickedTick: number,
    clicked: () -> boolean,
}

export type RightClicked = {
    _lastRightClickedTick: number,
    rightClicked: () -> boolean,
}

export type DoubleClicked = {
    _lastClickedTime: number,
    _lastClickedPosition: Vector2,
    _lastDoubleClickedTick: number,
    doubleClicked: () -> boolean,
}

export type CtrlClicked = {
    _lastCtrlClickedTick: number,
    ctrlClicked: () -> boolean,
}

export type Active = {
    active: () -> boolean,
}

export type Checked = {
    _lastCheckedTick: number,
    checked: () -> boolean,
}

export type Unchecked = {
    _lastUncheckedTick: number,
    unchecked: () -> boolean,
}

export type Opened = {
    _lastOpenedTick: number,
    opened: () -> boolean,
}

export type Closed = {
    _lastClosedTick: number,
    closed: () -> boolean,
}

export type Shown = {
    _lastShownTick: number,
    shown: () -> boolean,
}

export type Hidden = {
    _lastHiddenTick: number,
    hidden: () -> boolean,
}

export type Selected = {
    _lastSelectedTick: number,
    selected: () -> boolean,
}

export type Unselected = {
    _lastUnselectedTick: number,
    unselected: () -> boolean,
}

export type Changed = {
    _lastChangedTick: number,
    changed: () -> boolean,
}

export type Event = {
    Init: (Widget) -> (),
    Get: (Widget) -> boolean,
}

export type Events = { [string]: Event }

-- Widgets

export type WidgetClass = {
    hasState: boolean,
    hasChildren: boolean,
    numArguments: number,
    Arguments: { string },
    Events: Events,

    Generate: (thisWidget: Widget) -> GuiObject,
    Discard: (thisWidget: Widget) -> (),
    Update: (thisWidget: Widget, ...any) -> (),

    GenerateState: (thisWidget: Widget) -> (),
    UpdateState: (thisWidget: Widget) -> (),

    ChildAdded: (thisWidget: Widget, thisChild: Widget) -> GuiObject,
    ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}

return {}
