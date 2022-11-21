-- create
function GR:CreateBattleships()
    -- Values
    GR.BattleshipsBoardP1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP2 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP1Old = nil
    GR.BattleshipsBoardP2Old = nil
    GR.Phase = 1
    GR.HasOpponentBoard = false
    GR.SentBoard = false
    GR.P1SpacesLeft = 25
    GR.P2SpacesLeft = 25
    GR.P1Ship1 = 6
    GR.P1Ship2 = 3
    GR.P1Ship3 = 8
    GR.P1Ship4 = 4
    GR.P1Ship5 = 4
    GR.P2Ship1 = 6
    GR.P2Ship2 = 3
    GR.P2Ship3 = 8
    GR.P2Ship4 = 4
    GR.P2Ship5 = 4
    
    -- Battleship Frame
    GR_GUI.Main.Battleships = CreateFrame("Frame", Battleships, GR_GUI.Main, "ThinBorderTemplate")
    local Battleships = GR_GUI.Main.Battleships
    Battleships:SetPoint("BOTTOM", 0, 25)
    Battleships:SetSize(770, 450)
    Battleships:Hide()
    
    -- Battleship Arrays
    GR_GUI.Main.Battleships.Buttons = {}
    GR_GUI.Main.Battleships.VLines = {}
    GR_GUI.Main.Battleships.HLines = {}
    GR_GUI.Main.Battleships.OppButtons = {}
    GR_GUI.Main.Battleships.OppVLines = {}
    GR_GUI.Main.Battleships.OppHLines = {}

    -- Player Board
    Battleships.Board = CreateFrame("Frame", Board, Battleships, "ThinBorderTemplate")
    local Board = Battleships.Board
    Board:SetPoint("BOTTOMLEFT", 0, 0)
    Board:SetSize(570, 450)
    Board:Hide()
    Battleships.Board.FS = Battleships.Board:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.Board.FS:SetPoint("TOP", 0, 22)
    Battleships.Board.FS:SetTextColor(.8,.8,.8, 1)
    Battleships.Board.FS:SetText(GR.PlayerName .. " Board")
    Battleships.Board.FS:SetTextScale(1.3)
    Battleships.Board.FS:Hide()
    
    -- Opponent Board
    Battleships.OppBoard = CreateFrame("Frame", OppBoard, Battleships, "ThinBorderTemplate")
    local OppBoard = Battleships.OppBoard
    OppBoard:SetPoint("BOTTOMRIGHT", 0, 0)
    OppBoard:SetSize(380, 420)
    OppBoard:Hide()
    Battleships.OppBoard.FS = Battleships.OppBoard:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.OppBoard.FS:SetPoint("TOP", 0, 22)
    Battleships.OppBoard.FS:SetTextColor(.8,.8,.8, 1)
    Battleships.OppBoard.FS:Hide()
    Battleships.OppBoard.FS:SetTextScale(1.3)
    
    -- info strings
    Battleships.CurrPhase = Battleships:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.CurrPhase:SetPoint("TOP", 0, 60)
    Battleships.CurrPhase:SetTextColor(.8,.8,.8, 1)
    Battleships.CurrPhase:SetTextScale(1.6)
    Battleships.CurrPhase:SetText("Place your Battleships")
    Battleships.ExtraInfo = Battleships:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.ExtraInfo:SetPoint("TOP", 0, 30)
    Battleships.ExtraInfo:SetTextColor(.8,.8,.8, 1)
    Battleships.ExtraInfo:SetTextScale(1.6)
    Battleships.ExtraInfo:SetText("Press X to rotate ships")
    
    -- Show Legend Button
    Battleships.ShowLegend = CreateFrame("Button", ShowLegend, Battleships, "UIPanelButtonTemplate")
    Battleships.ShowLegend:SetPoint("TOPRIGHT", -20, 60)
    Battleships.ShowLegend:SetSize(230, 58)
    Battleships.ShowLegendFS = Battleships.ShowLegend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.ShowLegendFS:SetPoint("CENTER")
    Battleships.ShowLegendFS:SetTextScale(1.8)
    Battleships.ShowLegendFS:SetTextColor(.8,.8,.8, 1)
    Battleships.ShowLegendFS:SetText("Legend")
    Battleships.ShowLegend:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            if (Battleships.Legend:IsVisible()) then
                Battleships.Legend:Hide()
            else
                Battleships.Legend:Show()
            end
        end
    end)
    Battleships.ShowLegend:Hide()
    
    -- Complete Phase 1 Btn
    Battleships.Phase = CreateFrame("Button", Phase, Battleships, "UIPanelButtonTemplate")
    Battleships.Phase:SetPoint("TOPLEFT", 20, 58)
    Battleships.Phase:SetSize(230, 61)
    Battleships.Phase:Hide()
    Battleships.Phase:SetScript("OnClick", function(self, button, down) 
        if (button == "LeftButton" and down == false) then
            -- Send gameboard
            local Serial = nil
            GR.SentBoard = true
            if (GR.PlayerPos == 1) then 
                Serial = GR:Serialize(GR.BattleshipsBoardP1)
            end
            if (GR.PlayerPos == 2) then 
                Serial = GR:Serialize(GR.BattleshipsBoardP2)
            end
            GR:SendCommMessage("ZUI_GameRoom_BSG", "TicTacToe_Phase1Complete, " .. Serial, "WHISPER", GR.Opponent)
            -- make ships unmovable
            Battleships.Ship1:SetMovable(false)
            Battleships.Ship1:EnableMouse(false)
            Battleships.Ship2:SetMovable(false)
            Battleships.Ship2:EnableMouse(false)
            Battleships.Ship3:SetMovable(false)
            Battleships.Ship3:EnableMouse(false)
            Battleships.Ship4:SetMovable(false)
            Battleships.Ship4:EnableMouse(false)
            Battleships.Ship5:SetMovable(false)
            Battleships.Ship5:EnableMouse(false)
            -- set currphase 
            Battleships.CurrPhase:SetText("Waiting for " .. GR.Opponent)
            GR:CheckToStartPhase2()
            Battleships.ExtraInfo:Hide()
            Battleships.Phase:Hide()
        end
    end)
    Battleships.PhaseFS = Battleships.Phase:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Battleships.PhaseFS:SetPoint("CENTER")
    Battleships.PhaseFS:SetTextColor(.8,.8,.8, 1)
    Battleships.PhaseFS:SetTextScale(1.8)
    Battleships.PhaseFS:SetText("Confirm Selection")

    -- Create line and buttons for both boards, ships
    GR:CreateBattleshipsLines(GR_GUI.Main.Battleships.Board, GR_GUI.Main.Battleships.VLines, GR_GUI.Main.Battleships.HLines)
    GR:CreateBattleshipsLines(GR_GUI.Main.Battleships.OppBoard, GR_GUI.Main.Battleships.OppVLines, GR_GUI.Main.Battleships.OppHLines)
    GR:CreateBattleshipsButtons(GR_GUI.Main.Battleships.Board, GR_GUI.Main.Battleships.Buttons, "Player")
    GR:CreateBattleshipsButtons(GR_GUI.Main.Battleships.OppBoard, GR_GUI.Main.Battleships.OppButtons, "Opponent")
    GR:CreateShips()
    GR:CreateLegend()
end

function GR:CreateBattleshipsLines(Content, VLines, HLines)
    for i = 1, 9, 1 do
        local VLine = Content:CreateLine()
        VLine:SetColorTexture(.8,.8,.8, .2)
        VLine:SetStartPoint("TOPLEFT", (Content:GetWidth() / 10) * i, 0)
        VLine:SetEndPoint("BOTTOMLEFT", (Content:GetWidth() / 10) * i, 0)
        table.insert(VLines, VLine)
    end
    for i = 1, 9, 1 do
        local HLine = Content:CreateLine()
        HLine:SetColorTexture(.8,.8,.8, .2)
        HLine:SetStartPoint("TOPLEFT", 0, (Content:GetHeight() / 10) * -i)
        HLine:SetEndPoint("TOPRIGHT", 0, (Content:GetHeight() / 10) * -i)
        table.insert(HLines, HLine)
    end
end

