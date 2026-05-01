# Window Iris.Window   
    hasChildren = true
    hasState = true
## Arguments
    Title: string
    Flags: WindowFlags?,
## Events
    opened: () -> boolean
    closed: () -> boolean
    collapsed: () -> boolean
    uncollapsed: () -> boolean
    hovered: () -> boolean
## States
    size: State<Vector2>? = Vector2.new(400, 300)
    position: State<Vector2>?
    open: State<boolean>? = true
    collapsed: State<boolean>? = false
    scrollDistance: State<number>?


# Tooltip Iris.Tooltip
    hasChildren = false
    hasState = false
## Arguments
    Text: string


# MenuBar Iris.MenuBar
    hasChildren = true
    hasState = false


# Menu Iris.Menu
    hasChildren = true
    hasState = true
## Arguments
    Label: string
## Events
    clicked: () -> boolean
    opened: () -> boolean
    closed: () -> boolean
    hovered: () -> boolean
## States
    open: State<boolean>?


# MenuItem Iris.MenuItem
    hasChildren = false
    hasState = false
## Arguments
    Label: string
    KeyCode: Enum.KeyCode? = nil
    ModifierKey: Enum.ModifierKey? = nil
## Events
    clicked: () -> boolean
    hovered: () -> boolean


# MenuToggle Iris.MenuToggle
    hasChildren = false
    hasState = true
## Arguments
    Label: string
    KeyCode: Enum.KeyCode? = nil
    ModifierKey: Enum.ModifierKey? = nil
## Events
    checked: () -> boolean
    unchecked: () -> boolean
    hovered: () -> boolean
## States
    value: State<boolean>?


# Separator Iris.Separator
    hasChildren = false
    hasState = false


# Indent Iris.Indent
    hasChildren = true
    hasState = false
## Arguments
    Width: number? = Iris._config.IndentSpacing
    

# SameLine Iris.SameLine
    hasChildren = true
    hasState = false
## Arguments
    Width: number? = Iris._config.ItemSpacing.X
    VerticalAlignment: Enum.VerticalAlignment? = Enum.VerticalAlignment.Center
    HorizontalAlignment: Enum.HorizontalAlignment? = Enum.HorizontalAlignment.Center
    

# Group Iris.Group
    hasChildren = true
    hasState = false


# Text Iris.Text
    hasChildren = false
    hasState = false
## Arguments
    Text: string
    Wrapped: boolean? = [CONFIG] = false
    Color: Color3? = Iris._config.TextColor
    RichText: boolean? = [CONFIG] = false
## Events
    hovered: () -> boolean


# SeparatorText Iris.SeparatorText
    hasChildren = false
    hasState = false
## Arguments
    Text: string
    

# InputText Iris.InputText
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "InputText"
    TextHint: string? = ""
    ReadOnly: boolean? = false
    MultiLine: boolean? = false
## Events
    textChanged: () -> boolean
    hovered: () -> boolean
## States
    text: State<string>?
    

# Button Iris.Button, SmallButton Iris.SmallButton
    hasChildren = false
    hasState = false
## Arguments
    Label: string
    Size: UDim2? = UDim2.fromOffset(0, 0)
## Events
    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean
    

# Checkbox Iris.Checkbox
    hasChildren = false
    hasState = true
## Arguments
    Label: string
## Events
    checked: () -> boolean
    unchecked: () -> boolean
    hovered: () -> boolean
## States
    value = State<boolean>?
    

# RadioButton Iris.RadioButton
    hasChildren = false
    hasState = true
## Arguments
    Label: string
    Value: any
## Events
    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    hovered: () -> boolean
## States
    index = State<any>?
    

# Image Iris.Image
    hasChildren = false
    hasState = false
## Arguments
    Image: string
    Size: UDim2
    Rect: Rect? = Rect.new()
    ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch
    ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default
    TileSize: UDim2? = UDim2.fromScale(1, 1)
    SliceCenter: Rect? = Rect.new()
    SliceScale: number? = 1
## Events
    hovered: () -> boolean
    

# ImageButton Iris.ImageButton
    hasChildren = false
    hasState = false
## Arguments
    Image: string
    Size: UDim2
    Rect: Rect? = Rect.new()
    ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch
    ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default
    TileSize: UDim2? = UDim2.fromScale(1, 1)
    SliceCenter: Rect? = Rect.new()
    SliceScale: number? = 1
## Events
    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean
    

# Tree Iris.Tree, CollapsingHeader Iris.CollapsingHeader
    hasChildren: true
    hasState: true
## Arguments
    Label: string
    SpanAvailWidth: boolean? = false
    NoIndent: boolean? = false
    DefaultOpen: boolean? = false
