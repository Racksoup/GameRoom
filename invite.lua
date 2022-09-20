function GR:CreateInvite()
    GR.Friends = {}
    GR.Zone = {}
    GR.Party = {}
    GR.OnlyParty = {}
    GR.OnlyGuild = {}
    GR.Target = nil
    GR.Opponent = nil
    GR.CanSendInvite = true
    GR.IsChallenged = false
    GR.InGame = false
    GR.GameType = nil

    GR_GUI.Main.Invite = CreateFrame("Frame", Invite, GR_GUI.Main)
    local Invite = GR_GUI.Main.Invite
    Invite:SetPoint("TOP", 0, -66)
    Invite:SetSize(650,420)
    local H2 = Invite:CreateFontString(Invite, "HIGH", "GameTooltipText")
    H2:SetPoint("TOP", 0, 0)
    H2:SetTextColor(.8, .8, .8, 1)
    H2:SetTextScale(1.7)
    H2:SetText("Invite!")
    
    Invite.Settings = CreateFrame("Button", Settings, Invite, "UIPanelButtonTemplate")
    Invite.Settings:SetPoint("TOPRIGHT", -120, -92)
    Invite.Settings:SetSize(100, 30)
    Invite.Settings:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.tab = 7
            GR:TabSelect()
        end
    end)
    
    local SettingsFS = Invite.Settings:CreateFontString(Invite.Settings, "HIGH", "GameTooltipText")
    SettingsFS:SetPoint("CENTER")
    SettingsFS:SetTextColor(.8, .8, .8, 1)
    SettingsFS:SetTextScale(1.1)
    SettingsFS:SetText("Settings")

    -- listen for party changes
    GR_GUI.Main.Invite:RegisterEvent("GROUP_ROSTER_UPDATE")
    GR_GUI.Main.Invite:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
    GR_GUI.Main.Invite:RegisterEvent("FRIENDLIST_UPDATE")
    GR_GUI.Main.Invite:RegisterEvent("WHO_LIST_UPDATE")
    GR_GUI.Main.Invite:RegisterEvent("GUILD_ROSTER_UPDATE")
    GR_GUI.Main.Invite:SetScript("OnEvent", function(self, event, ...)
        if (event == "GROUP_ROSTER_UPDATE") then
            GR.Party = {}
            GR:RefreshPartyList()
            -- resends Register Party messages
            local NumParty = GetNumGroupMembers()
            for i = 1, NumParty, 1 do
                local PlayerIndex = "party" .. tostring(i)
                local PartyMember = UnitName(PlayerIndex)
                local PlayerName = UnitName("player")
                C_Timer.After(1, function() 
                    if (type(PartyMember) == "string" and UnitIsConnected(PlayerIndex)) then
                        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, "WHISPER", PartyMember)
                    end
                end)
            end
        end

        if (event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_LIST_SIZE_CHANGED") then
            C_Timer.After(.5, function()
                GR:RemoveFromFriendsList()
                GR:RefreshFriendsList()
            end)
        end

        if (event == "WHO_LIST_UPDATE" and GR_GUI.Main:IsVisible()) then
            C_Timer.After(.6, function() 
                local NumWhos, TotalNumWhos = C_FriendList.GetNumWhoResults()
                for i = 1, NumWhos, 1 do
                    local WhoPlayer = C_FriendList.GetWhoInfo(i)
                    for j,v in pairs(WhoPlayer) do
                        if (string.match(j, "fullName") and not string.match(v, UnitName("player"))) then
                            local PlayerName  = UnitName("player")
                            GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. PlayerName, "WHISPER", v)
                        end
                    end
                end
            end) 
        end

        if (event == "GUILD_ROSTER_UPDATE") then
            GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. UnitName("player"), "GUILD")
        end
    end)

    GR:CreateManualInvite()
    GR:CreateInviteFriends()
    GR:CreateInviteParty()
    GR:CreateInviteZone()
    GR:CreateGameButtons()
