-- Create
function GR:CreateSnake()
  local Main = GR_GUI.Main

  -- Constants
  GR.Snake = {}
  GR.Snake.Const = {}
  GR.Snake.Const.Width = 720 
  GR.Snake.Const.Height = 395
  GR.Snake.Const.NumOfCols = 60
  GR.Snake.Const.NumOfRows = 30

  -- Snake Frame
  Main.Snake = CreateFrame("Frame", Snake, Main, "ThinBorderTemplate")
  local Snake = Main.Snake
  Snake:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Snake:SetSize(GR.Snake.Const.Width * Main.XRatio, GR.Snake.Const.Height * Main.YRatio)
  Snake:Hide()

  -- Variables
  Snake.XRatio = Snake:GetWidth() / GR.Snake.Const.Width
  Snake.YRatio = Snake:GetHeight() / GR.Snake.Const.Height
  Snake.ScreenRatio = ((Snake:GetWidth() / GR.Snake.Const.Width) + (Snake:GetHeight() / GR.Snake.Const.Height)) / 2
  Snake.Pos = {
    X = math.floor(GR.Snake.Const.NumOfCols / 2),
    Y = math.floor(GR.Snake.Const.NumOfRows / 2),
  }
  Snake.Dir = "Up"
  Snake.GameTime = 0
  Snake.MoveInterval = .35
  Snake.MoveTick = 0


  -- Create
  GR:CreateSnakeGameLoop()
  GR:CreateSnakeStartStop()
  GR:CreateSnakeTimer()
  GR:CreateSnakeGrid()
  GR:CreateSnakeApple()

  -- Size
  GR:SnakeSize()
end

function GR:CreateSnakeGameLoop()
  local Snake = GR_GUI.Main.Snake

  Snake.Game = CreateFrame("Frame", Game, Snake)
  Snake.Game:SetScript("OnUpdate", function(self, elapsed) GR:SnakeUpdate(self, elapsed) end)
  Snake.Game:Hide()

  GR:SnakeControls()
end

function GR:CreateSnakeStartStop()
  local Snake = GR_GUI.Main.Snake

  Snake.Start = CreateFrame("Button", Start, Snake, "UIPanelButtonTemplate")
  Snake.Start.FS = Snake.Start:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  Snake.Start.FS:SetText("Start")
  Snake.Start.FS:SetTextColor(.8,.8,.8, 1)
  Snake.Start.FS:SetPoint("CENTER")
  Snake.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.SnakeStart()
    end
  end)
  Snake.Stopx = CreateFrame("Button", Stopx, Snake, "UIPanelButtonTemplate")
  Snake.Stopx.FS = Snake.Stopx:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  Snake.Stopx.FS:SetText("Stop")
  Snake.Stopx.FS:SetTextColor(.8,.8,.8, 1)
  Snake.Stopx.FS:SetPoint("CENTER")
  Snake.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR:SnakeStop()
    end
  end)
  Snake.Stopx:Hide()
end

function GR:CreateSnakeTimer()
  local Snake = GR_GUI.Main.Snake

  Snake.Timer = Snake:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Snake.Timer:SetText(Snake.GameTime)
  Snake.Timer:SetTextColor(.8,.8,.8, 1)
end

function GR:CreateSnakeGrid()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Grid = {}

  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)] = CreateFrame("Frame", nil, Snake)
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetColorTexture(255,255,255, 1)
      Tile.Tex:SetAllPoints(Tile)
      Tile:Hide()
    end
  end
end

function GR:CreateSnakeApple()
  local Snake = GR_GUI.Main.Snake

  Snake.Apple = CreateFrame("Frame", Apple, Snake)
  local Apple = Snake.Apple
  Apple.Tex = Apple:CreateTexture()
  Apple.Tex:SetColorTexture(255,0,0, 1)
  Apple.Tex:SetAllPoints(Apple)
  Apple.Pos = {
    X = math.random(1, GR.Snake.Const.NumOfCols),
    Y = math.random(1, GR.Snake.Const.NumOfRows),
  }
  Apple:Hide()
end

-- Resize
function GR:SnakeSize()
  local Snake = GR_GUI.Main.Snake

  -- Snake Frame
  Snake:SetPoint("BOTTOM", 0, 25 * GR_GUI.Main.YRatio)
  Snake:SetSize(GR.Snake.Const.Width * GR_GUI.Main.XRatio, GR.Snake.Const.Height * GR_GUI.Main.YRatio)

  -- Reset Snake Screen Variables
  Snake.XRatio = Snake:GetWidth() / GR.Snake.Const.Width
  Snake.YRatio = Snake:GetHeight() / GR.Snake.Const.Height
  Snake.ScreenRatio = ((Snake:GetWidth() / GR.Snake.Const.Width) + (Snake:GetHeight() / GR.Snake.Const.Height)) / 2


  GR:SnakeSizeStartStop()
  GR:SizeSnakeTimer()
  GR:SizeSnakeGrid()
  GR:SizeSnakeApple()
end

function GR:SnakeSizeStartStop()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Start:SetPoint("TOPLEFT", 50 * Snake.XRatio, 34 * Snake.YRatio)
  Snake.Start:SetSize(100 * Snake.XRatio, 30 * Snake.YRatio)
  Snake.Start.FS:SetTextScale(1.1 * Snake.ScreenRatio)
  Snake.Stopx:SetPoint("TOPLEFT", 50 * Snake.XRatio, 34 * Snake.YRatio)
  Snake.Stopx:SetSize(100 * Snake.XRatio, 30 * Snake.YRatio)
  Snake.Stopx.FS:SetTextScale(1.1 * Snake.ScreenRatio)
