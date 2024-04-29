function GR:CreateMultiGames()
  local Main = GR_GUI.Main
  Main.Tab3 = CreateFrame("Frame", Tab3, Main)
  local Tab3 = Main.Tab3
  
  Tab3:Hide()
  
  GR:CreateGameButtons()
  GR:CreateMultiInvite()
end

-- Create
function GR:CreateGameButtons()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3
  -- Game Buttons
  Tab3.GameButtons = CreateFrame("Frame", "GameButtons", Tab3)
  local GameButtons = Tab3.GameButtons

  Tab3.InviteText = Tab3:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Tab3.InviteText:SetText("Challenge ...")

  GameButtons.TicTacToeBtn = CreateFrame("Button", "TicTacToeBtn", GameButtons, "UIPanelButtonTemplate")
  local TicTacToeBtn = GameButtons.TicTacToeBtn
  TicTacToeBtn.FS = TicTacToeBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local TicTacToeFS = TicTacToeBtn.FS
  TicTacToeFS:SetTextColor(.8,.8,.8, 1)
  TicTacToeFS:SetText("TicTacToe")
  TicTacToeBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Tictactoe"
      Tab3.InviteText:SetText("Challenged " .. GR.Target .. " To " .. GR.GameType)
      Tab3.GameButtons:Hide()
      GR:SendGameInvite(self, button, down)
    end
  end)

  GameButtons.BattleshipsBtn = CreateFrame("Button", "BattleshipsBtn", GameButtons, "UIPanelButtonTemplate")
  local BattleshipsBtn = GameButtons.BattleshipsBtn
  BattleshipsBtn.FS = BattleshipsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local BattleshipsFS = BattleshipsBtn.FS
  BattleshipsFS:SetTextColor(.8,.8,.8, 1)
  BattleshipsFS:SetText("Battleships")
  BattleshipsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Battleships"
      Tab3.InviteText:SetText("Challenged " .. GR.Target .. " To " .. GR.GameType)
      Tab3.GameButtons:Hide()
      GR:SendGameInvite(self, button, down)
    end
  end)
end

function GR:CreateMultiInvite()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  Tab3.Invite = CreateFrame("Frame", Invite, Tab3)
  local Invite = Tab3.Invite
  Invite.ActiveTab = "server"

  GR:CreateInviteTab()
  GR:CreateInviteServer()
  GR:CreateInviteFriends()
  GR:CreateInviteParty()
  GR:CreateInviteZone()

  GR:SizeMultiGames()
end

