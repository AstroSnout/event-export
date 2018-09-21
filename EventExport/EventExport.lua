-- local CallbackHandler = LibStub("CallbackHandler-1.0")
local EE = LibStub("AceAddon-3.0"):NewAddon("EventExport", "AceConsole-3.0", "AceSerializer-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LibBase64 = LibStub:GetLibrary("LibBase64-1.0")
local LibParse = LibStub:GetLibrary("LibParse")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressEncoder = LibCompress:GetAddonEncodeTable()

function setContains(set, key)
    return set[key] ~= nil
end

function EE:OnInitialize()
    -- The OnInitialize() method of your addon object is called by AceAddon when the addon is first loaded by the game client. 
    -- It's a good time to do things like restore saved settings (see the info on AceConfig for more notes about that).
    -- Code that you want to run when the addon is first loaded goes here.
    EE.Record_Result = {
        stringType='1'
    }
    EE.Recording = false
end

function EE:OnEnable()
    -- Called when the addon is enabled
end

function EE:OnDisable()
    -- Called when the addon is disabled
end

-- You should always release your frames once your UI doesn't need them anymore (i.e. in dynamic lists), or the memory consumption of your addon will increase alot.

-- All callbacks in AceGUI-3.0 will always have the widget that issued the callback as the first parameter, 
-- and the name of the callback as the second. Any data provided by the widget follows after that.

-- /eeon
function onlineMembersSnapshot (editbox)
    local result = {
        stringType = '1'
    }
    local guildID = C_Club.GetGuildClubId()
    local guildMembers = C_Club.GetClubMembers(guildID)

    for key, memberID in pairs(guildMembers) do
        local memberWow = C_Club.GetMemberInfo(guildID, memberID)
        if memberWow['presence'] == 1 then
            result[memberWow['name']] = true
        end
    end

    local jsonData = LibParse:JSONEncode(result) 
    local encodedData = LibBase64.Encode(jsonData)

    editbox:SetText(encodedData)
    editbox:SetFocus()
    editbox:HighlightText()
end

-- /eeon start
function recordOnlineMembers ()
    local result = {}
    local guildID = C_Club.GetGuildClubId()
    local guildMembers = C_Club.GetClubMembers(guildID)

    for key, memberID in pairs(guildMembers) do
        local memberWow = C_Club.GetMemberInfo(guildID, memberID)
        if memberWow['presence'] == 1 then
            EE.Record_Result[memberWow['name']] = true
        end
    end

    function EE:CLUB_MEMBER_PRESENCE_UPDATED(eventName, clubID, memberID, presence)
        clubInfo = C_Club.GetClubInfo(clubID)
        guildId = C_Club.GetGuildClubId()
        memberInfo = C_Club.GetMemberInfo(clubID, memberID)
    
        if presence == 1 and clubID == guildId then
            if not setContains(EE.Record_Result, memberInfo['name']) then
                charname = memberInfo['name']
                EE.Record_Result[charname] = true
            end
        end
    end
    
    EE:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
    EE.Recording = true
end

-- /eeon stop
function stopRecord (editbox)
    EE:UnregisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
    EE.Recording = false
    local jsonData = LibParse:JSONEncode(EE.Record_Result) 
    local encodedData = LibBase64.Encode(jsonData)

    -- Reset the table
    EE.Record_Result = {
        stringType='1'
    }

    editbox:SetText(encodedData)
    editbox:SetFocus()
    editbox:HighlightText()
end

-- /eeall
function allMembersInfo(editbox)
    local complete_roster = {
        stringType='2'
    }

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

    local jsonData = LibParse:JSONEncode(complete_roster) 
    local encodedData = LibBase64.Encode(jsonData)

    editbox:SetText(encodedData);
    editbox:SetFocus()
    editbox:HighlightText()
end

-- /eeraid helper
function getUnitID(index)
    local unitID
	
	local unitType = "raid"
	if (not IsInRaid()) then --o jogador esta em grupo
		unitType = "party"
	end
	
	if (unitType == "party") then
		if (index == GetNumGroupMembers()) then
			unitID = "player"
		else
			unitID = unitType .. index
		end
	else
		unitID = unitType .. index
	end
	
	return unitID
end

-- /eeraid
function getRaidMembers(editbox)
    local allMembers = {
        stringType='3'
    }
    local groupSize = GetNumGroupMembers()
    for i = 1, groupSize, 1 do
        local unitID = getUnitID(i)
        
        local name = UnitName(unitID)
        local unitSerial = UnitGUID(unitID)
        
        allMembers[name] = true
    end

    local jsonData = LibParse:JSONEncode(allMembers) 
    local encodedData = LibBase64.Encode(jsonData)

    if IsInRaid() then editbox:SetText(encodedData) else editbox:SetText("Not in a raid") end
    editbox:SetFocus()
    editbox:HighlightText()
end

function createCalendarFrames(CalendarEventFrame)
    local frame = CreateFrame('Frame', nil, CalendarEventFrame)
    -- Main frame
    frame:SetPoint('TOPLEFT', CalendarEventFrame, 'BOTTOMLEFT', 0, 23)
    frame:SetWidth(CalendarEventFrame:GetWidth())
    frame:SetHeight(46);
    -- Export button to show text area
    button = CreateFrame('Button', nil, frame, "OptionsButtonTemplate");
    button:SetPoint("TOP", 0, 0);
    button:SetWidth(80);
    button:SetHeight(20);
    button:SetText("Export");
    button:Show();
    -- Text area wrapper
    editboxFrame = CreateFrame('Frame', nil, frame)
    editboxFrame:SetWidth(CalendarEventFrame:GetWidth());
    editboxFrame:SetHeight(26);
    editboxFrame:SetPoint('TOP', frame, 0, -20);
    editboxFrame:SetBackdrop {
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
        tileSize = 13,
        edgeSize = 13,
    }
    editboxFrame:Hide();
    -- Text area where copy link is
    editbox = CreateFrame('EditBox', nil, editboxFrame);
    editbox:SetWidth(CalendarEventFrame:GetWidth());
    editbox:SetFont('Fonts\\FRIZQT__.ttf', 12, 'THINOUTLINE');
    editbox:SetHeight(26);
    editbox:SetPoint('TOP', editboxFrame, 0, 0);
    editbox:SetScript("OnEscapePressed", OnEscape)
    editbox:SetScript("OnEnterPressed", OnEnter)
    editbox:Hide();

    return frame, button, editboxFrame, editbox
end

function EE:PLAYER_ENTERING_WORLD(eventName)
    ------------------ Calendar View Event Frame ------------------
    viewFrame, viewButton, viewEditboxFrame, viewEditbox = createCalendarFrames(CalendarViewEventFrame)
    viewButton:SetScript('OnClick', function() exportEventRoster(viewEditboxFrame, viewEditbox) end)
    ------------------ Calendar Create Event Frame ------------------
    createFrame, createButton, createEditboxFrame, createEditbox = createCalendarFrames(CalendarCreateEventFrame)
    createButton:SetScript('OnClick', function() exportEventRoster(createEditboxFrame, createEditbox) end)
end

EE:RegisterEvent("PLAYER_ENTERING_WORLD")

function EE:CALENDAR_OPEN_EVENT(eventName, calendarType)
    viewEditbox:SetText("");
    viewEditboxFrame:Hide();
    viewEditbox:Hide();

    createEditbox:SetText("");
    createEditboxFrame:Hide();
    createEditbox:Hide();
end

EE:RegisterEvent("CALENDAR_OPEN_EVENT")

-- OnClick handler for export button
function exportEventRoster(editboxFrame, editbox)
    local all_invites = {
        stringType = '0'
    }
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
                cls = singleInvite['className'],
                stat = singleInvite['inviteStatus']
            }
            -- Add to my set table thing
            all_invites[i] = mySingleInvite
        end
    end

    -- toJSON and encode to Base64 :3
    local jsonData = LibParse:JSONEncode(all_invites)
    local encodedData = LibBase64.Encode(jsonData)

    -- Show on GUI (ViewFrame)
    editbox:SetText(encodedData);
    editboxFrame:Show();
    editbox:Show();
    editbox:HighlightText()
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

