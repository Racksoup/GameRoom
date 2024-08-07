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
    tab = "solo",
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
  GR.Win.Const.Tab1Height = 520
  GR.Win.Const.Tab1WidthSuika = 475
  GR.Win.Const.Tab1HeightSuika = 800
  GR.Win.Const.Tab1WidthSuduko = 475
  GR.Win.Const.Tab1HeightSuduko = 525
  GR.Win.Const.GameScreenWidth = 750
  GR.Win.Const.GameScreenHeight = 420
  GR.Win.Const.SuikaScreenWidth = 435
  GR.Win.Const.SuikaScreenHeight = 680
  GR.Win.Const.SudukoScreenWidth = 425
  GR.Win.Const.SudukoScreenHeight = 425
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
	GR.GameDifficulty = "easy"

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
  GR:CreateSuika()
  GR:CreateMinesweepers()
  GR:CreateSuduko()

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
  Main:SetFrameStrata("HIGH")
  Main:SetPoint("TOP", UIParent, "TOP", 0, -130)
  Main:SetClampedToScreen(true)
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
  if (not GR.Retail) then
    Main.XButton:SetPoint("TOPRIGHT", 1.7, 1.5)
    Main.XButton:SetSize(28, 28)
  end

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
  
  if (not GR.Retail) then
    TabButton1:SetScale(.65)
    TabButton1.Text:SetTextScale(1.4)
    TabButton1:SetPoint("BOTTOMLEFT", 10, -26)
    TabButton2:SetScale(.65)
    TabButton2.Text:SetTextScale(1.4)
    TabButton2:SetPoint("BOTTOMLEFT", 140, -26)
    TabButton3:SetScale(.65)
    TabButton3.Text:SetTextScale(1.4)
    TabButton3:SetPoint("BOTTOMLEFT", 280, -26)
  end
  
  -- Header 2
  Main.H2 = Main:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local H2 = Main.H2
  H2:SetTextColor(1,1,1,1)
end

function GR:CreateAcceptDecline()
  local PlayerName = UnitName("player")
  GR_GUI.Accept = CreateFrame("Button", "GameRoomAcceptBtn", UIParent, "UIPanelButtonTemplate")
  local Accept = GR_GUI.Accept
  Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
  Accept:SetSize(175, 62)
  local AcceptString = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  AcceptString:SetPoint("TOP", 0, -17)
  AcceptString:SetTextScale(1)
  AcceptString:SetTextColor(1,.82,0, 1)
  AcceptString:SetText("Incoming Challenge!")
  Accept.FS = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local AcceptString = Accept.FS
  AcceptString:SetPoint("BOTTOM", 0, 15)
  AcceptString:SetTextScale(1)
  AcceptString:SetTextColor(1,.82,0, 1)
  Accept:SetScript("OnClick", function(self, button, down)
    GR_GUI.Main:Show() 
    GR:AcceptGameClicked()
  end)

  Accept.DeclineBtn = CreateFrame("Button", "GameRoomDeclineBtn", Accept, "UIPanelButtonTemplate")
  local DeclineBtn = Accept.DeclineBtn
  DeclineBtn:SetPoint("TOP", Accept, "BOTTOM", 0, 0)
  DeclineBtn:SetSize(70, 23)
  local DeclineFS = DeclineBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  DeclineFS:SetPoint("CENTER", 0, 0)
  DeclineFS:SetTextScale(1)
  DeclineFS:SetTextColor(1,1,1, 1)
  DeclineFS:SetText("Decline")
  DeclineBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then 
      GR_GUI.Accept:Hide()
      GR:DeclineGameClicked()
    end 
  end)

  -- Mover for Accept Button
  GR_GUI.AcceptMover = CreateFrame("Frame", "GameRoomAcceptMover", UIParent)
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
    -- Lock screen dimmensions for in game
    if (GR.GameType == 'Suika') then 
      Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab1WidthSuika
      Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab1HeightSuika
      if (Main.XRatio > Main.YRatio) then
        Main.XRatio = Main.YRatio
      else
        Main.YRatio = Main.XRatio
      end
      Main:SetSize(Main.XRatio * GR.Win.Const.Tab1WidthSuika, Main.YRatio * GR.Win.Const.Tab1HeightSuika)
    elseif (GR.GameType == 'Suduko') then 
      Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab1WidthSuduko
      Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab1HeightSuduko
      if (Main.XRatio > Main.YRatio) then
        Main.XRatio = Main.YRatio
      else
        Main.YRatio = Main.XRatio
      end
      Main:SetSize(Main.XRatio * GR.Win.Const.Tab1WidthSuduko, Main.YRatio * GR.Win.Const.Tab1HeightSuduko)
    else
      Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab1Width
      Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab1Height
      if (Main.XRatio > Main.YRatio) then
        Main.XRatio = Main.YRatio
      else
        Main.YRatio = Main.XRatio
      end
      Main:SetSize(Main.XRatio * GR.Win.Const.Tab1Width, Main.YRatio * GR.Win.Const.Tab1Height)
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

  -- only resize main element is the h2 fontstring
  -- H2
  if (GR.db.realm.tab == "solo" or GR.db.realm.tab == "multi" or GR.db.realm.tab == "settings") then
    Main.H2:SetPoint("TOP", 0, -38 * Main.YRatio)
  else
    Main.H2:SetPoint("TOP", 0, -50 * Main.YRatio)
  end
  Main.H2:SetTextScale(1.7 * Main.ScreenRatio)
  
  GR:SizeHeaderInfo()
  GR:SizeTabSoloGames()
  GR:SizeTabMultiGames()
  GR:SizeTabSettings()