function GR:CreateBattleshipsButtons(Content, Buttons, User)
    for i=1, 100, 1 do
        local function xPos() 
            if (i % 10 == 1) then 
                return 1 
            elseif (i % 10 == 2) then 
                return ((Content:GetWidth() / 10) * 1) + 1
            elseif (i % 10 == 3) then 
                return ((Content:GetWidth() / 10) * 2) + 1 
            elseif (i % 10 == 4) then 
                return ((Content:GetWidth() / 10) * 3) + 1 
            elseif (i % 10 == 5) then 
                return ((Content:GetWidth() / 10) * 4) + 1 
            elseif (i % 10 == 6) then 
                return ((Content:GetWidth() / 10) * 5) + 1 
            elseif (i % 10 == 7) then 
                return ((Content:GetWidth() / 10) * 6) + 1 
            elseif (i % 10 == 8) then 
                return ((Content:GetWidth() / 10) * 7) + 1 
            elseif (i % 10 == 9) then 
                return ((Content:GetWidth() / 10) * 8) + 1 
            else  
                return ((Content:GetWidth() / 10) * 9) + 1 
            end 
        end
        local function yPos() 
            if i > 90 then 
                return ((Content:GetHeight() / 10) * -9) - 1
            elseif i > 80 then 
                return ((Content:GetHeight() / 10) * -8) - 1
            elseif i > 70 then 
                return ((Content:GetHeight() / 10) * -7) - 1
            elseif i > 60 then 
                return ((Content:GetHeight() / 10) * -6) - 1
            elseif i > 50 then 
                return ((Content:GetHeight() / 10) * -5) - 1
            elseif i > 40 then 
                return ((Content:GetHeight() / 10) * -4) - 1
            elseif i > 30 then 
                return ((Content:GetHeight() / 10) * -3) - 1
            elseif i > 20 then 
                return ((Content:GetHeight() / 10) * -2) - 1
            elseif i > 10 then 
                return ((Content:GetHeight() / 10) * -1) - 1
            else 
                return -1
            end 
        end

        local Btn = CreateFrame("Button", nil, Content)
        Btn:SetPoint("TOPLEFT", xPos(), yPos())
        Btn:SetSize(Content:GetWidth() / 10, Content:GetHeight() / 10)
        -- if opponent board, give btns functionality
        if (User == "Opponent") then
            Btn:SetScript("OnClick", function(self, button, down) 
                local Tex, LastHitTex = Btn:GetRegions()
                if (button == "LeftButton" and down == false and GR.IsPlayerTurn and Tex:IsVisible() == false) then
                    
                    -- check which board is player. 
                    local Board = nil
                    if (GR.PlayerPos == 2) then
                        Board = GR.BattleshipsBoardP1
                    end
                    if (GR.PlayerPos == 1) then
                        Board = GR.BattleshipsBoardP2
                    end
                    
                    -- if player hit (2,4,6,8,10) ship
                    if (Board[i] == 2 or Board[i] == 4 or Board[i] == 6 or Board[i] == 8 or Board[i] == 10) then
                        -- Set Texture Green
                        Tex:SetColorTexture(.212,.969,.0588, 1)
                        Tex:Show()
                        -- set (3,5,7,9,11) ship hit
                        if (Board[i] == 2) then
                            Board[i] = 3
                        end
                        if (Board[i] == 4) then
                            Board[i] = 5
                        end
                        if (Board[i] == 6) then
                            Board[i] = 7
                        end
                        if (Board[i] == 8) then
                            Board[i] = 9
                        end
                        if (Board[i] == 10) then
                            Board[i] = 11
                        end
                    end
                    -- if player hit (0) nothing, 
                    if (Board[i] == 0) then
                        -- set texture Faded grey Red
                        Tex:SetColorTexture(74/255,34/255,34/255, 1)
                        Tex:Show()
                        -- set (1) no ship hit
                        Board[i] = 1
                    end
                    
                    -- send new game board to opponent
                    local Serial = GR:Serialize(Board)
                    GR:SendCommMessage("ZUI_GameRoom_BSG", "TicTacToe_Phase2_Move, " .. Serial, "WHISPER", GR.Opponent)
                    
                    -- change turn string
                    GR.IsPlayerTurn = not GR.IsPlayerTurn
                    GR:SetTurnString()
                    -- check how many spaces left and if game over
                    GR:BattleshipsCountRemainingSpaces()
                    GR:UpdateLegend()

                    -- Hide all other LastHitTex
                    for j,k in ipairs(GR_GUI.Main.Battleships.OppButtons) do
                        local x, LastHitTex2 = k:GetRegions()
                        LastHitTex2:Hide()
                    end
                    -- show last button was hit
                    LastHitTex:Show()
                end
            end)
        end
        local BtnTex = Btn:CreateTexture()
        BtnTex:SetAllPoints(Btn)
        BtnTex:SetDrawLayer("ARTWORK", 1)
        BtnTex:Hide()
        local BtnLastHit = Btn:CreateTexture()
        BtnLastHit:SetColorTexture(1,1,1, 1)
        BtnLastHit:SetPoint("TOPLEFT", Btn, "TOPLEFT", 9,-9)
        BtnLastHit:SetPoint("BOTTOMRIGHT", Btn, "BOTTOMRIGHT", -9, 9)
        BtnLastHit:SetDrawLayer("ARTWORK", 2)
        BtnLastHit:Hide()
        table.insert(Buttons, Btn)
    end
end

