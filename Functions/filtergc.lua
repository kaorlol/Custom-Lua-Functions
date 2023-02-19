local Tick = tick();

local is_executor_function = is_synapse_function or iskrnlclosure or isourclosure or isexecutorclosure or "Executor not supported.";
local getgc = getgc or "Executor not supported.";

if is_executor_function == "Executor not supported." then
    return warn("Executor not supported.");
end

if getgc == "Executor not supported." then
    return warn("Executor not supported.")
end

local function NewTableFind(Table, Want)
    for _, Value in next, Table do
        if Value == Want then
            return Value;
        end
    end

    return nil;
end

local Checks = {
    ['function'] = function(Object, Data)
        local Name, Constants, Upvalues, IgnoreSyn = (Data.Name), (Data.Constants or {}), (Data.Upvalues or {}), (Data.IgnoreSyn == nil) and true or false;
        local ObjectName, ObjectConstants, ObjectUpvalues, ObjectIsSyn = (debug.getinfo(Object).name), (islclosure(Object) and debug.getconstants(Object) or {}), (debug.getupvalues(Object) or {}), (is_executor_function(Object));

        if IgnoreSyn and ObjectIsSyn then
            return false;
        end

        if Name and ObjectName and Name ~= ObjectName then
            return false;
        end

        for _, Constant in next, Constants do
            if not NewTableFind(ObjectConstants, Constant) then
                return false;
            end
        end

        for _, Upvalue in next, Upvalues do
            if not NewTableFind(ObjectUpvalues, Upvalue) then
                return false;
            end
        end

        return true;
    end,

    ['table'] = function(Object, Data)
        local Keys, Values, KeyValuePairs, Metatable = (Data.Keys or {}), (Data.Values or {}), (Data.KeyValuePairs or {}), (Data.Metatable or {});

        local ObjectMetatable = getrawmetatable(Object)
        if ObjectMetatable then
            for Index, Value in next, ObjectMetatable do
                if (Metatable[Index] ~= Value) then
                    return false;
                end
            end
        end

        for _, Key in next, Keys do
            if not Object[Key] then
                return false;
            end
        end

        for _, Value in next, Values do
            if not NewTableFind(Object, Value) then
                return false;
            end
        end

        for Index, KeyValue in next, KeyValuePairs do
            local Other = Object[Index];

            if Other ~= KeyValue then
                return false;
            end
        end

        return true;
    end,
}

local filtergc = function(Type, Data, One)
    local Results = {};

    for _, Value in next, getgc(true) do
        if typeof(Value) == Type then
            if Checks[Type](Value, Data) then
                if One then
                    return Value;
                end

                table.insert(Results, Value);
            end
        end
    end

    return Results;
end

print(string.format("Loaded filtergc in %.3f seconds.", tick() - Tick));

return filtergc