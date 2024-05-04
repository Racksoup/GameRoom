-- Create
function GR:CreateMinesweepers()
  local Main = GR_GUI.Main
  GR.Minesweepers = {}
  GR.Minesweepers.Const = {}
  GR.Minesweepers.Const.NumOfCols = 24
  GR.Minesweepers.Const.NumOfRows = 16
  GR.Minesweepers.Const.NumOfBombs = 80
  
  GR.Minesweepers.isBoardSet = false

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
      Minesweepers.Grid[j + ((i - 1) * cols)] = CreateFrame("Button", nil, Minesweepers, "ThinBorderTemplate")
      local Tile = Minesweepers.Grid[j + ((i - 1) * cols)]
      Tile.hasBomb = false
      Tile.bombsTouching = 0
      Tile.revealed = false
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetColorTexture(255,255,255, .2)
      Tile.Tex:SetAllPoints(Tile)
      Tile.Tex:Show()
      Tile.FS = Tile:CreateFontString(nil, "OVERLAY", "GameTooltipText")
      Tile.FS:Hide()
      Tile:SetScript("OnClick", function() 
        Tile.FS:Show()
        if (not GR.Minesweepers.isBoardSet) then
          GR:MinesweepersSetBoard(j + ((i - 1) * cols))
          GR.Minesweepers.isBoardSet = true
        end

        if (Tile.hasBomb) then 
          Tile.Tex:SetColorTexture(255,0,0, 1)
        else
          Tile.Tex:Hide() 
          if Tile.bombsTouching == 0 then
            local row, col = GR:GetTilePosition(Tile)
            GR:RevealEmptyNeighbors(row, col)
          end
        end
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
      Tile.FS:SetPoint("CENTER")
      Tile.FS:SetTextScale(1 * Main.ScreenRatio)
    end
  end
end

-- Func
function GR:MinesweepersSetBoard(clickedTile)
  local Grid = GR_GUI.Main.Minesweepers.Grid
  local function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
  end

  local function rollBoard()
    -- Give some spaces bombs
    local indices = {}
    for i = 1, #Grid do
      indices[i] = i
    end
    indices = shuffle(indices)

    for i = 1, GR.Minesweepers.Const.NumOfBombs do 
      Grid[indices[i]].hasBomb = true
    end


    -- Calculate and set numbers for tiles touching bombs
    GR:MinesweepersTilesTouching()
    
    -- Check if the clicked tile contains a bomb
    if Grid[clickedTile].hasBomb or Grid[clickedTile].bombsTouching > 0 then
      -- Reroll the board if the clicked tile contains a bomb or is touching a bomb
      GR:ResetGridVariables()
      rollBoard()
    end
  end

  rollBoard()

end

function GR:MinesweepersTilesTouching()
  local Grid = GR_GUI.Main.Minesweepers.Grid
  local cols = GR.Minesweepers.Const.NumOfCols
  local rows = GR.Minesweepers.Const.NumOfRows

  local function countNeighboringBombs(row, col)
    local count = 0
    for i = -1, 1 do
      for j = -1, 1 do
        local r = row + i
        local c = col + j
        if r >= 1 and r <= rows and c >= 1 and c <= cols then
          if Grid[(r - 1) * cols + c].hasBomb then
            count = count + 1
          end
        end
      end
    end
    return count
  end

  for i = 1, rows do
    for j = 1, cols do
      local index = (i - 1) * cols + j
      if not Grid[index].hasBomb then
        Grid[index].FS:SetText("")
        local bombsTouching = countNeighboringBombs(i, j)
        if bombsTouching > 0 then
          Grid[index].bombsTouching = bombsTouching
          -- Set the text to display the number of neighboring bombs
          Grid[index].FS:SetText(bombsTouching)
        end
      end
    end
  end
end

function GR:RevealEmptyNeighbors(row, col)
  local cols = GR.Minesweepers.Const.NumOfCols
  local rows = GR.Minesweepers.Const.NumOfRows

  local function revealNeighbors(row, col)
    for i = -1, 1 do
      for j = -1, 1 do
        local r = row + i
        local c = col + j
        if r >= 1 and r <= rows and c >= 1 and c <= cols then
          local index = (r - 1) * cols + c
          local neighborTile = GR_GUI.Main.Minesweepers.Grid[index]
          if not neighborTile.revealed and not neighborTile.hasBomb then
            neighborTile.revealed = true
            neighborTile.FS:Show()
            neighborTile.Tex:Hide()
            if neighborTile.bombsTouching == 0 then
              -- Recursively reveal neighbors if they also have no neighboring bombs
              revealNeighbors(r, c)
            end
          end
        end
      end
    end
  end

  revealNeighbors(row, col)
end

function GR:GetTilePosition(Tile)
  local Grid = GR_GUI.Main.Minesweepers.Grid
  local cols = GR.Minesweepers.Const.NumOfCols

  for i, gridTile in ipairs(Grid) do
      if gridTile == Tile then
          local row = math.ceil(i / cols)
          local col = i - (row - 1) * cols
          return row, col
      end
  end
end

function GR:ResetGridVariables()
  local Grid = GR_GUI.Main.Minesweepers.Grid
  for _, tile in ipairs(Grid) do
    tile.hasBomb = false
    tile.bombsTouching = 0
    tile.revealed = false
    tile.Tex:SetColorTexture(255,255,255, .2)
    tile.Tex:Show()
    tile.FS:Hide()
    tile.FS:SetText("")
  end
end

-- Show / Hide
function GR:MinesweepersShow()
  GR:SizeMinesweepers()

  GR_GUI.Main.Minesweepers:Show()
end

function GR:MinesweepersHide()
  GR_GUI.Main.Minesweepers:Hide()
end