local Iris = require(script.Parent)
local Types = require(script.Parent.Types)

local band = bit32.band

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
        band(windowFlags, Wrapper.WindowFlags.NoTitleBar),
        band(windowFlags, Wrapper.WindowFlags.NoBackground),
        band(windowFlags, Wrapper.WindowFlags.NoCollapse),
        band(windowFlags, Wrapper.WindowFlags.NoClose),
        band(windowFlags, Wrapper.WindowFlags.NoMove),
        band(windowFlags, Wrapper.WindowFlags.NoScrollbar),
        band(windowFlags, Wrapper.WindowFlags.NoResize),
        band(windowFlags, Wrapper.WindowFlags.NoNav),
        band(windowFlags, Wrapper.WindowFlags.NoMenu),
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

-- -- Text Widget API
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
    return Iris.Text({ text, band(textFlags, Wrapper.TextFlags.Wrapped), color, band(textFlags, Wrapper.TextFlags.RichText) })
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
    return Iris.InputText({ text, textHint, band(inputTextFlags, Wrapper.InputTextFlags.ReadOnly), band(inputTextFlags, Wrapper.InputTextFlags.MultiLine) }, { text = textBuffer })
end

-- -- Basic Widget API
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

-- -- Tree Widget API
Wrapper.Tree = function(WidgetArguments, WidgetStates)
    return Iris.Tree()
end

Wrapper.CollapsingHeader = function(WidgetArguments, WidgetStates)
    return Iris.CollapsingHeader()
end

-- -- Tab Widget API
Wrapper.TabBar = function(WidgetArguments, WidgetStates)
    return Iris.TabBar()
end

Wrapper.Tab = function(WidgetArguments, WidgetStates)
    return Iris.Tab()
end

-- -- Input Widget API
Wrapper.InputNum = function(WidgetArguments, WidgetStates)
    return Iris.InputNum()
end

Wrapper.InputVector2 = function(WidgetArguments, WidgetStates)
    return Iris.InputVector2()
end

Wrapper.InputVector3 = function(WidgetArguments, WidgetStates)
    return Iris.InputVector3()
end

Wrapper.InputUDim = function(WidgetArguments, WidgetStates)
    return Iris.InputUDim()
end

Wrapper.InputUDim2 = function(WidgetArguments, WidgetStates)
    return Iris.InputUDim2()
end

Wrapper.InputRect = function(WidgetArguments, WidgetStates)
    return Iris.InputRect()
end

Wrapper.InputColor3 = function(WidgetArguments, WidgetStates)
    return Iris.InputColor3()
end

Wrapper.InputColor4 = function(WidgetArguments, WidgetStates)
    return Iris.InputColor4()
end

-- -- Drag Widget API
Wrapper.DragNum = function(WidgetArguments, WidgetStates)
    return Iris.DragNum()
end

Wrapper.DragVector2 = function(WidgetArguments, WidgetStates)
    return Iris.DragVector2()
end

Wrapper.DragVector3 = function(WidgetArguments, WidgetStates)
    return Iris.DragVector3()
end

Wrapper.DragUDim = function(WidgetArguments, WidgetStates)
    return Iris.DragUDim()
end

Wrapper.DragUDim2 = function(WidgetArguments, WidgetStates)
    return Iris.DragUDim2()
end

Wrapper.DragRect = function(WidgetArguments, WidgetStates)
    return Iris.DragRect()
end

-- -- Slider Widget API
Wrapper.SliderNum = function(WidgetArguments, WidgetStates)
    return Iris.SliderNum()
end

Wrapper.SliderVector2 = function(WidgetArguments, WidgetStates)
    return Iris.SliderVector2()
end

Wrapper.SliderVector3 = function(WidgetArguments, WidgetStates)
    return Iris.SliderVector3()
end

Wrapper.SliderUDim = function(WidgetArguments, WidgetStates)
    return Iris.SliderUDim()
end

Wrapper.SliderUDim2 = function(WidgetArguments, WidgetStates)
    return Iris.SliderUDim2()
end

Wrapper.SliderRect = function(WidgetArguments, WidgetStates)
    return Iris.SliderRect()
end

-- -- Combo Widget Widget API
Wrapper.Selectable = function(WidgetArguments, WidgetStates)
    return Iris.Selectable()
end

Wrapper.Combo = function(WidgetArguments, WidgetStates)
    return Iris.Combo()
end

Wrapper.ComboArray = function(WidgetArguments, WidgetStates)
    return Iris.ComboArray()
end

Wrapper.ComboEnum = function(WidgetArguments, WidgetStates, Enum)
    return Iris.ComboEnum()
end

Wrapper.InputEnum = function(WidgetArguments, WidgetStates, Enum)
    return Iris.InputEnum()
end

Wrapper.ProgressBar = function(WidgetArguments, WidgetStates)
    return Iris.ProgressBar()
end

Wrapper.PlotLines = function(WidgetArguments, WidgetStates)
    return Iris.PlotLines()
end

Wrapper.PlotHistogram = function(WidgetArguments, WidgetStates)
    return Iris.PlotHistogram()
end

Wrapper.Image = function(WidgetArguments)
    return Iris.Image()
end

Wrapper.ImageButton = function(WidgetArguments)
    return Iris.ImageButton()
end

-- -- Table Widget API
Wrapper.Table = function(WidgetArguments, WidgetStates)
    return Iris.Table()
end

Wrapper.NextColumn = Iris.NextColumn
Wrapper.NextRow = Iris.NextRow
Wrapper.SetColumnIndex = Iris.SetColumnIndex
Wrapper.SetRowIndex = Iris.SetRowIndex
Wrapper.NextHeaderColumn = Iris.NextHeaderColumn
Wrapper.SetHeaderColumnIndex = Iris.SetHeaderColumnIndex
Wrapper.SetColumnWidth = Iris.SetColumnWidth
