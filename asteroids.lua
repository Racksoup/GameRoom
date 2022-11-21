-- create
function GR:CreateAsteroids()
  -- Constants
  GR.Asteroids = {}
  GR.Asteroids.Const = {}
  GR.Asteroids.Const.ShipMaxSpeed = 150
  GR.Asteroids.Const.ShipAcceleration = 100
  GR.Asteroids.Const.ScreenSizeX = 750
  GR.Asteroids.Const.ScreenSizeY = 500
  GR.Asteroids.Const.ShipSize = 33
  GR.Asteroids.Const.BulletSize = 20
  GR.Asteroids.Const.BulletThickness = 4
  GR.Asteroids.Const.BulletSpeed = 200
  GR.Asteroids.Const.CometSize = 32
  GR.Asteroids.Const.CometMaxSpeed = 80
  GR.Asteroids.Const.NumOfComets = 10
  GR.Asteroids.Const.NumOfBullets = 6
  GR.Asteroids.Const.CometMaxLines = 12
  GR.Asteroids.Const.CometMinLines = 8
  GR.Asteroids.Const.CometMaxRotationSpeed = 5
  GR.Asteroids.Const.BulletTimeout = 1.95
  
  -- Asteroids Frame
  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / 640))
  Asteroids:SetSize(GR_GUI.Main:GetWidth() * (GR.Asteroids.Const.ScreenSizeX / 800), GR_GUI.Main:GetHeight() * (GR.Asteroids.Const.ScreenSizeY / 640))
  Asteroids:Hide()
  
  -- Variables
  GR.Asteroids.Phase = "Stopped"
  GR.Asteroids.GameTime = 0
  GR.Asteroids.ScreenXRatio = Asteroids:GetWidth() / GR.Asteroids.Const.ScreenSizeX
  GR.Asteroids.ScreenYRatio = Asteroids:GetHeight() / GR.Asteroids.Const.ScreenSizeY
  GR.Asteroids.ScreenRatio = (Asteroids:GetWidth() / GR.Asteroids.Const.ScreenSizeX + Asteroids:GetHeight() / GR.Asteroids.Const.ScreenSizeY) / 2
  GR.Asteroids.ShipRotation = 0
  GR.Asteroids.ShipSize = GR.Asteroids.Const.ShipSize
  GR.Asteroids.ShipAcceleration = GR.Asteroids.Const.ShipAcceleration
  GR.Asteroids.ShipDesceleration = -1
  GR.Asteroids.ShipMaxSpeed = GR.Asteroids.Const.ShipMaxSpeed
  GR.Asteroids.ShipXVelocity = 0
  GR.Asteroids.ShipYVelocity = 0
  GR.Asteroids.ShipPosX = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipPosY = Asteroids:GetHeight() / 2
  GR.Asteroids.BulletSize = GR.Asteroids.Const.BulletSize
  GR.Asteroids.BulletThickness = GR.Asteroids.Const.BulletThickness
  GR.Asteroids.BulletSpeed = GR.Asteroids.Const.BulletSpeed
  GR.Asteroids.CometSize = GR.Asteroids.Const.CometSize
  GR.Asteroids.CometMaxSpeed = GR.Asteroids.Const.CometMaxSpeed 
  GR.Asteroids.ShipHit = false
  GR.Asteroids.TimerSave = 0 

  -- Create
  GR:CreateAsteroidsGameLoop()
  GR:CreateAsteroidsGameButtons()
  GR:CreateAsteroidsShip()
  GR:CreateAsteroidsBullets()
  GR:CreateAsteroidsComets()
  GR:CreateAsteroidsFS()
  GR:CreateAsteroidsTimer()

  -- Size
  GR:SizeAsteroids()
end

function GR:CreateAsteroidsGameLoop()
  local Asteroids = GR_GUI.Main.Asteroids
  
  -- Game Loop
  Asteroids.Game = CreateFrame("Frame", Game, Asteroids)
  local Game = Asteroids.Game
  Game:SetScript("OnUpdate", function(self, elapsed) 
    GR:AsteroidsGameLoop(self, elapsed)
  end)

  -- Game Controls
  GR.Asteroids.DownW = false
  GR.Asteroids.DownA = false
  GR.Asteroids.DownS = false
  GR.Asteroids.DownD = false
  Game:SetScript("OnKeyDown", function(self, key) 
    if (key == "W") then
      GR.Asteroids.DownW = true
    end
    if (key == "A") then
      GR.Asteroids.DownA = true
    end
    if (key == "S") then
      GR.Asteroids.DownS = true
    end
    if (key == "D") then
      GR.Asteroids.DownD = true
    end
    if (key == "SPACE") then
      GR:AsteroidsShootBullet()
    end
  end)
  Game:SetScript("OnKeyUp", function(self, key) 
    if (key == "W") then
      GR.Asteroids.DownW = false
    end
    if (key == "A") then
      GR.Asteroids.DownA = false
    end
    if (key == "S") then
      GR.Asteroids.DownS = false
    end
    if (key == "D") then
      GR.Asteroids.DownD = false
    end
  end)
  Game:Hide()
end

function GR:CreateAsteroidsGameButtons()
  local Asteroids = GR_GUI.Main.Asteroids

  -- pause button
  Asteroids.PauseBtn = CreateFrame("Button", PauseBtn, Asteroids, "UIPanelButtonTemplate")
  local PauseBtn = Asteroids.PauseBtn
  PauseBtn.FS = PauseBtn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  PauseBtn.FS:SetPoint("CENTER")
  PauseBtn.FS:SetTextColor(.8,.8,.8, 1)
  PauseBtn.FS:SetText("Start")
  PauseBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then
      if (GR.Asteroids.Phase == "Stopped") then
        -- start game
        GR:AsteroidsStartGame()      
      elseif (GR.Asteroids.Phase == "Paused") then 
        -- unpause
        GR:AsteroidsUnPauseGame()
      elseif (GR.Asteroids.Phase == "Started") then
        -- pause game
        GR:AsteroidsPauseGame()
      end
    end
  end)
  
  -- stop button
  Asteroids.StopBtn = CreateFrame("Button", StopBtn, Asteroids, "UIPanelButtonTemplate")
  local StopBtn = Asteroids.StopBtn
  StopBtn.FS = StopBtn:CreateFontString(nil, "ARTWORK", "GameTooltipText")
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
end

