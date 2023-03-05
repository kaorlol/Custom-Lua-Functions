local PathfindingService = game:GetService("PathfindingService");
local LocalPlayer = game:GetService("Players").LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local function WorldToPoint(Position)
    local Vector, OnScreen = Camera:WorldToViewportPoint(Position);

    return Vector2.new(Vector.X, Vector.Y), OnScreen;
end

local function CheckLength(Table)
    local Length = 0;

    for _, _ in next, Table do
        Length = Length + 1;
    end

    return Length;
end;

local Pathfinding = {}; do
    Pathfinding.__index = Pathfinding;

    function Pathfinding.new(Start: Vector3, Goal: Vector3)
        local self = setmetatable({}, Pathfinding);

        self.PathfindingService = PathfindingService;
        self.LocalPlayer = LocalPlayer;
        self.Character = Character;
        self.Humanoid = Humanoid;

        self.Start = Start;
        self.Goal = Goal;

        self.Lines = {};

        self.Running = false;
        self.Stop = false;

        return self;
    end;

    function Pathfinding:FindPath()
        local Path = self.PathfindingService:FindPathAsync(self.Start, self.Goal);

        if Path.Status == Enum.PathStatus.Success then
            return Path;
        end

        return "Failed to find path";
    end;

    function Pathfinding:VisualizePath(Path)
        local Waypoints = Path:GetWaypoints();

        for Waypoint = 1, #Waypoints do
            local Line = Drawing.new("Line");

            Line.Visible = true;
            Line.Thickness = 2;
            Line.Color = Color3.fromRGB(255, 255, 255);
            Line.Transparency = 1;

            Line.From = WorldToPoint(Waypoints[Waypoint].Position);

            local LineTo;
            if Waypoints[Waypoint + 1] then
                LineTo = Waypoints[Waypoint + 1].Position;
            else
                LineTo = self.Goal;
            end

            Line.To = WorldToPoint(LineTo);

            table.insert(self.Lines, {
                Line = Line,
                From = Waypoints[Waypoint].Position,
                To = LineTo
            });
        end

        task.spawn(function()
            while #self.Lines > 0 do task.wait()
                if self.Stop then
                    for _, Line in next, self.Lines do
                        Line.Line:Remove();
                    end

                    self.Lines = {};

                    return false, "Stopped visualizing path";
                end

                for _, Line in next, self.Lines do
                    local _, OnScreen = Camera:WorldToViewportPoint(Line.From);

                    if OnScreen then
                        Line.Line.Visible = true;
                    else
                        Line.Line.Visible = false;
                    end

                    Line.Line.From = WorldToPoint(Line.From);
                    Line.Line.To = WorldToPoint(Line.To);
                    Line.Line.Color = Color3.fromRGB(255, 255, 255);
                end
            end
        end)
    end;

    function Pathfinding:MoveThroughPath(Path)
        local Waypoints = Path:GetWaypoints();

        self.Running = true;

        task.spawn(function()
            for Waypoint = 1, #Waypoints do
                if self.Stop then
                    self.Running = false;
                    self.Stop = false;

                    return false, "Stopped moving through path";
                else
                    if Waypoints[Waypoint].Action == Enum.PathWaypointAction.Jump then
                        self.Humanoid.Jump = true;
                        self.Humanoid:MoveTo(Waypoints[Waypoint + 1].Position);
                        self.Humanoid.MoveToFinished:Wait();
                    else
                        self.Humanoid:MoveTo(Waypoints[Waypoint].Position);
                        self.Humanoid.MoveToFinished:Wait();
                    end
                end
            end

            if #self.Lines > 0 then
                for _, Line in next, self.Lines do
                    if Line.Line then
                        Line.Line:Destroy();
                        Line.Line.Visible = false;
                    end
                end

                self.Lines = {};
            end

            self.Running = false;

            return true, "Moved through path";
        end)
    end;

    function Pathfinding:ChangeGoal(Start, Goal)
        self.Stop = true;

        local NewPathfinding = Pathfinding.new(Start, Goal);
        local Path = NewPathfinding:FindPath();

        if Path then
            NewPathfinding:VisualizePath(Path);
            NewPathfinding:MoveThroughPath(Path);
        end
    end;

    function Pathfinding:Cancel()
        self.Stop = true;
    end;

    function Pathfinding:IsRunning()
        return self.Running;
    end;

    function Pathfinding:IsStopped()
        return self.Stop;
    end;

    function Pathfinding:GetGoal()
        return self.Goal;
    end;
end

return Pathfinding;