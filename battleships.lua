function GR:CreateBattleships()
    GR.BattleshipsBoardP1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP2 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.Phase = 1
    GR.HasOpponentBoard = false
    GR.SentBoard = false
    
    GR_GUI.Main.Battleships = CreateFrame("Frame", Battleships, GR_GUI.Main, "ThinBorderTemplate")
    local Battleships = GR_GUI.Main.Battleships
    Battleships:SetPoint("CENTER", 0, -70)
    Battleships:SetSize(770, 450)
    Battleships:Hide()

    GR_GUI.Main.Battleships.Buttons = {}
    GR_GUI.Main.Battleships.OppButtons = {}
    GR_GUI.Main.Battleships.VLines = {}
    GR_GUI.Main.Battleships.HLines = {}
    GR_GUI.Main.Battleships.OppVLines = {}
    GR_GUI.Main.Battleships.OppHLines = {}

    Battleships.Board = CreateFrame("Frame", Board, Battleships, "ThinBorderTemplate")
    local Board = Battleships.Board
    Board:SetPoint("LEFT", 0, 0)
    Board:SetSize(570, 450)
    Board:Hide()

    Battleships.Board.FS = Battleships.Board:CreateFontString(Battleships.Board, "HIGH", "GameTooltipText")
    Battleships.Board.FS:SetPoint("TOP", 0, 30)
    Battleships.Board.FS:SetTextColor(.8,.8,.8, 1)
    Battleships.Board.FS:SetText(GR.PlayerName .. " Board")
    Battleships.Board.FS:Hide()
    
    Battleships.OppBoard = CreateFrame("Frame", OppBoard, Battleships, "ThinBorderTemplate")
    local OppBoard = Battleships.OppBoard
    OppBoard:SetPoint("BOTTOMRIGHT", 0, 0)
    OppBoard:SetSize(380, 420)
    OppBoard:Hide()

    Battleships.OppBoard.FS = Battleships.OppBoard:CreateFontString(Battleships.OppBoard, "HIGH", "GameTooltipText")
    Battleships.OppBoard.FS:SetPoint("TOP", 0, 30)
    Battleships.OppBoard.FS:SetTextColor(.8,.8,.8, 1)
    Battleships.OppBoard.FS:Hide()

    Battleships.CurrPhase = Battleships:CreateFontString(Battleships, "HIGH", "GameTooltipText")
    Battleships.CurrPhase:SetPoint("TOP", 0, 40)
    Battleships.CurrPhase:SetTextColor(.8,.8,.8, 1)
    Battleships.CurrPhase:SetText("Place your Battleships")
    
    Battleships.Phase = CreateFrame("Button", Phase, Battleships, "UIPanelButtonTemplate")
    Battleships.Phase:SetPoint("TOPLEFT", 100, 40)
    Battleships.Phase:SetSize(120, 30)
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
        end
    end)
    local PhaseFS = Battleships.Phase:CreateFontString(Battleships.Phase, "HIGH", "GameTooltipText")
    PhaseFS:SetPoint("CENTER")
    PhaseFS:SetTextColor(.8,.8,.8, 1)
    PhaseFS:SetText("Confirm Selection")

    GR:CreateBattleshipsLines(GR_GUI.Main.Battleships.Board, GR_GUI.Main.Battleships.VLines, GR_GUI.Main.Battleships.HLines)
    GR:CreateBattleshipsLines(GR_GUI.Main.Battleships.OppBoard, GR_GUI.Main.Battleships.OppVLines, GR_GUI.Main.Battleships.OppHLines)
    GR:CreateBattleshipsButtons(GR_GUI.Main.Battleships.Board, GR_GUI.Main.Battleships.Buttons)
    GR:CreateBattleshipsButtons(GR_GUI.Main.Battleships.OppBoard, GR_GUI.Main.Battleships.OppButtons)
    GR:CreateShips()
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

function GR:RedrawBattleshipLinesAndButtons()
    GR_GUI.Main.Battleships.Board:SetSize(380, 420)
    local Content = GR_GUI.Main.Battleships.Board
    local VLines = GR_GUI.Main.Battleships.VLines
    local HLines = GR_GUI.Main.Battleships.HLines
    local Buttons = GR_GUI.Main.Battleships.Buttons
 
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

