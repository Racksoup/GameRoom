function GR:CreateBouncyChicken()
  -- Constants
  GR.BC = {}
  GR.BC.Const = {}
  GR.BC.Const.WallStartInt = 1.65
  GR.BC.Const.WallSpeed = 190
  GR.BC.Const.WallWidth = 80
  GR.BC.Const.WallHeight = 180
  GR.BC.Const.WallYPosOptions = { -120, -58, 4, 66, 128, 190, 252, 314, 376, 438 }
  GR.BC.Const.ChickenXPos = 100
  GR.BC.Const.ChickenYStart = 250
  GR.BC.Const.ChickenWidth = 46
  GR.BC.Const.ChickenHeight = 52
  GR.BC.Const.ChickenGravity = -9.5
  GR.BC.Const.ChickenMinVelY = -3.8
  GR.BC.Const.ChickenMaxVelY = 4.4
  
  -- Bouncy Chicken Frame
  GR_GUI.Main.BC = CreateFrame("Frame", BouncyChicken, GR_GUI.Main, "ThinBorderTemplate")
  local BC = GR_GUI.Main.BC
  BC:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(GR_GUI.Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  BC:SetClipsChildren(true)
  BC:Hide()
  
  -- Variables
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2
  GR.BC.ActiveState = "Stop"
  GR.BC.GameTime = 0
  GR.BC.Points = 0
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed
  GR.BC.WallWidth = GR.BC.Const.WallWidth * GR.BC.XRatio
  GR.BC.WallHeight = GR.BC.Const.WallHeight * GR.BC.YRatio
  GR.BC.WallStartX = BC:GetWidth() * 1.1
  GR.BC.WallEndX = BC:GetWidth() * -.15
  GR.BC.WallYPosOptions = {}
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end
  GR.BC.ChickenXPos = GR.BC.Const.ChickenXPos * GR.BC.XRatio
  GR.BC.ChickenYStart = GR.BC.Const.ChickenYStart * GR.BC.YRatio
  GR.BC.ChickenWidth = GR.BC.Const.ChickenWidth * GR.BC.XRatio
  GR.BC.ChickenHeight = GR.BC.Const.ChickenHeight * GR.BC.YRatio
  GR.BC.ChickenGravity = GR.BC.Const.ChickenGravity * GR.BC.YRatio
  GR.BC.ChickenMinVelY = GR.BC.Const.ChickenMinVelY * GR.BC.YRatio 
  GR.BC.ChickenMaxVelY = GR.BC.Const.ChickenMaxVelY * GR.BC.YRatio 

  -- Create
  GR:CreateBCGameLoop()
  GR:ControlsBC()
  GR:CreateBCActiveStatusBtns()
  GR:CreateBCInfo()
  GR:CreateBCWalls()
  GR:CreateBCChicken()
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
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Start / Unpause
  BC.Start = CreateFrame("Button", Start, Main)
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
  BC.Start:Hide()
  
  -- Stop
  BC.Stopx = CreateFrame("Button", Stopx, Main)
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
  BC.Pausex = CreateFrame("Button", Pausex, Main)
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
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Timer
  BC.Timer = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Timer:SetText(GR.BC.GameTime)
  BC.Timer:SetTextColor(.8,.8,.8, 1)
  BC.Timer:Hide()

  -- Points
  BC.PointsFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.PointsFS:SetText(GR.BC.Points)
  BC.PointsFS:SetTextColor(.8,.8,.8, 1)
  BC.PointsFS:Hide()

  -- GameOver
  BC.GameOverFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.GameOverFS:SetText("Game Over")
  BC.GameOverFS:SetTextColor(.8,0,0, 1)
  BC.GameOverFS:Hide()

  -- Controls Info
  BC.Info = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Info:SetText("Bounce: Space, W, Up-Arrow")
  BC.Info:SetTextColor(.8,.8,.8, 1)
  BC.Info:Hide()
end

function GR:CreateBCWalls()
  local BC = GR_GUI.Main.BC
  BC.Walls = {}
  local Walls = BC.Walls

  for i = 1, 3, 1 do
    Walls[i] = CreateFrame("Frame", nil, BC)
    local Wall = Walls[i]
    Wall:SetPoint("BOTTOMLEFT")
    Wall.Tex = Wall:CreateTexture()
    Wall.Tex:SetColorTexture(.38, .84, 1, 1)
    Wall.Tex:SetAllPoints(Wall)
    Wall:Hide()
  end
end

function GR:CreateBCChicken()
  local BC = GR_GUI.Main.BC

  BC.Chicken = CreateFrame("Frame", Chicken, BC)
  local Chicken = BC.Chicken
  BC.Chicken.VelY = 0
  BC.Chicken.YPos = GR.BC.ChickenYStart
  Chicken.Tex = Chicken:CreateTexture()
  Chicken.Tex:SetAllPoints(Chicken)
  Chicken.Tex:SetTexture("Interface\\AddOns\\GameRoom\\images\\Chicken.blp")
  Chicken.Tex:SetTexCoord(0,0, 0,1, 1,0, 1,1)
  Chicken:Hide()
end

-- Size
function GR:SizeBC()
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Game Screen
  BC:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  GR:SizeBCActiveStatusBtns()
  GR:SizeBCInfo()
  GR:SizeBCWalls()
  GR:SizeBCChicken()
end

function GR:SizeBCActiveStatusBtns()
  local BC = GR_GUI.Main.BC
  local XRatio = GR.BC.XRatio
  local YRatio = GR.BC.YRatio
  local ScreenRatio = GR.BC.ScreenRatio
  
  -- Start
  BC.Start:SetPoint("TOPLEFT", BC, 50 * XRatio, 34 * YRatio)
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
  BC.Stopx:SetPoint("TOPLEFT", BC, 83 * XRatio, 34 * YRatio)
  BC.Stopx:SetSize(30 * XRatio, 30 * YRatio)
  BC.Stopx.Tex:SetSize(15 * XRatio, 15 * YRatio)
  
  -- Unpause
  BC.Pausex:SetPoint("TOPLEFT", BC, 50 * XRatio, 34 * YRatio)
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
  BC.GameOverFS:SetPoint("TOP", BC, 0, -140 * GR.BC.YRatio)
  BC.GameOverFS:SetTextScale(3.7 * GR.BC.ScreenRatio)
  
  -- Controls Info
  BC.Info:SetPoint("TOP", BC, "TOPLEFT", 100 * GR.BC.XRatio, 57 * GR.BC.YRatio)
  BC.Info:SetTextScale(1 * GR.BC.ScreenRatio)
end

function GR:SizeBCWalls()
  local BC = GR_GUI.Main.BC
  local Walls = GR_GUI.Main.BC.Walls

  -- Variables
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed * GR.BC.XRatio
  GR.BC.WallWidth = GR.BC.Const.WallWidth * GR.BC.XRatio
  GR.BC.WallHeight = GR.BC.Const.WallHeight * GR.BC.YRatio
  GR.BC.WallStartX = BC:GetWidth() * 1.1
  GR.BC.WallEndX = BC:GetWidth() * -.15
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end

  for i = 1, #Walls, 1 do
    local Wall = Walls[i]
    Wall:SetSize(GR.BC.WallWidth, GR.BC.WallHeight)
  end
end

function GR:SizeBCChicken()
  local BC = GR_GUI.Main.BC
  local Chicken = GR_GUI.Main.BC.Chicken

  GR.BC.ChickenMinVelY = GR.BC.Const.ChickenMinVelY * GR.BC.YRatio 
  GR.BC.ChickenMaxVelY = GR.BC.Const.ChickenMaxVelY * GR.BC.YRatio 
  GR.BC.ChickenGravity = GR.BC.Const.ChickenGravity * GR.BC.YRatio
  GR.BC.ChickenWidth = GR.BC.Const.ChickenWidth * GR.BC.XRatio
  GR.BC.ChickenHeight = GR.BC.Const.ChickenHeight * GR.BC.YRatio
  GR.BC.ChickenXPos = GR.BC.Const.ChickenXPos * GR.BC.XRatio
  GR.BC.ChickenYStart = GR.BC.Const.ChickenYStart * GR.BC.YRatio
  Chicken:SetPoint("BOTTOMLEFT", GR.BC.ChickenXPos, Chicken.YPos)
  Chicken:SetSize(GR.BC.ChickenWidth, GR.BC.ChickenHeight)
end

-- Update
function GR:UpdateBC(self, elapsed)
  local BC = GR_GUI.Main.BC

  GR.BC.GameTime = GR.BC.GameTime + elapsed

  BC.Timer:SetText(math.floor(GR.BC.GameTime * 100) / 100)

  GR:UpdateBCWalls(self, elapsed)
  GR:UpdateBCChicken(self, elapsed)

  GR:ColBC()
end

function GR:UpdateBCWalls(self, elapsed)
  local BC = GR_GUI.Main.BC
  local Walls = BC.Walls

  for i = 1, #Walls, 1 do
    if (Walls[i]:IsShown()) then
      local Wall = Walls[i]

      if (Wall.XPos < GR.BC.WallEndX) then
        Wall.YPos = GR.BC.WallYPosOptions[math.random(1,#GR.BC.Const.WallYPosOptions)]
        Wall.XPos = GR.BC.WallStartX
        Wall:SetPoint("BOTTOMLEFT", Wall.XPos, Wall.YPos)
      else
        Wall.XPos = Wall.XPos - elapsed * GR.BC.WallSpeed
        Wall:SetPoint("BOTTOMLEFT", Wall.XPos, Wall.YPos)
      end
    end
  end
end

function GR:UpdateBCChicken(self, elapsed)
  local BC = GR_GUI.Main.BC
  local Chicken = GR_GUI.Main.BC.Chicken

  Chicken.VelY = Chicken.VelY + (GR.BC.ChickenGravity * elapsed)
  if (Chicken.VelY <= GR.BC.ChickenMinVelY) then
    Chicken.VelY = GR.BC.ChickenMinVelY
  end

  if (Chicken.PosY == nil) then Chicken.PosY = GR.BC.ChickenYStart end
  Chicken.PosY = Chicken.PosY + Chicken.VelY
  Chicken:SetPoint("BOTTOMLEFT", GR.BC.ChickenXPos, Chicken.PosY)
end

-- Collisions
function GR:ColBC()
  -- Wall - Chicken
  for i,v in pairs(GR_GUI.Main.BC.Walls) do
    if (GR:ColBCChickenWall(v)) then GR:BCGameOver() end
  end
  -- Game Border - Chicken
  if (GR:ColBCChickenBorder()) then GR:BCGameOver() end
end

function GR:ColBCChickenWall(Wall)
  local Chicken = GR_GUI.Main.BC.Chicken

  local point, relativeTo, relativePoint, xOfs, yOfs = Chicken:GetPoint()
  local ChickenPoints = {
    LLx = xOfs + (12 * GR.BC.XRatio),
    LLy = yOfs + (12 * GR.BC.YRatio),
    URx = xOfs + Chicken:GetWidth() - (12 * GR.BC.XRatio),
    URy = yOfs + Chicken:GetHeight() - (12 * GR.BC.YRatio)
  }
  point, relativeTo, relativePoint, xOfs, yOfs = Wall:GetPoint()
  local WallPoints = {
    LLx = xOfs,
    LLy = yOfs,
    URx = xOfs + Wall:GetWidth(),
    URy = yOfs + Wall:GetHeight()
  }
  
  -- If Chicken Inside of Wall
  if (Wall:IsVisible() and (ChickenPoints.URx > WallPoints.LLx and ChickenPoints.LLx < WallPoints.URx) and (ChickenPoints.URy > WallPoints.LLy and ChickenPoints.LLy < WallPoints.URy)) then 
    return true
  end
  return false
end

function GR:ColBCChickenBorder()
  local BC = GR_GUI.Main.BC
  local Chicken = GR_GUI.Main.BC.Chicken

  local point, relativeTo, relativePoint, xOfs, yOfs = Chicken:GetPoint()
  local ChickenPoints = {
    LLx = xOfs,
    LLy = yOfs,
    URx = xOfs + Chicken:GetWidth(),
    URy = yOfs + Chicken:GetHeight()
  }
  point, relativeTo, relativePoint, xOfs, yOfs = BC:GetPoint()
  local BCPoints = {
    LLx = xOfs,
    LLy = yOfs - (34 * GR.BC.YRatio),
    URx = xOfs + BC:GetWidth(),
    URy = yOfs + BC:GetHeight() - (23 * GR.BC.YRatio)
  }
  
  -- If Chicken Touches Border
  -- Chicken top higher than Border Top
  if (ChickenPoints.URy > BCPoints.URy) then 
    return true
  end
  -- Chicken bottom lower than Border bottom
  if (ChickenPoints.LLy < BCPoints.LLy) then 
    return true
  end
  return false
end

-- Controls
function GR:ControlsBC()
  local Game = GR_GUI.Main.BC.Game

  Game:SetScript("OnKeyDown", function(self, key)
    if (key == "SPACE" or key == "W" or key == "w" or key == "UP") then 
      GR:BCBounce()
    end
  end)
end

-- Functions
function GR:BCBounce()
  GR_GUI.Main.BC.Chicken.VelY = GR.BC.ChickenMaxVelY
end

function GR:BCStartMovingWalls()
  local Walls = GR_GUI.Main.BC.Walls

  -- Scale WallYPosOptions for first render
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end

  -- Position Walls
  for i = 1, #Walls, 1 do
    Walls[i].XPos = GR.BC.WallStartX
    Walls[i].YPos = GR.BC.WallYPosOptions[math.random(1,#GR.BC.Const.WallYPosOptions)]
  end

  -- Cancel Old Wall Timers
  if (GR.BC.WallTimer1) then
    GR.BC.WallTimer1:Cancel()
    GR.BC.WallTimer2:Cancel()
  end

  -- Show First Wall
  Walls[1]:Show()
  
  -- Show Second Wall
  GR.BC.WallTimer1 = C_Timer.NewTimer(GR.BC.Const.WallStartInt, function()
    if (GR.BC.ActiveState == "Start") then Walls[2]:Show() end
  end)
  
  -- Show Third Wall 
  GR.BC.WallTimer2 = C_Timer.NewTimer(GR.BC.Const.WallStartInt * 2, function()
    if (GR.BC.ActiveState == "Start") then Walls[3]:Show() end
  end)
end

-- Hide Show
function GR:BCHide()
  local BC = GR_GUI.Main.BC
  
  GR:BCStop()

  BC:Hide()
  BC.Start:Hide()
  BC.Stopx:Hide()
  BC.Pausex:Hide()
  BC.Timer:Hide()
  BC.PointsFS:Hide()
  BC.GameOverFS:Hide()
  BC.Info:Hide()
end

function GR:BCShow()
  local BC = GR_GUI.Main.BC

  GR:SizeBC()

  BC:Show()
  BC.Start:Show()
  BC.Timer:Show()
  BC.PointsFS:Show()
  BC.GameOverFS:Hide()
  BC.Info:Show()
end

-- Start Stop Pause Unpause
function GR:BCStart()
  local BC = GR_GUI.Main.BC
  local Walls = GR_GUI.Main.BC.Walls

  for i = 1, #Walls, 1 do
    Walls[i]:Hide()
  end
  BC.Chicken:Hide()

  -- Reset Variables
  GR.BC.GameTime = 0
  GR.BC.Points = 0
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed * GR.BC.XRatio
  BC.Chicken.VelY = 0
  BC.Chicken.YPos = GR.BC.ChickenYStart

  -- Start Game
  BC.Game:Show()
  BC.Chicken:Show()
  BC.Chicken.PosY = GR.BC.ChickenYStart
  BC.Chicken.VelY = 0
  GR:BCStartMovingWalls()
  
  -- Show Game Info and Buttons
  GR.BC.ActiveState = "Start"
  BC.PointsFS:SetText(GR.BC.Points)
  BC.Stopx:Show()
  BC.Pausex:Show()
  BC.Start:Hide()
  BC.GameOverFS:Hide()
end

function GR:BCStop()
  local BC = GR_GUI.Main.BC
  local Walls = BC.Walls

  GR.BC.ActiveState = "Stop"
  BC.Game:Hide()
  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()
end

function GR:BCPause()
  local BC = GR_GUI.Main.BC

  GR.BC.ActiveState = "Pause"
  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()

  BC.Game:Hide()
end

function GR:BCUnpause()
  local BC = GR_GUI.Main.BC

  GR.BC.ActiveState = "Start"
  BC.Start:Hide()
  BC.Pausex:Show()
  BC.Stopx:Show()

  BC.Game:Show()
end

function GR:BCGameOver()
  GR:BCStop()

  GR_GUI.Main.BC.GameOverFS:Show()
end
