GR = LibStub("AceAddon-3.0"):NewAddon("ZUI_GameRoom", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0" )
L = LibStub("AceLocale-3.0"):GetLocale("ZUI_GameRoomLocale")
GR_GUI = {}
local icon = LibStub("LibDBIcon-1.0")
local GR_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GR", {
    type = "data source",
    text = "GameRoom",
    icon = "interface/icons/inv_misc_ticket_tarot_maelstrom_01.blp",
    OnClick = function()
        if (GR_GUI.Main:IsVisible()) then 
            --GR:HideMain()
            GR_GUI.Main:Hide()
        else 
            GR:ShowMain()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("Game Room")
    end,
})

local defaults = {
    realm = {
        minimap = { hide = false },
        HideInCombat = false,
        windowAlpha = 1,
        tab = 1,
        showBN = true,
        disableChallenges = false,
        showChallengeAsMsg = false,
        Xpos = 200,
        Ypos = -150,
        Point = "TOPLEFT",
        Blacklist = {},
        Whitelist = {},
        Rivals = {},
        onlyWhitelist = false,
        WhitelistGuild = false,
        WhitelistParty = false,
        WhitelistFriends = false
    }
}

function GR:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ZUI_GameRoomDB", defaults, true)
    icon:Register("ZUI_GameRoom", GR_LDB, self.db.realm.minimap)
    GR:RegisterChatCommand("gr", "OpenClose")

    -- Game Varibales
    GR.PlayerPos = nil
    GR.IsPlayerTurn = nil
    GR.GameOver = false
    GR.IsChallenged = false
    GR.PlayerName = UnitName("player")
    
    GR:CreateMainWindow()
    GR:CreateHeaderInfo()
    GR:CreateAcceptDecline()
    GR:CreateSettings()
    GR:CreateInvite()
    GR:CreateTicTacToe()
    GR:CreateBattleships()
    GR:CreateAsteroids()
    
    GR.db.realm.tab = 1
    GR:TabSelect()

    GR:RegisterComm("ZUI_GameRoom_Reg", function(...) GR:RegisterPlayers(...) end)
    GR:RegisterComm("ZUI_GameRoom_Inv", function(...) GR:AcceptDeclineChal(...) end)
    GR:RegisterComm("ZUI_GameRoom_TiG", function(...) GR:TicTacToeComm(...) end)
    GR:RegisterComm("ZUI_GameRoom_BSG", function(...) GR:BattleshipsComm(...) end)
end

function GR:OpenClose(input)
    if (GR_GUI.Main:IsVisible()) then 
        --GR:HideMain()
        GR_GUI.Main:Hide()
    else
        GR:ShowMain()
    end
end

function ScrollFrame_OnMouseWheel(self, delta)
    local newValue = self:GetVerticalScroll() - (delta * 20);
   
    if (newValue < 0) then
      newValue = 0;
    elseif (newValue > self:GetVerticalScrollRange()) then
      newValue = self:GetVerticalScrollRange();
    end
   
    self:SetVerticalScroll(newValue);
end

function GR:HideMain()
    if (GR.GameType == "Tictactoe" and GR.InGame) then
        GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_GameEnd", "WHISPER", GR.Opponent)
        GR:TicTacToeHideContent()
    end
    if (GR.GameType == "Battleships" and GR.InGame) then
        GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_GameEnd", "WHISPER", GR.Opponent)
        GR:BattleshipsHideContent()
    end
    GR_GUI.Main:Hide() 
    GR.GameType = nil
end

function GR:ShowMain()
    GR_GUI.Main:ClearAllPoints()

    if (GR:CheckOutOfBoundsRects(GR_GUI.Main, UIParent)) then
        GR_GUI.Main:SetPoint("TOP", UIParent, "TOP", 0, -130)
    end

    -- if main is bigger than screen, reset main size
    if (GR_GUI.Main:GetHeight() > UIParent:GetHeight() or GR_GUI.Main:GetWidth() > UIParent:GetWidth()) then
        GR_GUI.Main:SetSize(750, 510)
        if (GR.GameType == "Tictactoe" ) then
            GR_GUI.Main:SetSize(750, 620)
        end
        if (GR.GameType == "Battleships" ) then
            GR_GUI.Main:SetSize(800, 640)
        end
    end
    GR:ResizeMain()
    GR:ResizeBattleships()
    GR:ResizeTictactoe()
    GR:ShowChallengeIfChallenged() 
    GR_GUI.Main:Show() 
