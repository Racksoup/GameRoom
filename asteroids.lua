-- create
function GR:CreateAsteroids()
  GR_GUI.Main.Asteroids = CreateFrame("Frame", Asteroids, GR_GUI.Main, "ThinBorderTemplate")
  local Asteroids = GR_GUI.Main.Asteroids
  Asteroids:SetPoint("BOTTOM", 0, 25)
  Asteroids:SetSize(770, 450)
  Asteroids:Hide()
  
  GR:SizeAsteroids()
end

-- resize
function GR:SizeAsteroids()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  
  -- Main Window
  Asteroids:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / 640))
  Asteroids:SetSize(Main:GetWidth() * (770 / 800), Main:GetHeight() * (450 / 640))
end

-- hide / show
function GR:AsteroidsHide()
  local Main = GR_GUI.Main
  local Asteroids = GR_GUI.Main.Asteroids
  
  Asteroids:Hide()
  GR:HideGame()
end

function GR:AsteroidsShow()
  GR.GameType = "Asteroids"
  GR:ShowSoloGame()
end