function GR:CreateBattleshipsButtons(Content, Buttons)
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
        local BtnTex = Btn:CreateTexture()
        BtnTex:SetAllPoints(Btn)
        table.insert(Buttons, Btn)
    end
end

function GR:CreateShips()
    local Battleships = GR_GUI.Main.Battleships
    Battleships.Ship1 = CreateFrame("Frame", Ship1, Battleships)
    Battleships.Ship1.Rotate = 0
    Battleships.Ship1:SetPoint("TOPRIGHT", -4, -3)
    Battleships.Ship1:SetFrameLevel(7)
    Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 3 -18)
    local Ship1Tex = Battleships.Ship1:CreateTexture()
    Ship1Tex:SetAllPoints(Battleships.Ship1)
    Ship1Tex:SetColorTexture(0,.4,1, 1)
    Battleships.Ship1:SetMovable(true)
    Battleships.Ship1:EnableMouse(true)
    Battleships.Ship1:RegisterForDrag("LeftButton")
    Battleships.Ship1:SetPropagateKeyboardInput(true)
    Battleships.Ship1:SetScript("OnKeyDown", function(self, key) 
        if (key == "X" and self:IsDragging()) then
            if (Battleships.Ship1.Rotate == 0) then
                Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 3 -18, (Battleships.Board:GetHeight() / 10) * 2 -18)
                Battleships.Ship1.Rotate = 90
                return
            end
            if (Battleships.Ship1.Rotate == 90) then
                Battleships.Ship1:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 3 -18)
                Battleships.Ship1.Rotate = 0
                return
            end
        end
    end)
    Battleships.Ship1:SetScript("OnDragStart", function(self, button) 
        self:SetPropagateKeyboardInput(false)
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
        GR:SetShipPosOnPlacement(self)
        GR:ShadeTilesOnShipMovement()
        self:EnableKeyboard(false)
    end)

    -- Ship2
    Battleships.Ship2 = CreateFrame("Frame", Ship2, Battleships)
    Battleships.Ship2.Rotate = 0
    Battleships.Ship2:SetPoint("TOPRIGHT", -4, (Battleships.Board:GetHeight() / 10) * -3)
    Battleships.Ship2:SetFrameLevel(7)
    Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 1 -18, (Battleships.Board:GetHeight() / 10) * 3 -18)
    local Ship2Tex = Battleships.Ship2:CreateTexture()
    Ship2Tex:SetAllPoints(Battleships.Ship2)
    Ship2Tex:SetColorTexture(1,.4,.5, 1)
    Battleships.Ship2:SetMovable(true)
    Battleships.Ship2:EnableMouse(true)
    Battleships.Ship2:RegisterForDrag("LeftButton")
    Battleships.Ship2:SetPropagateKeyboardInput(true)
    Battleships.Ship2:SetScript("OnKeyDown", function(self, key) 
        if (key == "X" and self:IsDragging()) then
            if (Battleships.Ship2.Rotate == 0) then
                Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 3 -18, (Battleships.Board:GetHeight() / 10) * 1 -18)
                Battleships.Ship2.Rotate = 90
                return
            end
            if (Battleships.Ship2.Rotate == 90) then
                Battleships.Ship2:SetSize((Battleships.Board:GetWidth() / 10) * 1 -18, (Battleships.Board:GetHeight() / 10) * 3 -18)
                Battleships.Ship2.Rotate = 0
                return
            end
        end
    end)
    Battleships.Ship2:SetScript("OnDragStart", function(self, button) 
        self:SetPropagateKeyboardInput(false)
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
        GR:SetShipPosOnPlacement(self)
        GR:ShadeTilesOnShipMovement()
        self:EnableKeyboard(false)
    end)

    -- Ship3
    Battleships.Ship3 = CreateFrame("Frame", Ship3, Battleships)
    Battleships.Ship3.Rotate = 0
    Battleships.Ship3:SetPoint("TOPRIGHT", (Battleships.Board:GetWidth() / 10) * -2 +10, -3)
    Battleships.Ship3:SetFrameLevel(7)
    Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 4 -18)
    local Ship3Tex = Battleships.Ship3:CreateTexture()
    Ship3Tex:SetAllPoints(Battleships.Ship3)
    Ship3Tex:SetColorTexture(0,.7,1, 1)
    Battleships.Ship3:SetMovable(true)
    Battleships.Ship3:EnableMouse(true)
    Battleships.Ship3:RegisterForDrag("LeftButton")
    Battleships.Ship3:SetPropagateKeyboardInput(true)
    Battleships.Ship3:SetScript("OnKeyDown", function(self, key) 
        if (key == "X" and self:IsDragging()) then
            if (Battleships.Ship3.Rotate == 0) then
                Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 4 -18, (Battleships.Board:GetHeight() / 10) * 2 -18)
                Battleships.Ship3.Rotate = 90
                return
            end
            if (Battleships.Ship3.Rotate == 90) then
                Battleships.Ship3:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 4 -18)
                Battleships.Ship3.Rotate = 0
                return
            end
        end
    end)
    Battleships.Ship3:SetScript("OnDragStart", function(self, button) 
        self:SetPropagateKeyboardInput(false)
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
        GR:SetShipPosOnPlacement(self)
        GR:ShadeTilesOnShipMovement()
        self:EnableKeyboard(false)
    end)

    -- Ship4
    Battleships.Ship4 = CreateFrame("Frame", Ship4, Battleships)
    Battleships.Ship4.Rotate = 0
    Battleships.Ship4:SetPoint("TOPRIGHT", (Battleships.Board:GetWidth() / 10) * -2 +10, (Battleships.Board:GetHeight() / 10) * -4)
    Battleships.Ship4:SetFrameLevel(7)
    Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 2 -18)
    local Ship4Tex = Battleships.Ship4:CreateTexture()
    Ship4Tex:SetAllPoints(Battleships.Ship4)
    Ship4Tex:SetColorTexture(1,1,0, 1)
    Battleships.Ship4:SetMovable(true)
    Battleships.Ship4:EnableMouse(true)
    Battleships.Ship4:RegisterForDrag("LeftButton")
    Battleships.Ship4:SetPropagateKeyboardInput(true)
    Battleships.Ship4:SetScript("OnKeyDown", function(self, key) 
        if (key == "X" and self:IsDragging()) then
            if (Battleships.Ship4.Rotate == 0) then
                Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 2 -18)
                Battleships.Ship4.Rotate = 90
                return
            end
            if (Battleships.Ship4.Rotate == 90) then
                Battleships.Ship4:SetSize((Battleships.Board:GetWidth() / 10) * 2 -18, (Battleships.Board:GetHeight() / 10) * 2 -18)
                Battleships.Ship4.Rotate = 0
                return
            end
        end
    end)
    Battleships.Ship4:SetScript("OnDragStart", function(self, button) 
        self:SetPropagateKeyboardInput(false)
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
        GR:SetShipPosOnPlacement(self)
        GR:ShadeTilesOnShipMovement()
        self:EnableKeyboard(false)
    end)

    -- Ship5
    Battleships.Ship5 = CreateFrame("Frame", Ship5, Battleships)
    Battleships.Ship5.Rotate = 0
    Battleships.Ship5:SetPoint("TOPRIGHT", -4, (Battleships.Board:GetHeight() / 10) * -6)
    Battleships.Ship5:SetFrameLevel(7)
    Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 1 -18, (Battleships.Board:GetHeight() / 10) * 4 -18)
    local Ship5Tex = Battleships.Ship5:CreateTexture()
    Ship5Tex:SetAllPoints(Battleships.Ship5)
    Ship5Tex:SetColorTexture(0,1,.5, 1)
    Battleships.Ship5:SetMovable(true)
    Battleships.Ship5:EnableMouse(true)
    Battleships.Ship5:RegisterForDrag("LeftButton")
    Battleships.Ship5:SetPropagateKeyboardInput(true)
    Battleships.Ship5:SetScript("OnKeyDown", function(self, key) 
        if (key == "X" and self:IsDragging()) then
            if (Battleships.Ship5.Rotate == 0) then
                Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 4 -18, (Battleships.Board:GetHeight() / 10) * 1 -18)
                Battleships.Ship5.Rotate = 90
                return
            end
            if (Battleships.Ship5.Rotate == 90) then
                Battleships.Ship5:SetSize((Battleships.Board:GetWidth() / 10) * 1 -18, (Battleships.Board:GetHeight() / 10) * 4 -18)
                Battleships.Ship5.Rotate = 0
                return
            end
        end
    end)
    Battleships.Ship5:SetScript("OnDragStart", function(self, button) 
        self:SetPropagateKeyboardInput(false)
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
        GR:SetShipPosOnPlacement(self)
        GR:ShadeTilesOnShipMovement()
        self:EnableKeyboard(false)
    end)
    

