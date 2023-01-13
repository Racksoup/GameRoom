function GR:CreateMultiGames()
  local Main = GR_GUI.Main
  Main.Tab3 = CreateFrame("Frame", Tab3, Main)
  local Tab3 = Main.Tab3

  --Nav
  Tab3.Nav = CreateFrame("Frame", Nav, Tab3)
  local Nav = Tab3.Nav
  Nav.SoloBtn = CreateFrame("Button", SoloBtn, Nav, "UIPanelButtonTemplate")
  local SoloBtn = Nav.SoloBtn
  SoloBtn.FS = SoloBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SoloFS = SoloBtn.FS
  SoloFS:SetText("Single Player")
  SoloFS:SetTextColor(.8,.8,.8, 1)
  SoloBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.tab = 2
      GR:TabSelect()
    end
  end)
  Nav.SettingsBtn = CreateFrame("Button", SettingsBtn, Nav, "UIPanelButtonTemplate")
  local SettingsBtn = Nav.SettingsBtn
  SettingsBtn.FS = SettingsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SettingsFS = SettingsBtn.FS
  SettingsFS:SetText("Settings")
  SettingsFS:SetTextColor(.8,.8,.8, 1)
  SettingsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.tab = 4
      GR:TabSelect()
    end
  end)
  
  -- Game Buttons
  Tab3.MultiGames = CreateFrame("Frame", MultiGames, Tab3)
  local MultiGames = Tab3.MultiGames
  MultiGames.TicTacToeBtn = CreateFrame("Button", TicTacToeBtn, MultiGames, "UIPanelButtonTemplate")
  local TicTacToeBtn = MultiGames.TicTacToeBtn
  TicTacToeBtn.FS = TicTacToeBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local TicTacToeFS = TicTacToeBtn.FS
  TicTacToeFS:SetTextColor(.8,.8,.8, 1)
  TicTacToeFS:SetText("TicTacToe")
  TicTacToeBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Tictactoe"
      Tab3.Invite.Header:SetText("Invite Player to Play TicTacToe")
      Tab3.Invite:Show()
      Tab3.Invite.Tab:Show()
    end
  end)
  MultiGames.BattleshipsBtn = CreateFrame("Button", BattleshipsBtn, MultiGames, "UIPanelButtonTemplate")
  local BattleshipsBtn = MultiGames.BattleshipsBtn
  BattleshipsBtn.FS = BattleshipsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local BattleshipsFS = BattleshipsBtn.FS
  BattleshipsFS:SetTextColor(.8,.8,.8, 1)
  BattleshipsFS:SetText("Battleships")
  BattleshipsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Battleships"
      Tab3.Invite.Header:SetText("Invite Player to Play Battleships")
      Tab3.Invite:Show()
      Tab3.Invite.Tab:Show()
    end
  end)

  Tab3:Hide()

  GR:CreateMultiInvite()
end

-- Create
function GR:CreateMultiInvite()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  Tab3.Invite = CreateFrame("Frame", Invite, Tab3)
  local Invite = Tab3.Invite

  Invite.Header = Invite:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  Invite.Header:SetTextColor(.8,.8,.8, 1)

  Invite.SendBtn = CreateFrame("Button", SendBtn, Invite, "UIPanelButtonTemplate")
  Invite.SendBtn.FS = Invite.SendBtn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Invite.SendBtn.FS:SetPoint("CENTER")
  Invite.SendBtn.FS:SetTextColor(.8,.8,.8, 1)
  Invite.SendBtn:SetScript("OnClick", function(self, button, down) 
    GR:SendGameInvite(self, button, down)
  end)

  GR:CreateInviteTab()
  GR:CreateInviteFriends()
  GR:CreateInviteParty()
  GR:CreateInviteZone()

  GR:SizeMultiGames()
end

