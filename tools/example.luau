--[=[
    @within Widget
    @interface Tree
    .& ParentWidget
    .opened () -> boolean
    .closed () -> boolean
    .hovered () -> boolean

    .arguments {
        Label: string, -- text displayed on the tree
        Flags: number? -- optional flags affecting the behaviour
    }
    .state {
        open: State<boolean>? -- collapsing the children under the tree
    }
]=]
export type Tree = Types.ParentWidget & {
    arguments: {
        Label: string, -- text displayed on the tree
        Flags: number?, -- optional flags affecting the behaviour
    },

    state: {
        open: Types.State<boolean>?, -- collapsing the children under the tree
    },
} & Types.Opened & Types.Closed & Types.Hovered

--[=[
    @within Tree
    @interface TreeFlags
    .SpanAvailWidth 1 -- the tree title will fill all horizontal space to the end its parent container
    .NoIndent 2 -- the child widgets will not be indented underneath
    .DefaultOpen 4 -- initially opens the tree if no state is provided
]=]
const TreeFlags = {
    SpanAvailWidth = 1, -- the tree title will fill all horizontal space to the end its parent container
    NoIndent = 2, -- the child widgets will not be indented underneath
    DefaultOpen = 4, -- initially opens the tree if no state is provided
}

--[=[
    @within Tree
    @tag Widget
    @tag HasChildren
    @tag HasState

    @function Tree
    @param label string
    @param flags TreeFlags? -- optional bit flags, using Iris.TreeFlags, default is 0
    @param open State<boolean>? -- open state

    @return Tree

    A collapsable container for other widgets, to organise and hide widgets when not needed. The state determines whether the child widgets are visible or not. Clicking on the widget will open or close it.
]=]
local API_Tree = function(label: string, flags: number?, open: Types.APIState<boolean>?)
    return Internal._insert("Tree", label, flags or 0, open) :: Tree
end
