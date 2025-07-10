local Iris = require(script.Parent)
local Types = require(script.Parent.Types)

local btest = bit32.btest

local Wrapper = {
    State = Iris.State,
    WeakState = Iris.WeakState,
    VariableState = Iris.VariableState,
    TableState = Iris.TableState,
    ComputedState = Iris.ComputedState,

    --[[
        -------------
          FUNCTIONS
        -------------
    ]]

    Shutdown = Iris.Shutdown,
    Append = Iris.Append,
    ForceRefresh = Iris.ForceRefresh,

    -- Widget
    SetFocusedWindow = Iris.SetFocusedWindow,

    -- ID API
    PushId = Iris.PushId,
    PopId = Iris.PopId,
    SetNextWidgetID = Iris.SetNextWidgetID,

    -- Config API
    UpdateGlobalConfig = Iris.UpdateGlobalConfig,
    PushConfig = Iris.PushConfig,
    PopConfig = Iris.PopConfig,

    --[[
        --------------
          PROPERTIES
        --------------
    ]]

    Internal = Iris.Internal,
    Disabled = Iris.Disabled,
    Args = Iris.Args,
    Events = Iris.Events,

    TemplateConfig = Iris.TemplateConfig,
    _config = Iris._config,
    ShowDemoWindow = Iris.ShowDemoWindow,
}

function Wrapper.Init(playerInstance: BasePlayerGui?, eventConnection: (RBXScriptConnection | () -> () | false)?, allowMultipleInits: boolean?)
    Iris.Init(playerInstance, eventConnection, allowMultipleInits)
    return Wrapper
end

function Wrapper:Connect(callback: () -> ())
    return Iris:Connect(callback)
end

Wrapper.End = Iris.End

-- Window API
Wrapper.WindowFlags = {
    NoTitleBar = 1,
    NoBackground = 2,
    NoCollapse = 4,
    NoClose = 8,
    NoMove = 16,
    NoScrollbar = 32,
    NoResize = 64,
    NoNav = 128,
    NoMenu = 256,
}

Wrapper.Window = function(title: string, flags: number?, size: Types.State<Vector2>?, position: Types.State<Vector2>?, isUncollapsed: Types.State<boolean>?, isOpened: Types.State<boolean>?, scrollDistance: Types.State<number>?)
    local windowFlags = flags or 0
    return Iris.Window({
        title,
        btest(windowFlags, Wrapper.WindowFlags.NoTitleBar),
        btest(windowFlags, Wrapper.WindowFlags.NoBackground),
        btest(windowFlags, Wrapper.WindowFlags.NoCollapse),
        btest(windowFlags, Wrapper.WindowFlags.NoClose),
        btest(windowFlags, Wrapper.WindowFlags.NoMove),
        btest(windowFlags, Wrapper.WindowFlags.NoScrollbar),
        btest(windowFlags, Wrapper.WindowFlags.NoResize),
        btest(windowFlags, Wrapper.WindowFlags.NoNav),
        btest(windowFlags, Wrapper.WindowFlags.NoMenu),
    }, {
        size = size,
        position = position,
        isUncollapsed = isUncollapsed,
        isOpened = isOpened,
        scrollDistance = scrollDistance,
    })
end

Wrapper.Tooltip = function(text: string)
    return Iris.Tooltip({ text })
end

-- Menu Widget API
Wrapper.MenuBar = Iris.MenuBar

Wrapper.Menu = function(text: string, isOpened: Types.State<boolean>?)
    return Iris.Menu({ text }, { isOpened = isOpened })
end

Wrapper.MenuItem = function(text: string, keyCode: Enum.KeyCode?, modifierKey: Enum.ModifierKey?)
    return Iris.MenuItem({ text, keyCode, modifierKey })
end

Wrapper.MenuToggle = function(text: string, keyCode: Enum.KeyCode?, modifierKey: Enum.ModifierKey?)
    return Iris.MenuToggle({ text, keyCode, modifierKey })
end

-- Format Widget API
Wrapper.Separator = Iris.Separator

Wrapper.Indent = function(width: number?)
    return Iris.Indent({ width })
end

Wrapper.SameLine = function(width: number?, verticalAlignment: Enum.VerticalAlignment?, horizontalAlignment: Enum.HorizontalAlignment?)
    return Iris.SameLine({ width, verticalAlignment, horizontalAlignment })
end

Wrapper.Group = Iris.Group

-- Text Widget API
Wrapper.TextFlags = {
    Wrapped = 1,
    RichText = 2,
}

