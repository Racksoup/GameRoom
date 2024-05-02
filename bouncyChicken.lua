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
  BC:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  BC:SetSize(GR.Win.Const.GameScreenWidth * Main.XRatio, GR.Win.Const.GameScreenHeight * Main.YRatio)
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  GR:SizeBCWalls()
  GR:SizeBCChicken()
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

  GR_GUI.Main.HeaderInfo.Solo.Timer:SetText(math.floor(GR.BC.GameTime * 100) / 100)

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
end

function GR:BCShow()
  local BC = GR_GUI.Main.BC
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  GR:SizeBC()

  BC:Show()
  Solo:Show()
  Solo.Timer:Show()
  Solo.Info:SetText("Bounce: Space, W, Up-Arrow")
  Solo.Info:Show()
  Solo.PointsFS:Show()
  Solo.Start:Show()
end

-- Start Stop Pause Unpause
function GR:BCStart()
  local BC = GR_GUI.Main.BC
  local Solo = GR_GUI.Main.HeaderInfo.Solo
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
  Solo.PointsFS:SetText(GR.BC.Points)
  Solo.Stopx:Show()
  Solo.Pausex:Show()
  Solo.Start:Hide()
  Solo.GameOverFS:Hide()
end

function GR:BCStop()
  local BC = GR_GUI.Main.BC
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  GR.BC.ActiveState = "Stop"
  BC.Game:Hide()
  Solo.Start:Show()
  Solo.Pausex:Hide()
  Solo.Stopx:Hide()
end

function GR:BCPause()
  local BC = GR_GUI.Main.BC
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  GR.BC.ActiveState = "Pause"
  Solo.Start:Show()
  Solo.Pausex:Hide()
  Solo.Stopx:Hide()

  BC.Game:Hide()
end

function GR:BCUnpause()
  local BC = GR_GUI.Main.BC
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  GR.BC.ActiveState = "Start"
  Solo.Start:Hide()
  Solo.Pausex:Show()
  Solo.Stopx:Show()

  BC.Game:Show()
end

function GR:BCGameOver()
  GR:BCStop()

  GR_GUI.Main.HeaderInfo.Solo.GameOverFS:Show()
end