function GR:CreateInviteServer()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.ServerScrollFrame = CreateFrame("ScrollFrame", ServerScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local ServerScrollFrame = Invite.ServerScrollFrame
  ServerScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  ServerScrollFrame.Border = CreateFrame("Frame", "ServerBorder", ServerScrollFrame, "ThinBorderTemplate")
  
  Invite.Server = CreateFrame("Frame", Server, ServerScrollFrame)
  local Server = Invite.Server
  ServerScrollFrame:SetScrollChild(Server)
  
  Invite.Server.Btns = {}
  for i = 1, 100, 1 do
    local Btn = CreateFrame("Button", nil, Server)
    Btn:Hide()
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("TOPLEFT")
    table.insert(Invite.Server.Btns, Btn)
  end

  ServerScrollFrame:Hide()
end

function GR:CreateInviteFriends()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.FriendsScrollFrame = CreateFrame("ScrollFrame", FriendsScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local FriendsScrollFrame = Invite.FriendsScrollFrame
  FriendsScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  FriendsScrollFrame.Border = CreateFrame("Frame", "FriendsBorder", FriendsScrollFrame, "ThinBorderTemplate")
  
  Invite.Friends = CreateFrame("Frame", Friends, FriendsScrollFrame)
  local Friends = Invite.Friends
  FriendsScrollFrame:SetScrollChild(Friends)
  
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
  PartyScrollFrame.Border = CreateFrame("Frame", "PartyBorder", PartyScrollFrame, "ThinBorderTemplate")
  
  Invite.Party = CreateFrame("Frame", Party, PartyScrollFrame)
  local Party = Invite.Party
  PartyScrollFrame:SetScrollChild(Party)
  
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
      GR:SendCommMessage("GameRoom_Reg", "Register Party, " .. PlayerName, "PARTY")
    end
  end
  if (IsInGuild()) then
    GR:SendCommMessage("GameRoom_Reg", "Register Guild, " .. UnitName("player"), "GUILD")
  end

  PartyScrollFrame:Hide()
end

function GR:CreateInviteZone()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite
  
  Invite.ZoneScrollFrame = CreateFrame("ScrollFrame", ZoneScrollFrame, Invite, "UIPanelScrollFrameTemplate")
  local ZoneScrollFrame = Invite.ZoneScrollFrame
  ZoneScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
  ZoneScrollFrame.Border = CreateFrame("Frame", "ZoneBorder", ZoneScrollFrame, "ThinBorderTemplate")
  
  Invite.Zone = CreateFrame("Frame", Zone, ZoneScrollFrame)
  local Zone = Invite.Zone
  ZoneScrollFrame:SetScrollChild(Zone)
  
  Invite.Zone.Btns = {}
  for i = 1, 100, 1 do
    local Btn = CreateFrame("Button", nil, Zone)
    Btn:Hide()
    Btn.FS = Btn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Btn.FS:SetPoint("TOPLEFT")
    table.insert(Invite.Zone.Btns, Btn)
  end

  local function RegisterYell()
    GR:SendCommMessage("GameRoom_Reg", "Register Zone, " .. UnitName("player"), "YELL")
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
  local Invite = Tab3.Invite

  Invite.Tab = CreateFrame("Frame", "InviteTabs", Invite)
  local Tab = Invite.Tab

  -- Server
  Tab.Server = CreateFrame("Button", "ServerTab", Tab, "PanelTopTabButtonTemplate")
  Tab.Server.LeftActive:Hide()
  Tab.Server.MiddleActive:Hide()
  Tab.Server.RightActive:Hide()
  Tab.Server:SetText("Server")
  
  -- Friends
  Tab.Friends = CreateFrame("Button", "FriendsTab", Tab, "PanelTopTabButtonTemplate")
  Tab.Friends.LeftActive:Hide()
  Tab.Friends.MiddleActive:Hide()
  Tab.Friends.RightActive:Hide()
  Tab.Friends:SetText("Friends")
  
  -- Party
  Tab.Party = CreateFrame("Button", "PartyTab", Tab, "PanelTopTabButtonTemplate")
  Tab.Party.LeftActive:Hide()
  Tab.Party.MiddleActive:Hide()
  Tab.Party.RightActive:Hide()
  Tab.Party:SetText("Party")
  
  -- Zone
  Tab.Zone = CreateFrame("Button", "ZoneTab", Tab, "PanelTopTabButtonTemplate")
  Tab.Zone.LeftActive:Hide()
  Tab.Zone.MiddleActive:Hide()
  Tab.Zone.RightActive:Hide()
  Tab.Zone:SetText("Zone")

  
  Tab.Server:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Invite.ServerScrollFrame:Show()
      Invite.FriendsScrollFrame:Hide()
      Invite.PartyScrollFrame:Hide()
      Invite.ZoneScrollFrame:Hide()
      Invite.ActiveTab = "server"
      GR:ToggleInviteTab()
    end
  end)

  Tab.Friends:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Invite.ServerScrollFrame:Hide()
      Invite.FriendsScrollFrame:Show()
      Invite.PartyScrollFrame:Hide()
      Invite.ZoneScrollFrame:Hide()
      Invite.ActiveTab = "friends"
      GR:ToggleInviteTab()
    end
  end)
  
  Tab.Party:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Invite.ServerScrollFrame:Hide()
      Invite.FriendsScrollFrame:Hide()
      Invite.PartyScrollFrame:Show()
      Invite.ZoneScrollFrame:Hide()
      Invite.ActiveTab = "party"
      GR:ToggleInviteTab()
    end
  end)
  
  Tab.Zone:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Target = nil
      Invite.ServerScrollFrame:Hide()
      Invite.FriendsScrollFrame:Hide()
      Invite.PartyScrollFrame:Hide()
      Invite.ZoneScrollFrame:Show()
      Invite.ActiveTab = "zone"
      GR:ToggleInviteTab()

      GR:InviteSearchZone()
    end
  end)
