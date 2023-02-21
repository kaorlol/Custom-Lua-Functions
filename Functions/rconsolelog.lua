-- << Made by: Sw1ndler#7733 >> --
-- << Reworked by: Kaoru~#6438 >> --

local syn = typeof(syn) == 'table' and syn or nil;
local AnsiFromColors = nil;

local function GetTime()
    local CurrentTime = os.date("*t");
    local Day, Month, Year = CurrentTime.day, CurrentTime.month, CurrentTime.year;
    local Hour, Minute = CurrentTime.hour, CurrentTime.min;

    return string.format("%02d/%02d/%04d %02d:%02d", Month, Day, Year, Hour, Minute);
end

if syn and syn.trampoline_call then
    function AnsiFromColors(Text, TextColor, BgColor)
        local TextColorRgb = {math.floor(TextColor.R * 255), math.floor(TextColor.G * 255), math.floor(TextColor.B * 255)};
        local BgColorRgb = {math.floor(BgColor.R * 255), math.floor(BgColor.G * 255), math.floor(BgColor.B * 255)};

        local TextColorCode = "38;2;" .. table.concat(TextColorRgb, ";");
        local BgColorCode = "48;2;" .. table.concat(BgColorRgb, ";");

        return string.format("\x1b[%s;%sm%s\x1b[0m", TextColorCode, BgColorCode, Text);
    end
else
    function AnsiFromColors(Text, TextColor, BgColor)
        local TextColorCode = ("\27[38;2;%d;%d;%dm"):format(TextColor.R * 255, TextColor.G * 255, TextColor.B * 255);
        local BgColorCode = ("\27[48;2;%d;%d;%dm"):format(BgColor.R * 255, BgColor.G * 255, BgColor.B * 255);
        local ResetColorCode = "\27[0m";

        return string.format("%s%s%s%s", TextColorCode, BgColorCode, Text, ResetColorCode);
    end
end

local function RobloxColorPrint(Text, TextColor, BgColor)
    TextColor = TextColor or Color3.new(1, 1, 1);
    BgColor = BgColor or "0c0c0c";

    if typeof(TextColor) ~= 'Color3' then
        TextColor = Color3.fromHex(TextColor);
    end

    if typeof(BgColor) ~= 'Color3' then
        BgColor = Color3.fromHex(BgColor);
    end

    rconsoleprint(AnsiFromColors(Text, TextColor, BgColor));
    rconsoleprint(" ");
end

local Types = {
    ["Loading"] = function(Text)
        RobloxColorPrint(" ... ", "878eac","16161f");
        RobloxColorPrint(Text, "9ea6b0");
    end,
    ["Success"] = function(Text)
        RobloxColorPrint(" Success ", "a5db69", "16161f");
        RobloxColorPrint(Text, "a5db69");
    end,
    ["Error"] = function(Text)
        RobloxColorPrint(" Error ", "db4b4b", "16161f");
        RobloxColorPrint(Text, "db4b4b");
    end,
    ["Warn"] = function(Text)
        RobloxColorPrint(" Warn ", "ffff91", "16161f");
        RobloxColorPrint(Text, "ffff91");
    end,
    ["Info"] = function(Text)
        RobloxColorPrint(" Info ", "9ea6c9", "16161f");
        RobloxColorPrint(Text, "9ea6c9");
    end
};

local function RobloxConsoleLog(Option, Text)
    RobloxColorPrint(" " .. GetTime() .. " ", "9ea6c9", "16161f");

    if Types[Option] then
        Types[Option](Text);
    else
        error("Invalid option: " .. Option)
    end

    rconsoleprint("\n");
end

print("Loaded rconsolelog.");

return RobloxConsoleLog;