end

function GR:CreateManualInvite()
    GR_GUI.Main.Invite.ManualInput = CreateFrame("EditBox", ManualInput, GR_GUI.Main.Invite, "InputBoxInstructionsTemplate")
    local ManualInput = GR_GUI.Main.Invite.ManualInput
    ManualInput:SetPoint("TOPLEFT", 50, -80)
    ManualInput:SetWidth(200)
    ManualInput:SetFontObject("ChatFontNormal")
    ManualInput:SetMultiLine(true)
    ManualInput:SetAutoFocus(false)

    local ManualInputString = ManualInput:CreateFontString(ManualInput, "HIGH", "GameTooltipText")
    ManualInputString:SetPoint("TOP", 0, 23)
    ManualInputString:SetTextScale(1.1)
    ManualInputString:SetTextColor(.8,.8,.8, 1)
    ManualInputString:SetText("Challenge Target or Enter Name")

    ManualInput.Btn = CreateFrame("Button", ManualBtn, ManualInput, "UIPanelButtonTemplate")
    local ManualBtn = ManualInput.Btn
    ManualBtn:SetPoint("BOTTOM", 0, -37)
    ManualBtn:SetSize(120, 30)
    local ManualBtnString = ManualBtn:CreateFontString(ManualBtn, "HIGH", "GameTooltipText")
    ManualBtnString:SetPoint("CENTER")
    ManualBtnString:SetTextScale(1.1)
    ManualBtnString:SetTextColor(.8,.8,.8,1)
    ManualBtnString:SetText("Challenge")
    ManualBtn:SetScript("OnClick", function(self, button, down)
        local TarName = ManualInput:GetText()
        if (string.match(TarName, "")) then
            TarName = UnitName("target")
        end
        GR.Target = TarName
        GR:ToggleGameBtns()
    end)
end

function GR:ToggleGameBtns()
    if (GR.Target == nil) then
        GR_GUI.Main.Invite.GameBtns:Hide()
    else
        GR_GUI.Main.Invite.GameBtns.H4:SetText(GR.Target)
        GR_GUI.Main.Invite.GameBtns:Show()
        C_Timer.After(45, function() 
            GR.Target = nil
            GR:ToggleGameBtns()
        end)
    end
end

function GR:HideGameBtnsIfSentInvite()
    if (GR.CanSendInvite) then
        GR_GUI.Main.Invite.GameBtns:Show()
    else
        GR_GUI.Main.Invite.GameBtns:Hide()
    end
end

