local Task = {}; do
    Task.__index = Task;
    Task.__tostring = function(self)
        return string.format("Task(%s)", self.Name);
    end

    function Task.new(Name, Function, Delay, ...)
        local self = setmetatable({}, Task);

        self.Name = Name;
        self.Function = Function;
        self.Delay = Delay;
        self.Args = {...};

        self.Running = false;
        self.Stopped = false;

        return self;
    end

    function Task:Start()
        if self.Running then
            return warn("Task is already running");
        end

        self.Running = true;

        local Success, Error = pcall(function()
            task.wait(self.Delay);
            self.Function(unpack(self.Args));
        end)

        if not Success then
            warn(Error);
        end

        self.Running = false;
        self.Stopped = true;
    end

    function Task:Stop()
        self.Stopped = true;
    end
end

local TaskHandler = {}; do
    TaskHandler.__index = TaskHandler;
    TaskHandler.__tostring = function(self)
        return string.format("TaskHandler(%s)", self.Name);
    end

    function TaskHandler.new(Name)
        local self = setmetatable({}, TaskHandler);

        self.Name = Name;
        self.Tasks = {};

        return self;
    end

    function TaskHandler:AddTask(Name, Function, Delay, ...)
        local Task = Task.new(Name, Function, Delay, ...);
        table.insert(self.Tasks, Task);

        return Task;
    end

    function TaskHandler:Start()
        for _, Task in next, self.Tasks do
            if not Task.Stopped then
                Task:Start();
            end
        end
    end

    function TaskHandler:Stop()
        for _, Task in next, self.Tasks do
            Task:Stop();
        end
    end
end

return TaskHandler;