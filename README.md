### Lua-Functions
##Custom Lua Functions

#Example:
```lua
local Functions = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Lua-Functions/main/Loader.lua"))();
local rconsolelog = Functions.rconsolelog;
local filtergc = Functions.filtergc;

rconsolelog("Loading", "Sup") -- Shows "Sup" in the rconsole in the style of "Loading".

local CreateHitBox = filtergc("function", {
	Name = "CreateHitbox"
}, true)

print(CreateHitBox) -- Output: Function.
```
