function GR:SuikaCreate()
  -- Contants
  GR.Suika = {}
  GR.Suika.Const = {}
  GR.Suika.Const.GameScreenWidth = 400
  GR.Suika.Const.GameScreenHeight = 580
  GR.Suika.Const.Tab1Width = 450
  GR.Suika.Const.Tab1Height = 720
  GR.Suika.Const.BallSizes = {37, 67, 106.8, 132, 173, 213, 241.15, 280.7, 320.5, 380.1, 423.5, 467.8, 536.6, 590.3, 649.3, 714.2, 785.6}
  GR.Suika.Const.Gravity = -2000
  GR.Suika.Const.MinGravity = -10000
  GR.Suika.Const.MaxSpeed = 10000
  GR.Suika.Const.StartSizes = 4
  GR.Suika.Const.TargetFrameTime = 1.0 / 60
  GR.Suika.Const.DampingFactor = .85
  GR.Suika.Const.MinVelThres = 30
  GR.Suika.Const.Colors = {
    {1,0,0,1},
    {0,1,0,1},
    {0,0,1,1},
    {.5,0,.5,1},
    {.5,.5,0,1},
    {0,.5,.5,1},
    {1,1,0,1},
    {.66,0,.66,1},
    {0,0,.33,1},
    {1,1,0,1},
    {.66,0,.66,1},
    {0,.6,1,1},
    {1,0,1,1},
    {.75,.75,0,1},
    {.50,0,.50,1},
    {1,1,0,1},
    {.66,0,.66,1},
    {0,0,.33,1},
    {1,1,0,1},
    {.66,0,.66,1},
    {0,.6,1,1},
    {1,0,1,1},
    {.75,.75,0,1},
    {.50,0,.50,1},
    {1,1,0,1},
    {.66,0,.66,1},
    {0,0,.33,1},
  }
  
  -- Suika Frame
  GR_GUI.Main.Suika = CreateFrame("Frame", Suika, GR_GUI.Main, "ThinBorderTemplate")
  local Suika = GR_GUI.Main.Suika
  Suika:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Suika.Const.Tab1Height))
  Suika:SetSize(GR_GUI.Main:GetWidth() * (GR.Suika.Const.GameScreenWidth / GR.Suika.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Suika.Const.GameScreenHeight / GR.Suika.Const.Tab1Height))
  Suika:SetClipsChildren(true)
  Suika:Hide()
  
  -- Variables
  GR.Suika.XRatio = 1
  GR.Suika.YRatio = 1
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Suika.Const.GameScreenWidth + Suika:GetHeight() / GR.Suika.Const.GameScreenHeight) / 2
  GR.Suika.BallSizes = {}
  for i,v in ipairs(GR.Suika.Const.BallSizes) do
    GR.Suika.BallSizes[i] = v * GR.Suika.ScreenRatio
  end
  GR.Suika.ActiveState = "Start"
  GR.Suika.Points = 0
  GR.Suika.Gravity = GR.Suika.Const.Gravity * GR.Suika.YRatio
  GR.Suika.MinGravity = GR.Suika.Const.MinGravity * GR.Suika.YRatio
  GR.Suika.MaxSpeed = GR.Suika.Const.MaxSpeed * GR.Suika.ScreenRatio
  GR.Suika.SimTime = 0

  -- Create
  GR:SuikaGameLoop()
  GR:SuikaCreateStatusBtns()
  GR:SuikaCreateInfo()
  Suika.Balls = {}
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

function GR:CreateUseNextBall()
  local Suika = GR_GUI.Main.Suika

  local Ball = nil
  for i,v in pairs(Suika.Balls) do -- find usable ball
    if (v.IsActive == false) then
      Ball = v
      break;
    end
  end
  if (Ball == nil) then -- if no usable balls make one
    Ball = CreateFrame("Frame", Ball, Suika)
    Ball.New = true
  end
  GR:MakeBall(Ball)
end