function GR:CreateShips()
    local Battleships = GR_GUI.Main.Battleships

    -- Ship1
    local function BuildShip1()
        Battleships.Ship1 = CreateFrame("Frame", Ship1, Battleships)
        Battleships.Ship1.Rotate = 0
        Battleships.Ship1:SetPoint("TOPRIGHT", -4, -3)
        Battleships.Ship1:SetFrameLevel(7)
        Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 3 -(8 * (Battleships:GetHeight() / 450)))
        local Ship1Tex = Battleships.Ship1:CreateTexture()
        Ship1Tex:SetAllPoints(Battleships.Ship1)
        Ship1Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship1.blp")
        Ship1Tex:SetTexCoord(0,.02, 0,.73, .5,.02, .5,.73)
        Battleships.Ship1:SetMovable(true)
        Battleships.Ship1:EnableMouse(true)
        Battleships.Ship1:RegisterForDrag("LeftButton")
        Battleships.Ship1:SetPropagateKeyboardInput(true)
        Battleships.Ship1:SetScript("OnKeyDown", function(self, key) 
            if (key == "X" and self:IsDragging()) then
                -- rotate 90deg
                if (Battleships.Ship1.Rotate == 0) then
                    -- rotate ship
                    Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 3 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 2 -(4 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship1.Rotate = 90
                     -- rotate texture
                     local Tex = Battleships.Ship1:GetRegions()
                     Tex:SetAllPoints(Battleships.Ship1)
                     Tex:SetTexCoord( .5,.02, 0,.02, .5,.73, 0,.73)
                    return
                end
                -- rotate 0deg
                if (Battleships.Ship1.Rotate == 90) then
                    -- rotate ship
                    Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 3 -(8 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship1.Rotate = 0
                    -- rotate texture
                    local Tex = Battleships.Ship1:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship1)
                    Tex:SetTexCoord(0,.02, 0,.73, .5,.02, .5,.73)
                    return
                end
            end
        end)
        Battleships.Ship1:SetScript("OnDragStart", function(self, button) 
            self:SetPropagateKeyboardInput(false)
            -- check which tiles to shade
            local function RenderTilesOnMovement() 
                if self:IsDragging() then
                    C_Timer.After(.05, function() 
                        GR:ShadeTilesOnShipMovement()
                        RenderTilesOnMovement()
                    end)
                end
            end
            RenderTilesOnMovement()
            self:StartMoving() 
            self:EnableKeyboard(true)
        end)
        Battleships.Ship1:SetScript("OnDragStop", function(self) 
            self:SetPropagateKeyboardInput(true)
            self:StopMovingOrSizing() 
            -- stick ship to top left tile. after, re-check which tiles to shade.
            GR:SetShipPosOnPlacement(self)
            GR:ShadeTilesOnShipMovement()
            self:EnableKeyboard(false)
        end)
    end
    BuildShip1()

    -- Ship2
    local function BuildShip2()
        Battleships.Ship2 = CreateFrame("Frame", Ship2, Battleships)
        Battleships.Ship2.Rotate = 0
        Battleships.Ship2:SetPoint("TOPRIGHT", -4, (Battleships.Board:GetHeight() / 10) * -3)
        Battleships.Ship2:SetFrameLevel(7)
        Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 1 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 3 -(8 * (Battleships:GetHeight() / 450)))
        local Ship2Tex = Battleships.Ship2:CreateTexture()
        Ship2Tex:SetAllPoints(Battleships.Ship2)
        Ship2Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship2.blp")
        Ship2Tex:SetTexCoord(0,0, 0,.75, .25,0, .25,.75)
        Battleships.Ship2:SetMovable(true)
        Battleships.Ship2:EnableMouse(true)
        Battleships.Ship2:RegisterForDrag("LeftButton")
        Battleships.Ship2:SetPropagateKeyboardInput(true)
        Battleships.Ship2:SetScript("OnKeyDown", function(self, key) 
            if (key == "X" and self:IsDragging()) then
                -- rotate 90deg
                if (Battleships.Ship2.Rotate == 0) then
                    -- rotate ship
                    Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 3 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 1 -(4 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship2.Rotate = 90
                    -- rotate texture
                    local Tex = Battleships.Ship2:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship2)
                    Tex:SetTexCoord( .25,0, 0,0, .25,.75, 0,.75)
                    return
                end
                -- rotate 0deg
                if (Battleships.Ship2.Rotate == 90) then
                    -- rotate ship
                    Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 1 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 3 -(8 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship2.Rotate = 0
                     -- rotate texture
                     local Tex = Battleships.Ship2:GetRegions()
                     Tex:SetAllPoints(Battleships.Ship2)
                     Tex:SetTexCoord(0,0, 0,.75, .25,0, .25,.75)
                    return
                end
            end
        end)
        Battleships.Ship2:SetScript("OnDragStart", function(self, button) 
            self:SetPropagateKeyboardInput(false)
            -- check which tiles to shade
            local function RenderTilesOnMovement() 
                if self:IsDragging() then
                    C_Timer.After(.05, function() 
                        GR:ShadeTilesOnShipMovement()
                        RenderTilesOnMovement()
                    end)
                end
            end
            RenderTilesOnMovement()
            self:StartMoving() 
            self:EnableKeyboard(true)
        end)
        Battleships.Ship2:SetScript("OnDragStop", function(self) 
            self:SetPropagateKeyboardInput(true)
            self:StopMovingOrSizing() 
            -- stick ship to top left tile. after, re-check which tiles to shade.
            GR:SetShipPosOnPlacement(self)
            GR:ShadeTilesOnShipMovement()
            self:EnableKeyboard(false)
        end)
    end
    BuildShip2()

    -- Ship3
    local function BuildShip3()
        Battleships.Ship3 = CreateFrame("Frame", Ship3, Battleships)
        Battleships.Ship3.Rotate = 0
        Battleships.Ship3:SetPoint("TOPRIGHT", (Battleships.Board:GetWidth() / 10) * -2 +10, -3)
        Battleships.Ship3:SetFrameLevel(7)
        Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 4 -(8 * (Battleships:GetHeight() / 450)))
        local Ship3Tex = Battleships.Ship3:CreateTexture()
        Ship3Tex:SetAllPoints(Battleships.Ship3)
        Ship3Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship3.blp")
        Ship3Tex:SetTexCoord(0,0, 0,1, .5,0, .5,1)
        Battleships.Ship3:SetMovable(true)
        Battleships.Ship3:EnableMouse(true)
        Battleships.Ship3:RegisterForDrag("LeftButton")
        Battleships.Ship3:SetPropagateKeyboardInput(true)
        Battleships.Ship3:SetScript("OnKeyDown", function(self, key) 
            if (key == "X" and self:IsDragging()) then
                -- rotate 90deg
                if (Battleships.Ship3.Rotate == 0) then
                    -- rotate ship
                    Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 4 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 2 -(4 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship3.Rotate = 90
                    -- rotate texture
                    local Tex = Battleships.Ship3:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship3)
                    Tex:SetTexCoord( .5,0, 0,0, .5,1, 0,1)
                    return
                end
                -- rotate 0deg
                if (Battleships.Ship3.Rotate == 90) then
                    -- rotate ship
                    Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 4 -(8 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship3.Rotate = 0
                    -- rotate texture
                    local Tex = Battleships.Ship3:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship3)
                    Tex:SetTexCoord(0,0, 0,1, .5,0, .5,1)
                    return
                end
            end
        end)
        Battleships.Ship3:SetScript("OnDragStart", function(self, button) 
            self:SetPropagateKeyboardInput(false)
            -- check which tiles to shade
            local function RenderTilesOnMovement() 
                if self:IsDragging() then
                    C_Timer.After(.05, function() 
                        GR:ShadeTilesOnShipMovement()
                        RenderTilesOnMovement()
                    end)
                end
            end
            RenderTilesOnMovement()
            self:StartMoving() 
            self:EnableKeyboard(true)
        end)
        Battleships.Ship3:SetScript("OnDragStop", function(self) 
            self:SetPropagateKeyboardInput(true)
            self:StopMovingOrSizing() 
            -- stick ship to top left tile. after, re-check which tiles to shade.
            GR:SetShipPosOnPlacement(self)
            GR:ShadeTilesOnShipMovement()
            self:EnableKeyboard(false)
        end)
    end
    BuildShip3()

    -- Ship4
    local function BuildShip4()
        Battleships.Ship4 = CreateFrame("Frame", Ship4, Battleships)
        Battleships.Ship4.Rotate = 0
        Battleships.Ship4:SetPoint("TOPRIGHT", (Battleships.Board:GetWidth() / 10) * -2 +10, (Battleships.Board:GetHeight() / 10) * -4)
        Battleships.Ship4:SetFrameLevel(7)
        Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 2 -(8 * (Battleships:GetHeight() / 450)))
        local Ship4Tex = Battleships.Ship4:CreateTexture()
        Ship4Tex:SetAllPoints(Battleships.Ship4)
        Ship4Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship4.blp")
        Ship4Tex:SetTexCoord(0,.03, 0,.47, .5,.03, .5,.47)
        Battleships.Ship4:SetMovable(true)
        Battleships.Ship4:EnableMouse(true)
        Battleships.Ship4:RegisterForDrag("LeftButton")
        Battleships.Ship4:SetPropagateKeyboardInput(true)
        Battleships.Ship4:SetScript("OnKeyDown", function(self, key) 
            if (key == "X" and self:IsDragging()) then
                -- rotate 90deg
                if (Battleships.Ship4.Rotate == 0) then
                    -- rotate ship
                    Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 2 -(4 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship4.Rotate = 90
                    -- rotate texture
                    local Tex = Battleships.Ship4:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship4)
                    Tex:SetTexCoord( .5,.03, 0,.03, .5,.47, 0,.47)
                    return
                end
                -- rotate 0deg
                if (Battleships.Ship4.Rotate == 90) then
                    -- rotate ship
                    Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 2 -(8 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship4.Rotate = 0
                    -- rotate texture
                    local Tex = Battleships.Ship4:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship4)
                    Tex:SetTexCoord(0,.03, 0,.47, .5,.03, .5,.47)
                    return
                end
            end
        end)
        Battleships.Ship4:SetScript("OnDragStart", function(self, button) 
            self:SetPropagateKeyboardInput(false)
            -- check which tiles to shade
            local function RenderTilesOnMovement() 
                if self:IsDragging() then
                    C_Timer.After(.05, function() 
                        GR:ShadeTilesOnShipMovement()
                        RenderTilesOnMovement()
                    end)
                end
            end
            RenderTilesOnMovement()
            self:StartMoving() 
            self:EnableKeyboard(true)
        end)
        Battleships.Ship4:SetScript("OnDragStop", function(self) 
            self:SetPropagateKeyboardInput(true)
            self:StopMovingOrSizing() 
            -- stick ship to top left tile. after, re-check which tiles to shade.
            GR:SetShipPosOnPlacement(self)
            GR:ShadeTilesOnShipMovement()
            self:EnableKeyboard(false)
        end)
    end
    BuildShip4()

    -- Ship5
    local function BuildShip5()
        Battleships.Ship5 = CreateFrame("Frame", Ship5, Battleships)
        Battleships.Ship5.Rotate = 0
        Battleships.Ship5:SetPoint("TOPRIGHT", -4, (Battleships.Board:GetHeight() / 10) * -6)
        Battleships.Ship5:SetFrameLevel(7)
        Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 1 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 4 -(8 * (Battleships:GetHeight() / 450)))
        local Ship5Tex = Battleships.Ship5:CreateTexture()
        Ship5Tex:SetAllPoints(Battleships.Ship5)
        Ship5Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship5.blp")
        Ship5Tex:SetTexCoord(.14,0, .14,1, .36,0, .36,1)
        Battleships.Ship5:SetMovable(true)
        Battleships.Ship5:EnableMouse(true)
        Battleships.Ship5:RegisterForDrag("LeftButton")
        Battleships.Ship5:SetPropagateKeyboardInput(true)
        Battleships.Ship5:SetScript("OnKeyDown", function(self, key) 
            if (key == "X" and self:IsDragging()) then
                -- Rotate 90deg
                if (Battleships.Ship5.Rotate == 0) then
                    -- rotate ship
                    Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 4 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 1 -(4 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship5.Rotate = 90
                    -- rotate texture
                    local Tex = Battleships.Ship5:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship5)
                    Tex:SetTexCoord( .36,0, .14,0, .36,1, .14,1)
                    
                    return
                end
                -- Rotate 0deg
                if (Battleships.Ship5.Rotate == 90) then
                    -- rotate ship
                    Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 1 -(18 * (Battleships:GetWidth() / 770)), (Battleships.Board:GetHeight() / 10) * 4 -(8 * (Battleships:GetHeight() / 450)))
                    Battleships.Ship5.Rotate = 0
                    -- rotate Texture
                    local Tex = Battleships.Ship5:GetRegions()
                    Tex:SetAllPoints(Battleships.Ship5)
                    Tex:SetTexCoord(.14,0, .14,1, .36,0, .36,1)
                    -- Tex:ClearAllPoints()
                    -- Tex:SetAllPoints(Battleships.Ship5)
                    return
                end
            end
        end)
        Battleships.Ship5:SetScript("OnDragStart", function(self, button) 
            self:SetPropagateKeyboardInput(false)
            -- check which tiles to shade
            local function RenderTilesOnMovement() 
                if self:IsDragging() then
                    C_Timer.After(.05, function() 
                        GR:ShadeTilesOnShipMovement()
                        RenderTilesOnMovement()
                    end)
                end
            end
            RenderTilesOnMovement()
            self:StartMoving() 
            self:EnableKeyboard(true)
        end)
        Battleships.Ship5:SetScript("OnDragStop", function(self) 
            self:SetPropagateKeyboardInput(true)
            self:StopMovingOrSizing() 
            -- stick ship to top left tile. after, re-check which tiles to shade.
            GR:SetShipPosOnPlacement(self)
            GR:ShadeTilesOnShipMovement()
            self:EnableKeyboard(false)
        end)
    end
    BuildShip5()
