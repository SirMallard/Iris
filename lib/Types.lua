--!strict

--[=[
    @within Iris
    @type ID string
]=]
export type ID = string

--[=[
    @within State
    @type State<T> { ID: ID, value: T, get: (self) -> T, set: (self, newValue: T) -> T, onChange: (self, callback: (newValue: T) -> ()) -> (), ConnectedWidgets: { [ID]: Widget }, ConnectedFunctions: { (newValue: T) -> () } }
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
    @type Widget { ID: ID, type: string, lastCycleTick: number, parentWidget: Widget, Instance: GuiObject, ZIndex: number, arguments: { [string]: any }}
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
    collapsed: () -> boolean,
}

export type Hidden = {
    _lastHiddenTick: number,
    uncollapsed: () -> boolean,
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

export type NumberChanged = {
    _lastNumberChangedTick: number,
    numberChanged: () -> boolean,
}

export type TextChanged = {
    _lastTextChangedTick: number,
    textChanged: () -> boolean,
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
