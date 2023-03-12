local FunctionsFolder = "https://github.com/Uvxtq/Custom-Lua-Functions/tree/main/Functions";

local function ReplaceSpace(String)
    if String:find(" ") and not String:find("%%20") then
        return String:gsub(" ", "%%20");
    end
end

local function MakeRaw(Url)
    local NoBlob = Url:gsub("/blob", "");

    return string.format("https://raw.githubusercontent.com%s", NoBlob);
end

local function GetFunctions(Url)
	local Response = game:HttpGetAsync(Url);
	local Files = {};

	for File in string.gmatch(Response, 'href="([^"]+)"') do
		if string.find(File, "blob") then
			table.insert(Files, MakeRaw(File));
		end
    end

    return Files;
end

local function FormatFunctions()
    local FormattedFunctions = {};
    local Functions = GetFunctions(FunctionsFolder);

    for _, Function in next, Functions do
        local FunctionName = Function:match("([^/]+)$");
        FormattedFunctions[FunctionName:gsub(".lua", "")] = game:HttpGetAsync(Function);
    end

    return FormattedFunctions;
end

local function LoadFunction(Name)
    local FormatedFunctions = FormatFunctions();

    if typeof(Name) == "table" then
        local Functions = {};

        for _, FunctionName in next, Name do
            Name = ReplaceSpace(FunctionName);

            if FormatedFunctions[Name] then
                Functions[Name] = loadstring(FormatedFunctions[Name])();
            else
                warn(string.format("Function %s not found", Name));
            end
        end

        return Functions;
    end

    Name = ReplaceSpace(Name);

    if FormatedFunctions[Name] then
        return loadstring(FormatedFunctions[Name])();
    end

    warn(string.format("Function %s not found", Name));
    return nil;
end

return LoadFunction;