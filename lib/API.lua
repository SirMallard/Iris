local Types = require(script.Parent.Types)

local Internal = require(script.Parent.Internal)

-- local Root = require(script.Parent.widgets.Root)
local Window = require(script.Parent.widgets.Window)
local Menu = require(script.Parent.widgets.Menu)

local Format = require(script.Parent.widgets.Format)

local Text = require(script.Parent.widgets.Text)
local Button = require(script.Parent.widgets.Button)
local Checkbox = require(script.Parent.widgets.Checkbox)
local RadioButton = require(script.Parent.widgets.RadioButton)
local Image = require(script.Parent.widgets.Image)

local Tree = require(script.Parent.widgets.Tree)
local Tab = require(script.Parent.widgets.Tab)

local Input = require(script.Parent.widgets.Input)
local Combo = require(script.Parent.widgets.Combo)
local Plot = require(script.Parent.widgets.Plot)

local Table = require(script.Parent.widgets.Table)

local API = {}

API.WindowFlags = Window.WindowFlags
API.TextFlags = Text.TextFlags
API.InputFlags = Input.InputFlags
API.InputTextFlags = Input.InputTextFlags

API.TreeFlags = Tree.TreeFlags
API.TabFlags = Tab.TabFlags
API.ComboFlags = Combo.ComboFlags
API.TableFlags = Table.TableFlags

--[[
    ---------------------------------
        [SECTION] Text Widget API
    ---------------------------------
]]

