assert(getrawmetatable, "Your exploit is not supported.");

local Services = setmetatable({}, {
    __index = function(self, Index)
        local Service = game:GetService(Index);

        if Service then
            self[Index] = Service;

            return Service;
        end
    end;
})

local Initialized = setmetatable({}, {
    __call = function(self, Type)
        if self[Type] then
            return true, "Already Initialized";
        end

        self[Type] = true;

        return false, "Initialized";
    end;
});

local Types = setmetatable({}, {
    __index = function(self, Type)
        local Types = getrawmetatable(self).__index;
        local NewType = newproxy(true);
        local Metatable = getmetatable(NewType);

        Metatable.__tostring = function()
            return Type;
        end

        self[Type] = NewType;

        return Types;
    end;
})

local StorePlayer = setmetatable({}, {
    __call = function(self, Type, PlayerName)
        if not self[Type] then
            self[Type] = {};
        end

        if not self[Type][PlayerName] then
            self[Type][PlayerName] = true;

            return false, "Stored";
        end

        return true, "Already Stored";
    end;
});

local AddObject = setmetatable({}, {
    __call = function(self, Type, Name, Object)
        if not self[Type] then
            self[Type] = {}
        end

        self[Type][Name] = Object

        return Object
    end
})

local GetObject = setmetatable({}, {
    __call = function(self, Type, Name)
        local Success, Failure = pcall(function()
            return rawget(AddObject[Type], Name)
        end)

        return Success and Failure or false;
    end
})

local Players = Services.Players;
local LocalPlayer = Players.LocalPlayer;
local Camera = Services.Workspace.CurrentCamera;

