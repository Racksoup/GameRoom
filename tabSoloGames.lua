function GR:CreateTabSoloGames()
  local Main = GR_GUI.Main
  Main.Tab2 = CreateFrame("Frame", Tab2, Main)
  local Tab2 = Main.Tab2
  
  -- Game Buttons
  Tab2.SoloGames = CreateFrame("Frame", SoloGames, Tab2)
  local SoloGames = Tab2.SoloGames

  SoloGames.AsteroidsBtn = CreateFrame("Button", AsteroidsBtn, SoloGames, "UIPanelButtonTemplate")
  local AsteroidsBtn = SoloGames.AsteroidsBtn
  AsteroidsBtn.FS = AsteroidsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local AsteroidsFS = AsteroidsBtn.FS
  AsteroidsFS:SetTextColor(1,1,1, 1)
  AsteroidsFS:SetText("Asteroids")
  AsteroidsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR:AsteroidsShow()
    end
  end)

  SoloGames.SnakeBtn = CreateFrame("Button", "SnakeBtn", SoloGames, "UIPanelButtonTemplate")
  local SnakeBtn = SoloGames.SnakeBtn
  SnakeBtn.FS = SnakeBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SnakeFS = SnakeBtn.FS
  SnakeFS:SetTextColor(1,1,1, 1)
  SnakeFS:SetText("Snake")
  SnakeBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Snake"
      GR:ShowSoloGame()
    end
  end)

  SoloGames.BCBtn = CreateFrame("Button", "BCBtn", SoloGames, "UIPanelButtonTemplate")
  local BCBtn = SoloGames.BCBtn
  BCBtn.FS = BCBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local BCFS = BCBtn.FS
  BCFS:SetTextColor(1,1,1, 1)
  BCFS:SetText("Bouncy Chicken")
  BCBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Bouncy Chicken"
      GR:ShowSoloGame()
    end
  end)

  SoloGames.SuikaBtn = CreateFrame("Button", "SuikaBtn", SoloGames, "UIPanelButtonTemplate")
  local SuikaBtn = SoloGames.SuikaBtn
  SuikaBtn.FS = SuikaBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SuikaFS = SuikaBtn.FS
  SuikaFS:SetTextColor(1,1,1, 1)
  SuikaFS:SetText("Suika")
  SuikaBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Suika"
      GR:ShowSoloGame()
    end
  end)

  SoloGames.MinesweepersBtn = CreateFrame("Button", "MinesweepersBtn", SoloGames, "UIPanelButtonTemplate")
  local MinesweepersBtn = SoloGames.MinesweepersBtn
  MinesweepersBtn.FS = MinesweepersBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local MinesweepersFS = MinesweepersBtn.FS
  MinesweepersFS:SetTextColor(1,1,1, 1)
  MinesweepersFS:SetText("Minesweepers")
  MinesweepersBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Minesweepers"
      GR:ShowSoloGame()
    end
  end)

  Tab2:Hide()
end

function GR:ResizeSoloGames()
  local Main = GR_GUI.Main
  local Tab2 = Main.Tab2
  Tab2:SetPoint("TOP", 0, -50 * Main.YRatio)
  Tab2:SetSize(250 * Main.XRatio, 200 * Main.YRatio)

  -- Game Buttons
  local SoloGames = Tab2.SoloGames
  SoloGames:SetPoint("TOP", 0 * Main.XRatio, -12 * Main.YRatio)
  SoloGames:SetSize(255 * Main.XRatio, 100 * Main.YRatio)
  local AsteroidsBtn = SoloGames.AsteroidsBtn
  AsteroidsBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -5 * Main.YRatio)
  AsteroidsBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local AsteroidsFS = AsteroidsBtn.FS
  AsteroidsFS:SetPoint("CENTER", 0, 0)
  AsteroidsFS:SetTextScale(1 * Main.ScreenRatio)
  local SnakeBtn = SoloGames.SnakeBtn
  SnakeBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -5 * Main.YRatio)
  SnakeBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local SnakeFS = SnakeBtn.FS
  SnakeFS:SetPoint("CENTER", 0, 0)
  SnakeFS:SetTextScale(1 * Main.ScreenRatio)
  local BCBtn = SoloGames.BCBtn
  BCBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -40 * Main.YRatio)
  BCBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local BCFS = BCBtn.FS
  BCFS:SetPoint("CENTER", 0, 0)
  BCFS:SetTextScale(1 * Main.ScreenRatio)
  local SuikaBtn = SoloGames.SuikaBtn
  SuikaBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -40 * Main.YRatio)
  SuikaBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local SuikaFS = SuikaBtn.FS
  SuikaFS:SetPoint("CENTER", 0, 0)
  SuikaFS:SetTextScale(1 * Main.ScreenRatio)
  local MinesweepersBtn = SoloGames.MinesweepersBtn
  MinesweepersBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -75 * Main.YRatio)
  MinesweepersBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local MinesweepersFS = MinesweepersBtn.FS
  MinesweepersFS:SetPoint("CENTER", 0, 0)
  MinesweepersFS:SetTextScale(1 * Main.ScreenRatio)
end