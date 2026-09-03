# Completion

## Checks
- Type
  - Argumets
    - Optional
  - States
    - Optional
  - Events
- Constructor
  - Num Arguments
  - Arguments
  - Events
  - GenerateState
    - Optional
    - Default values
  - Update
    - Optional
    - Default values
- API
  - Arguments
    - Optional

## Windows
- [ ] [Window](#window-iriswindow)
- [ ] [Tooltip](#tooltip-iristooltip)
- [ ] [MenuBar](#menubar-irismenubar)
- [ ] [Menu](#menu-irismenu)
- [ ] [MenuItem](#menuitem-irismenuitem)
- [ ] [MenuToggle](#menutoggle-irismenutoggle)

## Formatting
- [ ] [Separator](#separator-irisseparator)
- [ ] [Indent](#indent-irisindent)
- [ ] [SameLine](#sameline-irissameline)
- [ ] [Group](#group-irisgroup)
- [ ] [SeparatorText](#separatortext-irisseparatortext)
  
## Basic
- [ ] [Text](#text-iristext)
- [ ] [Button](#button-irisbutton-smallbutton-irissmallbutton)
- [ ] [Checkbox](#checkbox-irischeckbox)
- [ ] [CheckboxFlags](#checkboxflags-irischeckboxflags)
- [ ] [RadioButton](#radiobutton-irisradiobutton)
- [ ] [Image](#image-irisimage)
- [ ] [ImageButton](#imagebutton-irisimagebutton)
- [ ] [Tree](#tree-iristree-collapsingheader-iriscollapsingheader)
- [ ] [TabBar](#tabbar-iristabbar)
- [ ] [Tab](#tab-iristab)

## Inputs
- [ ] [InputText](#inputtext-irisinputtext)
- [ ] [InputNum](#inputnum-inputvector2-inputvector3-inputudim-inputudim2-inputrect-irisinput)
- [ ] [DragNum](#dragnum-dragvector2-dragvector3-dragudim-dragudim2-dragrect-irisdrag)
- [ ] [InputColor3](#inputcolor3-irisinputcolor3)
- [ ] [InputColor4](#inputcolor4-irisinputcolor4)
- [ ] [SliderNum](#slidernum-slidervector2-slidervector3-sliderudim-sliderudim2-sliderrect-irisslidernum)
- [ ] [Selectable](#selectable-irisselectable)
  
## Dropdown
- [ ] [Combo](#combo-iriscombo)
- [ ] [ComboArray](#comboarray-iriscombo)
- [ ] [ComboEnum](#comboenum-iriscombo)
- [ ] [InputEnum](#inputenum-irisinputenum)

## Plotting
- [ ] [ProgressBar](#progressbar-irisprogressbar)
- [ ] [PlotLines](#plotlines-irisplotlines)
- [ ] [PlotHistogram](#plothistogram-irisplothistogram)
- [ ] [Table](#table-iristable)

# Widget Properties

## Window `Iris.Window`

- `hasChildren`
- `hasState`

### Arguments

    Title: string
    Flags: WindowFlags? = 0,

### Events

    opened: () -> boolean
    closed: () -> boolean
    collapsed: () -> boolean
    uncollapsed: () -> boolean
    hovered: () -> boolean

### States

    size: State<Vector2>? = Vector2.new(400, 300)
    position: State<Vector2>?
    open: State<boolean>? = true
    collapsed: State<boolean>? = false
    scrollDistance: State<number>?

## Tooltip `Iris.Tooltip`


### Arguments

    Text: string

## MenuBar `Iris.MenuBar`

- `hasChildren`

## Menu `Iris.Menu`

- `hasChildren`
- `hasState`

### Arguments

    Label: string

### Events

    clicked: () -> boolean
    opened: () -> boolean
    closed: () -> boolean
    hovered: () -> boolean

### States

    open: State<boolean>?

## MenuItem `Iris.MenuItem`


### Arguments

    Label: string
    KeyCode: Enum.KeyCode? = nil
    ModifierKey: Enum.ModifierKey? = nil

### Events

    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean

## MenuToggle `Iris.MenuToggle`

- `hasState`

### Arguments

    Label: string
    KeyCode: Enum.KeyCode? = nil
    ModifierKey: Enum.ModifierKey? = nil

### Events

    checked: () -> boolean
    unchecked: () -> boolean
    hovered: () -> boolean

### States

    value: State<boolean>?

## Separator `Iris.Separator`


## Indent `Iris.Indent`

- `hasChildren`

### Arguments

    Width: number? = Iris._config.IndentSpacing

## SameLine `Iris.SameLine`

- `hasChildren`

### Arguments

    Width: number? = Iris._config.ItemSpacing.X
    VerticalAlignment: Enum.VerticalAlignment? = Enum.VerticalAlignment.Center
    HorizontalAlignment: Enum.HorizontalAlignment? = Enum.HorizontalAlignment.Center

## Group `Iris.Group`

- `hasChildren`

## Text `Iris.Text`


### Arguments

    Text: string
    Wrapped: boolean? = [CONFIG] = false
    Color: Color3? = Iris._config.TextColor
    RichText: boolean? = [CONFIG] = false

### Events

    hovered: () -> boolean

## SeparatorText `Iris.SeparatorText`


### Arguments

    Label: string

## InputText `Iris.InputText`

- `hasState`

### Arguments

    Label: string? = "InputText"
    TextHint: string? = ""
    Flags: InputTextFlags? = 0

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    text: State<string>?

## Button `Iris.Button`, SmallButton `Iris.SmallButton`


### Arguments

    Label: string
    Size: UDim2? = UDim2.fromOffset(0, 0)

### Events

    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean

## Checkbox `Iris.Checkbox`

- `hasState`

### Arguments

    Label: string

### Events

    checked: () -> boolean
    unchecked: () -> boolean
    changed: () -> boolean
    hovered: () -> boolean

### States

    value = State<boolean>?

## CheckboxFlags `Iris.CheckboxFlags`

- `hasState`

### Arguments

    Label: string
    Bit: number

### Events

    checked: () -> boolean
    unchecked: () -> boolean
    changed: () -> boolean
    hovered: () -> boolean

### States

    flags = State<number>?

## RadioButton `Iris.RadioButton`

- `hasState`

### Arguments

    Label: string
    Value: any

### Events

    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    changed: () -> boolean
    hovered: () -> boolean

### States

    index = State<any>?

## Image `Iris.Image`


### Arguments

    Image: string
    Size: UDim2
    Rect: Rect? = Rect.new()
    ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch
    ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default
    TileSize: UDim2? = UDim2.fromScale(1, 1)
    SliceCenter: Rect? = Rect.new()
    SliceScale: number? = 1

### Events

    hovered: () -> boolean

## ImageButton `Iris.ImageButton`


### Arguments

    Image: string
    Size: UDim2
    Rect: Rect? = Rect.new()
    ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch
    ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default
    TileSize: UDim2? = UDim2.fromScale(1, 1)
    SliceCenter: Rect? = Rect.new()
    SliceScale: number? = 1

### Events

    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean

## Tree `Iris.Tree`, CollapsingHeader `Iris.CollapsingHeader`

    hasChildren: true
    hasState: true

### Arguments

    Label: string
    Flags: TreeFlags? = 0

### Events

    open: () -> boolean
    closed: () -> boolean
    changed: () -> boolean
    hovered: () -> boolean

### States

    open: State<boolean>?

## TabBar `Iris.TabBar`

    hasChildren: true
    hasState: true

### States

    index: State<number>?

## Tab `Iris.Tab`

    hasChildren: true
    hasState: true

### Arguments

    Text: string
    Hideable: boolean? = nil

### Events

    clicked: () -> boolean
    hovered: () -> boolean
    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    opened: () -> boolean
    closed: () -> boolean

## InputNum, InputVector2, InputVector3, InputUDim, InputUDim2, InputRect `Iris.Input`<T>

- `hasState`

### Arguments

    Label: string? = "InputNum"
    Increment: number? = nil
    Min: number? = nil
    Max: number? = nil
    Format: string? | { string }? = [DYNAMIC]
    NoButtons: boolean? = false

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    value: State<number>?

## DragNum, DragVector2, DragVector3, DragUDim, DragUDim2, DragRect `Iris.Drag`<T>

- `hasState`

### Arguments

    Label: string? = "DragNum"
    Increment: number? = nil
    Min: number? = nil
    Max: number? = nil
    Format: string? | { string }? = [DYNAMIC]

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    value: State<number>?

## InputColor3 `Iris.InputColor3`

- `hasState`

### Arguments

    Label: string? = "InputColor3"
    UseFloats: boolean? = false
    UseHSV: boolean? = false
    Format: string? | { string }? = [DYNAMIC]

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    color: State<Color3>?

## InputColor4 `Iris.InputColor4`

- `hasState`

### Arguments

    Label: string? = "InputColor4"
    UseFloats: boolean? = false
    UseHSV: boolean? = false
    Format: string? | { string }? = [DYNAMIC]

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    color: State<Color3>?
    transparency: State<number>?

## SliderNum, SliderVector2, SliderVector3, SliderUDim, SliderUDim2, SliderRect `Iris.SliderNum`

- `hasState`

### Arguments

    Label: string? = "SliderNum"
    Increment: number? = 1
    Min: number? = 0
    Max: number? = 100
    Format: string? | { string }? = [DYNAMIC]

### Events

    changed: () -> boolean
    editing: () -> boolean
    hovered: () -> boolean

### States

    value: State<number>?

## Selectable `Iris.Selectable`

- `hasState`

### Arguments

    Label: string
    Value: any
    NoClick: boolean? = false

### Events

    selected: () -> boolean
    unselected: () -> boolean
    active: () -> boolean
    clicked: () -> boolean
    rightClicked: () -> boolean
    doubleClicked: () -> boolean
    ctrlClicked: () -> boolean
    hovered: () -> boolean

### States

    index: State<any>

## Combo `Iris.Combo`

- `hasChildren`
- `hasState`

### Arguments

    Label: string
    Flags: ComboFlags? = 0

### Events

    opened: () -> boolean
    closed: () -> boolean
    changed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean

### States

    index: State<any>?
    open: State<boolean>?

## ComboArray `Iris.Combo`

- `hasChildren`
- `hasState`

### Arguments

    Label: string
    SelectionArray: { any }
    Flags: ComboFlags? = 0

### Events

    opened: () -> boolean
    closed: () -> boolean
    changed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean

### States

    index: State<any>?
    open: State<boolean>?

## ComboEnum `Iris.Combo`

- `hasChildren`
- `hasState`

### Arguments

    Text: string
    EnumType: Enum
    Flags: ComboFlags? = 0

### Events

    opened: () -> boolean
    closed: () -> boolean
    changed: () -> boolean
    clicked: () -> boolean
    hovered: () -> boolean

### States

    index: State<any>?
    open: State<boolean>?

## InputEnum `Iris.InputEnum`

- `hasState`

### Arguments

    Label: string? = "InputEnum"
    EnumType: Enum

### Events

    numberChanged: () -> boolean
    hovered: () -> boolean

### States

    enumItem: EnumItem

## ProgressBar `Iris.ProgressBar`

- `hasState`

### Arguments

    Label: string? = "Progress Bar"
    Format: string? = nil

### Events

    hovered: () -> boolean
    changed: () -> boolean

### States

    progress: State<number>?

## PlotLines `Iris.PlotLines`

- `hasState`

### Arguments

    Label: string? = "Plot Lines"
    Height: number? = 0
    Min: number? = min
    Max: number? = max
    TextOverlay: string? = ""

### Events

    hovered: () -> boolean

### States

    values: State<{number}>?

## PlotHistogram `Iris.PlotHistogram`

- `hasState`

### Arguments

    Label: string? = "Plot Histogram"
    Height: number? = 0
    Min: number? = min
    Max: number? = max
    TextOverlay: string? = ""
    BaseLine: number? = 0

### Events

    hovered: () -> boolean

### States

    values: State<{number}>?

## Table `Iris.Table`

- `hasChildren`

### Arguments

    NumColumns: number
    Flags: TableFlags? = 0

### Events

    changed: () -> boolean
    hovered: () -> boolean

### States

    widths: State<{ number }>?
