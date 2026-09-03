const Types = require("../Types")

const Internal = require("../Internal")

--[=[
    @class Example
    Example Widget API
]=]

--[=[
    @within
    @interface Example
    .& ParentWidget
    .opened () -> boolean
    .closed () -> boolean
    .hovered () -> boolean

    .arguments { Label: string, Flags: number }
    .state { open: State<boolean> }
]=]
export type Example = Types.ParentWidget & {
    arguments: {
        Label: string, -- text displayed on the tree
        Flags: number?, -- optional flags affecting the behaviour
    },

    state: {
        open: Types.State<boolean>?, -- collapsing the children under the tree
    },
} & Types.Opened & Types.Closed & Types.Hovered

--[=[
    @within
    @interface ExampleFlags
    .SpanAvailWidth 1 -- the tree title will fill all horizontal space to the end its parent container
    .NoIndent 2 -- the child widgets will not be indented underneath
    .DefaultOpen 4 -- initially opens the tree if no state is provided
]=]
const ExampleFlags = {
    SpanAvailWidth = 1, -- the tree title will fill all horizontal space to the end its parent container
    NoIndent = 2, -- the child widgets will not be indented underneath
    DefaultOpen = 4, -- initially opens the tree if no state is provided
}

--[=[
    @within
    @tag Widget
    @tag HasChildren
    @tag HasState

    @function Example
    @param label string -- text displayed on the tree
    @param flags ExampleFlags? -- optional flags affecting the behaviour
    @param open State<boolean>? -- collapsing the children under the tree

    @return Example

    A collapsable container for other widgets, to organise and hide widgets when not needed. The state determines whether the child widgets are visible or not. Clicking on the widget will open or close it.
]=]
const API_Example = function(label: string, flags: number?, open: Types.APIState<boolean>?)
    return Internal._insert("Example", label, flags or 0, open) :: Example
end

return {
    ExampleFlags = ExampleFlags,
    API_Example = API_Example,
}