## Events
    collapsed: () -> boolean
    uncollapsed: () -> boolean
    hovered: () -> boolean
## States
    open: State<boolean>?


# TabBar Iris.TabBar
    hasChildren: true
    hasState: true
## States
    index: State<number>?
    

# Tab Iris.Tab
    hasChildren: true
    hasState: true
## Arguments
    Text: string
    Hideable: boolean? = nil
## Events
    clicked: () -> boolean
    hovered: () -> boolean
    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    opened: () -> boolean
    closed: () -> boolean
    

# InputNum, InputVector2, InputVector3, InputUDim, InputUDim2, InputRect Iris.Input<T>
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "InputNum"
    Increment: number? = nil
    Min: number? = nil
    Max: number? = nil
    Format: string? | { string }? = [DYNAMIC]
    NoButtons: boolean? = false
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    value: State<number>?


# DragNum, DragVector2, DragVector3, DragUDim, DragUDim2, DragRect Iris.Drag<T>
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "DragNum"
    Increment: number? = nil
    Min: number? = nil
    Max: number? = nil
    Format: string? | { string }? = [DYNAMIC]
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    value: State<number>?


# InputColor3 Iris.InputColor3
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "InputColor3"
    UseFloats: boolean? = false
    UseHSV: boolean? = false
    Format: string? | { string }? = [DYNAMIC]
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    color: State<Color3>?
    

# InputColor4 Iris.InputColor4
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "InputColor4"
    UseFloats: boolean? = false
    UseHSV: boolean? = false
    Format: string? | { string }? = [DYNAMIC]
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    color: State<Color3>?
    transparency: State<number>?


# SliderNum, SliderVector2, SliderVector3, SliderUDim, SliderUDim2, SliderRect Iris.SliderNum
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "SliderNum"
    Increment: number? = 1
    Min: number? = 0
    Max: number? = 100
    Format: string? | { string }? = [DYNAMIC]
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    value: State<number>?


# Selectable Iris.Selectable
    hasChildren = false
    hasState = true
## Arguments
    Label: string
    Value: any
    NoClick: boolean? = false
## Events
    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean
## States
    index: State<any>


# Combo Iris.Combo
    hasChildren = true
    hasState = true
## Arguments
    Label: string
    NoButton: boolean? = false
    NoPreview: boolean? = false
## Events
    opened: () -> boolean
    closed: () -> boolean
    changed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean
## States
    index: State<any>
    open: State<boolean>?
    

# ComboArray Iris.Combo
    hasChildren = true
    hasState = true
## Arguments
    Label: string
    SelectionArray: { any }
    NoButton: boolean? = false
    NoPreview: boolean? = false
## Events
    opened: () -> boolean
    closed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean
## States
    index: State<any>
    open: State<boolean>?
    

# ComboEnum Iris.Combo
    hasChildren = true
    hasState = true
## Arguments
    Text: string
    EnumType: Enum
    NoButton: boolean? = false
    NoPreview: boolean? = false
## Events
    opened: () -> boolean
    closed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean
## States
    index: State<any>
    open: State<boolean>?
    

# InputEnum Iris.InputEnum
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "InputEnum"
    EnumType: Enum
## Events
    numberChanged: () -> boolean
    hovered: () -> boolean
## States
    enumItem: EnumItem
    

# ProgressBar Iris.ProgressBar
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "Progress Bar"
    Format: string? = nil
## Events
    hovered: () -> boolean
    changed: () -> boolean
## States
    progress: State<number>?
    

# PlotLines Iris.PlotLines
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "Plot Lines"
    Height: number? = 0
    Min: number? = min
    Max: number? = max
    TextOverlay: string? = ""
## Events
    hovered: () -> boolean
## States
    values: State<{number}>?


# PlotHistogram Iris.PlotHistogram
    hasChildren = false
    hasState = true
## Arguments
    Label: string? = "Plot Histogram"
    Height: number? = 0
    Min: number? = min
    Max: number? = max
    TextOverlay: string? = ""
    BaseLine: number? = 0
## Events
    hovered: () -> boolean
## States
    values: State<{number}>?


# Table Iris.Table
    hasChildren = true
    hasState = false
## Arguments
    NumColumns: number
    Header: boolean? = false
    RowBackground: boolean? = false
    OuterBorders: boolean? = false
    InnerBorders: boolean? = false
    Resizable: boolean? = false
    FixedWidth: boolean? = false
    ProportionalWidth: boolean? = false
    LimitTableWidth: boolean? = false
## Events
    hovered: () -> boolean
## States
    widths: State<{ number }>?
