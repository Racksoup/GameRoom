function GR:CreateSuika()
  -- Contants
  GR.Suika = {}
  GR.Suika.Const = {}
  GR.Suika.Const.BallSizes = {29, 47, 58, 74, 93, 149, 168, 196, 224, 266, 296, 328, 375, 413, 454, 500, 550}
  GR.Suika.Const.Gravity = -50
  GR.Suika.Const.MaxFallSpeed = -120
  GR.Suika.Const.MaxSpeed = 120
  GR.Suika.Const.StartSizes = 5
  GR.Suika.Const.TargetFrameTime = 1.0 / 60
  GR.Suika.Const.DampingFactorX = .99
  GR.Suika.Const.DampingFactorY = .99
  GR.Suika.Const.MinVelThres = 15
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
  local Main = GR_GUI.Main
  Main.Suika = CreateFrame("Frame", Suika, Main, "ThinBorderTemplate")
  local Suika = Main.Suika
  Suika:SetClipsChildren(true)
  Suika:Hide()
  
  -- Variables
  GR.Suika.BallSizes = {}
  for i,v in ipairs(GR.Suika.Const.BallSizes) do
    GR.Suika.BallSizes[i] = v * Main.ScreenRatio
  end
  GR.Suika.ActiveState = "Start"
  GR.Suika.Points = 0
  GR.Suika.SimTime = 0

  -- Create
  GR:SuikaGameLoop()
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

function GR:SuikaCreateUseNextBall()
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
  GR:SuikaMakeBall(Ball)
end

function GR:SuikaMakeBall(Ball)
  local Main = GR_GUI.Main
  local Suika = Main.Suika
  
  Ball.Size = math.random(GR.Suika.Const.StartSizes)
  Ball.IsClickable = true
  Ball.IsActive = false
  Ball.VelY = 0
  Ball.VelX = 0
  Ball.AccY = 0
  Ball.AccX = 0
  Ball.SkipGravity = false
  Ball.Mass = (4/3) * math.pi * (GR.Suika.BallSizes[Ball.Size] / 2)^3
  Ball:SetSize(GR.Suika.BallSizes[Ball.Size] * Main.XRatio, GR.Suika.BallSizes[Ball.Size] * Main.YRatio)
  Ball:SetPoint("CENTER", Suika, "BOTTOMLEFT", Suika:GetWidth() / 2, 570 * Main.YRatio)
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
    self:SetPoint("CENTER", Suika, "BOTTOMLEFT", left - left2, 570 * Main.YRatio)
    GR:SuikaCreateUseNextBall()
  end)
  if (Ball:GetRegions() == nil) then -- if new frame, create new texture
    Ball.Tex = Ball:CreateTexture()
    Ball.Tex:SetAllPoints(Ball)
    Ball.Mask = Ball:CreateMaskTexture()
    Ball.Tex:AddMaskTexture(Ball.Mask)
    Ball.Mask:SetAllPoints(Ball)
    Ball.Mask:SetTexture("Interface\\AddOns\\GameRoom\\images\\Circle.blp")
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
function GR:SizeSuika()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Game Screen
  Suika:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Suika:SetSize(GR.Win.Const.SuikaScreenWidth * Main.XRatio, GR.Win.Const.SuikaScreenHeight * Main.YRatio)

  GR:SizeSuikaBalls()
end

function GR:SizeSuikaBalls()
  for i,v in pairs(GR_GUI.Main.Suika.Balls) do
    v:SetSize(GR.Suika.BallSizes[v.Size] * GR_GUI.Main.XRatio, GR.Suika.BallSizes[v.Size] * GR_GUI.Main.YRatio)
  end
end

-- Update
-- function GR:SuikaUpdate(self, elapsed)
--   if (elapsed > GR.Suika.Const.TargetFrameTime ) then elapsed = GR.Suika.Const.TargetFrameTime  end

--   GR.Suika.SimTime = GR.Suika.SimTime + elapsed