function GR:CreateGameButtons()
    local Invite = GR_GUI.Main.Invite
    Invite.GameBtns = CreateFrame("Frame", GameBtns, Invite)
    local Btns = Invite.GameBtns
    Btns:SetPoint("CENTER", 0, -55)
    Btns:SetSize(500, 170)
    Btns.H3 = Btns:CreateFontString(Btns, "HIGH", "GameTooltipText")
    Btns.H3:SetPoint("TOP", 0, 48)
    Btns.H3:SetTextScale(1.5)
    Btns.H3:SetTextColor(.8,.8,.8, 1)
    Btns.H3:SetText("Challenge Opponent")
    Btns.H4 = Btns:CreateFontString(Btns, "HIGH", "GameTooltipText")
    Btns.H4:SetPoint("TOP", 0, 23)
    Btns.H4:SetTextScale(1.1)
    Btns.H4:SetTextColor(.8,.8,.8, 1)
    
    Btns.Tic = CreateFrame("Button", Tic, Btns, "UIPanelButtonTemplate")
    Btns.Tic:SetPoint("TOPLEFT", 0, 0)
    Btns.Tic:SetSize(120, 30)
    Btns.Tic:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then
            local UserName = UnitName("player")
            GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Challenge, " .. UserName, "WHISPER", GR.Target)
            GR.CanSendInvite = false
            GR:HideGameBtnsIfSentInvite()
            C_Timer.After(4, function() 
                GR.CanSendInvite = true
                GR:HideGameBtnsIfSentInvite()
            end)
        end
    end)
    local TicFS = Btns.Tic:CreateFontString(Btns.Tic, "HIGH", "GameTooltipText")
    TicFS:SetPoint("CENTER")
    TicFS:SetTextScale(1.1)
    TicFS:SetTextColor(.8,.8,.8, 1)
    TicFS:SetText("Tic-Tac-Toe")

    Btns.Battleships = CreateFrame("Button", Battleships, Btns, "UIPanelButtonTemplate")
    Btns.Battleships:SetPoint("TOPLEFT", 130, 0)
    Btns.Battleships:SetSize(120, 30)
    Btns.Battleships:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then
            local UserName = UnitName("player")
            GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Challenge, " .. UserName, "WHISPER", GR.Target)
            GR.CanSendInvite = false
            GR:HideGameBtnsIfSentInvite()
            C_Timer.After(4, function() 
                GR.CanSendInvite = true
                GR:HideGameBtnsIfSentInvite()
            end)
        end
    end)
    local BattleshipsFS = Btns.Battleships:CreateFontString(Btns.Battleships, "HIGH", "GameTooltipText")
    BattleshipsFS:SetPoint("CENTER")
    BattleshipsFS:SetTextScale(1.1)
    BattleshipsFS:SetTextColor(.8,.8,.8, 1)
    BattleshipsFS:SetText("Battleships")

    Btns:Hide()
end

function GR:CreateInviteFriends()
    GR_GUI.Main.Invite.FriendsScrollFrame = CreateFrame("ScrollFrame", FriendsScrollFrame, GR_GUI.Main.Invite, "UIPanelScrollFrameTemplate")
    local FriendsScrollFrame = GR_GUI.Main.Invite.FriendsScrollFrame
    FriendsScrollFrame:SetPoint("BOTTOMLEFT", 0, 10)
    FriendsScrollFrame:SetSize(200, 100)
    -- FriendsScrollFrame:SetClipsChildren(true)
    FriendsScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    
    GR_GUI.Main.Invite.Friends = CreateFrame("Frame", Friends, FriendsScrollFrame)
    local Friends = GR_GUI.Main.Invite.Friends
    Friends:SetSize(200,700)
    FriendsScrollFrame:SetScrollChild(Friends)
    local FriendsString = FriendsScrollFrame:CreateFontString(FriendsScrollFrame, "HIGH", "GameTooltipText")
    FriendsString:SetPoint("TOP", 0, 20)
    FriendsString:SetText("Friends")
    
    GR_GUI.Main.Invite.Friends.Btns = {}
    for i = 1, 100, 1 do
        local Btn = CreateFrame("Button", nil, Friends)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(200, 14)
        Btn:Hide()
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("TOPLEFT")
        table.insert(GR_GUI.Main.Invite.Friends.Btns, Btn)
    end

    C_Timer.After(5, function() 
        -- sends Register Friend message on login
        GR:RegisterFriends()
    end)
end

function GR:RegisterFriends()
    local PlayerName = UnitName("player")
    local NumFriends = C_FriendList.GetNumFriends()
    if (type(NumFriends) == "number") then
        for i = 1, NumFriends, 1 do
            local IsInFriends = false
            local OGFriend = C_FriendList.GetFriendInfoByIndex(i)
            for j,v in ipairs(GR.Friends) do
                if (v == OGFriend.name and OGFriend.connected) then
                    IsInFriends = true
                end
            end
            if (IsInFriends == false) then
                GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", OGFriend.name)
            end
        end
    end
    -- add battle.net account friends
    if (BNConnected() and GR.db.realm.showBN) then
        local NumBNFriends = BNGetNumFriends()
        if (type(NumBNFriends) == "number") then
            for i = 1, NumBNFriends, 1 do
                local IsInFriends = false
                local Character = select(5, BNGetFriendInfo(i))
                local Client = select(7, BNGetFriendInfo(i))
                for j,v in ipairs(GR.Friends) do
                    if (v == Character) then
                        IsInFriends = true
                    end
                end
                if (Client == "WoW" and type(Character) == "string" and IsInFriends == false) then
                    GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", Character)
                end
            end
        end
    end 
    -- add rivals
    for i,v in ipairs(GR.db.realm.Rivals) do
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", v)
    end
