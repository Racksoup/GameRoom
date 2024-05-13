-- Create
function GR:CreateMinesweepers()
  local Main = GR_GUI.Main
  GR.Minesweepers = {}
  GR.Minesweepers.Const = {}
  GR.Minesweepers.Const.NumOfCols = 24
  GR.Minesweepers.Const.NumOfRows = 16
  GR.Minesweepers.Const.NumOfBombs = 80
  
  GR.Minesweepers.isBoardSet = false
  GR.Minesweepers.tilesRevealed = 0

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
      Tile.flagged = false
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetColorTexture(255,255,255, .2)
      Tile.Tex:SetAllPoints(Tile)
      Tile.Tex:Show()
      Tile.FS = Tile:CreateFontString(nil, "OVERLAY", "GameTooltipText")
      Tile.FS:Hide()
      Tile:RegisterForClicks("LeftButtonDown", "RightButtonDown")
      Tile:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton") then
          Tile.flagged = false
          Tile.FS:Show()
          if (not GR.Minesweepers.isBoardSet) then
            GR:MinesweepersSetBoard(j + ((i - 1) * cols))
            GR.Minesweepers.isBoardSet = true
          end

          if (Tile.hasBomb) then 
            Tile.Tex:SetColorTexture(255,0,0, 1)
          else
            Tile.revealed = true
            Tile.Tex:Hide() 
            if Tile.bombsTouching == 0 then
              local row, col = GR:MinesweepersGetTilePosition(Tile)
              GR:MinesweepersRevealEmptyNeighbors(row, col)
            end
          end

          -- check game conditions after player move
          GR:MinesweepersCheckForLose(Tile)
          GR:MinesweepersCheckForWin()
        end
        
        if (button == "RightButton" and Tile.revealed == false) then
          if (not Tile.flagged) then
            Tile.flagged = true
            Tile.Tex:Show()
            Tile.Tex:SetColorTexture(255,255,0, 1)
          else
            Tile.flagged = false
            Tile.Tex:SetColorTexture(255,255,255, .2)
          end
        end
        GR:MinesweeperBombsRemaining()
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
      GR:MinesweepersResetGridVariables()
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

function GR:MinesweepersRevealEmptyNeighbors(row, col)
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

function GR:MinesweepersGetTilePosition(Tile)
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

function GR:MinesweepersDisableClicks()
  local Grid = GR_GUI.Main.Minesweepers.Grid

  for i,v in ipairs(Grid) do 
    v:Disable()
  end
end

function GR:MinesweeperBombsRemaining()
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  local total = 0

  for i,v in ipairs (GR_GUI.Main.Minesweepers.Grid) do
    if (v.flagged) then
      total = total + 1
    end
  end

  Solo.PointsFS:SetText("Bombs: " .. GR.Minesweepers.Const.NumOfBombs - total)
end

-- Win / Lose
function GR:MinesweepersCheckForWin()
  local whiteSpaces = GR.Minesweepers.Const.NumOfRows * GR.Minesweepers.Const.NumOfCols - GR.Minesweepers.Const.NumOfBombs
  local totalRevealed = 0

  for i,v in ipairs (GR_GUI.Main.Minesweepers.Grid) do
    if (v.revealed) then
      totalRevealed = totalRevealed + 1
    end
  end
  if ( whiteSpaces == totalRevealed ) then
    GR:MinesweepersDisableClicks()
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:Show()
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:SetText("Winner!")
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:SetTextColor(0,1,0, 1)
  end
end

function GR:MinesweepersCheckForLose(tile)
  if (tile.hasBomb) then
    --show bombs
    for i,v in pairs(GR_GUI.Main.Minesweepers.Grid) do 
      if v.hasBomb then 
        v.Tex:SetColorTexture(255,0,0, 1)
        v.Tex:Show()
      end
    end
    
    GR:MinesweepersDisableClicks()
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:Show()
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:SetText("Game Over")
    GR_GUI.Main.HeaderInfo.Solo.GameOverFS:SetTextColor(1,0,0, 1)
  end
end

-- Reset
function GR:MinesweepersResetGridVariables()
  local Grid = GR_GUI.Main.Minesweepers.Grid
  for _, tile in ipairs(Grid) do
    tile.hasBomb = false
    tile.bombsTouching = 0
    tile.revealed = false
    tile.flagged = false
    tile.Tex:SetColorTexture(255,255,255, .2)
    tile.Tex:Show()
    tile.FS:Hide()
    tile.FS:SetText("")
  end
end

function GR:MinesweepersReset()
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  Solo.OnState = "Start"

  for i,v in ipairs(GR_GUI.Main.Minesweepers.Grid) do 
    v:Enable()
  end
  
  Solo.GameOverFS:Hide()
  GR.Minesweepers.isBoardSet = false
  GR.Minesweepers.tilesRevealed = 0
  GR:MinesweeperBombsRemaining()

  GR:MinesweepersResetGridVariables()
end

-- Show / Hide
function GR:MinesweepersShow()
  GR:SizeMinesweepers()
  
  local Solo = GR_GUI.Main.HeaderInfo.Solo
  
  Solo.Stopx:Show()
  Solo.PointsFS:Show()
  GR:MinesweeperBombsRemaining()

  GR_GUI.Main.Minesweepers:Show()
end

function GR:MinesweepersHide()
  GR_GUI.Main.Minesweepers:Hide()
end
