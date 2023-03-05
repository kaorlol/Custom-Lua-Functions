local PreLoadTick = tick();

if typeof(syn) == "table" and RenderWindow then
    syn.protect_gui = gethui;
end

local Linoria = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/";

local Library = loadstring(game:HttpGet((Linoria .. "Library.lua")))();

local ScriptLoaded = false;
if not ScriptLoaded then
    Library:Notify("Loading Script...");
end

local LoadHandler = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/LoadHandler.lua"))();
--local ESPHandler = LoadHandler("ESP Handler");
local FileHandler = LoadHandler("File Handler");
local Pathfinding = LoadHandler("Pathfinding Handler");

local LocalPlayer = game:GetService("Players").LocalPlayer;

local ThemeManager = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Uvxtq/Project-AlphaZero/main/AlphaZero/Theme%20Manager.lua")))();
local SaveManager = loadstring(game:HttpGet(Linoria .. "addons/SaveManager.lua"))();

local Window = Library:CreateWindow({
    Title = "Sword Fighters Simulator",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    ["Main"] = Window:AddTab("Main"),
    --["ESP"] = Window:AddTab("ESP"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}; --ESPHandler(Tabs["ESP"]);

local AttackTab = Tabs["Main"]:AddLeftGroupbox("Attack");
local WeaponsTab = Tabs["Main"]:AddRightGroupbox("Weapons");
local PetsTab = Tabs["Main"]:AddRightGroupbox("Pets");
local MiscellaneousTab = Tabs["Main"]:AddLeftGroupbox("Miscellaneous");

-- << Locals >> --
local RFClick = game:GetService("ReplicatedStorage").Packages.Knit.Services.ClickService.RF.Click;
local RFBuyArea = game:GetService("ReplicatedStorage").Packages.Knit.Services.AreaService.RF.BuyArea;
local RFWEquipBest = game:GetService("ReplicatedStorage").Packages.Knit.Services.WeaponInvService.RF.EquipBest;
local RFPEquipBest = game:GetService("ReplicatedStorage").Packages.Knit.Services.PetInvService.RF.EquipBest;
local RFAscend = game:GetService("ReplicatedStorage").Packages.Knit.Services.AscendService.RF.Ascend;
local RFForge = game:GetService("ReplicatedStorage").Packages.Knit.Services.ForgeService.RF.Forge;
local RFWMultiSell = game:GetService("ReplicatedStorage").Packages.Knit.Services.WeaponInvService.RF.MultiSell;
local RFPMultiSell = game:GetService("ReplicatedStorage").Packages.Knit.Services.PetInvService.RF.MultiDelete;
local RFUpgrade = game:GetService("ReplicatedStorage").Packages.Knit.Services.UpgradeService.RF.Upgrade;

local Suffixes = {
    "K",
    "M",
    "B",
    "T",
    "Qa",
    "Qi",
    "Sx",
    "Sp",
    "Oc",
    "No",
    "Dc",
    "Ud",
    "Dd",
    "Td",
    "Qad",
    "Qid",
    "Sxd",
    "Spd",
    "Ocd",
    "Nod",
    "Vg",
    "Uvg",
    "Dvg",
    "Tvg",
    "Qavg",
};

local Utilities = {}; do
    function Utilities:ConvertToNumber(String)
        local Suffix = string.match(String, "%a+");
        local Number = string.gsub(String, "%a+", "");

        if not Suffix then
            return tonumber(Number);
        end

        for i = 1, #Suffixes do
            if Suffixes[i]:lower() == Suffix:lower() then
                return tonumber(Number) * 1000 ^ i;
            end
        end
    end;

    function Utilities:GetMedian(Numbers)
        table.sort(Numbers);

        local MiddleIndex = math.floor(#Numbers / 2);

        if #Numbers % 2 == 0 then
            return math.floor((Numbers[MiddleIndex] + Numbers[MiddleIndex + 1]) / 2);
        else
            return Numbers[MiddleIndex + 1];
        end
    end

    function Utilities:GetFeetPosition(Enemy)
        if not Enemy then return; end

        local Size = Enemy.HumanoidRootPart.Size;

        return Enemy.HumanoidRootPart.Position - Vector3.new(0, Size.Y / 2, 0);
    end;

    function Utilities:GetClosestEnemy()
        local ClosestEnemy, ClosestDistance = nil, math.huge;

        for _, Enemy in next, workspace.Live.NPCs.Client:GetChildren() do
            if Enemy:FindFirstChild("HumanoidRootPart") then
                local EnemyFeetPosition = self:GetFeetPosition(Enemy);
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - EnemyFeetPosition).Magnitude;

                if Distance < ClosestDistance then
                    ClosestEnemy = Enemy;
                    ClosestDistance = Distance;
                end
            end
        end

        return ClosestEnemy, ClosestDistance;
    end;

    function Utilities:GetEnemyLowestHealth()
        local LowestHealthEnemy, LowestHealth = nil, math.huge;
        local ClosestDistance = math.huge;

        for _, Enemy in next, workspace.Live.NPCs.Client:GetChildren() do
            if Enemy:FindFirstChild("HumanoidRootPart") and Enemy.HumanoidRootPart:FindFirstChild("NPCTag") then
                local EnemyHealth = self:ConvertToNumber(Enemy.HumanoidRootPart.NPCTag.HealthLabel.Text:split("/")[2]);
                local EnemyFeetPosition = self:GetFeetPosition(Enemy);
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - EnemyFeetPosition).Magnitude;

                if EnemyHealth < LowestHealth then
                    LowestHealthEnemy = Enemy;
                    LowestHealth = EnemyHealth;
                    ClosestDistance = Distance;
                end
            end
        end

        return LowestHealthEnemy, ClosestDistance;
    end;

    function Utilities:GetEnemyHighestHealth()
        local HighestHealthEnemy, HighestHealth = nil, 0;
        local ClosestDistance = math.huge;

        for _, Enemy in next, workspace.Live.NPCs.Client:GetChildren() do
            if Enemy:FindFirstChild("HumanoidRootPart") and Enemy.HumanoidRootPart:FindFirstChild("NPCTag") then
                local EnemyHealth = self:ConvertToNumber(Enemy.HumanoidRootPart.NPCTag.HealthLabel.Text:split("/")[2]);
                local EnemyFeetPosition = self:GetFeetPosition(Enemy);
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - EnemyFeetPosition).Magnitude;

                if EnemyHealth > HighestHealth then
                    HighestHealthEnemy = Enemy;
                    HighestHealth = EnemyHealth;
                    ClosestDistance = Distance;
                end
            end
        end

        return HighestHealthEnemy, ClosestDistance;
    end;

    function Utilities:GetEnemyWithBestTimeToKill()
        local BestTimeToKillEnemy, BestTimeToKill = nil, math.huge;
        local ClosestDistance = math.huge;

        for _, Enemy in next, workspace.Live.NPCs.Client:GetChildren() do
            if Enemy:FindFirstChild("HumanoidRootPart") and Enemy.HumanoidRootPart:FindFirstChild("NPCTag") then
                local EnemyHealth = self:ConvertToNumber(Enemy.HumanoidRootPart.NPCTag.HealthLabel.Text:split("/")[2]);
                local EnemyFeetPosition = self:GetFeetPosition(Enemy);
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - EnemyFeetPosition).Magnitude;

                local TimeToKill = EnemyHealth / self:ConvertToNumber(LocalPlayer.leaderstats.Power.Value)

                if TimeToKill < BestTimeToKill and Distance < ClosestDistance then
                    BestTimeToKillEnemy = Enemy;
                    BestTimeToKill = TimeToKill;
                    ClosestDistance = Distance;
                end
            end
        end

        return BestTimeToKillEnemy, ClosestDistance;
    end;

    function Utilities:GetEnemy(Method)
        return self[Method](self);
    end;

    function Utilities:CheckLength(Table)
        local Length = 0;

        for _, _ in next, Table do
            Length = Length + 1;
        end

        return Length;
    end;

    function Utilities:GetCoins()
        return self:ConvertToNumber(LocalPlayer.leaderstats.Coins.Value);
    end;

    function Utilities:GetPortalCost()
        local BestCost = math.huge;

        for _, Portal in next, LocalPlayer.PlayerGui:GetChildren() do
            if Portal:IsA("BillboardGui") and Portal.Name == "Portal" and Portal.Text2.Text:find("Coins") then
                local Cost = self:ConvertToNumber(Portal.Text2.Text:split(" ")[1]);

                if Cost < BestCost then
                    BestCost = Cost;
                end
            end
        end

        return BestCost;
    end