end

-- Resize
function GR:SizeMultiGames()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3
  Tab3:SetPoint("TOP", 0, -24 * Main.YRatio)
  Tab3:SetSize(250 * Main.XRatio, 400 * Main.YRatio)
  Tab3.InviteText:SetPoint("TOP", 0, -200 * Main.YRatio)


  GR:SizeGameButtons()
  GR:SizeInviteTab()
  GR:SizeMultiInvite()
  GR:SizeInviteServer()
  GR:SizeInviteFriends()
  GR:SizeInviteParty()
  GR:SizeInviteZone()
end

function GR:SizeGameButtons()
  local Main = GR_GUI.Main
  local GameButtons = Main.Tab3.GameButtons
  
  GameButtons:SetPoint("TOP", 0 * Main.XRatio, -200 * Main.YRatio)
  GameButtons:SetSize(255 * Main.XRatio, 100 * Main.YRatio)
  local TicTacToeBtn = GameButtons.TicTacToeBtn
  TicTacToeBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -20 * Main.YRatio)
  TicTacToeBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local TicTacToeFS = TicTacToeBtn.FS
  TicTacToeFS:SetPoint("CENTER", 0, 0)
  TicTacToeFS:SetTextScale(1 * Main.ScreenRatio)
  local BattleshipsBtn = GameButtons.BattleshipsBtn
  BattleshipsBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -20 * Main.YRatio)
  BattleshipsBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local BattleshipsFS = BattleshipsBtn.FS
  BattleshipsFS:SetPoint("CENTER", 0, 0)
  BattleshipsFS:SetTextScale(1 * Main.ScreenRatio)
end

function GR:SizeMultiInvite()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3
  local Invite = Tab3.Invite

  Invite:SetPoint("TOP", 0, -30 * Main.YRatio)
  Invite:SetSize(250 * Main.XRatio, 210 * Main.YRatio)
end

