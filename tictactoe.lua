function GR:CreateTicTacToe() 
    GR.TicBoard = {0,0,0,0,0,0,0,0,0}
    
    GR_GUI.Main.Tictactoe = CreateFrame("Frame", Game, GR_GUI.Main, "ThinBorderTemplate")
    local Game = GR_GUI.Main.Tictactoe
    Game:SetPoint("CENTER", 0, -50)
    Game:SetSize(570, 450)
    -- local GameTex = Game:CreateTexture()
    -- GameTex:SetPoint("TOPLEFT", Game, "TOPLEFT", -6, 6)
    -- GameTex:SetPoint("BOTTOMRIGHT", Game, "BOTTOMRIGHT", 6, -6)
    -- GameTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\ContentOutline2.blp")
    -- local TexX = 582 / 1024
    -- local TexY = 462 / 1024
    -- GameTex:SetTexCoord(0,0, 0,TexY, TexX,0, TexX,TexY)
    Game:Hide()

    GR:CreateTicTacToeLines()
    GR:CreateTicTacToeButtons()
end

function GR:CreateTicTacToeLines()
    local Content = GR_GUI.Main.Tictactoe
    local VLine1 = Content:CreateLine()
    VLine1:SetColorTexture(.8,.8,.8, 1)
    VLine1:SetStartPoint("TOPLEFT", 190, 0)
    VLine1:SetEndPoint("BOTTOMLEFT", 190, 0)
    local VLine2 = Content:CreateLine()
    VLine2:SetColorTexture(.8,.8,.8, 1)
    VLine2:SetStartPoint("TOPLEFT", 380, 0)
    VLine2:SetEndPoint("BOTTOMLEFT", 380, 0)
    local HLine1 = Content:CreateLine()
    HLine1:SetColorTexture(.8,.8,.8, 1)
    HLine1:SetStartPoint("TOPLEFT", 0, -150)
    HLine1:SetEndPoint("TOPRIGHT", 0, -150)
    local HLine2 = Content:CreateLine()
    HLine2:SetColorTexture(.8,.8,.8, 1)
    HLine2:SetStartPoint("TOPLEFT", 0, -300)
    HLine2:SetEndPoint("TOPRIGHT", 0, -300)
end

function GR:CreateTicTacToeButtons()
    local Content = GR_GUI.Main.Tictactoe
    GR_GUI.Main.Tictactoe.Buttons = {}
    local Buttons = GR_GUI.Main.Tictactoe.Buttons

    for i=1, 9, 1 do
        local function xVal() 
            if (i == 3 or i == 6 or i == 9) then 
                return 385 
            elseif (i == 2 or i == 5 or i == 8) then 
                return 195 
            else  
                return 5
            end 
        end
        local function yVal() 
            if i > 6 then 
                return -305 
            elseif i > 3 then 
                return -155 
            else 
                return -6
            end 
        end

        local Btn = CreateFrame("Button", nil, Content)
        Btn:SetPoint("TOPLEFT", xVal(), yVal())
        Btn:SetSize(180,140)
        -- local BtnFont = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        -- BtnFont:SetPoint("CENTER", 0, 0)
        -- BtnFont:SetText(i)
        local BtnTex = Btn:CreateTexture()
        BtnTex:SetAllPoints(Btn)
        Btn:RegisterForClicks("AnyUp", "AnyDown")
        Btn:SetScript("OnClick", function(self, button, down) 
            local x = (180/1024)
            local y = (140/1024)
            if (button == "LeftButton" and down == false and GR.IsPlayerTurn and GR.GameOver == false and GR.TicBoard[i] == 0) then
                local TextureX = "Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeX.blp"
                local TextureO = "Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeO.blp"
                local MsgO = " O" 
                local MsgX = " X"
                if (GR.PlayerPos == 1) then 
                    BtnTex:SetTexture(TextureX)
                    GR.TicBoard[i] = 1
                    GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgX, "WHISPER", GR.Opponent)
                end
                if (GR.PlayerPos == 2) then 
                    BtnTex:SetTexture(TextureO)
                    GR.TicBoard[i] = 2
                    GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgO, "WHISPER", GR.Opponent)
                end
                BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                BtnTex:Show()
                GR.IsPlayerTurn = false
                GR:TicCheckForWin()
                GR:SetTurnString()
            end
        end)
        table.insert(Buttons, Btn)
    end
end

