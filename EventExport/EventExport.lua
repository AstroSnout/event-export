local Ace3 = LibStub("AceAddon-3.0"):NewAddon("EventExport", "AceSerializer-3.0")
local LibBase64 = LibStub:GetLibrary("LibBase64-1.0")
local LibParse = LibStub:GetLibrary("LibParse")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressEncoder = LibCompress:GetAddonEncodeTable()

-- Frame creation
local Frame = CreateFrame('Frame', 'Frame', UIParent);
local Frame_2 = CreateFrame('Frame', 'Frame', UIParent);
local MidFrame = CreateFrame('Frame', 'Frame', UIParent)
local RECORDING = false
local RESULT = {}

-- Register events
Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
Frame:RegisterEvent("CALENDAR_OPEN_EVENT");
Frame_2:RegisterEvent("PLAYER_ENTERING_WORLD");
Frame_2:RegisterEvent("CALENDAR_OPEN_EVENT");
MidFrame:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED");

-- Helper functions
function addToSet(set, key)
    set[key] = true
end

function removeFromSet(set, key)
    set[key] = nil
end

function setContains(set, key)
    return set[key] ~= nil
end

-- Event handler for when character ends a loading screen
function Frame:PLAYER_ENTERING_WORLD()
    -- Load blizz addon
    if (not IsAddOnLoaded("Blizzard_Calendar")) then UIParentLoadAddOn("Blizzard_Calendar") end
    if (not IsAddOnLoaded("Blizzard_Communities")) then UIParentLoadAddOn("Blizzard_Communities") end

    ------------------ Calendar View Event Frame ------------------
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
    ExportButton = CreateFrame('Button', 'ExportButton', Frame, "OptionsButtonTemplate");
    ExportButton:SetPoint("TOPLEFT", Frame:GetWidth()/2 - 40, 26);
    ExportButton:SetWidth(80);
    ExportButton:SetHeight(20);
    ExportButton:SetText("Export");
    ExportButton:SetScript('OnClick', ExportEventRoster)
    ExportButton:Show();  
    -- Text area wrapper
    EditBoxFrame = CreateFrame('Frame', 'EditBoxFrame', Frame)
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
    EditBox = CreateFrame('EditBox', 'EditBox', EditBoxFrame);
    EditBox:SetWidth(CalendarViewEventFrame:GetWidth()*1.24);
    EditBox:SetFont('Fonts\\FRIZQT__.ttf', 12, 'THINOUTLINE');
    EditBox:SetHeight(26);
    EditBox:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 10, 0);
    EditBox:SetScript("OnEscapePressed", OnEscape)
    EditBox:SetScript("OnEnterPressed", OnEnter)
    EditBox:Hide();
    ------------------ Calendar Create Event Frame ------------------
    -- Main frame
    Frame_2:SetParent(CalendarCreateEventFrame)
    Frame_2:SetFrameStrata('DIALOG');
    Frame_2:SetToplevel(true);
    Frame_2:EnableMouse(true);
    Frame_2:SetClampedToScreen(true);
    Frame_2:SetPoint('TOPLEFT', CalendarCreateEventFrame, 'BOTTOMLEFT', 0, 0);
    Frame_2:SetWidth(CalendarCreateEventFrame:GetWidth());
    Frame_2:SetHeight(46);
    -- Export button to show text area
    ExportButton_2 = CreateFrame('Button', 'ExportButton_2', Frame_2, "OptionsButtonTemplate");
    ExportButton_2:SetPoint("TOPLEFT", Frame:GetWidth()/2 - 15, 33);
    ExportButton_2:SetWidth(80);
    ExportButton_2:SetHeight(20);
    ExportButton_2:SetText("Export");
    ExportButton_2:SetScript('OnClick', ExportEventRoster)
    ExportButton_2:Show();   
    -- Text area wrapper
    EditBoxFrame_2 = CreateFrame('Frame', 'EditBoxFrame_2', Frame_2)
    EditBoxFrame_2:SetWidth(CalendarCreateEventFrame:GetWidth()-10);
    EditBoxFrame_2:SetHeight(26);
    EditBoxFrame_2:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 5, -75);
    EditBoxFrame_2:SetBackdrop {
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
        tileSize = 13,
        edgeSize = 13,
    }
    EditBoxFrame_2:Hide();
    -- Text area where copy link is
    EditBox_2 = CreateFrame('EditBox', 'EditBox_2', EditBoxFrame_2);
    EditBox_2:SetWidth(CalendarCreateEventFrame:GetWidth()*1.24);
    EditBox_2:SetFont('Fonts\\FRIZQT__.ttf', 12, 'THINOUTLINE');
    EditBox_2:SetHeight(26);
    EditBox_2:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 10, -75);
    EditBox_2:SetScript("OnEscapePressed", OnEscape)
    EditBox_2:SetScript("OnEnterPressed", OnEnter)
    EditBox_2:Hide();
    ------------------ Mid PopUp Frame ------------------
    -- Main frame
    MidFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', UIParent:GetWidth()/2 - 260, UIParent:GetHeight()/2 - 23);
    MidFrame:SetWidth(520);
    MidFrame:SetHeight(46);
    -- Text area wrapper
    EditBoxMidFrame = CreateFrame('Frame', 'EditBoxFrame_2', MidFrame)
    EditBoxMidFrame:SetWidth(520);
    EditBoxMidFrame:SetHeight(26);
    EditBoxMidFrame:SetPoint('TOPLEFT', MidFrame, 'TOPLEFT', 5, -75);
    EditBoxMidFrame:SetBackdrop {
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
        tileSize = 13,
        edgeSize = 13,
    }
    EditBoxMidFrame:Hide();
    -- Text area where copy link is
    EditBoxMid = CreateFrame('EditBox', 'EditBoxMid', EditBoxMidFrame);
    EditBoxMid:SetWidth(500);
    EditBoxMid:SetFont('Fonts\\FRIZQT__.ttf', 12, 'THINOUTLINE');
    EditBoxMid:SetHeight(26);
    EditBoxMid:SetPoint('TOPLEFT', MidFrame, 'TOPLEFT', 10, -75);
    EditBoxMid:SetScript("OnEscapePressed", OnEscape)
    EditBoxMid:SetScript("OnEnterPressed", OnEnter)
    EditBoxMid:HighlightText()
    EditBoxMid:Hide();

    print("|cFF00cc00EventExports|r is now ready!")
