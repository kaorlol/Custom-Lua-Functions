local function FormatFileName(Folder, Version, FileName)
    if not Folder or not Version or not FileName then
        return;
    end

    return Folder .. "/" .. Version .. " " .. FileName .. ".lua";
end

local FileHandler = {}; do
    self.Version = "1.0.0";

    function FileHandler:ChangeVersion(NewVersion)
        if not NewVersion then
            return;
        end

        self.Version = NewVersion;
    end;

    function FileHandler:MakeFolder(Name)
        if not Name then
            return;
        end

        if not isfolder(Name) then
            makefolder(Name);
        end
    end;

    function FileHandler:MakeFile(Folder, Name, Content)
        if not Folder or not Name or not Content then
            return;
        end

        if not isfolder(Folder) then
            warn("Folder does not exist");
            return;
        end


        writefile(FormatFileName(Folder, self.Version, Name), Content);
    end;

    function FileHandler:ReadFile(Folder, Name)
        if not Folder or not Name then
            return;
        end

        if not isfolder(Folder) then
            warn("Folder does not exist");
            return;
        end

        if not isfile(FormatFileName(Folder, self.Version, Name)) then
            warn("File does not exist");
            return;
        end

        return readfile(FormatFileName(Folder, self.Version, Name));
    end;

    function FileHandler:LoadFile(Folder, Name)
        if not Folder or not Name then
            return;
        end

        if not isfolder(Folder) then
            warn("Folder does not exist");
            return;
        end

        if not isfile(FormatFileName(Folder, self.Version, Name)) then
            warn("File does not exist");
            return;
        end

        local Success, Failed = pcall(loadstring(readfile(FormatFileName(Folder, self.Version, Name))));

        if Success then
            return Success;
        else
            warn("Failed to load file: " .. Failed);
            return;
        end
    end;
end

return FileHandler;