function GR:TicCheckForWin()
    if (
        -- Horizontal
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[2] and GR.TicBoard[1] == GR.TicBoard[3] or
        GR.TicBoard[4] ~= 0 and GR.TicBoard[4] == GR.TicBoard[5] and GR.TicBoard[4] == GR.TicBoard[6] or
        GR.TicBoard[7] ~= 0 and GR.TicBoard[7] == GR.TicBoard[8] and GR.TicBoard[7] == GR.TicBoard[9] or
        -- Vertical
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[4] and GR.TicBoard[1] == GR.TicBoard[7] or
        GR.TicBoard[2] ~= 0 and GR.TicBoard[2] == GR.TicBoard[5] and GR.TicBoard[2] == GR.TicBoard[8] or
        GR.TicBoard[3] ~= 0 and GR.TicBoard[3] == GR.TicBoard[6] and GR.TicBoard[3] == GR.TicBoard[9] or
        -- Diagonal
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[5] and GR.TicBoard[1] == GR.TicBoard[9] or
        GR.TicBoard[3] ~= 0 and GR.TicBoard[3] == GR.TicBoard[5] and GR.TicBoard[3] == GR.TicBoard[7] 
    ) then
        GR.GameOver = true
        GR_GUI.Main.HeaderInfo.ReInvite:Show()
        GR_GUI.Main.HeaderInfo.OpponentString:Hide()
        -- show add to rival if not in rivals
        GR:ShowRivalsBtn()
        local TurnString = GR_GUI.Main.HeaderInfo.TurnString
        TurnString:SetPoint("TOP", -150, -35)
        if (GR.IsPlayerTurn == false) then
            TurnString:SetText("Win!")
        else
            TurnString:SetText("Lose")
        end
    end
end

function GR:ResizeTictactoe()
    local Game = GR_GUI.Main.Tictactoe
    local children = { Game:GetChildren() }
    local regions = { Game:GetRegions() }

    -- resizes Game Window
    Game:SetSize(GR_GUI.Main:GetWidth() - 150, GR_GUI.Main:GetHeight() - 150)
   
    -- resizes lines
    regions[9]:ClearAllPoints()
    regions[9]:SetStartPoint("TOPLEFT", Game:GetWidth() / 3, 0)
    regions[9]:SetEndPoint("BOTTOMLEFT", Game:GetWidth() / 3, 0)
    regions[10]:ClearAllPoints()
    regions[10]:SetStartPoint("TOPLEFT", (Game:GetWidth() / 3) * 2, 0)
    regions[10]:SetEndPoint("BOTTOMLEFT", (Game:GetWidth() / 3) * 2, 0)
    regions[11]:ClearAllPoints()
    regions[11]:SetStartPoint("TOPLEFT", 0, -1 * (Game:GetHeight() / 3))
    regions[11]:SetEndPoint("TOPRIGHT", 0, -1 * (Game:GetHeight() / 3))
    regions[12]:ClearAllPoints()
    regions[12]:SetStartPoint("TOPLEFT", 0, (Game:GetHeight() / 3) * -2)
    regions[12]:SetEndPoint("TOPRIGHT", 0, (Game:GetHeight() / 3) * -2)

    local function xPos(i) 
        if (i == 3 or i == 6 or i == 9) then 
            return ((Game:GetWidth() / 3) * 2) + 5 
        elseif (i == 2 or i == 5 or i == 8) then 
            return (Game:GetWidth() / 3) + 5 
        else  
            return 5
        end 
    end
    local function yPos(i) 
        if i > 6 then 
            return ((Game:GetHeight() / 3) * -2) - 6
        elseif i > 3 then 
            return ((Game:GetHeight() / 3) * -1) - 6
        else 
            return -6
        end 
    end
    
    -- resize buttons
    for i,v in ipairs(children) do
        -- point
        v:ClearAllPoints()
        v:SetPoint("TOPLEFT", xPos(i), yPos(i))
        -- size
        local xSize = 180 * (Game:GetWidth() / 570)
        local ySize = 140 * (Game:GetHeight() / 450)
        v:SetSize(xSize, ySize)
    end
end

function GR:TicTacToeHideContent()
    GR_GUI.Main.Tictactoe:Hide()
    GR.TicBoard = {0,0,0,0,0,0,0,0,0}
    local Buttons = GR_GUI.Main.Tictactoe.Buttons
    for i,v in ipairs(Buttons) do 
        local BtnTex = v:GetRegions()
        BtnTex:Hide()
    end
    GR:HideGame()
end

function GR:ShowTictactoe()
    GR_GUI.Main.Tictactoe:Show()
    GR_GUI.Main.HeaderInfo.TurnString:SetPoint("TOP", 0, -35)
    GR:ShowGame()            
end

function GR:TicTacToeComm(...) 
    local prefix, text, distribution, target = ...
    local Buttons = GR_GUI.Main.Tictactoe.Buttons
    local Move = (string.sub(text, 2, 3))
    local Place = tonumber((string.sub(text, 0, 1)))
    local x = (180/1024)
    local y = (140/1024)

    -- Sets Buttons To X or O
    if (type(Place) == "number" ) then
        if (Place > 0 and Place < 10 and string.match(Move, "O") or Place > 0 and Place < 10 and string.match(Move, "X") ) then
            for i,v in ipairs(Buttons) do 
                if (i == Place and string.match(Move, "O")) then 
                    local BtnTex = v:GetRegions()
                    BtnTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeO.blp")
                    BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                    BtnTex:Show()
                    GR.TicBoard[i] = 2
                end
                if (i == Place and string.match(Move, "X")) then 
                    local BtnTex = v:GetRegions()
                    BtnTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeX.blp")
                    BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                    BtnTex:Show()
                    GR.TicBoard[i] = 1
                end
            end
            GR.IsPlayerTurn = true
            GR:TicCheckForWin()
            GR:SetTurnString()
        end
    end
end