end

-- OnClick handler for export button
function ExportEventRoster()
    local all_invites = {}
    -- Get event-related info
    local event = C_Calendar.GetEventIndex();
    local monthOffset = event['monthOffset'];
    local monthDay = event['monthDay'];
    local eventIndex = event['eventIndex'];
    -- Get current date
    local date = C_Calendar.GetDate();
    local monthCurrent = date['month'];
    local yearCurrent = date['year'];
    -- Get number of invites for said event
    local numInvites = C_Calendar.GetNumInvites(eventIndex);
    -- Get all info on invited people
    local event_info = C_Calendar.GetEventInfo(monthOffset, monthDay, eventIndex);
    local eventMonth = monthCurrent;
    if monthOffset ~= nil then eventMonth = tostring( ( tonumber(monthCurrent) + tonumber(monthOffset) ) % 12 ) end
    local eventDate = monthDay..'-'..eventMonth..'-'..yearCurrent;

    all_invites["eventInfo"] = {
        title = event_info['title'],
        eventDate = eventDate
    }
    for i=1, numInvites do
        singleInvite = C_Calendar.EventGetInvite(i);
        if singleInvite['inviteStatus'] ~= 1 then  -- If status is not "Invited"
            -- Extract the info I need
            mySingleInvite = {
                name = singleInvite['name'],
                className = singleInvite['className'],
                inviteStatus = singleInvite['inviteStatus']
            }
            -- Add to my set table thing
            all_invites[i] = mySingleInvite
        end
    end

    stringType = '0'
    all_invites['stringType'] = stringType
    -- toJSON and encode to Base64 :3
    local jsonData = LibParse:JSONEncode(all_invites)
    local encodedData = LibBase64.Encode(jsonData)
    -- Show on GUI (ViewFrame)
    EditBox:SetText(encodedData);
    EditBoxFrame:Show();
    EditBox:Show();
    EditBox:HighlightText()
    -- Show on GUI (CreateFrame)
    EditBox_2:SetText(encodedData);
    EditBoxFrame_2:Show();
    EditBox_2:Show();
    EditBox_2:HighlightText()
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

