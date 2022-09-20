function GR:CreateSettings()
    GR.TargetName = ""
    GR.CurrList = "Blacklist"

    GR_GUI.Main.SettingsScroll = CreateFrame("ScrollFrame", SettingsScroll, GR_GUI.Main, "UIPanelScrollFrameTemplate")
    local SettingsScroll = GR_GUI.Main.SettingsScroll
    SettingsScroll:SetPoint("TOP", 0, -96)
    SettingsScroll:SetSize(360, 410)
    SettingsScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

    -- local SettingsBorder = CreateFrame("Frame", SettingsBorder, SettingsScroll, "ThinBorderTemplate")
    -- SettingsBorder:SetPoint("TOPLEFT", SettingsScroll, "TOPLEFT", -8, 2)
    -- SettingsBorder:SetPoint("BOTTOMRIGHT", SettingsScroll, "BOTTOMRIGHT", 24, -2)

    GR_GUI.Main.Settings = CreateFrame("Frame", Settings, SettingsScroll)
    local Settings = GR_GUI.Main.Settings
    Settings:SetPoint("TOPLEFT", 0, -66)
    Settings:SetSize(350, 480)
    SettingsScroll:SetScrollChild(Settings)
    SettingsScroll:Hide()

    local H2 = SettingsScroll:CreateFontString(SettingsScroll, "HIGH", "GameTooltipText")
    H2:SetPoint("TOP", 0, 30)
    H2:SetTextScale(1.5)
    H2:SetTextColor(.8,.8,.8,1)
    H2:SetText("Settings")

    GR:CreateMainSettings()
    GR:CreateSettingsLists()
end

