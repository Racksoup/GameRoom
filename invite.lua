function GR:Invite(...)
  local prefix, text, distribution, target = ...

  GR:IncomingInvite(text, distribution)
  GR:AcceptGameInvite(text, distribution)
  GR:OpponentEndedGame(text, distribution)
  GR:GameDeclined(text, distribution)
end

---
-- Game Invite
-- step 1: Btn Click, Send Invite
function GR:SendGameInvite(self, button, down)
  if (button == "LeftButton" and down == false) then
    -- needs to comm through party/raid chat if cross-server
    local PlayerName, PlayerServer = UnitFullName("player")
    local PartyMemberName, PartyMemberRealm = UnitName(GR.Target)
    local IsCrossServer = false
    local GroupType = "party"
    if IsInRaid() then GroupType = "raid" end
    local IsInParty = false
    local Message = {
      Tag = "",
      Target = GR.Target,
      Sender = UnitName("Player"),
    }

    -- set message tag
    if (GR.GameType == "Battleships") then Message.Tag = "Battleships_Challenge" end
    if (GR.GameType == "Tictactoe") then Message.Tag = "TicTacToe_Challenge" end

    -- unitname works if target is in party/raid. go through party/raid to find if target is in group. then check if they are cross-server. 
    for i = 1, GetNumGroupMembers() -1, 1 do
      local PlayerIndex = GroupType .. tostring(i)
      local PartyMember = UnitName(PlayerIndex)
      if (PartyMember == GR.Target) then 
        if (PartyMemberRealm ~= PlayerServer) then
          IsCrossServer = true
        end
      end
    end

    if (not IsCrossServer) then
      -- send invite
      if (GR.GameType == "Battleships") then
        GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Target)
      end
      if (GR.GameType == "Tictactoe") then
        GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Target)
      end
    else
      -- if target is cross-server they are in a party or raid
      -- check for party or raid for chat channel
      local ChatChannel = "PARTY"
      if IsInRaid() then ChatChannel = "RAID" end
      
      -- send invite
      GR.UseGroupChat = true
      if (GR.GameType == "Battleships") then
        GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
      end
      if (GR.GameType == "Tictactoe") then
        GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
      end
    end
  end
end

-- step 2: Message, Incoming Invite
function GR:IncomingInvite(text, distribution)
  local Main = GR_GUI.Main
  local Accept = GR_GUI.Accept
  local PlayerName, PlayerServer = UnitFullName("player")
  local P, V = GR:Deserialize(text)

  -- if raid/party we need to check that we are the correct receiver
  if (V.Target == "" or V.Target == UnitName("player") or V.Target == PlayerName .. "-" .. PlayerServer) then
    -- if challenge recieved, all challenges not disabled, not in a game
    if ((string.match(V.Tag, "Battleships_Challenge") or string.match(V.Tag, "TicTacToe_Challenge")) and GR.IsChallenged == false and GR.db.realm.disableChallenges == false and GR.InGame == false and Main.Battleships:IsVisible() == false and Main.Tictactoe:IsVisible() == false) then
      -- Check if challenger is allowed to invite player
      local function ChalAllowedInvite()
        local AcceptChal = true
        if (GR.db.realm.onlyWhitelist) then 
          AcceptChal = false
          -- go through whitelist and see if challenger is on list
          for i,v in ipairs(GR.db.realm.Whitelist) do
            if (string.match(v, V.Sender)) then
              AcceptChal = true
            end
          end
          -- if whitelist Friends, go through Friends and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistFriends) then
            for i,v in ipairs(GR.Friends) do
              if (string.match(v, V.Sender)) then
                AcceptChal = true
              end
            end
          end
          -- if whitelist Guild, go through Guild and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistGuild) then
            for i,v in ipairs(GR.Guild) do
              if (string.match(v, V.Sender)) then
                AcceptChal = true
              end
            end
          end
          -- if whitelist Party, go through Party and AcceptChal true if they match the opponent
          if (GR.db.realm.WhitelistParty) then
            for i,v in ipairs(GR.Group) do
              if (string.match(v, V.Sender)) then
                AcceptChal = true
              end
            end
          end
        end
        -- go through Blacklist and see if challenger is on list
        for i,v in ipairs(GR.db.realm.Blacklist) do
          if (string.match(v, V.Sender)) then
            AcceptChal = false
          end
        end
        return AcceptChal
      end

      -- if challenger is allowed to invite player to game
      if (ChalAllowedInvite()) then
        GR.IsChallenged = true
        if (distribution == "PARTY" or distribution == "RAID") then GR.GroupType = distribution end
        
        -- set game variables, strings, opponent
        local GameDisplayName = ""
        if (string.match(V.Tag, "Battleships_Challenge")) then
          GR.GameType = "Battleships"
          GR.IncGameType = "Battleships"
          GameDisplayName = "Battleships"
          Accept.FS2:SetText(V.Sender .. " - " .. GameDisplayName)
          GR.Opponent = V.Sender
        end
        if (string.match(V.Tag, "TicTacToe_Challenge")) then
          GR.GameType = "Tictactoe"
          GR.IncGameType = "Tictactoe"
          GameDisplayName = "Tic-Tac-Toe"
          Accept.FS2:SetText(V.Sender .. " - " .. GameDisplayName)
          GR.Opponent = V.Sender
        end

        -- hides invite (open and closed) after 15 seconds
        C_Timer.After(15, function()
          GR.IsChallenged = false
          Accept:Hide()
        end)
      
        -- if hideincombat selected and in combat, dont show invite
        if (not (GR.db.realm.HideInCombat and InCombatLockdown())) then
          if (GR.db.realm.showChallengeAsMsg == false) then
            -- show main open accept
            Accept:Show()
          else
            -- print invite message
            GR:Print(GR.Opponent .. " has challenged you to play " .. GameDisplayName .. "!")
          end
        end
      end
    end
  end
