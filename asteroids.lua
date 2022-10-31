-- create
function GR:CreateAsteroids()
  -- Constants
  GR.Asteroids = {}
  GR.Asteroids.Const = {}
  GR.Asteroids.Const.ShipSize = 40
  GR.Asteroids.Const.ShipMaxSpeed = 80
  GR.Asteroids.Const.ShipAcceleration = 100
  GR.Asteroids.Const.ScreenSizeX = 750
  GR.Asteroids.Const.ScreenSizeY = 500
  GR.Asteroids.Const.ColSize = 25
  GR.Asteroids.Const.BulletSize = 20
  GR.Asteroids.Const.BulletThickness = 4
  GR.Asteroids.Const.BulletSpeed = 120
  
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
  GR.Asteroids.ShipRotation = -.165
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
  
  -- Create
  GR:CreateAsteroidsGameLoop()
  GR:CreateAsteroidsGameButtons()
  GR:CreateAsteroidsShip()
  GR:CreateAsteroidsBullets()

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
  PauseBtn.FS = PauseBtn:CreateFontString(PauseBtn, "HIGH", "GameTooltipText")
  PauseBtn.FS:SetPoint("CENTER")
  PauseBtn.FS:SetTextColor(.8,.8,.8, 1)
  PauseBtn.FS:SetText("Start")
  PauseBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then
      if (GR.Asteroids.Phase == "Stopped" or GR.Asteroids.Phase == "Paused") then
        -- start game
        GR:AsteroidsStartGame()      
      elseif (GR.Asteroids.Phase == "Started") then
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
  Ship.Line1:SetColorTexture(.8,.8,.8, 1)
  -- top-right line
  Ship.Line2 = Ship:CreateLine()
  Ship.Line2:SetColorTexture(.5,1,0, 1)
  -- bottom-left line
  Ship.Line3 = Ship:CreateLine()
  Ship.Line3:SetColorTexture(1,0,1, 1)
  -- bottom-right line
  Ship.Line4 = Ship:CreateLine()
  Ship.Line4:SetColorTexture(0,.4,1, 1)
end

function GR:CreateAsteroidsBullets()
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids.Bullets = {}
  local Bullets = Asteroids.Bullets

  for i=1, 4, 1 do
    Bullets[i] = CreateFrame("Frame", nil, Asteroids)
    Bullets[i]:SetPoint("BOTTOMLEFT", 0, 0)
    Bullets[i]:SetSize(2,2)
    Bullets[i].Line = Bullets[i]:CreateLine()
    Bullets[i].Line:SetThickness(4)
    Bullets[i].Line:SetColorTexture(1,1,1,1)
    Bullets[i]:Hide()

    Bullets[i].VelocityX = 0
    Bullets[i].VelocityY = 0
    Bullets[i].PosY = 0
    Bullets[i].PosX = 0
  end
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
end

function GR:SizeAsteroidsShip(WidthRatio, HeightRatio)
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = GR_GUI.Main.Asteroids.Ship
  local ScreenRatio = ((Asteroids:GetWidth() / GR.Asteroids.Const.ScreenSizeX + Asteroids:GetHeight() / GR.Asteroids.Const.ScreenSizeY) / 2)

  GR.Asteroids.ShipAcceleration = GR.Asteroids.Const.ShipAcceleration * ScreenRatio
  GR.Asteroids.ShipMaxSpeed = GR.Asteroids.Const.ShipMaxSpeed * ScreenRatio


  Ship.Line1:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  Ship.Line2:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  Ship.Line3:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  Ship.Line4:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  Ship.Col:SetSize(GR.Asteroids.Const.ColSize * GR.Asteroids.ScreenXRatio, GR.Asteroids.Const.ColSize * GR.Asteroids.ScreenYRatio)

  GR.Asteroids.ShipSize = GR.Asteroids.Const.ShipSize * ((WidthRatio + HeightRatio) / 2)
  GR:AsteroidsRotateShip(Ship)
end

function GR:SizeAsteroidsBullets()
  local Bullets = GR_GUI.Main.Asteroids.Bullets
  
  GR.Asteroids.BulletSize = GR.Asteroids.Const.BulletSize * ((GR.Asteroids.ScreenXRatio + GR.Asteroids.ScreenYRatio) / 2)
  GR.Asteroids.BulletThickness = GR.Asteroids.Const.BulletThickness * ((GR.Asteroids.ScreenXRatio + GR.Asteroids.ScreenYRatio) / 2)
  GR.Asteroids.BulletSpeed = GR.Asteroids.Const.BulletSpeed * ((GR.Asteroids.ScreenXRatio + GR.Asteroids.ScreenYRatio) / 2)

  for i=1, #Bullets, 1 do
    Bullets[i].Line:SetThickness(GR.Asteroids.BulletThickness)
    GR:AsteroidsPosAndRotateBullet(Bullets[i])
  end
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
  GR.Asteroids.GameTime = GR.Asteroids.GameTime + elapsed

  GR:AsteroidsUpdateShip(elapsed)
  GR:AsteroidsUpdateBullets(elapsed)