end

function GR:CreateInviteParty()
    GR_GUI.Main.Invite.PartyScrollFrame = CreateFrame("ScrollFrame", PartyScrollFrame, GR_GUI.Main.Invite, "UIPanelScrollFrameTemplate")
    local PartyScrollFrame = GR_GUI.Main.Invite.PartyScrollFrame
    PartyScrollFrame:SetPoint("BOTTOM", 0, 10)
    PartyScrollFrame:SetSize(200, 100)
    -- PartyScrollFrame:SetClipsChildren(true)
    PartyScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    
    GR_GUI.Main.Invite.Party = CreateFrame("Frame", Party, PartyScrollFrame)
    local Party = GR_GUI.Main.Invite.Party
    Party:SetSize(200,700)
    PartyScrollFrame:SetScrollChild(Party)
    local PartyString = PartyScrollFrame:CreateFontString(PartyScrollFrame, "HIGH", "GameTooltipText")
    PartyString:SetPoint("TOP", 0, 20)
    PartyString:SetText("Party & Guild")
    
    GR_GUI.Main.Invite.Party.Btns = {}
    for i = 1, 100, 1 do
        local Btn = CreateFrame("Button", nil, Party)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(200, 14)
        Btn:Hide()
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("TOPLEFT")
        table.insert(GR_GUI.Main.Invite.Party.Btns, Btn)
    end

    -- sends Register Party message on login
    local NumParty = GetNumGroupMembers()
    for i = 1, NumParty, 1 do
        local PlayerIndex = "party" .. tostring(i)
        local PartyMember = UnitName(PlayerIndex)
        local PlayerName = UnitName("player")
        if (type(PartyMember) == "string"  and UnitIsConnected(PlayerIndex)) then
            GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, "PARTY")
        end
    end
    if (IsInGuild()) then
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Guild, " .. UnitName("player"), "GUILD")
    end
end

function GR:CreateInviteZone()
    GR_GUI.Main.Invite.ZoneScrollFrame = CreateFrame("ScrollFrame", ZoneScrollFrame, GR_GUI.Main.Invite, "UIPanelScrollFrameTemplate")
    local ZoneScrollFrame = GR_GUI.Main.Invite.ZoneScrollFrame
    ZoneScrollFrame:SetPoint("BOTTOMRIGHT", 0, 10)
    ZoneScrollFrame:SetSize(200, 100)
    -- ZoneScrollFrame:SetClipsChildren(true)
    ZoneScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    
    GR_GUI.Main.Invite.Zone = CreateFrame("Frame", Zone, ZoneScrollFrame)
    local Zone = GR_GUI.Main.Invite.Zone
    Zone:SetSize(200,700)
    ZoneScrollFrame:SetScrollChild(Zone)
    
    GR_GUI.Main.Invite.Zone.Btns = {}
    for i = 1, 100, 1 do
        local Btn = CreateFrame("Button", nil, Zone)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(200, 14)
        Btn:Hide()
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("TOPLEFT")
        table.insert(GR_GUI.Main.Invite.Zone.Btns, Btn)
    end

    local ZoneText = GetZoneText()
    local z = 'z-"' .. ZoneText .. '"'
    GR_GUI.Main.Invite.ZoneReq = CreateFrame("Button", ZoneReq, ZoneScrollFrame, "UIPanelButtonTemplate")
    local ZoneReq = GR_GUI.Main.Invite.ZoneReq
    ZoneReq:SetSize(100, 30)
    ZoneReq:SetPoint("TOP", 0, 30)
    local ZoneReqString = ZoneReq:CreateFontString(ZoneReq, "HIGH", "GameTooltipText")
    ZoneReqString:SetPoint("CENTER")
    ZoneReqString:SetText("Zone")
    ZoneReq:SetScript("OnClick", function(self, button, down)
        C_FriendList.SetWhoToUi(true)
        if (button == "LeftButton" and down == false) then
            GR.Zone = {}
            C_FriendList.SendWho(z)
            C_Timer.After(.6, function() 
                local NumWhos, TotalNumWhos = C_FriendList.GetNumWhoResults()
                for i = 1, NumWhos, 1 do
                    local WhoPlayer = C_FriendList.GetWhoInfo(i)
                    for j,v in pairs(WhoPlayer) do
                        if (string.match(j, "fullName") and not string.match(v, UnitName("player"))) then
                            GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. UnitName("player"), "WHISPER", v)
                        end
                    end
                end
            end) 
        end
    end) 

    local function RegisterYell()
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. UnitName("player"), "YELL")
        C_Timer.After(5, function() 
            RegisterYell()
        end)
    end
    RegisterYell()