function GR:MakeBall(Ball)
  local Suika = GR_GUI.Main.Suika
  
  Ball.Size = math.random(GR.Suika.Const.StartSizes)
  Ball.IsClickable = true
  Ball.IsActive = false
  Ball.VelY = 0
  Ball.VelX = 0
  Ball.AccY = 0
  Ball.AccX = 0
  Ball.Mass = (4/3) * math.pi * (Ball.Size / 2)^3
  Ball:SetSize(GR.Suika.BallSizes[Ball.Size] * GR.Suika.XRatio, GR.Suika.BallSizes[Ball.Size] * GR.Suika.YRatio)
  Ball:SetPoint("CENTER", Suika, "BOTTOMLEFT", Suika:GetWidth() / 2, 405 * GR.Suika.YRatio)
  Ball:SetMovable(true)
  Ball:EnableMouse(true)
  Ball:SetPropagateKeyboardInput(true)
  Ball:RegisterForDrag("LeftButton")
  Ball:SetScript("OnMouseDown", function(self, button)
    self:StartMoving()
  end)
  Ball:SetScript("OnMouseUp", function(self)
    Ball.IsActive = true
    Ball.IsClickable = false
    self:StopMovingOrSizing()
    self:SetMovable(false)
    self:EnableMouse(false)
    local left, bottom, width, height = self:GetRect()
    local left2, bottom2, width2, height2 = Suika:GetRect()
    self:ClearAllPoints()
    self:SetPoint("CENTER", Suika, "BOTTOMLEFT", left - left2, 405 * GR.Suika.YRatio)
    GR:CreateUseNextBall()
  end)
  if (Ball:GetRegions() == nil) then -- if new frame, create new texture
    Ball.Tex = Ball:CreateTexture()
    Ball.Tex:SetAllPoints(Ball)
    Ball.Mask = Ball:CreateMaskTexture()
    Ball.Tex:AddMaskTexture(Ball.Mask)
    Ball.Mask:SetAllPoints(Ball)
    Ball.Mask:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Circle.blp")
    Ball.Mask:SetTexCoord(0,1,0,1)
  end
  local color = GR.Suika.Const.Colors[Ball.Size]
  Ball.Tex:SetColorTexture(color[1],color[2],color[3],color[4])
  Ball:Show()
  if (Ball.New) then
    table.insert(Suika.Balls, Ball)
    Ball.New = false
  end
end

-- Size
function GR:SuikaSize()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Game Screen
  Suika:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Suika.Const.Tab1Height))
  Suika:SetSize(Main:GetWidth() * (GR.Suika.Const.GameScreenWidth / GR.Suika.Const.Tab1Width), Main:GetHeight() * (GR.Suika.Const.GameScreenHeight / GR.Suika.Const.Tab1Height))
  GR.Suika.XRatio = 1
  GR.Suika.YRatio = 1
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Suika.Const.GameScreenWidth + Suika:GetHeight() / GR.Suika.Const.GameScreenHeight) / 2

  -- variables
  GR.Suika.Gravity = GR.Suika.Const.Gravity * GR.Suika.YRatio
  GR.Suika.MinGravity = GR.Suika.Const.MinGravity * GR.Suika.YRatio
  GR.Suika.MaxSpeed = GR.Suika.Const.MaxSpeed * GR.Suika.ScreenRatio

  GR:SuikaSizeStatusBtns()
  GR:SuikaSizeInfo()
  GR:SuikaSizeBalls()
end

function GR:SuikaSizeStatusBtns()
  local Suika = GR_GUI.Main.Suika
  local XRatio = GR.Suika.XRatio
  local YRatio = GR.Suika.YRatio
  local ScreenRatio = GR.Suika.ScreenRatio
  
  -- Start
  Suika.Start:SetPoint("TOPLEFT", Suika, 30 * XRatio, 39 * YRatio)
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
  Suika.Stopx:SetPoint("TOPLEFT", Suika, 30 * XRatio, 39 * YRatio)
  Suika.Stopx:SetSize(30 * XRatio, 30 * YRatio)
  Suika.Stopx.Tex:SetSize(15 * XRatio, 15 * YRatio)
end

