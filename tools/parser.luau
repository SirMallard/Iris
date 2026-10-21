local Syntax = require("@std/syntax")
local Query = require("@std/syntax/query")
local Printer = require("@std/syntax/printer")
local Utils = require("@std/syntax/utils")

export type Context<Options = { [any]: any }> = {
    read path: string,
    read source: string,
    read parseresult: Syntax.CstParseResult,
    read options: Options,
}

export type Record = {
    read name: string,
    read type: string,
    read description: string?,
}

export type Body = {
    read arguments: { Record },
    read state: { Record },
    read properties: { Record },
}

export type Widget = {
    read name: string,
    body: Body?,
    inherit: string,
    read events: { string },
    read node: Syntax.CstStatTypeAlias,
}

export type FlagEntry = {
    read name: string,
    read value: number,
    read description: string?,
}

export type Flags = {
    read name: string,
    read entries: { FlagEntry },
    read node: Syntax.CstStatConst,
}

export type Constructor = {
    read name: string,
    read comment: string?,
    read node: Syntax.CstExprCall
}

export type APIFunction = {
    read name: string,
    read node: Syntax.CstStatLocalFunction
}

export type FileParse = {
    widgets: { Widget },
    constructors: { Constructor },
    flags: { Flags },
    node: Syntax.CstEof,
    apiFunctions: { APIFunction }
}

local Parser = {}

function Parser.parseRecord(record: Syntax.CstTableTypeItemProperty): Record
    local description
    if local separator = record.separator then
        for _, trailing in separator.trailingTrivia do
            if trailing.tag ~= "whitespace" then
                description = trailing.text
            end
        end
    end

    return {
        name = record.key.text,
        type = Printer.printNode(record.value),
        description = description,
    }
end

function Parser.parseWidgetBodyTable(node: Syntax.CstTypeTable): Body
    local body = {
        properties = {},
        arguments = {},
        state = {},
    }

    for _, record in node.entries do
        assert(record.kind == "property", "expected widget properties")

        if record.key.text == "arguments" or record.key.text == "state" then
            assert(record.value.tag == "table", "expected arguments to be a table")
            for _, subRecord in record.value.entries do
                assert(subRecord.kind == "property", "expected key-values to be properties")
                table.insert(body[record.key.text], Parser.parseRecord(subRecord))
            end
        else
            table.insert(body.properties, Parser.parseRecord(record))
        end
    end

    return body
end

function Parser.parseExportTypes(node: Syntax.CstStatTypeAlias): Widget
    local widget: Widget = {
        name = node.name.text,
        inherit = "",
        events = {},
        node = node,
    }

    if node.type.tag == "reference" then
        local name = node.type.name.text
        assert(name:sub(-6) == "Widget", "expected widget to be just a widget type")
        widget.inherit = name
        return widget
    end

    assert(node.type.tag == "intersection", "expected combination of widget types")
    for _, intersection in node.type.types do
        if intersection.tag == "table" then
            widget.body = Parser.parseWidgetBodyTable(intersection)
        elseif intersection.tag == "reference" then
            local name = intersection.name.text
            if name:sub(-6) == "Widget" then
                widget.inherit = name
            else
                table.insert(widget.events, name)
            end
        else
            warn(`Unsupported \"{intersection.tag}\" found in widget type \"{node.name.text}\", skipping.`)
        end
    end

    return widget
end

function Parser.parseConst(node: Syntax.CstStatConst): Flags
    local variable = node.variables[1]
    local value = node.values[1]
    assert(value.tag == "table", "only parsing table consts")

    local entries: { FlagEntry } = {}
    for _, item in value.entries do
        assert(item.kind == "record", "expected flag to be a record")

        local description
        if local separator = item.separator then
            for _, trailing in separator.trailingTrivia do
                if trailing.tag ~= "whitespace" then
                    description = trailing.text
                end
            end
        end

        assert(item.value.tag == "number", "flag values must be integers")
        table.insert(entries, {
            name = item.key.text,
            value = item.value.value,
            description = description,
        })
    end

    return {
        name = variable.name.text,
        entries = entries,
        node = node,
    }
end

function Parser.parseFunctionCall(node: Syntax.CstExprCall): Constructor
    local func = node.func
    local arguments = node.arguments
    assert(func.tag == "indexname", "expected a function call")
    assert(func.expression.tag == "local", "expected a local Internal call")
    assert(#arguments == 2, "expected two arguments to widget constructor")

    local name = arguments[1]
    assert(name.tag == "string", "expected widget name to be a string")
    
    local trivia = func.expression.token.leadingTrivia

    -- if #trivia > 0 and 

    local comment = nil
    for i = #trivia, 1, -1 do
        if trivia[i].tag == "blockcomment" then
            comment = trivia[i].text
            break
        end
    end

    
    return {
        name = name.value.text,
        comment = comment,
        node = node
    }
end

function Parser.parseLocalFunction(node: Syntax.CstStatLocalFunction): APIFunction
    return {
        name = node.name.name.text,
        node = node
    }
end

function Parser.parseWidget(context: Context): FileParse
    local typeAliasNodes = Query.findAllFromRoot(context.parseresult, Utils.isStatTypeAlias):filter(function(node)
        if node.export == nil then
            return false
        end

        if node.type.tag ~= "intersection" and node.type.tag ~= "reference" then
            return false
        end

        return true
    end)

    local constNodes = Query.findAllFromRoot(context.parseresult, Utils.isStatConst):filter(function(node)
        if #node.variables ~= 1 or #node.values ~= 1 then
            return false
        end

        local variable = node.variables[1]
        if variable.name.text:sub(-#"Flags") ~= "Flags" then
            return false
        end

        local value = node.values[1]
        if value.tag ~= "table" then
            return false
        end

        return true
    end)
    local exprCallNodes = Query.findAllFromRoot(context.parseresult, Utils.isExprCall):filter(function(node)
        if node.func.tag ~= "indexname" then
            return false
        end

        if node.func.expression.tag ~= "local" then
            return false
        end

        if node.func.index.text ~= "_widgetConstructor" then
            return false
        end

        if node.func.expression["local"].name.text ~= "Internal" then
            return false
        end

        return true
    end)

    local functionNodes = Query.findAllFromRoot(context.parseresult, Utils.isStatLocalFunction):filter(function(node)
        if node.name.name.text:sub(1, 4) ~= "API_" then
            return false
        end

        return true
    end)

    local widgets = typeAliasNodes:mapToArray(function(node: Syntax.CstStatTypeAlias): Widget
        return Parser.parseExportTypes(node)
    end)

    local flags = constNodes:mapToArray(function(node: Syntax.CstStatConst): Flags
        return Parser.parseConst(node)
    end)

    local widgetConstructors = exprCallNodes:mapToArray(function(node: Syntax.CstExprCall): Constructor
        return Parser.parseFunctionCall(node)
    end)

    local apiFunctions = functionNodes:mapToArray(function(node: Syntax.CstStatLocalFunction): APIFunction
        return Parser.parseLocalFunction(node)
    end)

    return {
        widgets = widgets,
        constructors = widgetConstructors,
        flags = flags,
        apiFunctions = apiFunctions,
        node = context.parseresult.eof,
    }
end

return Parser
