-- Create
function GR:CreateMinesweepers()
  local Main = GR_GUI.Main
  GR.Minesweepers = {}
  GR.Minesweepers.Const = {}
  GR.Minesweepers.Const.NumOfCols = 40
  GR.Minesweepers.Const.NumOfRows = 30
  
  Main.Minesweepers = CreateFrame("Frame", "Minesweepers", Main, "ThinBorderTemplate")
  local Minesweepers = Main.Minesweepers

  Minesweepers:Hide()
  
  GR:CreateMinesweepersGrid()

  GR:SizeMinesweepers()
end

function GR:CreateMinesweepersGrid()
  local Main = GR_GUI.Main
  local Minesweepers = Main.Minesweepers
  local rows = GR.Minesweepers.Const.NumOfRows
  local cols = GR.Minesweepers.Const.NumOfCols
  
  Minesweepers.Grid = {}

  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      Minesweepers.Grid[j + ((i - 1) * cols)] = CreateFrame("Button", nil, Minesweepers)
      local Tile = Minesweepers.Grid[j + ((i - 1) * cols)]
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetColorTexture(255,255,255, 1)
      Tile.Tex:SetAllPoints(Tile)
      Tile.Tex:Hide()
      Tile:SetScript("OnClick", function() 
        Tile.Tex:Show()
      end)
    end
  end
end

-- Size
function GR:SizeMinesweepers()
  local Main = GR_GUI.Main
  local Minesweepers = Main.Minesweepers
  
  Minesweepers:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Minesweepers:SetSize(GR.Win.Const.GameScreenWidth * Main.XRatio, GR.Win.Const.GameScreenHeight * Main.YRatio)
  
  GR:SizeMinesweepersGrid()
end

function GR:SizeMinesweepersGrid()
  local Main = GR_GUI.Main
  local Minesweepers = Main.Minesweepers
  local Grid = Minesweepers.Grid
  local cols = GR.Minesweepers.Const.NumOfCols
  local rows = GR.Minesweepers.Const.NumOfRows
  local height = GR.Win.Const.GameScreenHeight
  local width = GR.Win.Const.GameScreenWidth
  
  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      local Tile = Minesweepers.Grid[j + ((i - 1) * cols)]
      Tile:SetPoint("BOTTOMLEFT", (width * Main.XRatio) * ((j -1) / cols), (height * Main.YRatio) * ((i -1) / rows))
      Tile:SetSize((width * Main.XRatio) / cols, (height * Main.YRatio) / rows)
    end
  end
end

-- Func


-- Show / Hide
function GR:MinesweepersShow()
  GR:SizeMinesweepers()

  GR_GUI.Main.Minesweepers:Show()
end

function GR:MinesweepersHide()
  GR_GUI.Main.Minesweepers:Hide()
end