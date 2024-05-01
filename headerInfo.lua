-- Create
function GR:CreateHeaderInfo()
  -- Frame
  GR_GUI.Main.HeaderInfo = CreateFrame("Frame", HeaderInfo, GR_GUI.Main)
  local HeaderInfo = GR_GUI.Main.HeaderInfo

  -- Exit Button
  HeaderInfo.ExitBtn = CreateFrame("Button", "ExitBtn", HeaderInfo, "UIPanelButtonTemplate")
  local ExitBtn = HeaderInfo.ExitBtn
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
  
  GR:CreateHeaderMultiGames()
  GR:CreateHeaderSoloGames()

  HeaderInfo:Hide()
end

function GR:CreateHeaderMultiGames()
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  
  -- Multi Frame
  HeaderInfo.Multi = CreateFrame("Frame", "Multi", HeaderInfo)
  HeaderInfo.Multi:SetAllPoints(HeaderInfo)
  local Multi = HeaderInfo.Multi

  -- Turn String
  Multi.TurnString = Multi:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local TurnString = Multi.TurnString

  -- Opponet String
  Multi.OpponentString = Multi:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local Opp = Multi.OpponentString
  Opp:SetTextColor(1,1,1, 1)

  -- Reinvite Button
  Multi.ReInvite = CreateFrame("Button", "ReInvite", Multi, "UIPanelButtonTemplate")
  local ReInvite = Multi.ReInvite
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
  Multi.ReMatch = CreateFrame("Button", "ReMatch", Multi, "UIPanelButtonTemplate")
  local ReMatch = Multi.ReMatch
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
  Multi.Rival = CreateFrame("Button", "Rival", Multi, "UIPanelButtonTemplate")
  local Rival = Multi.Rival
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

  Multi:Hide()
end

function GR:CreateHeaderSoloGames()
  local HeaderInfo = GR_GUI.Main.HeaderInfo

  -- Solo Frame
  HeaderInfo.Solo = CreateFrame("Frame", "Solo", HeaderInfo)
  HeaderInfo.Solo:SetAllPoints(HeaderInfo)
  local Solo = HeaderInfo.Solo
  Solo.OnState = "Stop"

  GR:CreateHeaderSoloStartStop()
end

function GR:CreateHeaderSoloStartStop()
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  Solo.Start = CreateFrame("Button", "Start", Solo)
  Solo.Start.Line1 = Solo.Start:CreateLine()
  Solo.Start.Line1:SetColorTexture(0,1,0, 1)
  Solo.Start.Line2 = Solo.Start:CreateLine()
  Solo.Start.Line2:SetColorTexture(0,1,0, 1)
  Solo.Start.Line3 = Solo.Start:CreateLine()
  Solo.Start.Line3:SetColorTexture(0,1,0, 1)
  Solo.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      if (Solo.OnState == "Stop" or Solo.OnState == "Start") then
        Solo.OnState = "Start"
        GR:HeaderSoloStart()
      end
      if (Solo.OnState == "Pause") then
        Solo.OnState = "Start"
        GR:HeaderSoloUnpause()
      end
    end
  end)

  Solo.Stopx = CreateFrame("Button", "Stopx", Solo)
  Solo.Stopx.Tex = Solo.Stopx:CreateTexture()
  Solo.Stopx.Tex:SetColorTexture(1,0,0, 1)
  Solo.Stopx.Tex:SetPoint("CENTER")
  Solo.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      Solo.OnState = "Stop"
      GR:HeaderSoloStop()
    end
  end)
  Solo.Stopx:Hide()
  
  Solo.Pausex = CreateFrame("Button", "Pausex", Solo)
  Solo.Pausex.Tex1 = Solo.Pausex:CreateTexture()
  Solo.Pausex.Tex1:SetColorTexture(1,1,0, 1)
  Solo.Pausex.Tex2 = Solo.Pausex:CreateTexture()
  Solo.Pausex.Tex2:SetColorTexture(1,1,0, 1)
  Solo.Pausex:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      Solo.OnState = "Pause"
      GR:HeaderSoloPause()
    end
  end)
  Solo.Pausex:Hide()
end

-- Size
function GR:SizeHeaderInfo()
  -- Frame
  local Main = GR_GUI.Main
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  HeaderInfo:SetPoint("TOP", 0, -60 * Main.YRatio)
  HeaderInfo:SetSize(700 * Main.XRatio, 100 * Main.YRatio)
  
  -- Exit Button
  local ExitBtn = HeaderInfo.ExitBtn
  if (GR.GameType == "Bouncy Chicken") then
    ExitBtn:SetPoint("TOPRIGHT", 0 * Main.XRatio, 0 * Main.YRatio)
  else
    ExitBtn:SetPoint("TOPRIGHT", 0 * Main.XRatio, 0 * Main.YRatio)
  end
  ExitBtn:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  
  GR:SizeHeaderMultiGames()
  GR:SizeHeaderSoloGames()
end