end

function GR:CreateLegend()
    local Battleships = GR_GUI.Main.Battleships

    Battleships.Legend = CreateFrame("Frame", Legend, Battleships, "TranslucentFrameTemplate")
    local Legend = Battleships.Legend
    Legend:SetPoint("TOPRIGHT", 200, 0)
    Legend:SetSize(200, 200)
    -- Legend.Exit = CreateFrame("Button", Exit, Legend)
    -- local Exit = Legend.Exit
    -- Exit:SetPoint("TOPRIGHT", -13, -13)
    -- Exit:SetSize(25,25)
    -- Exit.Tex = Exit:CreateTexture()
    -- Exit.Tex:SetAllPoints(Exit)
    -- Exit.Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
    -- Exit.Tex:SetTexCoord(0, 1, 0, 1)
    -- Exit.Tint = Exit:CreateTexture()
    -- Exit.Tint:SetPoint("TOPLEFT", Exit, "TOPLEFT", 2, -2)
    -- Exit.Tint:SetPoint("BOTTOMRIGHT", Exit, "BOTTOMRIGHT", -2, 2)
    -- Exit.Tint:SetColorTexture(0,0,0,0);
    -- Exit:SetScript("OnClick", function(self, button, down) 
    --     if(button == "LeftButton" and down == true) then Exit.Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButtonDown.blp") end
    --     if(button == "LeftButton" and down == false) then 
    --         Legend:Hide()
    --     end
    -- end)
    -- Exit:SetScript("OnEnter", function(self, motion)
    --     Exit.Tint:SetColorTexture(0,0,0,.3);
    -- end)
    -- Exit:SetScript("OnLeave", function(self, motion)
    --     Exit.Tint:SetColorTexture(0,0,0,0);
    --     Exit.Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
    -- end)

    -- Player Text
    Legend.PlayerString = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerString:SetTextScale(1.3)
    Legend.PlayerString:SetTextColor(.8,.8,.8, 1)
    Legend.PlayerShip1 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerShip1:SetTextScale(1.3)
    Legend.PlayerShip1:SetTextColor(.8,.8,.8, 1)
    Legend.PlayerShip2 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerShip2:SetTextScale(1.3)
    Legend.PlayerShip2:SetTextColor(.8,.8,.8, 1)
    Legend.PlayerShip3 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerShip3:SetTextScale(1.3)
    Legend.PlayerShip3:SetTextColor(.8,.8,.8, 1)
    Legend.PlayerShip4 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerShip4:SetTextScale(1.3)
    Legend.PlayerShip4:SetTextColor(.8,.8,.8, 1)
    Legend.PlayerShip5 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.PlayerShip5:SetTextScale(1.3)
    Legend.PlayerShip5:SetTextColor(.8,.8,.8, 1)
    -- Opponent Text
    Legend.OppString = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppString:SetTextScale(1.3)
    Legend.OppString:SetTextColor(.8,.8,.8, 1)
    Legend.OppShip1 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppShip1:SetTextScale(1.3)
    Legend.OppShip1:SetTextColor(.8,.8,.8, 1)
    Legend.OppShip2 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppShip2:SetTextScale(1.3)
    Legend.OppShip2:SetTextColor(.8,.8,.8, 1)
    Legend.OppShip3 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppShip3:SetTextScale(1.3)
    Legend.OppShip3:SetTextColor(.8,.8,.8, 1)
    Legend.OppShip4 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppShip4:SetTextScale(1.3)
    Legend.OppShip4:SetTextColor(.8,.8,.8, 1)
    Legend.OppShip5 = Legend:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    Legend.OppShip5:SetTextScale(1.3)
    Legend.OppShip5:SetTextColor(.8,.8,.8, 1)

    -- Player Textures
    Legend.PlayerShip1Tex = Legend:CreateTexture()
    Legend.PlayerShip1Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship1.blp")
    Legend.PlayerShip1Tex:SetTexCoord(0,.73, .5,.73, 0,.02, .5,.02)
    Legend.PlayerShip2Tex = Legend:CreateTexture()
    Legend.PlayerShip2Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship2.blp")
    Legend.PlayerShip2Tex:SetTexCoord(0,.75, .25,.75, 0,0, .25,0)
    Legend.PlayerShip3Tex = Legend:CreateTexture()
    Legend.PlayerShip3Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship3.blp")
    Legend.PlayerShip3Tex:SetTexCoord(0,1, .5,1, 0,0, .5,0)
    Legend.PlayerShip4Tex = Legend:CreateTexture()
    Legend.PlayerShip4Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship4.blp")
    Legend.PlayerShip4Tex:SetTexCoord(0,.47, .5,.47, 0,.03, .5,.03)
    Legend.PlayerShip5Tex = Legend:CreateTexture()
    Legend.PlayerShip5Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship5.blp")
    Legend.PlayerShip5Tex:SetTexCoord(.14,1, .36,1, .14,0, .36,0)
    -- Opponent Textures
    Legend.OppShip1Tex = Legend:CreateTexture()
    Legend.OppShip1Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship1.blp")
    Legend.OppShip1Tex:SetTexCoord(0,.73, .5,.73, 0,.02, .5,.02)
    Legend.OppShip2Tex = Legend:CreateTexture()
    Legend.OppShip2Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship2.blp")
    Legend.OppShip2Tex:SetTexCoord(0,.75, .25,.75, 0,0, .25,0)
    Legend.OppShip3Tex = Legend:CreateTexture()
    Legend.OppShip3Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship3.blp")
    Legend.OppShip3Tex:SetTexCoord(0,1, .5,1, 0,0, .5,0)
    Legend.OppShip4Tex = Legend:CreateTexture()
    Legend.OppShip4Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship4.blp")
    Legend.OppShip4Tex:SetTexCoord(0,.47, .5,.47, 0,.03, .5,.03)
    Legend.OppShip5Tex = Legend:CreateTexture()
    Legend.OppShip5Tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\Battleship5.blp")
    Legend.OppShip5Tex:SetTexCoord(.14,1, .36,1, .14,0, .36,0)

    Legend:Hide()
end 

-- redraw
function GR:ResizeBattleships()
    local Battleships = GR_GUI.Main.Battleships
    local Board = GR_GUI.Main.Battleships.Board
    local VLines = GR_GUI.Main.Battleships.VLines
    local HLines = GR_GUI.Main.Battleships.HLines
    local Buttons = GR_GUI.Main.Battleships.Buttons
    local OppBoard = GR_GUI.Main.Battleships.OppBoard
    local OppVLines = GR_GUI.Main.Battleships.OppVLines
    local OppHLines = GR_GUI.Main.Battleships.OppHLines
    local OppButtons = GR_GUI.Main.Battleships.OppButtons
    
    --Battleships:ClearAllPoints()
    local heightBuffer =  (65 * (300 / GR_GUI.Main:GetHeight()))
    Battleships:SetSize(GR_GUI.Main:GetWidth() * (770 / 800), GR_GUI.Main:GetHeight() * (450 / 640))
    Battleships:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / 640))
    local WidthRatio = Battleships:GetWidth() / 770
    local HeightRatio = Battleships:GetHeight() / 450

    -- resize Game Window
    if (GR.Phase == 1) then
        Board:SetSize(Battleships:GetWidth() * (570 / 770), Battleships:GetHeight() * (450 / 450))
    end 
    if (GR.Phase == 2) then
        Board:SetSize(Battleships:GetWidth() * (380 / 770), Battleships:GetHeight() * (420 / 450))
    end
    OppBoard:SetSize(Battleships:GetWidth() * (380 / 770), Battleships:GetHeight() * (420 / 450))
    -- resize lines and buttons
    GR:RedrawBattleshipLinesAndButtons(Board, VLines, HLines, Buttons, Board:GetWidth(), Board:GetHeight())
    GR:RedrawBattleshipLinesAndButtons(OppBoard, OppVLines, OppHLines, OppButtons, OppBoard:GetWidth(), OppBoard:GetHeight())
    -- resize Ships, Legend
    GR:ResizeShips(Board)
    GR:ResizeLegend()

    -- resize FontStrings
    local FontScale = ((WidthRatio + HeightRatio) / 2)
    Battleships.Board.FS:SetTextScale(FontScale * 1.3)
    Battleships.Board.FS:SetPoint("TOP", 0, 22 * HeightRatio)
    Battleships.OppBoard.FS:SetTextScale(FontScale * 1.3)
    Battleships.OppBoard.FS:SetPoint("TOP", 0, 22 * HeightRatio)
    
    Battleships.CurrPhase:SetPoint("TOP", 0, 51 * HeightRatio)
    Battleships.CurrPhase:SetTextScale(FontScale * 1.6)
    Battleships.ExtraInfo:SetPoint("TOP", 0, 22 * HeightRatio)
    Battleships.ExtraInfo:SetTextScale(FontScale * 1.6)

    -- resize Phase Button
    Battleships.Phase:SetPoint("TOPLEFT", 20 * WidthRatio, 60 * HeightRatio)
    Battleships.Phase:SetSize(230 * WidthRatio, 58 * HeightRatio)
    Battleships.PhaseFS:SetTextScale(FontScale * 1.8)
    -- resize ShowLegend Button
    Battleships.ShowLegend:SetPoint("TOPRIGHT", -20 * WidthRatio, 60 * HeightRatio)
    Battleships.ShowLegend:SetSize(230 * WidthRatio, 58 * HeightRatio)
    Battleships.ShowLegendFS:SetTextScale(FontScale * 1.8)
