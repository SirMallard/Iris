local Parser = require("./parser")

local function transform(context: Parser.Context): { [string]: string }
    Parser.parseWidget(context)

    return {}
end

return transform