end

function GR:CreateMainWindow()
    -- Main Window
    GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "TranslucentFrameTemplate")
    GR_GUI.Main:SetSize(750, 510)
    GR_GUI.Main:SetMinResize(220,220)
    GR_GUI.Main:SetFrameStrata("HIGH")
    GR_GUI.Main:SetPoint("TOP", UIParent, "TOP", 0, -130)
    GR_GUI.Main:SetMovable(true)
    GR_GUI.Main:EnableMouse(true)
    GR_GUI.Main:SetResizable(true)
    GR_GUI.Main:RegisterForDrag("LeftButton")
    GR_GUI.Main:SetScript("OnDragStart", function() if(IsShiftKeyDown() == true) then GR_GUI.Main:StartMoving() end end)
    GR_GUI.Main:SetScript("OnDragStop", GR_GUI.Main.StopMovingOrSizing)
    GR_GUI.Main:SetPropagateKeyboardInput(true)
    GR_GUI.Main:SetScript("OnKeyDown", function(self, key)
        if (key == "ESCAPE" and GR_GUI.Main:IsVisible()) then
            GR_GUI.Main:Hide()
            GR_GUI.Main:SetPropagateKeyboardInput(false)
            C_Timer.After(.001, function() 
                GR_GUI.Main:SetPropagateKeyboardInput(true)
                -- ToggleGameMenu()
            end)
        end
    end)
    GR_GUI.Main:Show()
    GR_GUI.Main:SetAlpha(GR.db.realm.windowAlpha)

    GR_GUI.Main.ResizeBtn = CreateFrame("Button", nil, GR_GUI.Main)
    local ResizeBtn = GR_GUI.Main.ResizeBtn    
    ResizeBtn:SetPoint("BOTTOMRIGHT", -11, 10)
    ResizeBtn:SetSize(16, 16)
    ResizeBtn:EnableMouse("true")
    ResizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    ResizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    ResizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    ResizeBtn:SetScript("OnMouseDown", function(self)
        self:GetParent():StartSizing("BOTTOMRIGHT") 
    end)
    ResizeBtn:SetScript("OnMouseUp", function()
        GR_GUI.Main:StopMovingOrSizing("BOTTOMRIGHT")
        GR:ResizeMain()
        GR:ResizeTictactoe()
        GR:ResizeBattleships()
    end)

    -- GR_GUI.Main.Tex = GR_GUI.Main:CreateTexture()
    -- local tex = GR_GUI.Main.Tex
    -- tex:SetAllPoints(GR_GUI.Main)
    -- tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\BlackWhiteBorder.blp")
    -- tex:SetTexCoord(0,0, 0,.586, .731,0, .731,.586)
    -- tex:SetAlpha(GR.db.realm.windowAlpha)
    -- C_Timer.After(8, function() tex:SetTexCoord(.7324,0, 0,0, .7324,.586, 0,.586) end)
    -- C_Timer.After(10, function() tex:SetTexCoord(.7324,.586, .7324,0, 0,.586, 0,0) end)
    -- C_Timer.After(12, function() tex:SetTexCoord(0,.586, .7324,.586, 0,0, .7324,0) end)
    -- C_Timer.After(14, function() tex:SetTexCoord(0,0, 0,.586, .7324,0, .7324,.586) end)
    GR_GUI.Main.H1 =  GR_GUI.Main:CreateFontString(GR_GUI.Main, "HIGH", "GameTooltipText")
    local H1 = GR_GUI.Main.H1
    H1:SetPoint("TOP", 0, -18)
    H1:SetTextScale(2.8)
    H1:SetTextColor(.8,.8,.8,1)
    H1:SetText("Game Room")

    -- X Button
    GR_GUI.Main.xButton = CreateFrame("Button", XButton, GR_GUI.Main)
    local xButton = GR_GUI.Main.xButton
    xButton:SetSize(25,25)
    xButton:SetPoint("TOPRIGHT", -13, -13)
    xButton:RegisterForClicks("AnyUp", "AnyDown")

    GR_GUI.Main.xButton.tex = xButton:CreateTexture()
    local buttonTex = GR_GUI.Main.xButton.tex
    buttonTex:SetAllPoints(xButton)
    buttonTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
    buttonTex:SetTexCoord(0, 1, 0, 1)

    GR_GUI.Main.xButton.tint = xButton:CreateTexture()
    local buttonTint = GR_GUI.Main.xButton.tint
    buttonTint:SetPoint("TOPLEFT", xButton, "TOPLEFT", 2, -2)
    buttonTint:SetPoint("BOTTOMRIGHT", xButton, "BOTTOMRIGHT", -2, 2)
    buttonTint:SetColorTexture(0,0,0,0);

    GR_GUI.Main.xButton:SetScript("OnClick", function(self, button, down) 
        if(button == "LeftButton" and down == true) then GR_GUI.Main.xButton.tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButtonDown.blp") end
        if(button == "LeftButton" and down == false) then 
            --GR:HideMain() 
            GR_GUI.Main:Hide()
        end
    end)
    GR_GUI.Main.xButton:SetScript("OnEnter", function(self, motion)
        GR_GUI.Main.xButton.tint:SetColorTexture(0,0,0,.3);
    end)
    GR_GUI.Main.xButton:SetScript("OnLeave", function(self, motion)
        GR_GUI.Main.xButton.tint:SetColorTexture(0,0,0,0);
        GR_GUI.Main.xButton.tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
    end)

    -- Home Button 
    GR_GUI.Main.HomeBtn = CreateFrame("Button", HomeBtn, GR_GUI.Main)
    local HomeBtn = GR_GUI.Main.HomeBtn
    HomeBtn:SetSize(100, 25)
    HomeBtn:SetPoint("TOPLEFT", 18, -18)
    HomeBtn:SetScript("OnClick", function(self, button, down)
        if(button == "LeftButton" and down == false) then GR.db.realm.tab = 1 end
        GR:TabSelect()
    end)
    local HomeString = HomeBtn:CreateFontString(HomeBtn, "HIGH", "GameTooltipText")
    HomeString:SetPoint("CENTER")
    HomeString:SetText("Home")
    HomeString:SetTextScale(1.1)
    HomeString:SetTextColor(.8,.5,.2, 1)
