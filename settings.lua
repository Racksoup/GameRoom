function GR:CreateSettings()
  local Main = GR_GUI.Main

  GR.TargetName = ""      
  GR.CurrList = "Blacklist"
  GR.WinAlpha = 1

  Main.Tab4 = CreateFrame("Frame", Tab4, Main)
  local Tab4 = Main.Tab4    

  -- Settings
  Tab4.SettingsScroll = CreateFrame("ScrollFrame", "SettingsScroll", Tab4, "UIPanelScrollFrameTemplate")
  local SettingsScroll = Tab4.SettingsScroll
  SettingsScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  Tab4.Settings = CreateFrame("Frame", "Settings", SettingsScroll)
  local Settings = Tab4.Settings
  Settings:SetClipsChildren(true)
  SettingsScroll:SetScrollChild(Settings)

  GR:CreateMainSettings()
  GR:CreateSettingsLists() 
  GR:CreateSettingsTabs()
  GR:CreateListControls()

  GR:SizeSettings()
end

function GR:CreateMainSettings()
  local Settings = GR_GUI.Main.Tab4.Settings

  -- Alpha Settings
  Settings.AlphaFS = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local AlphaFS = Settings.AlphaFS
  AlphaFS:SetTextColor(1,1,1,1)
  AlphaFS:SetText("Alpha")
  Settings.AlphaSlider = CreateFrame("Slider", "AlphaSlider", Settings, "UISliderTemplate")
  local AlphaSlider = Settings.AlphaSlider
  AlphaSlider:SetScript("OnValueChanged", function(self, value) 
    GR.WinAlpha = value / 100
    GR_GUI.Main:SetAlpha(GR.WinAlpha)
  end)
  AlphaSlider:SetMinMaxValues(30, 100)
  AlphaSlider:SetValueStep(10)
  AlphaSlider:SetValue(100)
  AlphaSlider:SetObeyStepOnDrag(true)
  
  -- Disable Battle Net Friends
  Settings.BNString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local BNString = Settings.BNString
  BNString:SetTextColor(1,1,1,1)
  BNString:SetText("Disable Battle.net Friends")
  Settings.BNBtn = CreateFrame("CheckButton", BNBtn, Settings, "UICheckButtonTemplate")
  local BNBtn = Settings.BNBtn
  BNBtn:SetChecked(not GR.db.realm.showBN)
  BNBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.showBN = not GR.db.realm.showBN
      if (GR.db.realm.showBN == false) then
        GR:RemoveDisconnectedFromFriendsList()
        GR:RefreshFriendsListUI()
      end
    end
  end)

  -- Disable incoming Challenges
  Settings.IncString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local IncString = Settings.IncString
  IncString:SetTextColor(1,1,1,1)
  IncString:SetText("Disable Incoming Challenges")
  Settings.IncBtn = CreateFrame("CheckButton", IncBtn, Settings, "UICheckButtonTemplate")
  local IncBtn = Settings.IncBtn
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
  Settings.WhitelistString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local WhitelistString = Settings.WhitelistString
  WhitelistString:SetTextColor(1,1,1,1)
  WhitelistString:SetText("Show Challenges Only From Whitelist")
  Settings.WhitelistBtn = CreateFrame("CheckButton", WhitelistBtn, Settings, "UICheckButtonTemplate")
  local WhitelistBtn = Settings.WhitelistBtn
  WhitelistBtn:SetChecked(GR.db.realm.onlyWhitelist)
  WhitelistBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.onlyWhitelist = not GR.db.realm.onlyWhitelist
    end
  end)

  -- Show Challenges as Message 
  Settings.ShowChallengeString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local ShowChallengeString = Settings.ShowChallengeString
  ShowChallengeString:SetTextColor(1,1,1,1)
  ShowChallengeString:SetText("Show Challenges as Message")
  Settings.ShowChallengeBtn = CreateFrame("CheckButton", ShowChallengeBtn, Settings, "UICheckButtonTemplate")
  local ShowChallengeBtn = Settings.ShowChallengeBtn
  ShowChallengeBtn:SetChecked(GR.db.realm.showChallengeAsMsg)
  ShowChallengeBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.showChallengeAsMsg = not GR.db.realm.showChallengeAsMsg
    end
  end)

  -- Moveable Challenge Button
  Settings.MoveableChalString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local MoveableChalString = Settings.MoveableChalString
  MoveableChalString:SetTextColor(1,1,1,1)
  MoveableChalString:SetText("Move Challenge Button")
  Settings.MoveableChalBtn = CreateFrame("Button", MoveableChalBtn, Settings, "UIPanelButtonTemplate")
  local MoveableChalBtn = Settings.MoveableChalBtn
  Settings.MoveableChalBtnString = MoveableChalBtn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local MoveableChalBtnString = Settings.MoveableChalBtnString
  MoveableChalBtnString:SetTextColor(1,1,1,1)
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
  Settings.CombatString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local CombatString = Settings.CombatString
  CombatString:SetTextColor(1,1,1,1)
  CombatString:SetText("Hide Challenges in Combat")
  Settings.CombatBtn = CreateFrame("CheckButton", CombatBtn, Settings, "UICheckButtonTemplate")
  local CombatBtn = Settings.CombatBtn
  CombatBtn:SetChecked(GR.db.realm.HideInCombat)
  CombatBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.HideInCombat = not GR.db.realm.HideInCombat
    end
  end)

  -- Whitelist Guild
  Settings.WhiteGuildString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local WhiteGuildString = Settings.WhiteGuildString
  WhiteGuildString:SetTextColor(1,1,1, 1)
  WhiteGuildString:SetText("Whitelist Guild")
  Settings.WhiteGuildBtn = CreateFrame("CheckButton", WhiteGuildBtn, Settings, "UICheckButtonTemplate")
  local WhiteGuildBtn = Settings.WhiteGuildBtn
  WhiteGuildBtn:SetChecked(GR.db.realm.WhitelistGuild)
  WhiteGuildBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.WhitelistGuild = not GR.db.realm.WhitelistGuild
    end
  end)

  -- Whitelist Party
  Settings.WhitePartyString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local WhitePartyString = Settings.WhitePartyString
  WhitePartyString:SetTextColor(1,1,1, 1)
  WhitePartyString:SetText("Whitelist Party")
  Settings.WhitePartyBtn = CreateFrame("CheckButton", WhitePartyBtn, Settings, "UICheckButtonTemplate")
  local WhitePartyBtn = Settings.WhitePartyBtn
  WhitePartyBtn:SetChecked(GR.db.realm.WhitelistParty)
  WhitePartyBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.WhitelistParty = not GR.db.realm.WhitelistParty
    end
  end)

  -- Whitelist Friends
  Settings.WhiteFriendsString = Settings:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local WhiteFriendsString = Settings.WhiteFriendsString
  WhiteFriendsString:SetTextColor(1,1,1, 1)
  WhiteFriendsString:SetText("Whitelist Friends")
  Settings.WhiteFriendsBtn = CreateFrame("CheckButton", WhiteFriendsBtn, Settings, "UICheckButtonTemplate")
  local WhiteFriendsBtn = Settings.WhiteFriendsBtn
  WhiteFriendsBtn:SetChecked(GR.db.realm.WhitelistFriends)
  WhiteFriendsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.WhitelistFriends = not GR.db.realm.WhitelistFriends
    end
  end)