-- Slash command to generate a string to get all online members
SLASH_EE_ONLINE1, SLASH_EE_ONLINE2 = '/eeonline', '/eeon';
function SlashCmdList.EE_ONLINE(msg, editbox)
    -- Logic that needs to happen
    local guildID = C_Club.GetGuildClubId()
    local guildMembers = C_Club.GetClubMembers(guildID)

    for key, memberID in pairs(guildMembers) do
        local memberWow = C_Club.GetMemberInfo(guildID, memberID)
        if memberWow['presence'] == 1 then
            addToSet(RESULT, memberWow['name'])
        end
    end

    if msg == 'start' then  -- Record
        print('Started recording')
        RECORDING = true
        return
    elseif msg == 'stop' then -- Stop recording
        print('Stopped recording')
        RECORDING = false
    else  -- Instant snapshot
        if RECORDING then 
            print('Currently recording, please use "/eeonline stop" to stop recording')
            return
        end
    end

    stringType = '1'
    RESULT['stringType'] = stringType

    local jsonData = LibParse:JSONEncode(RESULT) 
    local encodedData = LibBase64.Encode(jsonData)

    EditBoxMid:SetText(encodedData);
    EditBoxMidFrame:Show();
    EditBoxMid:Show();
    EditBoxMid:HighlightText()
end

SLASH_EE_ALL1, SLASH_EE_ALL2 = '/eeall', '/eeallmembers';
function SlashCmdList.EE_ALL(msg, editbox)
    local complete_roster = {}

    -- Logic that needs to happen
    local guildID = C_Club.GetGuildClubId()
    local guildMembers = C_Club.GetClubMembers(guildID)

    ---- Gets all online members
    local i = 0
    for k, v in pairs(guildMembers) do
        local memberWow = C_Club.GetMemberInfo(guildID, v)
        local myMember = {
            name = memberWow.name,
            memberNote = memberWow.memberNote,
            officerNote = memberWow.officerNote
        }
        complete_roster[i] = myMember
        i = i + 1   
    end

    stringType = '2'
    complete_roster['stringType'] = stringType
    local jsonData = LibParse:JSONEncode(complete_roster) 
    local encodedData = LibBase64.Encode(jsonData)

    EditBoxMid:SetText(encodedData);
    EditBoxMidFrame:Show();
    EditBoxMid:Show();
    EditBoxMid:HighlightText()
end

------------ Specific Event Handlers ------------
-- On opening a calendar event pane
function Frame:CALENDAR_OPEN_EVENT()
    EditBox:SetText("");
    EditBoxFrame:Hide();
    EditBox:Hide();

    EditBox_2:SetText("");
    EditBoxFrame_2:Hide();
    EditBox_2:Hide();
end
-- On member changing status (onlline-offline)
function MidFrame:CLUB_MEMBER_PRESENCE_UPDATED(clubID, memberID, presence)
    if RECORDING == true then

        clubInfo = C_Club.GetClubInfo(clubID)
        guildId = C_Club.GetGuildClubId()
        memberInfo = C_Club.GetMemberInfo(clubID, memberID)

        if presence == 1 and clubID == guildId then
            if not setContains(RESULT, memberInfo['name']) then
                addToSet(RESULT, memberInfo['name'])
            end
        end
    end
end



-- Frame event handler
Frame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

-- MidFrame event handler
MidFrame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