function GR:CreateInviteFriends()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.FriendsScrollFrame = CreateFrame("ScrollFrame", FriendsScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local FriendsScrollFrame = Invite.FriendsScrollFrame
  FriendsScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  
  Invite.Friends = CreateFrame("Frame", Friends, FriendsScrollFrame)
  local Friends = Invite.Friends
  FriendsScrollFrame:SetScrollChild(Friends)
  FriendsScrollFrame.FS = FriendsScrollFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  FriendsScrollFrame.FS:SetText("Friends")
  
  Invite.Friends.Btns = {}
  for i = 1, 100, 1 do
    local Btn = CreateFrame("Button", nil, Friends)
    Btn:Hide()
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("TOPLEFT")
    table.insert(Invite.Friends.Btns, Btn)
  end
end

function GR:CreateInviteParty()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.PartyScrollFrame = CreateFrame("ScrollFrame", PartyScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local PartyScrollFrame = Invite.PartyScrollFrame
  PartyScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  
  Invite.Party = CreateFrame("Frame", Party, PartyScrollFrame)
  local Party = Invite.Party
  PartyScrollFrame:SetScrollChild(Party)
  PartyScrollFrame.FS = PartyScrollFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  PartyScrollFrame.FS:SetText("Party & Guild")
  
  Invite.Party.Btns = {}
  for i = 1, 100, 1 do
    local Btn = CreateFrame("Button", nil, Party)
    Btn:Hide()
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("TOPLEFT")
    table.insert(Invite.Party.Btns, Btn)
  end

  -- sends Register Party message on login
  local GroupType = "party"
  if IsInRaid() then GroupType = "raid" end
  local NumParty = GetNumGroupMembers()
  for i = 1, NumParty, 1 do
    local PlayerIndex = GroupType .. tostring(i)
    local PartyMember = UnitName(PlayerIndex)
    local PlayerName = UnitName("player")
    if (type(PartyMember) == "string"  and UnitIsConnected(PlayerIndex)) then
      GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, "PARTY")
    end
  end
  if (IsInGuild()) then
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Guild, " .. UnitName("player"), "GUILD")
  end

  PartyScrollFrame:Hide()
end

function GR:CreateInviteZone()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite
  
  Invite.ZoneScrollFrame = CreateFrame("ScrollFrame", ZoneScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local ZoneScrollFrame = Invite.ZoneScrollFrame
  ZoneScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  
  Invite.Zone = CreateFrame("Frame", Zone, ZoneScrollFrame)
  local Zone = Invite.Zone
  ZoneScrollFrame:SetScrollChild(Zone)
  ZoneScrollFrame.FS = ZoneScrollFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  ZoneScrollFrame.FS:SetText("Zone")
  
  Invite.Zone.Btns = {}
  for i = 1, 100, 1 do
    local Btn = CreateFrame("Button", nil, Zone)
    Btn:Hide()
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("TOPLEFT")
    table.insert(Invite.Zone.Btns, Btn)
  end

  local function RegisterYell()
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. UnitName("player"), "YELL")
    C_Timer.After(5, function() 
      RegisterYell()
    end)
  end
  RegisterYell()

  ZoneScrollFrame:Hide()
end

function GR:CreateInviteTab()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  Tab3.Invite.Tab = CreateFrame("Frame", Tab, Tab3.Invite)
  local Tab = Tab3.Invite.Tab

  Tab.Friends = CreateFrame("Button", FriendsBtn, Tab, "UIPanelButtonTemplate")
  Tab.Friends:SetPoint("TOPLEFT")
  Tab.Friends.FS = Tab.Friends:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Tab.Friends.FS:SetPoint("CENTER")
  Tab.Friends.FS:SetTextColor(.8,.8,.8, 1)
  Tab.Friends.FS:SetText("Friends")
  Tab.Party = CreateFrame("Button", FriendsBtn, Tab, "UIPanelButtonTemplate")
  Tab.Party:SetPoint("TOP")
  Tab.Party.FS = Tab.Party:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Tab.Party.FS:SetPoint("CENTER")
  Tab.Party.FS:SetTextColor(.8,.8,.8, 1)
  Tab.Party.FS:SetText("Party")
  Tab.Zone = CreateFrame("Button", FriendsBtn, Tab, "UIPanelButtonTemplate")
  Tab.Zone:SetPoint("TOPRIGHT")
  Tab.Zone.FS = Tab.Zone:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Tab.Zone.FS:SetPoint("CENTER")
  Tab.Zone.FS:SetTextColor(.8,.8,.8, 1)
  Tab.Zone.FS:SetText("Zone")
  
  Tab.Friends:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Tab3.Invite.FriendsScrollFrame:Show()
      Tab3.Invite.PartyScrollFrame:Hide()
      Tab3.Invite.ZoneScrollFrame:Hide()
      Tab3.Invite.SendBtn:Hide()
    end
  end)
  
  Tab.Party:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Tab3.Invite.FriendsScrollFrame:Hide()
      Tab3.Invite.PartyScrollFrame:Show()
      Tab3.Invite.ZoneScrollFrame:Hide()
      Tab3.Invite.SendBtn:Hide()
    end
  end)
  
  Tab.Zone:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Tab3.Invite.FriendsScrollFrame:Hide()
      Tab3.Invite.PartyScrollFrame:Hide()
      Tab3.Invite.ZoneScrollFrame:Show()
      Tab3.Invite.SendBtn:Hide()

      GR:InviteSearchZone()
    end
  end)

end

