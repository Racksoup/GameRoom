-- create
function GR:CreateAsteroids()
  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / 640))
  Asteroids:SetSize(GR_GUI.Main:GetWidth() * (500 / 800), GR_GUI.Main:GetHeight() * (500 / 640))
  Asteroids:Hide()

  GR.Asteroids = {}
  GR.Asteroids.Phase = "Stopped"
  GR.Asteroids.GameTime = 0
  GR.Asteroids.ShipRotation = 0.0
  GR.Asteroids.ShipAcceleration = 100
  GR.Asteroids.ShipDesceleration = -1
  GR.Asteroids.ShipMaxSpeed = 80
  GR.Asteroids.ShipXVelocity = 0
  GR.Asteroids.ShipYVelocity = 0
  GR.Asteroids.ShipPosX = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipPosY = Asteroids:GetHeight() / 2
  
  
  -- Create
  GR:CreateAsteroidsGameLoop()
  GR:CreateAsteroidsGameButtons()
  GR:CreateAsteroidsShip()

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
  
  
  -- test
  Asteroids.Test = CreateFrame("Frame", Test, Asteroids)
  Asteroids.Test:SetPoint("BOTTOMLEFT", 40, 40)
  Asteroids.Test:SetSize(20, 20)
  Asteroids.Test.TestTex = Asteroids.Test:CreateTexture()
  Asteroids.Test.TestTex:SetAllPoints(Asteroids.Test)
  Asteroids.Test.TestTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship3.blp")
  Asteroids.Test.TestTex:SetTexCoord(0,0, 0,1, 1,0, 1,1)
  
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

  -- top-left line
  Ship.Line1:SetStartPoint("CENTER", -15, -15)
  Ship.Line1:SetEndPoint("CENTER", 0, 25)
  Ship.Line1:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- top-right line
  Ship.Line2:SetStartPoint("CENTER", 15, -15)
  Ship.Line2:SetEndPoint("CENTER", 0, 25)
  Ship.Line2:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- bottom-left line
  Ship.Line3:SetStartPoint("CENTER", -15, -15)
  Ship.Line3:SetEndPoint("CENTER", 0, 0)
  Ship.Line3:SetThickness(3 * ((WidthRatio + HeightRatio) / 2))
  -- bottom-right line
  Ship.Line4:SetStartPoint("CENTER", 15, -15)
  Ship.Line4:SetEndPoint("CENTER", 0, 0)
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
  GR.Asteroids.GameTime = GR.Asteroids.GameTime + elapsed
  -- print(GR.Asteroids.GameTime)

  GR:AsteroidsUpdateShip(elapsed)
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
  
  -- game buttons
  GR.Asteroids.Phase = "Stopped"
  Asteroids.PauseBtn.FS:SetText("Start")
  Asteroids.StopBtn:Hide()
  
  -- ends game loop
  Asteroids.Game:Hide()
  GR.Asteroids.GameTime = 0
  GR.Asteroids.ShipXPos = Asteroids:GetWidth() / 2
  GR.Asteroids.ShipYPos = Asteroids:GetHeight() / 2
end
  
function GR:AsteroidsPauseGame()
  local Asteroids = GR_GUI.Main.Asteroids
    
  -- game buttons
  GR.Asteroids.Phase = "Paused"
  Asteroids.PauseBtn.FS:SetText("Start")
  
  -- pause game loop
  Asteroids.Game:Hide()
end

-- Update
function GR:AsteroidsUpdateShip(elapsed)
  local Asteroids = GR_GUI.Main.Asteroids
  local Ship = Asteroids.Ship

  --Ship:SetPoint("BOTTOMLEFT", Asteroids:GetWidth() / 2 + GR.Asteroids.GameTime * 20, Asteroids:GetHeight() / 2 + GR.Asteroids.GameTime * 20)

  if (GR.Asteroids.DownA == true) then
    GR.Asteroids.ShipRotation = (GR.Asteroids.ShipRotation + elapsed * 2) % 4
    GR:AsteroidsRotateShip(elapsed, Asteroids, Ship)
  end
  if (GR.Asteroids.DownD == true) then
    GR.Asteroids.ShipRotation = (GR.Asteroids.ShipRotation - elapsed * 2) % 4
    GR:AsteroidsRotateShip(elapsed, Asteroids, Ship)
  end
  if (GR.Asteroids.DownW == true) then
    GR:AsteroidsAccelerateShip(elapsed, Asteroids, Ship)
  end

  GR:AsteroidsApplySpeed(elapsed, Asteroids, Ship)
end