end

function GR:RefreshZoneList()
    local Btns = GR_GUI.Main.Invite.Zone.Btns
    for i = 1, 100, 1 do
        Btns[i]:Hide()
    end
    
    for i,v in ipairs(GR.Zone) do
        Btns[i].fs:SetText(v)
        Btns[i]:Show()
        Btns[i]:SetScript("OnClick", function(self, button, down)
            if (button == "LeftButton" and down == false) then
                GR.Target = v
                GR:ToggleGameBtns()
                GR:HideGameBtnsIfSentInvite()
            end
        end)
    end 
end

function GR:RefreshFriendsList()
    local Btns = GR_GUI.Main.Invite.Friends.Btns
    for i = 1, 100, 1 do
        Btns[i]:Hide()
    end

    for i,v in ipairs(GR.Friends) do
        Btns[i].fs:SetText(v)
        Btns[i]:Show()
        Btns[i]:SetScript("OnClick", function(self, button, down)
            if (button == "LeftButton" and down == false) then
                GR.Target = v
                GR:ToggleGameBtns()
                GR:HideGameBtnsIfSentInvite()
            end
        end)
    end

end

function GR:RemoveFromFriendsList()
    -- remove old friends
    local NumBNFriends = BNGetNumFriends()
    local NumFriends = C_FriendList.GetNumFriends()
    for i,v in ipairs(GR.Friends) do
        local IsInFriendList = false
        if (GR.db.realm.showBN) then
            for j = 1, NumBNFriends, 1 do
                local Friend = select(5,BNGetFriendInfo(j))
                if (type(Friend) == "string") then
                    if (string.match(v, Friend)) then
                        IsInFriendList = true
                    end
                end
            end
        end
        -- remove all BNFriends
        if (GR.db.realm.showBN == false) then
            for j = 1, NumBNFriends, 1 do
                local Friend = select(5,BNGetFriendInfo(j))
                if (type(Friend) == "string") then
                    if (string.match(v, Friend)) then
                        IsInFriendList = false
                    end
                end
            end
        end
        -- add from normal friends list after BNFriends dealt with
        for j = 1, NumFriends, 1 do
            local Friend = C_FriendList.GetFriendInfoByIndex(j)
            if (string.match(v, Friend.name) and Friend.connected) then
                IsInFriendList = true
            end
        end
        for j,k in ipairs(GR.db.realm.Rivals) do
            if (string.match(v, k)) then
                IsInFriendList = true
            end
        end
        if (IsInFriendList == false) then
            table.remove(GR.Friends, i)
        end
    end
end

function GR:AddToFriendsList(Value)
    local IsInTable = false
    for i,v in ipairs(GR.Friends) do
        if (string.match(v, Value)) then
            IsInTable = true
        end
    end
    if (IsInTable == false) then
        table.insert(GR.Friends, Value)
    end
