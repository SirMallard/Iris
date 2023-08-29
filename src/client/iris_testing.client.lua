local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris)

task.wait(2)

local typeToWidget = {
    string = { "InputText", "text" },
    boolean = { "Checkbox", "isChecked" },
    number = { "DragNum", "number" },
    Vector2 = { "DragVector2", "number" },
    Vector3 = { "DragVector3", "number" },
    UDim = { "DragUDim", "number" },
    UDim2 = { "DragUDim2", "number" },
    Color3 = { "InputColor3", "color" },
    Enum = { "InputEnum", "index" },
}

local order = { "Window", "Text", "TextColored", "TextWrapped", "SeparatorText", "Button", "SmallButton", "Checkbox", "RadioButton" }

Iris:Connect(function()
    local demoText = Iris.State("Lorem ipsum dolor sit amet.")

    local testingWidgets: { [string]: { Arguments: { { any } }, States: { { any } }, Events: { { string } } } } = {
        Window = {
            Arguments = {
                { "Title", demoText },
                { "NoTitleBar", false },
                { "NoBackground", false },
                { "NoCollapse", false },
                { "NoClose", false },
                { "NoMove", false },
                { "NoScrollbar", false },
                { "NoResize", false },
                { "NoNav", false },
                { "NoMenu", false },
            },
            States = {
                { "size", Vector2.new(300, 300) },
                { "position", Vector2.new(200, 200) },
                { "isUncollapsed", true },
                { "isOpened", true },
                { "scrollDistance", 0 },
            },
            Events = {
                { "closed" },
                { "opened" },
                { "collapsed" },
                { "uncollapsed" },
                { "hovered" },
            },
        },
        Text = {
            Arguments = {
                { "Text", demoText },
                { "Wrapped", false },
                { "Color", Color3.fromRGB(33, 84, 196) },
            },
            States = {},
            Events = {
                { "hovered" },
            },
        },
        TextColored = {
            Arguments = {
                { "Text", demoText },
                { "Color", Color3.fromRGB(255, 127, 127) },
            },
            States = {},
            Events = {
                { "hovered" },
            },
        },
        TextWrapped = {
            Arguments = {
                { "Text", demoText },
            },
            States = {},
            Events = {
                { "hovered" },
            },
        },
        SeparatorText = {
            Arguments = {
                { "Text", demoText },
            },
            States = {},
            Events = {
                { "hovered" },
            },
        },
        Button = {
            Arguments = {
                { "Text", demoText },
            },
            States = {},
            Events = {
                { "clicked" },
                { "rightClicked" },
                { "ctrlClicked" },
                { "doubleClicked" },
                { "hovered" },
            },
        },
        SmallButton = {
            Arguments = {
                { "Text", demoText },
            },
            States = {},
            Events = {
                { "clicked" },
                { "rightClicked" },
                { "ctrlClicked" },
                { "doubleClicked" },
                { "hovered" },
            },
        },
        Checkbox = {
            Arguments = {
                { "Text", demoText },
            },
            States = {
                { "isChecked", false },
            },
            Events = {
                { "checked" },
                { "unchecked" },
                { "hovered" },
            },
        },
        RadioButton = {
            Arguments = {
                { "Text", demoText },
                { "Index", 1 },
            },
            States = {
                { "index", 1 },
            },
            Events = {
                { "selected" },
                { "unselected" },
                { "active" },
                { "hovered" },
            },
        },
        InputText = {
            Arguments = {
                { "Text", demoText },
                { "TextHint", demoText:get() },
            },
            States = {
                { "text", demoText:get() },
            },
            Events = {
                { "textChanged" },
                { "hovered" },
            },
        },
        InputNum = {
            Arguments = {
                { "Text", demoText },
                { "Increment", 1 },
                { "Min", 0 },
                { "Max", 100 },
                { "Format", "%.3f" },
            },
            States = {
                { "number", 50 },
                { "editingText", false },
            },
            Events = {
                { "numberChanged" },
                { "hovered" },
            },
        },
    }

    -- stylua: ignore start
    Iris.Window({ "Iris Widget Testing" })

        Iris.CollapsingHeader({ "Options" })
            if Iris.Checkbox("Use multi-line text").state.isChecked.value then
                demoText:set("Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit. Vivamus vel.")
            else
                demoText:set("Lorem ipsum dolor sit amet.")
            end
        Iris.End()

        -- widget testing
        for _, widget: string in order do
            local data = testingWidgets[widget]
            Iris.CollapsingHeader({ widget })
                local arguments: { [string]: any } = {}
                local argumentValues: { any } = {}
                local states: { [string]: any } = {}

                for _, argument in data.Arguments do
                    local state
                    if typeof(argument[2]) == "table" then
                        state = argument[2]
                    else
                        state = Iris.State(argument[2])
                    end
                    arguments[argument[1]] = state
                    table.insert(argumentValues, state:get())
                end

                for _, state in data.States do
                    if typeof(state[2]) == "table" then
                        states[state[1]] = state[2]
                    else
                        states[state[1]] = Iris.State(state[2])
                    end
                end

                -- Create Window
                if widget ~= "Window" then
                    Iris.SetNextWidgetID("iris_widget_testing_window")
                    Iris.Window()
                    Iris.SeparatorText({ widget })
                else
                    Iris.SetNextWidgetID("iris_widget_testing_window")
                end

                -- Show widget type
                local _irisWidget = Iris[widget](
                    argumentValues,
                    states
                )

                Iris.End()

                -- control

                if #data.Arguments > 0 then
                    Iris.Tree({ "Arguments" })
                        for name: string, state in arguments do
                            local inputData = typeToWidget[typeof(state:get())]
                            Iris[inputData[1]](
                                { name },
                                { [inputData[2]] = state }
                            )
                        end
                    Iris.End()
                end
                if #data.States > 0 then
                    Iris.Tree({ "States" })
                        for name: string, state in states do
                            local inputData = typeToWidget[typeof(state:get())]
                            Iris[inputData[1]](
                                { name },
                                { [inputData[2]] = state }
                            )
                        end
                    Iris.End()
                end
                if #data.Events > 0 then
                    Iris.Tree({ "Events" })
                        for _, event in data.Events do
                            Iris.Text({ `{event[1]}: {_irisWidget[event[1]]()}`})
                        end
                    Iris.End()
                end

            Iris.End()
        end
    Iris.End()
    -- stylua: ignore end
end)
