function GR:CreateInvite()
  GR.Friends = {}
  GR.Zone = {}
  GR.Party = {}
  GR.OnlyParty = {}
  GR.OnlyGuild = {}
  GR.Target = nil
  GR.Opponent = nil
  GR.CanSendInvite = true
  GR.IsChallenged = false
  GR.InGame = false
  GR.GameType = nil
  GR.IncGameType = nil

  GR_GUI.Main.Invite = CreateFrame("Frame", Invite, GR_GUI.Main)
  local Invite = GR_GUI.Main.Invite

  -- listen for party changes
  Invite:RegisterEvent("GROUP_ROSTER_UPDATE")
  Invite:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
  Invite:RegisterEvent("FRIENDLIST_UPDATE")
  Invite:RegisterEvent("WHO_LIST_UPDATE")
  Invite:RegisterEvent("GUILD_ROSTER_UPDATE")
  Invite:SetScript("OnEvent", function(self, event, ...)
    if (event == "GROUP_ROSTER_UPDATE") then
      GR.Party = {}
      GR:RefreshPartyList()
      -- resends Register Party messages
      local NumOfGroupMembers = GetNumGroupMembers()
      local playerInRaid = IsInRaid()
      for i = 1, NumOfGroupMembers, 1 do
        local PartyMemberIndex
        if (not playerInRaid) then 
          PartyMemberIndex = "party" .. tostring(i)
        end
        if (playerInRaid) then
          PartyMemberIndex = "raid" .. tostring(i)
        end
        local PartyMember = GetUnitName(PartyMemberIndex, true)
        local PartyMemberName, PartyMemberRealm = UnitName(PartyMemberIndex)
        local PlayerName, PlayerServer = UnitFullName("player")
        C_Timer.After(1, function() 
          if (type(PartyMember) == "string" and UnitIsConnected(PartyMemberIndex)) then
            if ((PartyMemberRealm == PlayerServer and PlayerServer ~= nil) or PartyMemberRealm == nil) then 
              GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, "PARTY")
              print('same-server, register party')
            else
              GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName .. "-" .. PlayerServer, "PARTY")
              print('cross-server, register party')
            end
          end
        end)
      end
    end

    if (event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_LIST_SIZE_CHANGED") then
      C_Timer.After(.5, function()
        GR:RemoveFromFriendsList()
        GR:RefreshFriendsList()
      end)
    end

    if (event == "WHO_LIST_UPDATE" and GR_GUI.Main:IsVisible()) then
      C_Timer.After(.6, function() 
        local NumWhos, TotalNumWhos = C_FriendList.GetNumWhoResults()
        for i = 1, NumWhos, 1 do
          local WhoPlayer = C_FriendList.GetWhoInfo(i)
          for j,v in pairs(WhoPlayer) do
            if (string.match(j, "fullName") and not string.match(v, UnitName("player"))) then
              local PlayerName  = UnitName("player")
              GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. PlayerName, "WHISPER", v)
            end
          end
        end
      end) 
    end

    if (event == "GUILD_ROSTER_UPDATE") then
      GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Guild, " .. UnitName("player"), "GUILD")
    end
  end)
end

-- Friends
function GR:RegisterFriends()
  local PlayerName = UnitName("player")
  local NumFriends = C_FriendList.GetNumFriends()
  if (type(NumFriends) == "number") then
    for i = 1, NumFriends, 1 do
      local IsInFriends = false
      local OGFriend = C_FriendList.GetFriendInfoByIndex(i)
      
      if (GR.Friends == nil) then
        GR.Friends = {}
      end

      for j,v in ipairs(GR.Friends) do
        if (v == OGFriend.name and OGFriend.connected) then
          IsInFriends = true
        end
        if (v == OGFriend.name and not OGFriend.connected) then
          IsInFriends = true
          GR:RemoveFromFriendsList()
        end
      end

      if (IsInFriends == false and OGFriend.connected) then
        print('register friend, normal friend')
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", OGFriend.name)
      end
    end
  end
  -- add battle.net account friends
  if (BNConnected() and GR.db.realm.showBN) then
    local NumBNFriends = BNGetNumFriends()
    if (type(NumBNFriends) == "number") then
      for i = 1, NumBNFriends, 1 do
        local IsInFriends = false
        if (GR.Retail) then 
          local Character = select(5, C_BattleNet.GetFriendAccountInfo(i))
          local Client = select(7, C_BattleNet.GetFriendAccountInfo(i))
        else
          local Character = select(5, BNGetFriendInfo(i))
          local Client = select(7, BNGetFriendInfo(i))
        end
        for j,v in ipairs(GR.Friends) do
          if (v == Character) then
            IsInFriends = true
          end
        end
        if (Client == "WoW" and type(Character) == "string" and IsInFriends == false) then
          print('register friend, BN friend')
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", Character)
        end
      end
    end
  end 
  -- add rivals
  for i,v in ipairs(GR.db.realm.Rivals) do
    print('register friend, rival')
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Friend, " .. PlayerName, "WHISPER", v)
  end
end