end

function GR:RedrawBattleshipLinesAndButtons(Content, VLines, HLines, Buttons, x, y)
    Content:SetSize(x, y)

    -- set buttons
    for i,v in ipairs(Buttons) do
        local function xPos() 
            if (i % 10 == 1) then 
                return 1 
            elseif (i % 10 == 2) then 
                return ((Content:GetWidth() / 10) * 1) + 1
            elseif (i % 10 == 3) then 
                return ((Content:GetWidth() / 10) * 2) + 1 
            elseif (i % 10 == 4) then 
                return ((Content:GetWidth() / 10) * 3) + 1 
            elseif (i % 10 == 5) then 
                return ((Content:GetWidth() / 10) * 4) + 1 
            elseif (i % 10 == 6) then 
                return ((Content:GetWidth() / 10) * 5) + 1 
            elseif (i % 10 == 7) then 
                return ((Content:GetWidth() / 10) * 6) + 1 
            elseif (i % 10 == 8) then 
                return ((Content:GetWidth() / 10) * 7) + 1 
            elseif (i % 10 == 9) then 
                return ((Content:GetWidth() / 10) * 8) + 1 
            else  
                return ((Content:GetWidth() / 10) * 9) + 1 
            end 
        end
        local function yPos() 
            if i > 90 then 
                return ((Content:GetHeight() / 10) * -9) - 1
            elseif i > 80 then 
                return ((Content:GetHeight() / 10) * -8) - 1
            elseif i > 70 then 
                return ((Content:GetHeight() / 10) * -7) - 1
            elseif i > 60 then 
                return ((Content:GetHeight() / 10) * -6) - 1
            elseif i > 50 then 
                return ((Content:GetHeight() / 10) * -5) - 1
            elseif i > 40 then 
                return ((Content:GetHeight() / 10) * -4) - 1
            elseif i > 30 then 
                return ((Content:GetHeight() / 10) * -3) - 1
            elseif i > 20 then 
                return ((Content:GetHeight() / 10) * -2) - 1
            elseif i > 10 then 
                return ((Content:GetHeight() / 10) * -1) - 1
            else 
                return -1
            end 
        end

        v:ClearAllPoints()
        v:SetPoint("TOPLEFT", xPos(), yPos())
        v:SetSize(Content:GetWidth() / 10, Content:GetHeight() / 10)
    end

    -- set Lines
    for i,v in ipairs(VLines) do
        v:ClearAllPoints()
        v:SetStartPoint("TOPLEFT", (Content:GetWidth() / 10) * i, 0)
        v:SetEndPoint("BOTTOMLEFT", (Content:GetWidth() / 10) * i, 0)
    end
    for i,v in ipairs(HLines) do
        v:ClearAllPoints()
        v:SetStartPoint("TOPLEFT", 0, (Content:GetHeight() / 10) * -i)
        v:SetEndPoint("TOPRIGHT", 0, (Content:GetHeight() / 10) * -i)
    end
end

function GR:ResizeShips(Board)
    local Battleships = GR_GUI.Main.Battleships
    local Ship1 = GR_GUI.Main.Battleships.Ship1
    local Ship2 = GR_GUI.Main.Battleships.Ship2
    local Ship3 = GR_GUI.Main.Battleships.Ship3
    local Ship4 = GR_GUI.Main.Battleships.Ship4
    local Ship5 = GR_GUI.Main.Battleships.Ship5
    local BoardWidth = Board:GetWidth()
    local BoardHeight = Board:GetHeight()
    local BSWidthRatio = (Battleships:GetWidth() / 770)
    local BSHeightRatio = (Battleships:GetHeight() / 450)

    Ship1:ClearAllPoints()
    Ship1:SetParent(Battleships)
    Ship1:SetPoint("TOPRIGHT", -4, -3)
    Ship1:SetSize((BoardWidth / 10) * 2 -(18 * BSWidthRatio), (BoardHeight / 10) * 3 -(8 * BSHeightRatio))
    local Tex1 = Ship1:GetRegions()
    Tex1:SetTexCoord(0,.02, 0,.73, .5,.02, .5,.73)
    Ship2:ClearAllPoints()
    Ship2:SetParent(Battleships)
    Ship2:SetPoint("TOPRIGHT", -4, (BoardHeight / 10) * -3)
    Ship2:SetSize((BoardWidth / 10) * 1 -(18 * BSWidthRatio), (BoardHeight / 10) * 3 -(8 * BSHeightRatio))
    local Tex2 = Ship2:GetRegions()
    Tex2:SetTexCoord(0,0, 0,.75, .25,0, .25,.75)
    Ship3:ClearAllPoints()
    Ship3:SetParent(Battleships)
    Ship3:SetPoint("TOPRIGHT", (BoardWidth / 10) * -2 +10, -3)
    Ship3:SetSize((BoardWidth / 10) * 2 -(18 * BSWidthRatio), (BoardHeight / 10) * 4 -(8 * BSHeightRatio))
    local Tex3 = Ship3:GetRegions()
    Tex3:SetTexCoord(0,0, 0,1, .5,0, .5,1)
    Ship4:ClearAllPoints()
    Ship4:SetParent(Battleships)
    Ship4:SetPoint("TOPRIGHT", (BoardWidth / 10) * -2 +10, (BoardHeight / 10) * -4)
    Ship4:SetSize((BoardWidth / 10) * 2 -(18 * BSWidthRatio), (BoardHeight / 10) * 2 -(8 * BSHeightRatio))
    local Tex4 = Ship4:GetRegions()
    Tex4:SetTexCoord(0,.03, 0,.47, .5,.03, .5,.47)
    Ship5:ClearAllPoints()
    Ship5:SetParent(Battleships)
    Ship5:SetPoint("TOPRIGHT", -4, (BoardHeight / 10) * -6)
    Ship5:SetSize((BoardWidth / 10) * 1 -(18 * BSWidthRatio), (BoardHeight / 10) * 4 -(8 * BSHeightRatio))
    local Tex5 = Ship5:GetRegions()
    Tex5:SetTexCoord(.14,0, .14,1, .36,0, .36,1)
end

function GR:ResizeLegend()
    local Battleships = GR_GUI.Main.Battleships
    local Legend = GR_GUI.Main.Battleships.Legend
    
    Legend:SetSize(Battleships:GetWidth() * .26, Battleships:GetHeight() * .7)
    Legend:SetPoint("TOPRIGHT", Legend:GetWidth(), 0)
    local FontScale = (((Battleships:GetWidth() / 770) + (Battleships:GetHeight() / 450)) / 2)
    
    Legend.PlayerString:SetPoint("TOP", 0, Legend:GetHeight() * -((0 / 12) + (.05 * (10 / 12))))
    Legend.PlayerString:SetTextScale(FontScale * 1.3)
    Legend.PlayerShip1:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((1 / 12) + (.05 * (8 / 12))))
    Legend.PlayerShip1:SetTextScale(FontScale)
    Legend.PlayerShip2:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((2 / 12) + (.05 * (6 / 12))))
    Legend.PlayerShip2:SetTextScale(FontScale)
    Legend.PlayerShip3:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((3 / 12) + (.05 * (4 / 12))))
    Legend.PlayerShip3:SetTextScale(FontScale)
    Legend.PlayerShip4:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((4 / 12) + (.05 * (2 / 12))))
    Legend.PlayerShip4:SetTextScale(FontScale)
    Legend.PlayerShip5:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((5 / 12) + (.05 * (0 / 12))))
    Legend.PlayerShip5:SetTextScale(FontScale)
    Legend.PlayerShip1Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .19, Legend:GetHeight() * -((1 / 12) + (.05 * (8 / 12))))
    Legend.PlayerShip1Tex:SetSize(Legend:GetWidth() *.4, Legend:GetHeight() * .07)
    Legend.PlayerShip2Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .21, Legend:GetHeight() * -((1.8 / 12) + (.05 * (6 / 12))))
    Legend.PlayerShip2Tex:SetSize(Legend:GetWidth() *.4, Legend:GetHeight() * .07)
    Legend.PlayerShip3Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .11, Legend:GetHeight() * -((2.7 / 12) + (.05 * (4 / 12))))
    Legend.PlayerShip3Tex:SetSize(Legend:GetWidth() *.5, Legend:GetHeight() * .1)
    Legend.PlayerShip4Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .44, Legend:GetHeight() * -((4 / 12) + (.05 * (2 / 12))))
    Legend.PlayerShip4Tex:SetSize(Legend:GetWidth() *.15, Legend:GetHeight() * .07)
    Legend.PlayerShip5Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .11, Legend:GetHeight() * -((5 / 12) + (.05 * (0 / 12))))
    Legend.PlayerShip5Tex:SetSize(Legend:GetWidth() *.5, Legend:GetHeight() * .06)
    
    Legend.OppString:SetPoint("TOP", 0, Legend:GetHeight() * -((6 / 12) + (.05 * (-2 / 12))))
    Legend.OppString:SetTextScale(FontScale)
    Legend.OppShip1:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((7 / 12) + (.05 * (-4 / 12))))
    Legend.OppShip1:SetTextScale(FontScale)
    Legend.OppShip2:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((8 / 12) + (.05 * (-6 / 12))))
    Legend.OppShip2:SetTextScale(FontScale)
    Legend.OppShip3:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((9 / 12) + (.05 * (-8 / 12))))
    Legend.OppShip3:SetTextScale(FontScale)
    Legend.OppShip4:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((10 / 12) + (.05 * (-10 / 12))))
    Legend.OppShip4:SetTextScale(FontScale)
    Legend.OppShip5:SetPoint("TOPRIGHT", Legend:GetWidth() * -.1, Legend:GetHeight() * -((11 / 12) + (.05 * (-12 / 12))))
    Legend.OppShip5:SetTextScale(FontScale)
    Legend.OppShip1Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .19, Legend:GetHeight() * -((7 / 12) + (.05 * (-4 / 12))))
    Legend.OppShip1Tex:SetSize(Legend:GetWidth() *.4, Legend:GetHeight() * .07)
    Legend.OppShip2Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .21, Legend:GetHeight() * -((7.8 / 12) + (.05 * (-6 / 12))))
    Legend.OppShip2Tex:SetSize(Legend:GetWidth() *.4, Legend:GetHeight() * .07)
    Legend.OppShip3Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .11, Legend:GetHeight() * -((8.7 / 12) + (.05 * (-8 / 12))))
    Legend.OppShip3Tex:SetSize(Legend:GetWidth() *.5, Legend:GetHeight() * .1)
    Legend.OppShip4Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .44, Legend:GetHeight() * -((10 / 12) + (.05 * (-10 / 12))))
    Legend.OppShip4Tex:SetSize(Legend:GetWidth() *.15, Legend:GetHeight() * .07)
    Legend.OppShip5Tex:SetPoint("TOPLEFT",  Legend:GetWidth() * .11, Legend:GetHeight() * -((11 / 12) + (.05 * (-12 / 12))))
    Legend.OppShip5Tex:SetSize(Legend:GetWidth() *.5, Legend:GetHeight() * .06)