--[=[
    @within Text
    @function InputText
    @return InputText
    @tag Widget
    @tag HasState

    A field which allows the user to enter text.

    ```lua
    Iris.Window({"Input Text Demo"})
        local inputtedText = Iris.State("")

        Iris.InputText({"Enter text here:"}, {text = inputtedText})
        Iris.Text({"You entered: " .. inputtedText:get()})
    Iris.End()
    ```

    ![Example Input Text](/Iris/assets/api/text/basicInputText.gif)

    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputText",
        TextHint: string? = "", -- a hint to display when the text box is empty.
        ReadOnly: boolean? = false,
        MultiLine: boolean? = false
    }
    Events = {
        textChanged: () -> boolean, -- whenever the textbox looses focus and a change was made.
        hovered: () -> boolean
    }
    States = {
        text: State<string>?
    }
    ```
    @param text string?
    @param textHint string?
    @param flags number?
    @param textBuffer Types.State<string>?

]=]
API.InputText = function(text: string?, textHint: string?, flags: number?, textBuffer: Types.State<string>?)
    return Internal._insert("InputText", text, textHint, flags or 0, textBuffer) :: Input.InputText
end

--[[
    ----------------------------------
        [SECTION] Image Widget API
    ----------------------------------
]]
--[=[
    @class Image
    Image Widget API

    Provides two widgets for Images and ImageButtons, which provide the same control as a an ImageLabel instance.
]=]

--[=[
    @within Image
    @function Image
    @return Image
    @tag Widget

    An image widget for displaying an image given its texture ID and a size. The widget also supports Rect Offset and Size allowing cropping of the image and the rest of the ScaleType functionerties
    Some of the arguments are only used depending on the ScaleType functionerty

    ```lua
    hasChildren = false
    hasState = false
    Arguments = {
        Image: string, -- the texture asset id
        Size: UDim2,
        Rect: Rect? = Rect.new(), -- Rect structure which is used to determine the offset or size. An empty, zeroed rect is equivalent to nil
        ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch, -- used to determine whether the TileSize, SliceCenter and SliceScale arguments are used
        ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default,
        TileSize: UDim2? = UDim2.fromScale(1, 1), -- only used if the ScaleType is set to Tile
        SliceCenter: Rect? = Rect.new(), -- only used if the ScaleType is set to Slice
        SliceScale: number? = 1 -- only used if the ScaleType is set to Slice
    }
    Events = {
        hovered: () -> boolean
    }
    ```
    @param image string
    @param size UDim2
    @param rect Rect?
    @param scaleType Enum.ScaleType?
    @param resampleMode Enum.ResamplerMode?
    @param tileSize UDim2?
    @param sliceCenter Rect?
    @param sliceScale number?

]=]
API.Image = function(image: string, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Internal._insert("Image", image, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale) :: Image.Image
end

--[=[
    @within Image
    @function ImageButton
    @return ImageButton
    @tag Widget

    An image button widget for a button as an image given its texture ID and a size. The widget also supports Rect Offset and Size allowing cropping of the image, and the rest of the ScaleType functionerties
    Supports all of the events of a regular button.

    ```lua
    hasChildren = false
    hasState = false
    Arguments = {
        Image: string, -- the texture asset id
        Size: UDim2,
        Rect: Rect? = Rect.new(), -- Rect structure which is used to determine the offset or size. An empty, zeroed rect is equivalent to nil
        ScaleType: Enum.ScaleType? = Enum.ScaleType.Stretch, -- used to determine whether the TileSize, SliceCenter and SliceScale arguments are used
        ResampleMode: Enum.ResampleMode? = Enum.ResampleMode.Default,
        TileSize: UDim2? = UDim2.fromScale(1, 1), -- only used if the ScaleType is set to Tile
        SliceCenter: Rect? = Rect.new(), -- only used if the ScaleType is set to Slice
        SliceScale: number? = 1 -- only used if the ScaleType is set to Slice
    }
    Events = {
        clicked: () -> boolean,
        rightClicked: () -> boolean,
        doubleClicked: () -> boolean,
        ctrlClicked: () -> boolean, -- when the control key is down and clicked.
        hovered: () -> boolean
    }
    ```
    @param image string
    @param size UDim2
    @param rect Rect?
    @param scaleType Enum.ScaleType?
    @param resampleMode Enum.ResamplerMode?
    @param tileSize UDim2?
    @param sliceCenter Rect?
    @param sliceScale number?

]=]
API.ImageButton = function(image: string, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Internal._insert("ImageButton", image, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale) :: Image.ImageButton_
end

--[[
    ---------------------------------
        [SECTION] Tree Widget API
    ---------------------------------
]]
--[=[
    @class Tree
    Tree Widget API
]=]

--[=[
    @within Tree
    @function Tree
    @return Tree
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    A collapsable container for other widgets, to organise and hide widgets when not needed. The state determines whether the child widgets are visible or not. Clicking on the widget will collapse or uncollapse it.
    
    ```lua
    hasChildren: true
    hasState: true
    Arguments = {
        Text: string,
        SpanAvailWidth: boolean? = false, -- the tree title will fill all horizontal space to the end its parent container.
        NoIndent: boolean? = false, -- the child widgets will not be indented underneath.
        DefaultOpen: boolean? = false -- initially opens the tree if no state is provided
    }
    Events = {
        collapsed: () -> boolean,
        uncollapsed: () -> boolean,
        hovered: () -> boolean
    }
    State = {
        isUncollapsed: State<boolean>? -- whether the widget is collapsed.
    }
    ```
    @param text string
    @param flags number?
    @param open Types.State<boolean>?

]=]
API.Tree = function(text: string, flags: number?, open: Types.State<boolean>?)
    return Internal._insert("Tree", text, flags, open) :: Tree.Tree
end

--[=[
    @within Tree
    @function CollapsingHeader
    @return CollapsingHeader
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    The same as a Tree Widget, but with a larger title and clearer, used mainly for organsing widgets on the first level of a window.
    
    ```lua
    hasChildren: true
    hasState: true
    Arguments = {
        Text: string,
        DefaultOpen: boolean? = false -- initially opens the tree if no state is provided
    }
    Events = {
        collapsed: () -> boolean,
        uncollapsed: () -> boolean,
        hovered: () -> boolean
    }
    State = {
        isUncollapsed: State<boolean>? -- whether the widget is collapsed.
    }
    ```
    @param text string
    @param flags number?
    @param open Types.State<boolean>?

]=]
API.CollapsingHeader = function(text: string, flags: number?, open: Types.State<boolean>?)
    return Internal._insert("CollapsingHeader", text, flags, open) :: Tree.CollapsingHeader
end

--[[
    --------------------------------
        [SECTION] Tab Widget API
    --------------------------------
]]
--[=[
    @class Tab
    Tab Widget API
]=]

--[=[
    @within Tab
    @function TabBar
    @return TabBar
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    Creates a TabBar for putting tabs under. This does not create the tabs but just the container for them to be in.
    The index state is used to control the current tab and is based on an index starting from 1 rather than the
    text provided to a Tab. The TabBar will replicate the index to the Tab children .
    
    ```lua
    hasChildren: true
    hasState: true
    Arguments = {}
    Events = {}
    State = {
        index: State<number>? -- whether the widget is collapsed.
    }
    ```
    state: Types.State<number>?
]=]
API.TabBar = function(state: Types.State<number>?)
    return Internal._insert("TabBar", state) :: Tab.TabBar
end

--[=[
    @within Tab
    @function Tab
    @return Tab
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    The tab item for use under a TabBar. The TabBar must be the parent and determines the index value. You cannot
    provide a state for this tab. The optional Hideable argument determines if a tab can be closed, which is
    controlled by the isOpened state.

    A tab will take up the full horizontal width of the parent and hide any other tabs in the TabBar.
    
    ```lua
    hasChildren: true
    hasState: true
    Arguments = {
        Text: string,
        Hideable: boolean? = nil -- determines whether a tab can be closed/hidden
    }
    Events = {
        clicked: () -> boolean,
        hovered: () -> boolean
        selected: () -> boolean
        unselected: () -> boolean
        active: () -> boolean
        opened: () -> boolean
        closed: () -> boolean
    }
    State = {
        isOpened: State<boolean>?
    }
    ```
    @param text string
    @param flags number?
    @param open Types.State<boolean>?

]=]
API.Tab = function(text: string, flags: number?, open: Types.State<boolean>?)
    return Internal._insert("Tab", text, flags, open) :: Tab.Tab
end

--[[
    ----------------------------------
        [SECTION] Input Widget API
    ----------------------------------
]]
--[=[
    @class Input
    Input Widget API

    Input Widgets are textboxes for typing in specific number values. See [Drag], [Slider] or [InputText](Text#InputText) for more input types.

    Iris provides a set of specific inputs for the datatypes:
    Number,
    [Vector2](https://create.roblox.com/docs/reference/engine/datatypes/Vector2),
    [Vector3](https://create.roblox.com/docs/reference/engine/datatypes/Vector3),
    [UDim](https://create.roblox.com/docs/reference/engine/datatypes/UDim),
    [UDim2](https://create.roblox.com/docs/reference/engine/datatypes/UDim2),
    [Rect](https://create.roblox.com/docs/reference/engine/datatypes/Rect),
    [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)
    and the custom [Color4](https://create.roblox.com/docs/reference/engine/datatypes/Color3).
    
    Each Input widget has the same arguments but the types depend of the DataType:
    1. Text: string? = "Input{type}" -- the text to be displayed to the right of the textbox.
    2. Increment: DataType? = nil, -- the increment argument determines how a value will be rounded once the textbox looses focus.
    3. Min: DataType? = nil, -- the minimum value that the widget will allow, no clamping by default.
    4. Max: DataType? = nil, -- the maximum value that the widget will allow, no clamping by default.
    5. Format: string | { string }? = [DYNAMIC] -- uses `string.format` to customise visual display.

    The format string can either by a single value which will apply to every box, or a table allowing specific text.

    :::note
    If you do not specify a format option then Iris will dynamically calculate a relevant number of sigifs and format option.
    For example, if you have Increment, Min and Max values of 1, 0 and 100, then Iris will guess that you are only using integers
    and will format the value as an integer.
    As another example, if you have Increment, Min and max values of 0.005, 0, 1, then Iris will guess you are using a float of 3
    significant figures.

    Additionally, for certain DataTypes, Iris will append an prefix to each box if no format option is provided.
    For example, a Vector3 box will have the append values of "X: ", "Y: " and "Z: " to the relevant input box.
    :::
]=]

--[=[
    @within Input
    @function InputNum
    @return InputNum
    @tag Widget
    @tag HasState
    
    An input box for numbers. The number can be either an integer or a float.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputNum",
        Increment: number? = nil,
        Min: number? = nil,
        Max: number? = nil,
        Format: string? | { string }? = [DYNAMIC], -- Iris will dynamically generate an approriate format.
        NoButtons: boolean? = false -- whether to display + and - buttons next to the input box.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<number>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment number?
    @param min number?
    @param max number?
    @param format string? | { string }?
    @param value Types.State<number>?
    @param editing Types.State<boolean>?

]=]
API.InputNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Internal._insert("InputNum", text, increment, min, max, format, value, editing) :: Input.Input<number>
end

--[=[
    @within Input
    @function InputVector2
    @return InputVector2
    @tag Widget
    @tag HasState
    
    An input box for Vector2. The numbers can be either integers or floats.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputVector2",
        Increment: Vector2? = nil,
        Min: Vector2? = nil,
        Max: Vector2? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector2?
    @param min Vector2?
    @param max Vector2?
    @param format string? | { string }?
    @param value Types.State<Vector2>?
    @param editing Types.State<boolean>?

]=]
API.InputVector2 = function(text: string, increment: Vector2?, min: Vector2?, max: Vector2?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Internal._insert("InputVector2", text, increment, min, max, format, value, editing) :: Input.Input<Vector2>
end

--[=[
    @within Input
    @function InputVector3
    @return InputVector3
    @tag Widget
    @tag HasState
    
    An input box for Vector3. The numbers can be either integers or floats.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputVector3",
        Increment: Vector3? = nil,
        Min: Vector3? = nil,
        Max: Vector3? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector3>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector3?
    @param min Vector3?
    @param max Vector3?
    @param format string? | { string }?
    @param value Types.State<Vector3>?
    @param editing Types.State<boolean>?

]=]
API.InputVector3 = function(text: string, increment: Vector3?, min: Vector3?, max: Vector3?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Internal._insert("InputVector3", text, increment, min, max, format, value, editing) :: Input.Input<Vector3>
end

--[=[
    @within Input
    @function InputUDim
    @return InputUDim
    @tag Widget
    @tag HasState
    
    An input box for UDim. The Scale box will be a float and the Offset box will be
    an integer, unless specified differently.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputUDim",
        Increment: UDim? = nil,
        Min: UDim? = nil,
        Max: UDim? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim?
    @param min UDim?
    @param max UDim?
    @param format string? | { string }?
    @param value Types.State<UDim>?
    @param editing Types.State<boolean>?

]=]
API.InputUDim = function(text: string, increment: UDim?, min: UDim?, max: UDim?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Internal._insert("InputUDim", text, increment, min, max, format, value, editing) :: Input.Input<UDim>
end

--[=[
    @within Input
    @function InputUDim2
    @return InputUDim2
    @tag Widget
    @tag HasState
    
    An input box for UDim2. The Scale boxes will be floats and the Offset boxes will be
    integers, unless specified differently.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputUDim2",
        Increment: UDim2? = nil,
        Min: UDim2? = nil,
        Max: UDim2? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim2?
    @param min UDim2?
    @param max UDim2?
    @param format string? | { string }?
    @param value Types.State<UDim2>?
    @param editing Types.State<boolean>?

]=]
API.InputUDim2 = function(text: string, increment: UDim2?, min: UDim2?, max: UDim2?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Internal._insert("InputUDim2", text, increment, min, max, format, value, editing) :: Input.Input<UDim2>
end

--[=[
    @within Input
    @function InputRect
    @return InputRect
    @tag Widget
    @tag HasState
    
    An input box for Rect. The numbers will default to integers, unless specified differently.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputRect",
        Increment: Rect? = nil,
        Min: Rect? = nil,
        Max: Rect? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Rect>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Rect?
    @param min Rect?
    @param max Rect?
    @param format string? | { string }?
    @param value Types.State<Rect>?
    @param editing Types.State<boolean>?

]=]
API.InputRect = function(text: string, increment: Rect?, min: Rect?, max: Rect?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Internal._insert("InputRect", text, increment, min, max, format, value, editing) :: Input.Input<Rect>
end

--[[
    ---------------------------------
        [SECTION] Drag Widget API
    ---------------------------------
]]
--[=[
    @class Drag
    Drag Widget API

    A draggable widget for each datatype. Allows direct typing input but also dragging values by clicking and holding.
    
    See [Input] for more details on the arguments.
]=]

--[=[
    @within Drag
    @function DragNum
    @return DragNum
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a number.
    You can ctrl + click to directly input a number, like InputNum.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragNum",
        Increment: number? = nil,
        Min: number? = nil,
        Max: number? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<number>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment number?
    @param min number?
    @param max number?
    @param format string? | { string }?
    @param value Types.State<number>?
    @param editing Types.State<boolean>?

]=]
API.DragNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Internal._insert("DragNum", text, increment, min, max, format, value, editing) :: Input.Input<number>
end

--[=[
    @within Drag
    @function DragVector2
    @return DragVector2
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a Vector2.
    You can ctrl + click to directly input a Vector2, like InputVector2.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragVector2",
        Increment: Vector2? = nil,
        Min: Vector2? = nil,
        Max: Vector2? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector2?
    @param min Vector2?
    @param max Vector2?
    @param format string? | { string }?
    @param value Types.State<Vector2>?
    @param editing Types.State<boolean>?

]=]
API.DragVector2 = function(text: string, increment: Vector2?, min: Vector2?, max: Vector2?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Internal._insert("DragVector2", text, increment, min, max, format, value, editing) :: Input.Input<Vector2>
end

--[=[
    @within Drag
    @function DragVector3
    @return DragVector3
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a Vector3.
    You can ctrl + click to directly input a Vector3, like InputVector3.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragVector3",
        Increment: Vector3? = nil,
        Min: Vector3? = nil,
        Max: Vector3? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector3>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector3?
    @param min Vector3?
    @param max Vector3?
    @param format string? | { string }?
    @param value Types.State<Vector3>?
    @param editing Types.State<boolean>?

]=]
API.DragVector3 = function(text: string, increment: Vector3?, min: Vector3?, max: Vector3?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Internal._insert("DragVector3", text, increment, min, max, format, value, editing) :: Input.Input<Vector3>
end

--[=[
    @within Drag
    @function DragUDim
    @return DragUDim
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a UDim.
    You can ctrl + click to directly input a UDim, like InputUDim.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragUDim",
        Increment: UDim? = nil,
        Min: UDim? = nil,
        Max: UDim? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim?
    @param min UDim?
    @param max UDim?
    @param format string? | { string }?
    @param value Types.State<UDim>?
    @param editing Types.State<boolean>?

]=]
API.DragUDim = function(text: string, increment: UDim?, min: UDim?, max: UDim?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Internal._insert("DragUDim", text, increment, min, max, format, value, editing) :: Input.Input<UDim>
end

--[=[
    @within Drag
    @function DragUDim2
    @return DragUDim2
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a UDim2.
    You can ctrl + click to directly input a UDim2, like InputUDim2.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragUDim2",
        Increment: UDim2? = nil,
        Min: UDim2? = nil,
        Max: UDim2? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim2?
    @param min UDim2?
    @param max UDim2?
    @param format string? | { string }?
    @param value Types.State<UDim2>?
    @param editing Types.State<boolean>?

]=]
API.DragUDim2 = function(text: string, increment: UDim2?, min: UDim2?, max: UDim2?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Internal._insert("DragUDim2", text, increment, min, max, format, value, editing) :: Input.Input<UDim2>
end

--[=[
    @within Drag
    @function DragRect
    @return DragRect
    @tag Widget
    @tag HasState
    
    A field which allows the user to click and drag their cursor to enter a Rect.
    You can ctrl + click to directly input a Rect, like InputRect.
    You can hold Shift to increase speed, and Alt to decrease speed when dragging.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "DragRect",
        Increment: Rect? = nil,
        Min: Rect? = nil,
        Max: Rect? = nil,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Rect>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Rect?
    @param min Rect?
    @param max Rect?
    @param format string? | { string }?
    @param value Types.State<Rect>?
    @param editing Types.State<boolean>?

]=]
API.DragRect = function(text: string, increment: Rect?, min: Rect?, max: Rect?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Internal._insert("DragRect", text, increment, min, max, format, value, editing) :: Input.Input<Rect>
end

--[=[
    @within Input
    @function InputColor3
    @return InputColor3
    @tag Widget
    @tag HasState
    
    An input box for Color3. The input boxes are draggable between 0 and 255 or if UseFloats then between 0 and 1.
    Input can also be done using HSV instead of the default RGB.
    If no format argument is provided then a default R, G, B or H, S, V prefix is applied.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputColor3",
        UseFloats: boolean? = false, -- constrain the values between floats 0 and 1 or integers 0 and 255.
        UseHSV: boolean? = false, -- input using HSV instead.
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        color: State<Color3>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param flags number?
    @param format string? | { string }?
    @param color Types.State<Color3>?
    @param editing Types.State<boolean>?

]=]
API.InputColor3 = function(text: string, flags: number?, format: string? | { string }?, color: Types.State<Color3>?, editing: Types.State<boolean>?)
    return Internal._insert("InputColor3", text, flags or 0, format, color, editing) :: Input.InputColor3
end

--[=[
    @within Input
    @function InputColor4
    @return InputColor4
    @tag Widget
    @tag HasState
    
    An input box for Color4. Color4 is a combination of Color3 and a fourth transparency argument.
    It has two states for this purpose.
    The input boxes are draggable between 0 and 255 or if UseFloats then between 0 and 1.
    Input can also be done using HSV instead of the default RGB.
    If no format argument is provided then a default R, G, B, T or H, S, V, T prefix is applied.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputColor4",
        UseFloats: boolean? = false, -- constrain the values between floats 0 and 1 or integers 0 and 255.
        UseHSV: boolean? = false, -- input using HSV instead.
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        color: State<Color3>?,
        transparency: State<number>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param flags number?
    @param format string? | { string }?
    @param color Types.State<Color3>?
    @param transparency Types.State<number>?
    @param editing Types.State<boolean>?

]=]
API.InputColor4 = function(text: string, flags: number?, format: string? | { string }?, color: Types.State<Color3>?, transparency: Types.State<number>?, editing: Types.State<boolean>?)
    return Internal._insert("InputColor4", text, flags or 0, format, color, transparency, editing) :: Input.InputColor4
end

--[[
    -----------------------------------
        [SECTION] Slider Widget API
    -----------------------------------
]]
--[=[
    @class Slider
    Slider Widget API

    A draggable widget with a visual bar constrained between a min and max for each datatype.
    Allows direct typing input but also dragging the slider by clicking and holding anywhere in the box.
    
    See [Input] for more details on the arguments.
]=]

--[=[
    @within Slider
    @function SliderNum
    @return SliderNum
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a number within a range.
    You can ctrl + click to directly input a number, like InputNum.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderNum",
        Increment: number? = 1,
        Min: number? = 0,
        Max: number? = 100,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<number>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment number?
    @param min number?
    @param max number?
    @param format string? | { string }?
    @param value Types.State<number>?
    @param editing Types.State<boolean>?

]=]
API.SliderNum = function(text: string, increment: number?, min: number?, max: number?, format: string? | { string }?, value: Types.State<number>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderNum", text, increment, min, max, format, value, editing) :: Input.Input<number>
end

--[=[
    @within Slider
    @function SliderVector2
    @return SliderVector2
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a Vector2 within a range.
    You can ctrl + click to directly input a Vector2, like InputVector2.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderVector2",
        Increment: Vector2? = { 1, 1 },
        Min: Vector2? = { 0, 0 },
        Max: Vector2? = { 100, 100 },
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector2?
    @param min Vector2?
    @param max Vector2?
    @param format string? | { string }?
    @param value Types.State<Vector2>?
    @param editing Types.State<boolean>?

]=]
API.SliderVector2 = function(text: string, increment: Vector2?, min: Vector2?, max: Vector2?, format: string? | { string }?, value: Types.State<Vector2>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderVector2", text, increment, min, max, format, value, editing) :: Input.Input<Vector2>
end

--[=[
    @within Slider
    @function SliderVector3
    @return SliderVector3
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a Vector3 within a range.
    You can ctrl + click to directly input a Vector3, like InputVector3.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderVector3",
        Increment: Vector3? = { 1, 1, 1 },
        Min: Vector3? = { 0, 0, 0 },
        Max: Vector3? = { 100, 100, 100 },
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Vector3>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Vector3?
    @param min Vector3?
    @param max Vector3?
    @param format string? | { string }?
    @param value Types.State<Vector3>?
    @param editing Types.State<boolean>?

]=]
API.SliderVector3 = function(text: string, increment: Vector3?, min: Vector3?, max: Vector3?, format: string? | { string }?, value: Types.State<Vector3>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderVector3", text, increment, min, max, format, value, editing) :: Input.Input<Vector3>
end

--[=[
    @within Slider
    @function SliderUDim
    @return SliderUDim
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a UDim within a range.
    You can ctrl + click to directly input a UDim, like InputUDim.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderUDim",
        Increment: UDim? = { 0.01, 1 },
        Min: UDim? = { 0, 0 },
        Max: UDim? = { 1, 960 },
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim?
    @param min UDim?
    @param max UDim?
    @param format string? | { string }?
    @param value Types.State<UDim>?
    @param editing Types.State<boolean>?

]=]
API.SliderUDim = function(text: string, increment: UDim?, min: UDim?, max: UDim?, format: string? | { string }?, value: Types.State<UDim>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderUDim", text, increment, min, max, format, value, editing) :: Input.Input<UDim>
end

--[=[
    @within Slider
    @function SliderUDim2
    @return SliderUDim2
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a UDim2 within a range.
    You can ctrl + click to directly input a UDim2, like InputUDim2.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderUDim2",
        Increment: UDim2? = { 0.01, 1, 0.01, 1 },
        Min: UDim2? = { 0, 0, 0, 0 },
        Max: UDim2? = { 1, 960, 1, 960 },
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<UDim2>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment UDim2?
    @param min UDim2?
    @param max UDim2?
    @param format string? | { string }?
    @param value Types.State<UDim2>?
    @param editing Types.State<boolean>?

]=]
API.SliderUDim2 = function(text: string, increment: UDim2?, min: UDim2?, max: UDim2?, format: string? | { string }?, value: Types.State<UDim2>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderUDim2", text, increment, min, max, format, value, editing) :: Input.Input<UDim2>
end

--[=[
    @within Slider
    @function SliderRect
    @return SliderRect
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a Rect within a range.
    You can ctrl + click to directly input a Rect, like InputRect.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "SliderRect",
        Increment: Rect? = { 1, 1, 1, 1 },
        Min: Rect? = { 0, 0, 0, 0 },
        Max: Rect? = { 960, 960, 960, 960 },
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<Rect>?,
        editingText: State<boolean>?
    }
    ```
    @param text string
    @param increment Rect?
    @param min Rect?
    @param max Rect?
    @param format string? | { string }?
    @param value Types.State<Rect>?
    @param editing Types.State<boolean>?

]=]
API.SliderRect = function(text: string, increment: Rect?, min: Rect?, max: Rect?, format: string? | { string }?, value: Types.State<Rect>?, editing: Types.State<boolean>?)
    return Internal._insert("SliderRect", text, increment, min, max, format, value, editing) :: Input.Input<Rect>
