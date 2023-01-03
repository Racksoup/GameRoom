function GR:Invite(...)
  local prefix, text, distribution, target = ...
  local Main = GR_GUI.Main
  local Accept = GR_GUI.Accept

  GR:IncomingInvite(text, Main, Accept)
  GR:ChallengeAccepted(text)
  GR:OpponentEndedGame(text)
  GR:GameDeclined(text)
end

function GR:IncomingInvite(text, Main, Accept)
  local TicChallenge = string.sub(text, 0, 19)
  local BSChallenge = string.sub(text, 0, 21)
  local TicOpponent = string.sub(text, 22, 50)
  local BSOpponent = string.sub(text, 24, 50)

  -- if raid/party setup different variables
  local distribution = nil
  local Receiver = nil
  if (string.sub(text, 22, 25) == "PART" or string.sub(text, 22, 25) == "RAID") then
    distribution = string.sub(text, 22, 25)
    TicOpponent = string.sub(text, 26, 37)
    TicOpponent = TicOpponent.gsub("-", "")
    Receiver = string.sub(text, 38, 49)
    Receiver = Receiver:gsub("-", "")
  end
  if (string.sub(text, 24, 27) == "PART" or string.sub(text, 24, 27) == "RAID") then
    distribution = string.sub(text, 24, 27)
    BSOpponent = string.sub(text, 28, 39)
    BSOpponent = BSOpponent:gsub("-", "")
    Receiver = string.sub(text, 38, 49)
    Receiver = Receiver:gsub("-", "")
  end

  -- if raid/party we need to check that we are the reciver
  if (Receiver == nil or Receiver == UnitName("player")) then

    -- if challenge recieved
    if ((string.match(BSChallenge, "Battleships_Challenge") or string.match(TicChallenge, "TicTacToe_Challenge")) and GR.IsChallenged == false and GR.db.realm.disableChallenges == false) then
      local AcceptGameString = ""

      if (string.match(BSChallenge, "Battleships_Challenge")) then
        GR.GameType = "Battleships"
        GR.IncGameType = "Battleships"
        AcceptGameString = "Battleships"
      end
      if (string.match(TicChallenge, "TicTacToe_Challenge")) then
        GR.GameType = "Tictactoe"
        GR.IncGameType = "Tictactoe"
        AcceptGameString = "Tic-Tac-Toe"
      end

      -- Check if challenger is allowed to invite player
      local function ChalAllowedInvite()
        local AcceptChal = true
        if (GR.db.realm.onlyWhitelist) then 
          AcceptChal = false
          -- go through whitelist and see if challenger is on list
          for i,v in ipairs(GR.db.realm.Whitelist) do
            if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
              AcceptChal = true
            end
          end
          -- if whitelist Friends, go through Friends and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistFriends) then
            for i,v in ipairs(GR.Friends) do
              if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                AcceptChal = true
              end
            end
          end
          -- if whitelist Guild, go through Guild and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistGuild) then
            for i,v in ipairs(GR.OnlyGuild) do
              if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                AcceptChal = true
              end
            end
          end
          -- if whitelist Party, go through Party and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistParty) then
            for i,v in ipairs(GR.OnlyParty) do
              if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
                AcceptChal = true
              end
            end
          end
        end
        -- go through Blacklist and see if challenger is on list
        for i,v in ipairs(GR.db.realm.Blacklist) do
          if (string.match(v, TicOpponent) or string.match(v, BSOpponent)) then
            AcceptChal = false
          end
        end
        return AcceptChal
      end
      local AcceptChallenger = ChalAllowedInvite()

      -- if challenger is allowed to invite player to game
      if (AcceptChallenger) then
        
        if (string.match(BSChallenge, "Battleships_Challenge")) then
          Main.Accept.FS2:SetText(BSOpponent .. " - " .. AcceptGameString)
          Accept.FS2:SetText(BSOpponent .. " - " .. AcceptGameString)
          GR.Opponent = BSOpponent
        end
        if (string.match(TicChallenge, "TicTacToe_Challenge")) then
          Main.Accept.FS2:SetText(TicOpponent .. " - " .. AcceptGameString)
          Accept.FS2:SetText(TicOpponent .. " - " .. AcceptGameString)
          GR.Opponent = TicOpponent
        end
        if (GR.InGame == false and Main.Battleships:IsVisible() == false and Main.Tictactoe:IsVisible() == false) then
          GR.GroupType = distribution
          GR.IsChallenged = true
          C_Timer.After(15, function()
            GR.IsChallenged = false
            GR:ShowChalOnInvite()
          end)
          local Hide = false
          if (GR.db.realm.HideInCombat and InCombatLockdown()) then
            Hide = true
          end
          if (not Hide) then
            if (GR.db.realm.showChallengeAsMsg == false) then
              if (Main:IsVisible() == true) then
                Main.Accept:Show()
                Main.DeclineBtn:Show()
                C_Timer.After(15, function() 
                  Main.Accept:Hide()
                  Main.DeclineBtn:Hide()
                end)
              else
                Accept:Show()
                C_Timer.After(15, function() 
                  Accept:Hide()
                end)
              end
            else
              GR:Print(GR.Opponent .. " has challenged you to play " .. AcceptGameString .. "!")
              Accept.FS2:SetText(GR.Opponent .. " - " .. AcceptGameString)
              if (Main:IsVisible() == true) then
                Main.Accept:Show()
                Main.DeclineBtn:Show()
                C_Timer.After(15, function() 
                  Main.Accept:Hide()
                  Main.DeclineBtn:Hide()
                end)
              end
            end
          end
        else
          -- show accept button if not in game
          Main.HeaderInfo.ReInvite:Hide()
          Main.HeaderInfo.ReMatch:Show()
        end
      end
    end
  end