end

function GR:CreateSettingsLists()
  local Settings = GR_GUI.Main.Tab4.Settings
  Settings.Lists = CreateFrame("Frame", Lists, Settings)
  local Lists = Settings.Lists

  -- BlacklistScroll
  Settings.BlacklistScroll = CreateFrame("ScrollFrame", BlacklistScroll, Lists, "UIPanelScrollFrameTemplate")
  local BlacklistScroll = Settings.BlacklistScroll
  BlacklistScroll:SetPoint("TOP", 0, 0)
  BlacklistScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  BlacklistScroll.Border = CreateFrame("Frame", BlacklistBorder, BlacklistScroll, "ThinBorderTemplate")
  local BlacklistBorder = BlacklistScroll.Border
  -- WhitelistScroll
  Settings.WhitelistScroll = CreateFrame("ScrollFrame", WhitelistScroll, Lists, "UIPanelScrollFrameTemplate")
  local WhitelistScroll = Settings.WhitelistScroll
  WhitelistScroll:SetPoint("TOP", 0, 0)
  WhitelistScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  WhitelistScroll.Border = CreateFrame("Frame", WhitelistBorder, WhitelistScroll, "ThinBorderTemplate")
  local WhitelistBorder = WhitelistScroll.Border 
  -- RivalsScroll
  Settings.RivalsScroll = CreateFrame("ScrollFrame", RivalsScroll, Lists, "UIPanelScrollFrameTemplate")
  local RivalsScroll = Settings.RivalsScroll
  RivalsScroll:SetPoint("TOP", 0, 0)
  RivalsScroll:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  RivalsScroll.Border = CreateFrame("Frame", RivalsBorder, RivalsScroll, "ThinBorderTemplate")
  local RivalsBorder = RivalsScroll.Border

  -- Blacklist
  Settings.Blacklist = CreateFrame("Frame", "Blacklist", BlacklistScroll)
  local Blacklist = Settings.Blacklist
  BlacklistScroll:SetScrollChild(Blacklist)
  Settings.Blacklist.Btns = {}
  local BlackBtns = Settings.Blacklist.Btns
  for i,v in ipairs(GR.db.realm.Blacklist) do
    local Btn = CreateFrame("Button", nil, Blacklist)
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("LEFT")
    Btn.FS:SetText(v)
    Btn.Tex = Btn:CreateTexture()
    Btn.Tex:SetAllPoints(Btn)
    Btn.Tex:SetColorTexture(.7,.7,.7, .4)
    Btn.Tex:Hide()
    Btn:SetScript("OnClick", function(self, button, down) 
      if (button == "LeftButton" and down == false) then
        GR.TargetName = v
        for j,k in ipairs(BlackBtns) do
          local x, tex = k:GetRegions()
          tex:Hide()
        end
        Btn:Show()
      end
    end)
    table.insert(BlackBtns, Btn)
  end

  -- Whitelist
  Settings.Whitelist = CreateFrame("Frame", Whitelist, WhitelistScroll)
  local Whitelist = Settings.Whitelist
  WhitelistScroll:SetScrollChild(Whitelist)
  Settings.Whitelist.Btns = {}
  local WhiteBtns = Settings.Whitelist.Btns
  for i,v in ipairs(GR.db.realm.Whitelist) do
    local Btn = CreateFrame("Button", nil, Whitelist)
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("LEFT")
    Btn.FS:SetText(v)
    Btn.Tex = Btn:CreateTexture()
    Btn.Tex:SetAllPoints(Btn)
    Btn.Tex:SetColorTexture(.7,.7,.7, .4)
    Btn.Tex:Hide()
    Btn:SetScript("OnClick", function(self, button, down) 
      if (button == "LeftButton" and down == false) then
        GR.TargetName = v
        for j,k in ipairs(WhiteBtns) do
          local x, tex = k:GetRegions()
          tex:Hide()
        end
        Btn.Tex:Show()
      end
    end)
    table.insert(WhiteBtns, Btn)
  end

  -- Rivals
  Settings.Rivals = CreateFrame("Frame", Rivals, RivalsScroll)
  local Rivals = Settings.Rivals
  RivalsScroll:SetScrollChild(Rivals)
  Settings.Rivals.Btns = {}
  local RivalsBtns = Settings.Rivals.Btns
  for i,v in ipairs(GR.db.realm.Rivals) do
    local Btn = CreateFrame("Button", nil, Rivals)
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("LEFT")
    Btn.FS:SetText(v)
    Btn.Tex = Btn:CreateTexture()
    Btn.Tex:SetAllPoints(Btn)
    Btn.Tex:SetColorTexture(.7,.7,.7, .4)
    Btn.Tex:Hide()
    Btn:SetScript("OnClick", function(self, button, down) 
      if (button == "LeftButton" and down == false) then
        GR.TargetName = v
        for j,k in ipairs(RivalsBtns) do
          local x, tex = k:GetRegions()
          tex:Hide()
        end
        Btn.Tex:Show()
      end
    end)
    table.insert(RivalsBtns, Btn)
  end

  Settings.RivalsScroll:Hide()
  Settings.Rivals:Hide()
  Settings.WhitelistScroll:Hide()
  Settings.Whitelist:Hide()
