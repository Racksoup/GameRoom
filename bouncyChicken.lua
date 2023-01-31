function GR:CreateBouncyChicken()
  -- Constants
  GR.BC = {}
  GR.BC.Const = {}

  -- Bouncy Chicken Frame
  GR_GUI.Main.BC = CreateFrame("Frame", BouncyChicken, GR_GUI.Main, "ThinBorderTemplate")
  local BC = GR_GUI.Main.BC
  BC:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(GR_GUI.Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  BC:Hide()

  -- Variables
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2
  GR.BC.ActiveState = "Stop"
  GR.BC.GameTime = 0
  GR.BC.Points = 0

  -- Create
  GR:CreateBCGameLoop()
  GR:ControlsBC()
  GR:CreateBCActiveStatusBtns()
  GR:CreateBCInfo()
end

function GR:CreateBCGameLoop()
  local BC = GR_GUI.Main.BC

  -- Game Loop
  BC.Game = CreateFrame("Frame", Game, BC)
  local Game = BC.Game
  Game:SetScript("OnUpdate", function(self, elapsed)
    GR:UpdateBC(self, elapsed)
  end)
  Game:Hide()
end

function GR:CreateBCActiveStatusBtns()
  local BC = GR_GUI.Main.BC

  -- Start / Unpause
  BC.Start = CreateFrame("Button", Start, BC)
  BC.Start.Line1 = BC.Start:CreateLine()
  BC.Start.Line1:SetColorTexture(0,1,0, 1)
  BC.Start.Line2 = BC.Start:CreateLine()
  BC.Start.Line2:SetColorTexture(0,1,0, 1)
  BC.Start.Line3 = BC.Start:CreateLine()
  BC.Start.Line3:SetColorTexture(0,1,0, 1)
  BC.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      if (GR.BC.ActiveState == "Stop" or GR.BC.ActiveState == "Start") then
        GR.BC.ActiveState = "Start"
        GR.BCStart()
      end
      if (GR.BC.ActiveState == "Pause") then
        GR.BC.ActiveState = "Start"
        GR.BCUnpause()
      end
    end
  end)
  
  -- Stop
  BC.Stopx = CreateFrame("Button", Stopx, BC)
  BC.Stopx.Tex = BC.Stopx:CreateTexture()
  BC.Stopx.Tex:SetColorTexture(1,0,0, 1)
  BC.Stopx.Tex:SetPoint("CENTER")
  BC.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      BC.ActiveState = "Stop"
      GR:BCStop()
    end
  end)
  BC.Stopx:Hide()
  
  -- Pause
  BC.Pausex = CreateFrame("Button", Pausex, BC)
  BC.Pausex.Tex1 = BC.Pausex:CreateTexture()
  BC.Pausex.Tex1:SetColorTexture(1,1,0, 1)
  BC.Pausex.Tex2 = BC.Pausex:CreateTexture()
  BC.Pausex.Tex2:SetColorTexture(1,1,0, 1)
  BC.Pausex:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      BC.ActiveState = "Pause"
      GR:BCPause()
    end
  end)
  BC.Pausex:Hide()
end

function GR:CreateBCInfo()
  local BC = GR_GUI.Main.BC

  -- Timer
  BC.Timer = BC:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Timer:SetText(GR.BC.GameTime)
  BC.Timer:SetTextColor(.8,.8,.8, 1)

  -- Points
  BC.PointsFS = BC:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.PointsFS:SetText(GR.BC.Points)
  BC.PointsFS:SetTextColor(.8,.8,.8, 1)

  -- GameOver
  BC.GameOverFS = BC:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.GameOverFS:SetText("Game Over")
  BC.GameOverFS:SetTextColor(.8,0,0, 1)
  BC.GameOverFS:Hide()

  -- Controls Info
  BC.Info = BC:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Info:SetText("Bounce: Space, W, Up-Arrow")
  BC.Info:SetTextColor(.8,.8,.8, 1)
end

-- Size
function GR:SizeBC()
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  BC:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  GR:SizeBCActiveStatusBtns()
  GR:SizeBCInfo()
end