end

-- << Attack Tab >> --

local AutoAttack = false;
AttackTab:AddToggle("Auto Attack", {
    Text = "Auto Click/Attack",
    Default = false,
    Tooltip = "Automatically attack the closest enemy",
    Callback = function(Value)
        AutoAttack = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoAttack then break; end
                if Library.Unloaded then break; end

                local ClosestEnemy, ClosestDistance = Utilities:GetClosestEnemy();

                if ClosestEnemy and ClosestDistance <= 10 then
                    RFClick:InvokeServer(ClosestEnemy.Name);
                else
                    RFClick:InvokeServer();
                end
            end
        end)
    end
})

AttackTab:AddDivider()

local Method = "GetClosestEnemy";
AttackTab:AddDropdown("Method To Get Enemies", {
    Values = {
        "GetClosestEnemy",
        "GetEnemyLowestHealth",
        "GetEnemyHighestHealth",
        "GetEnemyWithBestTimeToKill"
    },

    Default = 1,
    Multi = false,

    Text = "Method to get enemy",
    Tooltip = "Method to get enemy",

    Callback = function(Value)
        Method = Value;
    end
})

local Path = Pathfinding.new(LocalPlayer.Character);
Path.Visualize = true;

local PathfindEnemies = false;
AttackTab:AddToggle("Pathfind", {
    Text = "Pathfind Enemies",
    Default = false,
    Tooltip = "Automatically pathfind to the closest enemy",
    Callback = function(Value)
        PathfindEnemies = Value;

        task.spawn(function()
            while true do task.wait()
                if not PathfindEnemies then break; end
                if Library.Unloaded then break; end

                local ClosestEnemy, ClosestDistance = Utilities:GetEnemy(Method);
                if ClosestEnemy and ClosestDistance then
                    local FeetPosition = Utilities:GetFeetPosition(ClosestEnemy);
                    local Offset = FeetPosition - Vector3.new(3, 0, 0);

                    Path:Run(Offset);
                end
            end
        end)
    end
})

