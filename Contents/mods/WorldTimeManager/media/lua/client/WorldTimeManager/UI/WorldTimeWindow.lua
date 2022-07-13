--- WorldTimeManager.Modules.WorldTime.OpenWorldTimeWindow();

--- Load Client
local Client = require 'WorldTimeManager/Client';

---@class WorldTimeWindow : ISPanel
local WorldTimeWindow = ISPanel:derive("WorldTimeWindow");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

function WorldTimeWindow:initialise()
    ISPanel.initialise(self);

    local startY = 100;
    local comboHgt = FONT_HGT_SMALL + 3 * 2;
    local isSystemTimeSyncEnabled = Client.Modules.WorldTime.IsSystemTimeSyncEnabled();
    local btnWid = 100;
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2);

    -- months
    self.monthCombo = ISComboBox:new(10, startY, 100, comboHgt, self, self.onMonthComboChanged);
    self.monthCombo:initialise();
    self:addChild(self.monthCombo);

    -- days
    self.dayCombo = ISComboBox:new(self.monthCombo:getRight() + 10, startY, 100, comboHgt, self, self.onDayComboChanged);
    self.dayCombo:initialise();
    self:addChild(self.dayCombo);

    -- years
    self.yearCombo = ISComboBox:new(self.dayCombo:getRight() + 10, startY, 100, comboHgt, self, self.onYearComboChanged);
    self.yearCombo:initialise();
    self:addChild(self.yearCombo);

    -- set date button
    self.setDate = ISButton:new(10, self.monthCombo:getBottom() + 10, self.width - 20, btnHgt, getText("IGUI_SetDate"), self, self.onSetDateClicked);
    self.setDate:initialise();
    self.setDate:instantiate();
    self.setDate.borderColor = {r=1, g=1, b=1, a=0.1};
    self.setDate:setEnable(not isSystemTimeSyncEnabled);
    self:addChild(self.setDate);

    -- hours
    self.hourCombo = ISComboBox:new(self.width / 2, self.setDate:getBottom() + 10, self.width / 2 - 15, comboHgt, self, self.onHourComboChanged);
    self.hourCombo:initialise();
    self:addChild(self.hourCombo);

    -- minutes
    self.minuteCombo = ISComboBox:new(self.width / 2, self.hourCombo:getY(), self.width / 2 - 15, comboHgt, self, self.onMinutesComboChanged);
    self.minuteCombo:initialise();
    self:addChild(self.minuteCombo);

    -- set time button
    self.setTime = ISButton:new(10, self.minuteCombo:getBottom() + 10, self.width - 20, btnHgt, getText("IGUI_SetTime"), self, self.onSetTimeClicked);
    self.setTime:initialise();
    self.setTime:instantiate();
    self.setTime.borderColor = {r=1, g=1, b=1, a=0.1};
    self.setTime:setEnable(not isSystemTimeSyncEnabled);
    self:addChild(self.setTime);

    -- sync time button
    self.syncTime = ISButton:new(10, self.setTime:getBottom() + 10, self.width - 20, btnHgt, getText("IGUI_SyncTime"), self, self.onSyncTimeClicked);
    self.syncTime:initialise();
    self.syncTime:instantiate();
    self.syncTime.textColor = {r=1, g=0.6, b=0.3, a=1};
    self.syncTime.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.syncTime);

    -- cancel button
    self.cancel = ISButton:new(10, self.syncTime:getBottom() + 10, self.width - 20, btnHgt, getText("IGUI_Close"), self, self.onCancelClicked);
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    -- initialize
    self:initializeComboBoxes();

    -- update height
    self:setHeight(self.cancel:getBottom() + 10)
end

function WorldTimeWindow:initializeComboBoxes()

    local currentYear = self.gameTime:getYear();
    local currentMonth = self.gameTime:getMonth();
    local currentDay = self.gameTime:getDay();
    local daysInMonth = self.gameTime:daysInMonth(currentYear, currentMonth);

    -- set month
    self.monthCombo:clear();
    for i = 1, 12 do
        self.monthCombo:addOption(Client.Utils.GetMonthString(i));
        if currentMonth == i - 1 then
            self.monthCombo.selected = #self.monthCombo.options;
        end
    end
    self.monthCombo:setWidthToOptions();

    -- set day
    self.dayCombo:clear();
    for i = 1, daysInMonth do
        self.dayCombo:addOption(tostring(i));
        if i == currentDay + 1 then
            self.dayCombo.selected = #self.dayCombo.options;
        end
    end
    self.dayCombo:setWidthToOptions();
    self.dayCombo:setX(self.monthCombo:getRight() + 10);

    -- set year
    self.yearCombo:clear();
    for i = currentYear - 100, currentYear + 100 do
        self.yearCombo:addOption(tostring(i));
        if i == self.gameTime:getYear() then
            self.yearCombo.selected = #self.yearCombo.options;
        end
    end
    self.yearCombo:setWidthToOptions();
    self.yearCombo:setX(self.dayCombo:getRight() + 10);

    -- adjust window width
    self:setWidth(self.yearCombo:getRight() + 10);

    -- set hours
    self.hourCombo:clear();
    for i = 0, 23 do
        self.hourCombo:addOption(tostring(i));
        if self.gameTime:getHour() == i then
            self.hourCombo.selected = #self.hourCombo.options;
        end
    end
    self.hourCombo:setWidthToOptions();
    self.hourCombo:setX(self.width / 2 - self.hourCombo.width - 5);

    -- set minutes
    self.minuteCombo:clear();
    for i = 0, 59 do
        self.minuteCombo:addOption(tostring(i));
        if self.gameTime:getMinutes() == i then
            self.minuteCombo.selected = #self.minuteCombo.options;
        end
    end
    self.minuteCombo:setWidthToOptions();
    self.minuteCombo:setX(self.width / 2 + 5);

    self:updateButtonsWidth();