function GR:CreateMainSettings()
    local Settings = GR_GUI.Main.Settings
    -- Alpha Settings
    local AlphaString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    AlphaString:SetPoint("TOPLEFT", 0, -20)
    AlphaString:SetTextScale(1.1)
    AlphaString:SetTextColor(.8,.8,.8,1)
    AlphaString:SetText("Alpha")
    -- x 601, y 787, 186
    local AlphaSlider = CreateFrame("Button", AlphaSlider, Settings)
    AlphaSlider:SetPoint("TOPRIGHT", 0, -20)
    AlphaSlider:SetSize(250, 15)
    AlphaSlider:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then     
            local x,y = GetCursorPosition()
            GR.db.realm.windowAlpha = (x - 591) / 188
            GR_GUI.Main:SetAlpha(GR.db.realm.windowAlpha)
        end
    end)
    local AlphaTex = AlphaSlider:CreateTexture()
    AlphaTex:SetAllPoints(AlphaSlider)
    AlphaTex:SetColorTexture(0,.5,1,1)
    
    -- Disable Battle Net Friends
    local BNString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    BNString:SetPoint("TOPLEFT", 0, -50)
    BNString:SetTextScale(1.1)
    BNString:SetTextColor(.8,.8,.8,1)
    BNString:SetText("Disable Battle.net Friends")
    local BNBtn = CreateFrame("CheckButton", BNBtn, Settings, "UICheckButtonTemplate")
    BNBtn:SetPoint("TOPRIGHT", 0, -50)
    BNBtn:SetSize(25, 25)
    BNBtn:SetChecked(not GR.db.realm.showBN)
    BNBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.showBN = not GR.db.realm.showBN
            if (GR.db.realm.showBN == false) then
                GR:RemoveFromFriendsList()
                GR:RefreshFriendsList()
            end
            GR:RegisterFriends()
        end
    end)

    -- Disable incoming Challenges
    local IncString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    IncString:SetPoint("TOPLEFT", 0, -80)
    IncString:SetTextScale(1.1)
    IncString:SetTextColor(.8,.8,.8,1)
    IncString:SetText("Disable Incoming Challenges")
    local IncBtn = CreateFrame("CheckButton", IncBtn, Settings, "UICheckButtonTemplate")
    IncBtn:SetPoint("TOPRIGHT", 0, -80)
    IncBtn:SetSize(25, 25)
    IncBtn:SetChecked(GR.db.realm.disableChallenges)
    IncBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.disableChallenges = not GR.db.realm.disableChallenges
            if (GR.db.realm.disableChallenges == true) then
                GR_GUI.Main.Accept:Hide()
                GR_GUI.Main.HeaderInfo.Accept:Hide()
            end
        end
    end)

    -- Whitelist Checkbox
    local WhitelistString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    WhitelistString:SetPoint("TOPLEFT", 0, -110)
    WhitelistString:SetTextScale(1.1)
    WhitelistString:SetTextColor(.8,.8,.8,1)
    WhitelistString:SetText("Show Challenges Only From Whitelist")
    local WhitelistBtn = CreateFrame("CheckButton", WhitelistBtn, Settings, "UICheckButtonTemplate")
    WhitelistBtn:SetPoint("TOPRIGHT", 0, -110)
    WhitelistBtn:SetSize(25, 25)
    WhitelistBtn:SetChecked(GR.db.realm.onlyWhitelist)
    WhitelistBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.onlyWhitelist = not GR.db.realm.onlyWhitelist
        end
    end)

    -- Show Challenges as Message 
    local ShowChallengeString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    ShowChallengeString:SetPoint("TOPLEFT", 0, -140)
    ShowChallengeString:SetTextScale(1.1)
    ShowChallengeString:SetTextColor(.8,.8,.8,1)
    ShowChallengeString:SetText("Show Challenges as Message")
    local ShowChallengeBtn = CreateFrame("CheckButton", ShowChallengeBtn, Settings, "UICheckButtonTemplate")
    ShowChallengeBtn:SetPoint("TOPRIGHT", 0, -140)
    ShowChallengeBtn:SetSize(25, 25)
    ShowChallengeBtn:SetChecked(GR.db.realm.showChallengeAsMsg)
    ShowChallengeBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.showChallengeAsMsg = not GR.db.realm.showChallengeAsMsg
            if (GR.db.realm.showChallengeAsMsg == true) then
                GR_GUI.Main.Accept:Hide()
                GR_GUI.Main.DeclineBtn:Hide()
            end
        end
    end)

    -- Moveable Challenge Button
    local MoveableChalString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    MoveableChalString:SetPoint("TOPLEFT", 0, -170)
    MoveableChalString:SetTextScale(1.1)
    MoveableChalString:SetTextColor(.8,.8,.8,1)
    MoveableChalString:SetText("Move Challenge Button")
    local MoveableChalBtn = CreateFrame("Button", MoveableChalBtn, Settings, "UIPanelButtonTemplate")
    MoveableChalBtn:SetPoint("TOPRIGHT", 0, -170)
    MoveableChalBtn:SetSize(50, 25)
    local MoveableChalBtnString = MoveableChalBtn:CreateFontString(MoveableChalBtn, "HIGH", "GameTooltipText")
    MoveableChalBtnString:SetPoint("CENTER")
    MoveableChalBtnString:SetTextScale(1.1)
    MoveableChalBtnString:SetTextColor(.8,.8,.8,1)
    MoveableChalBtnString:SetText("Show")
    MoveableChalBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            if (GR_GUI.AcceptMover:IsVisible() == false) then
                GR_GUI.AcceptMover:Show()
                MoveableChalBtnString:SetText("Hide")
            else
                GR_GUI.AcceptMover:Hide()
                MoveableChalBtnString:SetText("Show")
            end
        end
    end)

    -- Hide Challenge In Combat
    local CombatString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    CombatString:SetPoint("TOPLEFT", 0, -200)
    CombatString:SetTextScale(1.1)
    CombatString:SetTextColor(.8,.8,.8,1)
    CombatString:SetText("Hide Challenges in Combat")
    local CombatBtn = CreateFrame("CheckButton", CombatBtn, Settings, "UICheckButtonTemplate")
    CombatBtn:SetPoint("TOPRIGHT", 0, -200)
    CombatBtn:SetSize(25, 25)
    CombatBtn:SetChecked(GR.db.realm.HideInCombat)
    CombatBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.HideInCombat = not GR.db.realm.HideInCombat
        end
    end)

    -- Whitelist Guild
    local WhiteGuildString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    WhiteGuildString:SetPoint("TOPLEFT", 0, -230)
    WhiteGuildString:SetTextScale(1.1)
    WhiteGuildString:SetTextColor(.8,.8,.8, 1)
    WhiteGuildString:SetText("Whitelist Guild")
    local WhiteGuildBtn = CreateFrame("CheckButton", WhiteGuildBtn, Settings, "UICheckButtonTemplate")
    WhiteGuildBtn:SetPoint("TOPRIGHT", 0, -230)
    WhiteGuildBtn:SetSize(25, 25)
    WhiteGuildBtn:SetChecked(GR.db.realm.WhitelistGuild)
    WhiteGuildBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.WhitelistGuild = not GR.db.realm.WhitelistGuild
        end
    end)

    -- Whitelist Party
    local WhitePartyString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    WhitePartyString:SetPoint("TOPLEFT", 0, -260)
    WhitePartyString:SetTextScale(1.1)
    WhitePartyString:SetTextColor(.8,.8,.8, 1)
    WhitePartyString:SetText("Whitelist Party")
    local WhitePartyBtn = CreateFrame("CheckButton", WhitePartyBtn, Settings, "UICheckButtonTemplate")
    WhitePartyBtn:SetPoint("TOPRIGHT", 0, -260)
    WhitePartyBtn:SetSize(25, 25)
    WhitePartyBtn:SetChecked(GR.db.realm.WhitelistParty)
    WhitePartyBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.WhitelistParty = not GR.db.realm.WhitelistParty
        end
    end)

    -- Whitelist Friends
    local WhiteFriendsString = Settings:CreateFontString(Settings, "HIGH", "GameTooltipText")
    WhiteFriendsString:SetPoint("TOPLEFT", 0, -290)
    WhiteFriendsString:SetTextScale(1.1)
    WhiteFriendsString:SetTextColor(.8,.8,.8, 1)
    WhiteFriendsString:SetText("Whitelist Friends")
    local WhiteFriendsBtn = CreateFrame("CheckButton", WhiteFriendsBtn, Settings, "UICheckButtonTemplate")
    WhiteFriendsBtn:SetPoint("TOPRIGHT", 0, -290)
    WhiteFriendsBtn:SetSize(25, 25)
    WhiteFriendsBtn:SetChecked(GR.db.realm.WhitelistFriends)
    WhiteFriendsBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            GR.db.realm.WhitelistFriends = not GR.db.realm.WhitelistFriends
        end
    end)
