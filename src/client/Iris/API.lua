local Types = require(script.Parent.Types)

return function(Iris: Types.Iris)
    -- basic wrapper for nearly every widget, saves space.
    local function wrapper(name: string): (arguments: Types.WidgetArguments?, states: Types.States?) -> Types.Widget
        return function(arguments: Types.WidgetArguments?, states: Types.States?): Types.Widget
            return Iris.Internal._Insert(name, arguments, states)
        end
    end

    --[[
        =============================================================

             __        __ ___  ____    ____  _____  _____  ____  
             \ \      / /|_ _||  _ \  / ___|| ____||_   _|/ ___| 
              \ \ /\ / /  | | | | | || |  _ |  _|    | |  \___ \ 
               \ V  V /   | | | |_| || |_| || |___   | |   ___) |
                \_/\_/   |___||____/  \____||_____|  |_|  |____/ 
                                                     
        =============================================================
    ]]

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
        Iris.End() -- must always call `Iris.End()`, regardless of whether the window is open or not.
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

    --[[
        ---------------------------------
            [SECTION] Menu Widget API
        ---------------------------------
    ]]
    --[=[
        @class Menu
        Menu API
    ]=]

    Iris.MenuBar = wrapper("MenuBar")
    Iris.Menu = wrapper("Menu")
    Iris.MenuItem = wrapper("MenuItem")
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

    Iris.Separator = wrapper("Separator")
    Iris.Indent = wrapper("Indent")
    Iris.Sameline = wrapper("Sameline")
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

        ```lua
        hasChildren = false
        hasState = false
        Arguments = {
            Text: string,
            Wrapped: boolean? = false, -- whether the text will wrap around inside the parent container.
            Color: Color3? = Iris._config.TextColor -- the colour of the text.
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
        
        An alias for `Iris.Text` with the Wrapped argument set to true, and the text will wrap around if cut off by its parent.

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
        
        An alias for `Iris.Text` with the color set by the Color argument.

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

    Iris.SeparatorText = wrapper("SeparatorText")

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
        
        A smaller clickable button, the same as a `Iris.Button` but without padding. Can listen to the `clicked()` event to determine if it was pressed.

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
    ]=]

    Iris.InputNum = wrapper("InputNum")
    Iris.InputVector2 = wrapper("InputVector2")
    Iris.InputVector3 = wrapper("InputVector3")
    Iris.InputUDim = wrapper("InputUDim")
    Iris.InputUDim2 = wrapper("InputUDim2")
    Iris.InputRect = wrapper("InputRect")
    Iris.InputColor3 = wrapper("InputColor3")
    Iris.InputColor4 = wrapper("InputColor4")

    --[[
        ---------------------------------
            [SECTION] Drag Widget API
        ---------------------------------
    ]]
    --[=[
        @class Drag
        Drag Widget API
    ]=]

    Iris.DragNum = wrapper("DragNum")
    Iris.DragVector2 = wrapper("DragVector2")
    Iris.DragVector3 = wrapper("DragVector3")
    Iris.DragUDim = wrapper("DragUDim")
    Iris.DragUDim2 = wrapper("DragUDim2")
    Iris.DragRect = wrapper("DragRect")

    --[[
        -----------------------------------
            [SECTION] Slider Widget API
        -----------------------------------
    ]]
    --[=[
        @class Slider
        Slider Widget API
    ]=]

    Iris.SliderNum = wrapper("SliderNum")
    Iris.SliderVector2 = wrapper("SliderVector2")
    Iris.SliderVector3 = wrapper("SliderVector3")
    Iris.SliderUDim = wrapper("SliderUDim")
    Iris.SliderUDim2 = wrapper("SliderUDim2")
    Iris.SliderRect = wrapper("SliderRect")
    Iris.SliderEnum = wrapper("SliderEnum")

    --[[
        ----------------------------------------
            [SECTION] Other Input Widget API
        ----------------------------------------
    ]]
    --[=[
        @class Other Input
        Other Input Widget API
    ]=]

    Iris.InputText = wrapper("InputText")
    Iris.InputEnum = wrapper("InputEnum")

    --[[
        ----------------------------------
            [SECTION] Combo Widget API
        ----------------------------------
    ]]
    --[=[
        @class Combo
        Combo Widget API
    ]=]

    Iris.Selectable = wrapper("Selectable")
    Iris.Combo = wrapper("Combo")
    Iris.ComboArray = wrapper("ComboArray")
    Iris.ComboEnum = wrapper("ComboEnum")

    --[[
        ----------------------------------
            [SECTION] Table Widget API
        ----------------------------------
    ]]
    --[=[
        @class Table
        Table Widget API
    ]=]

    Iris.Table = wrapper("Table")

    --[[
        =========================================

              ____  _____   _   _____  _____ 
             / ___||_   _| / \ |_   _|| ____|
             \___ \  | |  / _ \  | |  |  _|  
              ___) | | | / ___ \ | |  | |___ 
             |____/  |_|/_/   \_\|_|  |_____|                                             
                                                     
        =========================================
    ]]

    --[[
        =====================================================================

              _____  _   _  _   _   ____  _____  ___  ___   _   _  ____  
             |  ___|| | | || \ | | / ___||_   _||_ _|/ _ \ | \ | |/ ___| 
             | |_   | | | ||  \| || |      | |   | || | | ||  \| |\___ \ 
             |  _|  | |_| || |\  || |___   | |   | || |_| || |\  | ___) |
             |_|     \___/ |_| \_| \____|  |_|  |___|\___/ |_| \_||____/                                                 
                                                     
        =====================================================================
    ]]

    function Iris.PushId(id: Types.ID)
        assert(typeof(id) == "string", "API expected the ID to PushId to be a string.")

        Iris.Internal._pushedId = tostring(id)
    end

    function Iris.PopId()
        Iris.Internal._pushedId = nil
    end

    function Iris.SetNextWidgetID(id: Types.ID)
        Iris.Internal._nextWidgetId = id
    end
end
