export type ID = string

export type State = {
    value: any,
    ConnectedWidgets: { [ID]: Widget },
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

export type Widget = {
    ID: ID,
    type: string,
    state: States,

    parentWidget: Widget,
    Instance: GuiObject,
    ChildContainer: GuiObject,
    arguments: Arguments,

    ZIndex: number,

    trackedEvents: {},
    lastCycleTick: number,
    LabelHeight: number,

    isHoveredEvent: boolean,
    lastClickedTick: number,
    lastRightClickedTick: number,
    lastClickedTime: number,
    lastClickedPosition: Vector2,
    lastShortcutTick: number,
    lastDoubleClickedTick: number,
    lastCtrlClickedTick: number,
    lastCheckedTick: number,
    lastUncheckedTick: number,
    lastNumberChangedTick: number,

    clicked: () -> boolean,
    closed: () -> boolean,
    opened: () -> boolean,
    collapsed: () -> boolean,
    uncollapsed: () -> boolean,
    hovered: () -> boolean,
}

export type InputDataType = number | Vector2 | Vector3 | UDim | UDim2 | Color3 | { number }
export type InputDataTypes = "Num" | "Vector2" | "Vector3" | "UDim" | "UDim2" | "Color3" | "Color4" | "Enum"

export type Argument = any
export type Arguments = {
    [string]: Argument,
    Text: string,
    TextHint: string,

    Increment: InputDataType,
    Min: InputDataType,
    Max: InputDataType,
    Format: { string },
    UseFloats: boolean,
    UseHSV: boolean,
    UseHex: boolean,

    Color: Color3,
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
}
export type WidgetArguments = { [number]: Argument }

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

    ChildAdded: (thisWidget: Widget) -> GuiObject,
    ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}

export type WidgetUtility = {
    GuiService: GuiService,
    RunService: RunService,
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
    },

    GuiInset: Vector2,

    findBestWindowPosForPopup: (refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2) -> Vector2,
    isPosInsideRect: (pos: Vector2, rectMin: Vector2, rectMax: Vector2) -> boolean,
    extend: (superClass: WidgetClass, { [any]: any }) -> WidgetClass,
    discardState: (thisWidget: Widget) -> (),

    UIPadding: (Parent: GuiObject, PxPadding: Vector2) -> UIPadding,
    UIListLayout: (Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim) -> UIListLayout,
    UIStroke: (Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number) -> UIStroke,
    UICorner: (Parent: GuiObject, PxRounding: number) -> UICorner,
    UISizeConstraint: (Parent: GuiObject, MinSize: Vector2?, MaxSize: Vector2?) -> UISizeConstraint,

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
    },

    abstractButton: WidgetClass,
}

export type WidgetAPI = (args: WidgetArguments?, state: States?) -> Widget

export type Iris = {
    _started: boolean,
    _globalRefreshRequested: boolean,
    _localRefreshActive: boolean,
    _widgets: { [string]: WidgetClass },
    _rootConfig: Config,
    _config: Config,
    _rootInstance: GuiObject,
    _rootWidget: Widget,
    _states: { [ID]: State },
    _postCycleCallbacks: {},
    _connectedFunctions: {},
    _IDStack: { State },
    _usedIDs: { [ID]: number },
    _stackIndex: number,
    _cycleTick: number,
    _widgetCount: number,
    _lastWidget: Widget,
    _nextWidgetId: ID,
    SelectionImageObject: Frame,
    parentInstance: BasePlayerGui,

    _lastVDOM: { [ID]: Widget },
    _VDOM: { [ID]: Widget },

    Args: {},

    Disabled: boolean,

    _generateSelectionImageObject: () -> (),
    _generateRootInstance: () -> (),
    _deepCompare: (t1: {}, t2: {}) -> boolean,
    _getID: (levelsToIgnore: number) -> ID,
    PushId: (Input: string | number) -> (),
    PopId: () -> (),
    SetNextWidgetID: (ID: ID) -> (),
    _generateEmptyVDOM: () -> { [ID]: Widget },
    _cycle: () -> (),
    _GetParentWidget: () -> Widget,
    _EventCall: (thisWidget: Widget, eventName: string) -> boolean,
    ForceRefresh: () -> (),
    _NoOp: () -> (),
    WidgetConstructor: (type: string, widgetClass: WidgetClass) -> (),

    UpdateGlobalConfig: (deltaStyle: { [any]: any }) -> (),
    PushConfig: (deltaStyle: { [any]: any }) -> (),
    PopConfig: () -> (),

    State: (initialValue: any) -> (),
    ComputedState: (firstState: State, onChangeCallback: (firstState: any) -> any) -> State,
    _widgetState: (thisWidget: Widget, stateName: string, initialValue: any) -> State,

    Init: (parentInstance: BasePlayerGui?, eventConnection: (RBXScriptConnection | () -> {})?) -> Iris,
    Connect: (self: Iris, callback: () -> ()) -> (),

    _DiscardWidget: (widgetToDiscard: Widget) -> (),
    _GenNewWidget: (widgetType: string, arguments: Arguments, widgetState: States?, ID: ID) -> Widget,
    _Insert: (widgetType: string, args: { [number]: any }, widgetState: States?) -> Widget,
    _ContinueWidget: (ID: ID, widgetType: string) -> Widget,
    Append: (userInstance: GuiObject) -> (),

    MenuBar: WidgetAPI,
    Menu: WidgetAPI,

    End: () -> (),
    Text: WidgetAPI,
    TextColored: WidgetAPI,
    TextWrapped: WidgetAPI,
    SeparatorText: WidgetAPI,

    Button: WidgetAPI,
    SmallButton: WidgetAPI,
    Checkbox: WidgetAPI,
    RadioButton: WidgetAPI,

    Separator: WidgetAPI,
    Indent: WidgetAPI,
    SameLine: WidgetAPI,
    Group: WidgetAPI,
    Selectable: WidgetAPI,

    Tree: WidgetAPI,
    CollapsingHeader: WidgetAPI,

    InputNum: WidgetAPI,
    InputVector2: WidgetAPI,
    InputVector3: WidgetAPI,
    InputUDim: WidgetAPI,
    InputUDim2: WidgetAPI,
    InputColor3: WidgetAPI,
    InputColo4: WidgetAPI,

    DragNum: WidgetAPI,
    DragVector2: WidgetAPI,
    DragVector3: WidgetAPI,
    DragUDim: WidgetAPI,
    DragUDim2: WidgetAPI,

    SliderNum: WidgetAPI,
    SliderVector2: WidgetAPI,
    SliderVector3: WidgetAPI,
    SliderUDim: WidgetAPI,
    SliderUDim2: WidgetAPI,
    SliderEnum: WidgetAPI,

    InputText: WidgetAPI,
    InputEnum: (args: WidgetArguments, state: States?, enumType: Enum) -> Widget,
    Combo: WidgetAPI,
    ComboArray: (args: WidgetArguments, state: States?, selectionArray: { any }) -> Widget,

    Table: WidgetAPI,
    NextColumn: () -> (),
    SetColumnIndex: (columnIndex: number) -> (),
    NextRow: () -> (),

    Window: WidgetAPI,
    Tooltip: WidgetAPI,
    SetFocusedWindow: (thisWidget: Widget?) -> (),
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