end

function GR:CreateSettingsLists()
    local Settings = GR_GUI.Main.Settings
    Settings.Lists = CreateFrame("Frame", Lists, Settings)
    local Lists = Settings.Lists
    Lists:SetPoint("TOP", 0, -405)
    Lists:SetSize(220, 180)

    -- BlacklistScroll
    Settings.BlacklistScroll = CreateFrame("ScrollFrame", BlacklistScroll, Lists, "UIPanelScrollFrameTemplate")
    local BlacklistScroll = Settings.BlacklistScroll
    BlacklistScroll:SetPoint("TOP", 0, 0)
    BlacklistScroll:SetSize(220, 180)
    BlacklistScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    local BlacklistBorder = CreateFrame("Frame", BlacklistBorder, BlacklistScroll, "ThinBorderTemplate")
    BlacklistBorder:SetPoint("TOPLEFT", BlacklistScroll, "TOPLEFT", -8, 2)
    BlacklistBorder:SetPoint("BOTTOMRIGHT", BlacklistScroll, "BOTTOMRIGHT", 24, -2)
    -- WhitelistScroll
    Settings.WhitelistScroll = CreateFrame("ScrollFrame", WhitelistScroll, Lists, "UIPanelScrollFrameTemplate")
    local WhitelistScroll = Settings.WhitelistScroll
    WhitelistScroll:SetPoint("TOP", 0, 0)
    WhitelistScroll:SetSize(220, 180)
    WhitelistScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    local WhitelistBorder = CreateFrame("Frame", WhitelistBorder, WhitelistScroll, "ThinBorderTemplate")
    WhitelistBorder:SetPoint("TOPLEFT", WhitelistScroll, "TOPLEFT", -8, 2)
    WhitelistBorder:SetPoint("BOTTOMRIGHT", WhitelistScroll, "BOTTOMRIGHT", 24, -2)
    -- RivalsScroll
    Settings.RivalsScroll = CreateFrame("ScrollFrame", RivalsScroll, Lists, "UIPanelScrollFrameTemplate")
    local RivalsScroll = Settings.RivalsScroll
    RivalsScroll:SetPoint("TOP", 0, 0)
    RivalsScroll:SetSize(220, 180)
    RivalsScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    local RivalsBorder = CreateFrame("Frame", RivalsBorder, RivalsScroll, "ThinBorderTemplate")
    RivalsBorder:SetPoint("TOPLEFT", RivalsScroll, "TOPLEFT", -8, 2)
    RivalsBorder:SetPoint("BOTTOMRIGHT", RivalsScroll, "BOTTOMRIGHT", 24, -2)

    -- Add to list
    Lists.AddInput = CreateFrame("Editbox", AddInput, Lists, "InputBoxInstructionsTemplate")
    Lists.AddInput:SetPoint("TOP", 0, 55)
    Lists.AddInput:SetWidth(150)
    Lists.AddInput:SetFontObject("ChatFontNormal")
    Lists.AddInput:SetMultiLine(true)
    Lists.AddInput:SetAutoFocus(false)

    Lists.AddInput.Btn = CreateFrame("Button", AddBtn, Lists.AddInput, "UIPanelButtonTemplate")
    local AddBtn = Lists.AddInput.Btn
    AddBtn:SetPoint("BOTTOM", 0, -32)
    AddBtn:SetSize(100, 25)
    AddBtn:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then
            if (GR.CurrList == "Blacklist") then 
                table.insert(GR.db.realm.Blacklist, Lists.AddInput:GetText()) 
                GR:ResetSettingsListScroll(GR.db.realm.Blacklist, Settings.Blacklist.Btns, Settings.Blacklist)
            end
            if (GR.CurrList == "Whitelist") then 
                table.insert(GR.db.realm.Whitelist, Lists.AddInput:GetText()) 
                GR:ResetSettingsListScroll(GR.db.realm.Whitelist, Settings.Whitelist.Btns, Settings.Whitelist)
            end
            if (GR.CurrList == "Rivals") then 
                table.insert(GR.db.realm.Rivals, Lists.AddInput:GetText()) 
                GR:ResetSettingsListScroll(GR.db.realm.Rivals, Settings.Rivals.Btns, Settings.Rivals)
            end
        end
    end)
    local AddString = AddBtn:CreateFontString(AddBtn, "HIGH", "GameTooltipText")
    AddString:SetPoint("CENTER")
    AddString:SetTextColor(.8,.8,.8, 1)
    AddString:SetText("Add To List")

    -- Delete from list
    Lists.Delete = CreateFrame("Button", Delete, Lists, "UIPanelButtonTemplate")
    local Delete = Lists.Delete
    Delete:SetPoint("TOPRIGHT", 60, 35)
    Delete:SetSize(100, 25)
    local DeleteFS = Delete:CreateFontString(Delete, "HIGH", "GameTooltipText")
    DeleteFS:SetPoint("CENTER")
    DeleteFS:SetTextColor(.8,.8,.8, 1)
    DeleteFS:SetTextScale(1.1)
    DeleteFS:SetText("Remove")
    Delete:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            if (GR.CurrList == "Blacklist") then 
                for i,v in ipairs (GR.db.realm.Blacklist) do
                    if (GR.TargetName == v) then
                        table.remove(GR.db.realm.Blacklist, i)
                        GR:ResetSettingsListScroll(GR.db.realm.Blacklist, Settings.Blacklist.Btns, Settings.Blacklist)
                    end
                end
            end
            if (GR.CurrList == "Whitelist") then 
                for i,v in ipairs (GR.db.realm.Whitelist) do
                    if (GR.TargetName == v) then
                        table.remove(GR.db.realm.Whitelist, i)
                        GR:ResetSettingsListScroll(GR.db.realm.Whitelist, Settings.Whitelist.Btns, Settings.Whitelist)
                    end
                end
            end
            if (GR.CurrList == "Rivals") then 
                for i,v in ipairs (GR.db.realm.Rivals) do
                    if (GR.TargetName == v) then
                        table.remove(GR.db.realm.Rivals, i)
                        GR:ResetSettingsListScroll(GR.db.realm.Rivals, Settings.Rivals.Btns, Settings.Rivals)
                    end
                end
            end
        end
    end)

    -- Select List
    Settings.Listtabs = CreateFrame("Frame", Listtabs, Lists)
    local Listtabs = Settings.Listtabs
    Listtabs:SetPoint("TOP", 0, 87)
    Listtabs:SetSize(250, 25)
    -- BlacklistBtn
    Settings.Listtabs.BlacklistBtn = CreateFrame("Button", BlacklistBtn, Listtabs, "UIPanelButtonTemplate")
    local BlacklistBtn = Settings.Listtabs.BlacklistBtn
    BlacklistBtn:SetPoint("LEFT")
    BlacklistBtn:SetSize(80, 25)
    BlacklistBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then 
            GR.CurrList = "Blacklist"
            Settings.WhitelistScroll:Hide()
            Settings.Whitelist:Hide()
            Settings.RivalsScroll:Hide()
            Settings.Rivals:Hide()
            Settings.BlacklistScroll:Show()
            Settings.Blacklist:Show()
        end
    end)
    local BlacklistBtnFS = BlacklistBtn:CreateFontString(BlacklistBtn, "HIGH", "GameTooltipText")
    BlacklistBtnFS:SetPoint("CENTER")
    BlacklistBtnFS:SetTextColor(.8,.8,.8, 1)
    BlacklistBtnFS:SetText("Blacklist")
    -- WhitelistBtn
    Settings.Listtabs.WhitelistBtn = CreateFrame("Button", WhitelistBtn, Listtabs, "UIPanelButtonTemplate")
    local WhitelistBtn = Settings.Listtabs.WhitelistBtn
    WhitelistBtn:SetPoint("CENTER")
    WhitelistBtn:SetSize(80, 25)
    WhitelistBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then 
            GR.CurrList = "Whitelist"
            Settings.BlacklistScroll:Hide()
            Settings.Blacklist:Hide()
            Settings.RivalsScroll:Hide()
            Settings.Rivals:Hide()
            Settings.WhitelistScroll:Show()
            Settings.Whitelist:Show()

        end
    end)
    local WhitelistBtnFS = WhitelistBtn:CreateFontString(WhitelistBtn, "HIGH", "GameTooltipText")
    WhitelistBtnFS:SetPoint("CENTER")
    WhitelistBtnFS:SetTextColor(.8,.8,.8, 1)
    WhitelistBtnFS:SetText("Whitelist")
    -- RivalBtn
    Settings.Listtabs.RivalsBtn = CreateFrame("Button", RivalsBtn, Listtabs, "UIPanelButtonTemplate")
    local RivalsBtn = Settings.Listtabs.RivalsBtn
    RivalsBtn:SetPoint("RIGHT")
    RivalsBtn:SetSize(80, 25)
    RivalsBtn:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then 
            GR.CurrList = "Rivals"
            Settings.WhitelistScroll:Hide()
            Settings.Whitelist:Hide()
            Settings.BlacklistScroll:Hide()
            Settings.Blacklist:Hide()
            Settings.RivalsScroll:Show()
            Settings.Rivals:Show()
        end
    end)
    local RivalsBtnFS = RivalsBtn:CreateFontString(RivalsBtn, "HIGH", "GameTooltipText")
    RivalsBtnFS:SetPoint("CENTER")
    RivalsBtnFS:SetTextColor(.8,.8,.8, 1)
    RivalsBtnFS:SetText("Rivals")

    -- Blacklist
    Settings.Blacklist = CreateFrame("Frame", Blacklist, BlacklistScroll)
    local Blacklist = Settings.Blacklist
    Blacklist:SetSize(210, 600)
    BlacklistScroll:SetScrollChild(Blacklist)
    Settings.Blacklist.Btns = {}
    local BlackBtns = Settings.Blacklist.Btns
    for i,v in ipairs(GR.db.realm.Blacklist) do
        local Btn = CreateFrame("Button", nil, Blacklist)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(300, 14)
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("LEFT")
        Btn.fs:SetText(v)
        local BtnTexture = Btn:CreateTexture()
        BtnTexture:SetAllPoints(Btn)
        BtnTexture:SetColorTexture(.7,.7,.7, .4)
        BtnTexture:Hide()
        Btn:SetScript("OnClick", function(self, button, down) 
            if (button == "LeftButton" and down == false) then
                GR.TargetName = v
                for j,k in ipairs(BlackBtns) do
                    local x, tex = k:GetRegions()
                    tex:Hide()
                end
                BtnTexture:Show()
            end
        end)
        table.insert(BlackBtns, Btn)
    end

    -- Whitelist
    Settings.Whitelist = CreateFrame("Frame", Whitelist, WhitelistScroll)
    local Whitelist = Settings.Whitelist
    Whitelist:SetSize(210, 600)
    WhitelistScroll:SetScrollChild(Whitelist)
    Settings.Whitelist.Btns = {}
    local WhiteBtns = Settings.Whitelist.Btns
    for i,v in ipairs(GR.db.realm.Whitelist) do
        local Btn = CreateFrame("Button", nil, Whitelist)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(300, 14)
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("LEFT")
        Btn.fs:SetText(v)
        local BtnTexture = Btn:CreateTexture()
        BtnTexture:SetAllPoints(Btn)
        BtnTexture:SetColorTexture(.7,.7,.7, .4)
        BtnTexture:Hide()
        Btn:SetScript("OnClick", function(self, button, down) 
            if (button == "LeftButton" and down == false) then
                GR.TargetName = v
                for j,k in ipairs(WhiteBtns) do
                    local x, tex = k:GetRegions()
                    tex:Hide()
                end
                BtnTexture:Show()
            end
        end)
        table.insert(WhiteBtns, Btn)
    end

    -- Rivals
    Settings.Rivals = CreateFrame("Frame", Rivals, RivalsScroll)
    local Rivals = Settings.Rivals
    Rivals:SetSize(210, 600)
    RivalsScroll:SetScrollChild(Rivals)
    Settings.Rivals.Btns = {}
    local RivalsBtns = Settings.Rivals.Btns
    for i,v in ipairs(GR.db.realm.Rivals) do
        local Btn = CreateFrame("Button", nil, Rivals)
        Btn:SetPoint("TOPLEFT", 0, i*-14)
        Btn:SetSize(300, 14)
        Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        Btn.fs:SetPoint("LEFT")
        Btn.fs:SetText(v)
        local BtnTexture = Btn:CreateTexture()
        BtnTexture:SetAllPoints(Btn)
        BtnTexture:SetColorTexture(.7,.7,.7, .4)
        BtnTexture:Hide()
        Btn:SetScript("OnClick", function(self, button, down) 
            if (button == "LeftButton" and down == false) then
                GR.TargetName = v
                for j,k in ipairs(RivalsBtns) do
                    local x, tex = k:GetRegions()
                    tex:Hide()
                end
                BtnTexture:Show()
            end
        end)
        table.insert(RivalsBtns, Btn)
    end

    Settings.RivalsScroll:Hide()
    Settings.Rivals:Hide()
    Settings.WhitelistScroll:Hide()
    Settings.Whitelist:Hide()
