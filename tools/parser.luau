local Syntax = require("@std/syntax")
local Query = require("@std/syntax/query")
local Printer = require("@std/syntax/printer")
local Utils = require("@std/syntax/utils")

export type Context<Options = { [any]: any }> = {
    path: string,
    source: string,
    parseresult: Syntax.CstParseResult,
    options: Options,
}

export type Record = {
    name: string,
    type: string,
    description: string?,
}

export type Body = {
    arguments: { Record },
    state: { Record },
    properties: { Record },
}

export type Widget = {
    body: Body,
    inherit: string,
    events: { string },
}

export type FlagEntry = {
    read key: string,
    read value: number,
}

export type Flags = {
    read name: string,
    read entries: { FlagEntry },
}

local Parser = {}

function Parser.parseRecord(record: Syntax.CstTableTypeItemProperty): Record
    local description = ""
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
    assert(node.type.tag == "intersection", "expected combination of widget types")

    local widget = {
        events = {},
    }

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

        assert(item.value.tag == "number", "flag values must be integers")
        table.insert(entries, {
            key = item.key.text,
            value = item.value.value,
        })
    end

    return {
        name = variable.name.text,
        entries = entries,
    }
end

function Parser.parseWidget(context: Context)
    local typeAliasNodes = Query.findAllFromRoot(context.parseresult, Utils.isStatTypeAlias):filter(function(node)
        if node.export == nil then
            return false
        end

        if node.type.tag ~= "intersection" then
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

    local widgets = typeAliasNodes:mapToArray(function(node: Syntax.CstStatTypeAlias): {}
        return Parser.parseExportTypes(node)
    end)

    local flags = constNodes:mapToArray(function(node: Syntax.CstStatConst): {}
        return Parser.parseConst(node)
    end)

    return {
        widgets = widgets,
        flags = flags,
    }
end

return Parser
