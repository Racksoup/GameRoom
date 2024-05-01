-- Author: Connor Rack
-- Git: https://github.com/Racksoup/GameRoom

GR = LibStub("AceAddon-3.0"):NewAddon("GameRoom", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0" )
L = LibStub("AceLocale-3.0"):GetLocale("GameRoomLocale")
GR_GUI = {}
local icon = LibStub("LibDBIcon-1.0")
local GR_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GR", {
  type = "data source",
  text = "GameRoom",
  icon = "interface/icons/inv_misc_ticket_tarot_maelstrom_01.blp",
  OnClick = function()
    if (GR_GUI.Main:IsVisible()) then 
      GR_GUI.Main:Hide()
    else 
      GR:UpdateFriendsList() 
      GR:ShowMain()
    end
  end,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("Game Room")
    tooltip:AddLine("|cFFCFCFCFShift-Click|r: Move Window")
  end,
})

local defaults = {
  realm = {
    minimap = { hide = false },
    HideInCombat = false,
    tab = 1,
    showBN = false,
    disableChallenges = false,
    showChallengeAsMsg = false,
    Xpos = 200,
    Ypos = -150,
    Point = "TOPLEFT",
    Blacklist = {},
    Whitelist = {},
    Rivals = {},
    onlyWhitelist = false,
    WhitelistGuild = false,
    WhitelistParty = false,
    WhitelistFriends = false
  }
}

-- Create
function GR:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("GameRoomDB", defaults, true)
  icon:Register("GameRoom", GR_LDB, self.db.realm.minimap)
  GR:RegisterChatCommand("gr", "OpenClose")

  -- Window Consts
  GR.Win = {}
  GR.Win.Const = {}
  GR.Win.Const.Tab1Width = 800
  GR.Win.Const.Tab1Height = 620
  GR.Win.Const.Tab1WidthSuika = 475
  GR.Win.Const.Tab1HeightSuika = 800
  GR.Win.Const.GameScreenWidth = 750
  GR.Win.Const.GameScreenHeight = 500
  GR.Win.Const.SuikaScreenWidth = 435
  GR.Win.Const.SuikaScreenHeight = 660
  GR.Win.Const.Tab2Width = 310
  GR.Win.Const.Tab2Height = 181
  GR.Win.Const.Tab3Width = 340
  GR.Win.Const.Tab3Height = 400
  GR.Win.Const.Tab4Width = 340
  GR.Win.Const.Tab4Height = 400

  -- Game Varibales
  GR.PlayerPos = nil
  GR.IsPlayerTurn = nil
  GR.GameOver = false
  GR.IsChallenged = false
  GR.PlayerName = UnitName("player")
  GR.ChannelNumber = nil

  -- Retail or Classic
  version, build, datex, tocversion = GetBuildInfo()
  if (tocversion > 90000) then 
    GR.Retail = true
  else
    GR.Retail = false
  end

  GR:CreateMainWindow()
  GR:CreateAcceptDecline()
  GR:CreateHeaderInfo()
  GR:CreateTabSoloGames()
  GR:CreateTabMultiGames()
  GR:CreateTabSettings()
  GR:CreateRegister()
  GR:CreateTicTacToe()
  GR:CreateBattleships()
  GR:CreateAsteroids()
  GR:CreateSnake()
  GR:CreateBouncyChicken()
  GR:SuikaCreate()
  GR:CreateMinesweepers()

  GR:SizeMain()
  GR:SizeAllGames()
  
  GR.db.realm.tab = "solo"
  GR:TabSelect()

  GR:RegisterComm("GameRoom_Reg", function(...) GR:RegisterPlayers(...) end)
  GR:RegisterComm("GameRoom_Inv", function(...) GR:Invite(...) end)
  GR:RegisterComm("GameRoom_TiG", function(...) GR:TicTacToeComm(...) end)
  GR:RegisterComm("GameRoom_BSG", function(...) GR:BattleshipsComm(...) end)
  
  GR_GUI.Main:Hide()
end

