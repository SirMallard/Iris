export type ID = string

export type Argument = any
export type Arguments = {
    [string]: Argument,
    Text: string,
    TextHint: string,
    Wrapped: boolean,
    Color: Color3,
    RichText: boolean,

    Increment: InputDataType,
    Min: InputDataType,
    Max: InputDataType,
    Format: { string },
    UseFloats: boolean,
    UseHSV: boolean,
    UseHex: boolean,
    Prefix: { string },

    Width: number,
    VerticalAlignment: Enum.VerticalAlignment,
    Index: any,

    SpanAvailWidth: boolean,
    NoIdent: boolean,
    NoClick: boolean,
    NoButtons: boolean,
    NoButton: boolean,
    NoPreview: boolean,

    NumColumns: number,
    RowBg: boolean,
    BordersOuter: boolean,
    BordersInner: boolean,

    Title: string,
    NoTitleBar: boolean,
    NoBackground: boolean,
    NoCollapse: boolean,
    NoClose: boolean,
    NoMove: boolean,
    NoScrollbar: boolean,
    NoResize: boolean,
    NoMenu: boolean,

    KeyCode: Enum.KeyCode,
    ModifierKey: Enum.ModifierKey,
    Disabled: boolean,
}

export type State = {
    value: any,
    ConnectedWidgets: { [ID]: string },
    ConnectedFunctions: { (any) -> () },

    get: (self: State) -> any,
    set: (self: State, newValue: any) -> (),
    onChange: (self: State, funcToConnect: (any) -> ()) -> (),
}

export type States = {
    [string]: State,
    number: State,
    color: State,
    transparency: State,
    editingText: State,
    index: State,

    size: State,
    position: State,
    scrollDistance: State,

    isChecked: State,
    isOpened: State,
    isUncollapsed: State,
}

export type Event = {
    Init: (Widget) -> (),
    Get: (Widget) -> boolean,
}
export type Events = { [string]: Event }

type EventAPI = () -> boolean

export type InputDataType = number | Vector2 | Vector3 | UDim | UDim2 | Color3 | Rect | { number }
export type InputDataTypes = "Num" | "Vector2" | "Vector3" | "UDim" | "UDim2" | "Color3" | "Color4" | "Rect" | "Enum" | "" | string

export type WidgetArguments = { [number]: Argument }
export type WidgetStates = { [string]: State }

export type Widget = {
    ID: ID,
    type: string,
    state: States,
    lastCycleTick: number,
    trackedEvents: {},

    parentWidget: Widget,
    Instance: GuiObject,
    ChildContainer: GuiObject,
    arguments: Arguments,
    providedArguments: Arguments,
    ZIndex: number,

    usesScreenGUI: boolean,
    ButtonColors: { [string]: Color3 | number },
    ComboChildrenHeight: number,

    -- Table properties
    RowColumnIndex: number,
    InitialNumColumns: number,
    ColumnInstances: { Frame },
    CellInstances: { Frame },

    -- Event Props
    isHoveredEvent: boolean,

    lastClickedTick: number,
    lastClickedTime: number,
    lastClickedPosition: Vector2,

    lastRightClickedTick: number,
    lastDoubleClickedTick: number,
    lastCtrlClickedTick: number,

    lastCheckedTick: number,
    lastUncheckedTick: number,
    lastOpenedTick: number,
    lastClosedTick: number,
    lastSelectedTick: number,
    lastUnselectedTick: number,
    lastCollapsedTick: number,
    lastUncollapsedTick: number,

    lastNumberChangedTick: number,
    lastTextchangeTick: number,
    lastShortcutTick: number,

    -- Events
    hovered: EventAPI,
    clicked: EventAPI,
    rightClicked: EventAPI,
    ctrlClicked: EventAPI,
    doubleClicked: EventAPI,

    checked: EventAPI,
    unchecked: EventAPI,
    activated: EventAPI,
    deactivated: EventAPI,
    collapsed: EventAPI,
    uncollapsed: EventAPI,
    selected: EventAPI,
    unselected: EventAPI,
    opened: EventAPI,
    closed: EventAPI,

    active: EventAPI,

    numberChanged: EventAPI,
    textChanged: EventAPI,

    [string]: EventAPI & State,
}