end

function GR:ResizeMain()
    -- resize FontStrings
    local Main = GR_GUI.Main
    local HeaderInfo = Main.HeaderInfo
    local WidthRatio = (Main:GetWidth() / 750)
    local HeightRatio = (Main:GetHeight() / 510)
    local FontScale = ((WidthRatio + HeightRatio) / 2)

    HeaderInfo:SetPoint("TOP", 0, -60 * HeightRatio)
    HeaderInfo:SetSize(700 * WidthRatio, 100 * HeightRatio)
    HeaderInfo.TurnString:SetTextScale(FontScale * 2)
    if (GR.GameType == "Battleships") then
        HeaderInfo.TurnString:SetPoint("TOP", 0, -55 * (Main:GetHeight() / 750))
    else
        HeaderInfo.TurnString:SetPoint("TOP", 0, -25 * (Main:GetHeight() / 750))
    end
    HeaderInfo.OpponentString:SetPoint("TOPLEFT", 0, 0)
    HeaderInfo.OpponentString:SetTextScale(FontScale * 1.5)
    HeaderInfo.H2:SetTextScale(FontScale * 2.1)
    HeaderInfo.ExitBtn:SetSize(100 * WidthRatio, 30 * HeightRatio)
    HeaderInfo.ExitBtnFS:SetTextScale(1.1 * FontScale)
    Main.H1:SetPoint("TOP", 0, -18 * HeightRatio)
    Main.H1:SetTextScale(2.8 * FontScale)
    
    Main.ResizeBtn:SetPoint("BOTTOMRIGHT", -11 * WidthRatio, 10 * HeightRatio)
    Main.ResizeBtn:SetSize(16 * WidthRatio, 16 * HeightRatio)

    Main.xButton:SetSize(25 * WidthRatio, 25 * HeightRatio)
    Main.xButton:SetPoint("TOPRIGHT", -13 * WidthRatio, -13 * HeightRatio)