end

-- phase 1 functionality
function GR:SetShipPosOnPlacement(Ship)
    local ShipX, ShipY, ShipWidth, ShipHeight = Ship:GetRect()
    local BoardX, BoardY, BoardWidth, BoardHeight = GR_GUI.Main.Battleships:GetRect()
    local Buttons = GR_GUI.Main.Battleships.Buttons
    -- out of bounds check
    if (ShipX + ShipWidth > BoardX + BoardWidth or ShipX < BoardX or ShipY + ShipHeight > BoardY + BoardHeight or ShipY < BoardY) then
        Ship:ClearAllPoints()
        Ship:SetPoint("TOPRIGHT", GR_GUI.Main.Battleships)
    end
    ShipCords = {
        tl = {
            x = ShipX,
            y = ShipHeight + ShipY,
        },
        br = {
            x = ShipWidth + ShipX,
            y = ShipY,
        }
    }
    -- check if rect overlaps with buttons
    local FirstTile = true
    for i,v in ipairs(Buttons) do
        BtnX, BtnY, BtnWidth, BtnHeight = v:GetRect()
        BtnCords = {
            tl = {
                x = BtnX,
                y = BtnHeight + BtnY,
            },
            br = {
                x = BtnWidth + BtnX,
                y = BtnY,
            }
        }
        local Overlapping = GR:AABB(ShipCords, BtnCords)
        if Overlapping then
            if FirstTile then
                FirstTile = false
                Ship:ClearAllPoints()
                Ship:SetParent(v)
                if (Ship.Rotate == 0) then
                    Ship:SetPoint("TOPLEFT", 8 * (GR_GUI.Main.Battleships:GetWidth() / 770), -3 * (GR_GUI.Main.Battleships:GetHeight() / 450))
                end
                if (Ship.Rotate == 90) then
                    Ship:SetPoint("TOPLEFT", 8 * (GR_GUI.Main.Battleships:GetWidth() / 770), -1 * (GR_GUI.Main.Battleships:GetHeight() / 450))
                end
            end
        end
    end
end

function GR:ShadeTilesOnShipMovement()
    local Buttons = GR_GUI.Main.Battleships.Buttons
    local Battleships = GR_GUI.Main.Battleships
    -- ship cords give topleft bottomright, rather than working with given bottomleft topright.
    local ShipX, ShipY, ShipWidth, ShipHeight = GR_GUI.Main.Battleships.Ship1:GetRect()
    local Ship1Cords = {
        tl = {
            x = ShipX,
            y = ShipHeight + ShipY,
        },
        br = {
            x = ShipWidth + ShipX,
            y = ShipY,
        }
    }
    local Ship2X, Ship2Y, Ship2Width, Ship2Height = GR_GUI.Main.Battleships.Ship2:GetRect()
    local Ship2Cords = {
        tl = {
            x = Ship2X,
            y = Ship2Height + Ship2Y,
        },
        br = {
            x = Ship2Width + Ship2X,
            y = Ship2Y,
        }
    }
    local Ship3X, Ship3Y, Ship3Width, Ship3Height = GR_GUI.Main.Battleships.Ship3:GetRect()
    local Ship3Cords = {
        tl = {
            x = Ship3X,
            y = Ship3Height + Ship3Y,
        },
        br = {
            x = Ship3Width + Ship3X,
            y = Ship3Y,
        }
    }
    local Ship4X, Ship4Y, Ship4Width, Ship4Height = GR_GUI.Main.Battleships.Ship4:GetRect()
    local Ship4Cords = {
        tl = {
            x = Ship4X,
            y = Ship4Height + Ship4Y,
        },
        br = {
            x = Ship4Width + Ship4X,
            y = Ship4Y,
        }
    }
    local Ship5X, Ship5Y, Ship5Width, Ship5Height = GR_GUI.Main.Battleships.Ship5:GetRect()
    local Ship5Cords = {
        tl = {
            x = Ship5X,
            y = Ship5Height + Ship5Y,
        },
        br = {
            x = Ship5Width + Ship5X,
            y = Ship5Y,
        }
    }
    -- check if rect overlaps with buttons
    local TotalHighlightedBtns = 0
    for i,v in ipairs(Buttons) do
        BtnX, BtnY, BtnWidth, BtnHeight = v:GetRect()
        BtnCords = {
            tl = {
                x = BtnX,
                y = BtnHeight + BtnY,
            },
            br = {
                x = BtnWidth + BtnX,
                y = BtnY,
            }
        }
        -- 0 no ship
        -- 1 tile hit, no ship
        -- 2 ship1 place
        -- 3 ship1 hit
        -- 4 ship2 place
        -- 5 ship2 hit
        -- 6 ship3 place
        -- 7 ship3 hit
        -- 8 ship4 place
        -- 9 ship4 hit
        -- 10 ship5 place
        -- 11 ship5 hit
        
        local IsOverlapping1 = GR:AABB(Ship1Cords, BtnCords)
        local IsOverlapping2 = GR:AABB(Ship2Cords, BtnCords)
        local IsOverlapping3 = GR:AABB(Ship3Cords, BtnCords)
        local IsOverlapping4 = GR:AABB(Ship4Cords, BtnCords)
        local IsOverlapping5 = GR:AABB(Ship5Cords, BtnCords)
        local tex = v:GetRegions()
           
        -- find which board is players
        local BoardData = nil
        if (GR.PlayerPos == 1) then
            BoardData = GR.BattleshipsBoardP1
        end
        if (GR.PlayerPos == 2) then
            BoardData = GR.BattleshipsBoardP2
        end
        
        -- if overlapping set board data
        if (IsOverlapping1) then
            BoardData[i] = 2
        end
        if (IsOverlapping2) then
            BoardData[i] = 4
        end
        if (IsOverlapping3) then
            BoardData[i] = 6
        end
        if (IsOverlapping4) then
            BoardData[i] = 8
        end
        if (IsOverlapping5) then
            BoardData[i] = 10
        end
        -- if ship isnt overlapping btn, hide btn tex, set board (0) no ship
        if (IsOverlapping1 == false and IsOverlapping2 == false and IsOverlapping3 == false and IsOverlapping4 == false and IsOverlapping5 == false) then
            BoardData[i] = 0
            tex:Hide()
        else -- if ship is overlapping btn, show texture
            tex:SetColorTexture(.7,.4,0, .4)
            tex:Show()
            TotalHighlightedBtns = TotalHighlightedBtns + 1
        end
    end
    -- Check if board is set, show confirm selection button
    if (TotalHighlightedBtns > 24 and Battleships.Ship1:IsDragging() == false and Battleships.Ship2:IsDragging() == false and Battleships.Ship3:IsDragging() == false and Battleships.Ship4:IsDragging() == false and Battleships.Ship5:IsDragging() == false ) then
        GR_GUI.Main.Battleships.Phase:Show()
    else 
        GR_GUI.Main.Battleships.Phase:Hide()
    end
end