end

--[[
    ----------------------------------
        [SECTION] Combo Widget API
    ----------------------------------
]]
--[=[
    @class Combo
    Combo Widget API
]=]

--[=[
    @within Combo
    @function Selectable
    @return Selectable
    @tag Widget
    @tag HasState
    
    An object which can be selected.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string,
        Index: any, -- index of selectable value.
        NoClick: boolean? = false -- prevents the selectable from being clicked by the user.
    }
    Events = {
        selected: () -> boolean,
        unselected: () -> boolean,
        active: () -> boolean,
        clicked: () -> boolean,
        rightClicked: () -> boolean,
        doubleClicked: () -> boolean,
        ctrlClicked: () -> boolean,
        hovered: () -> boolean,
    }
    States = {
        index: State<any> -- a shared state between all selectables.
    }
    ```
    @param text string
    @param index any
    @param flags number?
    @param state Types.State<any>?

]=]
API.Selectable = function(text: string, index: any, flags: number?, state: Types.State<any>?)
    return Internal._insert("Selectable", text, index, flags or 0, state) :: Combo.Selectable
end

--[=[
    @within Combo
    @function Combo
    @return Combo
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    A dropdown menu box to make a selection from a list of values.
    
    ```lua
    hasChildren = true
    hasState = true
    Arguments = {
        Text: string,
        NoButton: boolean? = false, -- hide the dropdown button.
        NoPreview: boolean? = false -- hide the preview field.
    }
    Events = {
        opened: () -> boolean,
        closed: () -> boolean,
        changed: () -> boolean,
        clicked: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        index: State<any>,
        isOpened: State<boolean>?
    }
    ```
    @param text string
    @param flags number?
    @param state Types.State<any>?
    @param open Types.State<boolean>?

]=]
API.Combo = function(text: string, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    return Internal._insert("Combo", text, flags or 0, state, open) :: Combo.Combo
end

--[=[
    @within Combo
    @function ComboArray
    @return ComboArray
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    A selection box to choose a value from an array.
    
    ```lua
    hasChildren = true
    hasState = true
    Arguments = {
        Text: string,
        NoButton: boolean? = false, -- hide the dropdown button.
        NoPreview: boolean? = false -- hide the preview field.
    }
    Events = {
        opened: () -> boolean,
        closed: () -> boolean,
        clicked: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        index: State<any>,
        isOpened: State<boolean>?
    }
    Extra = {
        selectionArray: { any } -- the array to generate a combo from.
    }
    ```
    @param T(text: string
    @param array { any }
    @param flags number?
    @param state Types.State<any>?
    @param open Types.State<boolean>?

]=]
API.ComboArray = function<T>(text: string, array: { any }, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    local thisWidget = Internal._insert("Combo", text, flags or 0, state, open) :: Combo.Combo
    local sharedIndex = thisWidget.state.index
    for _, Selection in array do
        Internal._insert("Selectable", tostring(Selection), Selection, flags or 0, sharedIndex)
    end
    API.End()

    return thisWidget
end

--[=[
    @within Combo
    @function ComboEnum
    @return ComboEnum
    @tag Widget
    @tag HasChildren
    @tag HasState
    
    A selection box to choose a value from an Enum.
    
    ```lua
    hasChildren = true
    hasState = true
    Arguments = {
        Text: string,
        NoButton: boolean? = false, -- hide the dropdown button.
        NoPreview: boolean? = false -- hide the preview field.
    }
    Events = {
        opened: () -> boolean,
        closed: () -> boolean,
        clicked: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        index: State<any>,
        isOpened: State<boolean>?
    }
    Extra = {
        enumType: Enum -- the enum to generate a combo from.
    }
    ```
    @param text string
    @param enum Enum
    @param flags number?
    @param state Types.State<any>?
    @param open Types.State<boolean>?

]=]
API.ComboEnum = function(text: string, enum: Enum, flags: number?, state: Types.State<any>?, open: Types.State<boolean>?)
    local thisWidget = Internal._insert("Combo", text, flags or 0, state, open)
    local sharedIndex = thisWidget.state.index
    for _, selection: EnumItem in enum:GetEnumItems() do
        Internal._insert("Selectable", selection.Name, selection, flags or 0, sharedIndex)
    end
    API.End()

    return thisWidget
end

--[=[
    @private
    @within Slider
    @function InputEnum
    @return InputEnum
    @tag Widget
    @tag HasState
    
    A field which allows the user to slide a grip to enter a number within a range.
    You can ctrl + click to directly input a number, like InputNum.
    
    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "InputEnum",
        Increment: number? = 1,
        Min: number? = 0,
        Max: number? = 100,
        Format: string? | { string }? = [DYNAMIC] -- Iris will dynamically generate an approriate format.
    }
    Events = {
        numberChanged: () -> boolean,
        hovered: () -> boolean
    }
    States = {
        number: State<number>?,
        editingText: State<boolean>?,
        enumItem: EnumItem
    }
    ```
]=]
API.InputEnum = API.ComboEnum

