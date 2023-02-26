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
    Documentation:
        ESP:Init(Type, Args)
            Type: string or table
            Args: table

            Args:
                Color: Color3
                Distance: number
                TeamCheck: boolean
                Rainbow: boolean
                FaceCamera: boolean
                Healthbar: boolean

            Types:
                Box
                Nametag
                Box3D

        ESP:DeInit()
            Deinitializes all ESPs.

            Note: If you want to deinitialize a specific ESP, you will need to rerun ESP:Init() -
            after you have used ESP:DeInit(), but with the specific ESP left out.

        ESP:Destroy(Player)
            Destroys all ESPs for a specific player.
]]--

```
