

local Settings = {
	TimeVariance = 0.07;
	ComparisonChecks = 1;
	JumpWhenStuck = true;
};

local PathfindingService = game:GetService("PathfindingService");
local Players = game:GetService("Players");

local function Output(Function, Message)
	Function(((Function == error and "SimplePath Error: ") or "SimplePath: ") .. Message);
end

local function WorldToView(Position)
	local Camera = workspace.CurrentCamera;
	local Vector, OnScreen = Camera:WorldToViewportPoint(Position);

	return Vector2.new(Vector.X, Vector.Y), Vector.Z;
end

local Path = {
	StatusType = {
		Idle = "Idle";
		Active = "Active";
	};
	ErrorType = {
		LimitReached = "LimitReached";
		TargetUnreachable = "TargetUnreachable";
		ComputationError = "ComputationError";
		AgentStuck = "AgentStuck";
	};
}
Path.__index = function(Table, Index)
	if Index == "Stopped" and not Table.Humanoid then
		Output(error, "Attempt to use Path.Stopped on a non-humanoid.");
	end

	return (Table.Events[Index] and Table.Events[Index].Event)
		or (Index == "LastError" and Table.LastError)
		or (Index == "Status" and Table.Status)
		or Path[Index];
end

local VisualWaypoint = Instance.new("Part");
VisualWaypoint.Size = Vector3.new(0.3, 0.3, 0.3);
VisualWaypoint.Anchored = true;
VisualWaypoint.CanCollide = false;
VisualWaypoint.Material = Enum.Material.Neon;
VisualWaypoint.Shape = Enum.PartType.Ball;

local function DeclareError(self, ErrorType)
	self.LastError = ErrorType;
	self.Events.Error:Fire(ErrorType);
end

