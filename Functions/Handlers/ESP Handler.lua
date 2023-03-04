local ESP = loadstring(game:HttpGet('https://scripts.luawl.com/17324/NewESP.lua'))();
local Settings = ESP.Settings;
local Color = nil;

local NonRainbowColors = {
    NameColor = Settings.NameColor,
    TeamColor = Settings.TeamColor,
    BoxColor = Settings.BoxColor,
    BoxFillColor = Settings.BoxFillColor,
    SkeletonColor = Settings.SkeletonColor,
    OofArrowsColor = Settings.OofArrowsColor,
    HealthtextColor = Settings.HealthtextColor,
    DistanceColor = Settings.DistanceColor,
};

local LocalPlayer = game:GetService("Players").LocalPlayer;
local VirtualUser = game:GetService("VirtualUser");

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController();
    VirtualUser:ClickButton2(Vector2.new(0, 0));
end)

local function InitESP(Window)
    if not Window then
        return;
    end

    local Tabs = {
        ["ESP Tab"] = Window:AddTab("ESP"),
    };

    local ESPTab = Tabs["ESP Tab"]:AddLeftGroupbox("Enabled");
    local ESPSettingsTab = Tabs["ESP Tab"]:AddRightGroupbox("Settings");
    local ESPColorsTab = Tabs["ESP Tab"]:AddLeftGroupbox("Colors");

    -- << ESP >> --

    ESPTab:AddToggle("Enable ESP", {
        Text = "Enable ESP",
        Default = false,
        Tooltip = "Enable the ESP",
    })

    ESPTab:AddToggle("Enable Boxes", {
        Text = "Enable Boxes",
        Default = false,
        Tooltip = "Enable the Boxes",
    })

    ESPTab:AddToggle("Enable Names", {
        Text = "Enable Names",
        Default = false,
        Tooltip = "Enable the Names",
    })

    ESPTab:AddToggle("Enable Teams", {
        Text = "Enable Teams",
        Default = false,
        Tooltip = "Enable the Teams",
    })

    ESPTab:AddToggle("Enable Healthbars", {
        Text = "Enable Healthbars",
        Default = false,
        Tooltip = "Enable the Healthbars",
    })

    ESPTab:AddToggle("Enable Healthtext", {
        Text = "Enable Healthtext",
        Default = false,
        Tooltip = "Enable the Healthtext",
    })

    ESPTab:AddToggle("Enable Distance", {
        Text = "Enable Distance",
        Default = false,
        Tooltip = "Enable the Distance",
    })

    ESPTab:AddToggle("Enable Arrow", {
        Text = "Enable Arrow",
        Default = false,
        Tooltip = "Enable the Arrow",
    })

    Toggles["Enable Healthbars"]:OnChanged(function()
        Settings.Healthbar = Toggles["Enable Healthbars"].Value;
    end);

    Toggles["Enable Healthtext"]:OnChanged(function()
        Settings.Healthtext = Toggles["Enable Healthtext"].Value;
    end);

    Toggles["Enable Distance"]:OnChanged(function()
        Settings.Distance = Toggles["Enable Distance"].Value;
    end);

    Toggles["Enable Arrow"]:OnChanged(function()
        Settings.OofArrows = Toggles["Enable Arrow"].Value;
    end);

    Toggles["Enable Teams"]:OnChanged(function()
        Settings.Teams = Toggles["Enable Teams"].Value;
    end);

    Toggles["Enable Names"]:OnChanged(function()
        Settings.Names = Toggles["Enable Names"].Value;
    end);

    Toggles["Enable Boxes"]:OnChanged(function()
        Settings.Boxes = Toggles["Enable Boxes"].Value;
    end);

    Toggles["Enable ESP"]:OnChanged(function()
        if Toggles["Enable ESP"].Value then
            ESP:Load();
        else
            ESP:Unload();
        end
    end);

    -- << ESP Colors >> --

    ESPColorsTab:AddLabel("Name Color"):AddColorPicker("Name Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Name Color",
        Callback = function(ColorValue)
            Settings.NameColor = ColorValue;

            NonRainbowColors.NameColor = ColorValue;
        end
    })

    ESPColorsTab:AddLabel("Team Color"):AddColorPicker("Team Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Team Color",
        Callback = function(ColorValue)
            Settings.TeamColor = ColorValue;

            NonRainbowColors.TeamColor = ColorValue;
        end
    })

    ESPColorsTab:AddLabel("Healthtext Color"):AddColorPicker("Healthtext Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Healthtext Color",
        Callback = function(ColorValue)
            Settings.HealthtextColor = ColorValue;

            NonRainbowColors.HealthtextColor = ColorValue;
        end
    })

    ESPColorsTab:AddLabel("Distance Color"):AddColorPicker("Distance Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Distance Color",
        Callback = function(ColorValue)
            Settings.DistanceColor = ColorValue;

            NonRainbowColors.DistanceColor = ColorValue;
        end
    })

    -- << ESP Settings >> --

    ESPSettingsTab:AddDropdown("Box Type", {
        Values = {"Static", "Dynamic"},
        Default = 1,
        Multi = false,

        Text = "Box Type",
        Tooltip = "Changes the Box Type",

        Callback = function(TypeValue)
            Settings.BoxType = TypeValue;
        end
    })

    ESPSettingsTab:AddLabel("Box Color"):AddColorPicker("Box Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Box Color",
        Callback = function(ColorValue)
            Settings.BoxColor = ColorValue;

            NonRainbowColors.BoxColor = ColorValue;
        end
    })

    ESPSettingsTab:AddToggle("Enable Box Fill", {
        Text = "Enable Box Fill",
        Default = false,
        Tooltip = "Enable the Box Fill",
    })

    ESPSettingsTab:AddLabel("Box Fill Color"):AddColorPicker("Box Fill Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Box Fill Color",
        Callback = function(ColorValue)
            Settings.BoxFillColor = ColorValue;

            NonRainbowColors.BoxFillColor = ColorValue;
        end
    })

    ESPSettingsTab:AddSlider("Box Fill Transparency", {
        Text = "Box Fill Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 0.1,
        Compact = false,
        Callback = function(TransparencyValue)
            Settings.BoxFillTransparency = TransparencyValue;
        end
    })

    ESPSettingsTab:AddDivider();

    ESPSettingsTab:AddLabel("Arrow Color"):AddColorPicker("Arrow Color", {
        Default = Color3.new(1, 1, 1),
        Title = "Arrow Color",
        Callback = function(ColorValue)
            Settings.OofArrowsColor = ColorValue;

            NonRainbowColors.OofArrowsColor = ColorValue;
        end
    })

    ESPSettingsTab:AddSlider("Arrow Size", {
        Text = "Arrow Size",
        Default = 20,
        Min = 20,
        Max = 50,
        Rounding = 1,
        Compact = false,
        Callback = function(ArrowSizeValue)
            Settings.OofArrowsSize = ArrowSizeValue;
        end
    })

    ESPSettingsTab:AddSlider("Arrow Radius", {
        Text = "Arrow Radius",
        Default = 50,
        Min = 50,
        Max = 500,
        Rounding = 1,
        Compact = false,
        Callback = function(ArrowRadiusValue)
            Settings.OofArrowsRadius = ArrowRadiusValue;
        end
    })

    ESPSettingsTab:AddDivider();

    ESPSettingsTab:AddToggle("Rainbow ESP", {
        Text = "Rainbow ESP",
        Default = false,
        Tooltip = "Rainbow ESP",
    })

    Toggles["Enable Box Fill"]:OnChanged(function()
        Settings.BoxFill = Toggles["Enable Box Fill"].Value;
    end);

    Toggles["Rainbow ESP"]:OnChanged(function()
        task.defer(function()
            while Toggles["Rainbow ESP"].Value do task.wait()
                Color = Color3.fromHSV(tick() / 10 % 1, 1, 1)

                if Color then
                    Settings.NameColor = Color;
                    Settings.TeamColor = Color;
                    Settings.BoxColor = Color;
                    Settings.BoxFillColor = Color;
                    Settings.SkeletonColor = Color;
                    Settings.OofArrowsColor = Color;
                    Settings.HealthtextColor = Color;
                    Settings.DistanceColor = Color;
                end
            end

            if not Toggles["Rainbow ESP"].Value then
                Settings.NameColor = NonRainbowColors.NameColor;
                Settings.TeamColor = NonRainbowColors.TeamColor;
                Settings.BoxColor = NonRainbowColors.BoxColor;
                Settings.BoxFillColor = NonRainbowColors.BoxFillColor;
                Settings.SkeletonColor = NonRainbowColors.SkeletonColor;
                Settings.OofArrowsColor = NonRainbowColors.OofArrowsColor;
                Settings.HealthtextColor = NonRainbowColors.HealthtextColor;
                Settings.DistanceColor = NonRainbowColors.DistanceColor;
            end
        end)
    end);
end

return InitESP;