end

function GR:CreateHeaderInfo()
    GR_GUI.Main.HeaderInfo = CreateFrame("Frame", HeaderInfo, GR_GUI.Main)
    local HeaderInfo = GR_GUI.Main.HeaderInfo
    HeaderInfo:SetPoint("TOP", 0, -56)
    HeaderInfo:SetSize(700, 100)
    GR_GUI.Main.HeaderInfo.H2 = HeaderInfo:CreateFontString(HeaderInfo, "HIGH", "GameTooltipText")
    local H2 = GR_GUI.Main.HeaderInfo.H2
    H2:SetPoint("TOP", 0, 0)
    H2:SetTextScale(2.1)
    H2:SetTextColor(.8,.8,.8,1)
    H2:SetText("Tic-Tac-Toe")
    
    HeaderInfo.TurnString = HeaderInfo:CreateFontString(HeaderInfo, "HIGH", "GameTooltipText")
    local TurnString = HeaderInfo.TurnString
    TurnString:SetPoint("TOP", 0, -90)
    TurnString:SetTextScale(2)

    HeaderInfo.ExitBtn = CreateFrame("Button", ExitBtn, HeaderInfo, "UIPanelButtonTemplate")
    local ExitBtn = HeaderInfo.ExitBtn
    ExitBtn:SetPoint("TOPRIGHT", 0, 0)
    ExitBtn:SetSize(100, 30)
    HeaderInfo.ExitBtnFS = ExitBtn:CreateFontString(ExitBtn, "HIGH", "GameTooltipText")
    local ExitBtnFS = HeaderInfo.ExitBtnFS 
    ExitBtnFS:SetPoint("CENTER", 0, 0)
    ExitBtnFS:SetTextScale(1.1)
    ExitBtnFS:SetTextColor(.8,.8,.8, 1)
    ExitBtnFS:SetText("Exit Game")
    ExitBtn:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
        if (GR.GameType == "Tictactoe") then
          GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_GameEnd", "WHISPER", GR.Opponent)
          GR:TicTacToeHideContent()
        end
        if (GR.GameType == "Battleships") then
          GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_GameEnd", "WHISPER", GR.Opponent)
          GR:BattleshipsHideContent()
        end
        if (GR.GameType == "Asteroids") then
          GR:AsteroidsHide()    
        end
        GR.GameType = nil
      end
    end)
    ExitBtn:Hide()

    HeaderInfo.OpponentString = HeaderInfo:CreateFontString(HeaderInfo, "HIGH", "GameTooltipText")
    local Opp = HeaderInfo.OpponentString
    Opp:SetPoint("TOPLEFT", 0, 0)
    Opp:SetTextColor(.8,.8,.8, 1)
    Opp:SetTextScale(1.5)
    Opp:Hide()

    HeaderInfo.ReInvite = CreateFrame("Button", ReInvite, HeaderInfo, "UIPanelButtonTemplate")
    local ReInvite = HeaderInfo.ReInvite
    ReInvite:SetPoint("TOPRIGHT", -130, 7)
    ReInvite:SetSize(100, 30)
    local ReInviteString = ReInvite:CreateFontString(ReInvite, "HIGH", "GameTooltipText")
    ReInviteString:SetPoint("CENTER", 0, 0)
    ReInviteString:SetTextScale(1.1)
    ReInviteString:SetTextColor(.8,.8,.8, 1)
    ReInviteString:SetText("Rematch?")
    ReInvite:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then
            local UserName = UnitName("player")
            if (GR.GameType == "Tictactoe") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Challenge, " .. UserName, "WHISPER", GR.Opponent)
            end
            if (GR.GameType == "Battleships") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Challenge, " .. UserName, "WHISPER", GR.Opponent)
            end
            GR.CanSendInvite = false
            ReInvite:Hide()
            C_Timer.After(4, function() 
                GR.CanSendInvite = true
            end)
        end
    end)
    ReInvite:Hide()

    HeaderInfo.ReMatch = CreateFrame("Button", ReMatch, HeaderInfo, "UIPanelButtonTemplate")
    local ReMatch = HeaderInfo.ReMatch
    ReMatch:SetPoint("TOPRIGHT", -130, 7)
    ReMatch:SetSize(100, 30)
    local ReMatchString = ReMatch:CreateFontString(ReMatch, "HIGH", "GameTooltipText")
    ReMatchString:SetPoint("CENTER", 0, 0)
    ReMatchString:SetTextScale(1.1)
    ReMatchString:SetTextColor(.8,.8,.8, 1)
    ReMatchString:SetText("Accept")
    ReMatch:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
            local Opponent = GR.Opponent
            GR.PlayerPos = random(1,2)
            if (GR.PlayerPos == 2) then
                GR.IsPlayerTurn = false
            else
                GR.IsPlayerTurn = true
            end
            if (GR.GameType == "Tictactoe") then
                GR:TicTacToeHideContent()
                GR_GUI.Main:SetSize(750, 620)
                GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. GR.PlayerPos .. ", " .. UnitName("player"), "WHISPER", Opponent)
                GR:ShowTictactoe()
            end
            if (GR.GameType == "Battleships") then
                GR:BattleshipsHideContent()
                GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. GR.PlayerPos .. ", " .. UnitName("player"), "WHISPER", Opponent)
                GR:BattleshipsShowContent()
            end
            GR.Opponent = Opponent
        end
    end)
    ReMatch:Hide()

    HeaderInfo.Rival = CreateFrame("Button", Rival, HeaderInfo, "UIPanelButtonTemplate")
    local Rival = HeaderInfo.Rival
    Rival:SetPoint("TOPLEFT", 0, 7)
    Rival:SetSize(100, 30)
    local RivalString = Rival:CreateFontString(Rival, "HIGH", "GameTooltipText")
    RivalString:SetPoint("CENTER", 0, 0)
    RivalString:SetTextScale(1.1)
    RivalString:SetTextColor(.8,.8,.8, 1)
    RivalString:SetText("Add Rival")
    Rival:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
            table.insert(GR.db.realm.Rivals, GR.Opponent)
            Rival:Hide()
        end
    end)
    Rival:Hide()

    -- hide opponent string end of game
    -- show rival end of game
    -- only show add rivalbtn if not rival

    HeaderInfo:Hide()
