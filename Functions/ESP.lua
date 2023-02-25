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
        local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");

        if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
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
        local Boxes = {};
        local OutlinedBoxes = {};
        local AlreadyBoxed = {};

        function Box:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not AlreadyBoxed[Player.Name] then
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

                    Boxes[Player.Name] = NewBox;
                    OutlinedBoxes[Player.Name] = NewOutlinedBox;
                    AlreadyBoxed[Player.Name] = true;
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and ESP:IsAlive(Player) then
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

                        if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                            Boxes[Player.Name].Visible = true;
                            Boxes[Player.Name].PointA = Vector2.new(Vectors[1].X, Vectors[1].Y);
                            Boxes[Player.Name].PointB = Vector2.new(Vectors[2].X, Vectors[2].Y);
                            Boxes[Player.Name].PointC = Vector2.new(Vectors[3].X, Vectors[3].Y);
                            Boxes[Player.Name].PointD = Vector2.new(Vectors[4].X, Vectors[4].Y);
                            Boxes[Player.Name].Color = Color;

                            OutlinedBoxes[Player.Name].Visible = true;
                            OutlinedBoxes[Player.Name].PointA = Vector2.new(Vectors[1].X, Vectors[1].Y);
                            OutlinedBoxes[Player.Name].PointB = Vector2.new(Vectors[2].X, Vectors[2].Y);
                            OutlinedBoxes[Player.Name].PointC = Vector2.new(Vectors[3].X, Vectors[3].Y);
                            OutlinedBoxes[Player.Name].PointD = Vector2.new(Vectors[4].X, Vectors[4].Y);
                            OutlinedBoxes[Player.Name].Color = Color3.new()
                        end

                        if Distance <= ESPDistance then
                            if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                                Boxes[Player.Name].Visible = true;
                                OutlinedBoxes[Player.Name].Visible = true;
                            end
                        else
                            if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                                Boxes[Player.Name].Visible = false;
                                OutlinedBoxes[Player.Name].Visible = false;
                            end
                        end
                    else
                        if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                            Boxes[Player.Name].Visible = false;
                            OutlinedBoxes[Player.Name].Visible = false;
                        end
                    end
                else
                    if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                        Boxes[Player.Name].Visible = false;
                        OutlinedBoxes[Player.Name].Visible = false;
                    end
                end
            end
        end;

        function Box:Destroy(Player)
            if Boxes[Player.Name] and OutlinedBoxes[Player.Name] then
                Boxes[Player.Name]:Destroy();
                Boxes[Player.Name] = nil;

                OutlinedBoxes[Player.Name]:Destroy();
                OutlinedBoxes[Player.Name] = nil;
            end
        end;
    end

    local Nametag = {}; do
        local Nametags = {};
        local AlreadyNametagged = {};

        function Nametag:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not AlreadyNametagged[Player.Name] then
                    local NewTag = Drawing.new("Text");
                    NewTag.Visible = true;
                    NewTag.Text = "";
                    NewTag.Size = 20;
                    NewTag.Color = Color3.fromRGB(255, 255, 255);
                    NewTag.Outline = true;

                    Nametags[Player.Name] = NewTag;
                    AlreadyNametagged[Player.Name] = true;
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if Player.Character:FindFirstChild("Head") and ESP:IsAlive(Player) and ESP:IsOnScreen(Player, "Head") and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local HeadPosition = Camera:WorldToViewportPoint(Player.Character.Head.Position);

                        if Nametags[Player.Name] then
                            Nametags[Player.Name].Text = ESP:FormatNametag(Player);
                            Nametags[Player.Name].Font = 3;
                            Nametags[Player.Name].Size = 16;
                            Nametags[Player.Name].ZIndex = 2;
                            Nametags[Player.Name].Visible = true;
                            Nametags[Player.Name].Position = Vector2.new(HeadPosition.X - (Nametags[Player.Name].TextBounds.X / 2), HeadPosition.Y - (Nametags[Player.Name].TextBounds.Y * 1.25));
                            Nametags[Player.Name].Color = Color;
                        end

                        if Distance <= ESPDistance then
                            if Nametags[Player.Name] then
                                Nametags[Player.Name].Visible = true;
                            end
                        else
                            if Nametags[Player.Name] then
                                Nametags[Player.Name].Visible = false;
                            end
                        end
                    else
                        if Nametags[Player.Name] then
                            Nametags[Player.Name].Visible = false;
                        end
                    end
                else
                    if Nametags[Player.Name] then
                        Nametags[Player.Name].Visible = false;
                    end
                end
            end
        end;

        function Nametag:Destroy(Player)
            if Nametags[Player.Name] then
                Nametags[Player.Name]:Destroy();
                Nametags[Player.Name] = nil;
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
    end

    Types.Box = Box;
    Types.Nametag = Nametag;
end

Players.PlayerRemoving:Connect(function(Player)
    ESP:Destroy(Player);
end)

return ESP;