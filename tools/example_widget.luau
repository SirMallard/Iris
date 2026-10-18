const Internal = require("../lib/Internal")

const Types = require("../lib/Types")

export type ExampleWidget = Types.ParentWidget & {
    Record: boolean,
    Comment: unknown, -- an example property comment

    arguments: {
        Boolean: boolean,
        Number: number,
        String: string,
        Optional: number?,
        Roblox: Vector2,
        Enum: Enum.Button,
        Comment: unknown, -- an example argument comment
        --[[
            another comment
        ]]
        -- one more
    },

    state: {
        State: Types.State<boolean>,
        Comment: Types.State<unknown>, -- an example state comment
    },
} & Types.Opened & Types.Closed & Types.Hovered

const Flags = {
    Flag = 1,
    Comment = 2, -- an example flag comment
}

local _ExampleWidget = {}

----------
-- Tree
----------

Internal._noOp()

return {
    Flags = Flags,
}
