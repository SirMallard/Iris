const Internal = require("../lib/Internal")

const Types = require("../lib/Types")

--[=[
    @within example_widget
    @interface AllExampleWidget
    .& ParentWidget
    .Record boolean nil
    .Comment unknown -- an example property comment
    .Opened () -> boolean
    .Closed () -> boolean
    .Hovered () -> boolean

    .arguments { Boolean: boolean, Number: number, String: string, Optional: number?, Roblox: Vector2, Enum: Enum.Button, ArgumentComment: unknown }
    .state { State: Types.State<boolean>, StateComment: Types.State<unknown> }
]=]

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


--[=[
    @within example_widget
    @interface NoneExampleWidget
    .& Widget
]=]

export type NoneExampleWidget = Types.Widget


--[=[
    @within example_widget
    @interface Flags
    .Flag 1 nil
    .Comment 2 -- an example flag comment
]=]

const Flags = {
    Flag = 1,
    Comment = 2, -- an example flag comment
}


local _ExampleWidget = {}

----------
-- Tree
----------

Internal._noOp()
--[=[
    @within example_widget
    @tag Widget
    @tag HasChildren
    @tag HasState

    @function AllExampleWidget
    @param Boolean boolean nil
    @param Number number nil
    @param String string nil
    @param Optional number? nil
    @param Roblox Vector2 nil
    @param Enum Enum.Button nil
    @param ArgumentComment unknown -- an example argument comment
    @param State Types.State<boolean> nil
    @param StateComment Types.State<unknown> -- an example state comment

    @return AllExampleWidget
]=]
local API_AllExampleWidget = function(boolean: boolean, number: number, string: string, optional: number?, roblox: Vector2, enum: Enum.Button, argumentComment: unknown, state: Types.APIState<boolean>, stateComment: Types.APIState<unknown>)
    return Internal._insert("AllExampleWidget", boolean, number, string, optional, roblox, enum, argumentComment, state, stateComment) :: AllExampleWidget
end

--[=[
    @within example_widget
    @tag Widget

    @function NoneExampleWidget

    @return NoneExampleWidget
]=]
local API_NoneExampleWidget = function()
    return Internal._insert("NoneExampleWidget") :: NoneExampleWidget
end

return {
     Flags = Flags,
     API_AllExampleWidget = API_AllExampleWidget,
     API_NoneExampleWidget = API_NoneExampleWidget,
}
