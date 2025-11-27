--- Contains a fix to the server auto sync at startup that was causing stack corruption
--- on windows (not sure on linux but I assume its the same) trying to set date and time to early before the world loads.
--- Also only check for mod setting changes every tenth tick instead of every tick. - Cyber-Punk 11/11/2025
--- Maybe make the settings change interval a SandboxVar for heavly loaded servers?

--- Load Server
local Server = require 'WorldTimeManager/Server';
local TimeZones = require 'WorldTimeManager/Classes/TimeZones';

---@class ServerModuleWorldTime
local ServerModuleWorldTime = {};

---@return boolean
function ServerModuleWorldTime.IsSystemTimeSyncEnabled()
    return SandboxVars.DayLength == 26 and SandboxVars.WorldTimeManager.syncWorldWithSystemTime;
end

---@param year number real year number
---@param month number real month number
---@param day number real day number
function ServerModuleWorldTime.SetDate(year, month, day)
    if SandboxVars.WorldTimeManager.disabled then return; end

    local gameTime = getGameTime();
    gameTime:setYear(year);
    gameTime:setMonth(month - 1);
    local daysInMonth = gameTime:daysInMonth(year, month - 1);
    if day > daysInMonth then day = daysInMonth; end
    gameTime:setDay(day - 1);

    local args = {
        year = year,
        month = month,
        day = day,
    };
    Server.SendCommand("SetDate", args);

    Server.TriggerEvent("OnDateSet", gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne());

    Server.Log("World date set to " .. Server.Utils.FormatDate(gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne()));
end

---@param hour number
---@param minute number
function ServerModuleWorldTime.SetTime(hour, minute)
    if SandboxVars.WorldTimeManager.disabled then return; end

    local gameTime = getGameTime();
    local floatMinute = minute / 60;
    local floatTime = hour + floatMinute;
    gameTime:setTimeOfDay(floatTime);

    local args = {
        hour = hour,
        minute = minute,
    };
    Server.SendCommand("SetTime", args);

    Server.TriggerEvent("OnTimeSet", gameTime:getHour(), gameTime:getMinutes());

    Server.Log("World time set to " .. Server.Utils.FormatTime(gameTime:getHour(), gameTime:getMinutes()));
end

function ServerModuleWorldTime.SyncSystemTime()
    if SandboxVars.WorldTimeManager.disabled then return; end

    Server.Log("Syncing game time to system time...");

    local systemTime = os.date("*t");
    local year, month, day, hour, minute = TimeZones.AdjustDateTime(SandboxVars.WorldTimeManager.utcOffset, systemTime.year, systemTime.month, systemTime.day, systemTime.hour, systemTime.min);

    ServerModuleWorldTime.SetDate(year, month, day);
    ServerModuleWorldTime.SetTime(hour, minute);
end

--- Add the module to the server Modules object
Server.Modules.WorldTime = ServerModuleWorldTime;

------------------------------------------------------------------------------------------------------------------------

local lastDayLength, lastUtcOffset;

--- Game Time is ready
local function onGameTimeLoaded()
    if SandboxVars.WorldTimeManager.disabled then return; end

    --- don't run for clients
    if not isServer() and not Server.Utils.IsSinglePlayer() then return; end

    lastDayLength = SandboxVars.DayLength;
    lastUtcOffset = SandboxVars.WorldTimeManager.utcOffset;
end
Events.OnGameTimeLoaded.Add(onGameTimeLoaded);

--- Check if sandbox vars has been changed
--- Sync the date and time on the first server tick since everything is properly loaded at this point.
local tCount = 0;

local function onTick(tick)
    if tCount == 0 then 
        if ServerModuleWorldTime.IsSystemTimeSyncEnabled() then
        ServerModuleWorldTime.SyncSystemTime(); end
        tCount = tick; 
    end

    if SandboxVars.WorldTimeManager.disabled then return; end

    --- don't run for clients
    if not isServer() and not Server.Utils.IsSinglePlayer() then
        Events.OnTick.Remove(onTick);
        return;
    end

    if tick - tCount >= 10 then
        tCount = tick;
        if lastDayLength ~= SandboxVars.DayLength or lastUtcOffset ~= SandboxVars.WorldTimeManager.utcOffset then
            if ServerModuleWorldTime.IsSystemTimeSyncEnabled() then
                lastDayLength = SandboxVars.DayLength;
                lastUtcOffset = SandboxVars.WorldTimeManager.utcOffset;
                ServerModuleWorldTime.SyncSystemTime();
            end
        end
    end
end
Events.OnTick.Add(onTick);
