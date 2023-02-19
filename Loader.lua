local FunctionsFolder = "https://github.com/Uvxtq/Lua-Functions/tree/main/Functions";

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

    for _, Function in pairs(Functions) do
        local FunctionName = Function:match("([^/]+)$");
        FormattedFunctions[FunctionName:gsub(".lua", "")] = loadstring(game:HttpGetAsync(Function));
    end

    return FormattedFunctions;
end

return FormatFunctions();