function GR:CreateMainWindow()
  -- Main Window
  GR_GUI.Main = CreateFrame("Frame", "GameRoom", UIParent, "DefaultPanelFlatTemplate")
  -- GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "SimplePanelTemplate")
  -- GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "DefaultPanelTemplate")
  -- GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "PortraitFrameFlatBaseTemplate")
  -- GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "PortraitFrameTemplate")
  local Main = GR_GUI.Main
  Main:SetSize(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)
  Main:SetFrameStrata("HIGH")
  Main:SetPoint("TOP", UIParent, "TOP", 0, -130)
  Main:SetMovable(true)
  Main:EnableMouse(true)
  Main:SetResizable(true)
  Main:RegisterForDrag("LeftButton")
  Main:SetScript("OnDragStart", function() if(IsShiftKeyDown() == true) then Main:StartMoving() end end)
  Main:SetScript("OnDragStop", Main.StopMovingOrSizing)
  Main:SetPropagateKeyboardInput(true)
  Main:SetScript("OnKeyDown", function(self, key)
    if (key == "ESCAPE" and Main:IsVisible()) then
      Main:Hide()
      Main:SetPropagateKeyboardInput(false)
      C_Timer.After(.001, function() 
        Main:SetPropagateKeyboardInput(true)
      end)
    end
  end)
  Main:Show()
  Main:SetAlpha(1)

  Main.XRatio = 1
  Main.YRatio = 1
  Main.ScreenRatio = 1

  -- close button
  Main.XButton = CreateFrame("Button", "XButton", Main, "UIPanelCloseButtonDefaultAnchors")
  Main.XButton:SetPoint("TOPRIGHT", 0, -1)
  Main.XButton:SetSize(21, 21)

  -- Resize Button
  Main.ResizeBtn = CreateFrame("Button", nil, Main)
  local ResizeBtn = Main.ResizeBtn  
  Main.ResizeBtn:SetPoint("BOTTOMRIGHT", -7, 6)
  Main.ResizeBtn:SetSize(16, 16)  
  ResizeBtn:EnableMouse("true")
  ResizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  ResizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  ResizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  ResizeBtn:SetScript("OnMouseDown", function(self)
    self:GetParent():StartSizing("BOTTOMRIGHT") 
  end)
  ResizeBtn:SetScript("OnMouseUp", function()
    Main:StopMovingOrSizing("BOTTOMRIGHT")
    GR:SizeMain()
    GR:SizeAllGames()
  end)
  
  -- Game Room Title
  Main.TitleContainer = CreateFrame("Frame", "TitleContainer", Main)
  local TitleContainer = Main.TitleContainer
  TitleContainer:SetFrameStrata("TOOLTIP")
  TitleContainer:SetSize(100, 18)
  TitleContainer:SetPoint("TOP", 0, -6)
  Main.H1 =  TitleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
  local H1 = Main.H1
  H1:SetText("Game Room")
  H1:SetPoint("TOP")

  -- tabs
  Main.TabButton1 = CreateFrame("Button", "TabButton1", Main, "PanelTabButtonTemplate")
  local TabButton1 = Main.TabButton1
  TabButton1:SetPoint("BOTTOMLEFT", 10, -30)
  TabButton1:SetText("Solo")
  TabButton1:SetScript("OnClick", function()
    GR.db.realm.tab = "solo" 
    GR:TabSelect()
  end)
  
  Main.TabButton2 = CreateFrame("Button", "TabButton2", Main, "PanelTabButtonTemplate")
  local TabButton2 = Main.TabButton2
  TabButton2:SetPoint("BOTTOMLEFT", 90, -30)
  TabButton2:SetText("Multi")
  TabButton2:SetScript("OnClick", function()
    GR.db.realm.tab = "multi" 
    GR:TabSelect()
  end)

  Main.TabButton3 = CreateFrame("Button", "TabButton3", Main, "PanelTabButtonTemplate")
  local TabButton3 = Main.TabButton3
  TabButton3:SetPoint("BOTTOMLEFT", 170, -30)
  TabButton3:SetText("Settings")
  TabButton3:SetScript("OnClick", function()
    GR.db.realm.tab = "settings"
    GR:TabSelect()
  end)

  -- Header 2
  Main.H2 = Main:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local H2 = Main.H2
  H2:SetTextColor(1,1,1,1)

  -- Exit Button
  Main.ExitBtn = CreateFrame("Button", "ExitBtn", Main, "UIPanelButtonTemplate")
  local ExitBtn = Main.ExitBtn
  ExitBtn.FS = ExitBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local ExitFS = ExitBtn.FS 
  ExitFS:SetTextColor(1,1,1, 1)
  ExitFS:SetText("Exit Game")
  ExitBtn:SetFontString(ExitFS)
  ExitBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then 
      GR:ExitGameClicked()
    end
  end)
  Main.ExitBtn:Hide()