end

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
                Ship:SetPoint("TOPLEFT", 8, -8)
            end
        end
    end
end

function GR:ShadeTilesOnShipMovement()
    local Buttons = GR_GUI.Main.Battleships.Buttons
    local Battleships = GR_GUI.Main.Battleships
    local ShipX, ShipY, ShipWidth, ShipHeight = GR_GUI.Main.Battleships.Ship1:GetRect()
    local ShipCords = {
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
        local Overlapping = GR:AABB(ShipCords, BtnCords)
        if (GR:AABB(Ship2Cords, BtnCords)) then
            Overlapping = true
        end
        if (GR:AABB(Ship3Cords, BtnCords)) then
            Overlapping = true
        end
        if (GR:AABB(Ship4Cords, BtnCords)) then
            Overlapping = true
        end
        if (GR:AABB(Ship5Cords, BtnCords)) then
            Overlapping = true
        end
        local tex = v:GetRegions()
        if (Overlapping) then
            TotalHighlightedBtns = TotalHighlightedBtns + 1
            if (GR.PlayerPos == 1) then
                GR.BattleshipsBoardP1[i] = 1
            end
            if (GR.PlayerPos == 2) then
                GR.BattleshipsBoardP1[i] = 1
            end
            tex:SetColorTexture(.7,.4,0, .4)
            tex:Show()
        else
            GR.BattleshipsBoardP1[i] = 0
            tex:Hide()
        end
    end
    -- Check if board is set, show confirm selection button
    if (TotalHighlightedBtns > 24 and Battleships.Ship1:IsDragging() == false and Battleships.Ship2:IsDragging() == false and Battleships.Ship3:IsDragging() == false and Battleships.Ship4:IsDragging() == false and Battleships.Ship5:IsDragging() == false ) then
        GR_GUI.Main.Battleships.Phase:Show()
    else 
        GR_GUI.Main.Battleships.Phase:Hide()
    end
end

function GR:CheckIfBoardIsSet()
 
end

function GR:AABB(Rect1, Rect2)
    local margin = 9
    if (Rect1.tl.x + margin > Rect2.br.x - margin or Rect1.tl.y - margin < Rect2.br.y + margin or Rect1.br.x - margin < Rect2.tl.x + margin or Rect1.br.y + margin > Rect2.tl.y - margin) then
        return false
    end
    return true
end

function GR:BattleshipsCheckForWin()

end

function GR:BattleshipsHideContent()
    GR_GUI.Main.Battleships:Hide()
    GR.BattleshipsBoardP1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    GR.BattleshipsBoardP2 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    local Buttons = GR_GUI.Main.Battleships.Buttons
    for i,v in ipairs(Buttons) do 
        local BtnTex = v:GetRegions()
        BtnTex:Hide()
    end
    GR:HideGame()
end

function GR:BattleshipsShowContent()
    GR_GUI.Main:SetSize(800, 640)
    GR_GUI.Main.HeaderInfo.TurnString:Hide()
    GR.Phase = 1
end

function GR:ResizeBattleships()

end

function GR:CheckToStartPhase2()
    if (GR.HasOpponentBoard and GR.SentBoard) then
        GR.Phase = 2
        local Battleships = GR_GUI.Main.Battleships
        Battleships.CurrPhase:Hide()
        Battleships.Phase:Hide()
        GR_GUI.Main.HeaderInfo.TurnString:Show()
        Battleships.OppBoard:Show()

        -- hide ships
        Battleships.Ship1:Hide()
        Battleships.Ship2:Hide()
        Battleships.Ship3:Hide()
        Battleships.Ship4:Hide()
        Battleships.Ship5:Hide()

        -- size board and show opponent board
        GR:RedrawBattleshipLinesAndButtons()
        Battleships.OppBoard.FS:SetText(GR.Opponent .. " Board")
        Battleships.Board.FS:Show()
        Battleships.OppBoard.FS:Show()
    end
end

function GR:BattleshipsComm(...)
    local prefix, text, distribution, target = ...

    local Action1 = string.sub(text, 0, 24)
    local Value1 = string.sub(text, 27, 1000)
    local Passed, DesValue1 = GR:Deserialize(Value1)
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
end

-- game pieces cant overlap