-- << Weapons Tab >> --

local AutoSellWeaponsTable = {};
local AutoSellCommon = false;
WeaponsTab:AddToggle("Auto Sell Common", {
    Text = "Auto Sell Common",
    Default = false,
    Tooltip = "Automatically sell common weapons",
    Callback = function(Value)
        AutoSellCommon = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellCommon then break; end
                if Library.Unloaded then break; end

                local WeaponHolder = LocalPlayer.PlayerGui.WeaponInv.Background.ImageFrame.Window.WeaponHolder;

                for _, Weapon in next, WeaponHolder.WeaponScrolling:GetChildren() do
                    if Weapon:IsA("Frame") and WeaponHolder.WeaponScrolling[Weapon.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(80, 80, 80) then
                        if WeaponHolder.WeaponScrolling[Weapon.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellWeaponsTable[Weapon.Name] = true;
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellWeaponsTable) > 0 then
                    RFWMultiSell:InvokeServer(AutoSellWeaponsTable);

                    AutoSellWeaponsTable = {};
                end
            end
        end)
    end
})

local AutoSellRare = false;
WeaponsTab:AddToggle("Auto Sell Rare", {
    Text = "Auto Sell Rare",
    Default = false,
    Tooltip = "Automatically sell rare weapons",
    Callback = function(Value)
        AutoSellRare = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellRare then break; end
                if Library.Unloaded then break; end

                local WeaponHolder = LocalPlayer.PlayerGui.WeaponInv.Background.ImageFrame.Window.WeaponHolder;

                for _, Weapon in next, WeaponHolder.WeaponScrolling:GetChildren() do
                    if Weapon:IsA("Frame") and WeaponHolder.WeaponScrolling[Weapon.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(59, 177, 251) then
                        if WeaponHolder.WeaponScrolling[Weapon.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellWeaponsTable[Weapon.Name] = true
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellWeaponsTable) > 0 then
                    RFWMultiSell:InvokeServer(AutoSellWeaponsTable);

                    AutoSellWeaponsTable = {};
                end
            end
        end)
    end
})