end

function GR:CreateHeaderInfo()
  -- Frame
  GR_GUI.Main.HeaderInfo = CreateFrame("Frame", HeaderInfo, GR_GUI.Main)
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  
  -- Turn String
  HeaderInfo.TurnString = HeaderInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local TurnString = HeaderInfo.TurnString

  -- Opponet String
  HeaderInfo.OpponentString = HeaderInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local Opp = HeaderInfo.OpponentString
  Opp:SetTextColor(1,1,1, 1)

  -- Reinvite Button
  HeaderInfo.ReInvite = CreateFrame("Button", ReInvite, HeaderInfo, "UIPanelButtonTemplate")
  local ReInvite = HeaderInfo.ReInvite
  ReInvite.FS = ReInvite:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  ReInvite.FS:SetTextColor(1,1,1, 1)
  ReInvite.FS:SetText("Rematch?")
  ReInvite:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then
          local UserName = UnitName("player")
          if (GR.GameType == "Tictactoe") then
              GR:SendCommMessage("GameRoom_Inv", "TicTacToe_Challenge, " .. UserName, "WHISPER", GR.Opponent)
          end
          if (GR.GameType == "Battleships") then
              GR:SendCommMessage("GameRoom_Inv", "Battleships_Challenge, " .. UserName, "WHISPER", GR.Opponent)
          end
          GR.CanSendInvite = false
          ReInvite:Hide()
          C_Timer.After(4, function() 
              GR.CanSendInvite = true
          end)
      end
  end)

  -- Rematch Button
  HeaderInfo.ReMatch = CreateFrame("Button", ReMatch, HeaderInfo, "UIPanelButtonTemplate")
  local ReMatch = HeaderInfo.ReMatch
  ReMatch.FS = ReMatch:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local ReMatchFS = ReMatch.FS
  ReMatchFS:SetTextColor(1,1,1, 1)
  ReMatchFS:SetText("Accept")
  ReMatch:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
          local Opponent = GR.Opponent
          local Rand = random(1,2)
          GR.PlayerPos = Rand
          if (GR.PlayerPos == 2) then
              GR.IsPlayerTurn = false
          else
              GR.IsPlayerTurn = true
          end
          if (GR.GameType == "Tictactoe") then
              GR:TicTacToeHideContent()
              GR:SendCommMessage("GameRoom_Inv", "TicTacToe_Accept, " .. Rand .. ", " .. UnitName("Player"), "WHISPER", Opponent)
              GR.db.realm.tab = "game"
              GR:TabSelect()
            end
            if (GR.GameType == "Battleships") then
              GR:BattleshipsHideContent()
              GR:SendCommMessage("GameRoom_Inv", "Battleships_Accept, " .. Rand .. ", " .. UnitName("player"), "WHISPER", Opponent)
              GR.db.realm.tab = "game"
              GR:TabSelect()
          end
      end
  end)

  -- Add Rival Button
  HeaderInfo.Rival = CreateFrame("Button", Rival, HeaderInfo, "UIPanelButtonTemplate")
  local Rival = HeaderInfo.Rival
  Rival.FS = Rival:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local RivalFS = Rival.FS
  RivalFS:SetTextColor(1,1,1, 1)
  RivalFS:SetText("Add Rival")
  Rival:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
          table.insert(GR.db.realm.Rivals, GR.Opponent)
          Rival:Hide()
      end
  end)

  HeaderInfo:Hide()
end

