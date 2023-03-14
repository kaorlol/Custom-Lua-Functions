--[[
    -- << Documentation: >> --
        Helper.new(); --> Helper
        Helper:Load(); --> Knit
        Helper:GetControllers(); --> Controllers
        Helper:GetController(Controller); --> ControllerContents
        Helper:GetServices(); --> Services
        Helper:GetService(Service); --> ServiceContents
        Helper:DumpKnit(); --> Dumped to Console
        Helper:DumpToFile(); --> Dumped to KnitHelper.txt

    -- << Example: >> --
        local Helper = Helper.new(); --> Creates a new Helper
        Helper:Load(); --> Loads Knit (Can also be in a variable to check if it loaded)
        Helper:DumpKnit(); --> Dumps Controllers to the console
        Helper:DumpToFile(); --> Dumps Controllers to KnitHelper.txt
]]

-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- << Functions >> --
local function Concat(Table)
	local Formatted = {};
	local Position = 1;

	for _, Value in next, Table do
		if typeof(Value) ~= "string" then continue; end
		if Value:match("^%s*$") then continue; end
		if not string.find(Value, "%w") then continue; end

		Formatted[Position] = Value;
		Position += 1;
	end

	return table.concat(Formatted, ", ");
end

local function Filter(Type, Table)
	if typeof(Table) ~= "table" then return Table; end
	if Type == "Constants" then
		local Constants = {};

		for _, Constant in next, Table do
			if typeof(Constant) == "function" then
				table.insert(Constants, debug.getinfo(Constant).name);
			elseif typeof(Constant) == "table" then
				table.insert(Constants, string.format("table: {%s}", Concat(Constant)));
			elseif typeof(Constant) == "string" then
				table.insert(Constants, string.format("%s", Constant));
			else
				table.insert(Constants, tostring(Constant));
			end
		end

		return Constants;
	end

	if Type == "Upvalues" then
		local Upvalues = {};

		for _, Upvalue in next, Table do
			if typeof(Upvalue) == "function" then
				table.insert(Upvalues, debug.getinfo(Upvalue).name);
			elseif typeof(Upvalue) == "table" then
				table.insert(Upvalues, string.format("table: {%s}", Concat(Upvalue)));
			elseif typeof(Upvalue) == "string" then
				table.insert(Upvalues, string.format('"%s"', Upvalue));
			else
				table.insert(Upvalues, tostring(Upvalue));
			end
		end

		return Upvalues;
	end

	if Type == "Protos" then
		local Protos = {};

		for _, Proto in next, Table do
			if typeof(Proto) == "function" then
				table.insert(Protos, debug.getinfo(Proto).name);
			elseif typeof(Proto) == "table" then
				table.insert(Protos, string.format("table: {%s}", Concat(Proto)));
			elseif typeof(Proto) == "string" then
				table.insert(Protos, string.format('"%s"', Proto));
			else
				table.insert(Protos, tostring(Proto));
			end
		end

		return Protos;
	end
end

local function GetFunctionData(Function)
	if typeof(Function) ~= "function" then
		return nil, "Function is not a function";
	end

	local Info = debug.getinfo(Function);
	local Protos = debug.getprotos(Function);
	local Upvalues = debug.getupvalues(Function);
	local Constants = debug.getconstants(Function);

	return {
		Info = Info,
		Protos = Filter("Protos", Protos),
		Upvalues = Filter("Upvalues", Upvalues),
		Constants = Filter("Constants", Constants)
	}
end

local function FormatInfo(Function)
	if typeof(Function) ~= "function" then
		return nil, "Function is not a function";
	end

	local Data = GetFunctionData(Function);

	if Data then
		local Info = Data.Info;
		local Protos = Filter("Protos", Data.Protos);
		local Upvalues = Filter("Upvalues", Data.Upvalues);
		local Constants = Filter("Constants", Data.Constants);

		return string.format(
			"{\n            Path: %s,\n            Constants: {%s},\n            Upvalues: {%s},\n            Protos: {%s}\n        }",
			Info.short_src,
			Concat(Constants),
			Concat(Upvalues),
			Concat(Protos)
		)
	end

	return nil, "Failed to get function data";
end