function GR:SizeHeaderMultiGames()
  local Main = GR_GUI.Main
  local Multi = Main.HeaderInfo.Multi

  -- Turn String
  local TurnString = Multi.TurnString
  TurnString:SetPoint("TOP", 0, 0 * Main.YRatio)
  TurnString:SetTextScale(2 * Main.ScreenRatio)

  -- Opponet String
  local Opp = Multi.OpponentString
  Opp:SetPoint("TOPLEFT", 0, -2 * Main.YRatio)
  Opp:SetTextScale(1.5 * Main.ScreenRatio)

  -- Reinvite Button
  local ReInvite = Multi.ReInvite
  ReInvite:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReInvite:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReInviteFS = ReInvite.FS
  ReInviteFS:SetPoint("CENTER", 0, 0)
  ReInviteFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Rematch Button
  local ReMatch = Multi.ReMatch
  ReMatch:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReMatch:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReMatchFS = ReMatch.FS
  ReMatchFS:SetPoint("CENTER", 0, 0)
  ReMatchFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Add Rival Button
  local Rival = Multi.Rival
  Rival:SetPoint("TOPLEFT", 0 * Main.XRatio, 7 * Main.YRatio)
  Rival:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local RivalFS = Rival.FS
  RivalFS:SetPoint("CENTER", 0, 0)
  RivalFS:SetTextScale(1.1 * Main.ScreenRatio)
end

function GR:SizeHeaderSoloGames()
  local Main = GR_GUI.Main
  local Solo = Main.HeaderInfo.Solo

  GR:SizeHeaderSoloStartStop()
end

function GR:SizeHeaderSoloStartStop()
  local Main = GR_GUI.Main
  local Solo = Main.HeaderInfo.Solo
  
  Solo.Start:SetPoint("TOPLEFT", 50 * Main.XRatio, 0 * Main.YRatio)
  Solo.Start:SetSize(30 * Main.XRatio, 30 * Main.YRatio)
  Solo.Start.Line1:SetStartPoint("CENTER", -8 * Main.XRatio, 8 * Main.YRatio)
  Solo.Start.Line1:SetEndPoint("CENTER", 8 * Main.XRatio, 0)
  Solo.Start.Line1:SetThickness(3 * Main.ScreenRatio)
  Solo.Start.Line2:SetStartPoint("CENTER", -8 * Main.XRatio, -8 * Main.YRatio)
  Solo.Start.Line2:SetEndPoint("CENTER", 8 * Main.XRatio, 0)
  Solo.Start.Line2:SetThickness(3 * Main.ScreenRatio)
  Solo.Start.Line3:SetStartPoint("CENTER", -8 * Main.XRatio, -8 * Main.YRatio)
  Solo.Start.Line3:SetEndPoint("CENTER", -8 * Main.XRatio, 8 * Main.YRatio)
  Solo.Start.Line3:SetThickness(3 * Main.ScreenRatio)

  Solo.Stopx:SetPoint("TOPLEFT", 83 * Main.XRatio, 0 * Main.YRatio)
  Solo.Stopx:SetSize(30 * Main.XRatio, 30 * Main.YRatio)
  Solo.Stopx.Tex:SetSize(15 * Main.XRatio, 15 * Main.YRatio)
  
  Solo.Pausex:SetPoint("TOPLEFT", 50 * Main.XRatio, 0 * Main.YRatio)
  Solo.Pausex:SetSize(30 * Main.XRatio, 30 * Main.YRatio)
  Solo.Pausex.Tex1:SetSize(6 * Main.XRatio, 15 * Main.YRatio)
  Solo.Pausex.Tex1:SetPoint("CENTER", -6 * Main.XRatio, 0)
  Solo.Pausex.Tex2:SetSize(6 * Main.XRatio, 15 * Main.YRatio)
  Solo.Pausex.Tex2:SetPoint("CENTER", 6 * Main.XRatio, 0)
end

-- Func
function GR:SetTurnString()
  local TurnString = GR_GUI.Main.HeaderInfo.Multi.TurnString
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
    GR_GUI.Main.HeaderInfo.Multi.Rival:Show()
  end
end

-- Start Stop Pause Unpause
function GR:HeaderSoloStart()
  if (GR.GameType == "Snake") then
    GR:SnakeStart()
  end
  if (GR.GameType == "Bouncy Chicken") then
    GR:BCStart()
  end
end
function GR:HeaderSoloStop()
  if (GR.GameType == "Snake") then
    GR:SnakeStop()
  end
  if (GR.GameType == "Bouncy Chicken") then
    GR:BCStop()
  end
end
function GR:HeaderSoloPause()
  if (GR.GameType == "Snake") then
    GR:SnakePause()
  end
  if (GR.GameType == "Bouncy Chicken") then
    GR:BCPause()
  end
end
function GR:HeaderSoloUnpause()
  if (GR.GameType == "Snake") then
    GR:SnakeUnpause()
  end
  if (GR.GameType == "Bouncy Chicken") then
    GR:BCUnpause()
  end
end