local AutoSellEpic = false;
WeaponsTab:AddToggle("Auto Sell Epic", {
    Text = "Auto Sell Epic",
    Default = false,
    Tooltip = "Automatically sell epic weapons",
    Callback = function(Value)
        AutoSellEpic = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellEpic then break; end
                if Library.Unloaded then break; end

                local WeaponHolder = LocalPlayer.PlayerGui.WeaponInv.Background.ImageFrame.Window.WeaponHolder;

                for _, Weapon in next, WeaponHolder.WeaponScrolling:GetChildren() do
                    if Weapon:IsA("Frame") and WeaponHolder.WeaponScrolling[Weapon.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(170, 85, 255) then
                        if WeaponHolder.WeaponScrolling[Weapon.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellWeaponsTable[Weapon.Name] = true;
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellWeaponsTable) > 0 then
                    RFWMultiSell:InvokeServer(AutoSellWeaponsTable);

                    AutoSellWeaponsTable = {};
                end
            end
        end)
    end
})

WeaponsTab:AddDivider()

local AutoEquipBest = false;
WeaponsTab:AddToggle("Auto Equip Best", {
    Text = "Auto Equip Best",
    Default = false,
    Tooltip = "Automatically equip the best weapon",
    Callback = function(Value)
        AutoEquipBest = Value;

        task.spawn(function()
            while true do task.wait(1)
                if not AutoEquipBest then break; end
                if Library.Unloaded then break; end

                RFWEquipBest:InvokeServer();
            end
        end)
    end
})

local AutoForgeWeapon = false;
WeaponsTab:AddToggle("Auto Forge Weapon", {
    Text = "Auto Forge Weapon",
    Default = false,
    Tooltip = "Automatically forge the best weapon",
    Callback = function(Value)
        AutoForgeWeapon = Value;

        task.spawn(function()
            while AutoForgeWeapon do task.wait(0.5)
                if not AutoForgeWeapon then break; end
                if Library.Unloaded then break; end

                local WeaponHolder = LocalPlayer.PlayerGui.WeaponInv.Background.ImageFrame.Window.WeaponHolder;

                for _, Weapon in next, WeaponHolder.WeaponScrolling:GetChildren() do
                    if Weapon:IsA("Frame") then
                        RFForge:InvokeServer(Weapon.Name);
                    end
                end
            end
        end)
    end
})

-- << Pets Tab >> --

local AutoSellPetsTable = {};

local AutoSellPetsCommon = false;
PetsTab:AddToggle("Auto Sell Common", {
    Text = "Auto Sell Common",
    Default = false,
    Tooltip = "Automatically sell common pets",
    Callback = function(Value)
        AutoSellPetsCommon = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellPetsCommon then break; end
                if Library.Unloaded then break; end

                local PetHolder = LocalPlayer.PlayerGui.PetInv.Background.ImageFrame.Window.PetHolder;

                for _, Pet in next, PetHolder.PetScrolling:GetChildren() do
                    if Pet:IsA("Frame") and PetHolder.PetScrolling[Pet.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(80, 80, 80) then
                        if PetHolder.PetScrolling[Pet.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellPetsTable[Pet.Name] = true;
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellPetsTable) > 0 then
                    RFPMultiSell:InvokeServer(AutoSellPetsTable);

                    AutoSellPetsTable = {};
                end
            end
        end)
    end
})

local AutoSellPetsRare = false;
PetsTab:AddToggle("Auto Sell Rare", {
    Text = "Auto Sell Rare",
    Default = false,
    Tooltip = "Automatically sell rare pets",
    Callback = function(Value)
        AutoSellPetsRare = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellPetsRare then break; end
                if Library.Unloaded then break; end

                local PetHolder = LocalPlayer.PlayerGui.PetInv.Background.ImageFrame.Window.PetHolder;

                for _, Pet in next, PetHolder.PetScrolling:GetChildren() do
                    if Pet:IsA("Frame") and PetHolder.PetScrolling[Pet.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(59, 177, 251) then
                        if PetHolder.PetScrolling[Pet.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellPetsTable[Pet.Name] = true;
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellPetsTable) > 0 then
                    RFPMultiSell:InvokeServer(AutoSellPetsTable);

                    AutoSellPetsTable = {};
                end
            end
        end)
    end
})