end

function GR:RefreshPartyList()
    local Btns = GR_GUI.Main.Invite.Party.Btns
    for i = 1, 100, 1 do
        Btns[i]:Hide()
    end
    
    for i,v in ipairs(GR.Party) do
        Btns[i].fs:SetText(v)
        Btns[i]:Show()
        Btns[i]:SetScript("OnClick", function(self, button, down)
            if (button == "LeftButton" and down == false) then
                GR.Target = v
                GR:ToggleGameBtns()
                GR:HideGameBtnsIfSentInvite()
            end
        end)
    end
end

function GR:RegisterPlayers(...)
    local prefix, text, distribution, target = ...
    local PlayerName = UnitName("player")

    -- Register Friend
    local Action1 = string.sub(text, 0, 15)
    local Value1 = string.sub(text, 18, 50)
    if (string.match(Action1, "Register Friend")) then
        GR:AddToFriendsList(Value1)
        GR:RemoveFromFriendsList()
        GR:RefreshFriendsList()
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Friend Registered, " .. PlayerName, "WHISPER", Value1)
    end
    -- Friend Registered
    local Action2 = string.sub(text, 0, 17)
    local Value2 = string.sub(text, 20, 50)
    if (string.match(Action2, "Friend Registered")) then
        GR:AddToFriendsList(Value2)
        GR:RemoveFromFriendsList()
        GR:RefreshFriendsList()
    end 


    -- Register Zone
    local Action3 = string.sub(text, 0, 13)
    local Value3 = string.sub(text, 16, 50)
    if (string.match(Action3, "Register Zone")) then
        local IsInTable = false
        if (string.match(Value3, PlayerName)) then
            IsInTable = true
        end

        for i,v in ipairs(GR.Zone) do
            if (string.match(v, Value3)) then
                IsInTable = true
            end
        end
        if (IsInTable == false) then
            table.insert(GR.Zone, Value3)
        end
        GR:RefreshZoneList()
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Zone Registered, " .. PlayerName, "WHISPER", Value3)
    end
    -- Zone Registered
    local Action4 = string.sub(text, 0, 15)
    local Value4 = string.sub(text, 18, 50)
    if (string.match(Action4, "Zone Registered")) then
        local IsInTable = false
        if (string.match(Value4, PlayerName)) then
            IsInTable = true
        end

        for i,v in ipairs(GR.Zone) do
            if (string.match(v, Value4)) then
                IsInTable = true
            end
        end
        if (IsInTable == false) then
            table.insert(GR.Zone, Value4)
        end
        GR:RefreshZoneList()
    end 


    -- Register Party
    local Action5 = string.sub(text, 0, 14)
    local Value5 = string.sub(text, 17, 50)
    if (string.match(Action5, "Register Party") or string.match(Action5, "Register Guild")) then
        local IsInTable = false
        if (string.match(Value5, PlayerName)) then
            IsInTable = true
        end

        for i,v in ipairs(GR.Party) do
            if (string.match(v, Value5)) then
                IsInTable = true
            end
        end
        if (IsInTable == false) then
            table.insert(GR.Party, Value5)
            -- set party and guild arrays for whilelist option
            if (string.match(Action5, "Register Party")) then
                table.insert(GR.OnlyParty, Value5)
                GR:SendCommMessage("ZUI_GameRoom_Reg", "Party Registered, " .. PlayerName, "WHISPER", Value5)
            end
            if (string.match(Action5, "Register Guild")) then
                table.insert(GR.OnlyGuild, Value5)
                GR:SendCommMessage("ZUI_GameRoom_Reg", "Guild Registered, " .. PlayerName, "WHISPER", Value5)
            end
        end
        GR:RefreshPartyList()
    end
    -- Party Registered
    local Action6 = string.sub(text, 0, 16)
    local Value6 = string.sub(text, 19, 50)
    if (string.match(Action6, "Party Registered") or string.match(Action6, "Guild Registered")) then
        local IsInTable = false
        if (string.match(Value6, PlayerName)) then
            IsInTable = true
        end

        for i,v in ipairs(GR.Party) do
            if (string.match(v, Value6)) then
                IsInTable = true
            end
        end
        if (IsInTable == false) then
            table.insert(GR.Party, Value6)
            -- set party and guild arrays for whilelist option
            if (string.match(Action5, "Party Registered")) then
                table.insert(GR.OnlyParty, Value5)
            end
            if (string.match(Action5, "Guild Registered")) then
                table.insert(GR.OnlyGuild, Value5)
            end
        end
        GR:RefreshPartyList()
    end 
