local Parser = require("./parser")
local Syntax = require("@std/syntax")
local Printer = require("@std/syntax/printer")

local TAB = "    "
local LE = "\r\n"
local DIR = "\\"

local function toCamelCase(str: string): string
    return str:sub(0, 1):lower() .. str:sub(2)
end

local function generateWidgetInterface(widget: Parser.Widget, group: string)
    local body = widget.body

    local interface = {
        "--[=[",
        `{TAB}@within {group}`,
        `{TAB}@interface {widget.name}`,
        `{TAB}.& {widget.inherit}`,
    }

    if body and #body.properties > 0 then
        for _, property in body.properties do
            table.insert(interface, `{TAB}.{property.name} {property.type} {property.description}`)
        end
    end

    if #widget.events > 0 then
        for _, event in widget.events do
            table.insert(interface, `{TAB}.{event} () -> boolean`)
        end
    end

    if body and (#body.arguments > 0 or #body.state > 0) then
        table.insert(interface, "")
    end

    if body and #body.arguments > 0 then
        local arguments = {}
        for _, argument in body.arguments do
            table.insert(arguments, `{argument.name}: {argument.type}`)
        end
        table.insert(interface, `{TAB}.arguments \{ {table.concat(arguments, ", ")} }`)
    end

    if body and #body.state > 0 then
        local states = {}
        for _, argument in body.state do
            table.insert(states, `{argument.name}: {argument.type}`)
        end
        table.insert(interface, `{TAB}.state \{ {table.concat(states, ", ")} }`)
    end

    table.insert(interface, "]=]")

    return table.concat(interface, LE)
end

local function generateWidgetFunction(widget: Parser.Widget, constructor: Parser.Constructor?, group: string)
    local body = widget.body
    local arguments: { Parser.Record } = if body then body.arguments else {}
    local states: { Parser.Record } = if body then body.state else {}

    local api = {
        "--[=[",
        `{TAB}@within {group}`,
        `{TAB}@tag Widget`,
    }

    if widget.inherit == "ParentWidget" then
        table.insert(api, `{TAB}@tag HasChildren`)
    end

    if body and #body.state > 0 then
        table.insert(api, `{TAB}@tag HasState`)
    end

    table.insert(api, "")
    table.insert(api, `{TAB}@function {widget.name}`)
    for _, argument in arguments do
        table.insert(api, `{TAB}@param {argument.name} {argument.type} {argument.description}`)
    end
    for _, state in states do
        table.insert(api, `{TAB}@param {state.name} {state.type} {state.description}`)
    end

    table.insert(api, "")
    table.insert(api, `{TAB}@return {widget.name}`)

    if constructor and constructor.comment then
        table.insert(api, "")
    end

    table.insert(api, "]=]")

    local parameters = {}
    local insert = { `\"{widget.name}\"` }
    for _, argument in arguments do
        table.insert(parameters, `{toCamelCase(argument.name)}: {argument.type}`)
        table.insert(insert, `{toCamelCase(argument.name)}{if argument.name == "Flags" then " or 0" else ""}`)
    end
    for _, state in states do
        table.insert(parameters, `{toCamelCase(state.name)}: {state.type:gsub("State", "APIState")}`)
        table.insert(insert, `{toCamelCase(state.name)}`)
    end

    table.insert(api, `local API_{widget.name} = function({table.concat(parameters, ", ")})`)
    table.insert(api, `{TAB}return Internal._insert({table.concat(insert, ", ")}) :: {widget.name}`)
    table.insert(api, "end")

    return table.concat(api, LE)
end

local function generateFlagsInterface(flags: Parser.Flags, group: string)
    local interface = {
        "--[=[",
        `{TAB}@within {group}`,
        `{TAB}@interface {flags.name}`,
    }

    for _, entry in flags.entries do
        table.insert(interface, `{TAB}.{entry.name} {entry.value} {entry.description}`)
    end

    table.insert(interface, "]=]")

    return table.concat(interface, LE)
end

local function generateReturnStatement(parsed: Parser.FileParse)
    local statement = {
        "return {",
    }

    for _, flags in parsed.flags do
        table.insert(statement, `{TAB}{flags.name} = {flags.name},`)
    end

    for _, widget in parsed.widgets do
        table.insert(statement, `{TAB}API_{widget.name} = API_{widget.name},`)
    end

    for _, func in parsed.apiFunctions do
        table.insert(statement, `{TAB}{func.name} = {func.name},`)
    end

    table.insert(statement, "}")

    return table.concat(statement, LE) .. LE
end

local function generateReplacement(text: string, node: Syntax.CstNode): string
    return text .. Printer.printNode(node)
end

local function transform(context: Parser.Context): { [Syntax.CstNode]: string }
    local replacements = {}

    local split = context.path:split(DIR)
    local file = split[#split]
    local group = file:gsub(".luau", "")

    local parsed = Parser.parseWidget(context)

    local endStatements = {}

    for _, widget in parsed.widgets do
        local constructor = nil
        for _, cons in parsed.constructors do
            if cons.name == widget.name then
                constructor = cons
                break
            end
        end
        replacements[widget.node] = generateReplacement(generateWidgetInterface(widget, group), widget.node)
        table.insert(endStatements, generateWidgetFunction(widget, constructor, group))
    end

    for _, flags in parsed.flags do
        replacements[flags.node] = generateReplacement(generateFlagsInterface(flags, group), flags.node)
    end

    table.insert(endStatements, generateReturnStatement(parsed))
    replacements[parsed.node :: Syntax.CstNode] = generateReplacement(LE .. table.concat(endStatements, LE .. LE), parsed.node)

    return replacements
end

return transform