local AutoSellPetsEpic = false;
PetsTab:AddToggle("Auto Sell Epic", {
    Text = "Auto Sell Epic",
    Default = false,
    Tooltip = "Automatically sell epic pets",
    Callback = function(Value)
        AutoSellPetsEpic = Value;

        task.spawn(function()
            while true do task.wait()
                if not AutoSellPetsEpic then break; end
                if Library.Unloaded then break; end

                local PetHolder = LocalPlayer.PlayerGui.PetInv.Background.ImageFrame.Window.PetHolder;

                for _, Pet in next, PetHolder.PetScrolling:GetChildren() do
                    if Pet:IsA("Frame") and PetHolder.PetScrolling[Pet.Name].Frame.Background.BackgroundColor3 == Color3.fromRGB(170, 85, 255) then
                        if PetHolder.PetScrolling[Pet.Name]:WaitForChild("Frame").Equipped.Visible == false then
                            AutoSellPetsTable[Pet.Name] = true;
                        end
                    end
                end

                if Utilities:CheckLength(AutoSellPetsTable) > 0 then
                    RFPMultiSell:InvokeServer(AutoSellPetsTable);

                    AutoSellPetsTable = {};
                end
            end
        end)
    end
})

PetsTab:AddDivider()

local AutoEquipBestPet = false;
PetsTab:AddToggle("Auto Equip Best", {
    Text = "Auto Equip Best",
    Default = false,
    Tooltip = "Automatically equip the best pets",
    Callback = function(Value)
        AutoEquipBestPet = Value;

        task.spawn(function()
            while true do task.wait(1)
                if not AutoEquipBestPet then break; end
                if Library.Unloaded then break; end

                RFPEquipBest:InvokeServer();
            end
        end)
    end
})

local AutoFeedPet = false;
PetsTab:AddToggle("Auto Feed Pet", {
    Text = "Auto Feed Pet (TODO)",
    Default = false,
    Tooltip = "Automatically feed the best pet",
    Callback = function(Value)
        AutoFeedPet = Value;

        print("TODO")
    end
})

-- << Miscellaneous Tab >> --
local AutoBuyAreas = false;
MiscellaneousTab:AddToggle("Auto Buy Areas", {
    Text = "Auto Buy Areas",
    Default = false,
    Tooltip = "Automatically buy areas",
    Callback = function(Value)
        AutoBuyAreas = Value;

        task.spawn(function()
            while true do
                if not AutoBuyAreas then break; end
                if Library.Unloaded then break; end

                for _, Area in next, workspace.Resources.Teleports:GetChildren() do
                    if Area:IsA("Folder") then
                        local CurrentCoins = Utilities:GetCoins();
                        local AreaCost = Utilities:GetPortalCost();

                        if CurrentCoins >= AreaCost then
                            RFBuyArea:InvokeServer(Area.Name);
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end
})

local AutoAscend = false;
MiscellaneousTab:AddToggle("Auto Ascend", {
    Text = "Auto Ascend",
    Default = false,
    Tooltip = "Automatically ascend",
    Callback = function(Value)
        AutoAscend = Value;

        task.spawn(function()
            while true do task.wait(0.1)
                if not AutoAscend then break; end
                if Library.Unloaded then break; end

                local Progress1 = Utilities:ConvertToNumber(LocalPlayer.PlayerGui.Ascend.Background.ImageFrame.Window.Progress.Progress.ProgressLabel.Text:split("/")[1]);
                local Progress2 = Utilities:ConvertToNumber(LocalPlayer.PlayerGui.Ascend.Background.ImageFrame.Window.Progress.Progress.ProgressLabel.Text:split("/")[2]);

                if Progress1 == Progress2 then
                    RFAscend:InvokeServer();
                end
            end
        end)
    end
})

local AutoBuyUpgrades, AutoBuyUpgradesTable = false, {
    "Power Gain";
    "More Storage";
    "WalkSpeed";
    --"Crit Chance";
};

local Upgrades = {"1", "2", "3", "4", "5"}

MiscellaneousTab:AddToggle("Auto Buy Upgrades", {
    Text = "Auto Buy Upgrades",
    Default = false,
    Tooltip = "Automatically buy upgrades",
    Callback = function(Value)
        AutoBuyUpgrades = Value;

        task.spawn(function()
            while true do task.wait(1)
                if not AutoBuyUpgrades then break; end
                if Library.Unloaded then break; end

                for _, UpgradeNumber in next, Upgrades do
                    for _, Upgrade in next, AutoBuyUpgradesTable do
                        RFUpgrade:InvokeServer(string.format("Area %s", UpgradeNumber), Upgrade);
                    end
                end
            end
        end)
    end
})

local BlacklistedWords = {
    "Defeat";
    "More";
    "Area";
    "forge";
};

LocalPlayer.PlayerGui.Notification.Background.Notification.ChildAdded:Connect(function(Notification)
    if Notification:IsA("TextLabel") then
        local NotificationText = Notification.Text;

        for _, Word in next, BlacklistedWords do
            if NotificationText:find(Word) then
                Notification.Visible = false;
            end
        end
    end
end)

local Animator = game:GetService("CoreGui").PurchasePrompt.ProductPurchaseContainer.Animator;
Animator.ChildAdded:Connect(function(Purchase)
    if AutoBuyUpgrades and Purchase:FindFirstChild("ItemName", true) and Purchase:FindFirstChild("ItemName", true).Text:find("Coin") then
        for _, Item in next, Animator:GetChildren() do
            Item:Destroy();
        end
    end
end)

Library:SetWatermarkVisibility(true)

Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    Library.Unloaded = true;
    ScriptLoaded = false;
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu");

MenuGroup:AddButton("Unload UI", function() Library:Unload() end);
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightControl", NoUI = true, Text = "Menu keybind"});

Library.ToggleKeybind = Options.MenuKeybind;

ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);