end

function GR:ResetSettingsListScroll(DB, Btns, Listx)
    -- add to btns
    for i,v in ipairs(DB) do
        local IsInBtns = false
        for j=1, #Btns, 1 do
            local fs = Btns[j]:GetRegions()
            local text = fs:GetText()
            if (text == v) then
                IsInBtns = true
            end
        end

        if (IsInBtns == false) then 
            local Btn = CreateFrame("Button", nil, Listx)
            Btn:SetPoint("TOPLEFT", 0, (#Btns * -14) -14)
            Btn:SetSize(300, 14)
            Btn.fs = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
            Btn.fs:SetPoint("LEFT")
            Btn.fs:SetText(v)
            local BtnTexture = Btn:CreateTexture()
            BtnTexture:SetAllPoints(Btn)
            BtnTexture:SetColorTexture(.7,.7,.7, .4)
            BtnTexture:Hide()
            Btn:SetScript("OnClick", function(self, button, down) 
                if (button == "LeftButton" and down == false) then
                    GR.TargetName = v
                    for j,k in ipairs(Btns) do
                        local x, tex = k:GetRegions()
                        tex:Hide()
                    end
                    BtnTexture:Show()
                end
            end)
            table.insert(Btns, Btn)
            Btn:Show()
        end
    end

    -- find btn to remove from Btns
    for i,v in ipairs(Btns) do
        local IsInDB = false
        local fs = v:GetRegions()
        local text = fs:GetText()
        for j,k in ipairs(DB) do
            if (text == k) then
                IsInDB = true
            end
        end
        if (IsInDB == false) then
            -- remove button from Btns
            Btns[i]:Hide()
            table.remove(Btns,i)
            GR.TargetName = ""
            -- reset pos of Btns
            for j,k in ipairs(Btns) do
                k:SetPoint("TOPLEFT", 0, j*-14)
            end
        end
    end
end