function GR:SuikaSizeInfo()
  local Suika = GR_GUI.Main.Suika

  -- Points
  Suika.PointsFS:SetPoint("BOTTOMLEFT", Suika, "TOPLEFT", 110 * GR.Suika.XRatio, 10 * GR.Suika.YRatio)
  Suika.PointsFS:SetTextScale(2 * GR.Suika.ScreenRatio)
  
  -- Game Over
  Suika.GameOverFS:SetPoint("TOP", Suika, 0, -140 * GR.Suika.YRatio)
  Suika.GameOverFS:SetTextScale(3.7 * GR.Suika.ScreenRatio)
end

function GR:SuikaSizeBalls()
  for i,v in pairs(GR_GUI.Main.Suika.Balls) do
    v:SetSize(GR.Suika.BallSizes[v.Size] * GR.Suika.XRatio, GR.Suika.BallSizes[v.Size] * GR.Suika.YRatio)
  end
end

-- Update
function GR:SuikaUpdate(self, elapsed)
  if (elapsed > GR.Suika.Const.TargetFrameTime ) then elapsed = GR.Suika.Const.TargetFrameTime  end

  GR.Suika.SimTime = GR.Suika.SimTime + elapsed

  while (GR.Suika.SimTime >= GR.Suika.Const.TargetFrameTime) do
    GR:SuikaUpdateBalls(self, GR.Suika.Const.TargetFrameTime)
    GR.Suika.SimTime = GR.Suika.SimTime - GR.Suika.Const.TargetFrameTime 
  end
  

  GR:SuikaCol()
end

function GR:SuikaUpdateBalls(self, elapsed)
  for i,v in pairs(GR_GUI.Main.Suika.Balls) do
    if (v.IsClickable == false and v.IsActive) then
      if (v.VelX > GR.Suika.MaxSpeed) then -- limit speed
        v.VelX = GR.Suika.MaxSpeed
      end
      if (v.VelX < -GR.Suika.MaxSpeed) then
        v.VelX = -GR.Suika.MaxSpeed
      end
      if (v.VelY > GR.Suika.MaxSpeed) then
        v.VelY = GR.Suika.MaxSpeed
      end
      if (v.VelY < -GR.Suika.MaxSpeed) then
        v.VelY = -GR.Suika.MaxSpeed
      end
      v.AccX = -v.VelX * .8 -- drag
      v.AccY = -v.VelY * .8
      v.VelX = v.VelX + (v.AccX * elapsed) -- Vel
      v.VelY = v.VelY + (v.AccY * elapsed)
      v.VelX = v.VelX * GR.Suika.Const.DampingFactor -- dampening for jiggle
      v.VelY = v.VelY * GR.Suika.Const.DampingFactor
      v.VelY = v.VelY + (GR.Suika.Gravity * elapsed) -- gravity after dampening
      if math.abs(v.VelX) < GR.Suika.Const.MinVelThres then
          v.VelX = 0
      end
      if math.abs(v.VelY) < GR.Suika.Const.MinVelThres then
          v.VelY = 0
      end
      if (v.VelY < GR.Suika.MinGravity) then v.VelY = GR.Suika.MinGravity end -- limit fall speed
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint()
      v:SetPoint(point, relativeTo, relativePoint, xOfs + v.VelX * elapsed, yOfs + v.VelY * elapsed) -- apply speed
    end
  end
end