local function CreateVisualWaypoints(Waypoints)
	local VisualWaypoints = {};

	for _, Waypoint in ipairs(Waypoints) do
		local VisualWaypointClone = VisualWaypoint:Clone();
		VisualWaypointClone.Position = Waypoint.Position;
		VisualWaypointClone.Parent = workspace;
		VisualWaypointClone.Color =
			(Waypoint == Waypoints[#Waypoints] and Color3.fromRGB(0, 255, 0))
			or (Waypoint.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(255, 0, 0))
			or Color3.fromRGB(255, 139, 0);
		table.insert(VisualWaypoints, VisualWaypointClone);
	end

	return VisualWaypoints;
end

-- local function CreateVisualWaypoints(Waypoints)
-- 	local VisualWaypoints = {};
-- 	local LastPosition = nil;

-- 	for _, Waypoint in ipairs(Waypoints) do
-- 		local Line = Drawing.new("Line");
-- 		Line.Visible = true;
-- 		Line.Thickness = 0.1;
-- 		Line.Color =
-- 			(Waypoint == Waypoints[#Waypoints] and Color3.fromRGB(0, 255, 0))
-- 			or (Waypoint.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(255, 0, 0))
-- 			or Color3.fromRGB(255, 139, 0);
-- 		Line.From = WorldToView(LastPosition or Waypoint.Position);
-- 		Line.To = WorldToView(Waypoint.Position);

-- 		LastPosition = Waypoint.Position;

-- 		table.insert(VisualWaypoints, Line);
-- 	end

-- 	return VisualWaypoints;
-- end

local function DestroyVisualWaypoints(Waypoints)
	if Waypoints then
		for _, Waypoint in ipairs(Waypoints) do
			Waypoint:Destroy();
		end
	end

	return;
end

local function GetNonHumanoidWaypoint(self)
	for Waypoint = 2, #self.Waypoints do
		if (self.Waypoints[Waypoint].Position - self.Waypoints[Waypoint - 1].Position).Magnitude > 0.1 then
			return Waypoint;
		end
	end

	return 2;
end

local function SetJumpState(self)
	pcall(function()
		if self.Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and self.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
		end
	end)
end

local function Move(self)
	if self.Waypoints[self.CurrentWaypoint].Action == Enum.PathWaypointAction.Jump then
		SetJumpState(self);
	end

	self.Humanoid:MoveTo(self.Waypoints[self.CurrentWaypoint].Position);
end

local function DisconnectMoveConnection(self)
	self.MoveConnection:Disconnect();
	self.MoveConnection = nil;
end

local function InvokeWaypointReached(self)
	local LastWaypoint = self.Waypoints[self.CurrentWaypoint - 1];
	local NextWaypoint = self.Waypoints[self.CurrentWaypoint];

	self.Events.WaypointReached:Fire(self.Agent, LastWaypoint, NextWaypoint);
end

local function MoveToFinished(self, Reached)
	if not getmetatable(self) then return; end

	if not self.Humanoid then
		if Reached and self.CurrentWaypoint + 1 <= #self.Waypoints then
			InvokeWaypointReached(self);
			self.CurrentWaypoint += 1;
		elseif Reached then
			self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
			self.Target = nil;
			self.Events.Reached:Fire(self.Agent, self.Waypoints[self.CurrentWaypoint]);
		else
			self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
			self.Target = nil;
			DeclareError(self, self.ErrorType.TargetUnreachable);
		end

		return;
	end

	if Reached and self.CurrentWaypoint + 1 <= #self.Waypoints then
		if self.CurrentWaypoint + 1 < #self.Waypoints then
			InvokeWaypointReached(self);
		end

		self.CurrentWaypoint += 1;
		Move(self);
	elseif Reached then
		DisconnectMoveConnection(self);
		self.Status = Path.StatusType.Idle;
		self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
		self.Events.Reached:Fire(self.Agent, self.Waypoints[self.CurrentWaypoint]);
	else
		DisconnectMoveConnection(self);
		self.Status = Path.StatusType.Idle;
		self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
		DeclareError(self, self.ErrorType.TargetUnreachable);
	end
end

local function ComparePosition(self)
	if self.CurrentWaypoint == #self.Waypoints then return; end
	self.Position.Count = ((self.Agent.PrimaryPart.Position - self.Position.Last).Magnitude <= 0.07 and (self.Position.Count + 1)) or 0;
	self.Position.Last = self.Agent.PrimaryPart.Position;

	if self.Position.Count >= self.Settings.ComparisonChecks then
		if self.Settings.JumpWhenStuck then
			SetJumpState(self);
		end

		DeclareError(self, self.ErrorType.AgentStuck);
	end
end

function Path.GetNearestCharacter(FromPosition)
	local Character, Distance = nil, math.huge;

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player.Character and (Player.Character.PrimaryPart.Position - FromPosition).Magnitude < Distance then
			Character, Distance = Player.Character, (Player.Character.PrimaryPart.Position - FromPosition).Magnitude;
		end
	end

	return Character;
end

function Path.new(Agent, AgentParameters, Override)
	if not (Agent and Agent:IsA("Model") and Agent.PrimaryPart) then
		Output(error, "Pathfinding agent must be a valid Model Instance with a set PrimaryPart.");
	end

	local self = setmetatable({
		Settings = Override or Settings;
		Events = {
			Reached = Instance.new("BindableEvent");
			WaypointReached = Instance.new("BindableEvent");
			Blocked = Instance.new("BindableEvent");
			Error = Instance.new("BindableEvent");
			Stopped = Instance.new("BindableEvent");
		};
		Agent = Agent;
		Humanoid = Agent:FindFirstChildOfClass("Humanoid");
		Path = PathfindingService:CreatePath(AgentParameters);
		Status = "Idle";
		Time = 0;
		Position = {
			Last = Vector3.new();
			Count = 0;
		};
	}, Path)

	for Setting, Value in next, Settings do
		self.Settings[Setting] = self.Settings[Setting] == nil and Value or self.Settings[Setting];
	end

	self.Path.Blocked:Connect(function(...)
		if (self.CurrentWaypoint <= ... and self.CurrentWaypoint + 1 >= ...) and self.Humanoid then
			SetJumpState(self);
			self.Events.Blocked:Fire(self.Agent, self.Waypoints[...]);
		end
	end)

	return self;
end


function Path:Destroy()
	for _, Event in ipairs(self.Events) do
		Event:Destroy();
	end
	self.Events = nil;

	if rawget(self, "VisualWaypoints") then
		self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
	end

	self.Path:Destroy();
	setmetatable(self, nil);

	for key, _ in next, self do
		self[key] = nil;
	end
end

function Path:Stop()
	if not self.Humanoid then
		Output(error, "Attempt to call Path:Stop() on a non-humanoid.");

		return;
	end

	if self.Status == Path.StatusType.Idle then
		Output(function(m)
			warn(debug.traceback(m));
		end, "Attempt to run Path:Stop() in idle state");

		return;
	end

	DisconnectMoveConnection(self)
	self.Status = Path.StatusType.Idle;
	self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
	self.Events.Stopped:Fire(self.Model);
end

function Path:Run(Target)
	if not Target and not self.Humanoid and self.Target then
		MoveToFinished(self, true);

		return;
	end

	if not (Target and (typeof(Target) == "Vector3" or Target:IsA("BasePart"))) then
		Output(error, "Pathfinding target must be a valid Vector3 or BasePart.");
	end

	if os.clock() - self.Time <= self.Settings.TimeVariance and self.Humanoid then
		task.wait(os.clock() - self.Time);
		DeclareError(self, self.ErrorType.LimitReached);

		return false;
	elseif self.Humanoid then
		self.Time = os.clock();
	end

	local HumanoidRootPart = self.Agent:FindFirstChild("HumanoidRootPart");

	if not HumanoidRootPart then
		HumanoidRootPart = self.Agent.PrimaryPart;
	end

	local PathComputed, _ = pcall(function()
		self.Path:ComputeAsync(HumanoidRootPart.Position, (typeof(Target) == "Vector3" and Target) or Target.Position);
	end)

	if not PathComputed
		or self.Path.Status == Enum.PathStatus.NoPath
		or #self.Path:GetWaypoints() < 2
		or (self.Humanoid and self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall) then

		self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
		task.wait();
		DeclareError(self, self.ErrorType.ComputationError);

		return false;
	end

	self.Status = (self.Humanoid and Path.StatusType.Active) or Path.StatusType.Idle;
	self.Target = Target;

	pcall(function()
		self.Agent.PrimaryPart:SetNetworkOwner(nil);
	end)

	self.Waypoints = self.Path:GetWaypoints();
	self.CurrentWaypoint = 2;

	if self.Humanoid then
		ComparePosition(self);
	end

	DestroyVisualWaypoints(self.VisualWaypoints);
	self.VisualWaypoints = (self.Visualize and CreateVisualWaypoints(self.Waypoints));

	self.MoveConnection = self.Humanoid and (self.MoveConnection or self.Humanoid.MoveToFinished:Connect(function(...)
		MoveToFinished(self, ...);
	end))

	if self.Humanoid then
		self.Humanoid:MoveTo(self.Waypoints[self.CurrentWaypoint].Position);
	elseif #self.Waypoints == 2 then
		self.Target = nil;
		self.VisualWaypoints = DestroyVisualWaypoints(self.VisualWaypoints);
		self.Events.Reached:Fire(self.Agent, self.Waypoints[2]);
	else
		self.CurrentWaypoint = GetNonHumanoidWaypoint(self);
		MoveToFinished(self, true);
	end

	return true;
end

return Path;