-- Create
function GR:CreateMinesweepers()
  local Main = GR_GUI.Main
  GR.Minesweepers = {}
  
  Main.Minesweepers = CreateFrame("Frame", "Minesweepers", Main, "ThinBorderTemplate")
  local Minesweepers = Main.Minesweepers

  Minesweepers:Hide()

  GR:SizeMinesweepers()
end

-- Size
function GR:SizeMinesweepers()
  local Main = GR_GUI.Main
  local Minesweepers = Main.Minesweepers

  Minesweepers:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Minesweepers:SetSize(GR.Win.Const.GameScreenWidth * Main.XRatio, GR.Win.Const.GameScreenHeight * Main.YRatio)
end

-- Show / Hide
function GR:MinesweepersShow()
  GR:SizeMinesweepers()

  GR_GUI.Main.Minesweepers:Show()
end

function GR:MinesweepersHide()
  GR_GUI.Main.Minesweepers:Hide()
end