--- repr - Version 1.2
-- Ozzypig - ozzypig.com - http://twitter.com/Ozzypig
-- Check out this thread for more info:
-- https://devforum.roblox.com/t/repr-function-for-printing-tables/276575
--[[
 
local repr = require(3148021300)

local myTable = {
	hello = "world",
	score = 5,
	isCool = true
}
print(repr(myTable)) --> {hello = "world", isCool = true, score = 5}
 
]]

local defaultSettings = {
    pretty = true,
    tabs = true,
    semicolons = false,
    spaces = 4,
    sortKeys = true,
}

-- lua keywords
local keywords = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,
}

local function isLuaIdentifier(str: string): boolean
    if type(str) ~= "string" then
        return false
    end
    -- must be nonempty
    if str:len() == 0 then
        return false
    end
    -- can only contain a-z, A-Z, 0-9 and underscore
    if str:find("[^%d%a_]") then
        return false
    end
    -- cannot begin with digit
    if tonumber(str:sub(1, 1)) then
        return false
    end
    -- cannot be keyword
    if keywords[str] then
        return false
    end
    return true
end

-- works like Instance:GetFullName(), but invalid Lua identifiers are fixed (e.g. workspace["The Dude"].Humanoid)
local function properFullName(object: Instance)
    if object == nil or object == game then
        return ""
    end

    local s = object.Name
    local usePeriod = true
    if not isLuaIdentifier(s) then
        s = ("[%q]"):format(s)
        usePeriod = false
    end

    if not object.Parent or object.Parent == game then
        return s
    else
        return properFullName(object.Parent) .. (usePeriod and "." or "") .. s
    end
end

local depth = 0
local shown: { [{}]: boolean }
local INDENT

local function repr(value: unknown, reprSettings: any): string
    reprSettings = reprSettings or defaultSettings
    INDENT = (" "):rep(reprSettings.spaces or defaultSettings.spaces)
    if reprSettings.tabs then
        INDENT = "\t"
    end

    local v = value --args[1]
    local tabs = INDENT:rep(depth)

    if depth == 0 then
        shown = {}
    end
    if type(v) == "string" then
        return ("%q"):format(v)
    elseif type(v) == "number" then
        if v == math.huge then
            return "math.huge"
        end
        if v == -math.huge then
            return "-math.huge"
        end
        return tostring(v)
    elseif type(v) == "boolean" then
        return tostring(v)
    elseif type(v) == "nil" then
        return "nil"
    elseif type(v) == "table" and type(v.__tostring) == "function" then
        return tostring(v.__tostring(v))
    elseif type(v) == "table" and getmetatable(v) and type(getmetatable(v).__tostring) == "function" then
        return tostring(getmetatable(v).__tostring(v))
    elseif type(v) == "table" then
        if shown[v] then
            return "{CYCLIC}"
        end
        shown[v] = true
        local str = "{" .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or "")
        local isArray = true
        for k, v in pairs(v) do
            if type(k) ~= "number" then
                isArray = false
                break
            end
        end
        if isArray then
            for i = 1, #v do
                if i ~= 1 then
                    str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
                end
                depth = depth + 1
                str = str .. repr(v[i], reprSettings)
                depth = depth - 1
            end
        else
            local keyOrder = {}
            local keyValueStrings = {}
            for k, v in pairs(v) do
                depth = depth + 1
                local kStr = isLuaIdentifier(k) and tostring(k) or "[" .. repr(k, reprSettings) .. "]"
                local vStr = repr(v, reprSettings)
                --[[str = str .. ("%s = %s"):format(
					isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]"),
					repr(v, reprSettings)
				)]]
                table.insert(keyOrder, kStr)
                keyValueStrings[kStr] = vStr
                depth = depth - 1
            end
            if reprSettings.sortKeys then
                table.sort(keyOrder)
            end
            local first = true
            for _, kStr in pairs(keyOrder) do
                if not first then
                    str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
                end
                str = str .. ("%s = %s"):format(kStr, keyValueStrings[kStr])
                first = false
            end
        end
        shown[v] = false
        if reprSettings.pretty then
            str = str .. "\n" .. tabs
        end
        str = str .. "}"
        return str
    else
        return "<" .. type(v) .. ">"
    end
end

return repr
