-- local Functions = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/Loader.lua"))();
-- local rconsolelog = Functions.rconsolelog;

-- local rconsolehide = rconsolehide or rconsoleclose;
-- local rconsoleshow = rconsoleshow or function() end;
-- local rconsoletop = rconsoletop or function() end;

-- rconsolename("ESP Debug Console");
-- rconsoleclear();
-- rconsoletop(true);
-- rconsoleshow();

-- rconsolelog("Loading", "Loading Variables");

local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;

local AlreadyBoxed = {};
local AlreadyCornered = {};

Instance.new("ScreenGui", game.CoreGui).Name = "Kaoru"
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "ChamsFolder"
for _, GUI in next, game.CoreGui:GetChildren() do
    if GUI:IsA('ScreenGui') and GUI.Name == 'Kaoru' then
        ChamsFolder.Parent = GUI
    end
end

-- rconsolelog("Info", "Successfully loaded variables")

-- rconsolelog("Loading", "Loading functions");

local function IsNotSameTeam(Player, Toggle)
    if Toggle then
        if Player.TeamColor == LocalPlayer.TeamColor then
            return false;
        end
    end

    return true;
end

local function IsAlive(Item)
    if not Item:IsA("Player") then
        return true;
    end

    return Item and Item.Character and Item.Character:FindFirstChild("Humanoid") and Item.Character.Humanoid.Health > 0;
end

local function IsOnScreen(Part)
    local _, OnScreen = Camera:WorldToViewportPoint(Part.Position);

    return OnScreen;
end

local function GetCorners(Part)
    local Size = Part.Size * Vector3.new(1, 1.5)
    return {
        TopRight = (Part.CFrame * CFrame.new(-Size.X, -Size.Y, 0)).Position;
        BottomRight = (Part.CFrame * CFrame.new(-Size.X, Size.Y, 0)).Position;
        TopLeft = (Part.CFrame * CFrame.new(Size.X, -Size.Y, 0)).Position;
        BottomLeft = (Part.CFrame * CFrame.new(Size.X, Size.Y, 0)).Position;
    };
end

local function NewLine(Color, Thickness)
    local Line = Drawing.new("Line");

    Line.Visible = false;
    Line.From = Vector2.new(0, 0);
    Line.To = Vector2.new(0, 0);
    Line.Color = Color;
    Line.Thickness = Thickness;

    return Line;
end

