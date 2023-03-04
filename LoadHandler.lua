local HandlersFolder = "https://github.com/Uvxtq/Custom-Lua-Functions/tree/main/Functions/Handlers";

local function ReplaceSpace(String)
    if String:find(" ") then
        return String:gsub(" ", "%%20");
    end
end

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
        FormattedFunctions[FunctionName:gsub(".lua", "")] = game:HttpGetAsync(Function);
    end

    return FormattedFunctions;
end


local function LoadHandler(Name)
    Name = ReplaceSpace(Name);
    local Functions = FormatFunctions();

    if typeof(Name) == "table" then
        local Handlers = {};

        for _, HandlerName in next, Name do
            if Functions[HandlerName] then
                Handlers[HandlerName] = loadstring(Functions[HandlerName])();
            else
                warn("Handler not found");
            end
        end

        return Handlers;
    end

    if Functions[Name] then
        return loadstring(Functions[Name])();
    end

    warn("Handler not found");
    return nil;
end

return LoadHandler;