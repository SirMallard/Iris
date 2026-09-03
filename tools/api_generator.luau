const Syntax = require("@std/syntax")
const Query = require("@std/syntax/query")
const Visitor = require("@std/syntax/visitor")
local repr = require("./repr")

export type Context<Options = { [any]: any }> = {
    path: string,
    source: string,
    parseresult: Syntax.ParseResult,
    options: Options,
}

function formatSpan(location: Syntax.Span)
    return `{location.beginLine}:{location.beginColumn} - {location.endLine}:{location.endColumn}`
end

function getSpan(location: Syntax.Span, lines: { string })
    return lines[location.beginLine]:sub(location.beginColumn, location.endColumn)
end

--[[
    EXPLAINED KINDS
    - attribute
        @native, @deprecated, @checked
    - typepack
        list of types
        tag: "explicit" | "variadic" | "generic"
        variadic: an number of values ...
        generic: 
    - type
        forms of types: union, intersection, optional, 
    - local
        local variable
    - stat
        statement as a line
    - expr
        expression
    - 


    # ignore
    - attribute
    - typepack

]]

local function transformQuery(context: Context)
    local lines = context.source:split("\n")

    local visitor = Visitor.create(function(literal): boolean
        return false
    end)

    function visitor.visitStatBlock(_)
        return true
    end

    function visitor.visitStatTypeAlias(literal)
        print(`\n{literal.name.text}`)

        return true
    end

    function visitor.visitTypeIntersection(literal)
        print(`\t{literal.leading and literal.leading.text or ""}`)
        return true
    end

    function visitor.visitTypeTable(literal)
        for _, entry in literal.entries do
            if entry.key.kind == "token" then
                print(entry.key.text)
            end
        end
        return false
    end

    Visitor.visit(context.parseresult.root, visitor)
end

return transformQuery
