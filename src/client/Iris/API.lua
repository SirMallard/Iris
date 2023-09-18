local Types = require(script.Parent.Types)

return function(Iris: Types.Iris)
    -- basic wrapper for nearly every widget, saves space.
    local function wrapper(name: string): (arguments: Types.WidgetArguments?, states: Types.States?) -> Types.Widget
        return function(arguments: Types.WidgetArguments?, states: Types.States?): Types.Widget
            return Iris.Internal._Insert(name, arguments, states)
        end
    end

    --[[
        ----------------------------
            [SECTION] Window API
        ----------------------------
    ]]
    --[=[
        @class Window
        
        Windows are the fundamental widget for Iris. Every other widget must be a descendant of a window.

        ```lua
        Iris.Window({ "Example Window" })
            Iris.Text({ "This is an example window!" })
        Iris.End()
        ```

        If you do not want the code inside a window to run unless it is open then you can use the following:
        ```lua
        local window = Iris.Window({ "Many Widgets Window" })

        if window.state.isOpened.value and window.state.isUncollapsed.value then
            Iris.Text({ "I will only be created when the window is open." })
        end
        Iris.End() -- must always call Iris.End(), regardless of whether the window is open or not.
        ```
    ]=]

    --[=[
        @prop Window Iris.Window
        @within Window
        @tag Widget
        @tag HasChildren
        @tag HasState
        
        The top-level container for all other widgets to be created within.
        Can be moved and resized across the screen. Cannot contain embedded windows.
        Menus can be appended to windows creating a menubar.
        
        ```lua
        hasChildren = true
        hasState = true
        Arguments = {
            Title: string,
            NoTitleBar: boolean? = false,
            NoBackground: boolean? = false, -- the background behind the widget container.
            NoCollapse: boolean? = false,
            NoClose: boolean? = false,
            NoMove: boolean? = false,
            NoScrollbar: boolean? = false, -- the scrollbar if the window is too short for all widgets.
            NoResize: boolean? = false,
            NoNav: boolean? = false, -- unimplemented.
            NoMenu: boolean? -- whether the menubar will show if created.
        }
        Events = {
            opened: () -> boolean, -- once when opened.
            closed: () -> boolean, -- once when closed.
            collapsed: () -> boolean, -- once when collapsed.
            uncollapsed: () -> boolean, -- once when uncollapsed.
            hovered: () -> boolean -- fires when the mouse hovers over any of the window.
        }
        States = {
            size = State<Vector2>?,
            position = State<Vector2>?,
            isUncollapsed = State<boolean>?,
            isOpened = State<boolean>?,
            scrollDistance = State<number>? -- vertical scroll distance, if too short.
        }
        ```
    ]=]
    Iris.Window = wrapper("Window")

    --[=[
        @function SetFocusedWindow
        @within Iris
        @param window Types.Widget -- the window to focus.

        Sets the focused window to the window provided, which brings it to the front and makes it active.
    ]=]
    Iris.SetFocusedWindow = Iris.Internal.SetFocusedWindow

    --[=[
        @prop Tooltip Iris.Tooltip
        @within Window
        @tag Widget

        Displays a text label next to the cursor
        
        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string
        }
        ```
    ]=]
    Iris.Tooltip = wrapper("Tooltip")

    --[[
        ---------------------------------
            [SECTION] Menu Widget API
        ---------------------------------
    ]]
    --[=[
        @class Menu
        Menu API
    ]=]

    --[=[
        @prop MenuBar Iris.MenuBar
        @within Menu
        @tag Widget
        @tag HasChildren
        
        Creates a MenuBar for the current window. Must be called directly under a Window and not within a child widget.
        :::info
            This does not create any menus, just tells the window that we going to add menus within.
        :::
        
        ```lua
        hasChildren = true
        hasState = false
        ```
    ]=]
    Iris.MenuBar = wrapper("MenuBar")

    --[=[
        @prop Menu Iris.Menu
        @within Menu
        @tag Widget
        @tag HasChildren
        @tag HasState
        
        Creates an collapsable menu. If the Menu is created directly under a MenuBar, then the widget will
        be placed horizontally below the window title. If the menu Menu is created within another menu, then
        it will be placed vertically alongside MenuItems and display an arrow alongside.

        The opened menu will be a vertically listed box below or next to the button.

        :::info
        There are widgets which are designed for being parented to a menu whilst other happens to work. There is nothing
        preventing you from adding any widget as a child, but the behaviour is unexplained and not intended, despite allowed.
        :::
        
        ```lua
        hasChildren = true
        hasState = true
        Arguments = {
            Text: string -- menu text.
        }
        Events = {
            clicked: () -> boolean,
            opened: () -> boolean, -- once when opened.
            closed: () -> boolean, -- once when closed.
            hovered: () -> boolean
        }
        States = {
            isOpened: State<boolean>? -- whether the menu is open, including any sub-menus within.
        }
        ```
    ]=]
    Iris.Menu = wrapper("Menu")

    --[=[
        @prop MenuItem Iris.MenuItem
        @within Menu
        @tag Widget
        
        Creates a button within a menu. The optional KeyCode and ModiferKey arguments will show the keys next
        to the title, but **will not** bind any connection to them. You will need to do this yourself.
        
        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
            KeyCode: Enum.KeyCode? = nil, -- an optional keycode, does not actually connect an event.
            ModifierKey: Enum.ModifierKey? = nil -- an optional modifer key for the key code.
        }
        Events = {
            clicked: () -> boolean,
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.MenuItem = wrapper("MenuItem")

    --[=[
        @prop MenuToggle Iris.MenuToggle
        @within Menu
        @tag Widget
        @tag HasState
        
        Creates a togglable button within a menu. The optional KeyCode and ModiferKey arguments act the same
        as the MenuItem. It is not visually the same as a checkbox, but has the same functionality.
        
        ```lua
        hasChildren = false
        hasState = true
        Arguments = {
            Text: string,
            KeyCode: Enum.KeyCode? = nil, -- an optional keycode, does not actually connect an event.
            ModifierKey: Enum.ModifierKey? = nil -- an optional modifer key for the key code.
        }
        Events = {
            checked: () -> boolean, -- once on check.
            unchecked: () -> boolean, -- once on uncheck.
            hovered: () -> boolean
        }
        States = {
            isChecked: State<boolean>?
        }
        ```
    ]=]
    Iris.MenuToggle = wrapper("MenuToggle")

    --[[
        -----------------------------------
            [SECTION] Format Widget Iris
        -----------------------------------
    ]]
    --[=[
        @class Format
        Format API
    ]=]

    --[=[
        @prop Separator Iris.Separator
        @within Format
        @tag Widget

        A vertical or horizonal line, depending on the context, which visually seperates widgets.
        
        ```lua
        hasChildren = false
        hasState = false
        ```
    ]=]
    Iris.Separator = wrapper("Separator")

    --[=[
        @prop Indent Iris.Indent
        @within Format
        @tag Widget
        @tag HasChildren
        
        Indents its child widgets.
        
        ```lua
        hasChildren = true
        hasState = false
        Arguments = {
            Width: number? = Iris._config.IndentSpacing -- indent width ammount.
        }
        ```
    ]=]
    Iris.Indent = wrapper("Indent")

    --[=[
        @prop Sameline Iris.Sameline
        @within Format
        @tag Widget
        @tag HasChildren
        
        Positions its children in a row, horizontally.
        
        ```lua
        hasChildren = true
        hasState = false
        Arguments = {
            Width: number? = Iris._config.ItemSpacing.X, -- horizontal spacing between child widgets.
            VerticalAlignment: Enum.VerticalAlignment? = Enum.VerticalAlignment.Center -- how widgets are aligned to the widget.
        }
        ```
    ]=]
    Iris.SameLine = wrapper("SameLine")

    --[=[
        @prop Group Iris.Group
        @within Format
        @tag Widget
        @tag HasChildren
        
        Layout widget which contains its children as a single group.
        
        ```lua
        hasChildren = true
        hasState = false
        ```
    ]=]
    Iris.Group = wrapper("Group")

    --[[
        ---------------------------------
            [SECTION] Text Widget API
        ---------------------------------
    ]]
    --[=[
        @class Text
        Text Widget API
    ]=]

    --[=[
        @prop Text Iris.Text
        @within Text
        @tag Widget
        
        A text label to display the text argument.
        The Wrapped argument will make the text wrap around if it is cut off by its parent.
        The Color argument will change the color of the text, by default it is defined in the configuration file.
        The RichText argument will 

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
            Wrapped: boolean? = false, -- whether the text will wrap around inside the parent container.
            Color: Color3? = Iris._config.TextColor, -- the colour of the text.
            RichText: boolean? = false -- enable RichText
        }
        Events = {
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.Text = wrapper("Text")

    --[=[
        @prop TextWrapped Iris.Text
        @within Text
        @tag Widget
        
        An alias for [Iris.Text](Text#Text) with the Wrapped argument set to true, and the text will wrap around if cut off by its parent.

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
        }
        Events = {
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.TextWrapped = function(arguments: Types.WidgetArguments): Types.Widget
        arguments[2] = true
        return Iris.Internal._Insert("Text", arguments)
    end

    --[=[
        @prop TextColored Iris.Text
        @within Text
        @tag Widget
        
        An alias for [Iris.Text](Text#Text) with the color set by the Color argument.

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
            Color: Color3 -- the colour of the text.
        }
        Events = {
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.TextColored = function(arguments: Types.WidgetArguments): Types.Widget
        arguments[3] = arguments[2]
        arguments[2] = nil
        return Iris.Internal._Insert("Text", arguments)
    end

    --[=[
        @prop SeparatorText Iris.SeparatorText
        @within Text
        @tag Widget
        
        Similar to [Iris.Separator](Format#Separator) but with a text label to be used as a header
        when an [Iris.Tree](Tree#Tree) or [Iris.CollapsingHeader](Tree#CollapsingHeader) is not appropriate.

        Visually a full width thin line with a text label clipping out part of the line.
        
        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string
        }
        ```
    ]=]
    Iris.SeparatorText = wrapper("SeparatorText")

    --[=[
        @prop InputText Iris.InputText
        @within Text
        @tag Widget
        @tag HasState

        A field which allows the user to enter text.
        
        ```lua
        hasChildren = false
        hasState = true
        Arguments = {
            Text: string? = "InputText",
            TextHint: string? = "" -- a hint to display when the text box is empty.
        }
        Events = {
            textChanged: () -> boolean, -- whenever the textbox looses focus and a change was made.
            hovered: () -> boolean
        }
        States = {
            text: State<string>?
        }
        ```
    ]=]
    Iris.InputText = wrapper("InputText")

    --[[
        ----------------------------------
            [SECTION] Basic Widget API
        ----------------------------------
    ]]
    --[=[
        @class Basic
        Basic Widget API
    ]=]

    --[=[
        @prop Button Iris.Button
        @within Basic
        @tag Widget
        
        A clickable button the size of the text with padding. Can listen to the `clicked()` event to determine if it was pressed.

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
        }
        Events = {
            clicked: () -> boolean,
            rightClicked: () -> boolean,
            doubleClicked: () -> boolean,
            ctrlClicked: () -> boolean, -- when the control key is down and clicked.
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.Button = wrapper("Button")

    --[=[
        @prop SmallButton Iris.SmallButton
        @within Basic
        @tag Widget
        
        A smaller clickable button, the same as a [Iris.Button](Basic#Button) but without padding. Can listen to the `clicked()` event to determine if it was pressed.

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
        }
        Events = {
            clicked: () -> boolean,
            rightClicked: () -> boolean,
            doubleClicked: () -> boolean,
            ctrlClicked: () -> boolean, -- when the control key is down and clicked.
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.SmallButton = wrapper("SmallButton")

    --[=[
        @prop Checkbox Iris.Checkbox
        @within Basic
        @tag Widget
        @tag HasState
        
        A checkable box with a visual tick to represent a boolean true or false state.

        ```lua
        hasChildren = false
        hasState = true
        Arguments = {
            Text: string
        }
        Events = {
            checked: () -> boolean, -- once when checked.
            unchecked: () -> boolean, -- once when unchecked.
            hovered: () -> boolean
        }
        State = {
            isChecked = State<boolean>? -- whether the box is checked.
        }
        ```
    ]=]
    Iris.Checkbox = wrapper("Checkbox")

    --[=[
        @prop RadioButton Iris.RadioButton
        @within Basic
        @tag Widget
        @tag HasState
        
        A circular selectable button, changing the state to its index argument. Used in conjunction with multiple other RadioButtons sharing the same state to represent one value from multiple options.
        
        ```lua
        hasChildren = false
        hasState = true
        Arguments = {
            Text: string,
            Index: any -- the state object is set to when clicked.
        }
        Events = {
            selected: () -> boolean,
            unselected: () -> boolean,
            active: () -> boolean, -- if the state index equals the RadioButton's index.
            hovered: () -> boolean
        }
        State = {
            index = State<any>? -- the state set by the index of a RadioButton.
        }
        ```
    ]=]
    Iris.RadioButton = wrapper("RadioButton")

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
        @prop Tree Iris.Tree
        @within Tree
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
            NoIndent: boolean? = false -- the child widgets will not be indented underneath.
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
    ]=]
    Iris.Tree = wrapper("Tree")

    --[=[
        @prop CollapsingHeader Iris.CollapsingHeader
        @within Tree
        @tag Widget
        @tag HasChildren
        @tag HasState
        
        The same as a Tree Widget, but with a larger title and clearer, used mainly for organsing widgets on the first level of a window.
        
        ```lua
        hasChildren: true
        hasState: true
        Arguments = {
            Text: string
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
    ]=]
    Iris.CollapsingHeader = wrapper("CollapsingHeader")

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
        @prop InputNum Iris.InputNum
        @within Input
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
    ]=]
    Iris.InputNum = wrapper("InputNum")

    --[=[
        @prop InputVector2 Iris.InputVector2
        @within Input
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
    ]=]
    Iris.InputVector2 = wrapper("InputVector2")

    --[=[
        @prop InputVector3 Iris.InputVector3
        @within Input
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
    ]=]
    Iris.InputVector3 = wrapper("InputVector3")

    --[=[
        @prop InputUDim Iris.InputUDim
        @within Input
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
    ]=]
    Iris.InputUDim = wrapper("InputUDim")

    --[=[
        @prop InputUDim2 Iris.InputUDim2
        @within Input
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
    ]=]
    Iris.InputUDim2 = wrapper("InputUDim2")

    --[=[
        @prop InputRect Iris.InputRect
        @within Input
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
    ]=]
    Iris.InputRect = wrapper("InputRect")

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
        @prop DragNum Iris.DragNum
        @within Drag
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
    ]=]
    Iris.DragNum = wrapper("DragNum")

    --[=[
        @prop DragVector2 Iris.DragVector2
        @within Drag
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
    ]=]
    Iris.DragVector2 = wrapper("DragVector2")

    --[=[
        @prop DragVector3 Iris.DragVector3
        @within Drag
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
    ]=]
    Iris.DragVector3 = wrapper("DragVector3")

    --[=[
        @prop DragUDim Iris.DragUDim
        @within Drag
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
    ]=]
    Iris.DragUDim = wrapper("DragUDim")

    --[=[
        @prop DragUDim2 Iris.DragUDim2
        @within Drag
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
    ]=]
    Iris.DragUDim2 = wrapper("DragUDim2")

    --[=[
        @prop DragRect Iris.DragRect
        @within Drag
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
    ]=]
    Iris.DragRect = wrapper("DragRect")

    --[=[
        @prop InputColor3 Iris.InputColor3
        @within Drag
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
    ]=]
    Iris.InputColor3 = wrapper("InputColor3")

    --[=[
        @prop InputColor4 Iris.InputColor4
        @within Drag
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
    ]=]
    Iris.InputColor4 = wrapper("InputColor4")

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
        @prop SliderNum Iris.SliderNum
        @within Slider
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
    ]=]
    Iris.SliderNum = wrapper("SliderNum")

    --[=[
        @prop SliderVector2 Iris.SliderVector2
        @within Slider
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
    ]=]
    Iris.SliderVector2 = wrapper("SliderVector2")

    --[=[
        @prop SliderVector3 Iris.SliderVector3
        @within Slider
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
    ]=]
    Iris.SliderVector3 = wrapper("SliderVector3")

    --[=[
        @prop SliderUDim Iris.SliderUDim
        @within Slider
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
    ]=]
    Iris.SliderUDim = wrapper("SliderUDim")

    --[=[
        @prop SliderUDim2 Iris.SliderUDim2
        @within Slider
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
    ]=]
    Iris.SliderUDim2 = wrapper("SliderUDim2")

    --[=[
        @prop SliderRect Iris.SliderRect
        @within Slider
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
    ]=]
    Iris.SliderRect = wrapper("SliderRect")

    --[=[
        @private
        @prop SliderNum Iris.SliderNum
        @within Slider
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
    ]=]
    -- Iris.SliderEnum = wrapper("SliderEnum")

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
        @prop Selectable Iris.Selectable
        @within Combo
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
    ]=]
    Iris.Selectable = wrapper("Selectable")

    --[=[
        @prop Combo Iris.Combo
        @within Combo
        @tag Widget
        @tag HasChildren
        @tag HasState
        
        A selection box to choose a value from a range of values.
        
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
            clsoed: () -> boolean,
            clicked: () -> boolean,
            hovered: () -> boolean
        }
        States = {
            index: State<any>,
            isOpened: State<boolean>?
        }
        ```
    ]=]
    Iris.Combo = wrapper("Combo")

    --[=[
        @prop ComboArray Iris.Combo
        @within Combo
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
            clsoed: () -> boolean,
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
    ]=]
    Iris.ComboArray = function(arguments: Types.WidgetArguments, states: Types.WidgetStates?, selectionArray: { any })
        local defaultState
        if states == nil then
            defaultState = Iris.State(selectionArray[1])
        else
            defaultState = states
        end
        local thisWidget = Iris.Internal._Insert("Combo", arguments, defaultState)
        local sharedIndex: Types.State = thisWidget.state.index
        for _, Selection in selectionArray do
            Iris.Internal._Insert("Selectable", { Selection, Selection }, { index = sharedIndex } :: Types.States)
        end
        Iris.End()

        return thisWidget
    end

    --[=[
        @prop ComboEnum Iris.Combo
        @within Combo
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
            clsoed: () -> boolean,
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
    ]=]
    Iris.ComboEnum = function(arguments: Types.WidgetArguments, states: Types.WidgetStates?, enumType: Enum)
        local defaultState
        if states == nil then
            defaultState = Iris.State(enumType[1])
        else
            defaultState = states
        end
        local thisWidget = Iris.Internal._Insert("Combo", arguments, defaultState)
        local sharedIndex = thisWidget.state.index
        for _, Selection in enumType:GetEnumItems() do
            Iris.Internal._Insert("Selectable", { Selection.Name, Selection }, { index = sharedIndex } :: Types.States)
        end
        Iris.End()

        return thisWidget
    end
    Iris.InputEnum = Iris.ComboEnum

    --[[
        ----------------------------------
            [SECTION] Table Widget API
        ----------------------------------
    ]]
    --[=[
        @class Table
        Table Widget API
    ]=]

    --[=[
        @prop Table Iris.Table
        @within Table
        @tag Widget
        @tag HasChildren
        
        A layout widget which allows children to be displayed in configurable columns and rows.
        
        ```lua
        hasChildren = true
        hasState = false
        Arguments = {
            NumColumns = number,
            RowBg = boolean? = false, -- whether the row backgrounds alternate a background fill.
            BordersOuter = boolean? = false,
            BordersInner = boolean? = false, -- borders on each cell.
        }
        Events = {
            hovered: () -> boolean
        }
        ```
    ]=]
    Iris.Table = wrapper("Table")

    --[=[
        @function NextColumn
        @within Table
        
        In a table, moves to the next available cell. if the current cell is in the last column,
        then the next cell will be the first column of the next row.
    ]=]
    Iris.NextColumn = function()
        Iris.Internal._GetParentWidget().RowColumnIndex += 1
    end

    --[=[
        @function SetColumnIndex
        @within Table
        @param index number
        
        In a table, directly sets the index of the column.
    ]=]
    Iris.SetColumnIndex = function(columnIndex: number)
        local ParentWidget: Types.Widget = Iris.Internal._GetParentWidget()
        assert(columnIndex >= ParentWidget.InitialNumColumns, "Iris.SetColumnIndex Argument must be in column range")
        ParentWidget.RowColumnIndex = math.floor(ParentWidget.RowColumnIndex / ParentWidget.InitialNumColumns) + (columnIndex - 1)
    end

    --[=[
        @function NextRow
        @within Table
        
        In a table, moves to the next available row,
        skipping cells in the previous column if the last cell wasn't in the last column
    ]=]
    Iris.NextRow = function()
        -- sets column Index back to 0, increments Row
        local ParentWidget: Types.Widget = Iris.Internal._GetParentWidget()
        local InitialNumColumns: number = ParentWidget.InitialNumColumns
        local nextRow: number = math.floor((ParentWidget.RowColumnIndex + 1) / InitialNumColumns) * InitialNumColumns
        ParentWidget.RowColumnIndex = nextRow
    end
end