end

function WorldTimeWindow:updateButtonsWidth()
    self.setDate:setWidth(self.width - 20);
    self.setTime:setWidth(self.width - 20);
    self.syncTime:setWidth(self.width - 20);
    self.cancel:setWidth(self.width - 20);
end

function WorldTimeWindow:onDayComboChanged()
end

function WorldTimeWindow:onMonthComboChanged()
    local selectedDay = self.dayCombo.selected;
    local selectedMonth = self.monthCombo.selected;
    local selectedYear = tonumber(self.yearCombo.options[self.yearCombo.selected]);
    local daysInMonth = self.gameTime:daysInMonth(selectedYear, selectedMonth - 1);

    self.dayCombo:clear();

    for i = 1, daysInMonth do
        self.dayCombo:addOption(tostring(i));
    end
    self.dayCombo:setWidthToOptions();
    self.yearCombo:setX(self.dayCombo:getRight() + 10);

    -- if selected is higher then new days in month
    if selectedDay > #self.dayCombo.options then
        self.dayCombo.selected = #self.dayCombo.options;
    end
end

function WorldTimeWindow:onYearComboChanged()
    self:onMonthComboChanged();
end

function WorldTimeWindow:onHourComboChanged()
end

function WorldTimeWindow:onMinutesComboChanged()
end

function WorldTimeWindow:onSetDateClicked()
    local selectedYear = tonumber(self.yearCombo.options[self.yearCombo.selected]);
    local selectedMonth = self.monthCombo.selected;
    local selectedDay = self.dayCombo.selected;
    Client.Modules.WorldTime.SendSetDate(selectedYear, selectedMonth, selectedDay);
end

function WorldTimeWindow:onSetTimeClicked()
    local selectedHour = self.hourCombo.selected - 1;
    local selectedMinute = self.minuteCombo.selected - 1;
    Client.Modules.WorldTime.SendSetTime(selectedHour, selectedMinute);
end

function WorldTimeWindow:onSyncTimeClicked()
    local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_ConfirmSyncTime"), true, self, self.onSyncTimeConfirm);
    modal:initialise();
    modal:addToUIManager();
end

function WorldTimeWindow:onSyncTimeConfirm(button, player)
    if button.internal == "YES" then
        Client.Modules.WorldTime.SendSyncTime();
    end
end

function WorldTimeWindow:onCancelClicked()
    self:close();
end

function WorldTimeWindow:render()
    local x = self.width / 2;
    local z = 15;

    -- current date
    local date = Client.Utils.FormatDate(self.gameTime:getYear(), self.gameTime:getMonth() + 1, self.gameTime:getDayPlusOne());
    local dateFont = UIFont.NewMedium;
    local dateWidth, dateHeight = getTextManager():MeasureStringX(dateFont, date), getTextManager():MeasureStringY(dateFont, date);
    self:drawText(date, x - dateWidth / 2, z, 1,1,1,1, dateFont);

    -- current time
    local time = Client.Utils.FormatTime(self.gameTime:getHour(), self.gameTime:getMinutes());
    local timeFont = UIFont.Massive;
    local timeWidth, timeHeight = getTextManager():MeasureStringX(timeFont, time), getTextManager():MeasureStringY(timeFont, time);
    self:drawText(time, x - timeWidth / 2, z + dateHeight + 5, 1,1,1,1, timeFont);

    local isSystemTimeSyncEnabled = Client.Modules.WorldTime.IsSystemTimeSyncEnabled();
    self.setDate:setEnable(not isSystemTimeSyncEnabled);
    self.setTime:setEnable(not isSystemTimeSyncEnabled);

    if SandboxVars.WorldTimeManager.disabled then
        self:close();
    end
end

function WorldTimeWindow:close()
    WorldTimeWindow.lastPosition = {
        x = self:getX(),
        y = self:getY(),
    };
    WorldTimeWindow.instance = nil;
    ISPanel.close(self);
end

function WorldTimeWindow:new()
    local o = {};
    local x, y, width, height = 0, 0, 300, 150;

    if WorldTimeWindow.lastPosition then
        x = WorldTimeWindow.lastPosition.x;
        y = WorldTimeWindow.lastPosition.y;
    else
        x = getCore():getScreenWidth() / 2 - width / 2;
        y = getCore():getScreenHeight() / 2 - height / 2;
    end

    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.zOffsetSmallFont = math.max(25, FONT_HGT_SMALL);
    o.moveWithMouse = true;
    o.gameTime = getGameTime();

    if WorldTimeWindow.instance then
        WorldTimeWindow.instance:close();
    end
    WorldTimeWindow.instance = o;

    return o;
end

local function onDateTimeUpdated()
    if WorldTimeWindow.instance then
        WorldTimeWindow.instance:initializeComboBoxes();
    end
end

Client.AddEvent("OnDateSet", onDateTimeUpdated);
Client.AddEvent("OnTimeSet", onDateTimeUpdated);

---Set the window object to the client UI object.
Client.UI.WorldTimeWindow = WorldTimeWindow;
