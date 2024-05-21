-- Create
function GR:CreateSuduko()
  local Main = GR_GUI.Main
  GR.Suduko = {}
  GR.Suduko.Const = {}

  Main.Suduko = CreateFrame("Frame", "Suduko", Main, "ThinBorderTemplate")
  Main.Suduko:Hide()

  
  GR:SizeSuduko()
end

-- Size
function GR:SizeSuduko()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko

  Suduko:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Suduko:SetSize(GR.Win.Const.GameScreenWidth * Main.XRatio, GR.Win.Const.GameScreenHeight * Main.YRatio)
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
