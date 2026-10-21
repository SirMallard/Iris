const Internal = require("../lib/Internal")

const Types = require("../lib/Types")

export type AllExampleWidget = Types.ParentWidget & {
    Record: boolean,
    Comment: unknown, -- an example property comment

    arguments: {
        Boolean: boolean,
        Number: number,
        String: string,
        Optional: number?,
        Roblox: Vector2,
        Enum: Enum.Button,
        ArgumentComment: unknown, -- an example argument comment
        --[[
            another comment
        ]]
        -- one more
    },

    state: {
        State: Types.State<boolean>,
        StateComment: Types.State<unknown>, -- an example state comment
    },
} & Types.Opened & Types.Closed & Types.Hovered

export type NoneExampleWidget = Types.Widget

const Flags = {
    Flag = 1,
    Comment = 2, -- an example flag comment
}

----------
-- Tree
----------

Internal._widgetConstructor("Example", {} :: any)

--[[
    An example widget constructor description
]]
Internal._widgetConstructor("ExampleComment", {} :: any)

--[[
    An example API function description
]]
local function API_ExampleFunction(Parameter: boolean, ...)
    return
end