end

function GR:AsteroidsStartGame()
  local Asteroids = GR_GUI.Main.Asteroids

  -- game buttons
  GR.Asteroids.Phase = "Started"
  Asteroids.PauseBtn.FS:SetText("Pause")
  Asteroids.StopBtn:Show()

  -- start game loop
  Asteroids.Game:Show()
end

function GR:AsteroidsStopGame()
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = Asteroids.Ship

  -- game buttons
  GR.Asteroids.Phase = "Stopped"
  Asteroids.PauseBtn.FS:SetText("Start")
  Asteroids.StopBtn:Hide()
  
  -- ends game loop
  Asteroids.Game:Hide()
  GR.Asteroids.GameTime = 0
  GR.Asteroids.ShipRotation = -.165
  GR.Asteroids.ShipXVelocity = 0
  GR.Asteroids.ShipYVelocity = 0
  GR.Asteroids.ShipPosX = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipPosY = Asteroids:GetHeight() / 2

  Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipPosX, GR.Asteroids.ShipPosY)
  GR:AsteroidsRotateShip(Ship)
end
  
function GR:AsteroidsPauseGame()
  local Asteroids = GR_GUI.Main.Asteroids
    
  -- game buttons
  GR.Asteroids.Phase = "Paused"
  Asteroids.PauseBtn.FS:SetText("Start")
  
  -- pause game loop
  Asteroids.Game:Hide()
end

-- Bullet
function GR:AsteroidsShootBullet()
  local Bullets = GR_GUI.Main.Asteroids.Bullets
  local BulletShot = false

  for i=1, #Bullets, 1 do 
    if (Bullets[i]:IsVisible() == false and BulletShot == false) then
      BulletShot = true
      Bullets[i].PosX = GR.Asteroids.ShipPosX
      Bullets[i].PosY = GR.Asteroids.ShipPosY
      Bullets[i].Angle = (3.14159 * ((-GR.Asteroids.ShipRotation -.66) % 4)) / 2
      GR:AsteroidsPosAndRotateBullet(Bullets[i])
      Bullets[i]:Show()
      C_Timer.After(5, function()
        Bullets[i]:Hide()
      end)
    end
  end
end

function GR:AsteroidsPosAndRotateBullet(Bullet)
  -- Rotate
  local function RotateCoordPair (x,y,ox,oy,a,asp)
    y=y/asp
    oy=oy/asp
    return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
      (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
  end

  local BulletSize = GR.Asteroids.BulletSize
  local coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  local origin={x=0.5,y=1}
  local aspect=1
  
  angle= (3.14159 * (GR.Asteroids.ShipRotation + 0.2)) / 2
  local line = {}
  line.ULx, line.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
  line.LLx, line.LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
  line.URx, line.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle,aspect)
  line.LRx, line.LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
  Bullet.Line:SetStartPoint("CENTER", ((line.LLx + line.LRx) / 2 * BulletSize) - BulletSize / 2, ((line.LLy + line.LRy) / 2 * BulletSize) - BulletSize) 
  Bullet.Line:SetEndPoint("CENTER", ((line.URx + line.ULx) / 2 * BulletSize) - BulletSize / 2, ((line.URy + line.ULy) / 2 * BulletSize) - BulletSize) 
 
  -- Position
  local Ship = GR_GUI.Main.Asteroids.Ship
  local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()
  Bullet:SetPoint("BOTTOMLEFT", xOfs, yOfs)

  -- Velocity

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
end

function GR:AsteroidsAccelerateShip(elapsed, Asteroids, Ship)
  local ShipRotation = GR.Asteroids.ShipRotation

  local Angle = (3.14159 * ((-ShipRotation -.66) % 4)) / 2

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

  local Angle = (3.14159 * ((-ShipRotation -.66) % 4)) / 2

  GR.Asteroids.ShipPosY = GR.Asteroids.ShipPosY + elapsed * GR.Asteroids.ShipYVelocity
  GR.Asteroids.ShipPosX = GR.Asteroids.ShipPosX + elapsed * GR.Asteroids.ShipXVelocity
  Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipPosX, GR.Asteroids.ShipPosY)
end

