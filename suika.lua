function GR:SuikaCreate()
  -- Contants
  GR.Suika = {}
  GR.Suika.Const = {}
  GR.Suika.Const.GameScreenWidth = 400
  GR.Suika.Const.Tab1Width = 450

  -- Suika Frame
  GR_GUI.Main.Suika = CreateFrame("Frame", Suika, GR_GUI.Main, "ThinBorderTemplate")
  local Suika = GR_GUI.Main.Suika
  Suika:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Win.Const.Tab1Height))
  Suika:SetSize(GR_GUI.Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  Suika:SetClipsChildren(true)
  Suika:Hide()

  -- Variables
  GR.Suika.XRatio = Suika:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.Suika.YRatio = Suika:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Win.Const.GameScreenWidth + Suika:GetHeight() / GR.Win.Const.GameScreenHeight) / 2
  GR.Suika.ActiveState = "Stop"
  GR.Suika.Points = 0

  -- Create
  GR:SuikaGameLoop()
  GR:SuikaControls()
  GR:SuikaCreateStatusBtns()
  GR:SuikaCreateInfo()
end

function GR:SuikaGameLoop()
  local Suika = GR_GUI.Main.Suika

  -- Game Loop
  Suika.Game = CreateFrame("Frame", Game, Suika)
  local Game = Suika.Game
  Game:SetScript("OnUpdate", function(self, elapsed)
    GR:SuikaUpdate(self, elapsed)
  end)
  Game:Hide()
end

function GR:SuikaCreateStatusBtns()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Start
  Suika.Start = CreateFrame("Button", Start, Main)
  Suika.Start.Line1 = Suika.Start:CreateLine()
  Suika.Start.Line1:SetColorTexture(0,1,0, 1)
  Suika.Start.Line2 = Suika.Start:CreateLine()
  Suika.Start.Line2:SetColorTexture(0,1,0, 1)
  Suika.Start.Line3 = Suika.Start:CreateLine()
  Suika.Start.Line3:SetColorTexture(0,1,0, 1)
  Suika.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Suika.ActiveState = "Start"
      GR.SuikaStart()
    end
  end)
  Suika.Start:Hide()

  -- Stop
  Suika.Stopx = CreateFrame("Button", Stopx, Main)
  Suika.Stopx.Tex = Suika.Stopx:CreateTexture()
  Suika.Stopx.Tex:SetColorTexture(1,0,0, 1)
  Suika.Stopx.Tex:SetPoint("CENTER")
  Suika.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.Suika.ActiveState = "Stop"
      GR:SuikaStop()
    end
  end)
  Suika.Stopx:Hide()
end

function GR:SuikaCreateInfo()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Points 
  Suika.PointsFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Suika.PointsFS:SetText(GR.Suika.Points)
  Suika.PointsFS:SetTextColor(.8,.8,.8, 1)
  Suika.PointsFS:Hide()

  -- GameOver
  Suika.GameOverFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Suika.GameOverFS:SetText("Game Over")
  Suika.GameOverFS:SetTextColor(.8,0,0, 1)
  Suika.GameOverFS:Hide()
end

-- Size
function GR:SuikaSize()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Game Screen
  Suika:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Win.Const.Tab1Height))
  Suika:SetSize(Main:GetWidth() * (GR.Suika.Const.GameScreenWidth / GR.Suika.Const.Tab1Width), Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  GR.Suika.XRatio = Suika:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.Suika.YRatio = Suika:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Suika.Const.GameScreenWidth + Suika:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  GR:SuikaSizeStatusBtns()
  GR:SuikaSizeInfo()
end

function GR:SuikaSizeStatusBtns()
  local Suika = GR_GUI.Main.Suika
  local XRatio = GR.Suika.XRatio
  local YRatio = GR.Suika.YRatio
  local ScreenRatio = GR.Suika.ScreenRatio
  
  -- Start
  Suika.Start:SetPoint("TOPLEFT", Suika, 50 * XRatio, 34 * YRatio)
  Suika.Start:SetSize(30 * XRatio, 30 * YRatio)
  Suika.Start.Line1:SetStartPoint("CENTER", -8 * XRatio, 8 * YRatio)
  Suika.Start.Line1:SetEndPoint("CENTER", 8 * XRatio, 0)
  Suika.Start.Line1:SetThickness(3 * ScreenRatio)
  Suika.Start.Line2:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  Suika.Start.Line2:SetEndPoint("CENTER", 8 * XRatio, 0)
  Suika.Start.Line2:SetThickness(3 * ScreenRatio)
  Suika.Start.Line3:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  Suika.Start.Line3:SetEndPoint("CENTER", -8 * XRatio, 8 * YRatio)
  Suika.Start.Line3:SetThickness(3 * ScreenRatio)

  -- Stop
  Suika.Stopx:SetPoint("TOPLEFT", Suika, 83 * XRatio, 34 * YRatio)
  Suika.Stopx:SetSize(30 * XRatio, 30 * YRatio)
  Suika.Stopx.Tex:SetSize(15 * XRatio, 15 * YRatio)
end

function GR:SuikaSizeInfo()
  local Suika = GR_GUI.Main.Suika

  -- Points
  Suika.PointsFS:SetPoint("BOTTOMLEFT", Suika, "TOPLEFT", 160 * GR.Suika.XRatio, 6 * GR.Suika.YRatio)
  Suika.PointsFS:SetTextScale(2 * GR.Suika.ScreenRatio)
  
  -- Game Over
  Suika.GameOverFS:SetPoint("TOP", Suika, 0, -140 * GR.Suika.YRatio)
  Suika.GameOverFS:SetTextScale(3.7 * GR.Suika.ScreenRatio)
end

-- Update
function GR:SuikaUpdate(self, elapsed)

end

-- Collisions
function GR:SuikaCol()

end

-- Controls
function GR:SuikaControls()

end

-- Functions

-- show / hide
function GR:SuikaShow()
  local Suika = GR_GUI.Main.Suika
  
  GR:SuikaSize()
  
  Suika:Show()
  Suika.PointsFS:Show()
  Suika.GameOverFS:Hide()
  if (GR.Suika.ActiveState == 'Stop') then Suika.Start:Show() end
  if (GR.Suika.ActiveState == 'Start') then Suika.Stopx:Show() end
end

function GR:SuikaHide()
  local Suika = GR_GUI.Main.Suika
  
  Suika:Hide()
  Suika.PointsFS:Hide()
  Suika.GameOverFS:Hide()
  Suika.Start:Hide()
  Suika.Stopx:Hide()
end

-- Start Stop Pause Unpause
function GR:SuikaStart()
  local Suika = GR_GUI.Main.Suika
  
  -- Reset Variables
  GR.Suika.Points = 0

  -- Start Game
  Suika.Game:Show()
  
  -- Show Game Info and Buttons
  GR.Suika.ActiveState = 'Start'
  Suika.PointsFS:SetText(GR.Suika.Points)
  Suika.Start:Hide()
  Suika.Stopx:Show()
  Suika.GameOverFS:Hide()
end

function GR:SuikaStop()
  local Suika = GR_GUI.Main.Suika
  
  GR.Suika.ActiveState = 'Stop'
  Suika.Stopx:Hide()
  Suika.Start:Show()
end

function GR:SuikaGameOver()
  GR:SuikaStop()

  GR_GUI.Main.Suika.GameOverFS:Show()
end