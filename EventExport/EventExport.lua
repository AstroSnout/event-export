-- Event Export
local Frame = CreateFrame('Frame', 'Frame', UIParent);

-- Register events
Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
Frame:RegisterEvent("CALENDAR_OPEN_EVENT");

function Frame:PLAYER_ENTERING_WORLD()
    -- Load blizz addon
    if (not IsAddOnLoaded("Blizzard_Calendar")) then UIParentLoadAddOn("Blizzard_Calendar") end

    -- Main frame
    Frame:SetParent(CalendarViewEventFrame)
    Frame:SetFrameStrata('DIALOG');
    Frame:SetToplevel(true);
    Frame:EnableMouse(true);
    Frame:SetClampedToScreen(true);
    Frame:SetPoint('TOPLEFT', CalendarViewEventFrame, 'BOTTOMLEFT', 0, 0);
    Frame:SetWidth(CalendarViewEventFrame:GetWidth());
    Frame:SetHeight(46);

    -- Export button to show text area
    local ExportButton = CreateFrame('Button', 'ExportButton', Frame, "OptionsButtonTemplate");
    ExportButton:SetPoint("TOPLEFT", Frame:GetWidth()/2 - 40, 26);
    ExportButton:SetWidth(80);
    ExportButton:SetHeight(20);
    ExportButton:SetText("Export");
    ExportButton:SetScript('OnClick', ExportButton_OnClick)
    ExportButton:Show();
    
    -- Text area wrapper
    local EditBoxFrame = CreateFrame('Frame', 'EditBoxFrame', Frame)
    EditBoxFrame:SetWidth(CalendarViewEventFrame:GetWidth()-10);
    EditBoxFrame:SetHeight(26);
    EditBoxFrame:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 5, 0);
    EditBoxFrame:SetBackdrop {
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
        tileSize = 13,
        edgeSize = 13,
    }
    EditBoxFrame:Hide();

    -- Text area where copy link is
    local EditBox = CreateFrame('EditBox', 'EditBox', EditBoxFrame);
    EditBox:SetWidth(CalendarViewEventFrame:GetWidth()*1.24);
    EditBox:SetFont('Fonts\\FRIZQT__.ttf', 12, 'THINOUTLINE');
    EditBox:SetHeight(26);
    EditBox:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 10, 0);
    EditBox:SetScript("OnEscapePressed", OnEscape)
    EditBox:SetScript("OnEnterPressed", OnEnter)
    EditBox:Hide();

    print("EventExports is now ready!")
end

-- OnClick handler for export button
function ExportButton_OnClick()
    event = C_Calendar.GetEventIndex(); -- monthOffset, eventIndex, monthDay

    monthOffset = event['monthOffset'];
    monthDay = event['monthDay'];
    eventIndex = event['eventIndex'];

    date = C_Calendar.GetDate();

    monthCurrent = date['month'];
    yearCurrent = date['year'];

    -- Get number of invites for said event
    numInvites = C_Calendar.GetNumInvites(eventIndex);
    -- Get all info on invited people
    event_info = C_Calendar.GetEventInfo(monthOffset, monthDay, eventIndex);
    title = event_info['title'];
    eventMonth = monthCurrent;
    if monthOffset ~= nil then eventMonth = tostring( ( tonumber(monthCurrent) + tonumber(monthOffset) ) % 12 ) end
    eventDate = monthDay..'-'..eventMonth..'-'..yearCurrent;

    printer = "title:"..title..';'..'eventDate:'..eventDate..';--end--;';
    for i=1, numInvites do
        invite = C_Calendar.EventGetInvite(i);
        for k,v in pairs(invite) do
            if k == "name" or k == "className" or k == "inviteStatus" then printer = printer .. k .. ":" .. tostring(v) .. ";" end
        end
        printer = printer .. '--end--;'
    end

    -- Show on GUI
    EditBox:SetText(printer);
    EditBoxFrame:Show();
    EditBox:Show();
    EditBox:HighlightText()
end

-- Event handler when opening an event in the calendar
function Frame:CALENDAR_OPEN_EVENT()
    EditBox:SetText("");
    EditBoxFrame:Hide();
    EditBox:Hide();
end

-- EditBox hide on escape key press
function OnEscape(self)
    self:Hide()
    self:GetParent():Hide()
end

-- EditBox hide on enter key press
function OnEnter(self)
    self:Hide()
    self:GetParent():Hide()
end

function Serialize(obj)
    if (type(obj) == "string") then
        return strformat("%q", obj);
    end
end

-- Frame event handler
Frame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)