end

function GR:SizeAllGames()
  GR:SizeTictactoe()
  GR:SizeBattleships()
  GR:SizeAsteroids()
  GR:SizeSnake()
  GR:SizeBC()
  GR:SizeSuika()
  GR:SizeMinesweepers()
  GR:SizeSuduko()
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
    local Width, Height
    
    if (GR.GameType == "Suika") then
      Width = GR.Win.Const.Tab1WidthSuika
      Height = GR.Win.Const.Tab1HeightSuika
    elseif (GR.GameType == "Suduko") then
      Width = GR.Win.Const.Tab1WidthSuduko
      Height = GR.Win.Const.Tab1HeightSuduko
    else
      Width = GR.Win.Const.Tab1Width
      Height = GR.Win.Const.Tab1Height
    end

    Main:SetSize(Width, Height)
    Main:SetResizeBounds(Width /2, Height /2)

    if (GR.GameType == "Asteroids") then
      GR:AsteroidsShow()
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
    if (GR.GameType == "Suduko") then
      GR:SudukoShow()
    end
  end
  -- Solo Games
  if (tab == "solo") then
    Main:SetSize(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)
    Main:SetResizeBounds(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)

    Main.Tab2:Show()
    Main.H2:SetText("Single Player Games")
    Main.H2:Show()
  end
  -- Multiplayer Games
  if (tab == "multi") then
    Main:SetSize(GR.Win.Const.Tab3Width, GR.Win.Const.Tab3Height)
    Main:SetResizeBounds(GR.Win.Const.Tab3Width, GR.Win.Const.Tab3Height)
    
    Main.Tab3.Invite.ServerScrollFrame:Show()
    Main.Tab3.Invite.ActiveTab = "server"
    GR:ToggleInviteTab()
    GR:DisableMultiGameButtons()

    Main.Tab3:Show()
    Main.H2:SetText("Multi Player Games")
    Main.H2:Show()
  end
  -- Settings
  if (tab == "settings") then
    Main:SetSize(GR.Win.Const.Tab4Width, GR.Win.Const.Tab4Height)
    Main:SetResizeBounds(GR.Win.Const.Tab4Width, GR.Win.Const.Tab4Height)

    GR.CurrList = "Blacklist"
    GR:ToggleSettingsListTab()

    Main.Tab4:Show()
    Main.H2:SetText("Settings")
    Main.H2:Show()
  end

  GR:SizeMain()
  GR:UIToggleTab()
end

function GR:UIToggleTab()
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

function GR:UIInitTabTop(tab)
  if (GR.Retail) then
    tab.LeftActive:Hide()
    tab.MiddleActive:Hide()
    tab.RightActive:Hide()
  else
    tab.HighlightTexture:Hide()
    tab.Left:Hide()
    tab.LeftDisabled:Hide()
    tab.Middle:Hide()
    tab.MiddleDisabled:Hide()
    tab.Right:Hide()
    tab.RightDisabled:Hide()
  end
end

-- Show/Hide Game
-- ShowmMultiGame or ShowSoloGame is called first on game show
-- then calls TabSelect()
-- then calls [game]Show
function GR:ShowMultiGame()
  local Main = GR_GUI.Main
  
  GR.InGame = true
  GR_GUI.Accept:Hide()

  GR:ResetHeader()
  
  Main.HeaderInfo:Show()
  Main.HeaderInfo.Solo:Hide()
  Main.HeaderInfo.Multi:Show()
  Main.HeaderInfo.Multi.ReInvite:Hide()
  Main.HeaderInfo.Multi.ReMatch:Hide()
  Main.HeaderInfo.Multi.Rival:Hide()
  GR_GUI.Main.H2:SetText(GR.GameType)
  if (GR.Opponent) then 
    Main.HeaderInfo.Multi.OpponentString:SetText("Opponent: " .. GR.Opponent)
  end
  GR:SetTurnString()

  GR.db.realm.tab = "game"
  GR:TabSelect()
end
  
function GR:ShowSoloGame()
  GR.InGame = true
  GR_GUI.Accept:Hide()
  
  GR:ResetHeader()

  GR_GUI.Main.HeaderInfo:Show()
  GR_GUI.Main.HeaderInfo.Multi:Hide()
  GR_GUI.Main.HeaderInfo.Solo:Show()
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

  local function resetMainSize()
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

  Main.ScreenRatio = 1
  Main.XRatio = 1
  Main.YRatio = 1

  resetMainSize()
  GR:SizeMain()
  Main:Show()
  GR:UpdateFriendsList()
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

function GR:deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[GR:deepCopy(orig_key)] = GR:deepCopy(orig_value)
        end
        setmetatable(copy, GR:deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- BUGS
-- guild needs to unregister offline players
-- show challenge as msg doesn't allow players to accept challenges
-- rivals spams 

-- GAMES
-- nonograms
-- maze puzzles
-- 2048
-- tents puzzle
-- tower defense
-- boat launch game (like angry birds  but you shoot the boat then they shoot you)
-- chess
-- bejeweled
-- frogger
-- tetris
-- pac-man
-- galaga

-- FUNCTIONS
-- rematch button
-- rival message/response to register/unregister online/offline rivals
-- maybe maybe... comms through bnet for cross-server games with bnet friends (while out of party/raid)
 
-- update curseforge pictures