--[[
    ---------------------------------
        [SECTION] Plot Widget API
    ---------------------------------
]]
--[=[
    @class Plot
    Plot Widget API
]=]

--[=[
    @within Plot
    @function ProgressBar
    @return ProgressBar
    @tag Widget
    @tag HasState

    A progress bar line with a state value to show the current state.

    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "Progress Bar",
        Format: string? = nil -- optional to override with a custom progress such as `29/54`
    }
    Events = {
        hovered: () -> boolean,
        changed: () -> boolean
    }
    States = {
        progress: State<number>?
    }
    ```
    @param text string?
    @param format string?
    @param progress Types.State<number>?

]=]
API.ProgressBar = function(text: string?, format: string?, progress: Types.State<number>?)
    return Internal._insert("ProgressBar", text, format, progress) :: Plot.ProgressBar
end

--[=[
    @within Plot
    @function PlotLines
    @return PlotLines
    @tag Widget
    @tag HasState

    A line graph for plotting a single line. Includes hovering to see a specific value on the graph,
    and automatic scaling. Has an overlay text option at the top of the plot for displaying any
    information.

    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "Plot Lines",
        Height: number? = 0,
        Min: number? = min, -- Iris will use the minimum value from the values
        Max: number? = max, -- Iris will use the maximum value from the values
        TextOverlay: string? = ""
    }
    Events = {
        hovered: () -> boolean
    }
    States = {
        values: State<{number}>?,
        hovered: State<{number}>? -- read-only functionert
    }
    ```
    @param text string?
    @param height number?
    @param min number?
    @param max number?
    @param textOverlay string?
    @param values Types.State<number>?
    @param hovered Types.State<number>?

]=]
API.PlotLines = function(text: string?, height: number?, min: number?, max: number?, textOverlay: string?, values: Types.State<number>?, hovered: Types.State<number>?)
    return Internal._insert("PlotLines", text, height, min, max, textOverlay, values, hovered) :: Plot.PlotLines
