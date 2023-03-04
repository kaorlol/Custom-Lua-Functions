local function FormatFileName(Folder, Version, FileName)
    if not Folder or not Version or not FileName then
        return;
    end

    return Folder .. "/" .. Version .. " " .. FileName .. ".lua";
end

local FileHandler = { Version = "1.0.0" }; do
    local Version = FileHandler.Version;

    function FileHandler:ChangeVersion(NewVersion)
        if not NewVersion then
            return;
        end

        Version = NewVersion;
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

        if not isfile(FormatFileName(Folder, Version, Name)) then
            writefile(FormatFileName(Folder, Version, Name), Content);
        end
    end;

    function FileHandler:ReadFile(Folder, Name)
        if not Folder or not Name then
            return;
        end

        if not isfolder(Folder) then
            warn("Folder does not exist");
            return;
        end

        if not isfile(FormatFileName(Folder, Version, Name)) then
            warn("File does not exist");
            return;
        end

        return readfile(FormatFileName(Folder, Version, Name));
    end;

    function FileHandler:LoadFile(Folder, Name)
        if not Folder or not Name then
            return;
        end

        if not isfolder(Folder) then
            warn("Folder does not exist");
            return;
        end

        if not isfile(FormatFileName(Folder, Version, Name)) then
            warn("File does not exist");
            return;
        end

        local Success, Failed = pcall(loadstring(readfile(FormatFileName(Folder, Version, Name))));

        if Success then
            return Success;
        else
            warn("Failed to load file: " .. Failed);
            return;
        end
    end;
end

return FileHandler;