local ESP = {}; do
    local Chams = nil;

    function ESP:Chams(List, Args)
        local Color = Args.Color or Color3.fromRGB(255, 255, 255);
        local ESPDist = Args.Distance or 1000;
        local TeamCheck = Args.TeamCheck or false;

        for _, Item in next, List do
            if ChamsFolder:FindFirstChild(Item.Name) then
                Chams = ChamsFolder[Item.Name];
                Chams.Enabled = false;
                Chams.FillColor = Color3.fromRGB(255, 255, 255);
                Chams.OutlineColor = Color;
            end

            if Item ~= LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if ChamsFolder:FindFirstChild(Item.Name) == nil then
                    local Highlight = Instance.new("Highlight");
                    Highlight.Name = Item.Name;
                    Highlight.Parent = ChamsFolder;
                    Chams = Highlight;
                end

                Chams.Enabled = true;
                Chams.Adornee = Item.Character or Item;
                Chams.OutlineTransparency = 0;
                Chams.DepthMode = Enum.HighlightDepthMode[(true and "AlwaysOnTop" or "Occluded")];
                Chams.FillTransparency = 1;

                local Distance = nil;
                if Item:IsA("Player") and Item.Character and Item.Character:FindFirstChild("HumanoidRootPart") and IsNotSameTeam(Item, TeamCheck) then
                    Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Character.HumanoidRootPart.Position).Magnitude;
                elseif not Item:IsA("Player") then
                    Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Position).Magnitude;
                end

                if Distance and Distance <= ESPDist then
                    Chams.Enabled = true;
                else
                    Chams.Enabled = false;
                end
            end
        end
    end

    local Boxes = {};
    function ESP:Box(List, Args)
        local Color = Args.Color or Color3.fromRGB(255, 255, 255);
        local ESPDist = Args.Distance or 1000;
        local TeamCheck = Args.TeamCheck or false;

        for _, Item in next, List do
            if not table.find(AlreadyBoxed, Item.Name) then
                local Box = Drawing.new("Quad");
                Box.Visible = false;
                Box.PointA = Vector2.new(0, 0);
                Box.PointB = Vector2.new(0, 0);
                Box.PointC = Vector2.new(0, 0);
                Box.PointD = Vector2.new(0, 0);
                Box.Color = Color3.fromRGB(255, 255, 255);
                Box.Thickness = 1;
                Box.Filled = false;

                Boxes[Item.Name] = Box;
                table.insert(AlreadyBoxed, Item.Name);
            end

            if Item ~= LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local Corners = nil;
                local OnScreen = nil;
                local Vectors = nil;

                if Item:IsA("Player") and Item.Character and Item.Character:FindFirstChild("HumanoidRootPart") and IsNotSameTeam(Item, TeamCheck) then
                    Corners = GetCorners(Item.Character.HumanoidRootPart);
                    OnScreen = IsOnScreen(Item.Character.HumanoidRootPart);
                elseif not Item:IsA("Player") then
                    Corners = GetCorners(Item);
                    OnScreen = IsOnScreen(Item);
                end

                if Corners then
                    Vectors = {
                        Camera:WorldToViewportPoint(Corners.TopRight);
                        Camera:WorldToViewportPoint(Corners.BottomRight);
                        Camera:WorldToViewportPoint(Corners.BottomLeft);
                        Camera:WorldToViewportPoint(Corners.TopLeft);
                    };
                end

                if IsAlive(Item) and IsNotSameTeam(Item, TeamCheck) and OnScreen then
                    Boxes[Item.Name].Visible = true;
                    Boxes[Item.Name].PointA = Vector2.new(Vectors[1].X, Vectors[1].Y);
                    Boxes[Item.Name].PointB = Vector2.new(Vectors[2].X, Vectors[2].Y);
                    Boxes[Item.Name].PointC = Vector2.new(Vectors[3].X, Vectors[3].Y);
                    Boxes[Item.Name].PointD = Vector2.new(Vectors[4].X, Vectors[4].Y);
                    Boxes[Item.Name].Color = Color;

                    local Distance = nil;
                    if Item:IsA("Player") and Item.Character and Item.Character:FindFirstChild("HumanoidRootPart") and IsNotSameTeam(Item, TeamCheck) then
                        Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Character.HumanoidRootPart.Position).Magnitude;
                    elseif not Item:IsA("Player") then
                        Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Position).Magnitude;
                    end

                    if Distance and Distance <= ESPDist then
                        Boxes[Item.Name].Visible = true;
                    else
                        Boxes[Item.Name].Visible = false;
                    end
                else
                    Boxes[Item.Name].Visible = false;
                end
            end
        end
    end

    local Lines = {};
    local Parts = {};
    function ESP:Corner(List, Args)
        local Color = Args.Color or Color3.fromRGB(255, 255, 255);
        local ESPDist = Args.Distance or 1000;
        local TeamCheck = Args.TeamCheck or false;

        for _, Item in next, List do
            if Item ~= LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if not table.find(AlreadyCornered, Item.Name) then
                    local ItemLines = {
                        TopLeft1 = NewLine(Color3.fromRGB(255, 255, 255), 1);
                        TopLeft2 = NewLine(Color3.fromRGB(255, 255, 255), 1);

                        TopRight1 = NewLine(Color3.fromRGB(255, 255, 255), 1);
                        TopRight2 = NewLine(Color3.fromRGB(255, 255, 255), 1);

                        BottomLeft1 = NewLine(Color3.fromRGB(255, 255, 255), 1);
                        BottomLeft2 = NewLine(Color3.fromRGB(255, 255, 255), 1);

                        BottomRight1 = NewLine(Color3.fromRGB(255, 255, 255), 1);
                        BottomRight2 = NewLine(Color3.fromRGB(255, 255, 255), 1);
                    };

                    local OrigenPart = Instance.new("Part");
                    OrigenPart.Parent = workspace;
                    OrigenPart.Transparency = 1;
                    OrigenPart.CanCollide = false;
                    OrigenPart.Size = Vector3.new(1, 1, 1);
                    OrigenPart.Position = Vector3.new(0, 0, 0);

                    Parts[Item.Name] = OrigenPart;
                    Lines[Item.Name] = ItemLines;
                    table.insert(AlreadyCornered, Item.Name);
                end

                local OnScreen = nil;
                local OrigenPart = Parts[Item.Name];
                local ItemLines = Lines[Item.Name];

                if Item:IsA("Player") and Item.Character and Item.Character:FindFirstChild("HumanoidRootPart") and IsNotSameTeam(Item, TeamCheck) then
                    OnScreen = IsOnScreen(Item.Character.HumanoidRootPart);
                elseif not Item:IsA("Player") then

                    OnScreen = IsOnScreen(Item);
                end

                if IsAlive(Item) and IsNotSameTeam(Item, TeamCheck) and OnScreen then
                    local Distance = nil;
                    if Item:IsA("Player") and Item.Character and Item.Character:FindFirstChild("HumanoidRootPart") and IsNotSameTeam(Item, TeamCheck) then
                        Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Character.HumanoidRootPart.Position).Magnitude;
                    elseif not Item:IsA("Player") then
                        Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Item.Position).Magnitude;
                    end

                    local DebugPart = (Item.Character.HumanoidRootPart or Item)
                    OrigenPart.Size = Vector3.new(DebugPart.Size.X, DebugPart.Size.Y * 1.5, DebugPart.Size.Z)
                    OrigenPart.CFrame = CFrame.new(DebugPart.CFrame.Position, Camera.CFrame.Position)
                    local SizeX = OrigenPart.Size.X
                    local SizeY = OrigenPart.Size.Y
                    local TopLeft = Camera:WorldToViewportPoint((OrigenPart.CFrame * CFrame.new(SizeX, SizeY, 0)).Position)
                    local TopRight = Camera:WorldToViewportPoint((OrigenPart.CFrame * CFrame.new(-SizeX, SizeY, 0)).Position)
                    local BottomLeft = Camera:WorldToViewportPoint((OrigenPart.CFrame * CFrame.new(SizeX, -SizeY, 0)).Position)
                    local BottomRight = Camera:WorldToViewportPoint((OrigenPart.CFrame * CFrame.new(-SizeX, -SizeY, 0)).Position)

                    local Ratio = (Camera.CFrame.Position - DebugPart.Position).Magnitude;
                    local Offset = math.clamp(1 / Ratio * 750, 2, 300);

                    ItemLines.TopLeft1.From = Vector2.new(TopLeft.X, TopLeft.Y)
                    ItemLines.TopLeft1.To = Vector2.new(TopLeft.X + Offset, TopLeft.Y)
                    ItemLines.TopLeft2.From = Vector2.new(TopLeft.X, TopLeft.Y)
                    ItemLines.TopLeft2.To = Vector2.new(TopLeft.X, TopLeft.Y + Offset)

                    ItemLines.TopRight1.From = Vector2.new(TopRight.X, TopRight.Y)
                    ItemLines.TopRight1.To = Vector2.new(TopRight.X - Offset, TopRight.Y)
                    ItemLines.TopRight2.From = Vector2.new(TopRight.X, TopRight.Y)
                    ItemLines.TopRight2.To = Vector2.new(TopRight.X, TopRight.Y + Offset)

                    ItemLines.BottomLeft1.From = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    ItemLines.BottomLeft1.To = Vector2.new(BottomLeft.X + Offset, BottomLeft.Y)
                    ItemLines.BottomLeft2.From = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    ItemLines.BottomLeft2.To = Vector2.new(BottomLeft.X, BottomLeft.Y - Offset)

                    ItemLines.BottomRight1.From = Vector2.new(BottomRight.X, BottomRight.Y)
                    ItemLines.BottomRight1.To = Vector2.new(BottomRight.X - Offset, BottomRight.Y)
                    ItemLines.BottomRight2.From = Vector2.new(BottomRight.X, BottomRight.Y)
                    ItemLines.BottomRight2.To = Vector2.new(BottomRight.X, BottomRight.Y - Offset)


                    if Distance and Distance <= ESPDist then
                        for _, Line in next, ItemLines do
                            Line.Visible = true;
                            Line.Color = Color;
                        end
                    else
                        for _, Line in next, ItemLines do
                            Line.Visible = false;
                        end
                    end
                else
                    for _, Line in next, ItemLines do
                        Line.Visible = false;
                    end
                end
            end
        end
    end

    function ESP:Init(Type, List, Args)
        local Shutdown = false;

        task.spawn(function()
            while true do task.wait();
                local NewList = ((List == Players and Players:GetPlayers()) or List:GetChildren()) or function()
                    -- rconsolelog("Error", "Invalid List!");
                    -- rconsoleshow();
                    error("Invalid List!");

                    Shutdown = true;
                end

                if Shutdown then
                    break;
                end

                self[Type](self, NewList, Args);
            end
        end)
    end

    function ESP:DestroyAll()
        for _, Line in next, Lines do
            for _, Line in next, Line do
                Line:Destroy();
            end
        end

        for _, Part in next, Parts do
            Part:Destroy();
        end

        for _, Box in next, Boxes do
            Box:Destroy();
        end

        for _, Highlight in next, ChamsFolder do
            Highlight:Destroy();
        end

        Lines = {};
        Parts = {};
        Boxes = {};
    end

    function ESP:Destroy(Item)
        if Lines[Item.Name] then
            for _, Line in next, Lines[Item.Name] do
                Line:Destroy();
            end
        end

        if Parts[Item.Name] then
            Parts[Item.Name]:Destroy();
        end

        if Boxes[Item.Name] then
            Boxes[Item.Name].Visible = false;
            Boxes[Item.Name]:Destroy();
        end

        if ChamsFolder:FindFirstChild(Item.Name) then
            ChamsFolder[Item.Name]:Destroy();
        end
    end
end;

-- rconsolelog("Info", "Successfully loaded Functions");

Players.PlayerRemoving:Connect(function(Player)
    ESP:Destroy(Player);
end);

-- rconsolelog("Success", "Successfully loaded Events!");

-- rconsolelog("Info", "Hiding Console In 10 seconds...");

-- task.spawn(function()
--     task.wait(9);

--     rconsolelog("Info", "Hiding...");

--     task.wait(1);

--     rconsolehide();
-- end)

print("Loaded ESP.");

return ESP;

--[[

    local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Uvxtq/Custom-Lua-Functions/main/Loader.lua"))();
    local ESP = Functions.ESP;

    local Players = game:GetService("Players");

    ESP:Init("Box", Players, {
        Color = Color3.fromRGB(255, 0, 0),
        TeamCheck = false,
        Distance = 1000,
    });

]]