function GR:CreateAsteroidsShip()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  
  -- Ship Vars
  GR.Asteroids.ShipXPos = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipYPos = Asteroids:GetHeight() / 2
  
  -- Ship
  Asteroids.Ship = CreateFrame("Frame", Ship, Asteroids)
  local Ship = Asteroids.Ship
  Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipXPos, GR.Asteroids.ShipYPos)
  Ship:SetSize(2,2)
  
  -- Collision Frame
  Ship.Col = CreateFrame("Frame", Col, Ship)

  -- top-left line
  Ship.Line1 = Ship:CreateLine()
  Ship.Line1:SetColorTexture(1,.6,0, 1)
  -- top-right line
  Ship.Line2 = Ship:CreateLine()
  Ship.Line2:SetColorTexture(1,.6,0, 1)
  -- bottom-left line
  Ship.Line3 = Ship:CreateLine()
  Ship.Line3:SetColorTexture(1,.6,0, 1)
  -- bottom-right line
  Ship.Line4 = Ship:CreateLine()
  Ship.Line4:SetColorTexture(1,.6,0, 1)
end

function GR:CreateAsteroidsBullets()
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids.Bullets = {}
  local Bullets = Asteroids.Bullets

  for i=1, GR.Asteroids.Const.NumOfBullets, 1 do
    Bullets[i] = CreateFrame("Frame", nil, Asteroids)
    Bullets[i]:SetPoint("BOTTOMLEFT", 0, 0)
    Bullets[i]:SetSize(2,2)
    Bullets[i].Line = Bullets[i]:CreateLine()
    Bullets[i].Line:SetThickness(4)
    Bullets[i].Line:SetColorTexture(1,0,0,1)
    Bullets[i]:Hide()

    Bullets[i].VelocityX = 0
    Bullets[i].VelocityY = 0
    Bullets[i].PosY = 0
    Bullets[i].PosX = 0
  end
end