function GR:RefreshFriendsList()
  local Btns = GR_GUI.Main.Tab3.Invite.Friends.Btns
  for i = 1, 100, 1 do
    Btns[i]:Hide()
  end

  for i,v in ipairs(GR.Friends) do
    Btns[i].FS:SetText(v)
    Btns[i]:Show()
    Btns[i]:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then
        GR.Target = v
        GR_GUI.Main.Tab3.Invite.SendBtn.FS:SetText("Invite " .. GR.Target)
        GR_GUI.Main.Tab3.Invite.SendBtn:Show()
      end
    end)
  end

end

function GR:RemoveFromFriendsList()
  -- remove old friends
  local NumBNFriends = BNGetNumFriends()
  local NumFriends = C_FriendList.GetNumFriends()
  for i,v in ipairs(GR.Friends) do
    local IsInFriendList = false
    if (GR.db.realm.showBN) then
      for j = 1, NumBNFriends, 1 do
        if (GR.Retail) then 
          local Friend = select(5, C_BattleNet.GetFriendAccountInfo(j))
        else
          local Friend = select(5,BNGetFriendInfo(j))
        end
        if (type(Friend) == "string") then
          if (string.match(v, Friend)) then
            IsInFriendList = true
          end
        end
      end
    end
    -- remove all BNFriends
    if (GR.db.realm.showBN == false) then
      for j = 1, NumBNFriends, 1 do
        if (GR.Retail) then 
          local Friend = select(5, C_BattleNet.GetFriendAccountInfo(j))
        else
          local Friend = select(5,BNGetFriendInfo(j))
        end
        if (type(Friend) == "string") then
          if (string.match(v, Friend)) then
            IsInFriendList = false
          end
        end
      end
    end
    -- add from normal friends list after BNFriends dealt with
    for j = 1, NumFriends, 1 do
      local Friend = C_FriendList.GetFriendInfoByIndex(j)
      if (string.match(v, Friend.name) and Friend.connected) then
        IsInFriendList = true
      end
    end
    for j,k in ipairs(GR.db.realm.Rivals) do
      if (string.match(v, k)) then
        IsInFriendList = true
      end
    end
    if (IsInFriendList == false) then
      table.remove(GR.Friends, i)
    end
  end
end

function GR:AddToFriendsList(Value)
  local IsInTable = false
  for i,v in ipairs(GR.Friends) do
    if (string.match(v, Value)) then
      IsInTable = true
    end
  end
  if (IsInTable == false) then
    table.insert(GR.Friends, Value)
  end
end

-- Zone
function GR:RefreshZoneList()
    local Btns = GR_GUI.Main.Tab3.Invite.Zone.Btns
    for i = 1, 100, 1 do
      Btns[i]:Hide()
    end
    
    for i,v in ipairs(GR.Zone) do
      Btns[i].FS:SetText(v)
      Btns[i]:Show()
      Btns[i]:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then
          GR.Target = v
          GR_GUI.Main.Tab3.Invite.SendBtn.FS:SetText("Invite " .. GR.Target)
          GR_GUI.Main.Tab3.Invite.SendBtn:Show()
        end
      end)
    end 
end

function GR:InviteSearchZone()
  local ZoneText = GetZoneText()
  local z = 'z-"' .. ZoneText .. '"'
  C_FriendList.SetWhoToUi(true)
  GR.Zone = {}
  C_FriendList.SendWho(z)
  C_Timer.After(.6, function() 
    local NumWhos, TotalNumWhos = C_FriendList.GetNumWhoResults()
    for i = 1, NumWhos, 1 do
      local WhoPlayer = C_FriendList.GetWhoInfo(i)
      for j,v in pairs(WhoPlayer) do
        if (string.match(j, "fullName") and not string.match(v, UnitName("player"))) then
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. UnitName("player"), "WHISPER", v)
        end
      end
    end
  end) 
end

-- Party
function GR:RefreshPartyList()
  local Btns = GR_GUI.Main.Tab3.Invite.Party.Btns
  for i = 1, 100, 1 do
    Btns[i]:Hide()
  end
  
  for i,v in ipairs(GR.Party) do
    Btns[i].FS:SetText(v)
    Btns[i]:Show()
    Btns[i]:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then
        GR.Target = v
        GR_GUI.Main.Tab3.Invite.SendBtn.FS:SetText("Invite " .. GR.Target)
        GR_GUI.Main.Tab3.Invite.SendBtn:Show()
      end
    end)
  end
end