function GR:SizeInviteServer()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.ServerScrollFrame:SetPoint("TOP", -7 * Main.XRatio, -38 * Main.YRatio)
  Invite.ServerScrollFrame:SetSize(247 * Main.XRatio, 100 * Main.YRatio)
  Invite.Server:SetSize(247 * Main.XRatio, 700 * Main.YRatio)

  local Border = Invite.ServerScrollFrame.Border
  Border:SetPoint("TOPLEFT", Invite.ServerScrollFrame, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  Border:SetPoint("BOTTOMRIGHT", Invite.ServerScrollFrame, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)

  for i = 1, #Invite.Server.Btns, 1 do
    Invite.Server.Btns[i]:SetPoint("TOPLEFT", 0, (i*-14) * Main.YRatio)
    Invite.Server.Btns[i]:SetSize(247 * Main.XRatio, 14 * Main.YRatio)
    Invite.Server.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteFriends()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.FriendsScrollFrame:SetPoint("TOP", -7 * Main.XRatio, -38 * Main.YRatio)
  Invite.FriendsScrollFrame:SetSize(247 * Main.XRatio, 100 * Main.YRatio)
  Invite.Friends:SetSize(247 * Main.XRatio, 700 * Main.YRatio)

  local Border = Invite.FriendsScrollFrame.Border
  Border:SetPoint("TOPLEFT", Invite.FriendsScrollFrame, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  Border:SetPoint("BOTTOMRIGHT", Invite.FriendsScrollFrame, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)

  for i = 1, #Invite.Friends.Btns, 1 do
    Invite.Friends.Btns[i]:SetPoint("TOPLEFT", 0, (i*-14) * Main.YRatio)
    Invite.Friends.Btns[i]:SetSize(247 * Main.XRatio, 14 * Main.YRatio)
    Invite.Friends.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteParty()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.PartyScrollFrame:SetPoint("TOP", -7 * Main.XRatio, -38 * Main.YRatio)
  Invite.PartyScrollFrame:SetSize(247 * Main.XRatio, 100 * Main.YRatio)
  Invite.Party:SetSize(247 * Main.XRatio, 700 * Main.YRatio)

  local Border = Invite.PartyScrollFrame.Border
  Border:SetPoint("TOPLEFT", Invite.PartyScrollFrame, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  Border:SetPoint("BOTTOMRIGHT", Invite.PartyScrollFrame, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)
  
  for i = 1, #Invite.Party.Btns, 1 do
    Invite.Party.Btns[i]:SetPoint("TOPLEFT", 0, (i*-14) * Main.YRatio)
    Invite.Party.Btns[i]:SetSize(247 * Main.XRatio, 14 * Main.YRatio)
    Invite.Party.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteZone()
  local Main = GR_GUI.Main
  local Invite = Main.Tab3.Invite

  Invite.ZoneScrollFrame:SetPoint("TOP", -7 * Main.XRatio, -38 * Main.YRatio)
  Invite.ZoneScrollFrame:SetSize(247 * Main.XRatio, 100 * Main.YRatio)
  Invite.Zone:SetSize(247 * Main.XRatio, 700 * Main.YRatio)

  local Border = Invite.ZoneScrollFrame.Border
  Border:SetPoint("TOPLEFT", Invite.ZoneScrollFrame, "TOPLEFT", -8 * Main.XRatio, 2 * Main.YRatio)
  Border:SetPoint("BOTTOMRIGHT", Invite.ZoneScrollFrame, "BOTTOMRIGHT", 24 * Main.XRatio, -2 * Main.YRatio)

  for i = 1, #Invite.Zone.Btns, 1 do
    Invite.Zone.Btns[i]:SetPoint("TOP", 0, (i*-14) * Main.YRatio)
    Invite.Zone.Btns[i]:SetSize(247 * Main.XRatio, 14 * Main.YRatio)
    Invite.Zone.Btns[i].FS:SetTextScale(1 * ((Main.XRatio + Main.YRatio) / 2))
  end
end

function GR:SizeInviteTab()
  local Main = GR_GUI.Main
  local Tab3 = Main.Tab3

  local Tab = Tab3.Invite.Tab
  Tab:SetPoint("TOP", 0, - 15 * Main.YRatio)
  Tab:SetSize(280 * Main.XRatio, 20 * Main.YRatio)

  Tab.Server:SetPoint("BOTTOMLEFT")
  Tab.Friends:SetPoint("BOTTOMLEFT", 70 * Main.XRatio, 0)
  Tab.Party:SetPoint("BOTTOMLEFT", 140 * Main.XRatio, 0)
  Tab.Zone:SetPoint("BOTTOMLEFT", 210 * Main.XRatio, 0)


  Tab.Server:SetSize(65 * Main.XRatio, 20)
  Tab.Friends:SetSize(65 * Main.XRatio, 20)
  Tab.Party:SetSize(65 * Main.XRatio, 20)
  Tab.Zone:SetSize(65 * Main.XRatio, 20)
end

function GR:ToggleInviteTab()
  local Invite = GR_GUI.Main.Tab3.Invite
  local tabIndex = Invite.ActiveTab

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

  if (tabIndex == "server") then
    active(Invite.Tab.Server)
    normal(Invite.Tab.Friends)
    normal(Invite.Tab.Party)
    normal(Invite.Tab.Zone)
  end
  if (tabIndex == "friends") then
    normal(Invite.Tab.Server)
    active(Invite.Tab.Friends)
    normal(Invite.Tab.Party)
    normal(Invite.Tab.Zone)
  end
  if (tabIndex == "party") then
    normal(Invite.Tab.Server)
    normal(Invite.Tab.Friends)
    active(Invite.Tab.Party)
    normal(Invite.Tab.Zone)
  end
  if (tabIndex == "zone") then
    normal(Invite.Tab.Server)
    normal(Invite.Tab.Friends)
    normal(Invite.Tab.Party)
    active(Invite.Tab.Zone)
  end

end