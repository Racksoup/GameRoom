-- create
function GR:CreateAsteroids()
  GR.Asteroids = {}
  GR.Asteroids.Phase = "Stopped"
  GR.Asteroids.GameTime = 0

  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / 640))
  Asteroids:SetSize(GR_GUI.Main:GetWidth() * (500 / 800), GR_GUI.Main:GetHeight() * (500 / 640))
  Asteroids:Hide()

  
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
  Ship:SetSize(20, 20)

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

  -- local s2 = sqrt(2);
  -- local cos, sin, rad = math.cos, math.sin, math.rad;
  -- local function CalculateCorner(angle)
  --   local r = rad(angle);
  --   return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
  -- end
  -- local function RotateTexture(texture, angle)
  --   local LRx, LRy = CalculateCorner(angle + 45);
  --   local LLx, LLy = CalculateCorner(angle + 135);
  --   local ULx, ULy = CalculateCorner(angle + 225);
  --   local URx, URy = CalculateCorner(angle - 45);
    
  --   texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
  -- end

  function RotateCoordPair (x,y,ox,oy,a,asp)
    y=y/asp
    oy=oy/asp
    return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
      (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
  end


  if (GR.Asteroids.DownA == true) then
    --RotateTexture(Asteroids.Test.TestTex, 39)
    coords={tl={x=0,y=0},
		bl={x=0,y=1},
		tr={x=1,y=0},
		br={x=1,y=1}}
    origin={x=0.5,y=0.5}
    aspect=1
    angle= (3.14159 * (GR.Asteroids.GameTime % 4)) / 2
    local ULx, ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
    local LLx, LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
    local URx, URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle,aspect)
    local LRx, LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)

    Asteroids.Test.TestTex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
    
    Asteroids.Ship.Line1:SetStartPoint("TOPLEFT", (URx + ULx) / 2 * 40, (URy + ULy) / 2 * 40) 
    Asteroids.Ship.Line1:SetEndPoint("TOPLEFT", (LLx + LRx) / 2 * 40, (LLy + LRy) / 2 * 40) 
    -- Asteroids.Ship.Line2:SetStartPoint("TOPLEFT", ULx * 40, ULy * 40, "TOPLEFT", LLx * 40, LLy * 40) 
    -- Asteroids.Ship.Line2:SetEndPoint("TOPLEFT", URx * 40, URy * 40, "TOPLEFT", LRx * 40, LRy * 40) 
    -- Asteroids.Ship.Line3:SetStartPoint("TOPLEFT", ULx * 20, ULy * 20, "TOPLEFT", LLx * 20, LLy * 20) 
    -- Asteroids.Ship.Line3:SetEndPoint("TOPLEFT", URx * 20, URy * 20, "TOPLEFT", LRx * 20, LRy * 20) 
    -- Asteroids.Ship.Line4:SetStartPoint("TOPLEFT", ULx * 20, ULy * 20, "TOPLEFT", LLx * 20, LLy * 20) 
    -- Asteroids.Ship.Line4:SetEndPoint("TOPLEFT", URx * 20, URy * 20, "TOPLEFT", LRx * 20, LRy * 20) 
    
    -- Asteroids.Test.TestTex:SetTexCoord(1,0, 0,0, 1,1, 0,1)
  end
  if (GR.Asteroids.DownD == true) then

  end

  -- GR.Asteroids.ShipXPos = GR.Asteroids.ShipXPos + elapsed * 10
  -- Ship:SetPoint("BOTTOMLEFT", GR.Asteroids.ShipXPos, GR.Asteroids.ShipYPos)
end