function GR:RegisterPlayers(...)
  local prefix, text, distribution, target = ...
  local PlayerName, PlayerServer = UnitFullName("player")
  print(text)

  -- Register Friend
  local Action1 = string.sub(text, 0, 15)
  local Value1 = string.sub(text, 18, 50)
  if (string.match(Action1, "Register Friend")) then
    GR:AddToFriendsList(Value1)
    GR:RemoveFromFriendsList()
    GR:RefreshFriendsList()
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Friend Registered, " .. PlayerName, "WHISPER", Value1)
  end
  -- Friend Registered
  local Action2 = string.sub(text, 0, 17)
  local Value2 = string.sub(text, 20, 50)
  if (string.match(Action2, "Friend Registered")) then
    GR:AddToFriendsList(Value2)
    GR:RemoveFromFriendsList()
    GR:RefreshFriendsList()
  end 


  -- Register Zone
  local Action3 = string.sub(text, 0, 13)
  local Value3 = string.sub(text, 16, 50)
  if (string.match(Action3, "Register Zone")) then
    local IsInTable = false
    if (string.match(Value3, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Zone) do
      if (string.match(v, Value3)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then
      table.insert(GR.Zone, Value3)
    end
    GR:RefreshZoneList()
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Zone Registered, " .. PlayerName, "WHISPER", Value3)
  end
  -- Zone Registered
  local Action4 = string.sub(text, 0, 15)
  local Value4 = string.sub(text, 18, 50)
  if (string.match(Action4, "Zone Registered")) then
    local IsInTable = false
    if (string.match(Value4, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Zone) do
      if (string.match(v, Value4)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then
      table.insert(GR.Zone, Value4)
    end
    GR:RefreshZoneList()
  end 


  -- Register Party
  local Action5 = string.sub(text, 0, 14)
  local Value5 = string.sub(text, 17, 50)
  if (string.match(Action5, "Register Party") or string.match(Action5, "Register Guild")) then
    local IsInTable = false
    if (string.match(Value5, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Party) do
      if (string.match(v, Value5)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then

      -- check if server name is appended
      local IsCrossServer = false
      if (string.match(Value5, ".-")) then IsCrossServer = true end

      table.insert(GR.Party, Value5)
      -- set party and guild arrays for whilelist option
      if (string.match(Action5, "Register Party")) then
        print(Value5)
        table.insert(GR.OnlyParty, Value5)
        if (IsCrossServer) then
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Party Registered, " .. PlayerName .. PlayerServer, distribution)
        else
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Party Registered, " .. PlayerName, "WHISPER", Value5)
        end
      end
      if (string.match(Action5, "Register Guild")) then
        table.insert(GR.OnlyGuild, Value5)
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Guild Registered, " .. PlayerName, "WHISPER", Value5)
      end
    end
    GR:RefreshPartyList()
  end

  -- Party Registered
  local Action6 = string.sub(text, 0, 16)
  local Value6 = string.sub(text, 19, 50)
  if (string.match(Action6, "Party Registered") or string.match(Action6, "Guild Registered")) then
    local IsInTable = false
    if (string.match(Value6, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Party) do
      if (string.match(v, Value6)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then
      table.insert(GR.Party, Value6)
      -- set party and guild arrays for whilelist option
      if (string.match(Action5, "Party Registered")) then
        table.insert(GR.OnlyParty, Value5)
      end
      if (string.match(Action5, "Guild Registered")) then
        table.insert(GR.OnlyGuild, Value5)
      end
    end
    GR:RefreshPartyList()
  end 
end

function GR:ShowChallengeIfChallenged()
  if (GR.IsChallenged and GR_GUI.Main.Tictactoe:IsVisible() == false and GR_GUI.Main.Battleships:IsVisible() == false) then 
    GR_GUI.Main.Accept:Show()
    GR_GUI.Main.DeclineBtn:Show()
  else
    GR_GUI.Main.Accept:Hide()
    GR_GUI.Main.DeclineBtn:Hide()
  end
end

function GR:AcceptDeclineChal(...)
  local prefix, text, distribution, target = ...
  local Main = GR_GUI.Main
  local Accept = GR_GUI.Accept

  -- registers incoming challenge
  local TicChallenge = string.sub(text, 0, 19)
  local BSChallenge = string.sub(text, 0, 21)
  local TicOpponent = string.sub(text, 22, 50)
  local BSOpponent = string.sub(text, 24, 50)
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
        GR.IsChallenged = true
        C_Timer.After(15, function()
          GR.IsChallenged = false
          GR:ShowChallengeIfChallenged()
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
  
  -- registers challenge accepted, shows game board. sender shows board on accept click
  local TicAccept = string.sub(text, 0, 16)
  local TicPlayerTurn = string.sub(text, 19, 19)
  local TicOpponent = string.sub(text, 22, 50)
  if (string.match(TicAccept, "TicTacToe_Accept")) then
    GR.GameType = "Tictactoe"
    GR:TicTacToeHideContent()  
    GR.Opponent = TicOpponent
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
  local BSAccept = string.sub(text, 0, 18)
  local BSPlayerTurn = string.sub(text, 21, 21)
  local BSOpponent = string.sub(text, 24, 50)
  if (string.match(BSAccept, "Battleships_Accept")) then
    GR.GameType = "Battleships"
    GR:BattleshipsHideContent()  
    GR.Opponent = BSOpponent
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

-- who invites work

-- guild can send messages with whisper
-- raid and party need to send game-comm through raid and party channels

-- make bnfriends work cross-server (whispers wont work, needs global channel)
-- classic disable cross-server bnfriends (whispers wont work, no global channel)

-- build global channel for retail

-- invites need to worry about cross-server (cant whisper) for raid and party