local ESP = {}; do
    function ESP:IsNotSameTeam(Player, Toggle)
        return not Toggle or Player.Team ~= LocalPlayer.Team;
    end

    function ESP:IsAlive(Player)
        return Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0;
    end

    function ESP:IsOnScreen(Player, Part)
        local _, OnScreen = Camera:WorldToViewportPoint(Player.Character[Part].Position);

        return OnScreen;
    end

    function ESP:GetCorners(Part)
        local Size = Part.Size * Vector3.new(1, 1.5)
        return {
            TopRight = (Part.CFrame * CFrame.new(-Size.X, -Size.Y, 0)).Position;
            BottomRight = (Part.CFrame * CFrame.new(-Size.X, Size.Y, 0)).Position;
            TopLeft = (Part.CFrame * CFrame.new(Size.X, -Size.Y, 0)).Position;
            BottomLeft = (Part.CFrame * CFrame.new(Size.X, Size.Y, 0)).Position;
        };
    end

    function ESP:FormatNametag(Player)
        if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
            local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");

            if not self:IsAlive(Player) or Player.Character.Humanoid.Health <= 0 then
                return ("[0] " .. Player.Name .. "| %sHP"):format(Player.Character.Humanoid.Health)
            end

            return string.format("[%s] %s | %sHP", unpack({
                HumanoidRootPart and tostring(math.round((Player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude)) or "N/A",
                Player.Name,
                tostring(math.round(Player.Character.Humanoid.Health))
            }));
        end

        return "N/A";
    end

    local Box = {}; do
        function Box:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not StorePlayer("Box", Player.Name) then
                    local NewBox = Drawing.new("Quad");
                    NewBox.Visible = false;
                    NewBox.PointA = Vector2.new(0, 0);
                    NewBox.PointB = Vector2.new(0, 0);
                    NewBox.PointC = Vector2.new(0, 0);
                    NewBox.PointD = Vector2.new(0, 0);
                    NewBox.Color = Color3.fromRGB(255, 255, 255);
                    NewBox.Thickness = 2;
                    NewBox.Filled = false;

                    local NewOutlinedBox = Drawing.new("Quad");
                    NewOutlinedBox.Visible = false;
                    NewOutlinedBox.PointA = Vector2.new(0, 0);
                    NewOutlinedBox.PointB = Vector2.new(0, 0);
                    NewOutlinedBox.PointC = Vector2.new(0, 0);
                    NewOutlinedBox.PointD = Vector2.new(0, 0);
                    NewOutlinedBox.Color = Color3.fromRGB(255, 255, 255);
                    NewOutlinedBox.Thickness = 1;
                    NewOutlinedBox.Filled = false;

                    AddObject("Boxes", Player.Name, NewBox);
                    AddObject("OutlinedBoxes", Player.Name, NewOutlinedBox);

                    StorePlayer("Box", Player.Name)
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and ESP:IsAlive(Player) then
                    local InlineBox = GetObject("Boxes", Player.Name);
                    local OutlinedBox = GetObject("OutlinedBoxes", Player.Name);
                    
                    local OnScreen = ESP:IsOnScreen(Player, "HumanoidRootPart");
                    local Corners = ESP:GetCorners(Player.Character.HumanoidRootPart);
                    local Vectors = {
                        Camera:WorldToViewportPoint(Corners.TopRight);
                        Camera:WorldToViewportPoint(Corners.BottomRight);
                        Camera:WorldToViewportPoint(Corners.BottomLeft);
                        Camera:WorldToViewportPoint(Corners.TopLeft);
                    };

                    if OnScreen and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;

                        if InlineBox and OutlinedBox then
                            InlineBox.Visible = true;
                            InlineBox.PointA = Vector2.new(Vectors[1].X, Vectors[1].Y);
                            InlineBox.PointB = Vector2.new(Vectors[2].X, Vectors[2].Y);
                            InlineBox.PointC = Vector2.new(Vectors[3].X, Vectors[3].Y);
                            InlineBox.PointD = Vector2.new(Vectors[4].X, Vectors[4].Y);
                            InlineBox.Color = Color;

                            OutlinedBox.Visible = true;
                            OutlinedBox.PointA = Vector2.new(Vectors[1].X, Vectors[1].Y);
                            OutlinedBox.PointB = Vector2.new(Vectors[2].X, Vectors[2].Y);
                            OutlinedBox.PointC = Vector2.new(Vectors[3].X, Vectors[3].Y);
                            OutlinedBox.PointD = Vector2.new(Vectors[4].X, Vectors[4].Y);
                            OutlinedBox.Color = Color3.new()
                        end

                        if Distance <= ESPDistance then
                            if InlineBox and OutlinedBox then
                                InlineBox.Visible = true;
                                OutlinedBox.Visible = true;
                            end
                        else
                            if InlineBox and OutlinedBox then
                                InlineBox.Visible = false;
                                OutlinedBox.Visible = false;
                            end
                        end
                    else
                        if InlineBox and OutlinedBox then
                            InlineBox.Visible = false;
                            OutlinedBox.Visible = false;
                        end
                    end
                else
                    local InlineBox = GetObject("Boxes", Player.Name);
                    local OutlinedBox = GetObject("OutlinedBoxes", Player.Name);

                    if InlineBox and OutlinedBox then
                        InlineBox.Visible = false;
                        OutlinedBox.Visible = false;
                    end
                end
            end
        end;

        function Box:Destroy(Player)
            local InlineBox = GetObject("Boxes", Player.Name);
            local OutlinedBox = GetObject("OutlinedBoxes", Player.Name);

            if InlineBox and OutlinedBox then
                InlineBox:Destroy();
                InlineBox = nil;

                OutlinedBox:Destroy();
                OutlinedBox = nil;
            end
        end;
    end

    local Nametag = {}; do
        function Nametag:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not StorePlayer("Nametag", Player.Name) then
                    local NewTag = Drawing.new("Text");
                    NewTag.Visible = true;
                    NewTag.Text = "";
                    NewTag.Size = 20;
                    NewTag.Color = Color3.fromRGB(255, 255, 255);
                    NewTag.Outline = true;

                    AddObject("Nametags", Player.Name, NewTag);
                    StorePlayer("Nametag", Player.Name)
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if Player.Character:FindFirstChild("Head") and ESP:IsAlive(Player) and ESP:IsOnScreen(Player, "Head") and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local HeadPosition = Camera:WorldToViewportPoint(Player.Character.Head.Position);

                        local FoundNametag = GetObject("Nametags", Player.Name);

                        if FoundNametag then
                            FoundNametag.Text = ESP:FormatNametag(Player);
                            FoundNametag.Font = 3;
                            FoundNametag.Size = 16;
                            FoundNametag.ZIndex = 2;
                            FoundNametag.Visible = true;
                            FoundNametag.Position = Vector2.new(HeadPosition.X - (FoundNametag.TextBounds.X / 2), HeadPosition.Y - (FoundNametag.TextBounds.Y * 1.25));
                            FoundNametag.Color = Color;
                        end

                        if Distance <= ESPDistance then
                            if FoundNametag then
                                FoundNametag.Visible = true;
                            end
                        else
                            if FoundNametag then
                                FoundNametag.Visible = false;
                            end
                        end
                    else
                        local FoundNametag = GetObject("Nametags", Player.Name);

                        if FoundNametag then
                            FoundNametag.Visible = false;
                        end
                    end
                else
                    local FoundNametag = GetObject("Nametags", Player.Name);

                    if FoundNametag then
                        FoundNametag.Visible = false;
                    end
                end
            end
        end;

        function Nametag:Destroy(Player)
            local FoundNametag = GetObject("Nametags", Player.Name);

            if FoundNametag then
                FoundNametag:Destroy();
                FoundNametag = nil;
            end
        end;
    end

    function ESP:Init(Type, Args)
        local Rainbow = Args.Rainbow or false;

        if typeof(Type) == "table" then
            for _, NewType in next, Type do
                self:Init(NewType, Args);
            end

            return;
        end

        task.spawn(function()
            while true do task.wait();
                if not Initialized(Type) then break; end

                if Rainbow then
                    Args.Color = Color3.fromHSV(tick() / 10 % 1, 1, 1);
                end

                Types[Type]:Draw(Args);
            end
        end)

        Initialized(Type);
    end

    function ESP:DeInit()
        for _, Player in next, Players:GetPlayers() do
            ESP:Destroy(Player);
        end

        for Type,_ in next, Initialized do
            rawset(Initialized, Type, nil);
        end
    end

    function ESP:Destroy(Player)
        for _, Type in next, Types do
            if Type.Destroy then
                Type:Destroy(Player);
            end
        end

        for Type,_ in next, Initialized do
            rawset(StorePlayer, Type, nil);
        end
    end

    Types.Box = Box;
    Types.Nametag = Nametag;
end

Players.PlayerRemoving:Connect(function(Player)
    ESP:Destroy(Player);
end)

return ESP;

-- ESP:Init({"Box", "Nametag"}, {
--     Color = Color3.fromRGB(255, 255, 255),
--     Distance = 1000,
--     TeamCheck = false,
--     --Rainbow = false
-- })

