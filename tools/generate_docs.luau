--[[
    This file was created using Claude AI. There have been some changes, but
    most of it is purely Claude-generated. The reasons for doing so were the
    unfamiliarity to using Lute and the lack of clear examples; the purpose to
    only generate comments and functions from existing code; and the aim to get
    a new version of Iris out sooner.

    In general, though, whilst I am not against AI, I am not interested in
    employing it for writing the actual Iris code. That can instead be left to
    humans who have a better understanding of the codebase and aims.

	generate_docs.luau

	A `lute transform` script (see https://lute.luau.org/guide/code-transforms.html).

	Usage:
		lute transform generate_docs.luau MyWidget.luau
			-- rewrites MyWidget.luau in place

		lute transform generate_docs.luau MyWidget.luau --output MyWidget.out.luau
			-- leaves MyWidget.luau untouched, writes the result elsewhere

		lute transform generate_docs.luau MyWidget.luau --dry-run
			-- prints what would change without writing anything

	Reads a .luau file containing declarations like:

		export type Tree = Types.ParentWidget & {
			arguments: { Label: string, -- comment
			             Flags: number?, -- comment
			},
			state: { open: Types.State<boolean>?, -- comment
			},
		} & Types.Opened & Types.Closed & Types.Hovered

		const TreeFlags = {
			SpanAvailWidth = 1, -- comment
		}

	...and inserts, IN PLACE:
		- a Moonwave-style `@interface` doc block directly above each
		  exported type and each const table it documents
		- an `API_<Name>` function stub + doc block appended at the
		  bottom of the file, one per exported type

	This assumes any previous doc comments above these declarations have
	already been removed -- it only ever inserts, it never tries to detect
	or delete existing `--[=[ ... ]=]` blocks.

	DESIGN NOTE
	-----------
	Lute's `@std/syntax` CST API is explicitly marked "still open to future
	evolution" (see https://lute.luau.org/std/syntax/). Rather than reaching
	into undocumented CST fields (exact field names for things like
	CstStatTypeAlias.type / CstTypeTable.items aren't published), this script
	only uses the parts of the API that ARE documented with stable signatures:

		query.findAllFromRoot   -- @std/syntax/query
		utils.isStatTypeAlias / utils.isStatConst -- @std/syntax/utils
		printer.printNode       -- @std/syntax/printer

	Lute (via `lute transform`) is used to reliably (a) parse the file and
	(b) find every top-level `export type ... = ...` and `const ... = ...`
	statement. `printer.printNode` then gives the *exact* original source
	text of each one (comments, whitespace and all, since CST round-trips
	exactly). That text is walked with small, fully-under-our-control string
	helpers below, instead of guessing at CST field names. The doc block is
	spliced back in as a `Replacements` entry keyed by that same node (see
	https://lute.luau.org/std/syntax/printer.html), and the generated
	functions are appended by keying a replacement off `ctx.parseresult.eof`.

	KNOWN LIMITATIONS (by design, to keep this predictable):
		- Assumes one field per physical line inside `{ ... }` bodies, with
		  any trailing comment on that same line (matches stylua formatting).
		- Doesn't handle generic type-alias parameters (`type Tree<T> = ...`).
		- `@tag` values beyond Widget/HasChildren/HasState, and the prose
		  description, aren't recoverable from syntax -- see TODOs in output.
]]

local Printer = require("@std/syntax/printer")
local Query = require("@std/syntax/query")
local Utils = require("@std/syntax/utils")
local Syntax = require("@std/syntax")

export type Context<Options = { [any]: any }> = {
    path: string,
    source: string,
    parseresult: Syntax.CstParseResult,
    options: Options,
}

local INDENT = "    "

--------------------------------------------------------------------------------
-- Configuration: project-specific conventions that can't be inferred from
-- syntax alone. Adjust these to match your codebase.
--------------------------------------------------------------------------------

-- Base types (from the trailing `& Types.X` list) that should be documented
-- as boolean-returning accessor methods instead of `.& Name` extensions.
local TRAIT_TYPES: { [string]: string } = {
    Hovered = "hovered",
    Clicked = "clicked",
    RightClicked = "rightClicked",
    DoubleClicked = "doubleClicked",
    CtrlClicked = "ctrlClicked",
    Active = "active",
    Checked = "checked",
    Unchecked = "unchecked",
    Opened = "opened",
    Closed = "closed",
    Collapsed = "collapsed",
    Uncollapsed = "uncollapsed",
    Selected = "selected",
    Unselected = "unselected",
    Changed = "changed",
    Editing = "editing",
}

-- Base types that imply a doc @tag when extended.
local BASE_TYPE_TAGS: { [string]: string } = {
    ParentWidget = "HasChildren",
}

-- Module prefix stripped from type references when rendering docs.
local TYPE_MODULE_PREFIX = "Types."

--------------------------------------------------------------------------------
-- Small text helpers. These operate on text that Lute has already produced
-- via printer.printNode, so it's guaranteed to be exact, valid Luau source.
--------------------------------------------------------------------------------

local function trim(s: string): string
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function stripOuterBraces(s: string): string
    s = trim(s)
    if s:sub(1, 1) == "{" and s:sub(-1) == "}" then
        return trim(s:sub(2, -2))
    end
    return s
end

local function stripModulePrefix(typeText: string): string
    if typeText:sub(1, #TYPE_MODULE_PREFIX) == TYPE_MODULE_PREFIX then
        return typeText:sub(#TYPE_MODULE_PREFIX + 1)
    end
    return typeText
end

local function stripOptional(typeText: string): (string, boolean)
    if typeText:sub(-1) == "?" then
        return trim(typeText:sub(1, -2)), true
    end
    return typeText, false
end

-- Splits `s` on top-level occurrences of the single-character `sep`,
-- ignoring separators nested inside (), {}, [], or <...> generics.
-- Used only for the "&"-joined intersection list, where each member is
-- reliably separated by whitespace on either side.
local function splitTopLevel(s: string, sep: string): { string }
    local parts: { string } = {}
    local depth = 0
    local current: { string } = {}
    for i = 1, #s do
        local c = s:sub(i, i)
        if c == "(" or c == "{" or c == "[" or c == "<" then
            depth += 1
        elseif c == ")" or c == "}" or c == "]" or c == ">" then
            depth -= 1
        end
        if c == sep and depth == 0 then
            table.insert(parts, table.concat(current))
            current = {}
        else
            table.insert(current, c)
        end
    end
    table.insert(parts, table.concat(current))
    for idx, p in parts do
        parts[idx] = trim(p)
    end
    return parts
end

--------------------------------------------------------------------------------
-- Field parsing: turns the text of a `{ ... }` body into an ordered list of
-- { name, valueText, optional, comment }. Handles one level of nesting
-- (e.g. `arguments: { ... }` inside the outer type body) by tracking brace
-- depth across physical lines.
--------------------------------------------------------------------------------

type Field = {
    name: string,
    valueText: string,
    optional: boolean,
    comment: string?,
    default: string?,
}

local function parseFields(bodyText: string): { Field }
    local inner = stripOuterBraces(bodyText)
    local lines: { string } = {}
    for line in (inner .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(lines, line)
    end

    local fields: { Field } = {}
    local i = 1
    while i <= #lines do
        local line = lines[i]
        if #trim(line) > 0 then
            local buffer = { line }
            local depth = 0
            for c in line:gmatch(".") do
                if c == "{" then
                    depth += 1
                elseif c == "}" then
                    depth -= 1
                end
            end

            local j = i
            while depth > 0 and j < #lines do
                j += 1
                local nextLine = lines[j]
                table.insert(buffer, nextLine)
                for c in nextLine:gmatch(".") do
                    if c == "{" then
                        depth += 1
                    elseif c == "}" then
                        depth -= 1
                    end
                end
            end
            i = j

            local lastLine = buffer[#buffer]
            local comment = lastLine:match("%-%-%s*(.-)%s*$")
            local default: string?
            if comment then
                local commentPos = lastLine:find("%-%-") :: number
                default = comment:match("%(default: (.+)%)")
                buffer[#buffer] = lastLine:sub(1, commentPos - 1)
            end

            local code = trim(table.concat(buffer, "\n")):gsub(",%s*$", "")
            code = trim(code)

            local name, rawValue = code:match("^([%w_]+)%s*:%s*(.+)$")
            if name and rawValue and name:sub(1, 1) ~= "_" then
                local valueText, optional = stripOptional(trim(rawValue))
                table.insert(fields, {
                    name = name,
                    valueText = valueText,
                    optional = optional,
                    comment = comment and comment ~= "" and comment or nil,
                    default = default,
                })
            end
        end
        i += 1
    end

    return fields
end

--------------------------------------------------------------------------------
-- Const table parsing: `const NAME = { KEY = VALUE, -- comment ... }`
--------------------------------------------------------------------------------

type ConstEntry = { name: string, value: string, comment: string? }

local function parseConstStat(_node: Syntax.CstStatConst, statText: string): (string?, { ConstEntry })
    -- printer.printNode includes the node's leading trivia (blank lines,
    -- comments), so trim before anchoring on `^const`.
    statText = trim(statText)
    local name, rest = statText:match("^const%s+([%w_]+)%s*=%s*(.+)$")
    if not name or not rest then
        return nil, {}
    end

    rest = trim(rest):gsub(";%s*$", "")
    local inner = stripOuterBraces(rest)

    local entries: { ConstEntry } = {}
    for line in (inner .. "\n"):gmatch("([^\n]*)\n") do
        if #trim(line) > 0 then
            local comment = line:match("%-%-%s*(.-)%s*$")
            local code = line
            if comment then
                code = line:sub(1, (line:find("%-%-") :: number) - 1)
            end
            code = trim(code):gsub(",%s*$", "")
            code = trim(code)

            local entryName, entryValue = code:match("^([%w_]+)%s*=%s*(.+)$")
            if entryName and entryValue then
                table.insert(entries, {
                    name = entryName,
                    value = trim(entryValue),
                    comment = comment and comment ~= "" and comment or nil,
                })
            end
        end
    end

    return name, entries
end

--------------------------------------------------------------------------------
-- Exported type parsing: `export type NAME = Base & { arguments: {...},
-- state: {...} } & Trait & ...`
--------------------------------------------------------------------------------

type ParsedType = {
    name: string,
    extends: { string },
    events: { string },
    sections: { [string]: { Field } },
    sectionOrder: { string },
}

local function parseExportedType(_node: Syntax.CstStatTypeAlias, statText: string): ParsedType?
    -- printer.printNode includes the node's leading trivia (blank lines,
    -- comments), so trim before anchoring on `^export`.
    statText = trim(statText)
    local name = statText:match("^export%s+type%s+([%w_]+)")
    if not name then
        return nil
    end

    local eqPos = statText:find("=", 1, true)
    if not eqPos then
        return nil
    end
    local rhs = trim(statText:sub(eqPos + 1)):gsub(";%s*$", "")

    local extends: { string } = {}
    local events: { string } = {}
    local sections: { [string]: { Field } } = {}
    local sectionOrder: { string } = {}

    for _, part in splitTopLevel(rhs, "&") do
        if part:sub(1, 1) == "{" then
            for _, field in parseFields(part) do
                sections[field.name] = parseFields(field.valueText)
                table.insert(sectionOrder, field.name)
            end
        elseif #part > 0 then
            local ref = stripModulePrefix(part)
            if TRAIT_TYPES[ref] then
                table.insert(events, TRAIT_TYPES[ref])
            else
                table.insert(extends, ref)
            end
        end
    end

    return {
        name = name,
        extends = extends,
        events = events,
        sections = sections,
        sectionOrder = sectionOrder,
    }
end

--------------------------------------------------------------------------------
-- Rendering
--------------------------------------------------------------------------------

local function renderTypeDoc(t: ParsedType): string
    local lines = { "--[=[", INDENT .. "@within [TODO]", INDENT .. `@interface {t.name}` }

    for _, ext in t.extends do
        table.insert(lines, `{INDENT}.& {ext}`)
    end
    for _, method in t.events do
        table.insert(lines, `{INDENT}.{method} () -> boolean`)
    end

    table.insert(lines, "")

    for _, sectionName in t.sectionOrder do
        local fields = t.sections[sectionName]
        if #fields > 0 then
            local rendered = {}
            for _, f in fields do
                table.insert(rendered, `{f.name}: {stripModulePrefix(f.valueText)}`)
            end
            -- NOTE: built with `..` rather than backtick interpolation,
            -- because a literal "{" right after an interpolation `{` is
            -- itself parsed as the start of a table constructor by Luau,
            -- not literal text.
            table.insert(lines, INDENT .. "." .. sectionName .. " { " .. table.concat(rendered, ", ") .. " }")
        end
    end

    table.insert(lines, "]=]")
    return table.concat(lines, "\n")
end

local function renderConstDoc(name: string, entries: { ConstEntry }): string
    local lines = { "--[=[", INDENT .. "@within [TODO]", INDENT .. `@interface {name}` }
    for _, e in entries do
        local line = `{INDENT}.{e.name} {e.value}`
        if e.comment then
            line ..= ` -- {e.comment}`
        end
        table.insert(lines, line)
    end
    table.insert(lines, "]=]")
    return table.concat(lines, "\n")
end

type ApiParam = {
    name: string,
    docType: string,
    sigType: string,
    optional: boolean,
    comment: string?,
    callExpr: string,
}

-- constTables: name -> true, just used to check whether a "<Type><Field>"
-- const table exists (e.g. "TreeFlags") to use as the friendlier doc type
-- for a numeric `arguments` field named e.g. "Flags".
local function computeParams(t: ParsedType, constTableNames: { [string]: boolean }): { ApiParam }
    local params: { ApiParam } = {}

    for _, sectionName in { "arguments", "state" } do
        local fields = t.sections[sectionName]
        if fields then
            for _, f in fields do
                local paramName = f.name:sub(1, 1):lower() .. f.name:sub(2)
                local docType = stripModulePrefix(f.valueText)
                local sigType = f.valueText
                local callExpr = paramName

                if sectionName == "state" and f.valueText:sub(1, #TYPE_MODULE_PREFIX) == TYPE_MODULE_PREFIX then
                    -- e.g. Types.State<boolean> -> Types.APIState<boolean> in the
                    -- function signature, while the doc keeps the friendlier name.
                    sigType = TYPE_MODULE_PREFIX .. "API" .. f.valueText:sub(#TYPE_MODULE_PREFIX + 1)
                end

                if sectionName == "arguments" and f.valueText == "number" and f.optional then
                    local constName = t.name .. f.name
                    if constTableNames[constName] then
                        docType = constName
                    end
                    callExpr = `{paramName} or 0`
                end

                table.insert(params, {
                    name = paramName,
                    docType = docType,
                    sigType = sigType,
                    optional = f.optional,
                    comment = f.comment,
                    callExpr = callExpr,
                })
            end
        end
    end

    return params
end

local function renderApiFunction(t: ParsedType, constTableNames: { [string]: boolean }): string
    local params = computeParams(t, constTableNames)

    local tags = { "Widget" }
    for _, ext in t.extends do
        if BASE_TYPE_TAGS[ext] then
            table.insert(tags, BASE_TYPE_TAGS[ext])
        end
    end
    if t.sections["state"] and #t.sections["state"] > 0 then
        table.insert(tags, "HasState")
    end

    local docLines = { "--[=[", INDENT .. "@within [TODO]" }
    for _, tag in tags do
        table.insert(docLines, `{INDENT}@tag {tag}`)
    end
    table.insert(docLines, "")
    table.insert(docLines, `{INDENT}@function {t.name}`)
    for _, p in params do
        local line = `{INDENT}@param {p.name} {p.docType}{p.optional and "?" or ""}`
        if p.comment then
            line ..= ` -- {p.comment}`
        end
        table.insert(docLines, line)
    end
    table.insert(docLines, "")
    table.insert(docLines, `{INDENT}@return {t.name}`)
    table.insert(docLines, "")
    -- Free-text descriptions aren't recoverable from the type declaration --
    -- fill this in by hand, or extend the parser to read it from a leading
    -- `---` comment block above `export type ... = ...` in the source file.
    table.insert(docLines, `{INDENT}[TODO] describe {t.name} here.`)
    table.insert(docLines, "]=]")

    local sigParams, callArgs = {}, {}
    for _, p in params do
        table.insert(sigParams, `{p.name}: {p.sigType}{p.optional and "?" or ""}`)
        table.insert(callArgs, p.callExpr)
    end

    local code = table.concat({
        `const API_{t.name} = function({table.concat(sigParams, ", ")})`,
        `{INDENT}return Internal._insert("{t.name}", {table.concat(callArgs, ", ")}) :: {t.name}`,
        "end",
    }, "\n")

    return table.concat(docLines, "\n") .. "\n" .. code
end

--------------------------------------------------------------------------------
-- Transform entry point (see the Context type in
-- https://lute.luau.org/guide/code-transforms.html). `lute transform`
-- supplies `ctx`, applies the returned Replacements via printer.printFile,
-- and writes the result back (in place, or to --output).
--------------------------------------------------------------------------------

local function transform(ctx: Context): { [any]: string }
    local parseResult = ctx.parseresult

    local typeAliasNodes = Query.findAllFromRoot(parseResult, Utils.isStatTypeAlias):mapToArray(function(n)
        return if n.export ~= nil then n else nil
    end)
    local constNodes = Query.findAllFromRoot(parseResult, Utils.isStatConst):mapToArray(function(n)
        if #n.values == 1 then
            return n.values[1].tag == "table" and n or nil
        end
        return nil
    end)

    -- First pass: parse every const table (need all their names up front,
    -- since a type's `arguments.Flags` field cross-references a sibling
    -- `<Type>Flags` const table by name -- see computeParams above).
    local parsedConsts: { { node: any, name: string, entries: { ConstEntry } } } = {}
    local constTableNames: { [string]: boolean } = {}
    for _, node in constNodes do
        local name, entries = parseConstStat(node, Printer.printNode(node))
        if name then
            table.insert(parsedConsts, { node = node, name = name, entries = entries })
            constTableNames[name] = true
        end
    end

    -- First pass, continued: parse every exported type.
    local parsedTypes: { { node: any, parsed: ParsedType } } = {}
    for _, node in typeAliasNodes do
        local parsed = parseExportedType(node, Printer.printNode(node))
        if parsed then
            table.insert(parsedTypes, { node = node, parsed = parsed })
        end
    end

    local replacements: { [any]: string } = {}

    -- Second pass: splice a doc block in directly above each const table...
    --
    -- NOTE: printer.printFile already reproduces a replaced node's original
    -- surrounding trivia (e.g. the blank line separating it from the
    -- previous statement) on its own. Including that trivia *again* inside
    -- the replacement string (e.g. via leading/trailing whitespace captured
    -- from printer.printNode) double-counts it and produces extra blank
    -- lines -- confirmed empirically. So the replacement value here is just
    -- "doc block, then the statement's own trimmed text", nothing else.
    for _, c in parsedConsts do
        replacements[c.node] = renderConstDoc(c.name, c.entries) .. "\n" .. trim(Printer.printNode(c.node))
    end

    -- ...and directly above each exported type.
    for _, t in parsedTypes do
        replacements[t.node] = renderTypeDoc(t.parsed) .. "\n" .. trim(Printer.printNode(t.node))
    end

    -- Append the generated API function + doc block for each type at the
    -- very bottom of the file, after anything already there (by keying a
    -- replacement off the EOF token -- see printer.printFile).
    local functionBlocks: { string } = {}
    for _, t in parsedTypes do
        table.insert(functionBlocks, renderApiFunction(t.parsed, constTableNames))
    end
    if #functionBlocks > 0 then
        -- As above: printFile already reproduces one natural line break at
        -- this boundary on its own, so a single extra "\n" here (not "\n\n")
        -- is what actually yields exactly one blank line before the
        -- appended block, matching the blank-line spacing used elsewhere.
        replacements[parseResult.eof] = Printer.printNode(parseResult.eof) .. "\n" .. table.concat(functionBlocks, "\n\n") .. "\n"
    end

    return replacements
end

return transform
