-- create
function GR:CreateAsteroids()
  GR.AsteroidsPhase = "Stopped"
  GR.AsteroidsGameTime = 0

  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:Hide()

  -- Game Loop
  Asteroids.Game = CreateFrame("Frame", Game, Asteroids)
  local Game = Asteroids.Game
  Game:SetScript("OnUpdate", function(self, elapsed) 
    GR:AsteroidsGameLoop(self, elapsed)
  end)
  Game:Hide()

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
        -- start game
        GR:AsteroidsStartGame()      
      elseif (GR.AsteroidsPhase == "Started") then
        -- pause game
        GR:AsteroidsPauseGame()
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
      -- stop game
      GR:AsteroidsStopGame()
    end
  end)
  StopBtn:Hide()
  
  -- Create
  GR:CreateAsteroidsShip()

  -- Size
  GR:SizeAsteroids()
end

function GR:CreateAsteroidsShip()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids

  Asteroids.Ship = CreateFrame("Frame", Ship, Asteroids)
  local Ship = Asteroids.Ship

  -- top-left line
  Ship.Line1 = Ship:CreateLine()
  Ship.Line1:SetColorTexture(.8,.8,.8, 1)
  -- top-right line
  Ship.Line2 = Ship:CreateLine()
  Ship.Line2:SetColorTexture(.8,.8,.8, 1)
  -- bottom-left line
  Ship.Line3 = Ship:CreateLine()
  Ship.Line3:SetColorTexture(.8,.8,.8, 1)
  -- bottom-right line
  Ship.Line4 = Ship:CreateLine()
  Ship.Line4:SetColorTexture(.8,.8,.8, 1)
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
  
  GR:SizeAsteroidsShip(WidthRatio, HeightRatio)
end

function GR:SizeAsteroidsShip(WidthRatio, HeightRatio)
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = GR_GUI.Main.Asteroids.Ship

  Ship:SetSize(32 * WidthRatio, 32 * HeightRatio)
  Ship:SetPoint("CENTER")

  -- top-left line
  Ship.Line1:SetStartPoint("BOTTOMLEFT", 0, 0)
  Ship.Line1:SetEndPoint("TOP", 0, 0)
  Ship.Line1:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- top-right line
  Ship.Line2:SetStartPoint("BOTTOMRIGHT", 0, 0)
  Ship.Line2:SetEndPoint("TOP", 0, 0)
  Ship.Line2:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- bottom-left line
  Ship.Line3:SetStartPoint("BOTTOMRIGHT", 0, 0)
  Ship.Line3:SetEndPoint("CENTER", 0, -6 * HeightRatio)
  Ship.Line3:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- bottom-right line
  Ship.Line4:SetStartPoint("BOTTOMLEFT", 0, 0)
  Ship.Line4:SetEndPoint("CENTER", 0, -6 * HeightRatio)
  Ship.Line4:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
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
  Asteroids.Game:Hide()
  GR:ShowSoloGame()
end

-- functionality

function GR:AsteroidsGameLoop(self, elapsed)
  GR.AsteroidsGameTime = GR.AsteroidsGameTime + elapsed
  print(GR.AsteroidsGameTime)
end

function GR:AsteroidsStartGame()
  local Asteroids = GR_GUI.Main.Asteroids

  -- game buttons
  GR.AsteroidsPhase = "Started"
  Asteroids.PauseBtn.FS:SetText("Pause")
  Asteroids.StopBtn:Show()

  -- start game loop
  Asteroids.Game:Show()
end

function GR:AsteroidsStopGame()
  local Asteroids = GR_GUI.Main.Asteroids
  
  -- game buttons
  GR.AsteroidsPhase = "Stopped"
  Asteroids.PauseBtn.FS:SetText("Start")
  Asteroids.StopBtn:Hide()
  
  -- ends game loop
  Asteroids.Game:Hide()
  GR.AsteroidsGameTime = 0
end
  
function GR:AsteroidsPauseGame()
  local Asteroids = GR_GUI.Main.Asteroids
    
  -- game buttons
  GR.AsteroidsPhase = "Paused"
  Asteroids.PauseBtn.FS:SetText("Start")
  
  -- pause game loop
  Asteroids.Game:Hide()
end