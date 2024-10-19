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
    value: T,
    ConnectedWidgets: { [ID]: Widget },
    ConnectedFunctions: { (newValue: T) -> () },

    get: (self: State<T>) -> T,
    set: (self: State<T>, newValue: T) -> (),
    onChange: (self: State<T>, funcToConnect: (newValue: T) -> ()) -> () -> (),
}

--[=[
    @within Iris
    @type Widget { ID: ID, type: string, lastCycleTick: number, parentWidget: Widget, Instance: GuiObject, ZIndex: number, arguments: { [string]: any }}
]=]
export type Widget = {
    ID: ID,
    type: string,
    lastCycleTick: number,
    trackedEvents: {},
    parentWidget: ParentWidget,

    arguments: {},
    providedArguments: {},

    Instance: GuiObject,
    ZIndex: number,
}

export type ParentWidget = Widget & {
    ChildContainer: GuiObject,
    ZOffset: number,
    ZUpdate: boolean,
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

-- Widgets

-- Window

export type Root = ParentWidget

export type Window = ParentWidget & {
    usesScreenGuis: boolean,

    arguments: {
        Title: string?,
        NoTitleBar: boolean?,
        NoBackground: boolean?,
        NoCollapse: boolean?,
        NoClose: boolean?,
        NoMove: boolean?,
        NoScrollbar: boolean?,
        NoResize: boolean?,
        NoNav: boolean?,
        NoMenu: boolean?,
    },

    state: {
        size: State<Vector2>,
        position: State<Vector2>,
        isUncollapsed: State<boolean>,
        isOpened: State<boolean>,
        scrollDistance: State<number>,
    },
} & Opened & Closed & Collapsed & Uncollapsed & Hovered

export type Tooltip = Widget & {
    arguments: {
        Text: string,
    },
}

-- Menu

export type MenuBar = ParentWidget

export type Menu = ParentWidget & {
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string?,
    },

    state: {
        isOpened: State<boolean>,
    },
} & Clicked & Opened & Closed & Hovered

export type MenuItem = Widget & {
    arguments: {
        Text: string,
        KeyCode: Enum.KeyCode?,
        ModifierKey: Enum.ModifierKey?,
    },
} & Clicked & Hovered

export type MenuToggle = Widget & {
    arguments: {
        Text: string,
        KeyCode: Enum.KeyCode?,
        ModifierKey: Enum.ModifierKey?,
    },

    state: {
        isChecked: State<boolean>,
    },
} & Checked & Unchecked & Hovered

-- Format

export type Separator = Widget

export type Indent = ParentWidget & {
    arguments: {
        Width: number?,
    },
}

export type SameLine = ParentWidget & {
    arguments: {
        Width: number?,
        VerticalAlignment: Enum.VerticalAlignment?,
        HorizontalAlignment: Enum.HorizontalAlignment?,
    },
}

export type Group = ParentWidget

-- Text

export type Text = Widget & {
    arguments: {
        Text: string,
        Wrapped: boolean?,
        Color: Color3?,
        RichText: boolean?,
    },
} & Hovered

export type SeparatorText = Widget & {
    arguments: {
        Text: string,
    },
} & Hovered

-- Basic

export type Button = Widget & {
    arguments: {
        Text: string?,
        Size: UDim2?,
    },
} & Clicked & RightClicked & DoubleClicked & CtrlClicked & Hovered

export type Checkbox = Widget & {
    arguments: {
        Text: string?,
    },

    state: {
        isChecked: State<boolean>,
    },
} & Unchecked & Checked & Hovered

export type RadioButton = Widget & {
    arguments: {
        Text: string?,
        Index: any,
    },

    state: {
        index: State<any>,
    },

    active: () -> boolean,
} & Selected & Unselected & Active & Hovered

-- Image

export type Image = Widget & {
    arguments: {
        Image: string,
        Size: UDim2,
        Rect: Rect?,
        ScaleType: Enum.ScaleType?,
        TileSize: UDim2?,
        SliceCenter: Rect?,
        SliceScale: number?,
        ResampleMode: Enum.ResamplerMode?,
    },
} & Hovered

export type ImageButton = Image & Clicked & RightClicked & DoubleClicked & CtrlClicked

-- Tree

export type Tree = CollapsingHeader & {
    arguments: {
        SpanAvailWidth: boolean?,
        NoIndent: boolean?,
    },
}

export type CollapsingHeader = ParentWidget & {
    arguments: {
        Text: string?,
    },

    state: {
        isUncollapsed: State<boolean>,
    },
} & Collapsed & Uncollapsed & Hovered

-- Tabs

export type TabBar = ParentWidget & {
    Tabs: { Tab },

    state: {
        index: State<number>,
    },
}

export type Tab = ParentWidget & {
    parentWidget: TabBar,
    Index: number,
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string,
        Hideable: boolean,
    },

    state: {
        index: State<number>,
        isOpened: State<boolean>,
    },
} & Clicked & Opened & Selected & Unselected & Active & Closed & Hovered

-- Input
export type Input<T> = Widget & {
    lastClickedTime: number,
    lastClickedPosition: Vector2,

    arguments: {
        Text: string?,
        Increment: T,
        Min: T,
        Max: T,
        Format: { string },
        Prefix: { string },
        NoButtons: boolean?,
    },

    state: {
        number: State<T>,
        editingText: State<number>,
    },
} & NumberChanged & Hovered

export type InputColor3 = Input<{ number }> & {
    arguments: {
        UseFloats: boolean?,
        UseHSV: boolean?,
    },

    state: {
        color: State<Color3>,
        editingText: State<boolean>,
    },
} & NumberChanged & Hovered

export type InputColor4 = InputColor3 & {
    state: {
        transparency: State<number>,
    },
}

export type InputEnum = Input<number> & {
    state: {
        enumItem: State<EnumItem>,
    },
}

export type InputText = Widget & {
    arguments: {
        Text: string?,
        TextHint: string?,
        ReadOnly: boolean?,
        MultiLine: boolean?,
    },

    state: {
        text: State<string>,
    },
} & TextChanged & Hovered

-- Combo

export type Selectable = Widget & {
    ButtonColors: { [string]: Color3 | number },

    arguments: {
        Text: string?,
        Index: any?,
        NoClick: boolean?,
    },

    state: {
        index: State<any>,
    },
} & Selected & Unselected & Clicked & RightClicked & DoubleClicked & CtrlClicked & Hovered

export type Combo = ParentWidget & {
    ComboChildrenHeight: number,

    arguments: {
        Text: string?,
        NoButton: boolean?,
        NoPreview: boolean?,
    },

    state: {
        index: State<any>,
        isOpened: State<boolean>,
    },
} & Opened & Closed & Clicked & Hovered

-- Plot

export type ProgressBar = Widget & {
    arguments: {
        Text: string?,
        Format: string?,
    },

    state: {
        progress: State<number>,
    },
} & Changed & Hovered

export type Table = ParentWidget & {
    RowColumnIndex: number,
    InitialNumColumns: number,
    ColumnInstances: { Frame },
    CellInstances: { Frame },

    arguments: {
        NumColumns: number,
        RowBg: boolean?,
        BordersOuter: boolean?,
        BordersInner: boolean?,
    },
} & Hovered

return {}