function GR:CreateAcceptDecline()
  local PlayerName = UnitName("player")
  GR_GUI.Accept = CreateFrame("Button", Accept, UIParent, "UIPanelButtonTemplate")
  local Accept = GR_GUI.Accept
  Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
  Accept:SetSize(214, 58)
  local AcceptString = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  AcceptString:SetPoint("TOP", 0, -11)
  AcceptString:SetTextScale(1.5)
  AcceptString:SetTextColor(1,.82,0, 1)
  AcceptString:SetText("Incoming Challenge!")
  Accept.FS2 = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local AcceptString2 = Accept.FS2
  AcceptString2:SetPoint("BOTTOM", 0, 10)
  AcceptString2:SetTextScale(1.3)
  AcceptString2:SetTextColor(1,.82,0, 1)
  Accept:SetScript("OnClick", function(self, button, down)
    GR_GUI.Main:Show() 
    GR:AcceptGameClicked()
  end)

  Accept.DeclineBtn = CreateFrame("Button", DeclineBtn, Accept, "UIPanelButtonTemplate")
  local DeclineBtn = Accept.DeclineBtn
  DeclineBtn:SetPoint("RIGHT", 100, 0)
  DeclineBtn:SetSize(70, 20)
  local DeclineFS = DeclineBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  DeclineFS:SetPoint("CENTER", 0, 0)
  DeclineFS:SetTextScale(1.1)
  DeclineFS:SetTextColor(1,1,1, 1)
  DeclineFS:SetText("Decline")
  DeclineBtn:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
        GR_GUI.Accept:Hide()
        GR:DeclineGameClicked()
      end 
  end)

  -- Mover for Accept Button
  GR_GUI.AcceptMover = CreateFrame("Frame", AcceptMover, UIParent)
  local AcceptMover = GR_GUI.AcceptMover
  AcceptMover:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
  AcceptMover:SetSize(50, 50)
  local AcceptMoverTex = AcceptMover:CreateTexture()
  AcceptMoverTex:SetAllPoints(AcceptMover)
  AcceptMoverTex:SetColorTexture(0,.4,1, 1)
  AcceptMover:SetMovable(true)
  AcceptMover:EnableMouse(true)
  AcceptMover:RegisterForDrag("LeftButton")
  AcceptMover:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
  AcceptMover:SetScript("OnDragStop", function(self) 
      self:StopMovingOrSizing() 
      local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
      GR.db.realm.Point = point
      GR.db.realm.Xpos = xOfs
      GR.db.realm.Ypos = yOfs
      Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
  end)

  Accept:Hide()
  AcceptMover:Hide()
end

-- Size
function GR:SizeMain()
  local Main = GR_GUI.Main

  -- Size Main Ratios
  -- In Game
  if (GR.db.realm.tab == "game") then
    if (GR.GameType == 'Suika') then 
      Main.XRatio = Main:GetWidth() / GR.Win.Const.SuikaScreenWidth
      Main.YRatio = Main:GetHeight() / GR.Win.Const.SuikaScreenHeight
      if (Main.XRatio > Main.YRatio) then
        Main.XRatio = Main.YRatio
      else
        Main.YRatio = Main.XRatio
      end
      Main:SetSize(Main.XRatio * GR.Win.Const.SuikaScreenWidth, Main.YRatio * GR.Win.Const.SuikaScreenHeight)
    else
      Main.XRatio = Main:GetWidth() / GR.Win.Const.GameScreenWidth
      Main.YRatio = Main:GetHeight() / GR.Win.Const.GameScreenHeight
      if (Main.XRatio > Main.YRatio) then
        Main.XRatio = Main.YRatio
      else
        Main.YRatio = Main.XRatio
      end
      Main:SetSize(Main.XRatio * GR.Win.Const.GameScreenWidth, Main.YRatio * GR.Win.Const.GameScreenHeight)
    end
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Solo Games
  if (GR.db.realm.tab == "solo") then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab2Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab2Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Mutli Games
  if (GR.db.realm.tab == "multi") then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab3Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab3Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Settings
  if (GR.db.realm.tab == "settings") then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab4Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab4Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  
  GR:SizeHeaderInfo()
  GR:SizeTabSoloGames()
  GR:SizeTabMultiGames()
  GR:SizeTabSettings()