end

-- step 3: Btn Click, Accept Invite or Decline Invite
function GR:AcceptGameClicked()
  local ChatChannel = "PARTY"
  if (IsInRaid()) then ChatChannel = "RAID" end
  GR.Target = GR.Opponent

  -- randomize player 1 and player 2, set player turn
  GR.PlayerPos = math.random(1,2)
  if (GR.PlayerPos == 1) then
    GR.IsPlayerTurn = true
  else
    GR.IsPlayerTurn = false
  end
  
  local Message = {
    Tag = "",
    Sender = UnitName("Player"),
    Target = GR.Opponent,
    OpponentPos = GR.PlayerPos
  }

  -- send game accept message
  if (GR.IncGameType == "Tictactoe") then
    GR.GameType = "Tictactoe"
    Message.Tag = "TicTacToe_Accept"
    
    if (GR.GroupType == nil) then
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
      GR.UseGroupChat = true
    end
    -- hide and reshowin GR:TabSelect()
    GR:TicTacToeHideContent()
  end
  if (GR.IncGameType == "Battleships") then
    GR.GameType = "Battleships"
    Message.Tag = "Battleships_Accept"
    
    if (GR.GroupType == nil) then
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
      GR.UseGroupChat = true
    end
    -- hide and reshow in GR:TabSelect()
    GR:BattleshipsHideContent() 
  end

  -- show game
  GR.db.realm.tab = "game"
  GR:TabSelect()
end

function GR:DeclineGameClicked()
  GR.IsChallenged = false
  local ChatChannel = "PARTY"
  if (IsInRaid()) then ChatChannel = "RAID" end
  local Message = {
    Tag = "",
    Target = GR.Opponent,
    Sender = UnitName("Player")
  }
  
  -- send decline game message
  if (GR.GameType == "Tictactoe") then
    Message.Tag = "TicTacToe_Decline"
    if (GR.GroupType == nil) then
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
    end
  end 
  if (GR.GameType == "Battleships") then
    Message.Tag = "Battleships_Decline"
    if (GR.GroupType == nil) then
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
    end
  end 

  -- clear variables
  GR.Opponent = nil
end

