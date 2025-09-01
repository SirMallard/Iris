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
    isHoveredEvent: boolean,
    hovered: () -> boolean,
}

export type Clicked = {
    lastClickedTick: number,
    clicked: () -> boolean,
}

export type RightClicked = {
    lastRightClickedTick: number,
    rightClicked: () -> boolean,
}

export type DoubleClicked = {
    lastClickedTime: number,
    lastClickedPosition: Vector2,
    lastDoubleClickedTick: number,
    doubleClicked: () -> boolean,
}

export type CtrlClicked = {
    lastCtrlClickedTick: number,
    ctrlClicked: () -> boolean,
}

export type Active = {
    active: () -> boolean,
}

export type Checked = {
    lastCheckedTick: number,
    checked: () -> boolean,
}

export type Unchecked = {
    lastUncheckedTick: number,
    unchecked: () -> boolean,
}

export type Opened = {
    lastOpenedTick: number,
    opened: () -> boolean,
}

export type Closed = {
    lastClosedTick: number,
    closed: () -> boolean,
}

export type Collapsed = {
    lastCollapsedTick: number,
    collapsed: () -> boolean,
}

export type Uncollapsed = {
    lastUncollapsedTick: number,
    uncollapsed: () -> boolean,
}

export type Selected = {
    lastSelectedTick: number,
    selected: () -> boolean,
}

export type Unselected = {
    lastUnselectedTick: number,
    unselected: () -> boolean,
}

export type Changed = {
    lastChangedTick: number,
    changed: () -> boolean,
}

export type NumberChanged = {
    lastNumberChangedTick: number,
    numberChanged: () -> boolean,
}

export type TextChanged = {
    lastTextChangedTick: number,
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
    numStates: number,
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

-- Iris

-- export type Internal = {
--     --[[
--         --------------
--           PROPERTIES
--         --------------
--     ]]
--     _version: string,
--     _started: boolean,
--     _paused: boolean,
--     _shutdown: boolean,

--     _cycleTick: number,
--     _deltaTime: number,
--     _eventConnection: RBXScriptConnection?,

--     -- Refresh
--     _globalRefreshRequested: boolean,
--     _refreshCounter: number,
--     _refreshLevel: number,
--     _refreshStack: { boolean },

--     -- Widgets & Instances
--     _widgets: { [string]: WidgetClass },
--     _rootInstance: GuiObject?,
--     _rootWidget: ParentWidget,
--     _lastWidget: Widget,

--     _selectionImageObject: Frame,
--     _parentInstance: BasePlayerGui | GuiBase2d,
--     _utility: WidgetUtility,
--     _fullErrorTracebacks: boolean,

--     _arguments: { [string]: { string } },
--     _events: { [string]: () -> () },

--     -- Config
--     _rootConfig: Config,
--     _config: Config,

--     -- ID
--     _IDStack: { ID },
--     _usedIDs: { [ID]: number },
--     _newID: boolean,
--     _pushedIds: { ID },
--     _nextWidgetId: ID?,
--     _stackIndex: number,

--     -- VDOM
--     _lastVDOM: { [ID]: Widget },
--     _VDOM: { [ID]: Widget },

--     -- State
--     _states: { [ID]: State<any> },

--     -- Callback
--     _postCycleCallbacks: { () -> () },
--     _connectedFunctions: { () -> () },
--     _connections: { RBXScriptConnection },
--     _initFunctions: { () -> () },
--     _cycleCoroutine: thread,

--     --[[
--         -------------
--           FUNCTIONS
--         -------------
--     ]]
--     _cycle: (deltaTime: number) -> (),
--     _noOp: () -> (),

--     -- Widget
--     _widgetConstructor: (type: string, widgetClass: WidgetClass) -> (),
--     _insert: (widgetType: string, ...any) -> Widget,
--     _genNewWidget: (widgetType: string, ID: ID, ...any) -> Widget,
--     _continueWidget: (ID: ID, widgetType: string) -> Widget,
--     _discardWidget: (widget: Widget) -> (),

--     _widgetState: <T>(thisWidget: StateWidget, stateName: string, initialValue: T) -> State<T>,
--     _eventCall: (thisWidget: Widget, eventName: string) -> boolean,
--     _getParentWidget: () -> ParentWidget,

--     -- Generate
--     _generateEmptyVDOM: () -> { [ID]: Widget },
--     _generateRootInstance: () -> (),
--     _generateSelectionImageObject: () -> (),

--     -- Utility
--     _getID: (levelsToIgnore: number) -> ID,
-- }

-- export type WidgetUtility = {
--     GuiService: GuiService,
--     RunService: RunService,
--     TextService: TextService,
--     UserInputService: UserInputService,
--     ContextActionService: ContextActionService,

--     getTime: () -> number,
--     getMouseLocation: () -> Vector2,

--     ICONS: {
--         BLANK_SQUARE: string,
--         RIGHT_POINTING_TRIANGLE: string,
--         DOWN_POINTING_TRIANGLE: string,
--         MULTIPLICATION_SIGN: string,
--         BOTTOM_RIGHT_CORNER: string,
--         CHECK_MARK: string,
--         BORDER: string,
--         ALPHA_BACKGROUND_TEXTURE: string,
--         UNKNOWN_TEXTURE: string,
--     },

--     guiOffset: Vector2,
--     mouseOffset: Vector2,

--     isPosInsideRect: (pos: Vector2, rectMin: Vector2, rectMax: Vector2) -> boolean,
--     findBestWindowPosForPopup: (refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2) -> Vector2,
--     getScreenSizeForWindow: (thisWidget: Widget) -> Vector2,
--     extend: (superClass: WidgetClass, { [any]: any }) -> WidgetClass,
--     discardState: (thisWidget: Widget) -> (),

--     UIPadding: (Parent: GuiObject, PxPadding: Vector2) -> UIPadding,
--     UIListLayout: (Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim) -> UIListLayout,
--     UIStroke: (Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number) -> UIStroke,
--     UICorner: (Parent: GuiObject, PxRounding: number?) -> UICorner,
--     UISizeConstraint: (Parent: GuiObject, MinSize: Vector2?, MaxSize: Vector2?) -> UISizeConstraint,

--     applyTextStyle: (thisInstance: TextLabel | TextButton | TextBox) -> (),
--     applyInteractionHighlights: (Property: string, Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any }) -> (),
--     applyInteractionHighlightsWithMultiHighlightee: (Property: string, Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number } } }) -> (),
--     applyFrameStyle: (thisInstance: GuiObject, noPadding: boolean?, noCorner: boolean?) -> (),