end

function GR:CreateSettingsTabs()
  local Settings = GR_GUI.Main.Tab4.Settings
  -- Select List
  Settings.Listtabs = CreateFrame("Frame", "Listtabs", Settings.Lists)
  local Listtabs = Settings.Listtabs
  
  -- BlacklistBtn
  Settings.Listtabs.BlacklistBtn = CreateFrame("Button", "BlacklistBtn", Listtabs, "PanelTopTabButtonTemplate")
  local BlacklistBtn = Settings.Listtabs.BlacklistBtn
  BlacklistBtn.LeftActive:Hide()
  BlacklistBtn.MiddleActive:Hide()
  BlacklistBtn.RightActive:Hide()
  BlacklistBtn:SetText("Blacklist")
  BlacklistBtn:SetPoint("BOTTOMLEFT")
  BlacklistBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then 
      GR.CurrList = "Blacklist"
      GR:ToggleSettingsListTab()
      Settings.WhitelistScroll:Hide()
      Settings.Whitelist:Hide()
      Settings.RivalsScroll:Hide()
      Settings.Rivals:Hide()
      Settings.BlacklistScroll:Show()
      Settings.Blacklist:Show()
    end
  end)

  -- WhitelistBtn
  Settings.Listtabs.WhitelistBtn = CreateFrame("Button", "WhitelistBtn", Listtabs, "PanelTopTabButtonTemplate")
  local WhitelistBtn = Settings.Listtabs.WhitelistBtn
  WhitelistBtn.LeftActive:Hide()
  WhitelistBtn.MiddleActive:Hide()
  WhitelistBtn.RightActive:Hide()
  WhitelistBtn:SetText("Whitelist")
  WhitelistBtn:SetPoint("BOTTOM")
  WhitelistBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then 
      GR.CurrList = "Whitelist"
      GR:ToggleSettingsListTab()
      Settings.BlacklistScroll:Hide()
      Settings.Blacklist:Hide()
      Settings.RivalsScroll:Hide()
      Settings.Rivals:Hide()
      Settings.WhitelistScroll:Show()
      Settings.Whitelist:Show()
    end
  end)
  
  -- RivalBtn
  Settings.Listtabs.RivalsBtn = CreateFrame("Button", "RivalsBtn", Listtabs, "PanelTopTabButtonTemplate")
  local RivalsBtn = Settings.Listtabs.RivalsBtn
  RivalsBtn.LeftActive:Hide()
  RivalsBtn.MiddleActive:Hide()
  RivalsBtn.RightActive:Hide()
  RivalsBtn:SetText("Rivals")
  RivalsBtn:SetPoint("BOTTOMRIGHT")
  RivalsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then 
      GR.CurrList = "Rivals"
      GR:ToggleSettingsListTab()
      Settings.WhitelistScroll:Hide()
      Settings.Whitelist:Hide()
      Settings.BlacklistScroll:Hide()
      Settings.Blacklist:Hide()
      Settings.RivalsScroll:Show()
      Settings.Rivals:Show()
    end
  end)
