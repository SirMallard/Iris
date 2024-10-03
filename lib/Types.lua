local WidgetTypes = require(script.Parent.WidgetTypes)

export type ID = WidgetTypes.ID
export type State<T> = WidgetTypes.State<T>

export type Hovered = WidgetTypes.Hovered
export type Clicked = WidgetTypes.Clicked
export type RightClicked = WidgetTypes.RightClicked
export type DoubleClicked = WidgetTypes.DoubleClicked
export type CtrlClicked = WidgetTypes.CtrlClicked
export type Active = WidgetTypes.Active
export type Checked = WidgetTypes.Checked
export type Unchecked = WidgetTypes.Unchecked
export type Opened = WidgetTypes.Opened
export type Closed = WidgetTypes.Closed
export type Collapsed = WidgetTypes.Collapsed
export type Uncollapsed = WidgetTypes.Uncollapsed
export type Selected = WidgetTypes.Selected
export type Unselected = WidgetTypes.Unselected
export type Changed = WidgetTypes.Changed
export type NumberChanged = WidgetTypes.NumberChanged
export type TextChanged = WidgetTypes.TextChanged

export type Widget = WidgetTypes.Widget
export type ParentWidget = WidgetTypes.ParentWidget
export type StateWidget = WidgetTypes.StateWidget

export type Root = WidgetTypes.Root
export type Window = WidgetTypes.Window
export type Tooltip = WidgetTypes.Tooltip
export type MenuBar = WidgetTypes.MenuBar
export type Menu = WidgetTypes.Menu
export type MenuItem = WidgetTypes.MenuItem
export type MenuToggle = WidgetTypes.MenuToggle
export type Separator = WidgetTypes.Separator
export type Indent = WidgetTypes.Indent
export type SameLine = WidgetTypes.SameLine
export type Group = WidgetTypes.Group
export type Text = WidgetTypes.Text
export type SeparatorText = WidgetTypes.SeparatorText
export type Button = WidgetTypes.Button
export type Checkbox = WidgetTypes.Checkbox
export type RadioButton = WidgetTypes.RadioButton
export type Image = WidgetTypes.Image
export type ImageButton = WidgetTypes.ImageButton
export type Tree = WidgetTypes.Tree
export type CollapsingHeader = WidgetTypes.CollapsingHeader
export type Input<T> = WidgetTypes.Input<T>
export type InputColor3 = WidgetTypes.InputColor3
export type InputColor4 = WidgetTypes.InputColor4
export type InputEnum = WidgetTypes.InputEnum
export type InputText = WidgetTypes.InputText
export type Selectable = WidgetTypes.Selectable
export type Combo = WidgetTypes.Combo
export type ProgressBar = WidgetTypes.ProgressBar
export type Table = WidgetTypes.Table

export type InputDataType = number | Vector2 | Vector3 | UDim | UDim2 | Color3 | Rect | { number }