end

function GR:SizeHeaderInfo()
  -- Frame
  local Main = GR_GUI.Main
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  HeaderInfo:SetPoint("TOP", 0, -60 * Main.YRatio)
  HeaderInfo:SetSize(700 * Main.XRatio, 100 * Main.YRatio)
  
  -- Turn String
  local TurnString = HeaderInfo.TurnString
  TurnString:SetPoint("TOP", 0, 0 * Main.YRatio)
  TurnString:SetTextScale(2 * Main.ScreenRatio)

  -- Opponet String
  local Opp = HeaderInfo.OpponentString
  Opp:SetPoint("TOPLEFT", 0, -2 * Main.YRatio)
  Opp:SetTextScale(1.5 * Main.ScreenRatio)

  -- Reinvite Button
  local ReInvite = HeaderInfo.ReInvite
  ReInvite:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReInvite:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReInviteFS = ReInvite.FS
  ReInviteFS:SetPoint("CENTER", 0, 0)
  ReInviteFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Rematch Button
  local ReMatch = HeaderInfo.ReMatch
  ReMatch:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReMatch:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReMatchFS = ReMatch.FS
  ReMatchFS:SetPoint("CENTER", 0, 0)
  ReMatchFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Add Rival Button
  local Rival = HeaderInfo.Rival
  Rival:SetPoint("TOPLEFT", 0 * Main.XRatio, 7 * Main.YRatio)
  Rival:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local RivalFS = Rival.FS
  RivalFS:SetPoint("CENTER", 0, 0)
  RivalFS:SetTextScale(1.1 * Main.ScreenRatio)

  local HeaderInfo = Main.HeaderInfo
  
  -- H2
  if (GR.db.realm.tab == "solo" or GR.db.realm.tab == "multi" or GR.db.realm.tab == "settings") then
    Main.H2:SetPoint("TOP", 0, -38 * Main.YRatio)
  else
    if (GR.GameType == "Bouncy Chicken") then
      Main.H2:SetPoint("TOP", 0, -50 * Main.YRatio)
    else
      Main.H2:SetPoint("TOP", 0, -65 * Main.YRatio)
    end
  end
  Main.H2:SetTextScale(1.7 * Main.ScreenRatio)
  
  -- Exit Button
  if (GR.GameType == "Bouncy Chicken") then
    Main.ExitBtn:SetPoint("TOPRIGHT", -40 * Main.XRatio, -44 * Main.YRatio)
  else
    Main.ExitBtn:SetPoint("TOPRIGHT", -40 * Main.XRatio, -56 * Main.YRatio)
  end
  Main.ExitBtn:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
end

function GR:SizeAllGames()
  GR:SizeTictactoe()
  GR:SizeBattleships()
  GR:SizeAsteroids()
  GR:SnakeSize()
  GR:SizeBC()
  GR:SuikaSize()
  GR:SizeMinesweepers()
end