end

function GR:SizeSnakeTimer()
  local Snake = GR_GUI.Main.Snake
  local Timer = Snake.Timer
  Timer:SetPoint("BOTTOMLEFT", Snake, "TOPRIGHT", -200 * Snake.XRatio, 6 * Snake.YRatio)
  Timer:SetTextScale(2 * Snake.ScreenRatio)
end

function GR:SizeSnakeGrid()
  local Snake = GR_GUI.Main.Snake
  local Grid = Snake.Grid

  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]
      Tile:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * ((j -1) / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * ((i -1) / GR.Snake.Const.NumOfRows))
      Tile:SetSize((GR.Snake.Const.Width * Snake.XRatio) / GR.Snake.Const.NumOfCols, (GR.Snake.Const.Height * Snake.YRatio) / GR.Snake.Const.NumOfRows)
    end
  end
end

function GR:SizeSnakeApple()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Apple:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * (Apple.Pos.X / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * (Apple.Pos.Y / GR.Snake.Const.NumOfRows))
  Apple:SetSize((GR.Snake.Const.Width * Snake.XRatio) / GR.Snake.Const.NumOfCols, (GR.Snake.Const.Height * Snake.YRatio) / GR.Snake.Const.NumOfRows)
end

-- Show / Hide
function GR:SnakeShow()
  local Snake = GR_GUI.Main.Snake

  GR:SnakeSize()

  Snake:Show()
end

function GR:SnakeHide()
  local Snake = GR_GUI.Main.Snake
  
  GR:SnakeStop()

  Snake:Hide()
end

-- Start Stop
function GR:SnakeStart()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Snake.GameTime = 0
  Snake.Dir = "Up"
  Snake.Pos = {
    X = math.floor(GR.Snake.Const.NumOfCols / 2),
    Y = math.floor(GR.Snake.Const.NumOfRows / 2),
  }
  GR:SnakeMoveApple()

  Snake.Game:Show()
  Snake.Stopx:Show()
  Snake.Start:Hide()
  Snake.Apple:Show()
end

function GR:SnakeStop()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Game:Hide()
  Snake.Start:Show()
  Snake.Stopx:Hide()
end

-- Update
function GR:SnakeUpdate(self, elapsed)
  local Snake = GR_GUI.Main.Snake

  Snake.GameTime = Snake.GameTime + elapsed

  Snake.Timer:SetText(math.floor(Snake.GameTime * 100) / 100)

  local MoveSnake = GR:SnakeUpdatePos(elapsed)

  if (MoveSnake) then GR:SnakeMove() end

  local Grid = Snake.Grid
  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]

      -- Show Current Pos Tile
      if (i == Snake.Pos.Y and j == Snake.Pos.X) then
        Tile:Show()
      else
        Tile:Hide()
      end

      -- Light Up Animation
      -- if (math.floor(Snake.GameTime) % 2 == 0) then
      --   if (j % 2 == 0) then
      --     Tile:Show()
      --   else
      --     Tile:Hide()
      --   end
      -- end
      -- if (math.floor(Snake.GameTime) % 2 == 1) then
      --   if (j % 2 == 1) then
      --     Tile:Show()
      --   else
      --     Tile:Hide()
      --   end
      -- end
    end
  end
end

function GR:SnakeUpdatePos(elapsed)
  local Snake = GR_GUI.Main.Snake

  Snake.MoveTick = Snake.MoveTick + elapsed

  if (Snake.MoveTick > Snake.MoveInterval) then
    Snake.MoveTick = Snake.MoveTick - Snake.MoveInterval

    return true
  end
  return false
end

-- Function
function GR:SnakeControls()
  local Snake = GR_GUI.Main.Snake
  local Game = GR_GUI.Main.Snake.Game

  Game:SetScript("OnKeyDown", function(self, key) 
    if (key == "W") then
      Snake.Dir = "Up"
    end
    if (key == "A") then
      Snake.Dir = "Left"
    end
    if (key == "S") then
      Snake.Dir = "Down"
    end
    if (key == "D") then
      Snake.Dir = "Right"
    end
  end)
end

function GR:SnakeMove()
  local Snake = GR_GUI.Main.Snake

  -- Change Pos
  if (Snake.Dir == "Up") then Snake.Pos.Y = Snake.Pos.Y + 1 end
  if (Snake.Dir == "Down") then Snake.Pos.Y = Snake.Pos.Y - 1 end
  if (Snake.Dir == "Right") then Snake.Pos.X = Snake.Pos.X + 1 end
  if (Snake.Dir == "Left") then Snake.Pos.X = Snake.Pos.X - 1 end
  
  -- Bounds Check
  if (Snake.Pos.Y > GR.Snake.Const.NumOfRows) then Snake.Pos.Y = 1 end
  if (Snake.Pos.Y < 1) then Snake.Pos.Y = GR.Snake.Const.NumOfRows end
  if (Snake.Pos.X > GR.Snake.Const.NumOfCols) then Snake.Pos.X = 1 end
  if (Snake.Pos.X < 1) then Snake.Pos.X = GR.Snake.Const.NumOfCols end
end

function GR:SnakeMoveApple()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Apple.Pos = {
    X = math.random(1, GR.Snake.Const.NumOfCols),
    Y = math.random(1, GR.Snake.Const.NumOfRows),
  }

  Apple:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * (Apple.Pos.X / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * (Apple.Pos.Y / GR.Snake.Const.NumOfRows))
end