--   while (GR.Suika.SimTime >= GR.Suika.Const.TargetFrameTime) do
--     GR:SuikaUpdateBalls(self, GR.Suika.Const.TargetFrameTime)
--     GR.Suika.SimTime = GR.Suika.SimTime - GR.Suika.Const.TargetFrameTime 
--   end
  

--   GR:SuikaCol()
-- end

function GR:SuikaUpdate(self, elapsed)
  local targetFrameRate = 60  -- Adjust this value based on your desired frame rate

  local scaledElapsed = elapsed * (targetFrameRate / GR.Suika.Const.TargetFrameTime)

  if (scaledElapsed > GR.Suika.Const.TargetFrameTime) then
    scaledElapsed = GR.Suika.Const.TargetFrameTime
  end

  GR.Suika.SimTime = GR.Suika.SimTime + scaledElapsed

  while (GR.Suika.SimTime >= GR.Suika.Const.TargetFrameTime) do
    GR:SuikaUpdateBalls(self, GR.Suika.Const.TargetFrameTime)
    GR.Suika.SimTime = GR.Suika.SimTime - GR.Suika.Const.TargetFrameTime 
  end
  GR:SuikaCol()

end

function GR:SuikaUpdateBalls(self, elapsed)
  for i,v in pairs(GR_GUI.Main.Suika.Balls) do
    if (v.IsClickable == false and v.IsActive) then

      -- limit lowest speed so that objects rest
      if math.abs(v.VelX) < GR.Suika.Const.MinVelThres then
        v.VelX = 0
      end
      -- only limit if going up so that gravity continues to apply
      if (v.VelY > 0 and v.VelY < GR.Suika.Const.MinVelThres) then
        v.VelY = 0
      end
      
      -- apply gravity
      v.VelY = v.VelY + GR.Suika.Const.Gravity * elapsed
      
      -- limit fall speed
      if (v.VelY < GR.Suika.Const.MaxFallSpeed) then 
        v.VelY = GR.Suika.Const.MaxFallSpeed
      end 

      -- limit speed
      if (v.VelX > GR.Suika.Const.MaxSpeed) then 
        v.VelX = GR.Suika.Const.MaxSpeed
      end
      if (v.VelX < -GR.Suika.Const.MaxSpeed) then
        v.VelX = -GR.Suika.Const.MaxSpeed
      end
      if (v.VelY > GR.Suika.Const.MaxSpeed) then
        v.VelY = GR.Suika.Const.MaxSpeed
      end
      if (v.VelY < -GR.Suika.Const.MaxSpeed) then
        v.VelY = -GR.Suika.Const.MaxSpeed
      end

      v.AccX = -v.VelX * .01 -- drag
      v.AccY = -v.VelY * .01
      v.VelX = v.VelX + v.AccX -- Vel
      v.VelY = v.VelY + v.AccY
      v.VelX = v.VelX * GR.Suika.Const.DampingFactorX -- dampening for jiggle
      v.VelY = v.VelY * GR.Suika.Const.DampingFactorY

      print("Vel Y:", v.VelY)
      print("Vel X:", v.VelX)
      print("Max Fall Speed:", GR.Suika.Const.MaxFallSpeed)
      print("Max Speed:", GR.Suika.Const.MaxSpeed)
      print("Min Vel Threshold:", GR.Suika.Const.MinVelThres)
      
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint()
      v:SetPoint(point, relativeTo, relativePoint, xOfs + v.VelX * elapsed, yOfs + v.VelY * elapsed) -- apply speed
    end
  end
end