SaveManager:IgnoreThemeSettings();

SaveManager:SetIgnoreIndexes({"MenuKeybind"});

ThemeManager:SetFolder("Fighters");
SaveManager:SetFolder("Fighters");

SaveManager:BuildConfigSection(Tabs["UI Settings"]);

ThemeManager:ApplyToTab(Tabs["UI Settings"]);

task.spawn(function()
    while game:GetService("RunService").RenderStepped:Wait() do
        if Library.Unloaded then break; end

        if Toggles.Rainbow and Toggles.Rainbow.Value then
            local Registry = Window.Holder.Visible and Library.Registry or Library.HudRegistry;

            for _, Object in next, Registry do
                for Property, ColorIdx in next, Object.Properties do
                    if ColorIdx == 'AccentColor' or ColorIdx == 'AccentColorDark' then
                        local Instance = Object.Instance;
                        local yPos = Instance.AbsolutePosition.Y;

                        local Mapped = Library:MapValue(yPos, 0, 1080, 0, 0.5) * 1.5;
                        local Color = Color3.fromHSV((Library.CurrentRainbowHue - Mapped) % 1, 0.8, 1);

                        if ColorIdx == 'AccentColorDark' then
                            Color = Library:GetDarkerColor(Color);
                        end

                        Instance[Property] = Color;
                    end
                end
            end
        end
    end
end)

Toggles.Rainbow:OnChanged(function()
    if not Toggles.Rainbow.Value then
        ThemeManager:ThemeUpdate()
    end
end)

local function GetLocalTime()
	local Time = os.date("*t")
	local Hour = Time.hour;
	local Minute = Time.min;
	local Second = Time.sec;

	local AmPm = nil;
	if Hour >= 12 then
		Hour = Hour - 12;
		AmPm = "PM";
	else
		Hour = Hour == 0 and 12 or Hour;
		AmPm = "AM";
	end

	return string.format("%s:%02d:%02d %s", Hour, Minute, Second, AmPm);
end

local DayMap = {"st", "nd", "rd", "th"};
local function FormatDay(Day)
    local LastDigit = Day % 10;
    if LastDigit >= 1 and LastDigit <= 3 then
        return string.format("%s%s", Day, DayMap[LastDigit]);
    end

    return string.format("%s%s", Day, DayMap[4]);
end

local MonthMap = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
local function GetLocalDate()
	local Time = os.date("*t")
	local Day = Time.day;

	local Month = nil;
	if Time.month >= 1 and Time.month <= 12 then
		Month = MonthMap[Time.month];
	end

	return string.format("%s %s", Month, FormatDay(Day));
end

local function GetLocalDateTime()
	return GetLocalDate() .. " " .. GetLocalTime();
end

Toggles.Rainbow:SetValue(true);

Library:Notify(string.format("Loaded script in %.2f second(s)!", tick() - PreLoadTick), 5);

task.spawn(function()
    while true do task.wait(0.1)
        if Library.Unloaded then break; end

        local Ping = string.split(string.split(game.Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1], ".")[1];
        local Fps = string.split(game.Stats.Workspace.Heartbeat:GetValueString(), ".")[1];
        local AccountName = LocalPlayer.Name;

        Library:SetWatermark(string.format("%s | %s | %s FPS | %s Ping", GetLocalDateTime(), AccountName, Fps, Ping));
    end
end)

game:GetService("Lighting").ClockTime = 0;
game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
    game:GetService("Lighting").ClockTime = 0;
end)