export type WidgetClass = {
    Generate: (thisWidget: Widget) -> GuiObject,
    Discard: (thisWidget: Widget) -> (),
    Update: (thisWidget: Widget, ...any) -> (),

    Args: { [string]: number },
    Events: Events,
    hasChildren: boolean,
    hasState: boolean,
    ArgNames: { [number]: string },

    GenerateState: (thisWidget: Widget) -> (),
    UpdateState: (thisWidget: Widget) -> (),

    ChildAdded: (thisWidget: Widget, thisChild: Widget) -> GuiObject,
    ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}

export type WidgetUtility = {
    GuiService: GuiService,
    RunService: RunService,
    TextService: TextService,
    UserInputService: UserInputService,
    ContextActionService: ContextActionService,

    getTime: () -> number,
    getMouseLocation: () -> Vector2,

    ICONS: {
        RIGHT_POINTING_TRIANGLE: string,
        DOWN_POINTING_TRIANGLE: string,
        MULTIPLICATION_SIGN: string,
        BOTTOM_RIGHT_CORNER: string,
        CHECK_MARK: string,
        ALPHA_BACKGROUND_TEXTURE: string,
    },

    GuiInset: Vector2,

    findBestWindowPosForPopup: (refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2) -> Vector2,
    isPosInsideRect: (pos: Vector2, rectMin: Vector2, rectMax: Vector2) -> boolean,
    extend: (superClass: WidgetClass, { [any]: any }) -> WidgetClass,
    discardState: (thisWidget: Widget) -> (),

    UIPadding: (Parent: GuiObject, PxPadding: Vector2) -> UIPadding,
    UIListLayout: (Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim) -> UIListLayout,
    UIStroke: (Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number) -> UIStroke,
    UICorner: (Parent: GuiObject, PxRounding: number?) -> UICorner,
    UISizeConstraint: (Parent: GuiObject, MinSize: Vector2?, MaxSize: Vector2?) -> UISizeConstraint,
    UIReference: (Parent: GuiObject, Child: GuiObject, Name: string) -> ObjectValue,

    calculateTextSize: (text: string, width: number?) -> Vector2,
    applyTextStyle: (thisInstance: TextLabel | TextButton | TextBox) -> (),
    applyInteractionHighlights: (Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any }) -> (),
    applyInteractionHighlightsWithMultiHighlightee: (Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number } } }) -> (),
    applyTextInteractionHighlights: (Button: GuiButton, Highlightee: TextLabel | TextButton | TextBox, Colors: { [string]: any }) -> (),
    applyFrameStyle: (thisInstance: GuiObject, forceNoPadding: boolean?, doubleyNoPadding: boolean?) -> (),

    EVENTS: {
        hover: (pathToHovered: (thisWidget: Widget) -> GuiObject) -> Event,
        click: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        rightClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        doubleClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        ctrlClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        shortcut: (pathToKeys: (thisWidget: Widget) -> (Enum.KeyCode, Enum.ModifierKey)) -> Event,
    },

    abstractButton: WidgetClass,
}

export type Internal = {
    --[[
        --------------
          PROPERTIES
        --------------
    ]]
    _started: boolean,
    _cycleTick: number,

    -- Refresh
    _globalRefreshRequested: boolean,
    _localRefreshActive: boolean,

    -- Widgets & Instances
    _widgets: { [string]: WidgetClass },
    _widgetCount: number,
    _stackIndex: number,
    _rootInstance: GuiObject?,
    _rootWidget: Widget,
    _lastWidget: Widget,
    SelectionImageObject: Frame,
    parentInstance: BasePlayerGui,

    -- Config
    _rootConfig: Config,
    _config: Config,

    -- ID
    _IDStack: { State },
    _usedIDs: { [ID]: number },
    _pushedId: ID?,
    _nextWidgetId: ID?,

    -- VDOM
    _lastVDOM: { [ID]: Widget },
    _VDOM: { [ID]: Widget },

    -- State
    _states: { [ID]: State },

    -- Callback
    _postCycleCallbacks: {},
    _connectedFunctions: {},
    _cycleCoroutine: thread?,

    --[[
        ---------
          STATE
        ---------
    ]]

    StateClass: {
        __index: any,

        get: (self: State) -> any,
        set: (self: State, newValue: any) -> any,
        onChange: (self: State, callback: (newValue: any) -> ()) -> (),
    },

    --[[
        -------------
          FUNCTIONS
        -------------
    ]]
    _cycle: () -> (),
    _NoOp: () -> (),

    -- Widget
    WidgetConstructor: (type: string, widgetClass: WidgetClass) -> (),
    _Insert: (widgetType: string, arguments: WidgetArguments?, states: States?) -> Widget,
    _GenNewWidget: (widgetType: string, arguments: Arguments, states: States?, ID: ID) -> Widget,
    _ContinueWidget: (ID: ID, widgetType: string) -> Widget,
    _DiscardWidget: (widgetToDiscard: Widget) -> (),

    _widgetState: (thisWidget: Widget, stateName: string, initialValue: any) -> State,
    _EventCall: (thisWidget: Widget, eventName: string) -> boolean,
    _GetParentWidget: () -> Widget,
    SetFocusedWindow: (thisWidget: Widget?) -> (),

    -- Generate
    _generateEmptyVDOM: () -> { [ID]: Widget },
    _generateRootInstance: () -> (),
    _generateSelectionImageObject: () -> (),

    -- Utility
    _getID: (levelsToIgnore: number) -> ID,
    _deepCompare: (t1: {}, t2: {}) -> boolean,
    _deepCopy: (t: {}) -> {},
}

