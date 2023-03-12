local getupvalues = getupvalues or debug.getupvalues
local getconstants = getconstants or debug.getconstants

assert(getgc and getupvalues and getconstants, "Lacking one of these functions: getgc/getupvalues/getconstants")

local TypeOptionFuncs = {
	["function"] = {
		Name = function(Function, Value)
			return (debug.info(Function, "n") or "") == Value;
		end,
		Upvalues = function(Function, Value)
			local Success, Error = pcall(function()
				local Upvalues = debug.getupvalues(Function);
				local Passed = 0;

				for Index = 1, #Value do
					Passed += (table.find(Upvalues, Value[Index]) and 1) or 0;
				end

				return #Value == Passed;
			end)
			
			return Success;
		end,
		Constants = function(Function, Value)
			local Success, Error = pcall(function()
				local Constants = debug.getconstants(Function);
				local Passed = 0;

				for Index = 1, #Value do
					Passed += (table.find(Constants, Value[Index]) and 1) or 0;
				end

				return #Value == Passed;
			end)
			
			return Success;
		end
	};

	["table"] = {
		Keys = function(Table, Value)
			for Index in next, Table do -- no __iter = no detection 🤑
				if not Value[Index] then
					return false;
				end
			end

			return true;
		end,
		Values = function(Table, Value)
			for _, Values in next, Table do -- no __iter = no detection 🤑
				if not table.find(Value, Values) then
					return false;
				end
			end

			return true;
		end,
		KeyValuePairs = function(Table, Value)
			for Index, ValuePair in next, Table do -- no __iter = no detection 🤑
				if Value[Index] ~= ValuePair then
					return false;
				end
			end

			return true;
		end,
		Select = function(Table, Value)
			local Passed = 0;

			for Index = 1, #Value do
				Passed += (rawget(Table, Value[Index]) ~= nil and 1) or 0;
			end

			return #Value == Passed;
		end,
	};
}

local function FilterTheGC(Type, Options, ReturnOne)
	ReturnOne = (ReturnOne == nil) or ReturnOne;
	assert(#Options == 0, "There should be atleast 1 option");

	local Results = {};
	local GC = getgc(true);

	for Index = 1, #GC do
		local Value = GC[Index];

		if typeof(Value) == Type then
			local OptionsAmount = 0;
			local Passed = 0;

			for OptionName, OptionValue in Options do
				OptionsAmount += 1
				Passed += (TypeOptionFuncs[typeof(Value)][OptionName](Value, OptionValue) and 1) or 0;
			end

			if OptionsAmount == Passed then
				if ReturnOne then
					return Value;
				else
					table.insert(Results, Value);
				end
			end
		end
	end

	return (#Results ~= 0 and Results) or nil
end

return FilterTheGC