-- Functionality
function GR:TabSelect()
  local Main = GR_GUI.Main
  local tab = GR.db.realm.tab

  Main.XRatio = 1
  Main.YRatio = 1
  Main.ScreenRatio = 1
  
  Main.Tab2:Hide()
  Main.Tab3:Hide()
  Main.Tab4:Hide() 
  
  -- In Game
  if (tab == "game") then
    local Width, Height, BoundX, BoundY
    
    if (GR.GameType == "Suika") then
      Width = GR.Win.Const.Tab1WidthSuika
      Height = GR.Win.Const.Tab1WidthSuika
      BoundX = GR.Win.Const.Tab1WidthSuika /2
      BoundY = GR.Win.Const.Tab1HeightSuika /2
    else
      Width = GR.Win.Const.Tab1Width
      Height = GR.Win.Const.Tab1Height
      BoundX = GR.Win.Const.Tab1Width /2
      BoundY = GR.Win.Const.Tab1Height /2
    end

    Main:SetSize(Width, Height)
    Main:SetResizeBounds(BoundX, BoundY)

    GR:SizeMain()
    
    if (GR.GameType == "Asteroids") then
      Main.Asteroids:Show()
      GR:SizeAsteroids()
    end
    if (GR.GameType == "Snake") then
      GR:SnakeShow()
    end
    if (GR.GameType == "Tictactoe") then
      GR:TictactoeShow()
    end
    if (GR.GameType == "Battleships") then
      GR:BattleshipsShow()
    end
    if (GR.GameType == "Bouncy Chicken") then
      GR:BCShow()
    end
    if (GR.GameType == "Suika") then
      GR:SuikaShow()
    end
    if (GR.GameType == "Minesweepers") then
      GR:MinesweepersShow()
    end
  end
  -- Solo Games
  if (tab == "solo") then
    Main:SetSize(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)
    Main:SetResizeBounds(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)

    GR:SizeMain()

    Main.Tab2:Show()
    Main.H2:SetText("Single Player Games")
    Main.H2:Show()
  end
  -- Multiplayer Games
  if (tab == "multi") then
    Main:SetSize(GR.Win.Const.Tab3Width, GR.Win.Const.Tab3Height)
    Main:SetResizeBounds(GR.Win.Const.Tab3Width, GR.Win.Const.Tab3Height)
    
    GR:SizeMain()

    Main.Tab3:Show()
    Main.Tab3.Invite.ServerScrollFrame:Show()
    Main.Tab3.Invite.ActiveTab = "server"
    GR:ToggleInviteTab()
    GR:DisableMultiGameButtons()
    Main.H2:SetText("Multi Player Games")
    Main.H2:Show()
  end
  -- Settings
  if (tab == "settings") then
    Main:SetSize(GR.Win.Const.Tab4Width, GR.Win.Const.Tab4Height)
    Main:SetResizeBounds(GR.Win.Const.Tab4Width, GR.Win.Const.Tab4Height)
  
    GR:SizeMain()

    Main.Tab4:Show()
    Main.H2:SetText("Settings")
    Main.H2:Show()
    GR.CurrList = "Blacklist"
    GR:ToggleSettingsListTab()
  end

  GR:ToggleTab()
end

function GR:ToggleTab()
  local tabIndex = GR.db.realm.tab
  local tab1 = GR_GUI.Main.TabButton1
  local tab2 = GR_GUI.Main.TabButton2
  local tab3 = GR_GUI.Main.TabButton3
  
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
    tab.Text:SetPoint("CENTER", 0, -4)
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
  
  if (tabIndex == "game") then
    tab1:Hide()
    tab2:Hide()
    tab3:Hide()
  else 
    tab1:Show()
    tab2:Show()
    tab3:Show()
  end
  if (tabIndex == "solo") then
    active(tab1)
    normal(tab2)
    normal(tab3)
  end
  if (tabIndex == "multi") then
    normal(tab1)
    active(tab2)
    normal(tab3)
  end
  if (tabIndex == "settings") then
    normal(tab1)
    normal(tab2)
    active(tab3)
  end

end

function GR:SetTurnString()
    local TurnString = GR_GUI.Main.HeaderInfo.TurnString
    if (GR.GameOver == false) then
        if (GR.IsPlayerTurn) then
            TurnString:SetTextColor(0,1,0,1)
            TurnString:SetText(UnitName("player"))
        else
            TurnString:SetTextColor(1,0,0,1)
            TurnString:SetText(GR.Opponent)
        end
    end
end

function GR:ShowRivalsBtn() 
    local InRivals = false
    for i,v in ipairs(GR.db.realm.Rivals) do
        if (string.match(v, GR.Opponent)) then
            InRivals = true
        end
    end
    if (InRivals == false) then
        GR_GUI.Main.HeaderInfo.Rival:Show()
    end
end

