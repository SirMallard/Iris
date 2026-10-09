const Internal = require("../lib/Internal")

const Types = require("../lib/Types")

export type ExampleWidget = Types.ParentWidget & {
    Record: boolean,

    arguments: {
        Boolean: boolean,
        Number: number, -- test
        String: string,
        Optional: number?,
        Roblox: Vector2,
        Enum: Enum.Button, -- test
    },

    state: {
        State: Types.State<boolean>,
    },
} & Types.Opened & Types.Closed & Types.Hovered

const Flags = {
    Flag1 = 1,
    Flag2 = 2,
}

local _ExampleWidget = {}

----------
-- Tree
----------

Internal._noOp()
