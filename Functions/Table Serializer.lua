local Tab = "    ";
local Serialize, SerializeCompress = nil, nil;

local function SerializeArgs(...)
    local Serialized = {};

    for i = 1, select("#", ...) do
        local Value = select(i, ...);
        local Type = typeof(Value);

        if Type == "string" then
            Serialized[i] = string.format("\"%s\"", Value);
        elseif Type == "table" then
            Serialized[i] = Serialize(Value);
        else
            Serialized[i] = tostring(Value);
        end;
    end;

    return table.concat(Serialized, ", ");
end

local function FormatFunction(Function)
    if debug.getinfo(Function) then
        local Proto = debug.getinfo(Function);
        local Params = {};

        if Proto.numparams then
            for i = 1, Proto.numparams do
                Params[i] = string.format("p%d", i);
            end
            if Proto.is_vararg then
                Params[#Params + 1] = "...";
            end
        end

        local FuncName = Proto.name or ""
        return string.format("function(%s) --[[ Function Name: %s, Type: %s ]] -- end", table.concat(Params, ", "), FuncName ~= "" and ("\"" .. FuncName .. "\"") or "ANONYMOUS", Proto.what);
    end

    return "function()end";
end

local function FormatString(String)
    local Position = 0;
    local Formatted = {};

    while Position <= #String do
        local Key = string.sub(String, Position, Position);
        if Key == "\n" then
            Formatted[Position] = "\\n";
        elseif Key == "\t" then
            Formatted[Position] = "\\t";
        elseif Key == "\"" then
            Formatted[Position] = "\\\"";
        else
            Formatted[Position] = Key;
        end
        Position += 1;
    end

    return table.concat(Formatted);
end

local function FormatNumber(Number)
    if Number == math.huge then
        return "math.huge";
    elseif Number == -math.huge then
        return "-math.huge";
    elseif Number ~= Number then
        return "0/0";
    end

    return tostring(Number);
end

local function FormatIndex(Index, Scope)
    local IndexType = typeof(Index);
    local FinishedFormat = Index;

    if IndexType == "string" then
        if string.match(Index, "[^_%a%d]+") then
            FinishedFormat = string.format("[\"%s\"]", FormatString(Index));
        else
            return string.format("\"%s\"", FormatString(Index));
        end
    elseif IndexType == "table" then
        if not Scope then
            Scope = SerializeCompress(Index);
        end

        if Scope[Index] then
            return string.format("\"%s -- recursive table\"", tostring(Index));
        end

        Scope[Index] = true;
        FinishedFormat = Serialize(Index, Scope);
    end

    return FinishedFormat;
end

function SerializeCompress(Table, Checked)
    Checked = Checked or {};

    if Checked[Table] then
        return string.format("\"%s -- recursive table\"", tostring(Table));
    end

    Checked[Table] = true;

    local Serialized = {};
    local TableLength = 0;

    for Index, Value in next, Table do
        local FormattedIndex = FormatIndex(Index);
        local ValueType = typeof(Value);

        if ValueType == "string" then
            if typeof(FormattedIndex) == "string" then
                Serialized[TableLength + 1] = string.format("[%s] = \"%s\",\n", FormattedIndex, FormatString(Value));
            else
                Serialized[TableLength + 1] = string.format("\"%s\",\n", FormatString(Value));
            end
        elseif ValueType == "table" then
            Serialized[TableLength + 1] = string.format("%s,\n", SerializeCompress(Value, Checked));
        elseif ValueType == "number" then
            Serialized[TableLength + 1] = string.format("%s,\n", FormatNumber(Value));
        elseif ValueType == "boolean" then
            Serialized[TableLength + 1] = string.format("%s,\n", tostring(Value));
        elseif ValueType == "function" then
            Serialized[TableLength + 1] = string.format("%s,\n", FormatFunction(Value));
        end

        TableLength += 1;
    end

    local LastValue = Serialized[#Serialized];
    if LastValue then
        Serialized[#Serialized] = string.sub(LastValue, 0, -3) .. "\n";
    end

    return string.format("{%s}", table.concat(Serialized));
end

function Serialize(Table, Scope, Checked)
    Checked = Checked or {};

    if Checked[Table] then
        return string.format("\"%s -- recursive table\"", tostring(Table));
    end

    Checked[Table] = true;

    local Serialized = {};
    local TableLength = 0;

    Scope = Scope or 0;
    local ScopeTab = string.rep(Tab, Scope);
    local ScopeTab2 = string.rep(Tab, Scope + 1);

    for Index, Value in next, Table do
        local FormattedIndex = FormatIndex(Index, Scope);
        local ValueType = typeof(Value);

        if ValueType == "string" then
            if typeof(FormattedIndex) == "string" then
                Serialized[TableLength + 1] = string.format("%s[%s] = \"%s\",\n", ScopeTab2, FormattedIndex, FormatString(Value));
            else
                Serialized[TableLength + 1] = string.format("%s\"%s\",\n", ScopeTab2, FormatString(Value));
            end
        elseif ValueType == "table" then
            Serialized[TableLength + 1] = string.format("%s%s,\n", ScopeTab2, Serialize(Value, Scope + 1, Checked));
        elseif ValueType == "number" then
            Serialized[TableLength + 1] = string.format("%s%s,\n", ScopeTab2, FormatNumber(Value));
        elseif ValueType == "boolean" then
            Serialized[TableLength + 1] = string.format("%s%s,\n", ScopeTab2, tostring(Value));
        elseif ValueType == "function" then
            Serialized[TableLength + 1] = string.format("%s%s,\n", ScopeTab2, FormatFunction(Value));
        end

        TableLength += 1;
    end

    local LastValue = Serialized[#Serialized];
    if LastValue then
        Serialized[#Serialized] = string.sub(LastValue, 0, -3) .. "\n";
    end

    if TableLength > 0 then
        if Scope < 1 then
            return string.format("{\n%s}", table.concat(Serialized));
        else
            return string.format("{\n%s%s}", table.concat(Serialized), ScopeTab);
        end
    else
        return "{}";
    end
end

return function(...)
    local Args = {...};
    local ArgsLength = select("#", ...);

    if ArgsLength == 1 then
        return Serialize(Args[1]);
    else
        return SerializeArgs(...);
    end
end