-- create
function GR:CreateAsteroids()
  GR.AsteroidsPhase = "Stopped"

  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:Hide()

  -- pause button
  Asteroids.PauseBtn = CreateFrame("Button", PauseBtn, Asteroids, "UIPanelButtonTemplate")
  local PauseBtn = Asteroids.PauseBtn
  PauseBtn.FS = PauseBtn:CreateFontString(PauseBtn, "HIGH", "GameTooltipText")
  PauseBtn.FS:SetPoint("CENTER")
  PauseBtn.FS:SetTextColor(.8,.8,.8, 1)
  PauseBtn.FS:SetText("Start")
  PauseBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then
      if (GR.AsteroidsPhase == "Stopped" or GR.AsteroidsPhase == "Paused") then
        GR.AsteroidsPhase = "Started"
        PauseBtn.FS:SetText("Pause")
        Asteroids.StopBtn:Show()
        
      elseif (GR.AsteroidsPhase == "Started") then
        GR.AsteroidsPhase = "Paused"
        PauseBtn.FS:SetText("Start")
        
      end
    end
  end)
  
  -- stop button
  Asteroids.StopBtn = CreateFrame("Button", StopBtn, Asteroids, "UIPanelButtonTemplate")
  local StopBtn = Asteroids.StopBtn
  StopBtn.FS = StopBtn:CreateFontString(StopBtn, "HIGH", "GameTooltipText")
  StopBtn.FS:SetPoint("CENTER")
  StopBtn.FS:SetTextColor(.8,.8,.8, 1)
  StopBtn.FS:SetText("Stop")
  StopBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then
      GR.AsteroidsPhase = "Stopped"
      PauseBtn.FS:SetText("Start")
      StopBtn:Hide()
    end
  end)
  StopBtn:Hide()
  
  -- Size
  GR:SizeAsteroids()
end

-- resize
function GR:SizeAsteroids()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  local PauseBtn = GR_GUI.Main.Asteroids.PauseBtn
  local StopBtn = GR_GUI.Main.Asteroids.StopBtn
  
  -- Main Window
  Asteroids:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / 640))
  Asteroids:SetSize(Main:GetWidth() * (500 / 800), Main:GetHeight() * (500 / 640))
  local WidthRatio = Asteroids:GetWidth() / 770
  local HeightRatio = Asteroids:GetHeight() / 450

  -- pause button
  PauseBtn:SetPoint("TOPLEFT", 15 * WidthRatio, 40 * HeightRatio)
  PauseBtn:SetSize(100 * WidthRatio, 35 * HeightRatio)
  PauseBtn.FS:SetTextScale(1.8 * ((WidthRatio + HeightRatio) / 2))

  -- stop button
  StopBtn:SetPoint("TOPLEFT", 120 * WidthRatio, 40 * HeightRatio)
  StopBtn:SetSize(100 * WidthRatio, 35 * HeightRatio)
  StopBtn.FS:SetTextScale(1.8 * ((WidthRatio + HeightRatio) / 2))
end

-- hide / show
function GR:AsteroidsHide()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  
  Asteroids:Hide()
  GR:HideGame()
end

function GR:AsteroidsShow()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids

  GR.GameType = "Asteroids"
  GR:SizeAsteroids()
  Asteroids:Show()
  GR:ShowSoloGame()
end

-- functionality