Wrapper.InputTextFlags = {
    ReadOnly = 1,
    MultiLine = 2,
}

Wrapper.Text = function(text: string, flags: number?, color: Color3?)
    local textFlags = flags or 0
    return Iris.Text({ text, btest(textFlags, Wrapper.TextFlags.Wrapped), color, btest(textFlags, Wrapper.TextFlags.RichText) })
end

Wrapper.TextWrapped = function(text: string)
    return Iris.Text({ text, true })
end

Wrapper.TextColored = function(text: string, color: Color3)
    return Iris.Text({ text, nil, color })
end

Wrapper.SeparatorText = function(text: string)
    return Iris.SeparatorText(text)
end

Wrapper.InputText = function(text: string?, textHint: string?, flags: number?, textBuffer: Types.State<string>?)
    local inputTextFlags = flags or 0
    return Iris.InputText({ text, textHint, btest(inputTextFlags, Wrapper.InputTextFlags.ReadOnly), btest(inputTextFlags, Wrapper.InputTextFlags.MultiLine) }, { text = textBuffer })
end

-- Basic Widget API
Wrapper.Button = function(text: string, size: UDim2?)
    return Iris.Button({ text, size })
end

Wrapper.SmallButton = function(text: string, size: UDim2?)
    return Iris.SmallButton({ text, size })
end

Wrapper.Checkbox = function(text: string, checked: Types.State<boolean>?)
    return Iris.Checkbox({ text }, { isChecked = checked })
end

Wrapper.RadioButton = function(text: string, index: any, state: Types.State<any>?)
    return Iris.RadioButton({ text, index }, { index = state })
end

-- Tree Widget API
Wrapper.TreeFlags = {
    SpanAvailWidth = 1,
    NoIndent = 2,
    DefaultOpen = 4,
}

Wrapper.Tree = function(text: string, flags: number?, open: Types.State<boolean>?)
    local treeFlags = flags or 0
    return Iris.Tree({ text, btest(treeFlags, Wrapper.TreeFlags.SpanAvailWidth), btest(treeFlags, Wrapper.TreeFlags.NoIndent), btest(treeFlags, Wrapper.TreeFlags.DefaultOpen) }, { isUncollapsed = open })
end

Wrapper.CollapsingHeader = function(text: string, flags: number?, open: Types.State<boolean>?)
    local treeFlags = flags or 0
    return Iris.CollapsingHeader({ text, btest(treeFlags, Wrapper.TreeFlags.DefaultOpen) }, { isUncollapsed = open })
end

-- Tab Widget API
Wrapper.TabFlags = {
    Hideable = 1,
}

Wrapper.TabBar = function(state: Types.State<number>?)
    return Iris.TabBar({}, { index = state })
end

Wrapper.Tab = function(text: string, flags: number?, open: Types.State<boolean>?)
    local tabFlags = flags or 0
    return Iris.Tab({ text, btest(tabFlags, Wrapper.TabFlags.Hideable) }, { isOpened = open })
end

-- Input Widget API
Wrapper.InputFlags = {
    UseFloats = 1,
    UseHSV = 2,
}

