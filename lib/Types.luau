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
    .set (self: State<T>, newValue: T, force: boolean?) -> ()
    .onChange (self: State<T>, funcToConnect: (newValue: T) -> ()) -> () -> ()
    .changed (self: State<T>) -> boolean
]=]
export type State<T> = {
    read ID: ID,
    _value: T,
    _lastChangeTick: number,
    read _connectedWidgets: { [ID]: Widget },
    read _connectedFunctions: { (newValue: T) -> () },

    read get: (self: State<T>) -> T,
    read set: (self: State<T>, newValue: T, force: boolean?) -> (),
    read onChange: (self: State<T>, funcToConnect: (newValue: T) -> ()) -> () -> (),
    read changed: (self: State<T>) -> boolean,
}

export type APIState<T> = State<T> | T

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
    read ID: ID,
    read type: string,
    _lastCycleTick: number,
    read _trackedEvents: { [string]: boolean },
    read parentWidget: ParentWidget,

    read arguments: { [string]: any },

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
    read hovered: () -> boolean,
}

export type Clicked = {
    _lastClickedTick: number,
    read clicked: () -> boolean,
}

export type RightClicked = {
    _lastRightClickedTick: number,
    read rightClicked: () -> boolean,
}

export type DoubleClicked = {
    _lastClickedTime: number,
    _lastClickedPosition: Vector2,
    _lastDoubleClickedTick: number,
    read doubleClicked: () -> boolean,
}

export type CtrlClicked = {
    _lastCtrlClickedTick: number,
    read ctrlClicked: () -> boolean,
}

export type Active = {
    read active: () -> boolean,
}

export type Checked = {
    read checked: () -> boolean,
}

export type Unchecked = {
    read unchecked: () -> boolean,
}

export type Opened = {
    read opened: () -> boolean,
}

export type Closed = {
    read closed: () -> boolean,
}

export type Collapsed = {
    read collapsed: () -> boolean,
}

export type Uncollapsed = {
    read uncollapsed: () -> boolean,
}

export type Selected = {
    read selected: () -> boolean,
}

export type Unselected = {
    read unselected: () -> boolean,
}

export type Changed = {
    read changed: () -> boolean,
}

export type Editing = {
    read editing: () -> boolean,
}

export type Event = {
    read Init: (Widget) -> (),
    read Get: (Widget) -> boolean,
}

export type Events = { [string]: Event }

-- Widgets

export type WidgetClass = {
    read numArguments: number,
    read Arguments: { string },
    read Events: Events,

    read Generate: (thisWidget: Widget) -> GuiObject,
    read Discard: (thisWidget: Widget) -> (),
    read Update: (thisWidget: Widget, ...any) -> (),
} & ({
    read hasState: false,
} | {
    read hasState: true,
    read GenerateState: (thisWidget: Widget) -> (),
    read UpdateState: (thisWidget: Widget) -> (),
}) & ({
    read hasChildren: false,
} | {
    read hasChildren: true,
    read ChildAdded: (thisWidget: Widget, thisChild: Widget) -> GuiObject,
    read ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> ()?,
})

return {}