end

--[=[
    @within Plot
    @function PlotHistogram
    @return PlotHistogram
    @tag Widget
    @tag HasState

    A hisogram graph for showing values. Includes hovering to see a specific block on the graph,
    and automatic scaling. Has an overlay text option at the top of the plot for displaying any
    information. Also supports a baseline option, which determines where the blocks start from.

    ```lua
    hasChildren = false
    hasState = true
    Arguments = {
        Text: string? = "Plot Histogram",
        Height: number? = 0,
        Min: number? = min, -- Iris will use the minimum value from the values
        Max: number? = max, -- Iris will use the maximum value from the values
        TextOverlay: string? = "",
        BaseLine: number? = 0 -- by default, blocks swap side at 0
    }
    Events = {
        hovered: () -> boolean
    }
    States = {
        values: State<{number}>?,
        hovered: State<{number}>? -- read-only functionert
    }
    ```
    @param text string?
    @param height number?
    @param min number?
    @param max number?
    @param textOverlay string?
    @param baseline number?
    @param values Types.State<number>?
    @param hovered Types.State<number>?

]=]
API.PlotHistogram = function(text: string?, height: number?, min: number?, max: number?, textOverlay: string?, baseline: number?, values: Types.State<number>?, hovered: Types.State<number>?)
    return Internal._insert("PlotHistogram", text, height, min, max, textOverlay, baseline, values, hovered) :: Plot.PlotHistogram
