local RunService = cloneref(game:GetService("RunService"));
local TaskScheduler = {}; do
    TaskScheduler.__index = TaskScheduler;

    function TaskScheduler.new(Name)
        return setmetatable({
            Name = Name;
            Connections = {};
            Tasks = {};
            Scheduled = {};
            ParentSchedulers = {};
        }, TaskScheduler);
    end

    function TaskScheduler:Add(Name, Task)
        local RunTask = Task;

        if typeof(Task) == "table" and Task.Scheduled then
            RunTask = function(...)
                Task:Step(...);
            end
        end

        table.insert(self.Tasks, {
            Name = Name;
            Task = RunTask;
        });

        return self;
    end

    function TaskScheduler:Remove(Name)
        for Index, Task in next, self.Tasks do
            if Task.Name == Name then
                if self.Connections[Name] then
                    self.Connections[Name]:Disconnect();
                    self.Connections[Name] = nil;
                end

                table.remove(self.Tasks, Index);
            end
        end

        return self;
    end

    function TaskScheduler:Step(Name, ...)
        self.RunTasks = table.clone(self.Tasks);
        self:ProsessTask(self.RunTasks[Name], ...);
    end

    function TaskScheduler:ProsessTask(Task, ...)
        local Success, Error = pcall(Task.Task, ...);

        if not Success then
            warn(Error);
        end
    end

    function TaskScheduler:Heartbeat(Step)
        local Heartbeat = RunService.Heartbeat;

        self.Connections[Step] = Heartbeat:Connect(function(...)
            self:Step(Step, ...);
        end);
    end
end

return TaskScheduler;