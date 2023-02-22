local Tick = tick();

local Functions = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/Loader.lua"))();
local rconsolelog = Functions.rconsolelog;
local filtergc = Functions.filtergc;
local ESP = Functions.ESP;

-- local hookfuncs = Functions.hookfuncs;

-- local hookfunc = hookfuncs.HookFunction;
-- local restorefunc = hookfuncs.RestoreFunction;
-- local ishooked = hookfuncs.IsHooked;

local rconsoletop = rconsoletop or function() end;

rconsolename("Weaponry Debug Console");
rconsoleclear();
rconsoletop(true)

local Services = setmetatable({},{
    __index = function(self, Index)
        local Service = game:GetService(Index);

        if Service then
            self[Index] = Service;

            return Service;
        end
    end,
})

LPH_NO_UPVALUES = function(...) return ... end;

local Players = Services.Players;
local LocalPlayer = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;
local Mouse = LocalPlayer:GetMouse();

local TeamCheck = false;

LocalPlayer.CharacterAdded:Connect(function()
    if #Services.Teams:GetTeams() ~= 0 then
        TeamCheck = true;

        ESP:DeInit({"Box", "Nametag"});

        ESP:Init({"Box", "Nametag"}, Players, {
            Color = Color3.fromRGB(255, 255, 255),
            TeamCheck = TeamCheck,
            Distance = 1000,
            Rainbow = true,
        });
    else
        TeamCheck = false;

        ESP:DeInit({"Box", "Nametag"});

        ESP:Init({"Box", "Nametag"}, Players, {
            Color = Color3.fromRGB(255, 255, 255),
            TeamCheck = TeamCheck,
            Distance = 1000,
            Rainbow = true,
        });
    end
end)

if #Services.Teams:GetTeams() ~= 0 then
    TeamCheck = true;
else
    TeamCheck = false;
end

if not LocalPlayer.Character then
    rconsolelog("Error", "Character not found, waiting for character to load");

    LocalPlayer.CharacterAdded:Wait();

    rconsolelog("Success", "Character loaded");
end

rconsolelog("Loading", "Finding important functions in gc");

local ReloadWeapon = filtergc("function", {
	Name = "reloadWeapon"
}, true)

local InventoryManager = filtergc("function", {
	Name = "InventoryManager"
}, true)

rconsolelog("Info", "Successfully found important functions in gc");

rconsolelog("Loading", "Loading functions");

local Weaponry = {}; do
    function Weaponry:IsVisible(Player, Part)
        local Parts = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, Player.Character[Part].Position}, {Player.Character})

        for Index, Part in next, Parts do
            if Part.Transparency == 1 or Part.CanCollide == false then
                Parts[Index] = nil;
            end
        end

        return #Parts == 0;
    end

    function Weaponry:IsNotSameTeam(Player, Toggle)
        return not Toggle or Player.Team ~= LocalPlayer.Team;
    end

    function Weaponry:IsAlive(Player)
        return Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0;
    end

    function Weaponry:IsOnScreen(Part)
        local _, OnScreen = Camera:WorldToViewportPoint(Part.Position);

        return OnScreen;
    end

    function Weaponry:IsInFOV(Player, FOVSize, Toggle)
        local Vector, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position);

        return not Toggle or OnScreen and (Vector2.new(Vector.X, Vector.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude <= FOVSize;
    end

    function Weaponry:GetClosestToMouseInFov()
        local ClosestPlayer = nil;
        local ClosestDistance = math.huge;

        for _, Player in next, Players:GetPlayers() do
            if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                if self:IsNotSameTeam(Player, TeamCheck) and self:IsAlive(Player) then
                    local Distance = (Mouse.Hit.Position - Player.Character.HumanoidRootPart.Position).Magnitude;

                    if Distance < ClosestDistance and self:IsOnScreen(Player.Character.HumanoidRootPart) then
                        ClosestPlayer = Player;
                        ClosestDistance = Distance;
                    end
                end
            end
        end

        return ClosestPlayer;
    end
end;

local function Find(Table, Name)
    for Index, Value in next, Table do
        if typeof(Value) == "table" then
            local Found = Find(Value, Name);

            if Found then
                return Found;
            end
        elseif typeof(Index) == "string" and Index == Name then
            return Value;
        end
    end
end

rconsolelog("Info", "Successfully loaded functions");

rconsolelog("Loading", "Hooking cat");

local Raycast = require(Services.ReplicatedStorage.SharedModules.RayCat);

local function RandomHit(Percentage)
    local Random = Random.new();

    return Random:NextNumber(0, 100) < Percentage and "Head" or "HumanoidRootPart";
end

local OldRayCast; OldRayCast = LPH_NO_UPVALUES(hookfunction(Raycast.cat, function(...)
    local Args = {...};
    local Position, Direction = Args[1], Args[2];
    local Target = Weaponry:GetClosestToMouseInFov();
    local RandomPart = RandomHit(25);

    if Target then
        local Character = Target.Character;
        local HitPart = Character and Character:FindFirstChild(RandomPart);

        if HitPart and Weaponry:IsVisible(Target, RandomPart) and Weaponry:IsInFOV(Target, 250, true) then
            Direction = (HitPart.Position - Position).Unit * 1000;
        end
    end

    return OldRayCast(Position, Direction, unpack(Args, 3));
end))

rconsolelog("Info", "Successfully hooked cat");

rconsolelog("Loading", "Loading Gun Mods");

local CurrentWeapons = debug.getupvalues(InventoryManager)[5];

if not CurrentWeapons then
    repeat task.wait();
        CurrentWeapons = debug.getupvalues(InventoryManager)[5];
    until CurrentWeapons;
end

task.spawn(function()
    while true do task.wait()
        for _, Weapon in next, CurrentWeapons do
            local CurrentAmmo = Find(Weapon, "CurrentAmmo");

            if tonumber(CurrentAmmo) and tonumber(CurrentAmmo) == 0 then
                ReloadWeapon();
            end
        end
    end
end)

rconsolelog("Info", "Successfully loaded Gun Mods");

hookfunction(LocalPlayer.Kick, function()
    rconsolelog("Info", "Prevented kick!");
end)

rconsolelog("Loading", "Initializing Esp");

ESP:Init({"Box", "Nametag"}, Players, {
    Color = Color3.fromRGB(255, 255, 255),
    TeamCheck = TeamCheck,
    Distance = 1000,
    Rainbow = true,
});

task.spawn(function()
    local FOVCircle = Drawing.new("Circle");
    FOVCircle.Visible = false;
    FOVCircle.Thickness = 1;
    FOVCircle.NumSides = 100;
    FOVCircle.Filled = false;
    FOVCircle.Color = Color3.fromRGB(255, 255, 255);
    FOVCircle.Radius = 0;
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);

    while true do task.wait()
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36);
        FOVCircle.Radius = 250;
        FOVCircle.Visible = true;
        FOVCircle.Color = Color3.fromHSV(tick() / 10 % 1, 1, 1);
    end
end)

rconsolelog("Info", "Successfully initialized Esp");

rconsolelog("Success", string.format("Loaded script in %s ms", math.floor((tick() - Tick) * 1000)));
