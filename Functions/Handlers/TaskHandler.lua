local RunService = cloneref(game:GetService("RunService"));
local TaskScheduler = {}; do
    TaskScheduler.__index = TaskScheduler;

    function TaskScheduler.new(Name)
        return setmetatable({
            Name = Name;
            Connection = {};
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
            Toggled = false;
        });

        return self;
    end

    function TaskScheduler:Toggle(Name, Toggle, OffFunction)
        for Index, Task in next, self.Tasks do
            if Task.Name == Name then
                self.Tasks[Index].Toggled = Toggle;
                break;
            end
        end

        if not Toggle and OffFunction then
            OffFunction();
        end

        return self;
    end

    function TaskScheduler:Step(Name, ...)
        self.RunTasks = table.clone(self.Tasks);

        for _, Task in next, self.RunTasks do
            if Task.Name == Name then
                self:ProsessTask(Task, ...);
                break;
            end
        end
    end

    function TaskScheduler:ProsessTask(Task, ...)
        local Success, Error = pcall(Task.Task, ...);

        if not Success then
            warn(Error);
        end
    end

    function TaskScheduler:Heartbeat()
        local Heartbeat = RunService.Heartbeat;
        self.RunTasks = table.clone(self.Tasks);

        self.Connection = Heartbeat:Connect(function(...)
            for _, Task in next, self.RunTasks do
                if Task.Toggled then
                    self:Step(Task.Name, ...);
                end
            end
        end);
    end
end

return TaskScheduler;