end

function GR:ShowChallengeIfChallenged()
    if (GR.IsChallenged and GR_GUI.Main.Tictactoe:IsVisible() == false) then 
        GR_GUI.Main.Accept:Show()
        GR_GUI.Main.DeclineBtn:Show()
    else
        GR_GUI.Main.Accept:Hide()
        GR_GUI.Main.DeclineBtn:Hide()
    end
end

function GR:AcceptDeclineChal(...)
    local prefix, text, distribution, target = ...

    -- registers incoming challenge
    local TicChallenge = string.sub(text, 0, 19)
    local BSChallenge = string.sub(text, 0, 21)
    local TicOpponent = string.sub(text, 22, 50)
    local BSOpponent = string.sub(text, 24, 50)
    if ((string.match(BSChallenge, "Battleships_Challenge") or string.match(TicChallenge, "TicTacToe_Challenge")) and GR.IsChallenged == false and GR.db.realm.disableChallenges == false) then
        local AcceptGameString = ""
        if (string.match(BSChallenge, "Battleships_Challenge")) then
            GR.GameType = "Battleships"
            AcceptGameString = "Battleships"
        end
        if (string.match(TicChallenge, "TicTacToe_Challenge")) then
            GR.GameType = "Tictactoe"
            AcceptGameString = "Tic-Tac-Toe"
        end
        local AcceptChallenger = true
        if (GR.db.realm.onlyWhitelist) then 
            AcceptChallenger = false
            -- go through whitelist and see if challenger is on list
            for i,v in ipairs(GR.db.realm.Whitelist) do
                if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                    AcceptChallenger = true
                end
            end
            -- if whitelist Friends, go through Friends and AcceptChallenger true if they match the opponent
            if (GR.db.realm.WhitelistFriends) then
                for i,v in ipairs(GR.Friends) do
                    if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                        AcceptChallenger = true
                    end
                end
            end
            -- if whitelist Guild, go through Guild and AcceptChallenger true if they match the opponent
            if (GR.db.realm.WhitelistGuild) then
                for i,v in ipairs(GR.OnlyGuild) do
                    if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                        AcceptChallenger = true
                    end
                end
            end
            -- if whitelist Party, go through Party and AcceptChallenger true if they match the opponent
            if (GR.db.realm.WhitelistParty) then
                for i,v in ipairs(GR.OnlyParty) do
                    if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                        AcceptChallenger = true
                    end
                end
            end
        end
        -- go through Blacklist and see if challenger is on list
        for i,v in ipairs(GR.db.realm.Blacklist) do
            if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                AcceptChallenger = false
            end
        end
        if (AcceptChallenger) then
            GR_GUI.Main.Accept.Fs2:SetText(TicOpponent .. " - " .. AcceptGameString)
            GR_GUI.Accept.Fs2:SetText(TicOpponent .. " - " .. AcceptGameString)
            if (string.match(BSChallenge, "Battleships_Challenge")) then
                GR.Opponent = BSOpponent
            end
            if (string.match(TicChallenge, "TicTacToe_Challenge")) then
                GR.Opponent = TicOpponent
            end
            if (GR.InGame == false) then
                GR.IsChallenged = true
                C_Timer.After(15, function()
                    GR.IsChallenged = false
                    GR:ShowChallengeIfChallenged()
                end)
                local Hide = false
                if (GR.db.realm.HideInCombat and InCombatLockdown()) then
                    Hide = true
                end
                if (not Hide) then
                    if (GR.db.realm.showChallengeAsMsg == false) then
                        if (GR_GUI.Main:IsVisible() == true) then
                            GR_GUI.Main.Accept:Show()
                            GR_GUI.Main.DeclineBtn:Show()
                            C_Timer.After(15, function() 
                                GR_GUI.Main.Accept:Hide()
                                GR_GUI.Main.DeclineBtn:Hide()
                            end)
                        else
                            GR_GUI.Accept:Show()
                            C_Timer.After(15, function() 
                                GR_GUI.Accept:Hide()
                            end)
                        end
                    else
                        GR:Print(GR.Opponent .. " has challenged you to play " .. AcceptGameString .. "!")
                        GR_GUI.Accept.Fs2:SetText(GR.Opponent .. " - " .. AcceptGameString)
                        if (GR_GUI.Main:IsVisible() == true) then
                            GR_GUI.Main.Accept:Show()
                            GR_GUI.Main.DeclineBtn:Show()
                            C_Timer.After(15, function() 
                                GR_GUI.Main.Accept:Hide()
                                GR_GUI.Main.DeclineBtn:Hide()
                            end)
                        end
                    end
                end
            else
                GR_GUI.Main.HeaderInfo.ReInvite:Hide()
                GR_GUI.Main.HeaderInfo.ReMatch:Show()
            end
        end
    end
    
    -- registers challenge accepted, shows game board. sender shows board on accept click
    local TicAccept = string.sub(text, 0, 16)
    local TicPlayerTurn = string.sub(text, 19, 19)
    local TicOpponent = string.sub(text, 22, 50)
    if (string.match(TicAccept, "TicTacToe_Accept")) then
        GR.GameType = "Tictactoe"
        GR:TicTacToeHideContent()  
        GR.Opponent = TicOpponent
        if (string.match(TicPlayerTurn, "2")) then
            GR.PlayerPos = 1
            GR.IsPlayerTurn = true
        else
            GR.PlayerPos = 2
            GR.IsPlayerTurn = false
        end
        GR:TicTacToeShowContent()  
    end
    local BSAccept = string.sub(text, 0, 18)
    local BSPlayerTurn = string.sub(text, 21, 21)
    local BSOpponent = string.sub(text, 24, 50)
    if (string.match(BSAccept, "Battleships_Accept")) then
        GR.GameType = "Battleships"
        GR:BattleshipsHideContent()  
        GR.Opponent = BSOpponent
        if (string.match(BSPlayerTurn, "2")) then
            GR.PlayerPos = 1
            GR.IsPlayerTurn = true
        else
            GR.PlayerPos = 2
            GR.IsPlayerTurn = false
        end
        GR:BattleshipsShowContent()  
    end

    -- ends game if opponent ends game
    local TicEndGame = string.sub(text, 0, 17)
    if (string.match(TicEndGame, "TicTacToe_GameEnd")) then
        GR.GameType = nil
        GR:TicTacToeHideContent()
    end
    local BSEndGame = string.sub(text, 0, 19)
    if (string.match(BSEndGame, "Battleships_GameEnd")) then
        GR.GameType = nil
        GR:BattleshipsHideContent()
    end
    
    -- game declined
    local TicDecline = string.sub(text, 0, 17)
    if (string.match(TicDecline, "TicTacToe_Decline")) then
        GR.CanSendInvite = true
        GR:HideGameBtnsIfSentInvite()
        GR.Opponent = nil
    end
    local BSDecline = string.sub(text, 0, 19)
    if (string.match(BSDecline, "Battleships_Decline")) then
        GR.CanSendInvite = true
        GR:HideGameBtnsIfSentInvite()
        GR.Opponent = nil
    end
end

-- (impossible bug) error message on whisper to offline player (BNFriends and Rivals)