-- step 4: Message, Game Accepted or Game Declined
function GR:AcceptGameInvite(text, distribution)  
  local P, V = GR:Deserialize(text)

  if (string.match(V.Tag, "TicTacToe_Accept") or string.match(V.Tag, "Battleships_Accept")) then
    -- if sender isn't player and sender is target we sent invite
    if (V.Sender ~= UnitName("player") and V.Target == UnitName("player")) then
      GR.Opponent = V.Sender
      -- set variables if using party/raid chat
      if (distribution == "PARTY" or distribution == "RAID") then
        GR.GroupType = distribution
        GR.UseGroupChat = true
      else 
        GR.GroupType = nil
        GR.UseGroupChat = false
      end

      -- set playerpos
      if (V.OpponentPos == 2) then
        GR.PlayerPos = 1
        GR.IsPlayerTurn = true
      else
        GR.PlayerPos = 2
        GR.IsPlayerTurn = false
      end

      -- hide game, set variable to show game in GR:TabSelect()
      if (string.match(V.Tag, "TicTacToe_Accept")) then
        GR.GameType = "Tictactoe"
        GR:TicTacToeHideContent()  
      end
      if (string.match(V.Tag, "Battleships_Accept")) then
        GR.GameType = "Battleships"
        GR:BattleshipsHideContent()  
      end
      
      -- show game
      GR.db.realm.tab = "game"
      GR:TabSelect()
    end
  end

end

function GR:GameDeclined(text, distribution)
  local P, V = GR:Deserialize(text)
  local Declined = false

  if (string.match(V.Tag, "TicTacToe_Decline") or string.match(V.Tag, "Battleships_Decline")) then
    -- if distribution is not raid/party, register decline
    if (distribution ~= "RAID" and distribution ~= "PARTY") then Declined = true end
    -- if distribution is raid/party and player is the message target, register decline
    if (V.Target == UnitName("Player") and (distribution == "RAID" or distribution == "PARTY")) then
      Declined = true
    end

    -- set variables
    if Decline then
      GR.CanSendInvite = true
      GR.Opponent = nil
    end
  end
end
---


-- Game ended
function GR:ExitGameClicked()
  local Message = {
    Tag = "",
    Target = ""
  }
  local ChatChannel = "PARTY"
  if IsInRaid() then ChatChannel = "RAID" end

  -- Tictactoe
  if (GR.GameType == "Tictactoe") then
    Message.Tag = "TicTacToe_GameEnd"
    if (GR.UseGroupChat) then 
      Message.Target = GR.Opponent
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    end
    GR:TicTacToeEndGame()
  end

  -- Battleship
  if (GR.GameType == "Battleships") then
    Message.Tag = "Battleships_GameEnd"
    if (GR.UseGroupChat) then 
      Message.Target = GR.Opponent
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), ChatChannel)
    else
      GR:SendCommMessage("GameRoom_Inv", GR:Serialize(Message), "WHISPER", GR.Opponent)
    end
    GR:BattleshipsEndGame()
  end

  -- Asteroids
  if (GR.GameType == "Asteroids") then
    GR:AsteroidsHide()    
  end

  -- Snake
  if (GR.GameType == "Snake") then
    GR:SnakeHide()    
  end
  
  -- Bouncy Chicken
  if (GR.GameType == "Bouncy Chicken") then
    GR:BCHide()    
  end

  -- Suika
  if (GR.GameType == "Suika") then
    GR:SuikaHide()    
  end
  
  -- Minesweepers
  if (GR.GameType == "Minesweepers") then
    GR:MinesweepersHide()    
  end

  GR_GUI.Main.ExitBtn:Hide()
  GR.GameType = nil
  GR.db.realm.tab = "solo"
  GR:TabSelect()
end

function GR:OpponentEndedGame(text, distribution)
  local P, V = GR:Deserialize(text)
  -- ends game if opponent ends game
  if P then 
    if (string.match(V.Tag, "TicTacToe_GameEnd") and ((V.Target == "" or V.Target == UnitName("Player")) or (distribution ~= "RAID" and distribution ~= "PARTY"))) then
      GR.GameType = nil
      GR:TicTacToeEndGame()
    end
    if (string.match(V.Tag, "Battleships_GameEnd") and ((V.Target == "" or V.Target == UnitName("Player")) or (distribution ~= "RAID" and distribution ~= "PARTY"))) then
      GR.GameType = nil
      GR:BattleshipsEndGame()
    end
  end 
end