end

function GR:CreateListControls()
  local Settings = GR_GUI.Main.Tab4.Settings
  local Lists = Settings.Lists
  
  -- Add to list
  Lists.AddInput = CreateFrame("Editbox", AddInput, Lists, "InputBoxInstructionsTemplate")
  Lists.AddInput:SetFontObject("ChatFontNormal")
  Lists.AddInput:SetMultiLine(false)
  Lists.AddInput:SetAutoFocus(false)

  Lists.AddInput.Btn = CreateFrame("Button", AddBtn, Lists.AddInput, "UIPanelButtonTemplate")
  local AddBtn = Lists.AddInput.Btn
  AddBtn:SetText("Add")
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

  -- Delete from list
  Lists.AddInput.Delete = CreateFrame("Button", Delete, Lists.AddInput, "UIPanelButtonTemplate")
  local Delete = Lists.AddInput.Delete
  Delete:SetText("Delete")
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
end

-- Resize
function GR:SizeSettings()
  local Main = GR_GUI.Main
  local Tab4 = Main.Tab4

  -- Main Settings Window & Scroll
  Tab4:SetPoint("TOP", 0, -50 * Main.YRatio)
  Tab4:SetSize(250 * Main.XRatio, 200 * Main.YRatio)
  Tab4.SettingsScroll:SetPoint("TOP", -9 * Main.XRatio, -20 * Main.YRatio)
  Tab4.SettingsScroll:SetSize(305 * Main.XRatio, 305 * Main.YRatio)
  local Settings = Tab4.Settings
  Settings:SetPoint("TOPLEFT", 0 * Main.XRatio, 0 * Main.YRatio)
  Settings:SetSize(300 * Main.XRatio, 520 * Main.YRatio)

  -- Settings
  -- Alpha SLider
  Settings.AlphaFS:SetPoint("TOPLEFT", 10, -0 * Main.YRatio)
  Settings.AlphaFS:SetTextScale(1 * Main.ScreenRatio)
  Settings.AlphaSlider:SetPoint("TOPRIGHT", 0, -0 * Main.YRatio)
  Settings.AlphaSlider:SetSize(226 * Main.XRatio, 15 * Main.YRatio)
  -- Battle Net Friends
  Settings.BNString:SetPoint("TOPLEFT", 40, -25 * Main.YRatio)
  Settings.BNString:SetTextScale(1 * Main.ScreenRatio)
  Settings.BNBtn:SetPoint("TOPLEFT", 10, -20 * Main.YRatio)
  Settings.BNBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Moveable Challenge Button
  Settings.MoveableChalString:SetPoint("TOPLEFT", 66, -50 * Main.YRatio)
  Settings.MoveableChalString:SetTextScale(1 * Main.ScreenRatio)
  Settings.MoveableChalBtn:SetPoint("TOPLEFT", 10, -45 * Main.YRatio)
  Settings.MoveableChalBtn:SetSize(50 * Main.XRatio, 25 * Main.YRatio)
  Settings.MoveableChalBtnString:SetPoint("CENTER")
  Settings.MoveableChalBtnString:SetTextScale(1 * Main.ScreenRatio)
  -- Hide Challenge In Combat
  Settings.CombatString:SetPoint("TOPLEFT", 40, -75 * Main.YRatio)
  Settings.CombatString:SetTextScale(1 * Main.ScreenRatio)
  Settings.CombatBtn:SetPoint("TOPLEFT", 10, -70 * Main.YRatio)
  Settings.CombatBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Show Challenge As Message
  Settings.ShowChallengeString:SetPoint("TOPLEFT", 40, -100 * Main.YRatio)
  Settings.ShowChallengeString:SetTextScale(1 * Main.ScreenRatio)
  Settings.ShowChallengeBtn:SetPoint("TOPLEFT", 10, -95 * Main.YRatio)
  Settings.ShowChallengeBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Disable Incoming Challenge
  Settings.IncString:SetPoint("TOPLEFT", 40, -125 * Main.YRatio)
  Settings.IncString:SetTextScale(1 * Main.ScreenRatio)
  Settings.IncBtn:SetPoint("TOPLEFT", 10, -120 * Main.YRatio)
  Settings.IncBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Whitelist Checkbox
  Settings.WhitelistString:SetPoint("TOPLEFT", 40, -150 * Main.YRatio)
  Settings.WhitelistString:SetTextScale(1 * Main.ScreenRatio)
  Settings.WhitelistBtn:SetPoint("TOPLEFT", 10, -145 * Main.YRatio)
  Settings.WhitelistBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Whitelist Guild
  Settings.WhiteGuildString:SetPoint("TOPLEFT", 40, -175 * Main.YRatio)
  Settings.WhiteGuildString:SetTextScale(1 * Main.ScreenRatio)
  Settings.WhiteGuildBtn:SetPoint("TOPLEFT", 10, -170 * Main.YRatio)
  Settings.WhiteGuildBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  -- Whitelist Party
  Settings.WhitePartyString:SetPoint("TOPLEFT", 40, -200 * Main.YRatio)
  Settings.WhitePartyString:SetTextScale(1 * Main.ScreenRatio)
  Settings.WhitePartyBtn:SetPoint("TOPLEFT", 10, -195 * Main.YRatio)
  Settings.WhitePartyBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  --
  Settings.WhiteFriendsString:SetPoint("TOPLEFT", 40, -225 * Main.YRatio)
  Settings.WhiteFriendsString:SetTextScale(1 * Main.ScreenRatio)
  Settings.WhiteFriendsBtn:SetPoint("TOPLEFT", 10, -220 * Main.YRatio)
  Settings.WhiteFriendsBtn:SetSize(25 * Main.XRatio, 25 * Main.YRatio)

  GR:SizeSettingsList()
  GR:SizeSettingsTabs()
  GR:SizeListControls()