export type Iris = {
    --[[
        -----------
          WIDGETS
        -----------
    ]]

    End: () -> (),

    -- Window API
    Window: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    Tooltip: (arguments: WidgetArguments) -> Widget,

    -- Menu Widget API
    MenuBar: () -> Widget,
    Menu: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    MenuItem: (arguments: WidgetArguments) -> Widget,
    MenuToggle: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Format Widget API
    Separator: () -> Widget,
    Indent: (arguments: WidgetArguments?) -> Widget,
    SameLine: (arguments: WidgetArguments?) -> Widget,
    Group: () -> Widget,

    -- Text Widget API
    Text: (arguments: WidgetArguments) -> Widget,
    TextWrapped: (arguments: WidgetArguments) -> Widget,
    TextColored: (arguments: WidgetArguments) -> Widget,
    SeparatorText: (arguments: WidgetArguments) -> Widget,
    InputText: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Basic Widget API
    Button: (arguments: WidgetArguments) -> Widget,
    SmallButton: (arguments: WidgetArguments) -> Widget,
    Checkbox: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    RadioButton: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Tree Widget API
    Tree: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    CollapsingHeader: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Input Widget API
    InputNum: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputVector2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputVector3: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputUDim: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputUDim2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputRect: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputColor3: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    InputColor4: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Drag Widget API
    DragNum: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    DragVector2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    DragVector3: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    DragUDim: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    DragUDim2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    DragRect: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Slider Widget API
    SliderNum: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderVector2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderVector3: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderUDim: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderUDim2: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderRect: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    SliderEnum: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    -- Combo Widget Widget API
    Selectable: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    Combo: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,
    ComboArray: (arguments: WidgetArguments, states: WidgetStates?, selectionArray: { any }) -> Widget,
    ComboEnum: (arguments: WidgetArguments, states: WidgetStates?, enumType: Enum) -> Widget,
    InputEnum: (arguments: WidgetArguments, states: WidgetStates?, enumType: Enum) -> Widget,

    -- Table Widget Api
    Table: (arguments: WidgetArguments) -> Widget,
    NextColumn: () -> (),
    SetColumnIndex: (columnIndex: number) -> (),
    NextRow: () -> (),

    --[[
        ---------
          STATE
        ---------
    ]]

    State: (initialValue: any) -> State,
    WeakState: (initialValue: any) -> State,
    ComputedState: (firstState: State, onChangeCallback: (firstState: any) -> any) -> State,

    --[[
        -------------
          FUNCTIONS
        -------------
    ]]

    Init: (playerInstance: BasePlayerGui?, eventConnection: (RBXScriptConnection | () -> ())?) -> Iris,
    Connect: (callback: () -> ()) -> (),
    Append: (userInstance: GuiObject) -> (),
    ForceRefresh: () -> (),

    -- Widget
    SetFocusedWindow: (thisWidget: Widget?) -> (),

    -- ID API
    PushId: (id: ID) -> (),
    PopId: (id: ID) -> (),
    SetNextWidgetID: (id: ID) -> (),

    -- Config API
    UpdateGlobalConfig: (deltaStyle: { [string]: any }) -> (),
    PushConfig: (deltaStyle: { [string]: any }) -> (),
    PopConfig: () -> (),

    --[[
        --------------
          PROPERTIES
        --------------
    ]]

    Internal: Internal,
    Disabled: boolean,
    Args: { [string]: { [string]: number } },
    Events: { [string]: () -> boolean },

    TemplateConfig: { [string]: Config },
    _config: Config,
    ShowDemoWindow: () -> (),
}