EE:RegisterChatCommand("ee", "MyAddonSettings")

function EE:MyAddonSettings (input)
    EE:Print("Opening Settings!")

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Event Export Hub")
    frame:SetStatusText("Ima jos svasta nesto da se doda, bice")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetWidth(420)
    frame:SetLayout("Flow")
    frame:EnableResize(false)

    -- Online Members Snapshot
    local editbox1 = AceGUI:Create("EditBox")
    editbox1:SetLabel("Snapshot of all online guild members")
    editbox1:SetRelativeWidth(0.7)
    frame:AddChild(editbox1)

    local button1 = AceGUI:Create("Button")
    button1:SetText("Generate!")
    button1:SetRelativeWidth(0.3)
    button1:SetCallback("OnClick", function(widget, event, text) onlineMembersSnapshot(editbox1) end)
    frame:AddChild(button1)

    -- Online Members Record
    local editbox2 = AceGUI:Create("EditBox")
    editbox2:SetLabel("Record all members that came online since the start of the recording")
    editbox2:SetRelativeWidth(1)
    frame:AddChild(editbox2)

    local buttonStart = AceGUI:Create("Button")
    buttonStart:SetText("Start")
    buttonStart:SetWidth(100)
    if EE.Recording then buttonStart:SetDisabled(true) else buttonStart:SetDisabled(false) end
    frame:AddChild(buttonStart)

    local buttonStop = AceGUI:Create("Button")
    buttonStop:SetText("Stop")
    buttonStop:SetWidth(100)
    if EE.Recording then buttonStop:SetDisabled(false) else buttonStop:SetDisabled(true) end
    frame:AddChild(buttonStop)

    local isRecording = AceGUI:Create("Label")
    if EE.Recording then isRecording:SetText("Recording . . .") else isRecording:SetText("") end
    isRecording:SetWidth(100)
    isRecording:SetPoint("LEFT", 0, 0)
    frame:AddChild(isRecording)

    buttonStart:SetCallback("OnClick", function(widget, event, text)
        buttonStart:SetDisabled(true)
        buttonStop:SetDisabled(false) 
        editbox2:SetText("")
        isRecording:SetText("Recording . . .")
        recordOnlineMembers() 
    end)

    buttonStop:SetCallback("OnClick", function(widget, event, text) 
        buttonStart:SetDisabled(false)
        buttonStop:SetDisabled(true)
        isRecording:SetText("")
        stopRecord(editbox2) 
    end)

    -- All members info
    local editbox3 = AceGUI:Create("EditBox")
    editbox3:SetLabel("Retrieve all guild members' notes")
    editbox3:SetRelativeWidth(0.7)
    frame:AddChild(editbox3)

    local button3 = AceGUI:Create("Button")
    button3:SetText("Generate!")
    button3:SetRelativeWidth(0.3)
    button3:SetCallback("OnClick", function(widget, event, text) allMembersInfo(editbox3) end)
    frame:AddChild(button3)

    -- All raid members
    local editbox4 = AceGUI:Create("EditBox")
    editbox4:SetLabel("Export all members currently in raid")
    editbox4:SetRelativeWidth(0.7)
    frame:AddChild(editbox4)

    local button4 = AceGUI:Create("Button")
    button4:SetText("Generate!")
    button4:SetRelativeWidth(0.3)
    button4:SetCallback("OnClick", function(widget, event, text) getRaidMembers(editbox4) end)
    frame:AddChild(button4)

    -- Process the slash command ('input' contains whatever follows the slash command)