-- Collisions
function GR:SuikaCol()
  local Main = GR_GUI.Main
  local Suika = Main.Suika
  local Balls = Suika.Balls
  
  -- Ball to Wall
  local Border = {
    top = Suika:GetHeight(),
    right = Suika:GetWidth(),
    bottom = 0,
    left = 0
  }
  for i,v in pairs(Balls) do
    if v.IsActive and not v.IsClickable then
      local point, _, _, xOfs, yOfs = v:GetPoint()
      local r = (GR.Suika.BallSizes[v.Size] / 2) * Main.ScreenRatio
      local Ball = {
        top = yOfs + r,
        right = xOfs + r,
        bottom = yOfs - r,
        left = xOfs - r
      }

      -- check if circle is outside of border
      -- circle top past border top
      if (Ball.top > Border.top) then 
        yOfs = Border.top - r
        v.VelY = -v.VelY * 1
      end
      -- circle right past border right
      if (Ball.right > Border.right) then 
        xOfs = Border.right - r
        v.VelX = -v.VelX * 1
      end
      -- circle bottom past border bottom
      if (Ball.bottom < Border.bottom) then 
        yOfs = Border.bottom + r
        v.VelY = -v.VelY * 1
      end
      -- circle left past border left
      if (Ball.left < Border.left) then 
        xOfs = Border.left + r
        v.VelX = -v.VelX * 1
      end
      
      v:SetPoint("CENTER", Suika, "BOTTOMLEFT", xOfs, yOfs)
    end
  end

  -- Ball to Ball 
  for i,v in pairs(Balls) do
    if (v.IsActive and not v.IsClickable) then
      local p1, rf1, rp1, x1, y1 = v:GetPoint()
      local r1 = (GR.Suika.BallSizes[v.Size] / 2) * Main.ScreenRatio

      for j,k in pairs(Balls) do
        if (k.IsActive and j ~= i) then
          local p2, rf2, rp2, x2, y2 = k:GetPoint()
          local r2 = (GR.Suika.BallSizes[k.Size] / 2) * Main.ScreenRatio
          
          if(GR:DoCirclesOverlap(x1, y1, r1, x2, y2, r2)) then
            v.SkipGravity = true
            k.SkipGravity = true
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
              v.Mass = (4/3) * math.pi * (GR.Suika.BallSizes[v.Size] / 2)^3
              local color = GR.Suika.Const.Colors[v.Size]
              v.Tex:SetColorTexture(color[1], color[2], color[3], color[4])
              v:SetSize(GR.Suika.BallSizes[v.Size] * Main.XRatio, GR.Suika.BallSizes[v.Size] * Main.YRatio)
            else
              local distance = sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
              local overlap = (distance - r1 - r2) * .5
              
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
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  
  GR:SizeSuika()
  
  Suika:Show()
  Solo:Show()
  Solo.Timer:Show()
  Solo.Info:SetText("Click and Drag Balls")
  Solo.Info:Show()
  Solo.PointsFS:Show()
  if (GR.Suika.ActiveState == 'Stop') then Solo.Start:Show() end
  if (GR.Suika.ActiveState == 'Start') then Solo.Stopx:Show() Suika.Game:Show() end
  
  GR:SuikaStart()
end

function GR:SuikaHide()
  local Suika = GR_GUI.Main.Suika
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  
  Suika:Hide()
  Solo.PointsFS:Hide()
  Solo.GameOverFS:Hide()
end

-- Start Stop Pause Unpause
function GR:SuikaStart()
  local Suika = GR_GUI.Main.Suika
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  
  -- Reset Variables
  GR.Suika.Points = 0
  GR.Suika.SimTime = 0

  -- Start Game
  Suika.Game:Show()
  local Ball = CreateFrame("Frame", Ball, Suika)
  Ball.New = true
  GR:SuikaMakeBall(Ball)
  
  -- Show Game Info and Buttons
  GR.Suika.ActiveState = 'Start'
  Solo.PointsFS:SetText(GR.Suika.Points)
  Solo.Stopx:Show()
  Solo.Pausex:Hide()
  Solo.Start:Hide()
  Solo.GameOverFS:Hide()
end

function GR:SuikaStop()
  local Suika = GR_GUI.Main.Suika
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  
  GR.Suika.ActiveState = 'Stop'
  Solo.Start:Show()
  Solo.Pausex:Hide()
  Solo.Stopx:Hide()
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
-- points
-- end-game
-- make balls work properly