end

function GR:CreateAcceptDecline()
    -- Accept Button when GameRoom is closed
    local PlayerName = UnitName("player")
    GR_GUI.Accept = CreateFrame("Button", Accept, UIParent, "UIPanelButtonTemplate")
    local Accept = GR_GUI.Accept
    Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    Accept:SetSize(214, 58)
    local AcceptString = Accept:CreateFontString(Accept, "HIGH", "GameTooltipText")
    AcceptString:SetPoint("TOP", 0, -11)
    AcceptString:SetTextScale(1.5)
    AcceptString:SetTextColor(.8,1,0, 1)
    AcceptString:SetText("Incoming Challenge!")
    Accept.Fs2 = Accept:CreateFontString(Accept, "HIGH", "GameTooltipText")
    local AcceptString2 = Accept.Fs2
    AcceptString2:SetPoint("BOTTOM", 0, 10)
    AcceptString2:SetTextScale(1.3)
    AcceptString2:SetTextColor(.8,1,0, 1)
    Accept:SetScript("OnClick", function(self, button, down) 
        -- send message to show other user board
        GR_GUI.Main:Show()
        GR.PlayerPos = random(1,2)
        if (GR.PlayerPos == 2) then
            GR.IsPlayerTurn = false
        else
            GR.IsPlayerTurn = true
        end
        if (GR.GameType == "Tictactoe") then
            GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. GR.PlayerPos .. ", " .. PlayerName, "WHISPER", GR.Opponent)
            GR:ShowTictactoe()
        end
        if (GR.GameType == "Battleships") then
            GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. GR.PlayerPos .. ", " .. PlayerName, "WHISPER", GR.Opponent)
            GR:BattleshipsShowContent()
        end
    end)

    Accept.DeclineBtn = CreateFrame("Button", DeclineBtn, Accept, "UIPanelButtonTemplate")
    local DeclineBtn = Accept.DeclineBtn
    DeclineBtn:SetPoint("RIGHT", 100, 0)
    DeclineBtn:SetSize(70, 20)
    local DeclineBtnString = DeclineBtn:CreateFontString(DeclineBtn, "HIGH", "GameTooltipText")
    DeclineBtnString:SetPoint("CENTER", 0, 0)
    DeclineBtnString:SetTextScale(1.1)
    DeclineBtnString:SetTextColor(.8,.8,.8, 1)
    DeclineBtnString:SetText("Decline")
    DeclineBtn:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
            GR.IsChallenged = false
            GR_GUI.Main.Accept:Hide()
            GR_GUI.Accept:Hide()
            if (GR.GameType == "Tictactoe") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Decline, ", "WHISPER", GR.Opponent)
            end 
            if (GR.GameType == "Battleships") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Decline, ", "WHISPER", GR.Opponent)
            end 
            GR.Opponent = nil
        end 
    end)

    -- Mover for Accept Button when GameRoom is closed
    GR_GUI.AcceptMover = CreateFrame("Frame", AcceptMover, UIParent)
    GR_GUI.AcceptMover:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    GR_GUI.AcceptMover:SetSize(50, 50)
    local AcceptMoverTex = GR_GUI.AcceptMover:CreateTexture()
    AcceptMoverTex:SetAllPoints(GR_GUI.AcceptMover)
    AcceptMoverTex:SetColorTexture(0,.4,1, 1)
    GR_GUI.AcceptMover:SetMovable(true)
    GR_GUI.AcceptMover:EnableMouse(true)
    GR_GUI.AcceptMover:RegisterForDrag("LeftButton")
    GR_GUI.AcceptMover:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
    GR_GUI.AcceptMover:SetScript("OnDragStop", function(self) 
        self:StopMovingOrSizing() 
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        GR.db.realm.Point = point
        GR.db.realm.Xpos = xOfs
        GR.db.realm.Ypos = yOfs
        Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    end)
    GR_GUI.AcceptMover:Hide()



    -- Accept Button when GameRoom is open
    GR_GUI.Main.Accept = CreateFrame("Button", Accept2, GR_GUI.Main, "UIPanelButtonTemplate")
    local Accept2 = GR_GUI.Main.Accept
    Accept2:SetPoint("TOPLEFT", 30, -50)
    Accept2:SetSize(214, 58)
    local Accept2String = Accept2:CreateFontString(Accept2, "HIGH", "GameTooltipText")
    Accept2String:SetPoint("TOP", 0, -11)
    Accept2String:SetTextScale(1.5)
    Accept2String:SetTextColor(.8,1,0, 1)
    Accept2String:SetText("Incoming Challenge!")
    Accept2.Fs2 = Accept2:CreateFontString(Accept2, "HIGH", "GameTooltipText")
    local Accept2String2 = Accept2.Fs2
    Accept2String2:SetPoint("BOTTOM", 0, 10)
    Accept2String2:SetTextScale(1.3)
    Accept2String2:SetTextColor(.8,1,0, 1)
    Accept2:SetScript("OnClick", function(self, button, down) 
        -- send message to show other user board
        GR_GUI.Main.Accept:Hide()
        GR_GUI.Main.DeclineBtn:Hide()
        GR.PlayerPos = random(1,2)
        if (GR.PlayerPos == 2) then
            GR.IsPlayerTurn = false
        else
            GR.IsPlayerTurn = true
        end
        if (GR.GameType == "Tictactoe") then
            GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. GR.PlayerPos .. ", " .. PlayerName, "WHISPER", GR.Opponent)
            GR:ShowTictactoe()
        end
        if (GR.GameType == "Battleships") then
            GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. GR.PlayerPos .. ", " .. PlayerName, "WHISPER", GR.Opponent)
            GR:BattleshipsShowContent()
        end
    end)

    GR_GUI.Main.DeclineBtn = CreateFrame("Button", DeclineBtn2, GR_GUI.Main, "UIPanelButtonTemplate")
    local DeclineBtn2 = GR_GUI.Main.DeclineBtn
    DeclineBtn2:SetPoint("TOPRIGHT", -150, -65)
    DeclineBtn2:SetSize(70, 20)
    local DeclineBtn2String = DeclineBtn2:CreateFontString(DeclineBtn2, "HIGH", "GameTooltipText")
    DeclineBtn2String:SetPoint("CENTER", 0, 0)
    DeclineBtn2String:SetTextScale(1.1)
    DeclineBtn2String:SetTextColor(.8,.8,.8, 1)
    DeclineBtn2String:SetText("Decline")
    DeclineBtn2:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
            GR.IsChallenged = false
            GR.Opponent = nil
            GR_GUI.Main.Accept:Hide()
            GR_GUI.Main.DeclineBtn:Hide()
            GR_GUI.Accept:Hide()
            if (GR.GameType == "Tictactoe") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Decline, ", "WHISPER", GR.Opponent)
            end
            if (GR.GameType == "Battleships") then
                GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Decline, ", "WHISPER", GR.Opponent)
            end
        end
    end)
    
    Accept:Hide()
    Accept2:Hide()
    DeclineBtn2:Hide()