function GR:CheckToStartPhase2()
    if (GR.HasOpponentBoard and GR.SentBoard) then
        GR.Phase = 2
        local Battleships = GR_GUI.Main.Battleships
        Battleships.CurrPhase:Hide()
        Battleships.ExtraInfo:SetText("Time to Fight!")
        Battleships.Phase:Hide()
        GR_GUI.Main.HeaderInfo.TurnString:Show()
        Battleships.OppBoard:Show()
        Battleships.ShowLegend:Show()

        
        -- hide ships
        Battleships.Ship1:Hide()
        Battleships.Ship2:Hide()
        Battleships.Ship3:Hide()
        Battleships.Ship4:Hide()
        Battleships.Ship5:Hide()
        
        -- size player board 
        Battleships.Board:SetSize(Battleships:GetWidth() * (380 / 770), Battleships:GetHeight() * (420 / 450))
        GR:RedrawBattleshipLinesAndButtons(Battleships.Board, Battleships.VLines, Battleships.HLines, Battleships.Buttons, Battleships.Board:GetWidth(), Battleships.Board:GetHeight())

        -- set boards header strings
        if (GR.PlayerPos == 1) then 
            Battleships.OppBoard.FS:SetText(GR.Opponent .. " Board - " .. GR.P2SpacesLeft)
            Battleships.Board.FS:SetText(GR.PlayerName .. " Board - " .. GR.P1SpacesLeft)
        end
        if (GR.PlayerPos == 2) then 
            Battleships.OppBoard.FS:SetText(GR.Opponent .. " Board - " .. GR.P1SpacesLeft)
            Battleships.Board.FS:SetText(GR.PlayerName .. " Board - " .. GR.P2SpacesLeft)
        end
        Battleships.Board.FS:Show()
        Battleships.OppBoard.FS:Show()
        GR:UpdateLegend()
    end
end

-- phase 2 functionality
function GR:ShowOpponentMoves(Board, OldBoard)
    local buttons = GR_GUI.Main.Battleships.Buttons
    
    for i,v in ipairs(buttons) do
        -- Check for last tile hit
        local IsLastHitBtn = false
        if (Board[i] ~= OldBoard[i] ) then 
            IsLastHitBtn = true
        end

        local Tex, TexLastHit = v:GetRegions()
        -- didn't hit ship
        if (Board[i] == 1) then
            -- ocean blue
            Tex:SetColorTexture(.149,.603,.87, 1)
            Tex:Show()
            -- if was last button hit show, else hide
            if (IsLastHitBtn) then
                TexLastHit:Show()
            else
                TexLastHit:Hide()
            end
        end
        -- hit ship
        if (Board[i] == 3 or Board[i] == 5 or Board[i] == 7 or Board[i] == 9 or Board[i] == 11) then
            -- red
            Tex:SetColorTexture(219/255,0,0, 1)
            Tex:Show()
            -- if was last button hit show, else hide
            if (IsLastHitBtn) then
                TexLastHit:Show()
            else
                TexLastHit:Hide()
            end
        end
    end
end

function GR:BattleshipsCountRemainingSpaces()
    local P1SpacesLeft = 0
    local P1Ship1 = 6
    local P1Ship2 = 3
    local P1Ship3 = 8
    local P1Ship4 = 4
    local P1Ship5 = 4
    local function CountP1ShipRemainingTiles()
        -- find remaining ship spaces for P1
        for i,v in ipairs(GR.BattleshipsBoardP1) do
            if (v == 2 or v == 4 or v == 6 or v == 8 or v == 10) then
                P1SpacesLeft = P1SpacesLeft +1
            end
            -- count spaces remaining for each ship P1
            if (v == 3) then
                P1Ship1 = P1Ship1 -1
            end
            if (v == 5) then
                P1Ship2 = P1Ship2 -1
            end
            if (v == 7) then
                P1Ship3 = P1Ship3 -1
            end
            if (v == 9) then
                P1Ship4 = P1Ship4 -1
            end
            if (v == 11) then
                P1Ship5 = P1Ship5 -1
            end
        end
        -- set GR variables
        if (P1SpacesLeft < GR.P1SpacesLeft) then
            GR.P1SpacesLeft = P1SpacesLeft
        end
        if (P1Ship1 < GR.P1Ship1) then
            GR.P1Ship1 = P1Ship1
        end
        if (P1Ship2 < GR.P1Ship2) then
            GR.P1Ship2 = P1Ship2
        end
        if (P1Ship3 < GR.P1Ship3) then
            GR.P1Ship3 = P1Ship3
        end
        if (P1Ship4 < GR.P1Ship4) then
            GR.P1Ship4 = P1Ship4
        end
        if (P1Ship5 < GR.P1Ship5) then
            GR.P1Ship5 = P1Ship5
        end
    end
    CountP1ShipRemainingTiles()

    local P2SpacesLeft = 0
    local P2Ship1 = 6
    local P2Ship2 = 3
    local P2Ship3 = 8
    local P2Ship4 = 4
    local P2Ship5 = 4
    local function CountP2ShipRemainingTiles()
        -- find remaining ship spaces for P2
        for i,v in ipairs(GR.BattleshipsBoardP2) do
            if (v == 2 or v == 4 or v == 6 or v == 8 or v == 10) then
                P2SpacesLeft = P2SpacesLeft +1
            end
            -- count spaces remaining for each ship P2
            if (v == 3) then
                P2Ship1 = P2Ship1 -1
            end
            if (v == 5) then
                P2Ship2 = P2Ship2 -1
            end
            if (v == 7) then
                P2Ship3 = P2Ship3 -1
            end
            if (v == 9) then
                P2Ship4 = P2Ship4 -1
            end
            if (v == 11) then
                P2Ship5 = P2Ship5 -1
            end
        end
        -- set GR variables
        if (P2SpacesLeft < GR.P2SpacesLeft) then
            GR.P2SpacesLeft = P2SpacesLeft
        end
        if (P2Ship1 < GR.P2Ship1) then
            GR.P2Ship1 = P2Ship1
        end
        if (P2Ship2 < GR.P2Ship2) then
            GR.P2Ship2 = P2Ship2
        end
        if (P2Ship3 < GR.P2Ship3) then
            GR.P2Ship3 = P2Ship3
        end
        if (P2Ship4 < GR.P2Ship4) then
            GR.P2Ship4 = P2Ship4
        end
        if (P2Ship5 < GR.P2Ship5) then
            GR.P2Ship5 = P2Ship5
        end
    end
    CountP2ShipRemainingTiles()

    local function CheckGameOver()
        -- if your player 1 or player 2 and your enemy clears your board, you lose. 
        if ((P1SpacesLeft == 0 and GR.PlayerPos == 1) or (P2SpacesLeft == 0 and GR.PlayerPos == 2)) then
            -- Lose
            GR_GUI.Main.HeaderInfo.TurnString:SetTextColor(1,0,0,1)
            GR_GUI.Main.HeaderInfo.TurnString:SetText("You lose")
            for i,v in ipairs(GR_GUI.Main.Battleships.OppButtons) do
                v:EnableMouse(false)
            end
            GR_GUI.Main.HeaderInfo.ReInvite:Show()
            GR_GUI.Main.HeaderInfo.OpponentString:Hide()
            GR:ShowRivalButtons()
        end
        -- if your player 1 or player 2 and you clear your enemies board, you win. 
        if ((P1SpacesLeft == 0 and GR.PlayerPos == 2) or (P2SpacesLeft == 0 and GR.PlayerPos == 1)) then
            -- Win
            GR_GUI.Main.HeaderInfo.TurnString:SetTextColor(0,1,0,1)
            GR_GUI.Main.HeaderInfo.TurnString:SetText("You Win!")
            for i,v in ipairs(GR_GUI.Main.Battleships.OppButtons) do
                v:EnableMouse(false)
            end
            -- GR_GUI.Main.HeaderInfo.ReInvite:Show()
            GR_GUI.Main.HeaderInfo.OpponentString:Hide()
            GR:ShowRivalButtons()
        end
    end
    CheckGameOver()

    -- set board header strings
    if (GR.PlayerPos == 1) then 
        GR_GUI.Main.Battleships.OppBoard.FS:SetText(GR.Opponent .. " Board - " .. GR.P2SpacesLeft)
        GR_GUI.Main.Battleships.Board.FS:SetText(GR.PlayerName .. " Board - " .. GR.P1SpacesLeft)
    end
    if (GR.PlayerPos == 2) then 
        GR_GUI.Main.Battleships.OppBoard.FS:SetText(GR.Opponent .. " Board - " .. GR.P1SpacesLeft)
        GR_GUI.Main.Battleships.Board.FS:SetText(GR.PlayerName .. " Board - " .. GR.P2SpacesLeft)
    end
end