--     applyButtonClick: (thisInstance: GuiButton, callback: () -> ()) -> (),
--     applyButtonDown: (thisInstance: GuiButton, callback: (x: number, y: number) -> ()) -> (),
--     applyMouseEnter: (thisInstance: GuiObject, callback: (x: number, y: number) -> ()) -> (),
--     applyMouseMoved: (thisInstance: GuiObject, callback: (x: number, y: number) -> ()) -> (),
--     applyMouseLeave: (thisInstance: GuiObject, callback: (x: number, y: number) -> ()) -> (),
--     applyInputBegan: (thisInstance: GuiObject, callback: (input: InputObject) -> ()) -> (),
--     applyInputEnded: (thisInstance: GuiObject, callback: (input: InputObject) -> ()) -> (),

--     registerEvent: (event: string, callback: (...any) -> ()) -> (),

--     EVENTS: {
--         hover: (pathToHovered: (thisWidget: Widget & Hovered) -> GuiObject) -> Event,
--         click: (pathToClicked: (thisWidget: Widget & Clicked) -> GuiButton) -> Event,
--         rightClick: (pathToClicked: (thisWidget: Widget & RightClicked) -> GuiButton) -> Event,
--         doubleClick: (pathToClicked: (thisWidget: Widget & DoubleClicked) -> GuiButton) -> Event,
--         ctrlClick: (pathToClicked: (thisWidget: Widget & CtrlClicked) -> GuiButton) -> Event,
--     },

--     abstractButton: WidgetClass,
-- }

