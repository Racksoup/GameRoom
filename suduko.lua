-- Create
function GR:CreateSuduko()
  local Main = GR_GUI.Main
  GR.Suduko = {}
  GR.Suduko.Const = {}
  GR.Suduko.Const.NumOfCols = 9
  GR.Suduko.Const.NumOfRows = 9

  Main.Suduko = CreateFrame("Frame", "Suduko", Main, "ThinBorderTemplate")
  Main.Suduko:Hide()

  GR:CreateSudukoGrid()
  GR:CreateSudukoBlackLines()

  GR:SizeSuduko()
end

function GR:CreateSudukoGrid()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local rows = GR.Suduko.Const.NumOfRows
  local cols = GR.Suduko.Const.NumOfCols

  Suduko.Grid = {}

  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      Suduko.Grid[j + ((i -1) * cols)] = CreateFrame("BUTTON", nil, Suduko, "ThinBorderTemplate")
      local Tile = Suduko.Grid[j + ((i -1) * cols)] 
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetAllPoints(Tile)
      Tile.Tex:Hide()
      Tile.FS = Tile:CreateFontString(nil, "OVERLAY", "GameTooltipText")
      Tile.FS:Hide()
      Tile:RegisterForClicks("LeftButtonDown", "RightButtonDown")
      Tile:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton") then
          Tile.Tex:Show()
          Tile.Tex:SetColorTexture(255,0,0, .2)
        end
        
        if (button == "RightButton") then
          Tile.Tex:Show()
          Tile.Tex:SetColorTexture(255,255,255, .2)

        end
      end)
    end
  end
end

function GR:CreateSudukoBlackLines()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko

  Suduko.BlackLines = CreateFrame("FRAME", "BlackLines", Suduko)
  local BlackLines = Suduko.BlackLines
  BlackLines:SetAllPoints(Suduko);
  BlackLines:Raise()

  BlackLines.VL = BlackLines:CreateLine()
  BlackLines.VL:SetColorTexture(0,0,0, 1)
  BlackLines.VR = BlackLines:CreateLine()
  BlackLines.VR:SetColorTexture(0,0,0, 1)
  BlackLines.HB = BlackLines:CreateLine()
  BlackLines.HB:SetColorTexture(0,0,0, 1)
  BlackLines.HT = BlackLines:CreateLine()
  BlackLines.HT:SetColorTexture(0,0,0, 1)
end

-- Size
function GR:SizeSuduko()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko

  Suduko:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Suduko:SetSize(GR.Win.Const.SudukoScreenWidth * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio)

  GR:SizeSudukoGrid()
  GR:SizeSudukoBlackLines()
end

function GR:SizeSudukoGrid()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local Grid = Suduko.Grid
  local cols = GR.Suduko.Const.NumOfCols
  local rows = GR.Suduko.Const.NumOfRows
  local height = GR.Win.Const.SudukoScreenHeight
  local width = GR.Win.Const.SudukoScreenWidth
  
  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      local Tile = Suduko.Grid[j + ((i - 1) * cols)]
      Tile:SetPoint("BOTTOMLEFT", (width * Main.XRatio) * ((j -1) / cols), (height * Main.YRatio) * ((i -1) / rows))
      Tile:SetSize((width * Main.XRatio) / cols, (height * Main.YRatio) / rows)
      Tile.FS:SetPoint("CENTER")
      Tile.FS:SetTextScale(1 * Main.ScreenRatio)
    end
  end
end

function GR:SizeSudukoBlackLines()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local BlackLines = Suduko.BlackLines

  BlackLines.VL:SetThickness(5 * Main.ScreenRatio)
  BlackLines.VR:SetThickness(5 * Main.ScreenRatio)
  BlackLines.HB:SetThickness(5 * Main.ScreenRatio)
  BlackLines.HT:SetThickness(5 * Main.ScreenRatio)
  BlackLines.VL:SetStartPoint("TOPLEFT", GR.Win.Const.SudukoScreenWidth * Main.XRatio /3, -3 * Main.YRatio)
  BlackLines.VL:SetEndPoint("BOTTOMLEFT", GR.Win.Const.SudukoScreenWidth * Main.XRatio /3, 3 * Main.YRatio)
  BlackLines.VR:SetStartPoint("TOPLEFT", (GR.Win.Const.SudukoScreenWidth * Main.XRatio /3) *2, -3 * Main.YRatio)
  BlackLines.VR:SetEndPoint("BOTTOMLEFT", (GR.Win.Const.SudukoScreenWidth * Main.XRatio /3) *2, 3 * Main.YRatio)
  BlackLines.HB:SetStartPoint("BOTTOMLEFT", 3 * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio /3)
  BlackLines.HB:SetEndPoint("BOTTOMRIGHT", -3 * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio /3)
  BlackLines.HT:SetStartPoint("BOTTOMLEFT", 3 * Main.XRatio, (GR.Win.Const.SudukoScreenHeight * Main.YRatio /3) *2)
  BlackLines.HT:SetEndPoint("BOTTOMRIGHT", -3 * Main.XRatio, (GR.Win.Const.SudukoScreenHeight * Main.YRatio /3) *2)
end

-- Show / Hide
function GR:SudukoShow()
  local Solo = GR_GUI.Main.HeaderInfo.Solo

  GR:SizeSuduko()  
  
  GR_GUI.Main.Suduko:Show()
end

function GR:SudukoHide()
  GR_GUI.Main.Suduko:Hide()
end
