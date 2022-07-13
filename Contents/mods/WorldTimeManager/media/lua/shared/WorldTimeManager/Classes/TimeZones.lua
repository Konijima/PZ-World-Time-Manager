local stringTimezones = {
    "-12:00",
    "-11:00",
    "-10:00",
    "-09:30",
    "-09:00",
    "-08:00",
    "-07:00",
    "-06:00",
    "-05:00",
    "-04:00",
    "-03:30",
    "-03:00",
    "-02:00",
    "-01:00",
    "00:00",
    "+01:00",
    "+02:00",
    "+03:00",
    "+03:30",
    "+04:00",
    "+04:30",
    "+05:00",
    "+05:30",
    "+05:45",
    "+06:00",
    "+06:30",
    "+07:00",
    "+08:00",
    "+08:45",
    "+09:00",
    "+09:30",
    "+10:00",
    "+10:30",
    "+11:00",
    "+12:00",
    "+12:45",
    "+13:00",
    "+14:00",
};

---@class TimeZones
local TimeZones = {};

---@param index number
function TimeZones.GetAsString(index)
    return stringTimezones[index];
end

---@param index number
function TimeZones.GetAsNumber(index)
    local str = stringTimezones[index];
    if str then
        local subStr = string.sub(str, 2, #str);
        local split = luautils.split(subStr, ":");
        local hour, min = tonumber(split[1]), tonumber(split[2]);
        local value = hour;
        if min > 0 then value = hour + (60 / min); end

        if luautils.stringStarts(str, "+") then
            return value;
        elseif luautils.stringStarts(str, "-") then
            return -value;
        else
            return 0;
        end
    end
end

---@param index number
function TimeZones.GetAsTable(index)
    local str = stringTimezones[index];
    if str then
        local subStr = string.sub(str, 2, #str);
        local split = luautils.split(subStr, ":");
        local hour, min = tonumber(split[1]), tonumber(split[2]);

        if luautils.stringStarts(str, "+") then
            return { hour = hour, minute = min };
        elseif luautils.stringStarts(str, "-") then
            return { hour = -hour, minute = -min };
        else
            return { hour = 0, minute = 0 };
        end
    end
end

---@param index number
---@param year number
---@param month number
---@param day number
---@param hour number
---@param minute number
function TimeZones.AdjustDateTime(index, year, month, day, hour, minute)
    local gameTime = getGameTime();
    local utcOffset = TimeZones.GetAsTable(index);

    if utcOffset.hour == 0 and utcOffset.minute == 0 then
        return year, month, day, hour, minute;
    end

    local function checkMinute()
        if minute < 0 then
            minute = 60 + minute;
            hour = hour - 1;
        elseif minute > 59 then
            minute = minute - 60;
            hour = hour + 1;
        end
    end

    local function checkHour()
        if hour < 0 then
            hour = 24 + hour;
            day = day - 1;
        elseif hour > 23 then
            hour = hour - 24;
            day = day + 1;
        end
    end

    local function checkMonth()
        if month < 1 then
            month = 12;
            year = year - 1;
        elseif month > 12 then
            month = 1;
            year = year + 1;
        end
    end

    local function checkDay()
        if day <= 1 then
            month = month - 1;
            checkMonth();
            day = gameTime:daysInMonth(year, month - 1);
        elseif day > gameTime:daysInMonth(year, month - 1) then
            day = 1;
            month = month + 1;
        end
    end

    minute = minute + utcOffset.minute;
    checkMinute();

    hour = hour + utcOffset.hour;
    checkHour();

    checkDay();
    checkMonth();

    return year, month, day, hour, minute;
end

return TimeZones;
