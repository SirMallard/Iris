export type ID = string

export type State = {
    value: any,
    ConnectedWidgets: { [ID]:  Widget },
    ConnectedFunctions: { (any) -> () },

    get: (self: State) -> any,
    set: (self: State, newValue: any) -> (),
    onChange: (self: State, funcToConnect: (any) -> ()) -> (),
}
export type States = { [string]: State }

export type Event = {
    Init: (Widget) -> (),
    Get: (Widget) -> (boolean)
}
export type Events = { [string]: Event }

export type Widget = {
    ID: ID,
    type: string,
    state: States,

    parentWidget: Widget,
    Instance: GuiObject,
    arguments: Arguments,

    ZIndex: number,

    trackedEvents: {},
    lastCycleTick: number,

    isHoveredEvent: boolean,
    lastClickedTick: number,
    lastRightClickedTick: number,
    lastClickedTime: number,
    lastClickedPosition: Vector2,
    lastDoubleClickedTick: number,
    lastCtrlClickedTick: number,
    lastCheckedTick: number,
    lastUncheckedTick: number,
}

export type Argument = any
export type Arguments = { [string]: Argument }
export type WidgetArguments = { [number]: Argument }

export type WidgetClass = {
    Generate: (thisWidget: Widget) -> (GuiObject),
    Discard: (thisWidget: Widget) -> (),
    Update: (thisWidget: Widget) -> (),

    Args: { [string]: number },
    Events: Events,
    hasChildren: boolean,
    hasState: boolean,
    ArgNames: { [number]: string },

    GenerateState: (thisWidget: Widget) -> (),
    UpdateState: (thisWidget: Widget) -> (),

    ChildAdded: (thisWidget: Widget) -> (GuiObject),
    ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}

export type WidgetUtility = {
    GuiService: GuiService,
    UserInputService: UserInputService,

    ICONS: {
        RIGHT_POINTING_TRIANGLE: string,
        DOWN_POINTING_TRIANGLE: string,
        MULTIPLICATION_SIGN: string,
        BOTTOM_RIGHT_CORNER: string,
        CHECK_MARK: string
    },

    findBestWindowPosForPopup: (refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2) -> Vector2,
    isPosInsideRect: (pos: Vector2, rectMin: Vector2, rectMax: Vector2) -> boolean,
    extend: (superClass: WidgetClass, subClass: WidgetClass) -> WidgetClass,
    discardState: (thisWidget: Widget) -> (),

    UIPadding: (Parent: GuiObject, PxPadding: Vector2) -> UIPadding,
    UIListLayout: (Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim) -> UIListLayout,
    UIStroke: (Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number) -> UIStroke,
    UICorner: (Parent: GuiObject, PxRounding: number) -> UICorner,
    UISizeConstraint: (Parent: GuiObject, MinSize: Vector2, MaxSize: Vector2) -> UISizeConstraint,

    applyTextStyle: (thisInstance: TextLabel | TextButton | TextBox) -> (),
    applyInteractionHighlights: (Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any }) -> (),
    applyInteractionHighlightsWithMultiHighlightee: (Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number} } }) -> (),
    applyTextInteractionHighlights: (Button: GuiButton, Highlightee: TextLabel | TextButton | TextBox, Colors: { [string]: any }) -> (),
    applyFrameStyle: (thisInstance: GuiObject, forceNoPadding: boolean?, doubleyNoPadding: boolean?) -> (),

    EVENTS: {
        hover: (pathToHovered: (thisWidget: Widget) -> GuiObject) -> Event,
        click: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        rightClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        doubleClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
        ctrlClick: (pathToClicked: (thisWidget: Widget) -> GuiButton) -> Event,
    },

    abstractButton: WidgetClass
}

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

    _generateSelectionImageObject: () -> (),
    _generateRootInstance: () -> (),
    _deepCompare: ( t1: {}, t2: {} ) -> boolean,
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
    ComputedState: (firstState: State, onChangeCallback: (firstState: any) -> (any)) -> State,
    _widgetState: (thisWidget: Widget, stateName: string, initialValue: any) -> State,

    Init: (parentInstance: BasePlayerGui?, eventConnection: (RBXScriptConnection | () -> {})?) -> Iris,
    Connect: (self: Iris, callback: () -> ()) -> (),

    _DiscardWidget: (widgetToDiscard: Widget) -> (),
    _GenNewWidget: (widgetType: string, arguments: Arguments, widgetState: States?, ID: ID) -> Widget,
    _Inset: (widgetType: string, args: { [number]: any }, widgetState: States?) -> Widget,
    _ContinueWidget: (ID: ID, widgetType: string) -> Widget,
    Append: (userInstance: GuiObject) -> (),

    End: () -> (),
    Text: (args: WidgetArguments) -> Widget,
    TextColored: (args: WidgetArguments) -> Widget,
    TextWrapped: (args: WidgetArguments) -> Widget,

    Button: (args: WidgetArguments) -> Widget,
    SmallButton: (args: WidgetArguments) -> Widget,
    Checkbox: (args: WidgetArguments, state: States?) -> Widget,
    RadioButton: (args: WidgetArguments, state: States?) -> Widget,

    Separator: (args: WidgetArguments) -> Widget,
    Indent: (args: WidgetArguments) -> Widget,
    SameLine: (args: WidgetArguments) -> Widget,
    Group: (args: WidgetArguments) -> Widget,
    Selectable: (args: WidgetArguments, state: States?) -> Widget,

    Tree: (args: WidgetArguments, state: States?) -> Widget,
    CollapsingHeader: (args: WidgetArguments, state: States?) -> Widget,
    
    DragNum: (args: WidgetArguments, state: States?) -> Widget,
    SliderNum: (args: WidgetArguments, state: States?) -> Widget,
    InputNum: (args: WidgetArguments, state: States?) -> Widget,
    InputText: (args: WidgetArguments, state: States?) -> Widget,
    InputEnum: (args: WidgetArguments, state: States?, enumType: Enum) -> Widget,
    Combo: (args: WidgetArguments, state: States?) -> Widget,
    ComboArray: (args: WidgetArguments, state: States?, selectionArray: {any} ) -> Widget,
    
    Table: (args: WidgetArguments, state: States?) -> Widget,
    NextColumn: () -> (),
    SetColumnIndex: (columnIndex: number) -> (),
    NextRow: () -> (),
    
    Window: (args: WidgetArguments, state: States?) -> Widget,
    Tooltip: (args: WidgetArguments) -> Widget,
    SetFocusedWindow: (thisWidget: Widget?) -> ()
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

    UseScreenGUIs: boolean,
    Parent: BasePlayerGui,
    DisplayOrderOffset: number,
    ZIndexOffset: number,

    MouseDoubleClickTime: number,
    MouseDoubleClickMaxDist: number,
    MouseDragThreshold: number
}

return {}