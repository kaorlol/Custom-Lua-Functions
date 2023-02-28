local HandlersFolder = "https://github.com/Uvxtq/Custom-Lua-Functions/tree/main/Functions/Handlers";

local function MakeRaw(Url)
    local NoBlob = Url:gsub("/blob", "");

    return string.format("https://raw.githubusercontent.com%s", NoBlob);
end

local function GetHandlers(Url)
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
    local Functions = GetHandlers(HandlersFolder);

    for _, Function in next, Functions do
        local FunctionName = Function:match("([^/]+)$");
        FormattedFunctions[FunctionName:gsub(".lua", "")] = loadstring(game:HttpGetAsync(Function))();
    end

    return FormattedFunctions;
end


local function LoadHandler(Name)
    local Handlers = FormatFunctions();

    if Handlers[Name] then
        return Handlers[Name];
    end

    warn("Handler not found");
    return nil;
end

return LoadHandler;