-- Collisions
function GR:SuikaCol()
  local Suika = GR_GUI.Main.Suika
  local Balls = Suika.Balls
  
  -- Ball to Wall
  local Border = {
    top = Suika:GetHeight(),
    right = Suika:GetWidth(),
    bottom = 0,
    left = 0
  }
  for i,v in pairs(Balls) do
    if (v.IsActive and not v.IsClickable ) then
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint()
      r = GR.Suika.BallSizes[v.Size] / 2
      local Ball = {
        top = yOfs + r,
        right = xOfs + r,
        bottom = yOfs - r,
        left = xOfs - r
      }

      -- check if circle is outside of border
      -- circle top past border top
      local pos = {x = xOfs, y = yOfs}
      if (Ball.top > Border.top) then 
        pos.y = Border.top - r
        v.VelY = v.VelY - v.VelY * 1
      end
      -- circle right past border right
      if (Ball.right > Border.right) then 
        pos.x = Border.right - r
        v.VelX = v.VelX - v.VelX * 1
      end
      -- circle bottom past border bottom
      if (Ball.bottom < Border.bottom) then 
        pos.y = Border.bottom + r
        v.VelY = v.VelY - v.VelY * 1
      end
      -- circle left past border left
      if (Ball.left < Border.left) then 
        pos.x = Border.left + r
        v.VelX = v.VelX - v.VelX * 1
      end
      
      -- apply pos change if collision
      if (pos.x ~= xOfs or pos.y ~= yOfs) then
        v:SetPoint("CENTER", Suika, "BOTTOMLEFT", pos.x, pos.y)
      end
    end
  end

  -- Ball to Ball 
  for i,v in pairs(Balls) do
    if (v.IsActive and not v.IsClickable) then
      local p1, rf1, rp1, x1, y1 = v:GetPoint()
      local r1 = GR.Suika.BallSizes[v.Size] / 2

      for j,k in pairs(Balls) do
        if (k.IsActive and j ~= i) then
          local p2, rf2, rp2, x2, y2 = k:GetPoint()
          local r2 = GR.Suika.BallSizes[k.Size] / 2
          
          if(GR:DoCirclesOverlap(x1, y1, r1, x2, y2, r2)) then
            -- check for same size ball first
            if (v.Size == k.Size) then
              k.IsActive = false
              k:Hide()
              v.Size = v.Size + 1             
              v.VelY = 0
              v.VelX = 0
              v.AccY = 0
              v.AccX = 0
              -- v.Mass = v.Size
              v.Mass = (4/3) * math.pi * (v.Size / 2)^3
              local color = GR.Suika.Const.Colors[v.Size]
              v.Tex:SetColorTexture(color[1], color[2], color[3], color[4])
              v:SetSize(GR.Suika.BallSizes[v.Size] * GR.Suika.XRatio, GR.Suika.BallSizes[v.Size] * GR.Suika.YRatio)
            else
              local distance = sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
              local overlap = (distance - r1 - r2) * .3
              
              v:SetPoint(p1,rf1,rp1, x1 - overlap * (x1-x2) / distance, y1 - overlap * (y1-y2) / distance)
              k:SetPoint(p2,rf2,rp2, x2 + overlap * (x1-x2) / distance, y2 + overlap * (y1-y2) / distance)
              
              -- dynamic collision
              local nx = (x2 - x1) / distance
              local ny = (y2 - y1) / distance
              local tx = -ny
              local ty = nx
              local dpTan1 = v.VelX * tx + v.VelY * ty
              local dpTan2 = k.VelX * tx + k.VelY * ty
              local dpNorm1 = v.VelX * nx + v.VelY * ny
              local dpNorm2 = k.VelX * nx + k.VelY * ny
              
              -- conservation of momentum in 1D
              local m1 = (dpNorm1 * (v.Mass - k.Mass) + 2.0 * k.Mass * dpNorm2) / (v.Mass + k.Mass)
              local m2 = (dpNorm2 * (k.Mass - v.Mass) + 2.0 * v.Mass * dpNorm1) / (v.Mass + k.Mass)
              
              v.VelX = (tx * dpTan1 + nx * m1)
              v.VelY = (ty * dpTan1 + ny * m1)
              k.VelX = (tx * dpTan2 + nx * m2)
              k.VelY = (ty * dpTan2 + ny * m2)
            end
          end
        end
      end
    end
  end
end

function GR:DoCirclesOverlap(x1, y1, r1, x2, y2, r2)
  return abs((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)) <= (r1+r2)*(r1+r2)
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
  if (GR.Suika.ActiveState == 'Start') then Suika.Stopx:Show() Suika.Game:Show() end

  GR:SuikaStart()
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
  GR.Suika.SimTime = 0

  -- Start Game
  Suika.Game:Show()
  local Ball = CreateFrame("Frame", Ball, Suika)
  Ball.New = true
  GR:MakeBall(Ball)
  
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
  for i,v in pairs(Suika.Balls) do
    v.IsActive = false
    v:Hide()
  end
end

function GR:SuikaGameOver()
  GR:SuikaStop()

  GR_GUI.Main.Suika.GameOverFS:Show()
end

-- balls spawn with left offset
-- needs resize dimensions locked so circles stay circles
-- points
-- end-game