-- HookFunction("OpenEgg", NewFunction) -- Function Name.
-- RestoreFunction("OpenEgg") -- Function Name.
-- IsHooked("OpenEgg")) -- Function Name.

if not shared.Functions then
    shared.Functions = {};
end

local function IsHooked(Function)
    if shared.Functions[Function] then
        return true;
    else
        return false;
    end
end


local function HookFunction(Function, NewFunction)
    if shared.Functions[Function] then
        return;
    end

     for _, Value in next, getgc(true) do
        if typeof(Value) == 'table' and rawget(Value, Function) then
            shared.Functions[Function] = Value[Function];
            hookfunction(Value[Function], (NewFunction or function()
                return;
            end))
        end
    end
end

local function RestoreFunction(Function)
    if not shared.Functions[Function] then
        return;
    end

    for _, Value in next, getgc(true) do
        if typeof(Value) == 'table' and rawget(Value, Function) then
            if shared.Functions[Function] then
                hookfunction(Value[Function], shared.Functions[Function]);
                shared.Functions[Function] = nil
            else
                return;
            end
        end
    end
end

return {
    IsHooked = IsHooked,
    HookFunction = HookFunction,
    RestoreFunction = RestoreFunction
};