function GR:AsteroidsAccelerateShip(elapsed, Asteroids, Ship)
  local ShipRotation = GR.Asteroids.ShipRotation

  local Angle = (3.14159 * ((-ShipRotation -.66) % 4)) / 2

  -- apply acceleration
  GR.Asteroids.ShipYVelocity = GR.Asteroids.ShipYVelocity + (math.cos(Angle) - math.sin(Angle)) * elapsed * 80
  GR.Asteroids.ShipXVelocity = GR.Asteroids.ShipXVelocity + (math.cos(Angle) + math.sin(Angle)) * elapsed * 80

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

function GR:AsteroidsRotateShip(elapsed, Asteroids, Ship)
  function RotateCoordPair (x,y,ox,oy,a,asp)
    y=y/asp
    oy=oy/asp
    return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
      (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
  end

  coords={tl={x=0,y=0},
  bl={x=0,y=1},
  tr={x=1,y=0},
  br={x=1,y=1}}
  origin={x=0.5,y=1}
  aspect=1
  
  -- TopLeft Ship Line
  angle1= (3.14159 * GR.Asteroids.ShipRotation) / 2
  local line1 = {}
  line1.ULx, line1.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle1,aspect)
  line1.LLx, line1.LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle1,aspect)
  line1.URx, line1.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle1,aspect)
  line1.LRx, line1.LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle1,aspect)
  Ship.Line1:SetStartPoint("CENTER", ((line1.LLx + line1.LRx) / 2 * 40) - 40 / 2, ((line1.LLy + line1.LRy) / 2 * 40) - 40) 
  Ship.Line1:SetEndPoint("CENTER", ((line1.URx + line1.ULx) / 2 * 40) - 40 / 2, ((line1.URy + line1.ULy) / 2 * 40) - 40) 
  
  -- TopRight Ship Line
  angle2= (3.14159 * (GR.Asteroids.ShipRotation + 0.4)) / 2
  local line2 = {}
  line2.ULx, line2.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle2,aspect)
  line2.LLx, line2.LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle2,aspect)
  line2.URx, line2.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle2,aspect)
  line2.LRx, line2.LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle2,aspect)
  Ship.Line2:SetStartPoint("CENTER", ((line2.LLx + line2.LRx) / 2 * 40) - 40 / 2, ((line2.LLy + line2.LRy) / 2 * 40) - 40) 
  Ship.Line2:SetEndPoint("CENTER", ((line2.URx + line2.ULx) / 2 * 40) - 40 / 2, ((line2.URy + line2.ULy) / 2 * 40) - 40) 
  
  
  -- BottomLeft Ship Line
  angle3= (3.14159 * (GR.Asteroids.ShipRotation + 0.4)) / 2
  local line3 = {}
  line3.ULx, line3.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle3,aspect)
  line3.LLx, line3.LLy = RotateCoordPair(coords.bl.x -.333,coords.bl.y,origin.x,origin.y,angle3,aspect)
  line3.URx, line3.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle3,aspect)
  line3.LRx, line3.LRy = RotateCoordPair(coords.br.x,coords.br.y -1,origin.x,origin.y,angle3,aspect)
  Ship.Line3:SetStartPoint("CENTER", ((line3.LLx + line3.LRx) / 2 * 40) - 40 / 2, ((line3.LLy + line3.LRy) / 2 * 40) - 40) 
  Ship.Line3:SetEndPoint("CENTER", ((line3.URx + line3.ULx) / 2 * 40) - 40 / 2, ((line3.URy + line3.ULy) / 2 * 40) - 40) 
  
  -- BottomRight Ship Line
  angle4= (3.14159 * GR.Asteroids.ShipRotation) / 2
  local line4 = {}
  line4.ULx, line4.ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle4,aspect)
  line4.LLx, line4.LLy = RotateCoordPair(coords.bl.x -.333,coords.bl.y,origin.x,origin.y,angle3,aspect)
  line4.URx, line4.URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle4,aspect)
  line4.LRx, line4.LRy = RotateCoordPair(coords.br.x,coords.br.y -1,origin.x,origin.y,angle3,aspect)
  Ship.Line4:SetStartPoint("CENTER", ((line4.LLx + line4.LRx) / 2 * 40) - 40 / 2, ((line4.LLy + line4.LRy) / 2 * 40) - 40) 
  Ship.Line4:SetEndPoint("CENTER", ((line4.URx + line4.ULx) / 2 * 40) - 40 / 2, ((line4.URy + line4.ULy) / 2 * 40) - 40) 
  
  Asteroids.Test.TestTex:SetTexCoord(line1.ULx, line1.ULy, line1.LLx, line1.LLy, line1.URx, line1.URy, line1.LRx, line1.LRy)

end