end

--[[
    ----------------------------------
        [SECTION] Table Widget API
    ----------------------------------
]]
--[=[
    @class Table
    Table Widget API

    Example usage for creating a simple table:
    ```lua
    Iris.Table({ 4, true })
    do
        Iris.SetHeaderColumnIndex(1)

        -- for each row
        for i = 0, 10 do

            -- for each column
            for j = 1, 4 do
                if i == 0 then
                    -- 
                    Iris.Text({ `H: {j}` })
                else
                    Iris.Text({ `R: {i}, C: {j}` })
                end

                -- move the next column (and row when necessary)
                Iris.NextColumn()
            end
        end
    ```
]=]

--[=[
    @within Table
    @function Table
    @return Table
    @tag Widget
    @tag HasChildren
    
    A layout widget which allows children to be displayed in configurable columns and rows. Highly configurable for many different
    options, with options for custom width columns as configured by the user, or automatically use the best size.

    When Resizable is enabled, the vertical columns can be dragged horizontally to increase or decrease space. This is linked to
    the widths state, which controls the width of each column. This is also dependent on whether the FixedWidth argument is enabled.
    By default, the columns will scale with the width of the table overall, therefore taking up a percentage, and the widths will be
    in the range of 0 to 1 as a float. If FixedWidth is enabled, then the widths will be in pixels and have a value of > 2 as an
    integer.

    ProportionalWidth determines whether each column has the same width, or individual. By default, each column will take up an equal
    functionortion
    meaning wider columns take up a greater share of the total available space. For a fixed width table, by default each column will
    take the max width of all the columns. When true, each column width will the minimum to fit the children within.

    LimitTableWidth is used when FixedWidth is true. It will cut off the table horizontally after the last column.

    :::info
    Once the NumColumns is set, it is not possible to change it without some extra code. The best way to do this is by using
    `Iris.PushConfig()` and `Iris.PopConfig()` which will automatically redraw the widget when the columns change.

    ```lua
    local numColumns = 4
    Iris.PushConfig({ columns = numColumns })
    Iris.Table({ numColumns, ...})
    do
        ...
    end
    Iris.End()
    Iris.PopConfig()
    ```

    :::danger Error: nil
    Always ensure that the number of elements in the widths state is greater or equal to the
    new number of columns when changing the number of columns.
    :::
    :::
    
    ```lua
    hasChildren = true
    hasState = false
    Arguments = {
        NumColumns: number, -- number of columns in the table, cannot be changed
        Header: boolean? = false, -- display a header row for each column
        RowBackground: boolean? = false, -- alternating row background colours
        OuterBorders: boolean? = false, -- outer border on the entire table
        InnerBorders: boolean? = false, -- inner bordres on the entire table
        Resizable: boolean? = false, -- the columns can be resized by dragging or state
        FixedWidth: boolean? = false, -- columns takes up a fixed pixel width, rather than a functionortion
        ProportionalWidth: boolean? = false, -- minimises the width of each column individually
        LimitTableWidth: boolean? = false, -- when a fixed width, cut of any unused space
    }
    Events = {
        hovered: () -> boolean
    }
    States = {
        widths: State<{ number }>? -- the widths of each column if Resizable
    }
    ```
    @param numColumns number
    @param flags number?
    @param widths Types.State<{ number }>?

]=]
API.Table = function(numColumns: number, flags: number?, widths: Types.State<{ number }>?)
    return Internal._insert("Table", numColumns, flags, widths) :: Table.Table
