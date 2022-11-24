-- Create
function GR:CreateSnake()
  local Main = GR_GUI.Main

  -- Constants
  GR.Snake = {}
  GR.Snake.Const = {}
  GR.Snake.Const.Width = 720 
  GR.Snake.Const.Height = 395

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
  Snake.GameTime = 0

  -- Create
  GR:CreateSnakeGameLoop()
  GR:CreateSnakeStartStop()
  GR:CreateSnakeTimer()

  -- Size
  GR:SnakeSize()
end

function GR:CreateSnakeGameLoop()
  local Snake = GR_GUI.Main.Snake

  Snake.Game = CreateFrame("Frame", Game, Snake)
  Snake.Game:SetScript("OnUpdate", function(self, elapsed) GR:SnakeUpdate(self, elapsed) end)
  Snake.Game:Hide()
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

  Snake.GameTime = 0

  Snake.Game:Show()
  Snake.Stopx:Show()
  Snake.Start:Hide()
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
end

-- Function