export type Tree = Types.ParentWidget & {
    arguments: {
        Label: string, -- text displayed on the tree
        Flags: number?, -- optional flags affecting the behaviour
    },

    state: {
        open: Types.State<boolean>?, -- collapsing the children under the tree
    },
} & Types.Opened & Types.Closed & Types.Hovered

const TreeFlags = {
    SpanAvailWidth = 1, -- the tree title will fill all horizontal space to the end its parent container
    NoIndent = 2, -- the child widgets will not be indented underneath
    DefaultOpen = 4, -- initially opens the tree if no state is provided
}

return {}