end

function GR:SizeSettingsList()
  local Main = GR_GUI.Main
  local Settings = Main.Tab4.Settings
  local Lists = Settings.Lists
  Lists:SetPoint("TOP", 0, -330 * Main.YRatio)
  Lists:SetSize(244 * Main.XRatio, 180 * Main.YRatio)

  -- BlacklistScroll
  local BlacklistScroll = Settings.BlacklistScroll
  BlacklistScroll:SetSize(244 * Main.XRatio, 180 * Main.YRatio)
  local BlacklistBorder = BlacklistScroll.Border
  BlacklistBorder:SetPoint("TOPLEFT", BlacklistScroll, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  BlacklistBorder:SetPoint("BOTTOMRIGHT", BlacklistScroll, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)
  -- WhitelistScroll
  local WhitelistScroll = Settings.WhitelistScroll
  WhitelistScroll:SetSize(244 * Main.XRatio, 180 * Main.YRatio)
  local WhitelistBorder = WhitelistScroll.Border 
  WhitelistBorder:SetPoint("TOPLEFT", WhitelistScroll, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  WhitelistBorder:SetPoint("BOTTOMRIGHT", WhitelistScroll, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)
  -- RivalsScroll
  local RivalsScroll = Settings.RivalsScroll
  RivalsScroll:SetSize(244 * Main.XRatio, 180 * Main.YRatio)
  local RivalsBorder = RivalsScroll.Border
  RivalsBorder:SetPoint("TOPLEFT", RivalsScroll, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  RivalsBorder:SetPoint("BOTTOMRIGHT", RivalsScroll, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)

  -- Blacklist
  local Blacklist = Settings.Blacklist
  Blacklist:SetSize(234 * Main.XRatio, 600 * Main.YRatio)
  for i,v in ipairs(Blacklist.Btns) do
    v:SetPoint("TOPLEFT", 0, i*-14)
    v:SetSize(300, 14)
  end

  -- Whitelist
  local Whitelist = Settings.Whitelist
  Whitelist:SetSize(234 * Main.XRatio, 600 * Main.YRatio)
  for i,v in ipairs(Whitelist.Btns) do
    v:SetPoint("TOPLEFT", 0, i*-14)
    v:SetSize(300, 14)
  end

  -- Rivals
  local Rivals = Settings.Rivals
  Rivals:SetSize(234 * Main.XRatio, 600 * Main.YRatio)
  for i,v in ipairs(Rivals.Btns) do
    v:SetPoint("TOPLEFT", 0, i*-14)
    v:SetSize(300, 14)
  end
end

function GR:SizeSettingsTabs()
  local Main = GR_GUI.Main
  local Listtabs = Main.Tab4.Settings.Listtabs
  Listtabs:SetPoint("TOP", 0, 28 * Main.YRatio)
  Listtabs:SetSize(250 * Main.XRatio, 25 * Main.YRatio)
  -- BlacklistBtn
  local BlacklistBtn = Listtabs.BlacklistBtn
  BlacklistBtn:SetSize(66 * Main.XRatio, 18)
  -- WhitelistBtn
  local WhitelistBtn = Listtabs.WhitelistBtn
  WhitelistBtn:SetSize(66 * Main.XRatio, 18)
  -- RivalBtn
  local RivalsBtn = Listtabs.RivalsBtn
  RivalsBtn:SetSize(66 * Main.XRatio, 18)
end

function GR:SizeListControls()
  local Main = GR_GUI.Main
  local Lists = Main.Tab4.Settings.Lists
  
  Lists.AddInput:SetPoint("TOPLEFT", -4 * Main.XRatio, 62 * Main.YRatio)
  Lists.AddInput:SetSize(150 * Main.XRatio, 30 * Main.YRatio)
  local AddBtn = Lists.AddInput.Btn
  AddBtn:SetPoint("CENTER", 108 * Main.XRatio, 0 * Main.YRatio)
  AddBtn:SetSize(60 * Main.XRatio, 25 * Main.YRatio)

  local Delete = Lists.AddInput.Delete
  Delete:SetPoint("CENTER", 170 * Main.XRatio, 0 * Main.YRatio)
  Delete:SetSize(60 * Main.XRatio, 25 * Main.YRatio)
end

-- functionality
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
      Btn.fs = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
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

function GR:ToggleSettingsListTab()
  local tabIndex = GR.CurrList
  local tabs = GR_GUI.Main.Tab4.Settings.Listtabs
  
  local function normal(tab)
    tab.Left:Show()
    tab.LeftActive:Hide()
    tab.LeftHighlight:Hide()
    tab.Middle:Show()
    tab.MiddleActive:Hide()
    tab.MiddleHighlight:Hide()
    tab.Right:Show()
    tab.RightActive:Hide()
    tab.RightHighlight:Hide() 
    tab.Text:SetPoint("CENTER", 0, 0)
    tab.Text:SetTextColor(1,.82,0,1)
  end

  local function active(tab)
    tab.Left:Hide()
    tab.LeftActive:Show()
    tab.LeftHighlight:Hide()
    tab.Middle:Hide()
    tab.MiddleActive:Show()
    tab.MiddleHighlight:Hide()
    tab.Right:Hide()
    tab.RightActive:Show()
    tab.RightHighlight:Hide() 
    tab.Text:SetPoint("CENTER", 0, 0)
    tab.Text:SetTextColor(1,1,1,1)
  end

  local function highlight(tab)
    tab.Left:Hide()
    tab.LeftActive:Hide()
    tab.LeftHighlight:Show()
    tab.Middle:Hide()
    tab.MiddleActive:Hide()
    tab.MiddleHighlight:Show()
    tab.Right:Hide()
    tab.RightActive:Hide()
    tab.RightHighlight:Show() 
  end

  if (tabIndex == "Blacklist") then
    active(tabs.BlacklistBtn)
    normal(tabs.WhitelistBtn)
    normal(tabs.RivalsBtn)
  end
  if (tabIndex == "Whitelist") then
    normal(tabs.BlacklistBtn)
    active(tabs.WhitelistBtn)
    normal(tabs.RivalsBtn)
  end
  if (tabIndex == "Rivals") then
    normal(tabs.BlacklistBtn)
    normal(tabs.WhitelistBtn)
    active(tabs.RivalsBtn)
  end
end