export type Argument = any
export type Arguments = {
    [string]: Argument,
    Text: string,
    TextHint: string,
    ReadOnly: boolean,
    MultiLine: boolean,
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
    HorizontalAlignment: Enum.HorizontalAlignment,
    Index: any,
    Image: string,
    Size: UDim2,
    Rect: Rect,
    ScaleType: Enum.ScaleType,
    TileSize: UDim2,
    SliceCenter: Rect,
    SliceScale: number,
    ResampleMode: Enum.ResamplerMode,

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

export type States = {
    [string]: State<any>,
    number: State<number>,
    color: State<Color3>,
    transparency: State<number>,
    editingText: State<boolean>,
    index: State<any>,

    size: State<Vector2>,
    position: State<Vector2>,
    progress: State<number>,
    scrollDistance: State<number>,

    isChecked: State<boolean>,
    isOpened: State<boolean>,
    isUncollapsed: State<boolean>,
}

export type Event = {
    Init: (Widget) -> (),
    Get: (Widget) -> boolean,
}
export type Events = { [string]: Event }

-- Widgets

export type WidgetArguments = { [number]: Argument }
export type WidgetStates = {
    [string]: State<any>,
    number: State<number>?,
    color: State<Color3>?,
    transparency: State<number>?,
    editingText: State<boolean>?,
    index: State<any>?,

    size: State<Vector2>?,
    position: State<Vector2>?,
    progress: State<number>?,
    scrollDistance: State<number>?,

    isChecked: State<boolean>?,
    isOpened: State<boolean>?,
    isUncollapsed: State<boolean>?,
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

-- Iris

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

    -- Tab Bar API
    TabBar: () -> Widget,
    Tab: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

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

    ProgressBar: (arguments: WidgetArguments, states: WidgetStates?) -> Widget,

    Image: (arguments: WidgetArguments) -> Widget,
    ImageButton: (arguments: WidgetArguments) -> Widget,

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
    Shutdown: () -> (),
    Connect: (self: Iris, callback: () -> ()) -> () -> (),
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
    ShowDemoWindow: () -> Widget,
}

export type Internal = {
    --[[
        --------------
          PROPERTIES
        --------------
    ]]
    _version: string,
    _started: boolean,
    _shutdown: boolean,
    _cycleTick: number,
    _eventConnection: RBXScriptConnection?,

    -- Refresh
    _globalRefreshRequested: boolean,
    _localRefreshActive: boolean,

    -- Widgets & Instances
    _widgets: { [string]: WidgetClass },
    _widgetCount: number,
    _stackIndex: number,
    _rootInstance: GuiObject?,
    _rootWidget: ParentWidget,
    _lastWidget: Widget,
    SelectionImageObject: Frame,
    parentInstance: Instance,
    _utility: WidgetUtility,

    -- Config
    _rootConfig: Config,
    _config: Config,

    -- ID
    _IDStack: { ID },
    _usedIDs: { [ID]: number },
    _pushedId: ID?,
    _nextWidgetId: ID?,

    -- VDOM
    _lastVDOM: { [ID]: Widget },
    _VDOM: { [ID]: Widget },

    -- State
    _states: { [ID]: State<any> },

    -- Callback
    _postCycleCallbacks: { () -> () },
    _connectedFunctions: { () -> () },
    _connections: { RBXScriptConnection },
    _initFunctions: { () -> () },
    _cycleCoroutine: thread?,

    --[[
        ---------
          STATE
        ---------
    ]]

    StateClass: {
        __index: any,

        get: <T>(self: State<T>) -> any,
        set: <T>(self: State<T>, newValue: any) -> any,
        onChange: <T>(self: State<T>, callback: (newValue: any) -> ()) -> (),
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
    _Insert: (widgetType: string, arguments: WidgetArguments?, states: WidgetStates?) -> Widget,
    _GenNewWidget: (widgetType: string, arguments: Arguments, states: WidgetStates?, ID: ID) -> Widget,
    _ContinueWidget: (ID: ID, widgetType: string) -> Widget,
    _DiscardWidget: (widgetToDiscard: Widget) -> (),

    _widgetState: (thisWidget: Widget, stateName: string, initialValue: any) -> State<any>,
    _EventCall: (thisWidget: Widget, eventName: string) -> boolean,
    _GetParentWidget: () -> ParentWidget,
    SetFocusedWindow: (thisWidget: WidgetTypes.Window?) -> (),

    -- Generate
    _generateEmptyVDOM: () -> { [ID]: Widget },
    _generateRootInstance: () -> (),
    _generateSelectionImageObject: () -> (),

    -- Utility
    _getID: (levelsToIgnore: number) -> ID,
    _deepCompare: (t1: {}, t2: {}) -> boolean,
    _deepCopy: (t: {}) -> {},
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
        UNKNOWN_TEXTURE: string,
    },

    GuiOffset: Vector2,
    MouseOffset: Vector2,

    findBestWindowPosForPopup: (refPos: Vector2, size: Vector2, outerMin: Vector2, outerMax: Vector2) -> Vector2,
    getScreenSizeForWindow: (thisWidget: Widget) -> Vector2,
    isPosInsideRect: (pos: Vector2, rectMin: Vector2, rectMax: Vector2) -> boolean,
    extend: (superClass: WidgetClass, { [any]: any }) -> WidgetClass,
    discardState: (thisWidget: Widget) -> (),

    UIPadding: (Parent: GuiObject, PxPadding: Vector2) -> UIPadding,
    UIListLayout: (Parent: GuiObject, FillDirection: Enum.FillDirection, Padding: UDim) -> UIListLayout,
    UIStroke: (Parent: GuiObject, Thickness: number, Color: Color3, Transparency: number) -> UIStroke,
    UICorner: (Parent: GuiObject, PxRounding: number?) -> UICorner,
    UISizeConstraint: (Parent: GuiObject, MinSize: Vector2?, MaxSize: Vector2?) -> UISizeConstraint,

    applyTextStyle: (thisInstance: TextLabel | TextButton | TextBox) -> (),
    applyInteractionHighlights: (Property: string, Button: GuiButton, Highlightee: GuiObject, Colors: { [string]: any }) -> (),
    applyInteractionHighlightsWithMultiHighlightee: (Property: string, Button: GuiButton, Highlightees: { { GuiObject | { [string]: Color3 | number } } }) -> (),
    applyFrameStyle: (thisInstance: GuiObject, noPadding: boolean?, noCorner: boolean?) -> (),

    applyButtonClick: (thisInstance: GuiButton, callback: () -> ()) -> (),
    applyButtonDown: (thisInstance: GuiButton, callback: (x: number, y: number) -> ()) -> (),
    applyMouseEnter: (thisInstance: GuiObject, callback: () -> ()) -> (),
    applyMouseLeave: (thisInstance: GuiObject, callback: () -> ()) -> (),
    applyInputBegan: (thisInstance: GuiObject, callback: (input: InputObject) -> ()) -> (),
    applyInputEnded: (thisInstance: GuiObject, callback: (input: InputObject) -> ()) -> (),

    registerEvent: (event: string, callback: (...any) -> ()) -> (),

    EVENTS: {
        hover: (pathToHovered: (thisWidget: Widget & Hovered) -> GuiObject) -> Event,
        click: (pathToClicked: (thisWidget: Widget & Clicked) -> GuiButton) -> Event,
        rightClick: (pathToClicked: (thisWidget: Widget & RightClicked) -> GuiButton) -> Event,
        doubleClick: (pathToClicked: (thisWidget: Widget & DoubleClicked) -> GuiButton) -> Event,
        ctrlClick: (pathToClicked: (thisWidget: Widget & CtrlClicked) -> GuiButton) -> Event,
    },

    abstractButton: WidgetClass,
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
    PopupBgColor: Color3,
    PopupBgTransparency: number,

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

    ImageColor: Color3,
    ImageTransparency: number,

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

    TabColor: Color3,
    TabTransparency: number,
    TabHoveredColor: Color3,
    TabHoveredTransparency: number,
    TabActiveColor: Color3,
    TabActiveTransparency: number,

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

    PlotHistogramColor: Color3,
    PlotHistogramTransparency: number,
    PlotHistogramHoveredColor: Color3,
    PlotHistogramHoveredTransparency: number,

    HoverColor: Color3,
    HoverTransparency: number,

    -- Sizes
    ItemWidth: UDim,
    ContentWidth: UDim,
    ContentHeight: UDim,

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
    ImageBorderSize: number,

    UseScreenGUIs: boolean,
    IgnoreGuiInset: boolean,
    Parent: BasePlayerGui,
    RichText: boolean,
    TextWrapped: boolean,
    DisplayOrderOffset: number,
    ZIndexOffset: number,

    MouseDoubleClickTime: number,
    MouseDoubleClickMaxDist: number,
    MouseDragThreshold: number,
}

return {}