-- Show/Hide Game
function GR:ShowGame()
  GR.InGame = true

  GR_GUI.Main.HeaderInfo:Show()
  GR_GUI.Main.HeaderInfo.OpponentString:Show()
  GR_GUI.Main.HeaderInfo.TurnString:Show()
  GR_GUI.Main.ExitBtn:Show()
  
  GR_GUI.Accept:Hide()
  GR_GUI.Main.HeaderInfo.ReInvite:Hide()
  GR_GUI.Main.HeaderInfo.ReMatch:Hide()
  GR_GUI.Main.HeaderInfo.Rival:Hide()
  
  if (GR.Opponent) then 
    GR_GUI.Main.HeaderInfo.OpponentString:SetText("Opponent: " .. GR.Opponent)
  end
  GR:SetTurnString()
end
  
function GR:ShowSoloGame()
  GR.InGame = true
  GR_GUI.Accept:Hide()
  
  GR_GUI.Main.ExitBtn:Show()
  GR_GUI.Main.H2:SetText(GR.GameType)

  GR.db.realm.tab = "game"
  GR:TabSelect()
end

-- Show/Hide Main
function GR:OpenClose(input)
  if (GR_GUI.Main:IsVisible()) then 
      GR_GUI.Main:Hide()
  else
      GR:ShowMain()
  end
end

function GR:ShowMain()
  local Main = GR_GUI.Main

  local function SizeMain()
    if (GR.db.realm.tab == "game") then 
      Main:SetSize(GR.Win.Const.Tab1Width, GR.Win.Const.Tab1Height)
    end
    if (GR.db.realm.tab == "solo") then 
      Main:SetSize(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)
    end
    if (GR.db.realm.tab == "multi") then 
      Main:SetSize(GR.Win.Const.Tab3Width, GR.Win.Const.Tab3Height)
    end
    if (GR.db.realm.tab == "settings") then 
      Main:SetSize(GR.Win.Const.Tab4Width, GR.Win.Const.Tab4Height)
    end
  end
  
  Main:Show() 

  if (GR:CheckOutOfBoundsRects(Main, UIParent)) then
    Main:SetPoint("TOPLEFT", UIParent, "TOPLEFT", UIParent:GetWidth() / 2 - GR.Win.Const.Tab2Width / 2, -130)
  end

  -- if main is bigger than screen, reset main size
  if (Main:GetHeight() > UIParent:GetHeight() or Main:GetWidth() > UIParent:GetWidth()) then
      SizeMain()
  end
  
  GR:UpdateFriendsList()

  Main.ScreenRatio = 1
  Main.XRatio = 1
  Main.YRatio = 1

  SizeMain()

  GR:SizeMain()
end

-- Extra
function GR:CheckOutOfBoundsRects(Rect1, Rect2)
    local Rect1X, Rect1Y, Rect1Width, Rect1Height = Rect1:GetRect()
    local Rect2X, Rect2Y, Rect2Width, Rect2Height = Rect2:GetRect()
    -- out of bounds check. rect1 is fully out of rect2
    if (Rect1X > Rect2X + Rect2Width or Rect1X + Rect1Width < Rect2X or Rect1Y > Rect2Y + Rect2Height or Rect1Y + Rect1Height < Rect2Y) then
        return true
    end
    return false
end

function ScrollFrame_OnMouseWheel(self, delta)
  local newValue = self:GetVerticalScroll() - (delta * 20);
 
  if (newValue < 0) then
    newValue = 0;
  elseif (newValue > self:GetVerticalScrollRange()) then
    newValue = self:GetVerticalScrollRange();
  end
 
  self:SetVerticalScroll(newValue);
end

-- BUGS
-- guild needs to unregister offline players
-- show challenge as msg doesn't allow players to accept challenges

-- GAMES
-- chess
-- pac-man
-- suduko
-- tetris
-- bejeweled
-- galaga
-- frogger
-- minesweeper
-- pin-ball macheine
-- tower defense
-- boat launch game (like angry birds  but you shoot the boat then they shoot you)
-- heli attack 3 (or something similar thats generated where you shoot targets, dodge attacks, get power ups)

-- FUNCTIONS
-- rematch button
-- look into retail custom chat channel addon comms
-- rival message/response to register/unregister online/offline rivals
-- maybe maybe... comms through bnet for cross-server games with bnet friends (while out of party/raid)

-- highlight selected opponent on multiplayer invite scroll




-- fix resize
-- fix show / hide
-- standardize game header bar