-- export type Iris = {
--     --[[
--         -----------
--           WIDGETS
--         -----------
--     ]]

--     End: () -> (),

--     -- Window API
--     Window: () -> Window,
--     Tooltip: () -> Tooltip,

--     -- Menu Widget API
--     MenuBar: () -> Widget,
--     Menu: () -> Menu,
--     MenuItem: () -> MenuItem,
--     MenuToggle: () -> MenuToggle,

--     -- Format Widget API
--     Separator: () -> Separator,
--     Indent: (arguments: WidgetArguments?) -> Indent,
--     SameLine: (arguments: WidgetArguments?) -> SameLine,
--     Group: () -> Group,

--     -- Text Widget API
--     Text: () -> Text,
--     TextWrapped: () -> Text,
--     TextColored: () -> Text,
--     SeparatorText: () -> SeparatorText,
--     InputText: () -> InputText,

--     -- Basic Widget API
--     Button: () -> Button,
--     SmallButton: () -> Button,
--     Checkbox: () -> Checkbox,
--     RadioButton: () -> RadioButton,

--     -- Tree Widget API
--     Tree: () -> Tree,
--     CollapsingHeader: () -> CollapsingHeader,

--     -- Tab Widget API
--     TabBar: () -> TabBar,
--     Tab: () -> Tab,

--     -- Input Widget API
--     InputNum: () -> Input,
--     InputVector2: () -> Input,
--     InputVector3: () -> Input,
--     InputUDim: () -> Input,
--     InputUDim2: () -> Input,
--     InputRect: () -> Input,
--     InputColor3: () -> InputColor3,
--     InputColor4: () -> InputColor4,

--     -- Drag Widget API
--     DragNum: () -> Input,
--     DragVector2: () -> Input,
--     DragVector3: () -> Input,
--     DragUDim: () -> Input,
--     DragUDim2: () -> Input,
--     DragRect: () -> Input,

--     -- Slider Widget API
--     SliderNum: () -> Input,
--     SliderVector2: () -> Input,
--     SliderVector3: () -> Input,
--     SliderUDim: () -> Input,
--     SliderUDim2: () -> Input,
--     SliderRect: () -> Input,

--     -- Combo Widget Widget API
--     Selectable: () -> Selectable,
--     Combo: () -> Combo,
--     ComboArray: () -> Combo,
--     ComboEnum: () -> Combo,
--     InputEnum: () -> Combo,

--     ProgressBar: () -> ProgressBar,
--     PlotLines: () -> PlotLines,
--     PlotHistogram: () -> PlotHistogram,

--     Image: () -> Image,
--     ImageButton: () -> ImageButton,

--     -- Table Widget Api
--     Table: () -> Table,
--     NextColumn: () -> number,
--     NextRow: () -> number,
--     SetColumnIndex: (index: number) -> (),
--     SetRowIndex: (index: number) -> (),
--     NextHeaderColumn: () -> number,
--     SetHeaderColumnIndex: (index: number) -> (),
--     SetColumnWidth: (index: number, width: number) -> (),

--     --[[
--         ---------
--           STATE
--         ---------
--     ]]

--     State: <T>(initialValue: T) -> State<T>,
--     WeakState: <T>(initialValue: T) -> T,
--     VariableState: <T>(variable: T, callback: (T) -> ()) -> State<T>,
--     TableState: <K, V>(tab: { [K]: V }, key: K, callback: ((newValue: V) -> true?)?) -> State<V>,
--     ComputedState: <T, U>(firstState: State<T>, onChangeCallback: (firstValue: T) -> U) -> State<U>,

--     --[[
--         -------------
--           FUNCTIONS
--         -------------
--     ]]

--     Init: (parentInstance: BasePlayerGui | GuiBase2d?, eventConnection: (RBXScriptSignal | (() -> number) | false)?, allowMultipleInits: boolean) -> Iris,
--     Shutdown: () -> (),
--     Connect: (self: Iris, callback: () -> ()) -> () -> (),
--     Append: (userInstance: GuiObject) -> (),
--     ForceRefresh: () -> (),

--     -- ID API
--     PushId: (ID: ID) -> (),
--     PopId: () -> (),
--     SetNextWidgetID: (ID: ID) -> (),

--     -- Config API
--     UpdateGlobalConfig: (deltaStyle: { [string]: any }) -> (),
--     PushConfig: (deltaStyle: { [string]: any }) -> (),
--     PopConfig: () -> (),

--     --[[
--         --------------
--           PROPERTIES
--         --------------
--     ]]

--     _internal: Internal,
--     Disabled: boolean,
--     Arguments: { [string]: { [string]: number } },
--     Events: { [string]: () -> boolean },

--     TemplateConfig: { [string]: Config },
--     _config: Config,
--     ShowDemoWindow: () -> Window,
-- }

--[[

    --[[
        ---------
          STATE
        ---------
    ]-]

    StateClass: {
        __index: any,

        get: <T>(self: State<T>) -> any,
        set: <T>(self: State<T>, newValue: any) -> any,
        onChange: <T>(self: State<T>, callback: (newValue: any) -> ()) -> (),
    },

]]

return {}
