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

export type Widget = {
    arguments: { Record },
    state: { Record },
    properties: { Record },
}

export type FlagEntry = {
    read key: string,
    read value: number,
}

export type Flags = {
    read name: string,
    read entries: { FlagEntry },
}

function isTableExprRecordItem(n: Syntax.CstNode | Syntax.CstTableExprRecordItem): Syntax.CstTableExprRecordItem?
    return if (n :: Syntax.CstTableExprRecordItem).kind == "record" then n :: Syntax.CstTableExprRecordItem else nil
end

function isTypeTableItemProperty(n: Syntax.CstNode): Syntax.CstTableTypeItemProperty?
    return if n.kind == "type" and n.tag == "table" then n.entries else nil
end

local Parser = {}

function Parser.parseRecord(record: Syntax.CstTableTypeItemProperty)
    print(`    - {record.key.text} = {Printer.printNode(record.value)}`)
end

function Parser.parseExportTypes(node: Syntax.CstStatTypeAlias)
    assert(node.type.tag == "intersection", "expected combination of widget types")

    print(`- {node.name.text}`)

    for _, intersection in node.type.types do
        print(`  - {intersection.tag}`)

        if intersection.tag == "table" then
            for _, record in intersection.entries do
                assert(record.kind == "property", "expected widget properties")

                if record.key.text == "arguments" or record.key.text == "state" then
                    assert(record.value.tag == "table", "expected arguments to be a table")
                    print(`    - {record.key.text}`)
                    for _, subRecord in record.value.entries do
                        assert(subRecord.kind == "property", "expected key-values to be properties")
                        Parser.parseRecord(subRecord)
                    end
                else
                    Parser.parseRecord(record)
                end
            end
        end
    end

    return {}
end

function Parser.parseConst(node: Syntax.CstStatConst): Flags
    local variable = node.variables[1]
    local value = node.values[1]
    assert(value.tag == "table", "only parsing table consts")

    return {
        name = variable.name.text,
        entries = Query.findAllFromRoot(value, isTableExprRecordItem):mapToArray(function(record: Syntax.CstTableExprRecordItem): FlagEntry
            assert(record.value.tag == "number", "flag values must be integers")
            return {
                key = record.key.text,
                value = record.value.value,
            }
        end),
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

    print("\nParse exports:")
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