end

function GR:TabSelect()
    if GR.db.realm.tab ~= 1 then 
        GR_GUI.Main.Invite:Hide() 
    else 
        GR_GUI.Main.Tictactoe:Hide() 
        GR_GUI.Main.HomeBtn:Hide() 
        GR_GUI.Main.HeaderInfo:Hide() 
        GR_GUI.Main.Settings:Hide() 
        GR_GUI.Main.Invite:Show() 
    end 
    if GR.db.realm.tab ~= 2 then 
        GR_GUI.Main.HeaderInfo:Hide()
    else 
        GR_GUI.Main.Settings:Hide() 
        GR_GUI.Main.HeaderInfo:Show() 
        GR_GUI.Main.HeaderInfo.Accept:Hide()
        GR_GUI.Main.HeaderInfo.ExitBtn:Hide() 
    end 
    if GR.db.realm.tab ~= 7 then 
        GR_GUI.Main.SettingsScroll:Hide() 
        GR_GUI.Main.Settings:Hide() 
        GR_GUI.Main.HomeBtn:Hide() 
    else 
        GR_GUI.Main.HomeBtn:Show() 
        GR_GUI.Main.SettingsScroll:Show() 
        GR_GUI.Main.Settings:Show() 
    end 
end

function GR:SetTurnString()
    local TurnString = GR_GUI.Main.HeaderInfo.TurnString
    if (GR.GameOver == false) then
        if (GR.IsPlayerTurn) then
            TurnString:SetTextColor(0,1,0,1)
            TurnString:SetText(UnitName("player"))
        else
            TurnString:SetTextColor(1,0,0,1)
            TurnString:SetText(GR.Opponent)
        end
    end