end

--[=[
    @within Table
    @function NextColumn
    
    In a table, moves to the next available cell. If the current cell is in the last column,
    then moves to the cell in the first column of the next row.
]=]
API.NextColumn = function()
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.NextColumn() can only called when directly within a table.")

    local columnIndex = thisWidget._columnIndex
    if columnIndex == thisWidget.arguments.NumColumns then
        thisWidget._columnIndex = 1
        thisWidget._rowIndex += 1
    else
        thisWidget._columnIndex += 1
    end
    return thisWidget._columnIndex
end

--[=[
    @within Table
    @function NextRow
    
    In a table, moves to the cell in the first column of the next row.
]=]
API.NextRow = function()
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.NextRow() can only called when directly within a table.")
    thisWidget._columnIndex = 1
    thisWidget._rowIndex += 1
    return thisWidget._rowIndex
end

--[=[
    @within Table
    @function SetColumnIndex
    @param index number
    
    In a table, moves to the cell in the given column in the same previous row.

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
API.SetColumnIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.SetColumnIndex() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)
    thisWidget._columnIndex = index
end

--[=[
    @within Table
    @function SetRowIndex
    @param index number

    In a table, moves to the cell in the given row with the same previous column.
]=]
API.SetRowIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.SetRowIndex() can only called when directly within a table.")
    assert(index >= 1, "The index must be greater or equal to 1.")
    thisWidget._rowIndex = index
end

--[=[
    @within Table
    @function NextHeaderColumn

    In a table, moves to the cell in the next column in the header row (row index 0). Will loop around
    from the last column to the first.
]=]
API.NextHeaderColumn = function()
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.NextHeaderColumn() can only called when directly within a table.")

    thisWidget._rowIndex = 0
    thisWidget._columnIndex = (thisWidget._columnIndex % thisWidget.arguments.NumColumns) + 1

    return thisWidget._columnIndex
end

--[=[
    @within Table
    @function SetHeaderColumnIndex
    @param index number

    In a table, moves to the cell in the given column in the header row (row index 0).

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
API.SetHeaderColumnIndex = function(index: number)
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.SetHeaderColumnIndex() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)

    thisWidget._rowIndex = 0
    thisWidget._columnIndex = index
end

--[=[
    @within Table
    @function SetColumnWidth
    @param index number
    @param width number

    In a table, sets the width of the given column to the given value by changing the
    Table's widths state. When the FixedWidth argument is true, the width should be in
    pixels >2, otherwise as a float between 0 and 1.

    Will erorr if the given index is not in the range of 1 to NumColumns.
]=]
API.SetColumnWidth = function(index: number, width: number)
    local thisWidget = Internal._getParentWidget() :: Table.Table
    assert(thisWidget ~= nil, "Iris.SetColumnWidth() can only called when directly within a table.")
    assert((index >= 1) and (index <= thisWidget.arguments.NumColumns), `The index must be between 1 and {thisWidget.arguments.NumColumns}, inclusive.`)

    local oldValue = thisWidget.state.widths.value[index]
    thisWidget.state.widths.value[index] = width
    thisWidget.state.widths:set(thisWidget.state.widths.value, width ~= oldValue)
end

return API
