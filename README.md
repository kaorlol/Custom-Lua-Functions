# Custom Lua Functions

### Example:
```lua
local Functions = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/Loader.lua"))();
local rconsolelog = Functions.rconsolelog;
local filtergc = Functions.filtergc;

rconsolelog("Loading", "Sup") -- Shows "Sup" in the rconsole in the style of "Loading".

local CreateHitBox = filtergc("function", {
	Name = "CreateHitbox"
}, true)

print(CreateHitBox) -- Output: Function.
```

### ESP Example:
```lua
local Functions = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/Loader.lua"))();
local ESP = Functions.ESP;
local Players = game:GetService("Players");

-- Init loops through the List with the args using a selected ESP.
ESP:Init("Box", Players, {
    Color = Color3.fromRGB(255, 255, 255),
    TeamCheck = false,
    Distance = 1000,
    Rainbow = false,
});

--[[

	The List can't be a table give the folder of wear it is stored... For example: Not Players:GetPlayers(), Just Players.
	
	The List has to contain parts.

	ESP List:
		Corner,
		Box,
		Chams
		
	Args:
		Color,
		TeamCheck,
		Distance

]]--

```