end

function GR:ChallengeAccepted(text)
  -- registers challenge accepted, shows game board. sender shows board on accept click
  -- TicTacToe Challenge Accepted
  local TicAccept = string.sub(text, 0, 16)
  local TicPlayerTurn = string.sub(text, 19, 19)
  local TicOpponent = string.sub(text, 22, 50)
  local TicGroupType = string.sub(text, 19, 22)

  if (string.match(TicAccept, "TicTacToe_Accept")) then
    if (TicGroupType == "PART" or TicGroupType == "RAID") then
      TicPlayerTurn = string.sub(text, 23, 23)
      TicOpponent = string.sub(text, 24, 50)
      GR.GroupType = TicGroupType
      GR.UseGroupChat = true
    else 
      GR.UseGroupChat = false
      GR.GroupType = nil
    end

    if (TicOpponent ~= UnitName("player")) then
      GR.GameType = "Tictactoe"
      GR:TicTacToeHideContent()  
      GR.Opponent = TicOpponent
      if (TicGroupType == "PART") then TicGroupType = "PARTY" end
      if (string.match(TicPlayerTurn, "2")) then
        GR.PlayerPos = 1
        GR.IsPlayerTurn = true
      else
        GR.PlayerPos = 2
        GR.IsPlayerTurn = false
      end
      GR.db.realm.tab = 1
      GR:TabSelect()
    end
  end

  -- Battleships Challenge Accepted
  local BSAccept = string.sub(text, 0, 18)
  local BSPlayerTurn = string.sub(text, 21, 21)
  local BSOpponent = string.sub(text, 24, 50)
  local BSGroupType = string.sub(text, 21, 24)
  
  if (string.match(BSAccept, "Battleships_Accept")) then
    if (BSGroupType == "PART" or BSGroupType == "RAID") then
      BSPlayerTurn = string.sub(text, 25, 25)
      BSOpponent = string.sub(text, 26, 50)
      GR.GroupType = BSGroupType
      GR.UseGroupChat = true
    else
      GR.UseGroupChat = false
      GR.GroupType = nil
    end

    if (BSOpponent ~= UnitName("player")) then
      GR.GameType = "Battleships"
      GR:BattleshipsHideContent()  
      GR.Opponent = BSOpponent
      if (TicGroupType == "PART") then TicGroupType = "PARTY" end
      if (string.match(BSPlayerTurn, "2")) then
        GR.PlayerPos = 1
        GR.IsPlayerTurn = true
      else
        GR.PlayerPos = 2
        GR.IsPlayerTurn = false
      end
      GR.db.realm.tab = 1
      GR:TabSelect()
    end
  end
end

function GR:OpponentEndedGame(text)
  -- ends game if opponent ends game
  local TicEndGame = string.sub(text, 0, 17)
  if (string.match(TicEndGame, "TicTacToe_GameEnd")) then
    GR.GameType = nil
    GR:TicTacToeHideContent()
  end
  local BSEndGame = string.sub(text, 0, 19)
  if (string.match(BSEndGame, "Battleships_GameEnd")) then
    GR.GameType = nil
    GR:BattleshipsHideContent()
  end
end

function GR:GameDeclined(text)
  -- game declined
  local TicDecline = string.sub(text, 0, 17)
  if (string.match(TicDecline, "TicTacToe_Decline")) then
    GR.CanSendInvite = true
    GR.Opponent = nil
  end
  local BSDecline = string.sub(text, 0, 19)
  if (string.match(BSDecline, "Battleships_Decline")) then
    GR.CanSendInvite = true
    GR.Opponent = nil
  end
end

function GR:ShowChalOnInvite()
  if (GR.IsChallenged and GR_GUI.Main.Tictactoe:IsVisible() == false and GR_GUI.Main.Battleships:IsVisible() == false) then 
    GR_GUI.Main.Accept:Show()
    GR_GUI.Main.DeclineBtn:Show()
  else
    GR_GUI.Main.Accept:Hide()
    GR_GUI.Main.DeclineBtn:Hide()
  end
end