end

function GR:ShowRivalsBtn() 
    local InRivals = false
    for i,v in ipairs(GR.db.realm.Rivals) do
        if (string.match(v, GR.Opponent)) then
            InRivals = true
        end
    end
    if (InRivals == false) then
        GR_GUI.Main.HeaderInfo.Rival:Show()
    end
end

function GR:ShowGame()
    GR.InGame = true
    GR_GUI.Main.HeaderInfo:Show()
    GR_GUI.Main.HeaderInfo.OpponentString:Show()
    GR_GUI.Main.HeaderInfo.TurnString:Show()
    GR_GUI.Main.HeaderInfo.ExitBtn:Show()
    GR_GUI.Accept:Hide()
    GR_GUI.Main.SettingsScroll:Hide()
    GR_GUI.Main.Settings:Hide()
    GR_GUI.Main.HeaderInfo.ReInvite:Hide()
    GR_GUI.Main.HeaderInfo.ReMatch:Hide()
    GR_GUI.Main.HeaderInfo.Rival:Hide()
    GR_GUI.Main.HomeBtn:Hide()
    GR_GUI.Main.Invite:Hide()
    if (GR.Opponent) then 
      GR_GUI.Main.HeaderInfo.OpponentString:SetText("Opponent: " .. GR.Opponent)
    end
    GR:SetTurnString()
    if GR.GameType == "Tictactoe" then
        GR_GUI.Main:SetSize(750, 620)
    end