-- << Helper >> --
local Helper = {}; do
	Helper.__index = Helper;

	function Helper.new()
		local self = setmetatable({}, Helper);

		self.Knit = nil;
		self.Module = nil;

		self.Controllers = {};
		self.Services = {};

		self.ControllerContents = {};
		self.ServiceContents = {};

		return self;
	end;

	function Helper:GetKnitModule()
		if self.Module then
			return self.Module;
		end

		for _, Module in next, ReplicatedStorage:GetDescendants() do
			if Module:IsA("ModuleScript") and Module.Name == "KnitClient" then
				self.Module = Module;

				return self.Module;
			end
		end

		return nil, "KnitClient not found";
	end;

	function Helper:Load()
		local GetKnitModule = self:GetKnitModule()

		if GetKnitModule then
			self.Knit = require(GetKnitModule);

			return self.Knit;
		end

		return nil, "KnitClient not found";
	end;

	function Helper:GetControllers()
		local Knit = self.Knit;

		if Knit then
			self.Controllers = rawget(Knit, "Controllers");

			return self.Controllers;
		end

		return nil, "Knit not found";
	end;

	function Helper:GetController(Controller)
		local Controllers = self:GetControllers();

		if Controllers then
			self.ControllerContents = rawget(Controllers, Controller);

			return self.ControllerContents;
		end

		return nil, "Controller not found";
	end;

    function Helper:GetServices()
        local Knit = self.Knit;

        if Knit then
            local GetService = rawget(Knit, "GetService");

            self.Services = debug.getupvalue(GetService, 1):GetChildren();

            return self.Services;
        end

        return nil, "Knit not found";
    end;

    function Helper:GetService(Service)
        local Services = self:GetServices();

        if Services then
            local ServiceContents = Services[Service];

            if ServiceContents then
                self.ServiceContents = ServiceContents;

                return self.ServiceContents;
            end

            return nil, "Service not found";
        end

        return nil, "Services not found";
    end;

	function Helper:DumpKnit()
		local Controllers = self:GetControllers();
        local Services = self:GetServices();

		print("Controllers:")
		table.foreach(Controllers, function(Index, Value)
			local Success, Error = pcall(function()
                warn("    " .. Index .. ":")
                table.foreach(Value, function(Index, Value)
                    if Index == "Name" then return; end
                    if typeof(Value) == "function" then
                        print("        " .. Index .. ": " .. FormatInfo(Value));
                        return;
                    end
                    print("        " .. Index .. ": " .. tostring(Value));
                end)
			end)

			if not Success then
			    warn('Failed to dump controller "'..Index..'"');
			end
		end)
        print("Services:")
        table.foreach(Services, function(_, Service)
            local Success, Error = pcall(function()
                warn("    " .. Service.Name .. ":")
                table.foreach(Service:GetDescendants(), function(_, Item)
                    if Item:IsA("Folder") and Item.Name == "RF" then
                        print("        Remote Function(s):");
                        table.foreach(Item:GetDescendants(), function(_, Value)
                            print("            " .. Value.Name);
                        end)
                    elseif Item:IsA("Folder") and Item.Name == "RE" then
                        print("        Remote Event(s):");
                        table.foreach(Item:GetDescendants(), function(_, Value)
                            print("            " .. Value.Name);
                        end)
                    end
                end)
            end)

            if not Success then
                warn('Failed to dump service "'..Service.Name..'"');
            end
        end)
	end;

	function Helper:DumpToFile()
		local Controllers = self:GetControllers();
        local Services = self:GetServices();

        writefile("KnitHelper.txt", "");
		appendfile("KnitHelper.txt", "Controllers:\n");

		table.foreach(Controllers, function(Index, Value)
			local Success, Error = pcall(function()
				appendfile("KnitHelper.txt", "    " .. Index .. ":\n");
				table.foreach(Value, function(Index, Value)
					if Index == "Name" then return; end
					if typeof(Value) == "function" then
						appendfile("KnitHelper.txt", "        " .. Index .. ": " .. FormatInfo(Value) .. "\n");
						return;
					end
					appendfile("KnitHelper.txt", "        " .. Index .. ": " .. tostring(Value) .. "\n");
				end)
			end)

			if not Success then
				warn('Failed to dump controller "' .. Index .. '" to file');
			end
		end)

        appendfile("KnitHelper.txt", "Services:\n");
        table.foreach(Services, function(_, Service)
            local Success, Error = pcall(function()
                appendfile("KnitHelper.txt", "    " .. Service.Name .. ":\n");
                table.foreach(Service:GetDescendants(), function(_, Item)
                    if Item:IsA("Folder") and Item.Name == "RF" then
                        appendfile("KnitHelper.txt", "        Remote Function(s):\n");
                        table.foreach(Item:GetDescendants(), function(_, Value)
                            appendfile("KnitHelper.txt", "            " .. Value.Name .. "\n");
                        end)
                    elseif Item:IsA("Folder") and Item.Name == "RE" then
                        appendfile("KnitHelper.txt", "        Remote Event(s):\n");
                        table.foreach(Item:GetDescendants(), function(_, Value)
                            appendfile("KnitHelper.txt", "            " .. Value.Name .. "\n");
                        end)
                    end
                end)
            end)

            if not Success then
                warn('Failed to dump service "' .. Service.Name .. '" to file');
            end
        end)
	end;
end

return Helper;