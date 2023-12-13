function GR:SuikaCreate()
  -- Contants
  GR.Suika = {}
  GR.Suika.Const = {}
  GR.Suika.Const.GameScreenWidth = 400
  GR.Suika.Const.Tab1Width = 450
  GR.Suika.Const.BallSizes = {20, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100}
  GR.Suika.Const.Gravity = -9.5
  GR.Suika.Const.MinGravity = -4.5
  
  -- Suika Frame
  GR_GUI.Main.Suika = CreateFrame("Frame", Suika, GR_GUI.Main, "ThinBorderTemplate")
  local Suika = GR_GUI.Main.Suika
  Suika:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Win.Const.Tab1Height))
  Suika:SetSize(GR_GUI.Main:GetWidth() * (GR.Suika.Const.GameScreenWidth / GR.Suika.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  Suika:SetClipsChildren(true)
  Suika:Hide()
  
  -- Variables
  GR.Suika.XRatio = Suika:GetWidth() / GR.Suika.Const.GameScreenWidth
  GR.Suika.YRatio = Suika:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Suika.Const.GameScreenWidth + Suika:GetHeight() / GR.Win.Const.GameScreenHeight) / 2
  GR.Suika.BallSizes = {}
  for i,v in ipairs(GR.Suika.Const.BallSizes) do
    GR.Suika.BallSizes[i] = v * GR.Suika.ScreenRatio
  end
  GR.Suika.ActiveState = "Start"
  GR.Suika.Points = 0
  GR.Suika.Gravity = GR.Suika.Const.Gravity * GR.Suika.YRatio
  GR.Suika.MinGravity = GR.Suika.Const.MinGravity * GR.Suika.YRatio

  -- Create
  GR:SuikaGameLoop()
  GR:SuikaControls()
  GR:SuikaCreateStatusBtns()
  GR:SuikaCreateInfo()
  GR:SuikaCreateBalls()
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

function GR:SuikaCreateBalls()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  Suika.Balls = {}



  function CreateUseNextBall()
    local Ball = nil
    for i,v in pairs(Suika.Balls) do -- find usable ball
      if (v.IsActive == false) then
        Ball = v
        break;
      end
    end
    if (Ball == nil) then -- if no usable balls make one
      Ball = CreateFrame("Frame", Ball, Suika)
    end
    MakeBall(Ball)
  end

  function MakeBall(Ball)
    Ball.Size = 1
    Ball.IsClickable = true
    Ball.IsActive = true
    Ball.VelY = 0
    Ball:SetSize(GR.Suika.BallSizes[Ball.Size] * GR.Suika.XRatio, GR.Suika.BallSizes[Ball.Size] * GR.Suika.YRatio)
    Ball:SetPoint("CENTER", Suika, "CENTER", 0, 150)
    Ball:SetMovable(true)
    Ball:EnableMouse(true)
    Ball:SetPropagateKeyboardInput(true)
    Ball:RegisterForDrag("LeftButton")
    Ball:SetScript("OnMouseDown", function(self, button)
      self:StartMoving()
    end)
    Ball:SetScript("OnMouseUp", function(self)
      Ball.IsClickable = false
      self:StopMovingOrSizing()
      self:SetMovable(false)
      self:EnableMouse(false)
      local left, bottom, width, height = self:GetRect()
      local left2, bottom2, width2, height2 = Suika:GetRect()
      self:ClearAllPoints()
      self:SetPoint("CENTER", Suika, "CENTER", (left - Suika:GetWidth() / 2) - left2 + 9, 150)
      CreateUseNextBall()
    end)
    if (Ball:GetRegions() == nil) then -- if new frame, create new texture
      Ball.Tex = Ball:CreateTexture()
      Ball.Tex:SetAllPoints(Ball)
      Ball.Tex:SetColorTexture(1,0,0,1)
    end
    Ball:Show()
    table.insert(Suika.Balls, Ball)
  end

  local Ball = CreateFrame("Frame", Ball, Suika)
  MakeBall(Ball)


end

-- Size
function GR:SuikaSize()
  local Main = GR_GUI.Main
  local Suika = Main.Suika

  -- Game Screen
  Suika:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Win.Const.Tab1Height))
  Suika:SetSize(Main:GetWidth() * (GR.Suika.Const.GameScreenWidth / GR.Suika.Const.Tab1Width), Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  GR.Suika.XRatio = Suika:GetWidth() / GR.Suika.Const.GameScreenWidth
  GR.Suika.YRatio = Suika:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.Suika.ScreenRatio = (Suika:GetWidth() / GR.Suika.Const.GameScreenWidth + Suika:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  -- variables
  GR.Suika.Gravity = GR.Suika.Const.Gravity * GR.Suika.YRatio
  GR.Suika.MinGravity = GR.Suika.Const.MinGravity * GR.Suika.YRatio

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
  GR:SuikaUpdateBalls(self, elapsed)

  GR:SuikaCol()
end

function GR:SuikaUpdateBalls(self, elapsed)
  for i,v in pairs(GR_GUI.Main.Suika.Balls) do
    if (v.IsClickable == false) then -- apply gravity
      v.VelY = v.VelY + (GR.Suika.Gravity * elapsed)
      if (v.VelY < GR.Suika.MinGravity) then v.VelY = GR.Suika.MinGravity end -- limit fall speed
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint()
      v:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + v.VelY)
    end
  end
end

-- Collisions
function GR:SuikaCol()
  local Suika = GR_GUI.Main.Suika
  local Balls = Suika.Balls
  local Border = {
    top = Suika:GetHeight() /2,
    right = Suika:GetWidth() /2,
    bottom = - Suika:GetHeight() /2,
    left= - Suika:GetWidth() /2
  }


  -- Ball to Wall
  for i,v in pairs(Balls) do
    if (v.IsActive) then
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint()
      -- print(point, relativeTo, relativePoint, xOfs, yOfs)
      BallSize = GR.Suika.BallSizes[v.Size] / 2
      local Ball = {
        top = yOfs + BallSize,
        right = xOfs + BallSize,
        bottom = yOfs - BallSize,
        left = xOfs - BallSize
      }

      print(Border.bottom, Ball.bottom)

      -- check if ship is outside of border
      -- circle top past border top
      local pos = {x = xOfs, y = yOfs}
      if (Ball.top > Border.top) then 
        pos.y = Border.bottom - BallSize
      end
      -- circle right past border right
      if (Ball.right > Border.right) then 
        pos.x = Border.right - BallSize
      end
      -- circle bottom past border bottom
      if (Ball.bottom < Border.bottom) then 
        pos.y = Border.bottom + BallSize
      end
      -- circle left past border left
      if (Ball.left < Border.left) then 
        pos.x = Border.left + BallSize
      end
      
      -- apply pos change if collision
      if (pos.x ~= xOfs or pos.y ~= yOfs) then
        v:SetPoint("CENTER", pos.x, pos.y)
      end
    end
  end
end

-- Controls
function GR:SuikaControls()

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

  -- Start Game
  Suika.Game:Show()
  
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
end

function GR:SuikaGameOver()
  GR:SuikaStop()

  GR_GUI.Main.Suika.GameOverFS:Show()
end

function GR:ColSquareCircle(cir, rect)
  local MarginX = 9 * (GR_GUI.Main:GetWidth() / 800)
  local MarginY = 9 * (GR_GUI.Main:GetHeight() / 640)
  if (cir.left + MarginX > rect.br.x - MarginX or cir.top - MarginY < rect.br.y + MarginY or cir.right - MarginX < rect.tl.x + MarginX or cir.bottom + MarginY > rect.tl.y - MarginY) then
    return false
  end
  return true
end

-- needs resize dimensions locked so circles stay circles