function GR:AsteroidsRotateShip(Ship)
  local function RotateCoordPair (x,y,ox,oy,a,asp)
    y=y/asp
    oy=oy/asp
    return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
      (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
  end

  local ShipSize = GR.Asteroids.ShipSize  
  local coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  local origin={x=0.5,y=1}
  local aspect=1
  
  -- TopLeft Ship Line
  angle1= (3.14159 * GR.Asteroids.ShipRotation) / 2
  local line1 = {}
  line1.ULx, line1.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle1,aspect)
  line1.LLx, line1.LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle1,aspect)
  line1.URx, line1.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle1,aspect)
  line1.LRx, line1.LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle1,aspect)
  Ship.Line1:SetStartPoint("CENTER", ((line1.LLx + line1.LRx) / 2 * ShipSize) - ShipSize / 2, ((line1.LLy + line1.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line1:SetEndPoint("CENTER", ((line1.URx + line1.ULx) / 2 * ShipSize) - ShipSize / 2, ((line1.URy + line1.ULy) / 2 * ShipSize) - ShipSize) 
  
  -- TopRight Ship Line
  angle2= (3.14159 * (GR.Asteroids.ShipRotation + 0.4)) / 2
  local line2 = {}
  line2.ULx, line2.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle2,aspect)
  line2.LLx, line2.LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle2,aspect)
  line2.URx, line2.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle2,aspect)
  line2.LRx, line2.LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle2,aspect)
  Ship.Line2:SetStartPoint("CENTER", ((line2.LLx + line2.LRx) / 2 * ShipSize) - ShipSize / 2, ((line2.LLy + line2.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line2:SetEndPoint("CENTER", ((line2.URx + line2.ULx) / 2 * ShipSize) - ShipSize / 2, ((line2.URy + line2.ULy) / 2 * ShipSize) - ShipSize) 
  
  
  -- BottomLeft Ship Line
  angle3= (3.14159 * (GR.Asteroids.ShipRotation + 0.4)) / 2
  local line3 = {}
  line3.ULx, line3.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle3,aspect)
  line3.LLx, line3.LLy = RotateCoordPair(coords.bl.x -.333,coords.bl.y,origin.x,origin.y,angle3,aspect)
  line3.URx, line3.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle3,aspect)
  line3.LRx, line3.LRy = RotateCoordPair(coords.br.x,coords.br.y -1,origin.x,origin.y,angle3,aspect)
  Ship.Line3:SetStartPoint("CENTER", ((line3.LLx + line3.LRx) / 2 * ShipSize) - ShipSize / 2, ((line3.LLy + line3.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line3:SetEndPoint("CENTER", ((line3.URx + line3.ULx) / 2 * ShipSize) - ShipSize / 2, ((line3.URy + line3.ULy) / 2 * ShipSize) - ShipSize) 
  
  -- BottomRight Ship Line
  angle4= (3.14159 * GR.Asteroids.ShipRotation) / 2
  local line4 = {}
  line4.ULx, line4.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle4,aspect)
  line4.LLx, line4.LLy = RotateCoordPair(coords.bl.x -.333,coords.bl.y,origin.x,origin.y,angle3,aspect)
  line4.URx, line4.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle4,aspect)
  line4.LRx, line4.LRy = RotateCoordPair(coords.br.x,coords.br.y -1,origin.x,origin.y,angle3,aspect)
  Ship.Line4:SetStartPoint("CENTER", ((line4.LLx + line4.LRx) / 2 * ShipSize) - ShipSize / 2, ((line4.LLy + line4.LRy) / 2 * ShipSize) - ShipSize) 
  Ship.Line4:SetEndPoint("CENTER", ((line4.URx + line4.ULx) / 2 * ShipSize) - ShipSize / 2, ((line4.URy + line4.ULy) / 2 * ShipSize) - ShipSize) 

  -- Collision Frame
  Ship.Col:SetPoint("CENTER", ((line4.LLx + line4.LRx) / 2 * ShipSize) - ShipSize / 2, ((line4.LLy + line4.LRy) / 2 * ShipSize) - ShipSize)
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

-- Collision
function GR:AsteroidsColShipWall(Asteroids, Ship)
  local point, relativeTo, relativePoint, xOfs, yOfs = Ship:GetPoint()

  local Shipx = {
    LLx = xOfs,
    LLy = yOfs,
    URx = xOfs + Ship:GetWidth(),
    URy = yOfs + Ship:GetHeight()
  }
  local Border = {
    LLx = 0,
    LLy = 0,
    URx = Asteroids:GetWidth(),
    URy = Asteroids:GetHeight()
  }
  
  -- check if ship is outside of border
  -- ship right past border left
  if (Shipx.URx < Border.LLx) then 
    GR.Asteroids.ShipPosX = Asteroids:GetWidth() - GR.Asteroids.ShipSize
  end
  -- ship left past border right
  if (Shipx.LLx > Border.URx) then 
    GR.Asteroids.ShipPosX = 0 + GR.Asteroids.ShipSize
  end
  -- ship top past border bottom
  if (Shipx.URy < Border.LLy) then 
    GR.Asteroids.ShipPosY = Asteroids:GetHeight() - GR.Asteroids.ShipSize
  end
  -- ship bottom past border top
  if (Shipx.LLy > Border.URy) then 
    GR.Asteroids.ShipPosY = 0 + GR.Asteroids.ShipSize
  end
end

