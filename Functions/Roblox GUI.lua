-- << Yield Until Game Loaded >> --
if not game:IsLoaded() then
    game.Loaded:Wait();
end

-- << Services >> --
local TeleportService = cloneref(game:GetService("TeleportService"));
local CoreGui = cloneref(game:GetService("CoreGui"));
local Players = cloneref(game:GetService("Players"));
local HttpService = cloneref(game:GetService("HttpService"));
local StarterGui = cloneref(game:GetService("StarterGui"));
local MarketplaceService = cloneref(game:GetService("MarketplaceService"));

-- << Modules >> --
local Utility = getrenv().require(CoreGui.RobloxGui.Modules.Settings.Utility);

-- << Variables >> --
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name;
local Exploit = identifyexecutor and table.concat({identifyexecutor()}, " ") or "Unknown";
local getasset = getsynasset or getcustomasset;
local Request = (typeof(syn) == "table" and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or getgenv().request or request;
local LocalPlayer = Players.LocalPlayer;
local BottomButtonFrame = CoreGui:WaitForChild("RobloxGui"):WaitForChild("SettingsShield"):WaitForChild("SettingsShield"):WaitForChild("MenuContainer"):WaitForChild("BottomButtonFrame");
local ToastTypes = {
    ["None"] = 0,
    ["Success"] = 1,
    ["Warning"] = 2,
    ["Error"] = 3,
    ["Info"] = 4
};

-- << Functions >> --
local function GetKaoruAsset(Path)
    makefolder("kaoru");
    makefolder("kaoru/assets");

    if not isfile(Path) then
        local Body = Request({
            Url = "https://raw.githubusercontent.com/Uvxtq/ServerhopPNG/main/"..Path:gsub("kaoru/assets", "assets"),
            Method = "GET";
        }).Body;

        writefile(Path, Body)
    end

    return getasset(Path);
end

local function CheckExecutor(Name)
    if Exploit:gmatch("/") then
        Exploit = Exploit:split("/")[1];
    end

    if Exploit:lower():match(Name:lower()) then
        return true;
    end

    return false;
end

local function Notify(Type, Duration, Title, Content, IconColor)
    assert(ToastTypes[Type], "Invalid toast type");

    if CheckExecutor("Synapse X v3") then
        return syn.toast_notification({
            Type = ToastTypes[Type],
            Duration = Duration,
            Title = Title,
            Content = Content,
            IconColor = IconColor
        })
    end

    return StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = Content,
        Duration = Duration
    })
end

local function ServerHop(PlaceId, JobId)
    local ServerId = nil;
    local Success, Servers = pcall(function()
        return HttpService:JSONDecode(Request({
            Url = "https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?limit=100",
            Method = "GET"
        }).Body).data;
    end)

    if not Success then
        return Notify("Error", 5, "Server Hopping", "Failed to server hop");
    end

    while true do
        if #Servers > 0 then
            local Index = math.random(1, #Servers);
            local Server = Servers[Index];
            ServerId = Server.id;

            if Server.playing < Server.maxPlayers and ServerId ~= JobId then
                break;
            else
                table.remove(Servers, Index);
            end
        else
            ServerId = nil;
            break;
        end
    end

    if ServerId then
        Notify("Info", 5, "Server Hopping", "Server hopped to "..ServerId);

        TeleportService:TeleportToPlaceInstance(PlaceId, ServerId, LocalPlayer);

        TeleportService.TeleportInitFailed:Connect(function()
            Notify("Error", 5, "Server Hopping", "Failed to server hop");
        end)
    else
        Notify("Info", 5, "Server Hopping", "Server hopped to "..PlaceId);

        TeleportService:Teleport(PlaceId, LocalPlayer);
    end
end

local function MakeButtonWithHint(Name, Text, Image, Position, ClickFunction)
    local ButtonInstance, TextInstance = Utility:MakeStyledButton(Name .. "Button", Text, UDim2.new(0, 260, 0, 70), ClickFunction, nil, nil);

    ButtonInstance.Position = Position;
    ButtonInstance.Parent = BottomButtonFrame;

    TextInstance.Size = UDim2.new(0.75, 0, 0.9, 0);
    TextInstance.Position = UDim2.new(0.25, 0, 0, 0);

    local HintLabel = Utility:Create("ImageLabel")({
        Name = Name .. "Hint",
        BackgroundTransparency = 1,
        Image = Image,
        Parent = ButtonInstance
    })

    HintLabel.AnchorPoint = Vector2.new(0.5, 0.5);
    HintLabel.Size = UDim2.new(0, 55, 0, 60);
    HintLabel.Position = UDim2.new(0.150000006, 0, 0.474999994, 0);

    -- if CoreGui.RobloxGui.SettingsShield.SettingsShield.MenuContainer.BottomButtonFrame:FindFirstChild("MuteButtonButtonButton") then
    --     ButtonInstance.Size = UDim2.new(0, 235, 0, 70);
    -- end
end

-- << RejoinButton >> --
MakeButtonWithHint("Rejoin", "Rejoin", GetKaoruAsset("kaoru/assets/Rejoin.png"), UDim2.new(0.5, -130, 0.5, 50), function()
    Notify("Info", 5, "Rejoining", "Rejoined "..game.JobId);

    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer);

    TeleportService.TeleportInitFailed:Connect(function()
        Notify("Error", 5, "Rejoining", "Failed to rejoin");
    end)
end)

-- << ServerHopButton >> --
MakeButtonWithHint("ServerHop", "Server Hop", GetKaoruAsset("kaoru/assets/ServerHop.png"), UDim2.new(0.5, -400, 0.5, 50), function()
    ServerHop(game.PlaceId, game.JobId)
end)

-- << CopyJoinScriptButton >> --
MakeButtonWithHint("CopyJoinScript", "Copy Join Script", GetKaoruAsset("kaoru/assets/Copy.png"), UDim2.new(0.5, 140, 0.5, 50), function()
    Notify("Info", 5, "Copy Join Script", "Copied Join Script to clipboard");

    local Script = '**Executor Script:**\n```lua\n game:GetService("TeleportService"):TeleportToPlaceInstance('..tostring(game.PlaceId)..', "'..game.JobId..'")```\n**Browser Console Script:**\n```js\n Roblox.GameLauncher.joinGameInstance('..tostring(game.PlaceId)..', "'..game.JobId..'")```';

    setclipboard(Script);
end)