function GR:CreateAsteroidsComets()
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids.Comets = {}
  local Comets = Asteroids.Comets


  for i=1, GR.Asteroids.Const.NumOfComets, 1 do
    local randX = (Asteroids:GetWidth() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    local randY = (Asteroids:GetHeight() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    while (randX > Asteroids:GetWidth() / 2 - 35 * GR.Asteroids.ScreenRatio and randX < Asteroids:GetWidth() / 2 + 35 * GR.Asteroids.ScreenRatio) do
      randX = (Asteroids:GetWidth() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    end
    while (randY > Asteroids:GetHeight() / 2 - 35 * GR.Asteroids.ScreenRatio and randY < Asteroids:GetHeight() / 2 + 35 * GR.Asteroids.ScreenRatio) do
      randY = (Asteroids:GetHeight() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    end
    local randVelX = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    local randVelY = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    Comets[i] = CreateFrame("Frame", Comet, Asteroids)
    Comets[i]:SetPoint("BOTTOMLEFT", randX, randY)
    Comets[i]:SetSize(GR.Asteroids.CometSize, GR.Asteroids.CometSize)
    Comets[i].PosX = randX
    Comets[i].PosY = randY
    Comets[i].VelX = randVelX
    Comets[i].VelY = randVelY
    Comets[i].RotationSpeed = GR.Asteroids.Const.CometMaxRotationSpeed * (math.random(0, 10000) / 10000)

    Comets[i].Lines = {}
    Comets[i].Points = {}
    local NumOfLines = math.random(GR.Asteroids.Const.CometMinLines, GR.Asteroids.Const.CometMaxLines)
    for j=1, NumOfLines, 1 do 
      
      local angle = (3.14159 * (4 * (j / NumOfLines))) / 2
      local y = math.random(5, 22 * GR.Asteroids.ScreenRatio)
      local x = 0
      Comets[i].Points[j] = CreateFrame("Frame", nil, Comets[i])
      local Point = Comets[i].Points[j] 
      Point.PosX = x
      Point.PosY = y
      Point.Angle = angle
      local x2, y2 = GR:RotateCoordPair(x,y, .5, .5, angle, 1)
      Point:SetPoint("CENTER", x2, y2)
      Point:SetSize(3, 3)
      
      -- draw lines
      if (j > 1) then
        local Point2 = Comets[i].Points[j - 1] 
        Comets[i].Lines[j] = Comets[i]:CreateLine()
        local Line = Comets[i].Lines[j]
        local x3, y3 = GR:RotateCoordPair(Point2.PosX, Point2.PosY, .5,.5, Point2.Angle, 1)
        Line:SetStartPoint("CENTER", Comets[i], x2, y2)
        Line:SetEndPoint("CENTER", Comets[i], x3, y3)
        Line:SetThickness(3 * GR.Asteroids.ScreenRatio)
        Line:SetColorTexture(.8,.8,.8, 1)

        -- draw last line
        if (j == NumOfLines) then
          local Point3 = Comets[i].Points[1]
          Comets[i].Lines[1] = Comets[i]:CreateLine()
          local Line = Comets[i].Lines[1]
          local x4, y4 = GR:RotateCoordPair(Point3.PosX, Point3.PosY, .5,.5, Point3.Angle, 1)
          Line:SetStartPoint("CENTER", Comets[i], x2, y2)
          Line:SetEndPoint("CENTER", Comets[i], x4, y4)
          Line:SetThickness(3 * GR.Asteroids.ScreenRatio)
          Line:SetColorTexture(.8,.8,.8, 1)
        end
      end
    end

  end
end

function GR:CreateAsteroidsFS()
  local Asteroids = GR_GUI.Main.Asteroids

  Asteroids.FS = Asteroids:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Asteroids.FS:SetTextColor(0,1,0, 1)
end

function GR:CreateAsteroidsTimer()
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids.Timer = Asteroids:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  local Timer = Asteroids.Timer
  Timer:SetText(GR.Asteroids.GameTime)
  Timer:SetTextColor(.8,.8,.8, 1)
  GR:SizeAsteroidsTimer()
end

-- resize
function GR:SizeAsteroids()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  local PauseBtn = GR_GUI.Main.Asteroids.PauseBtn
  local StopBtn = GR_GUI.Main.Asteroids.StopBtn
  
  -- Main Window
  Asteroids:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / 640))
  Asteroids:SetSize(Main:GetWidth() * (GR.Asteroids.Const.ScreenSizeX / 800), Main:GetHeight() * (GR.Asteroids.Const.ScreenSizeY / 640))
  GR.Asteroids.ScreenXRatio = Asteroids:GetWidth() / GR.Asteroids.Const.ScreenSizeX
  GR.Asteroids.ScreenYRatio = Asteroids:GetHeight() / GR.Asteroids.Const.ScreenSizeY
  GR.Asteroids.ScreenRatio = (Asteroids:GetWidth() / GR.Asteroids.Const.ScreenSizeX + Asteroids:GetHeight() / GR.Asteroids.Const.ScreenSizeY) / 2
  local WidthRatio = GR.Asteroids.ScreenXRatio
  local HeightRatio = GR.Asteroids.ScreenYRatio
  
  -- pause button
  PauseBtn:SetPoint("TOPLEFT", 15 * WidthRatio, 40 * HeightRatio)
  PauseBtn:SetSize(100 * WidthRatio, 35 * HeightRatio)
  PauseBtn.FS:SetTextScale(1.8 * ((WidthRatio + HeightRatio) / 2))
  
  -- stop button
  StopBtn:SetPoint("TOPLEFT", 120 * WidthRatio, 40 * HeightRatio)
  StopBtn:SetSize(100 * WidthRatio, 35 * HeightRatio)
  StopBtn.FS:SetTextScale(1.8 * ((WidthRatio + HeightRatio) / 2))
  
  GR:SizeAsteroidsShip(WidthRatio, HeightRatio)
  GR:SizeAsteroidsBullets()
  GR:SizeAsteroidsComets()
  GR:SizeAsteroidsFS()
  GR:SizeAsteroidsTimer()
end

function GR:SizeAsteroidsShip(WidthRatio, HeightRatio)
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = GR_GUI.Main.Asteroids.Ship

  GR.Asteroids.ShipAcceleration = GR.Asteroids.Const.ShipAcceleration * GR.Asteroids.ScreenRatio
  GR.Asteroids.ShipMaxSpeed = GR.Asteroids.Const.ShipMaxSpeed * GR.Asteroids.ScreenRatio

  Ship:SetPoint("BOTTOMLEFT", Asteroids:GetWidth() / 2, Asteroids:GetHeight() / 2)
  GR.Asteroids.ShipPosX = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipPosY = Asteroids:GetHeight() / 2
  Ship.Line1:SetThickness(3 * GR.Asteroids.ScreenRatio)
  Ship.Line2:SetThickness(3 * GR.Asteroids.ScreenRatio)
  Ship.Line3:SetThickness(3 * GR.Asteroids.ScreenRatio)
  Ship.Line4:SetThickness(3 * GR.Asteroids.ScreenRatio)
  Ship.Col:SetSize(GR.Asteroids.ShipSize, GR.Asteroids.ShipSize)

  GR.Asteroids.ShipSize = GR.Asteroids.Const.ShipSize * GR.Asteroids.ScreenRatio
  GR:AsteroidsRotateShip(Ship)
end

function GR:SizeAsteroidsBullets()
  local Bullets = GR_GUI.Main.Asteroids.Bullets
  
  GR.Asteroids.BulletSize = GR.Asteroids.Const.BulletSize * GR.Asteroids.ScreenRatio
  GR.Asteroids.BulletThickness = GR.Asteroids.Const.BulletThickness * GR.Asteroids.ScreenRatio
  GR.Asteroids.BulletSpeed = GR.Asteroids.Const.BulletSpeed * GR.Asteroids.ScreenRatio

  for i=1, #Bullets, 1 do
    Bullets[i].Line:SetThickness(GR.Asteroids.BulletThickness)
    GR:AsteroidsRotateBullet(Bullets[i])
  end
end

function GR:SizeAsteroidsComets()
  local Asteroids = GR_GUI.Main.Asteroids
  local Comets = GR_GUI.Main.Asteroids.Comets

  
  GR.Asteroids.CometSize = GR.Asteroids.Const.CometSize * GR.Asteroids.ScreenRatio
  GR.Asteroids.CometMaxSpeed = GR.Asteroids.Const.CometMaxSpeed * GR.Asteroids.ScreenRatio

  for i=1, GR.Asteroids.Const.NumOfComets, 1 do
    local randX = (Asteroids:GetWidth() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    local randY = (Asteroids:GetHeight() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    local randVelX = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    local randVelY = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    Comets[i]:SetPoint("BOTTOMLEFT", randX, randY)
    Comets[i]:SetSize(GR.Asteroids.CometSize, GR.Asteroids.CometSize)
    Comets[i].PosX = randX
    Comets[i].PosY = randY
    Comets[i].VelX = randVelX
    Comets[i].VelY = randVelY

    for j=1, #Comets[i].Points, 1 do 
      local angle = (3.14159 * (4 * (j / #Comets[i].Points))) / 2
      local y = math.random(5, 22 * GR.Asteroids.ScreenRatio)
      local x = 0
      local Point = Comets[i].Points[j] 
      Point.PosX = x
      Point.PosY = y
      Point.Angle = angle
      local x2, y2 = GR:RotateCoordPair(x,y, .5, .5, angle, 1)
      Point:SetPoint("CENTER", x2, y2)
      
      -- draw lines
      if (j > 1) then
        local Point2 = Comets[i].Points[j - 1] 
        local Line = Comets[i].Lines[j]
        local x3, y3 = GR:RotateCoordPair(Point2.PosX, Point2.PosY, .5,.5, Point2.Angle, 1)
        Line:SetStartPoint("CENTER", Comets[i], x2, y2)
        Line:SetEndPoint("CENTER", Comets[i], x3, y3)
        Line:SetThickness(3 * GR.Asteroids.ScreenRatio)
        Line:SetColorTexture(.8,.8,.8, 1)

        -- draw last line
        if (j == #Comets[i].Points) then
          local Point3 = Comets[i].Points[1]
          local Line = Comets[i].Lines[1]
          local x4, y4 = GR:RotateCoordPair(Point3.PosX, Point3.PosY, .5,.5, Point3.Angle, 1)
          Line:SetStartPoint("CENTER", Comets[i], x2, y2)
          Line:SetEndPoint("CENTER", Comets[i], x4, y4)
          Line:SetThickness(3 * GR.Asteroids.ScreenRatio)
          Line:SetColorTexture(.8,.8,.8, 1)
        end
      end
    end
  end
end

function GR:SizeAsteroidsFS()
  local FS = GR_GUI.Main.Asteroids.FS

  FS:SetTextScale(4 * (GR.Asteroids.ScreenXRatio + GR.Asteroids.ScreenYRatio) / 2)
  FS:SetPoint("TOP", 0, -100 * GR.Asteroids.ScreenYRatio)
end

function GR:SizeAsteroidsTimer()
  local Timer = GR_GUI.Main.Asteroids.Timer
  Timer:SetPoint("BOTTOMLEFT", GR_GUI.Main.Asteroids, "TOPRIGHT", -200 * GR.Asteroids.ScreenXRatio, 6 * GR.Asteroids.ScreenYRatio)
  Timer:SetTextScale(2 * GR.Asteroids.ScreenRatio)
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
  Asteroids:Show()
  Asteroids.Game:Hide()
  GR:ShowSoloGame()
end

-- functionality
function GR:AsteroidsGameLoop(self, elapsed)
  GR.Asteroids.GameTime = GR.Asteroids.GameTime + elapsed
  GR_GUI.Main.Asteroids.Timer:SetText(math.floor(GR.Asteroids.GameTime * 100) / 100)

  GR:AsteroidsUpdateShip(elapsed)
  GR:AsteroidsUpdateBullets(elapsed)
  GR:AsteroidsUpdateComets(elapsed)
  GR:AsteroidsCheckForWin()
  GR:AsteroidsCheckForLose()
end

function GR:RotateCoordPair (x,y,ox,oy,a,asp)
  y=y/asp
  oy=oy/asp
  return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
    (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
end

function GR:AsteroidsStartGame()
  local Asteroids = GR_GUI.Main.Asteroids
  local Comets = GR_GUI.Main.Asteroids.Comets
  local Bullets = GR_GUI.Main.Asteroids.Bullets
  
  -- game buttons
  GR.Asteroids.Phase = "Started"
  Asteroids.PauseBtn.FS:SetText("Pause")
  Asteroids.StopBtn:Show()
  
  Asteroids.Timer:SetText("0")
  GR.Asteroids.TimerSave = 0 
  GR.Asteroids.GameTime = 0

  -- gameover fontstring
  GR_GUI.Main.Asteroids.FS:Hide()

  -- show comets
  for i=1, #Comets, 1 do
    Comets[i]:Show()
  end

  -- hide bullets 
  for i=1, #Bullets, 1 do
    Bullets[i]:Hide()
  end

  -- start game loop
  Asteroids.Game:Show()
end

function GR:AsteroidsUnPauseGame()
  local Asteroids = GR_GUI.Main.Asteroids

  -- game buttons
  GR.Asteroids.Phase = "Started"
  Asteroids.PauseBtn.FS:SetText("Pause")
  Asteroids.StopBtn:Show()

  GR.Asteroids.GameTime = GR.Asteroids.TimerSave
  GR.Asteroids.TimerSave = 0

  -- gameover fontstring
  GR_GUI.Main.Asteroids.FS:Hide()

  -- start game loop
  Asteroids.Game:Show()
end

function GR:AsteroidsStopGame()
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = Asteroids.Ship
  local Comets = Asteroids.Comets

  -- game buttons
  GR.Asteroids.Phase = "Stopped"
  Asteroids.PauseBtn.FS:SetText("Start")
  Asteroids.StopBtn:Hide()
  
  GR.Asteroids.GameTime = GR.Asteroids.TimerSave
  GR.Asteroids.TimerSave = 0
  GR.Asteroids.ShipRotation = 0
  GR.Asteroids.ShipXVelocity = 0
  GR.Asteroids.ShipYVelocity = 0
  GR.Asteroids.ShipPosX = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipPosY = Asteroids:GetHeight() / 2
  GR.Asteroids.ShipXVelocity = 0
  GR.Asteroids.ShipYVelocity = 0
  GR.Asteroids.ShipHit = false
  GR.Asteroids.DownW = false
  GR.Asteroids.DownA = false
  GR.Asteroids.DownD = false

  -- ends game loop
  Asteroids.Game:Hide()

  -- reset ship
  Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipPosX, GR.Asteroids.ShipPosY)
  GR:AsteroidsRotateShip(Ship)

  -- reset comets
  for i=1, #Comets, 1 do
    local randX = (Asteroids:GetWidth() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    local randY = (Asteroids:GetHeight() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    while (randX > Asteroids:GetWidth() / 2 - 35 * GR.Asteroids.ScreenRatio and randX < Asteroids:GetWidth() / 2 + 35 * GR.Asteroids.ScreenRatio) do
      randX = (Asteroids:GetWidth() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    end
    while (randY > Asteroids:GetHeight() / 2 - 35 * GR.Asteroids.ScreenRatio and randY < Asteroids:GetHeight() / 2 + 35 * GR.Asteroids.ScreenRatio) do
      randY = (Asteroids:GetHeight() - GR.Asteroids.CometSize - 4) * (math.random(0, 10000) / 10000)
    end
    local randVelX = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    local randVelY = GR.Asteroids.CometMaxSpeed * (math.random(-10000, 10000) / 10000)
    Comets[i]:SetPoint("BOTTOMLEFT", randX, randY)
    Comets[i]:SetSize(GR.Asteroids.CometSize, GR.Asteroids.CometSize)
    Comets[i].PosX = randX
    Comets[i].PosY = randY
    Comets[i].VelX = randVelX
    Comets[i].VelY = randVelY
    Comets[i]:Hide()
  end
end
  
function GR:AsteroidsPauseGame()
  local Asteroids = GR_GUI.Main.Asteroids
    
  -- game buttons
  GR.Asteroids.Phase = "Paused"
  Asteroids.PauseBtn.FS:SetText("Start")

  GR.Asteroids.TimerSave = GR.Asteroids.GameTime
  
  -- pause game loop
  Asteroids.Game:Hide()
  Asteroids.Timer:SetText(math.floor(GR.Asteroids.GameTime * 100) / 100)
end

-- Bullet
function GR:AsteroidsShootBullet()
  local Bullets = GR_GUI.Main.Asteroids.Bullets
  local Ship = GR_GUI.Main.Asteroids.Ship
  local BulletShot = false


  local BulletSize = GR.Asteroids.BulletSize
  local ShipSize = GR.Asteroids.ShipSize  
  local coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  local origin={x=0.5,y=.5}
  local aspect=1
  angle= (3.14159 * GR.Asteroids.ShipRotation) / 2

  -- Bullet Start Pos
  local shooter = {}
  shooter.LLx, shooter.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
  shooter.LRx, shooter.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
  
  for i=1, #Bullets, 1 do 
    if (Bullets[i]:IsVisible() == false and BulletShot == false) then
      local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()
      BulletShot = true
      Bullets[i].PosX = (((shooter.LLx + shooter.LRx) / 2 * ShipSize) - ShipSize / 2) *1.5 + xOfs
      Bullets[i].PosY = (((shooter.LLy + shooter.LRy) / 2 * ShipSize) - ShipSize) *1.5 + yOfs + (20 * GR.Asteroids.ScreenRatio)
      Bullets[i].Angle = (3.14159 * ((-GR.Asteroids.ShipRotation -.5) % 4)) / 2
      GR:AsteroidsRotateBullet(Bullets[i])
      Bullets[i]:Show()
      if (Bullets[i].Timer) then
        Bullets[i].Timer:Cancel()
      end
      Bullets[i].Timer = C_Timer.NewTimer(GR.Asteroids.Const.BulletTimeout, function()
        Bullets[i]:Hide()
      end)
    end
  end
end

function GR:AsteroidsRotateBullet(Bullet)
  -- Rotate

  local BulletSize = GR.Asteroids.BulletSize
  local coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  local origin={x=0.5,y=.5}
  local aspect=1
  
  angle= (3.14159 * GR.Asteroids.ShipRotation) / 2
  local line = {}
  line.ULx, line.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line.LLx, line.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
  line.URx, line.URy = GR:RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle,aspect)
  line.LRx, line.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
  Bullet.Line:SetStartPoint("CENTER", ((line.LLx + line.LRx) / 2 * BulletSize) - BulletSize / 2, ((line.LLy + line.LRy) / 2 * BulletSize) - BulletSize) 
  Bullet.Line:SetEndPoint("CENTER", ((line.URx + line.ULx) / 2 * BulletSize) - BulletSize / 2, ((line.URy + line.ULy) / 2 * BulletSize) - BulletSize) 
end

-- Update
function GR:AsteroidsUpdateShip(elapsed)
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = Asteroids.Ship

  if (GR.Asteroids.DownA == true) then
    GR.Asteroids.ShipRotation = (GR.Asteroids.ShipRotation + elapsed * 2) % 4
    GR:AsteroidsRotateShip(Ship)
  end
  if (GR.Asteroids.DownD == true) then
    GR.Asteroids.ShipRotation = (GR.Asteroids.ShipRotation - elapsed * 2) % 4
    GR:AsteroidsRotateShip(Ship)
  end
  if (GR.Asteroids.DownW == true) then
    GR:AsteroidsAccelerateShip(elapsed, Asteroids, Ship)
  end

  -- speed/velocity
  GR:AsteroidsApplySpeed(elapsed, Asteroids, Ship)

  -- collisions
  GR:AsteroidsColShipWall(Asteroids, Ship)
  for i=1, #Asteroids.Bullets, 1 do
    if(Asteroids.Bullets[i]:IsVisible()) then
      GR:AsteroidsColBulletWall(Asteroids, Asteroids.Bullets[i])
    end
  end
  for i=1, #Asteroids.Comets, 1 do
    if(Asteroids.Comets[i]:IsVisible()) then
      GR:AsteroidsColShipComet(Ship, Asteroids.Comets[i])
    end
  end
end

function GR:AsteroidsAccelerateShip(elapsed, Asteroids, Ship)
  local ShipRotation = GR.Asteroids.ShipRotation

  local Angle = (3.14159 * ((-ShipRotation -.5) % 4)) / 2

  -- apply acceleration
  GR.Asteroids.ShipYVelocity = GR.Asteroids.ShipYVelocity + (math.cos(Angle) - math.sin(Angle)) * elapsed * GR.Asteroids.ShipAcceleration
  GR.Asteroids.ShipXVelocity = GR.Asteroids.ShipXVelocity + (math.cos(Angle) + math.sin(Angle)) * elapsed * GR.Asteroids.ShipAcceleration

  -- limit speed
  if (GR.Asteroids.ShipXVelocity > GR.Asteroids.ShipMaxSpeed) then
    GR.Asteroids.ShipXVelocity = GR.Asteroids.ShipMaxSpeed
  end
  if (GR.Asteroids.ShipXVelocity < -GR.Asteroids.ShipMaxSpeed) then
    GR.Asteroids.ShipXVelocity = -GR.Asteroids.ShipMaxSpeed
  end
  if (GR.Asteroids.ShipYVelocity > GR.Asteroids.ShipMaxSpeed) then
    GR.Asteroids.ShipYVelocity = GR.Asteroids.ShipMaxSpeed
  end
  if (GR.Asteroids.ShipYVelocity < -GR.Asteroids.ShipMaxSpeed) then
    GR.Asteroids.ShipYVelocity = -GR.Asteroids.ShipMaxSpeed
  end
end

function GR:AsteroidsApplySpeed(elapsed, Asteroids, Ship)
  local ShipRotation = GR.Asteroids.ShipRotation

  GR.Asteroids.ShipPosY = GR.Asteroids.ShipPosY + elapsed * GR.Asteroids.ShipYVelocity
  GR.Asteroids.ShipPosX = GR.Asteroids.ShipPosX + elapsed * GR.Asteroids.ShipXVelocity
  Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipPosX, GR.Asteroids.ShipPosY)
end

function GR:AsteroidsRotateShip(Ship)

  local ShipSize = GR.Asteroids.ShipSize  
  local coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  local origin={x=0.5,y=.5}
  local aspect=1
  angle= (3.14159 * GR.Asteroids.ShipRotation) / 2
  
  -- TopLeft Ship Line
  local line1 = {}
  line1.ULx, line1.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line1.LLx, line1.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
  line1.URx, line1.URy = GR:RotateCoordPair(coords.tr.x -.7,coords.tr.y,origin.x,origin.y,angle,aspect)
  line1.LRx, line1.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
  Ship.Line1:SetStartPoint("CENTER", ((line1.LLx + line1.LRx) / 2 * ShipSize) - ShipSize / 2, ((line1.LLy + line1.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line1:SetEndPoint("CENTER", ((line1.URx + line1.ULx) / 2 * ShipSize) - ShipSize / 2, ((line1.URy + line1.ULy) / 2 * ShipSize) - ShipSize) 
  
  -- TopRight Ship Line
  local line2 = {}
  line2.ULx, line2.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line2.LLx, line2.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
  line2.URx, line2.URy = GR:RotateCoordPair(coords.tr.x +.7,coords.tr.y,origin.x,origin.y,angle,aspect)
  line2.LRx, line2.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
  Ship.Line2:SetStartPoint("CENTER", ((line2.LLx + line2.LRx) / 2 * ShipSize) - ShipSize / 2, ((line2.LLy + line2.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line2:SetEndPoint("CENTER", ((line2.URx + line2.ULx) / 2 * ShipSize) - ShipSize / 2, ((line2.URy + line2.ULy) / 2 * ShipSize) - ShipSize) 
  
  
  -- BottomLeft Ship Line
  local line3 = {}
  line3.ULx, line3.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line3.LLx, line3.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y -.6,origin.x,origin.y,angle,aspect)
  line3.URx, line3.URy = GR:RotateCoordPair(coords.tr.x -.7,coords.tr.y,origin.x,origin.y,angle,aspect)
  line3.LRx, line3.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y -.6,origin.x,origin.y,angle,aspect)
  Ship.Line3:SetStartPoint("CENTER", ((line3.URx + line3.ULx) / 2 * ShipSize) - ShipSize / 2, ((line3.URy + line3.ULy) / 2 * ShipSize) - ShipSize) 
  Ship.Line3:SetEndPoint("CENTER", ((line3.LLx + line3.LRx) / 2 * ShipSize) - ShipSize / 2, ((line3.LLy + line3.LRy) / 2 * ShipSize) - ShipSize) 
  
  -- BottomRight Ship Line
  local line4 = {}
  line4.ULx, line4.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line4.LLx, line4.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y -.6,origin.x,origin.y,angle,aspect)
  line4.URx, line4.URy = GR:RotateCoordPair(coords.tr.x +.7,coords.tr.y,origin.x,origin.y,angle,aspect)
  line4.LRx, line4.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y -.6,origin.x,origin.y,angle,aspect)
  Ship.Line4:SetStartPoint("CENTER", ((line4.URx + line4.ULx) / 2 * ShipSize) - ShipSize / 2, ((line4.URy + line4.ULy) / 2 * ShipSize) - ShipSize) 
  Ship.Line4:SetEndPoint("CENTER", ((line4.LLx + line4.LRx) / 2 * ShipSize) - ShipSize / 2, ((line4.LLy + line4.LRy) / 2 * ShipSize) - ShipSize) 
  
  -- Collision Frame
  -- local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()
  local line5 = {}
  line5.ULx, line5.ULy = GR:RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line5.LLx, line5.LLy = GR:RotateCoordPair(coords.bl.x,coords.bl.y -.5,origin.x,origin.y,angle,aspect)
  line5.URx, line5.URy = GR:RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle,aspect)
  line5.LRx, line5.LRy = GR:RotateCoordPair(coords.br.x,coords.br.y -.5,origin.x,origin.y,angle,aspect)
  Ship.Col:SetPoint("CENTER", ((line5.LLx + line5.LRx) / 2 * ShipSize) - ShipSize / 2, ((line5.LLy + line5.LRy) / 2 * ShipSize) - ShipSize) 
end

function GR:AsteroidsUpdateBullets(elapsed)
  local Bullets = GR_GUI.Main.Asteroids.Bullets

  for i=1, #Bullets, 1 do
    if (Bullets[i]:IsVisible()) then
      Bullets[i].PosY = Bullets[i].PosY + (math.cos(Bullets[i].Angle) - math.sin(Bullets[i].Angle)) * elapsed * GR.Asteroids.BulletSpeed
      Bullets[i].PosX = Bullets[i].PosX + (math.cos(Bullets[i].Angle) + math.sin(Bullets[i].Angle)) * elapsed * GR.Asteroids.BulletSpeed
      Bullets[i]:SetPoint("BOTTOMLEFT", Bullets[i].PosX, Bullets[i].PosY)
    end
  end
end

function GR:AsteroidsUpdateComets(elapsed)
  local Comets = GR_GUI.Main.Asteroids.Comets
  local Bullets = GR_GUI.Main.Asteroids.Bullets

  
  for i=1, #Comets, 1 do 
    Comets[i].PosX = Comets[i].PosX + Comets[i].VelX * elapsed
    Comets[i].PosY = Comets[i].PosY + Comets[i].VelY * elapsed
    Comets[i]:SetPoint("BOTTOMLEFT", Comets[i].PosX, Comets[i].PosY)
    
    for j=1, #Comets[i].Points, 1 do
      local Point = Comets[i].Points[j]
      Point.Angle = (Point.Angle + elapsed * Comets[i].RotationSpeed) % (3.14159 * 2)
      local x, y = GR:RotateCoordPair(Point.PosX,Point.PosY, .5,.5, Point.Angle, 1)
      Comets[i].Points[j]:SetPoint("CENTER", x, y)
        
      -- draw lines
      if (j > 1) then
        local Point2 = Comets[i].Points[j - 1] 
        local Line = Comets[i].Lines[j]
        local x3, y3 = GR:RotateCoordPair(Point2.PosX, Point2.PosY, .5,.5, Point2.Angle, 1)
        Line:SetStartPoint("CENTER", Comets[i], x, y)
        Line:SetEndPoint("CENTER", Comets[i], x3, y3)

        -- draw last line
        if (j == #Comets[i].Points) then
          local Point3 = Comets[i].Points[1]
          local Line = Comets[i].Lines[1]
          local x4, y4 = GR:RotateCoordPair(Point3.PosX, Point3.PosY, .5,.5, Point3.Angle, 1)
          Line:SetStartPoint("CENTER", Comets[i], x, y)
          Line:SetEndPoint("CENTER", Comets[i], x4, y4)
        end
      end
    end
    
    
    
    GR:AsteroidsColCometWall(GR_GUI.Main.Asteroids, Comets[i])

    for j=1, #Bullets, 1 do 
      GR:AsteroidsColCometBullet(GR_GUI.Main.Asteroids, Comets[i], Bullets[j])
    end
  end
end

function GR:AsteroidsCheckForWin()
  local Comets = GR_GUI.Main.Asteroids.Comets
  local GameOver = true

  for i=1, #Comets, 1 do
    if (Comets[i]:IsVisible()) then
      GameOver = false
    end
  end

  if (GameOver) then 
    GR_GUI.Main.Asteroids.FS:SetText("Winner!")
    GR_GUI.Main.Asteroids.FS:SetTextColor(0,1,0, 1)
    GR_GUI.Main.Asteroids.FS:Show()
    GR:AsteroidsStopGame()
  end 
end

function GR:AsteroidsCheckForLose()
  if (GR.Asteroids.ShipHit == true) then
    GR_GUI.Main.Asteroids.FS:SetText("Game Over")
    GR_GUI.Main.Asteroids.FS:SetTextColor(1,0,0, .8)
    GR_GUI.Main.Asteroids.FS:Show()
    GR:AsteroidsStopGame()
  end
end

-- Collision
function GR:AsteroidsColShipWall(Asteroids, Ship)
  local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()
  local Cpoint, CrelativeTo, CrelativePoint, CxOfs, CyOfs = Ship.Col:GetPoint()

  local Shipx = {
    LLx = xOfs +CxOfs - GR.Asteroids.ShipSize / 2,
    LLy = yOfs +CyOfs - GR.Asteroids.ShipSize / 2,
    URx = xOfs +CxOfs + GR.Asteroids.ShipSize / 2,
    URy = yOfs +CyOfs + GR.Asteroids.ShipSize / 2
  }
  local Border = {
    LLx = 0,
    LLy = 0,
    URx = Asteroids:GetWidth(),
    URy = Asteroids:GetHeight()
  }
  
  -- check if ship is outside of border
  -- ship left past border left
  if (Shipx.LLx < Border.LLx) then 
    GR.Asteroids.ShipPosX = Asteroids:GetWidth() - GR.Asteroids.ShipSize
  end
  -- ship right past border right
  if (Shipx.URx > Border.URx) then 
    GR.Asteroids.ShipPosX = 0 + GR.Asteroids.ShipSize
  end
  -- ship bottom past border bottom
  if (Shipx.LLy < Border.LLy) then 
    GR.Asteroids.ShipPosY = Asteroids:GetHeight() - GR.Asteroids.ShipSize
  end
  -- ship top past border top
  if (Shipx.URy > Border.URy) then 
    GR.Asteroids.ShipPosY = 0 + GR.Asteroids.ShipSize
  end
end

function GR:AsteroidsColBulletWall(Asteroids, Bullet)
  local relativePoint, relativeTo, SxOfs, SyOfs = Bullet.Line:GetStartPoint()
  local relativePoint, relativeTo, ExOfs, EyOfs = Bullet.Line:GetEndPoint()
  local Bulletx = {
    LLx = Bullet.PosX + SxOfs,
    LLy = Bullet.PosY + SyOfs,
    URx = Bullet.PosX + SxOfs +5 * ((GR.Asteroids.ScreenXRatio * GR.Asteroids.ScreenYRatio) /2),
    URy = Bullet.PosY + SyOfs +5 * ((GR.Asteroids.ScreenXRatio * GR.Asteroids.ScreenYRatio) /2)
  }
  local Border = {
    LLx = 0,
    LLy = 0,
    URx = Asteroids:GetWidth(),
    URy = Asteroids:GetHeight()
  }
  
  -- check if bullet is outside of border
  -- bullet left past border left
  if (Bulletx.LLx < Border.LLx) then 
    Bullet.PosX = Asteroids:GetWidth() - GR.Asteroids.BulletSize
  end
  -- bullet right past border right
  if (Bulletx.URx > Border.URx) then 
    Bullet.PosX = 0 + GR.Asteroids.BulletSize
  end
  -- bullet bottom past border bottom
  if (Bulletx.LLy < Border.LLy) then 
    Bullet.PosY = Asteroids:GetHeight() - GR.Asteroids.BulletSize
  end
  -- bullet top past border top
  if (Bulletx.URy > Border.URy) then 
    Bullet.PosY = 0 + GR.Asteroids.BulletSize
  end
end

function GR:AsteroidsColCometWall(Asteroids, Comet)
  if (Comet:IsVisible()) then
    local point, relativeTo, relativePoint, xOfs, yOfs = Comet:GetPoint()
    local Cometx = {
      LLx = xOfs,
      LLy = yOfs,
      URx = xOfs + Comet:GetWidth(),
      URy = yOfs + Comet:GetHeight()
    }
    local Border = {
      LLx = 0,
      LLy = 0,
      URx = Asteroids:GetWidth(),
      URy = Asteroids:GetHeight()
    }
    
    -- check if commet is outside of border
    -- commet left past border left
    if (Cometx.LLx < Border.LLx) then 
      Comet.PosX = Asteroids:GetWidth() - GR.Asteroids.CometSize
    end
    -- commet right past border right
    if (Cometx.URx > Border.URx) then 
      Comet.PosX = 0 + GR.Asteroids.CometSize
    end
    -- commet bottom past border bottom
    if (Cometx.LLy < Border.LLy) then 
      Comet.PosY = Asteroids:GetHeight() - GR.Asteroids.CometSize
    end
    -- commet top past border top
    if (Cometx.URy > Border.URy) then 
      Comet.PosY = 0 + GR.Asteroids.CometSize
    end
  end
end

function GR:AsteroidsColCometBullet(Asteroids, Comet, Bullet)
  if (Comet:IsVisible() and Bullet:IsVisible()) then
    local point, relativeTo, relativePoint, xOfs, yOfs = Comet:GetPoint()
    local Cometx = {
      LLx = xOfs,
      LLy = yOfs,
      URx = xOfs + Comet:GetWidth(),
      URy = yOfs + Comet:GetHeight()
    }
    local relativePoint, relativeTo, SxOfs, SyOfs = Bullet.Line:GetStartPoint()
    local relativePoint, relativeTo, ExOfs, EyOfs = Bullet.Line:GetEndPoint()
    local Bulletx = {
      LLx = Bullet.PosX + SxOfs,
      LLy = Bullet.PosY + SyOfs,
      URx = Bullet.PosX + SxOfs +0 * ((GR.Asteroids.ScreenXRatio * GR.Asteroids.ScreenYRatio) /2),
      URy = Bullet.PosY + SyOfs +0 * ((GR.Asteroids.ScreenXRatio * GR.Asteroids.ScreenYRatio) /2)
    }

      -- check if bullet is inside of comet
    if ((Bulletx.URx > Cometx.LLx and Bulletx.LLx < Cometx.URx) and (Bulletx.URy > Cometx.LLy and Bulletx.LLy < Cometx.URy)) then 
      Bullet:Hide()
      Comet:Hide()
    end
  end
end

function GR:AsteroidsColShipComet(Ship, Comet)
  local Apoint, ArelativeTo, ArelativePoint, AxOfs, AyOfs = Comet:GetPoint()
  local Cometx = {
    LLx = AxOfs,
    LLy = AyOfs,
    URx = AxOfs + Comet:GetWidth(),
    URy = AyOfs + Comet:GetHeight()
  }

  local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()
  local Cpoint, CrelativeTo, CrelativePoint, CxOfs, CyOfs = Ship.Col:GetPoint()
  local Shipx = {
    LLx = (xOfs +CxOfs - GR.Asteroids.ShipSize / 2) + 13 * GR.Asteroids.ScreenRatio,
    LLy = (yOfs +CyOfs - GR.Asteroids.ShipSize / 2) + 13 * GR.Asteroids.ScreenRatio,
    URx = (xOfs +CxOfs + GR.Asteroids.ShipSize / 2) - 13 * GR.Asteroids.ScreenRatio,
    URy = (yOfs +CyOfs + GR.Asteroids.ShipSize / 2) - 13 * GR.Asteroids.ScreenRatio
  }

    -- check if ship is inside of comet
    if ((Shipx.URx > Cometx.LLx and Shipx.LLx < Cometx.URx) and (Shipx.URy > Cometx.LLy and Shipx.LLy < Cometx.URy)) then 
      GR.Asteroids.ShipHit = true
    end
end

-- timer needs to stay on game end, reset at game start
-- pause shouldn't reset asteroids position