end

local _G = _G

_G.StaticPopupDialogs["EVENTEXPORT_MID_DIALOG"] = {
    text = "%s",
    button2 = CLOSE,
    hasEditBox = true,
    hasWideEditBox = true,
    editBoxWidth = 350,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        self:SetWidth(420)
        local editBox = _G[self:GetName() .. "WideEditBox"] or _G[self:GetName() .. "EditBox"]
        editBox:SetText(self.text.text_arg2)
        editBox:SetFocus()
        editBox:HighlightText(false)
        local button = _G[self:GetName() .. "Button2"]
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    OnHide = nil,
    OnAccept = nil,
    OnCancel = nil
}

EE:RegisterChatCommand("eeon", "OnlineMembers")

function EE:OnlineMembers (input)
    if input == 'start' then
        EE:Print("Online members recording has started!")
        recordOnlineMembers()
        return
    end

    if input == 'stop' then
        if EE.Recording then            
            EE:UnregisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
            EE.Recording = false
            local jsonData = LibParse:JSONEncode(EE.Record_Result) 
            local encodedData = LibBase64.Encode(jsonData)

            -- Reset the table
            EE.Record_Result = {
                stringType='1'
            }
            StaticPopup_Show("EVENTEXPORT_MID_DIALOG", "Paste this text to the EventExport bot", encodedData) 
        else 
            EE:Print('No recording was initiated!') 
        end
    end

    if input == '' then
        local result = {
            stringType = '1'
        }
        local guildID = C_Club.GetGuildClubId()
        local guildMembers = C_Club.GetClubMembers(guildID)
    
        for key, memberID in pairs(guildMembers) do
            local memberWow = C_Club.GetMemberInfo(guildID, memberID)
            if memberWow['presence'] == 1 then
                result[memberWow['name']] = true
            end
        end
    
        local jsonData = LibParse:JSONEncode(result) 
        local encodedData = LibBase64.Encode(jsonData)

        StaticPopup_Show("EVENTEXPORT_MID_DIALOG", "Paste this text to the EventExport bot", encodedData)
    end
end

EE:RegisterChatCommand("eeraid", "RaidMembers")
function EE:RaidMembers (input)
    if IsInRaid() then
        local allMembers = {
            stringType='3'
        }
        local groupSize = GetNumGroupMembers()
        for i = 1, groupSize, 1 do
            local unitID = getUnitID(i)
            
            local name = UnitName(unitID)
            local unitSerial = UnitGUID(unitID)
            
            allMembers[name] = true
        end

        local jsonData = LibParse:JSONEncode(allMembers) 
        local encodedData = LibBase64.Encode(jsonData)

        StaticPopup_Show("EVENTEXPORT_MID_DIALOG", "Paste this text to the EventExport bot", encodedData)
    else
        EE:Print('You are not in a raid')
    end
end