-- Resize
function GR:SizeMultiGames()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3
  Tab3:SetPoint("TOP", 0, -50 * Main.YRatio)
  Tab3:SetSize(250 * Main.XRatio, 200 * Main.YRatio)
  
  -- Nav
  local Nav = Tab3.Nav
  Nav:SetPoint("TOP", 0, 0)
  Nav:SetSize(240 * Main.XRatio, 40 * Main.YRatio)
  local SoloBtn = Nav.SoloBtn
  SoloBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -5 * Main.YRatio)
  SoloBtn:SetSize(110 * Main.XRatio, 30 * Main.YRatio)
  local SoloFS = SoloBtn.FS
  SoloFS:SetPoint("CENTER", 0, 0)
  SoloFS:SetTextScale(1.3 * Main.ScreenRatio)
  local SettingsBtn = Nav.SettingsBtn
  SettingsBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -5 * Main.YRatio)
  SettingsBtn:SetSize(110 * Main.XRatio, 30 * Main.YRatio)
  local SettingsFS = SettingsBtn.FS
  SettingsFS:SetPoint("CENTER", 0, 0)
  SettingsFS:SetTextScale(1.3 * Main.ScreenRatio)

  -- Game Buttons
  local MultiGames = Tab3.MultiGames
  MultiGames:SetPoint("TOP", 0 * Main.XRatio, -75 * Main.YRatio)
  MultiGames:SetSize(250 * Main.XRatio, 100 * Main.YRatio)
  local TicTacToeBtn = MultiGames.TicTacToeBtn
  TicTacToeBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -5 * Main.YRatio)
  TicTacToeBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local TicTacToeFS = TicTacToeBtn.FS
  TicTacToeFS:SetPoint("CENTER", 0, 0)
  TicTacToeFS:SetTextScale(1.4 * Main.ScreenRatio)
  local BattleshipsBtn = MultiGames.BattleshipsBtn
  BattleshipsBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -5 * Main.YRatio)
  BattleshipsBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local BattleshipsFS = BattleshipsBtn.FS
  BattleshipsFS:SetPoint("CENTER", 0, 0)
  BattleshipsFS:SetTextScale(1.4 * Main.ScreenRatio)

  GR:SizeInviteTab()
  GR:SizeMultiInvite()
  GR:SizeInviteFriends()
  GR:SizeInviteParty()
  GR:SizeInviteZone()
end

function GR:SizeMultiInvite()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  local Invite = Tab3.Invite
  Invite:SetPoint("TOP", 0, -130 * Main.YRatio)
  Invite:SetSize(250 * Main.XRatio, 210 * Main.YRatio)

  Invite.Header:SetPoint("TOP", 0, 0)
  Invite.Header:SetTextScale(1.1 * Main.ScreenRatio)

  Invite.SendBtn:SetPoint("BOTTOM")
  Invite.SendBtn:SetSize(268 * Main.XRatio, 50 * Main.YRatio)
  Invite.SendBtn.FS:SetTextScale(2 * Main.ScreenRatio)
end

function GR:SizeInviteFriends()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.FriendsScrollFrame:SetPoint("TOP", 0, -55 * Main.YRatio)
  Invite.FriendsScrollFrame:SetSize(200 * Main.XRatio, 100 * Main.YRatio)
  Invite.Friends:SetSize(200 * Main.XRatio, 700 * Main.YRatio)
  Invite.FriendsScrollFrame.FS:SetPoint("TOP", 0, 15 * Main.YRatio)

  for i = 1, #Invite.Friends.Btns, 1 do
    Invite.Friends.Btns[i]:SetPoint("TOPLEFT", 0, (i*-14) * Main.YRatio)
    Invite.Friends.Btns[i]:SetSize(200 * Main.XRatio, 14 * Main.YRatio)
    Invite.Friends.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteParty()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.PartyScrollFrame:SetPoint("TOP", 0, -55 * Main.YRatio)
  Invite.PartyScrollFrame:SetSize(200 * Main.XRatio, 100 * Main.YRatio)
  Invite.Party:SetSize(200 * Main.XRatio, 700 * Main.YRatio)
  Invite.PartyScrollFrame.FS:SetPoint("TOP", 0, 15 * Main.YRatio)
  
  for i = 1, #Invite.Party.Btns, 1 do
    Invite.Party.Btns[i]:SetPoint("TOPLEFT", 0, (i*-14) * Main.YRatio)
    Invite.Party.Btns[i]:SetSize(200 * Main.XRatio, 14 * Main.YRatio)
    Invite.Party.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteZone()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.ZoneScrollFrame:SetPoint("TOP", 0, -55 * Main.YRatio)
  Invite.ZoneScrollFrame:SetSize(200 * Main.XRatio, 100 * Main.YRatio)
  Invite.Zone:SetSize(200 * Main.XRatio, 700 * Main.YRatio)
  Invite.ZoneScrollFrame.FS:SetPoint("TOP", 0, 15 * Main.YRatio)

  for i = 1, #Invite.Zone.Btns, 1 do
    Invite.Zone.Btns[i]:SetPoint("TOP", 0, (i*-14) * Main.YRatio)
    Invite.Zone.Btns[i]:SetSize(200 * Main.XRatio, 14 * Main.YRatio)
    Invite.Zone.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteTab()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  local Tab = Tab3.Invite.Tab
  Tab:SetPoint("TOP", 0, - 15 * Main.YRatio)
  Tab:SetSize(220 * Main.XRatio, 40 * Main.YRatio)

  Tab.Friends:SetSize(70 * Main.XRatio, 20 * Main.YRatio)
  Tab.Friends.FS:SetTextScale(1 * Main.ScreenRatio) 
  Tab.Party:SetSize(70 * Main.XRatio, 20 * Main.YRatio)
  Tab.Party.FS:SetTextScale(1 * Main.ScreenRatio) 
  Tab.Zone:SetSize(70 * Main.XRatio, 20 * Main.YRatio)
  Tab.Zone.FS:SetTextScale(1 * Main.ScreenRatio) 
end