function GR:SizeBCActiveStatusBtns()
  local BC = GR_GUI.Main.BC
  local XRatio = GR.BC.XRatio
  local YRatio = GR.BC.YRatio
  local ScreenRatio = GR.BC.ScreenRatio
  
  -- Start
  BC.Start:SetPoint("TOPLEFT", 50 * XRatio, 34 * YRatio)
  BC.Start:SetSize(30 * XRatio, 30 * YRatio)
  BC.Start.Line1:SetStartPoint("CENTER", -8 * XRatio, 8 * YRatio)
  BC.Start.Line1:SetEndPoint("CENTER", 8 * XRatio, 0)
  BC.Start.Line1:SetThickness(3 * ScreenRatio)
  BC.Start.Line2:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  BC.Start.Line2:SetEndPoint("CENTER", 8 * XRatio, 0)
  BC.Start.Line2:SetThickness(3 * ScreenRatio)
  BC.Start.Line3:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  BC.Start.Line3:SetEndPoint("CENTER", -8 * XRatio, 8 * YRatio)
  BC.Start.Line3:SetThickness(3 * ScreenRatio)

  -- Stop
  BC.Stopx:SetPoint("TOPLEFT", 83 * XRatio, 34 * YRatio)
  BC.Stopx:SetSize(30 * XRatio, 30 * YRatio)
  BC.Stopx.Tex:SetSize(15 * XRatio, 15 * YRatio)
  
  -- Unpause
  BC.Pausex:SetPoint("TOPLEFT", 50 * XRatio, 34 * YRatio)
  BC.Pausex:SetSize(30 * XRatio, 30 * YRatio)
  BC.Pausex.Tex1:SetSize(6 * XRatio, 15 * YRatio)
  BC.Pausex.Tex1:SetPoint("CENTER", -6 * XRatio, 0)
  BC.Pausex.Tex2:SetSize(6 * XRatio, 15 * YRatio)
  BC.Pausex.Tex2:SetPoint("CENTER", 6 * XRatio, 0)
end

function GR:SizeBCInfo()
  local BC = GR_GUI.Main.BC
  
  -- Timer
  BC.Timer:SetPoint("BOTTOMLEFT", BC, "TOPRIGHT", -220 * GR.BC.XRatio, 6 * GR.BC.YRatio)
  BC.Timer:SetTextScale(2 * GR.BC.ScreenRatio)
  
  -- Points
  BC.PointsFS:SetPoint("BOTTOMLEFT", BC, "TOPLEFT", 160 * GR.BC.XRatio, 6 * GR.BC.YRatio)
  BC.PointsFS:SetTextScale(2 * GR.BC.ScreenRatio)
  
  -- Game Over
  BC.GameOverFS:SetPoint("TOP", 0, -80 * GR.BC.YRatio)
  BC.GameOverFS:SetTextScale(3.7 * GR.BC.ScreenRatio)
  
  -- Controls Info
  BC.Info:SetPoint("TOP", BC, "TOPLEFT", 100 * GR.BC.XRatio, 57 * GR.BC.YRatio)
  BC.Info:SetTextScale(1 * GR.BC.ScreenRatio)
end

-- Update
function GR:UpdateBC(self, elapsed)
  local BC = GR_GUI.Main.BC

  GR.BC.GameTime = GR.BC.GameTime + elapsed

  BC.Timer:SetText(math.floor(GR.BC.GameTime * 100) / 100)
end

-- Controls
function GR:ControlsBC()
  local Game = GR_GUI.Main.BC.Game

  Game:SetScript("OnKeyDown", function(self, key)
    if (key == "SPACE") then 
      GR:BCBounce()
    end
  end)
end

-- Functions
function GR:BCBounce()

end

-- Hide Show
function GR:BCHide()
  local BC = GR_GUI.Main.BC
  
  GR:BCStop()

  BC:Hide()
end

function GR:BCShow()
  local BC = GR_GUI.Main.BC

  GR:SizeBC()

  BC:Show()
end

-- Start Stop Pause Unpause
function GR:BCStart()
  local BC = GR_GUI.Main.BC

  -- Reset Variables
  GR.BC.GameTime = 0
  GR.BC.Points = 0

  BC.PointsFS:SetText(GR.BC.Points)

  BC.Game:Show()
  BC.Stopx:Show()
  BC.Pausex:Show()
  BC.Start:Hide()
  BC.GameOverFS:Hide()
end

function GR:BCStop()
  local BC = GR_GUI.Main.BC
  
  BC.Game:Hide()
  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()
end

function GR:BCPause()
  local BC = GR_GUI.Main.BC

  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()

  BC.Game:Hide()
end

function GR:BCUnpause()
  local BC = GR_GUI.Main.BC

  BC.Start:Hide()
  BC.Pausex:Show()
  BC.Stopx:Show()

  BC.Game:Show()
end

function GR:BCGameOver()
  GR:BCStop()

  GR_GUI.Main.BC.GameOverFS:Show()
end