function GR:UpdateLegend()
    local Legend = GR_GUI.Main.Battleships.Legend

    Legend.PlayerString:SetText(GR.PlayerName)
    Legend.OppString:SetText(GR.Opponent)

    if (GR.PlayerPos == 1) then
        Legend.PlayerShip1:SetText("6")
        Legend.PlayerShip2:SetText("3")
        Legend.PlayerShip3:SetText("8")
        Legend.PlayerShip4:SetText("4")
        Legend.PlayerShip5:SetText("4")
        Legend.OppShip1:SetText("6")
        Legend.OppShip2:SetText("3")
        Legend.OppShip3:SetText("8")
        Legend.OppShip4:SetText("4")
        Legend.OppShip5:SetText("4")
        -- Legend.PlayerShip1:SetText(GR.P1Ship1 .. " / 6")
        -- Legend.PlayerShip2:SetText(GR.P1Ship2 .. " / 3")
        -- Legend.PlayerShip3:SetText(GR.P1Ship3 .. " / 8")
        -- Legend.PlayerShip4:SetText(GR.P1Ship4 .. " / 4")
        -- Legend.PlayerShip5:SetText(GR.P1Ship5 .. " / 4")
        -- Legend.OppShip1:SetText(GR.P2Ship1 .. " / 6")
        -- Legend.OppShip2:SetText(GR.P2Ship2 .. " / 3")
        -- Legend.OppShip3:SetText(GR.P2Ship3 .. " / 8")
        -- Legend.OppShip4:SetText(GR.P2Ship4 .. " / 4")
        -- Legend.OppShip5:SetText(GR.P2Ship5 .. " / 4")
    end
    if (GR.PlayerPos == 2) then
        Legend.PlayerShip1:SetText("6")
        Legend.PlayerShip2:SetText("3")
        Legend.PlayerShip3:SetText("8")
        Legend.PlayerShip4:SetText("4")
        Legend.PlayerShip5:SetText("4")
        Legend.OppShip1:SetText("6")
        Legend.OppShip2:SetText("3")
        Legend.OppShip3:SetText("8")
        Legend.OppShip4:SetText("4")
        Legend.OppShip5:SetText("4")
        -- Legend.PlayerShip1:SetText(GR.P2Ship1 .. " / 6")
        -- Legend.PlayerShip2:SetText(GR.P2Ship2 .. " / 3")
        -- Legend.PlayerShip3:SetText(GR.P2Ship3 .. " / 8")
        -- Legend.PlayerShip4:SetText(GR.P2Ship4 .. " / 4")
        -- Legend.PlayerShip5:SetText(GR.P2Ship5 .. " / 4")
        -- Legend.OppShip1:SetText(GR.P1Ship1 .. " / 6")
        -- Legend.OppShip2:SetText(GR.P1Ship2 .. " / 3")
        -- Legend.OppShip3:SetText(GR.P1Ship3 .. " / 8")
        -- Legend.OppShip4:SetText(GR.P1Ship4 .. " / 4")
        -- Legend.OppShip5:SetText(GR.P1Ship5 .. " / 4")
    end
end

function GR:ShowRivalButtons()
    local Buttons = GR_GUI.Main.Battleships.OppButtons

    local Board = nil
    if (GR.PlayerPos == 1) then
        Board = GR.BattleshipsBoardP2
    end
    if (GR.PlayerPos == 2) then
        Board = GR.BattleshipsBoardP1
    end

    for i,v in ipairs(Board) do
        local Tex = Buttons[i]:GetRegions()

        if (Tex:IsVisible() == false and (v == 2 or v == 4 or v == 6 or v == 8 or v == 10)) then
            Tex:SetColorTexture(1,1,0, 1)
            Tex:Show()
        end
    end
end

-- communication
function GR:BattleshipsComm(...)
    local prefix, text, distribution, target = ...

    -- Opponent Completed Phase 1
    local Action1 = string.sub(text, 0, 24)
    local Value1 = string.sub(text, 27, 1000)
    local Passed1, DesValue1 = GR:Deserialize(Value1)
    if (string.match(Action1, "TicTacToe_Phase1Complete")) then
        GR.HasOpponentBoard = true
        if (GR.PlayerPos == 1) then
            GR.BattleshipsBoardP2 = DesValue1
        end
        if (GR.PlayerPos == 2) then
            GR.BattleshipsBoardP1 = DesValue1
        end
        GR:CheckToStartPhase2()
    end

    -- received opponent move/board
    local Action2 = string.sub(text, 0, 21)
    local Value2 = string.sub(text, 24, 1000)
    local Passed2, DesValue2 = GR:Deserialize(Value2)
    if (string.match(Action1, "TicTacToe_Phase2_Move")) then
        GR.IsPlayerTurn = true
        GR:SetTurnString()

        if (GR.PlayerPos == 1) then
            GR.BattleshipsBoardP1Old = GR.BattleshipsBoardP1
            GR.BattleshipsBoardP1 = DesValue2
            GR:ShowOpponentMoves(GR.BattleshipsBoardP1, GR.BattleshipsBoardP1Old)
        end
        if (GR.PlayerPos == 2) then
            GR.BattleshipsBoardP2Old = GR.BattleshipsBoardP2
            GR.BattleshipsBoardP2 = DesValue2
            GR:ShowOpponentMoves(GR.BattleshipsBoardP2, GR.BattleshipsBoardP2Old)
        end
        GR:BattleshipsCountRemainingSpaces()
        GR:UpdateLegend()
    end
end

-- show and hide
function GR:BattleshipsHideContent()
    GR_GUI.Main.Battleships:Hide()
    GR_GUI.Main.Battleships.Legend:Hide()
    GR.BattleshipsBoardP1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP2 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    local Buttons = GR_GUI.Main.Battleships.Buttons
    for i,v in ipairs(Buttons) do 
        local BtnTex, x = v:GetRegions()
        BtnTex:Hide()
        x:Hide()
    end
    for i,v in ipairs(GR_GUI.Main.Battleships.OppButtons) do 
        local BtnTex, x = v:GetRegions()
        BtnTex:Hide()
        x:Hide()
    end
    GR:HideGame()
end

function GR:BattleshipsShowContent()
    local Battleships = GR_GUI.Main.Battleships
    
    GR:ShowGame()
    
    GR.BattleshipsBoardP1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP2 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.Phase = 1
    GR.HasOpponentBoard = false
    GR.SentBoard = false
    GR.P1SpacesLeft = 25
    GR.P2SpacesLeft = 25
    GR.P1Ship1 = 6
    GR.P1Ship2 = 3
    GR.P1Ship3 = 8
    GR.P1Ship4 = 4
    GR.P1Ship5 = 4
    GR.P2Ship1 = 6
    GR.P2Ship2 = 3
    GR.P2Ship3 = 8
    GR.P2Ship4 = 4
    GR.P2Ship5 = 4
    GR.GameType = "Battleships"
    
    GR_GUI.Main.H2:SetText("Battleships")
    Battleships.CurrPhase:SetText("Place your Battleships")
    GR_GUI.Main.HeaderInfo.TurnString:Hide()
    GR_GUI.Main.Battleships.ShowLegend:Hide()
    GR_GUI.Main.HeaderInfo.OpponentString:Show()
    GR_GUI.Main.Battleships.Legend:Hide()
    GR_GUI.Main.HeaderInfo.TurnString:SetPoint("TOP", 0, -67 * (GR_GUI.Main:GetHeight() / 750))
    
    GR:RedrawBattleshipLinesAndButtons(Battleships.Board, Battleships.VLines, Battleships.HLines, Battleships.Buttons, 570, 450)
    for i,v in ipairs(GR_GUI.Main.Battleships.OppButtons) do
        v:EnableMouse(true)
        local Tex = v:GetRegions()
        Tex:Hide()
    end
    for i,v in ipairs(GR_GUI.Main.Battleships.Buttons) do
        local Tex = v:GetRegions()
        Tex:Hide()
    end
    
    Battleships:Show()
    Battleships.Board:Show()
    Battleships.OppBoard:Hide()
    Battleships.CurrPhase:Show()
    Battleships.ExtraInfo:Show()
    Battleships.ExtraInfo:SetText("Press X to rotate ships")
    Battleships.Board.FS:Hide()
    Battleships.OppBoard.FS:Hide()
    Battleships.Ship1:Show()
    Battleships.Ship1:SetMovable(true)
    Battleships.Ship1:EnableMouse(true)
    Battleships.Ship2:Show()
    Battleships.Ship2:SetMovable(true)
    Battleships.Ship2:EnableMouse(true)
    Battleships.Ship3:Show()
    Battleships.Ship3:SetMovable(true)
    Battleships.Ship3:EnableMouse(true)
    Battleships.Ship4:Show()
    Battleships.Ship4:SetMovable(true)
    Battleships.Ship4:EnableMouse(true)
    Battleships.Ship5:Show()
    Battleships.Ship5:SetMovable(true)
    Battleships.Ship5:EnableMouse(true)
    GR:ResizeShips(Battleships.Board)
    GR:ResizeBattleships(Battleships.Board)
end

function GR:AABB(Rect1, Rect2)
  local MarginX = 9 * (GR_GUI.Main:GetWidth() / 800)
  local MarginY = 9 * (GR_GUI.Main:GetHeight() / 640)
  if (Rect1.tl.x + MarginX > Rect2.br.x - MarginX or Rect1.tl.y - MarginY < Rect2.br.y + MarginY or Rect1.br.x - MarginX < Rect2.tl.x + MarginX or Rect1.br.y + MarginY > Rect2.tl.y - MarginY) then
      return false
  end
  return true
end

-- rematch button