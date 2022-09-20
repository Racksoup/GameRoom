function GR:CreateBattleships()
    GR.BattleshipsBoard = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    
    GR_GUI.Main.Battleships = CreateFrame("Frame", Battleships, GR_GUI.Main, "ThinBorderTemplate")
    local Game = GR_GUI.Main.Battleships
    Game:SetPoint("CENTER", 0, -50)
    Game:SetSize(570, 450)
    Game:Hide()

    GR:CreateBattleshipsLines()
    GR:CreateBattleshipsButtons()
end

function GR:CreateBattleshipsLines()
    local Content = GR_GUI.Main.Battleships
    for i = 1, 9, 1 do
        local VLine = Content:CreateLine()
        VLine:SetColorTexture(.8,.8,.8, .2)
        VLine:SetStartPoint("TOPLEFT", (Content:GetWidth() / 10) * i, 0)
        VLine:SetEndPoint("BOTTOMLEFT", (Content:GetWidth() / 10) * i, 0)
    end
    for i = 1, 9, 1 do
        local HLine = Content:CreateLine()
        HLine:SetColorTexture(.8,.8,.8, .2)
        HLine:SetStartPoint("TOPLEFT", 0, (Content:GetHeight() / 10) * -i)
        HLine:SetEndPoint("TOPRIGHT", 0, (Content:GetHeight() / 10) * -i)
    end
end

function GR:CreateBattleshipsButtons()
    local Content = GR_GUI.Main.Battleships
    GR_GUI.Main.Battleships.Buttons = {}
    local Buttons = GR_GUI.Main.Battleships.Buttons

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
        -- local BtnFont = Btn:CreateFontString(Btn, "HIGH", "GameTooltipText")
        -- BtnFont:SetPoint("CENTER", 0, 0)
        -- BtnFont:SetText(i)
        local BtnTex = Btn:CreateTexture()
        BtnTex:SetAllPoints(Btn)
        Btn:RegisterForClicks("AnyUp", "AnyDown")
        Btn:SetScript("OnClick", function(self, button, down) 
            local x = ((Content:GetWidth() / 10) / 1024)
            local y = ((Content:GetHeight() / 10) / 1024)
            if (button == "LeftButton" and down == false and GR.IsPlayerTurn and GR.GameOver == false and GR.TicBoard[i] == 0) then
                -- local TextureX = "Interface\\AddOns\\ZUI_GameRoom\\images\\BattleshipsRed.blp"
                -- local TextureO = "Interface\\AddOns\\ZUI_GameRoom\\images\\BattleshipsBlue.blp"
                -- local MsgO = " O" 
                -- local MsgX = " X"
                -- if (GR.PlayerPos == 1) then 
                --     BtnTex:SetTexture(TextureX)
                --     GR.TicBoard[i] = 1
                --     GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgX, "WHISPER", GR.Opponent)
                -- end
                -- if (GR.PlayerPos == 2) then 
                --     BtnTex:SetTexture(TextureO)
                --     GR.TicBoard[i] = 2
                --     GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgO, "WHISPER", GR.Opponent)
                -- end
                -- BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                -- BtnTex:Show()
                -- GR.IsPlayerTurn = false
                -- GR:TicCheckForWin()
                -- GR:SetTurnString()
            end
        end)
        table.insert(Buttons, Btn)
    end
end

function GR:BattleshipsCheckForWin()

end

function GR:BattleshipsHideContent()
    GR_GUI.Main.Battleships:Hide()
    GR.BattleshipsBoard = {
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
    }
    local Buttons = GR_GUI.Main.Battleships.Buttons
    for i,v in ipairs(Buttons) do 
        local BtnTex = v:GetRegions()
        BtnTex:Hide()
    end
    GR:HideGame()
end

function GR:ResizeBattleships()

end

function GR:BattleshipsComm(...)
    local prefix, text, distribution, target = ...
end