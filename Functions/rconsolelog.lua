-- << Made by: Sw1ndler#7733 >> --
-- << Refomated by: Kaoru~#6438 >> --

local syn = typeof(syn) == 'table' and syn or nil;
local AnsiFromColors = nil;

if not syn then
    return warn("This script is only for Synapse X users.");
end

local function GetTime()
    local CurrentTime = os.date("*t");
    local Day, Month, Year = CurrentTime.day, CurrentTime.month, CurrentTime.year;
    local Hour, Minute = CurrentTime.hour, CurrentTime.minute;

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

local function Color3FromHex(Hex)
    Hex = Hex:gsub("#", "");

    local R = tonumber(Hex:sub(1, 2), 16) / 255;
    local G = tonumber(Hex:sub(3, 4), 16) / 255;
    local B = tonumber(Hex:sub(5, 6), 16) / 255;

    return Color3.new(R, G, B);
end

local function RobloxColorPrint(Text, TextColor, BgColor)
    TextColor = TextColor or Color3.new(1, 1, 1);
    BgColor = BgColor or "0c0c0c";

    if typeof(TextColor) ~= 'Color3' then
        TextColor = Color3FromHex(TextColor);
    end

    if typeof(BgColor) ~= 'Color3' then
        BgColor = Color3FromHex(BgColor);
    end

    rconsoleprint(AnsiFromColors(Text, TextColor, BgColor));
    rconsoleprint(" ");
end

local function RobloxConsoleLog(Option, Text)
    local BgText;

    RobloxColorPrint(" " .. GetTime() .. " ", "9ea6c9", "16161f");

    if Option == "Loading" then
        RobloxColorPrint(" ... ", "878eac","16161f");
        BgText = "9ea6b0";
    end

    if Option == "Success" then
        RobloxColorPrint(" Success ", "a5db69", "16161f");
        BgText = "a5db69";
    end

    if Option == "Error" then
        RobloxColorPrint(" Error ", "db4b4b", "16161f");
        BgText = "db4b4b";
    end

    if Option == "Warn" then
        RobloxColorPrint(" Warn ", "ffff91", "16161f");
        BgText = "ffff91";
    end

    if Option == "Info" then
        RobloxColorPrint(" info ", "9ea6c9", "16161f");
        BgText = "9ea6c9";
    end

    RobloxColorPrint(Text, BgText);
    rconsoleprint("\n");
end

print("Loaded rconsolelog.");

return RobloxConsoleLog;