Wrapper.InputNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Iris.InputNum({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputVector2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Iris.InputVector2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputVector3 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Iris.InputVector3({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputUDim = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Iris.InputUDim({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputUDim2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Iris.InputUDim2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputRect = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Iris.InputRect({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.InputColor3 = function(text: string, flags: number?, format: string? | { string }?, color: Types.State<Color3>?, editing: Types.State<boolean>?)
    local inputFlags = flags or 0
    return Iris.InputColor3({ text, btest(inputFlags, Wrapper.InputFlags.UseFloats), btest(inputFlags, Wrapper.InputFlags.UseHSV), format }, { color = color, editingText = editing })
end

Wrapper.InputColor4 = function(text: string, flags: number?, format: string? | { string }?, color: Types.State<Color3>?, transparency: Types.State<number>?, editing: Types.State<boolean>?)
    local inputFlags = flags or 0
    return Iris.InputColor4({ text, btest(inputFlags, Wrapper.InputFlags.UseFloats), btest(inputFlags, Wrapper.InputFlags.UseHSV), format }, { color = color, transparency = transparency, editingText = editing })
end

-- Drag Widget API
Wrapper.DragNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Iris.DragNum({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.DragVector2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Iris.DragVector2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.DragVector3 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Iris.DragVector3({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.DragUDim = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Iris.DragUDim({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.DragUDim2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Iris.DragUDim2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.DragRect = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Iris.DragRect({ text, increment, min, max, format }, { number = value, editingText = editing })
end

-- Slider Widget API
Wrapper.SliderNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Iris.SliderNum({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.SliderVector2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Iris.SliderVector2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.SliderVector3 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Iris.SliderVector3({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.SliderUDim = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Iris.SliderUDim({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.SliderUDim2 = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Iris.SliderUDim2({ text, increment, min, max, format }, { number = value, editingText = editing })
end

Wrapper.SliderRect = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Iris.SliderRect({ text, increment, min, max, format }, { number = value, editingText = editing })
end

-- Combo Widget Widget API
Wrapper.ComboFlags = {
    NoClick = 1,
    NoButton = 2,
    NoPreview = 4,
}

Wrapper.Selectable = function(text: string, index: any, flags: number?, state: Types.State<any>?)
    local comboFlags = flags or 0
    return Iris.Selectable({ text, index, btest(comboFlags, Wrapper.ComboFlags.NoClick) }, { index = state })
end

Wrapper.Combo = function(text: string, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    local comboFlags = flags or 0
    return Iris.Combo({ text, btest(comboFlags, Wrapper.ComboFlags.NoButton), btest(comboFlags, Wrapper.ComboFlags.NoPreview) }, { index = state, isOpened = open })
end

Wrapper.ComboArray = function(text: string, array: { any }, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    local comboFlags = flags or 0
    return Iris.ComboArray({ text, btest(comboFlags, Wrapper.ComboFlags.NoButton), btest(comboFlags, Wrapper.ComboFlags.NoPreview) }, { index = state, isOpened = open }, array)
end

Wrapper.ComboEnum = function(text: string, enum: Enum, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    local comboFlags = flags or 0
    return Iris.ComboEnum({ text, btest(comboFlags, Wrapper.ComboFlags.NoButton), btest(comboFlags, Wrapper.ComboFlags.NoPreview) }, { index = state, isOpened = open }, enum)
end

Wrapper.InputEnum = Wrapper.ComboEnum

-- Plot Widget API
Wrapper.ProgressBar = function(text: string?, format: string?, progress: Types.State<number>?)
    return Iris.ProgressBar({ text, format }, { progress = progress })
end

Wrapper.PlotLines = function(text: string?, height: number?, min: number?, max: number?, textOverlay: string?, values: Types.State<number>?, hovered: Types.State<number>?)
    return Iris.PlotLines({ text, height, min, max, textOverlay }, { values = values, hovered = hovered })
end

Wrapper.PlotHistogram = function(text: string?, height: number?, min: number?, max: number?, textOverlay: string?, baseline: number?, values: Types.State<number>?, hovered: Types.State<number>?)
    return Iris.PlotHistogram({ text, height, min, max, textOverlay, baseline }, { values = values, hovered = hovered })
end

-- Image Widget API
Wrapper.Image = function(image: string, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Iris.Image({ image, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale })
end

Wrapper.ImageButton = function(image: string, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Iris.ImageButton({ image, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale })
end

-- Table Widget API
Wrapper.TableFlags = {
    Header = 1,
    RowBackground = 2,
    OuterBorders = 4,
    InnerBorders = 8,
    Resizable = 16,
    FixedWidth = 32,
    ProportionalWidth = 64,
    LimitTableWidth = 128,
}

Wrapper.Table = function(numColumns: number, flags: number?, widths: Types.State<{ number }>?)
    local tableFlags = flags or 0
    return Iris.Table({
        numColumns,
        btest(tableFlags, Wrapper.TableFlags.Header),
        btest(tableFlags, Wrapper.TableFlags.RowBackground),
        btest(tableFlags, Wrapper.TableFlags.OuterBorders),
        btest(tableFlags, Wrapper.TableFlags.InnerBorders),
        btest(tableFlags, Wrapper.TableFlags.Resizable),
        btest(tableFlags, Wrapper.TableFlags.FixedWidth),
        btest(tableFlags, Wrapper.TableFlags.ProportionalWidth),
        btest(tableFlags, Wrapper.TableFlags.LimitTableWidth),
    }, { widths = widths })
end

Wrapper.NextColumn = Iris.NextColumn
Wrapper.NextRow = Iris.NextRow
Wrapper.SetColumnIndex = Iris.SetColumnIndex
Wrapper.SetRowIndex = Iris.SetRowIndex
Wrapper.NextHeaderColumn = Iris.NextHeaderColumn
Wrapper.SetHeaderColumnIndex = Iris.SetHeaderColumnIndex
Wrapper.SetColumnWidth = Iris.SetColumnWidth

return Wrapper