end

function GR:ShowSoloGame()
  GR.InGame = true
  GR_GUI.Main.HeaderInfo:Show()
  GR_GUI.Main.HeaderInfo.OpponentString:Hide()
  GR_GUI.Main.HeaderInfo.TurnString:Hide()
  GR_GUI.Main.HeaderInfo.ExitBtn:Show()
  GR_GUI.Accept:Hide()
  GR_GUI.Main.SettingsScroll:Hide()
  GR_GUI.Main.Settings:Hide()
  GR_GUI.Main.HeaderInfo.ReInvite:Hide()
  GR_GUI.Main.HeaderInfo.ReMatch:Hide()
  GR_GUI.Main.HeaderInfo.Rival:Hide()
  GR_GUI.Main.HomeBtn:Hide()
  GR_GUI.Main.Invite:Hide()
end

function GR:HideGame()
    GR.PlayerPos = nil
    GR.IsPlayerTurn = nil
    GR.InGame = false
    GR.GameOver = false
    GR.db.realm.tab = 1
    GR.CanSendInvite = true
    GR.IsChallenged = false
    GR.Opponent = nil
    GR_GUI.Main.HeaderInfo:Hide()
    GR_GUI.Main.HeaderInfo.ExitBtn:Hide()
    GR_GUI.Main.HeaderInfo.OpponentString:Hide()
    GR_GUI.Main.Invite:Show()
    GR_GUI.Main.HomeBtn:Show()
    GR_GUI.Main:SetSize(750, 510)
end

function GR:AABB(Rect1, Rect2)
    local MarginX = 9 * (GR_GUI.Main:GetWidth() / 800)
    local MarginY = 9 * (GR_GUI.Main:GetHeight() / 640)
    if (Rect1.tl.x + MarginX > Rect2.br.x - MarginX or Rect1.tl.y - MarginY < Rect2.br.y + MarginY or Rect1.br.x - MarginX < Rect2.tl.x + MarginX or Rect1.br.y + MarginY > Rect2.tl.y - MarginY) then
        return false
    end
    return true
end

function GR:CheckOutOfBoundsRects(Rect1, Rect2)
    local Rect1X, Rect1Y, Rect1Width, Rect1Height = Rect1:GetRect()
    local Rect2X, Rect2Y, Rect2Width, Rect2Height = Rect2:GetRect()
    -- out of bounds check. rect1 is fully out of rect2
    if (Rect1X > Rect2X + Rect2Width or Rect1X + Rect1Width < Rect2X or Rect1Y > Rect2Y + Rect2Height or Rect1Y + Rect1Height < Rect2Y) then
        return true
    end
    return false
end

-- 2048 game before release
-- asteroids
-- death rolls

