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
            self[Type] = {};
        end

        self[Type][Name] = Object;

        return Object;
    end;
})

local GetObject = setmetatable({}, {
    __call = function(self, Type, Name)
        local Success, Failure = pcall(function()
            return rawget(AddObject[Type], Name);
        end)

        return Success and Failure or false;
    end;
})

local RemoveObject = setmetatable({}, {
    __call = function(self, Type, Name)
        local Success, Failure = pcall(function()
            return rawset(AddObject[Type], Name, nil);
        end)

        return Success and Failure or false;
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


    function ESP:GetCorners(Part, FaceCamera)
        FaceCamera = FaceCamera or false;

        local Size = Part.Size * Vector3.new(1, 1.5)
        local PartCFrame = Part.CFrame;

        if FaceCamera then
            local LookVector = (Part.Position - Camera.CFrame.Position).Unit;

            PartCFrame = CFrame.new(Part.Position, Part.Position + Vector3.new(LookVector.X, 0, LookVector.Z));
        end

        return {
            TopRight = (PartCFrame * CFrame.new(-Size.X, -Size.Y, 0)).Position;
            BottomRight = (PartCFrame * CFrame.new(-Size.X, Size.Y, 0)).Position;
            TopLeft = (PartCFrame * CFrame.new(Size.X, -Size.Y, 0)).Position;
            BottomLeft = (PartCFrame * CFrame.new(Size.X, Size.Y, 0)).Position;
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

    function ESP:PointOffset(Point, Offset)
        return Vector2.new(Point.X + Offset.X, Point.Y + Offset.Y);
    end

    local Healthbar = {}; do
        function Healthbar:Draw(Args)
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not StorePlayer("Healthbar", Player.Name) then
                    local NewBar = Drawing.new("Line");
                    NewBar.Visible = true;
                    NewBar.Color = Color3.fromRGB(255, 255, 255);
                    NewBar.Thickness = 3;
                    NewBar.Transparency = 1;
                    NewBar.ZIndex = 2;

                    local Background = Drawing.new("Line");
                    Background.Visible = true;
                    Background.Color = Color3.new();
                    Background.Thickness = 3;
                    Background.Transparency = 1;
                    Background.ZIndex = 1;

                    AddObject("Background Healthbars", Player.Name, Background);
                    AddObject("Healthbars", Player.Name, NewBar);
                    StorePlayer("Healthbar", Player.Name)
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if Player.Character:FindFirstChild("Head") and ESP:IsAlive(Player) and ESP:IsOnScreen(Player, "Head") and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local FoundHealthbar = GetObject("Healthbars", Player.Name);
                        local FoundBackground = GetObject("Background Healthbars", Player.Name);
                        local OnScreen = ESP:IsOnScreen(Player, "Head");
                        local LeftPoints = GetObject("Left Points", Player.Name);

                        if OnScreen then
                            local Health = Player.Character.Humanoid.Health;
                            local MaxHealth = Player.Character.Humanoid.MaxHealth;

                            if LeftPoints and LeftPoints[1] and LeftPoints[2] then
                                FoundHealthbar.From = Vector2.new(LeftPoints[1].X, LeftPoints[1].Y);
                                FoundHealthbar.To = Vector2.new(LeftPoints[2].X, LeftPoints[2].Y);
                            end

                            FoundHealthbar.Color = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), Health / MaxHealth)

                            if Distance <= ESPDistance then
                                FoundHealthbar.Visible = true;
                                FoundBackground.Visible = true;
                            else
                                FoundHealthbar.Visible = false;
                                FoundBackground.Visible = false;
                            end
                        else
                            FoundHealthbar.Visible = false;
                            FoundBackground.Visible = false;
                        end
                    else
                        local FoundHealthbar = GetObject("Healthbars", Player.Name);
                        local FoundBackground = GetObject("Background Healthbars", Player.Name);

                        if FoundHealthbar then
                            FoundHealthbar.Visible = false;
                            FoundBackground.Visible = false;
                        end
                    end
                end
            end
        end;

        function Healthbar:Destroy(Player)
            local FoundHealthbar = GetObject("Healthbars", Player.Name);
            local FoundBackground = GetObject("Background Healthbars", Player.Name);

            if FoundHealthbar then
                FoundHealthbar:Destroy();
                FoundHealthbar = nil;
            end

            if FoundBackground then
                FoundBackground:Destroy();
                FoundBackground = nil;
            end
        end;
    end

    local Box = {}; do
        function Box:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;
            local FaceCamera = Args.FaceCamera or false;
            local HealthBarEnabled = Args.Healthbar or false;

            if HealthBarEnabled then
                Healthbar:Draw({
                    Distance = ESPDistance;
                    TeamCheck = TeamCheck;
                });
            end

            for _, Player in next, Players:GetPlayers() do
                if not StorePlayer("Box", Player.Name) then
                    local NewBox = Drawing.new("Quad");
                    NewBox.Visible = false;
                    NewBox.PointA = Vector2.new(0, 0);
                    NewBox.PointB = Vector2.new(0, 0);
                    NewBox.PointC = Vector2.new(0, 0);
                    NewBox.PointD = Vector2.new(0, 0);
                    NewBox.Color = Color3.fromRGB(255, 255, 255);
                    NewBox.Thickness = 3;
                    NewBox.Filled = false;

                    AddObject("Boxes", Player.Name, NewBox);

                    StorePlayer("Box", Player.Name)
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and ESP:IsAlive(Player) then
                    local InlineBox = GetObject("Boxes", Player.Name);

                    local OnScreen = ESP:IsOnScreen(Player, "HumanoidRootPart");
                    local Corners = ESP:GetCorners(Player.Character.HumanoidRootPart, FaceCamera);
                    local Vectors = {
                        Camera:WorldToViewportPoint(Corners.TopRight);
                        Camera:WorldToViewportPoint(Corners.BottomRight);
                        Camera:WorldToViewportPoint(Corners.BottomLeft);
                        Camera:WorldToViewportPoint(Corners.TopLeft);
                    };

                    if OnScreen and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local TopRight, BottomRight, BottomLeft, TopLeft = unpack(Vectors);

                        if InlineBox then
                            InlineBox.Visible = true;
                            InlineBox.PointA = Vector2.new(TopRight.X, TopRight.Y);
                            InlineBox.PointB = Vector2.new(BottomRight.X, BottomRight.Y);
                            InlineBox.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y);
                            InlineBox.PointD = Vector2.new(TopLeft.X, TopLeft.Y);
                            InlineBox.Color = Color;

                            AddObject("Left Points", Player.Name, {
                                ESP:PointOffset(InlineBox.PointA, Vector2.new(-7.5, 0));
                                ESP:PointOffset(InlineBox.PointB, Vector2.new(-7.5, 0));
                            });
                        end

                        if Distance <= ESPDistance then
                            if InlineBox then
                                InlineBox.Visible = true;
                            end
                        else
                            if InlineBox then
                                InlineBox.Visible = false;
                            end
                        end
                    else
                        if InlineBox then
                            InlineBox.Visible = false;
                        end
                    end
                else
                    local InlineBox = GetObject("Boxes", Player.Name);

                    if InlineBox then
                        InlineBox.Visible = false;
                    end
                end
            end
        end;

        function Box:Destroy(Player)
            local InlineBox = GetObject("Boxes", Player.Name);

            if InlineBox then
                InlineBox:Destroy();
                InlineBox = nil;
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
                    NewTag.Size = 16;
                    NewTag.Color = Color3.fromRGB(255, 255, 255);
                    NewTag.Outline = true;
                    NewTag.Center = true;
                    NewTag.Font = 3;
                    NewTag.ZIndex = 2;

                    AddObject("Nametags", Player.Name, NewTag);
                    StorePlayer("Nametag", Player.Name)
                end

                local function WorldToVector(Position)
                    local Vector = Camera:WorldToViewportPoint(Position);

                    return Vector2.new(Vector.X, Vector.Y), Vector.Z;
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if Player.Character:FindFirstChild("Head") and ESP:IsAlive(Player) and ESP:IsOnScreen(Player, "Head") and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local Size = Player.Character.HumanoidRootPart.Size;
                        local Top = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, (Size.Y / 2) + 2, 0);

                        local FoundNametag = GetObject("Nametags", Player.Name);

                        if FoundNametag then
                            FoundNametag.Text = ESP:FormatNametag(Player);
                            FoundNametag.Visible = true;
                            FoundNametag.Position = WorldToVector(Top.Position);
                            FoundNametag.Position = Vector2.new(FoundNametag.Position.X, FoundNametag.Position.Y - FoundNametag.TextBounds.Y / 2 - 10);
                            -- FoundNametag.Position = Vector2.new(NewHeadPosition.X - (FoundNametag.TextBounds.X / 2), NewHeadPosition.Y - (FoundNametag.TextBounds.Y * 1.25));
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

    local Box3D = {}; do
        function Box3D:Draw(Args)
            local Color = Args.Color or Color3.fromRGB(255, 255, 255);
            local ESPDistance = Args.Distance or 1000;
            local TeamCheck = Args.TeamCheck or false;

            for _, Player in next, Players:GetPlayers() do
                if not StorePlayer("Box3Ds", Player.Name) then
                    local FistQuad = Drawing.new("Quad");
                    FistQuad.Visible = true;
                    FistQuad.Color = Color3.fromRGB(255, 255, 255);
                    FistQuad.Thickness = 3;
                    FistQuad.Transparency = 1;

                    local SecondQuad = Drawing.new("Quad");
                    SecondQuad.Visible = true;
                    SecondQuad.Color = Color3.fromRGB(255, 255, 255);
                    SecondQuad.Thickness = 3;
                    SecondQuad.Transparency = 1;

                    local ThirdQuad = Drawing.new("Quad");
                    ThirdQuad.Visible = true;
                    ThirdQuad.Color = Color3.fromRGB(255, 255, 255);
                    ThirdQuad.Thickness = 3;
                    ThirdQuad.Transparency = 1;

                    local FourthQuad = Drawing.new("Quad");
                    FourthQuad.Visible = true;
                    FourthQuad.Color = Color3.fromRGB(255, 255, 255);
                    FourthQuad.Thickness = 3;
                    FourthQuad.Transparency = 1;

                    AddObject("Box3Ds", Player.Name, {
                        FistQuad = FistQuad;
                        SecondQuad = SecondQuad;
                        ThirdQuad = ThirdQuad;
                        FourthQuad = FourthQuad;
                    });
                end

                local function CreateFaces(Position, SizeXYZ)
                    local X, Y, Z = unpack(SizeXYZ)

                    local Faces = {
                        FrontFaces = {
                            Position * CFrame.new(X, Y, -Z);
                            Position * CFrame.new(X, -Y, -Z);
                            Position * CFrame.new(-X, -Y, -Z);
                            Position * CFrame.new(-X, Y, -Z);
                        };

                        BackFaces = {
                            Position * CFrame.new(-X, Y, Z);
                            Position * CFrame.new(-X, -Y, Z);
                            Position * CFrame.new(X, -Y, Z);
                            Position * CFrame.new(X, Y, Z);
                        };

                        RightFaces = {
                            Position * CFrame.new(-X, Y, -Z);
                            Position * CFrame.new(-X, -Y, -Z);
                            Position * CFrame.new(-X, -Y, Z);
                            Position * CFrame.new(-X, Y, Z);
                        };

                        LeftFaces = {
                            Position * CFrame.new(X, Y, -Z);
                            Position * CFrame.new(X, -Y, -Z);
                            Position * CFrame.new(X, -Y, Z);
                            Position * CFrame.new(X, Y, Z);
                        };
                    };

                    return Faces;
                end

                local function WorldToVector(Position)
                    local Vector = Camera:WorldToViewportPoint(Position);

                    return Vector2.new(Vector.X, Vector.Y), Vector.Z;
                end

                if Player and Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if ESP:IsAlive(Player) and ESP:IsNotSameTeam(Player, TeamCheck) then
                        local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                        local FoundObjects = GetObject("Box3Ds", Player.Name);
                        local OnScreen = ESP:IsOnScreen(Player, "HumanoidRootPart");

                        if OnScreen then
                            local Orientation, Size = Player.Character:GetBoundingBox();
                            local Faces = CreateFaces(Player.Character.HumanoidRootPart.CFrame, {
                                Size.X / 2;
                                Size.Y / 2;
                                Size.Z / 2;
                            });

                            local QuadPoints = {
                                ["FistQuad"] = Faces.FrontFaces,
                                ["SecondQuad"] = Faces.BackFaces,
                                ["ThirdQuad"] = Faces.RightFaces,
                                ["FourthQuad"] = Faces.LeftFaces,
                            };

                            for QuadName, FacePoints in next, QuadPoints do
                                FoundObjects[QuadName].PointA = WorldToVector(FacePoints[1].Position)
                                FoundObjects[QuadName].PointB = WorldToVector(FacePoints[2].Position)
                                FoundObjects[QuadName].PointC = WorldToVector(FacePoints[3].Position)
                                FoundObjects[QuadName].PointD = WorldToVector(FacePoints[4].Position)

                                FoundObjects[QuadName].Color = Color;
                            end

                            if Distance <= ESPDistance then
                                FoundObjects.FistQuad.Visible = true;
                                FoundObjects.SecondQuad.Visible = true;
                                FoundObjects.ThirdQuad.Visible = true;
                                FoundObjects.FourthQuad.Visible = true;
                            else
                                FoundObjects.FistQuad.Visible = false;
                                FoundObjects.SecondQuad.Visible = false;
                                FoundObjects.ThirdQuad.Visible = false;
                                FoundObjects.FourthQuad.Visible = false;
                            end
                        else
                            FoundObjects.FistQuad.Visible = false;
                            FoundObjects.SecondQuad.Visible = false;
                            FoundObjects.ThirdQuad.Visible = false;
                            FoundObjects.FourthQuad.Visible = false;
                        end
                    else
                        local FoundObjects = GetObject("Box3Ds", Player.Name);

                        if FoundObjects then
                            for _, Object in next, FoundObjects do
                                Object.Visible = false;
                            end
                        end
                    end
                end
            end
        end

        function Box3D:Destroy(Player)
            local FoundObjects = GetObject("Box3Ds", Player.Name);

            if FoundObjects then
                for _, Object in next, FoundObjects do
                    Object:Destroy();
                    Object = nil;
                end
            end
        end
    end

    function ESP:Init(Type, Args)
        local Rainbow = Args.Rainbow or false;

        if typeof(Type) == "table" then
            for _, NewType in next, Type do
                self:Init(NewType, Args);
            end

            return;
        end

        if not Types[Type] or Type == "Healthbar" then
            return warn("Invalid type: " .. Type);
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
    Types.Box3D = Box3D;
    Types.Healthbar = Healthbar;
end

Players.PlayerRemoving:Connect(function(Player)
    ESP:Destroy(Player);
end)

return ESP;