export type Config = {
    TextColor: Color3,
    TextTransparency: number,
    TextDisabledColor: Color3,
    TextDisabledTransparency: number,

    BorderColor: Color3,
    BorderActiveColor: Color3,
    BorderTransparency: number,
    BorderActiveTransparency: number,

    WindowBgColor: Color3,
    WindowBgTransparency: number,
    ScrollbarGrabColor: Color3,
    ScrollbarGrabTransparency: number,

    TitleBgColor: Color3,
    TitleBgTransparency: number,
    TitleBgActiveColor: Color3,
    TitleBgActiveTransparency: number,
    TitleBgCollapsedColor: Color3,
    TitleBgCollapsedTransparency: number,

    MenubarBgColor: Color3,
    MenubarBgTransparency: number,

    FrameBgColor: Color3,
    FrameBgTransparency: number,
    FrameBgHoveredColor: Color3,
    FrameBgHoveredTransparency: number,
    FrameBgActiveColor: Color3,
    FrameBgActiveTransparency: number,

    ButtonColor: Color3,
    ButtonTransparency: number,
    ButtonHoveredColor: Color3,
    ButtonHoveredTransparency: number,
    ButtonActiveColor: Color3,
    ButtonActiveTransparency: number,

    SliderGrabColor: Color3,
    SliderGrabTransparency: number,
    SliderGrabActiveColor: Color3,
    SliderGrabActiveTransparency: number,

    HeaderColor: Color3,
    HeaderTransparency: number,
    HeaderHoveredColor: Color3,
    HeaderHoveredTransparency: number,
    HeaderActiveColor: Color3,
    HeaderActiveTransparency: number,

    SelectionImageObjectColor: Color3,
    SelectionImageObjectTransparency: number,
    SelectionImageObjectBorderColor: Color3,
    SelectionImageObjectBorderTransparency: number,

    TableBorderStrongColor: Color3,
    TableBorderStrongTransparency: number,
    TableBorderLightColor: Color3,
    TableBorderLightTransparency: number,
    TableRowBgColor: Color3,
    TableRowBgTransparency: number,
    TableRowBgAltColor: Color3,
    TableRowBgAltTransparency: number,

    NavWindowingHighlightColor: Color3,
    NavWindowingHighlightTransparency: number,
    NavWindowingDimBgColor: Color3,
    NavWindowingDimBgTransparency: number,

    SeparatorColor: Color3,
    SeparatorTransparency: number,

    CheckMarkColor: Color3,
    CheckMarkTransparency: number,

    HoverColor: Color3,
    HoverTransparency: number,

    -- Sizes
    ItemWidth: UDim,
    ContentWidth: UDim,

    WindowPadding: Vector2,
    WindowResizePadding: Vector2,
    FramePadding: Vector2,
    ItemSpacing: Vector2,
    ItemInnerSpacing: Vector2,
    CellPadding: Vector2,
    DisplaySafeAreaPadding: Vector2,
    IndentSpacing: number,
    SeparatorTextPadding: Vector2,

    TextFont: Font,
    TextSize: number,
    FrameBorderSize: number,
    FrameRounding: number,
    GrabRounding: number,
    WindowBorderSize: number,
    WindowTitleAlign: Enum.LeftRight,
    PopupBorderSize: number,
    PopupRounding: number,
    ScrollbarSize: number,
    GrabMinSize: number,
    SeparatorTextBorderSize: number,

    UseScreenGUIs: boolean,
    IgnoreGuiInset: boolean,
    Parent: BasePlayerGui,
    DisplayOrderOffset: number,
    ZIndexOffset: number,

    MouseDoubleClickTime: number,
    MouseDoubleClickMaxDist: number,
    MouseDragThreshold: number,
}

return {}
