function GR:CreateRegister()
  GR.Friends = {}
  GR.Zone = {}
  GR.Group = {}
  GR.Guild = {}
  GR.Server = {}
  GR.Target = nil
  GR.Opponent = nil
  GR.CanSendInvite = true
  GR.IsChallenged = false
  GR.InGame = false
  GR.GameType = nil
  GR.IncGameType = nil
  GR.GroupType = nil
  GR.UseGroupChat = false

  Register = CreateFrame("Frame", Register)
  
  -- listen for party, guild, who changes
  Register:RegisterEvent("GROUP_LEFT")
  Register:RegisterEvent("FRIENDLIST_UPDATE")
  Register:RegisterEvent("BN_FRIEND_INFO_CHANGED")
  Register:RegisterEvent("GROUP_JOINED")
  Register:RegisterEvent("GROUP_FORMED")
  Register:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
  Register:RegisterEvent("GROUP_ROSTER_UPDATE")
  Register:RegisterEvent("WHO_LIST_UPDATE")
  Register:RegisterEvent("GUILD_ROSTER_UPDATE")
  Register:RegisterEvent("PLAYER_ENTERING_WORLD")
  Register:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
  Register:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")


  Register:SetScript("OnEvent", function(self, event, ...)
    if (event == "CHAT_MSG_CHANNEL_JOIN") then
      local text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons = ...
      if (channelBaseName == 'gameroom') then
        GR:RegisterServerInviteReceived(playerName)
      end
    end

    if (event == "CHAT_MSG_CHANNEL_LEAVE") then
      local text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons = ...
      if (channelBaseName == 'gameroom') then
        GR:LeaveGRChannel(playerName)
      end
    end
    
    if (event == "WHO_LIST_UPDATE" and GR_GUI.Main:IsVisible()) then
      GR:WhoListUpdate()
    end
    
    if (event == "GROUP_LEFT") then
      GR.Group = {}
      GR:RefreshGuildGroupListUI()
    end
    
    -- removes offline friends
    if (event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_INFO_CHANGED") then
      GR:RemoveDisconnectedFromFriendsList()
      GR:RefreshFriendsListUI()
    end
      
    -- register group send invite
    if (event == "GROUP_JOINED" or event == "GROUP_FORMED") then
      local GroupDist
      if (IsInInstance()) then
        GroupDist = "INSTANCE_CHAT"
      else
        if (IsInRaid()) then
          GroupDist = "RAID"
        else
          GroupDist = "PARTY"
        end
      end
      local GroupMessage = {
        Tag = "Register Group Invite",
        Sender = UnitName("Player")
      }
      GR:SendCommMessage("GameRoom_Reg", GR:Serialize(GroupMessage), GroupDist) 
    end
    
    if (event == "GROUP_ROSTER_UPDATE" or event == "GROUP_ROSTER_UPDATE") then
      GR:CheckRemoveGroup()
    end

    -- on login/reload
    if (event == "PLAYER_ENTERING_WORLD") then
      -- register server
      GR:JoinGRChannel()

      -- register friends
      GR:UpdateFriendsList() 

      -- register guild send invite
      if IsInGuild() then
        local GuildMessage = {
          Tag = "Register Guild Invite",
          Sender = UnitName("Player")
        }
        GR:SendCommMessage("GameRoom_Reg", GR:Serialize(GuildMessage), "GUILD") 
      end

      -- register group send invite
      local GroupDist
      if (IsInInstance()) then
        GroupDist = "INSTANCE_CHAT"
      else
        if (IsInRaid()) then
          GroupDist = "RAID"
        else
          GroupDist = "PARTY"
        end
      end
      local GroupMessage = {
        Tag = "Register Group Invite",
        Sender = UnitName("Player")
      }
      GR:SendCommMessage("GameRoom_Reg", GR:Serialize(GroupMessage), GroupDist) 
    end
  end)
end

function GR:WhoListUpdate()
  C_Timer.After(.6, function() 
    local NumWhos, TotalNumWhos = C_FriendList.GetNumWhoResults()
    for i = 1, NumWhos, 1 do
      local WhoPlayer = C_FriendList.GetWhoInfo(i)
      for j,v in pairs(WhoPlayer) do
        if (string.match(j, "fullName") and not string.match(v, UnitName("player"))) then
          local PlayerName  = UnitName("player")
          GR:SendCommMessage("GameRoom_Reg", "Register Zone, " .. PlayerName, "WHISPER", v)
        end
      end
    end
  end) 
end

-- Friends
function GR:RefreshFriendsListUI()
  local Btns = GR_GUI.Main.Tab3.Invite.Friends.Btns
  for i = 1, 100, 1 do
    Btns[i]:Hide()
  end

  -- change script and text on button 
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

function GR:UpdateFriends5Seconds()
  -- update friends every 5 seconds
  GR:UpdateFriendsList()
  if (GR_GUI.Main:IsVisible()) then
    C_Timer.After(5, function()
      GR:UpdateFriends5Seconds()
    end)
  end
end

function GR:UpdateFriendsList()
  GR:RemoveDisconnectedFromFriendsList()
  GR:AddToFriendsList()
  GR:RefreshFriendsListUI()
end

function GR:RemoveDisconnectedFromFriendsList()
  -- go through all players in friend list
  for i,v in ipairs(GR.Friends) do
    local IsConnected = false

    -- check target against friendslist
    for j = 1, C_FriendList.GetNumFriends(), 1 do
      local Friend = C_FriendList.GetFriendInfoByIndex(j)
      if (string.match(v, Friend.name) and Friend.connected) then
        IsConnected = true
      end
    end

    -- check target against bnfriendslist
    for j = 1, select(1, BNGetNumFriends()), 1 do
      local Friend
      local RealmName
      local FactionName
      if (GR.Retail) then 
        local x = C_BattleNet.GetFriendAccountInfo(i)
        if (x) then
          Friend = x.gameAccountInfo.characterName
          RealmName = x.gameAccountInfo.realmName
          FactionName = x.gameAccountInfo.factionName
        end
      else
        Friend = select(5, BNGetFriendInfo(i))
      end
      
      if (Friend ~= nil) then
        if (GR.Retail) then
          -- same realm, faction, target matches bnfriend
          if (FactionName ~= nil) then
            if (string.match(v, Friend) and string.match(RealmName, select(2, UnitFullName("Player"))) and string.match(FactionName, select(2, UnitFactionGroup("Player")))) then
              IsConnected = true
            end
          end
        else
          -- target match bnfriend
          if (Friend ~= nil) then
            if (string.match(v, Friend)) then
              IsConnected = true
            end
          end
        end
      end
    end
    
    -- no way to check random player is online. needs message/response to check if online. will do one day
    -- if in rivals pass
    for j,k in ipairs(GR.db.realm.Rivals) do
      if (string.match(v, k)) then
        IsConnected = true
      end
    end

    -- if target not connected, remove target
    if (not IsConnected) then
      table.remove(GR.Friends, i)
    end
  end
end

function GR:RemoveDuplicatesFromFriendsList()
  for i = 1, #GR.Friends, 1 do
    for j = 1, #GR.Friends, 1 do
      if (GR.Friends[j] ~= nil and GR.Friends[i] ~= nil) then
        if (string.match(GR.Friends[i], GR.Friends[j]) and i ~= j) then
          table.remove(GR.Friends, j)
          j = j - 1
        end
      end
    end
  end
end 

function GR:AddToFriendsList()
  local Message = {
    Tag = "Register Friend Invite",
    Sender = UnitName("Player")
  }
  local SerialMessage = GR:Serialize(Message) 

  -- if target from friendslist is not in friends, send add to friends comms
  for i = 1, C_FriendList.GetNumFriends(), 1 do
    local InFriends = false
    local Friend = C_FriendList.GetFriendInfoByIndex(i)
    for j,v in ipairs(GR.Friends) do
      if (string.match(v, Friend.name)) then
        InFriends = true
        return 
      end
    end

    -- Friendlist target not found in GR.Friends
    if (not InFriends and Friend.connected) then
        GR:SendCommMessage("GameRoom_Reg", SerialMessage, "WHISPER", Friend.name)
    end
  end
  
  -- if target from bnfriendslist is not in friends, send add to friends comms
  if (GR.db.realm.showBN) then 
    for i = 1, select(1, BNGetNumFriends()), 1 do
      local InFriends = false
      local Friend
      local ClientProgram
      local RealmName
      local FactionName
      if (GR.Retail) then 
        local x = C_BattleNet.GetFriendAccountInfo(i)
        if (x ~= nil) then
          Friend = x.gameAccountInfo.characterName
          ClientProgram = x.gameAccountInfo.clientProgram
          RealmName = x.gameAccountInfo.realmName
          FactionName = x.gameAccountInfo.factionName
        end
      else
        Friend = select(5, BNGetFriendInfo(i))
        ClientProgram = select(7, BNGetFriendInfo(i))
      end
      for j,v in ipairs(GR.Friends) do
        if (Friend ~= nil) then
          if (string.match(v, Friend)) then
            InFriends = true
            return
          end
        end
      end
      
      -- BNFriendlist target not found in GR.Friends
      if (not InFriends) then
        -- if connected same realm same faction

        if (GR.Retail) then
          if (FactionName ~= nil and ClientProgram ~= nil and RealmName ~= nil) then
            if (string.match(ClientProgram, "WoW") and string.match(RealmName, select(2, UnitFullName("Player"))) and string.match(FactionName, select(2, UnitFactionGroup("Player")))) then
              GR:SendCommMessage("GameRoom_Reg", SerialMessage, "WHISPER", Friend)
            end
          end
        else
          if (ClientProgram ~= nil) then
            if (string.match(ClientProgram, "WoW")) then
              GR:SendCommMessage("GameRoom_Reg", SerialMessage, "WHISPER", Friend)
            end
          end
        end
      end
    end
  end
  
  -- if target from rivals is not in friends, send add to friends comms
  if (GR.db.realm.Rivals ~= nil) then
    for i = 1, #GR.db.realm.Rivals, 1 do
      local InFriends = false
      for j,v in ipairs(GR.Friends) do
        if (GR.db.realm.Rivals[i] == v) then
          InFriends = true
          return
        end
      end

      -- if rival not found in GR.Friends
      if (not InFriends) then
        GR:SendCommMessage("GameRoom_Reg", SerialMessage, "WHISPER", GR.db.realm.Rivals[i])
      end
    end
  end

end

function GR:RegisterFriendInviteReceived(text)
  local P,V = GR:Deserialize(text)
  
  if P and string.match(V.Tag, "Register Friend Invite") then
    -- add to list
    table.insert(GR.Friends, V.Sender)
    GR:RemoveDuplicatesFromFriendsList()
    GR:RefreshFriendsListUI()
    
    -- respond
    local Message = {
      Tag = "Register Friend Response",
      Sender = UnitName("Player")
    }
    local SerialMessage = GR:Serialize(Message) 
    GR:SendCommMessage("GameRoom_Reg", SerialMessage, "WHISPER", V.Sender)
  end
end

function GR:RegisterFriendResponseReceived(text)
  local P,V = GR:Deserialize(text)
  
  if P and string.match(V.Tag, "Register Friend Response") then
    table.insert(GR.Friends, V.Sender)
    GR:RemoveDuplicatesFromFriendsList()
    GR:RefreshFriendsListUI()
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
          GR:SendCommMessage("GameRoom_Reg", "Register Zone, " .. UnitName("player"), "WHISPER", v)
        end
      end
    end
  end) 
end

function GR:RegisterZone(text, PlayerName)
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
    GR:SendCommMessage("GameRoom_Reg", "Zone Registered, " .. PlayerName, "WHISPER", Value3)
  end
end

function GR:ZoneRegistered(text, PlayerName)
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
end

-- Group
function GR:RegisterGroupInviteReceived(text)
  local P,V = GR:Deserialize(text)

  if P then 
    local Message = {
      Tag = "Register Group Response",
      Sender = UnitName("Player"),
      Target = V.Sender
    }
    local Dist
    if (IsInInstance()) then
      Dist = "INSTANCE_CHAT"
    else
      if (IsInRaid()) then
        Dist = "RAID"
      else
        Dist = "PARTY"
      end
    end
  
    if (string.match(V.Tag, "Register Group Invite") and not string.match(V.Sender, UnitName("Player"))) then
      table.insert(GR.Group, V.Sender)
      GR:RemoveDuplicates(GR.Group)
      GR:RefreshGuildGroupListUI()
      GR:SendCommMessage("GameRoom_Reg", GR:Serialize(Message), Dist)
    end
  end
end

function GR:RegisterGroupResponseReceived(text)
  local P,V = GR:Deserialize(text)
  
  if P then 
    if (string.match(V.Tag, "Register Group Response") and string.match(V.Target, UnitName("Player")) and not string.match(V.Sender, UnitName("Player"))) then
      table.insert(GR.Group, V.Sender)
      GR:RemoveDuplicates(GR.Group)
      GR:RefreshGuildGroupListUI()
    end
  end
end

function GR:CheckRemoveGroup()
  for i = 1, #GR.Group, 1 do
    if (UnitName(GR.Group[i]) == nil) then
      table.remove(GR.Group, i)
      GR:RefreshGuildGroupListUI()
    end
  end
end


-- Guild
function GR:RegisterGuildInviteReceived(text)
  local P,V = GR:Deserialize(text)
  local Message = {
    Tag = "Register Guild Response",
    Sender = UnitName("Player")
  }

  if P then 
    if (string.match(V.Tag, "Register Guild Invite") and not string.match(V.Sender, UnitName("Player"))) then
      table.insert(GR.Guild, V.Sender)
      GR:RemoveDuplicates(GR.Guild)
      GR:RefreshGuildGroupListUI()
      GR:SendCommMessage("GameRoom_Reg", GR:Serialize(Message), "WHISPER", V.Sender)
    end
  end
end

function GR:RegisterGuildResponseReceived(text)
  local P,V = GR:Deserialize(text)
  
  if P then 
    if (string.match(V.Tag, "Register Guild Response") and not string.match(V.Sender, UnitName("Player"))) then
      table.insert(GR.Guild, V.Sender)
      GR:RemoveDuplicates(GR.Guild)
      GR:RefreshGuildGroupListUI()
    end
  end
end

function GR:CheckRemoveGuild()
  for i = 1, GetNumGuildMembers(), 1 do
    local Name = select(1, GetGuildRosterInfo(i))
    local Online = select(1, GetGuildRosterInfo(i))

    if (Name ~= nil) then
      Name = string.match(Name, "(.*)\\-")

      for j = 1, #GR.Guild, 1 do
        if (string.match(Name, GR.Guild[j]) and not Online) then
          table.remove(GR.Guild, j)
        end
      end
    end
  end
end

-- Guild + Group
function GR:RefreshGuildGroupListUI()
  local Btns = GR_GUI.Main.Tab3.Invite.Party.Btns
  -- reset buttons
  for i = 1, 100, 1 do
    Btns[i]:Hide()
  end
  
  local JoinedList = {}
  -- go through both group and guild lists
  for i = 1, #GR.Group + #GR.Guild, 1 do
    local List = GR.Guild
    local RestartIndexForList2 = 0
    -- if done with first list grab second list
    if (#GR.Guild < i) then
      List = GR.Group
      RestartIndexForList2 = #GR.Guild
    end

    -- add to list item to JoinedList 
    table.insert(JoinedList, List[i - RestartIndexForList2])  
  end
  
  GR:RemoveDuplicates(JoinedList)

  -- set text and set buttons
  for i = 1, #JoinedList, 1 do 
    Btns[i].FS:SetText(JoinedList[i])
    Btns[i]:Show()
    Btns[i]:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then
        GR.Target = JoinedList[i]
        GR_GUI.Main.Tab3.Invite.SendBtn.FS:SetText("Invite " .. GR.Target)
        GR_GUI.Main.Tab3.Invite.SendBtn:Show()
      end
    end)
  end
end

function GR:RemoveDuplicates(list)
  for i = 1, #list, 1 do
    for j = 1, #list, 1 do
      if (list[i] ~= nil and list[j] ~= nil) then
        if (string.match(list[i], list[j]) and i ~= j) then
          table.remove(list, j)
          j = j - 1
        end
      end
    end
  end
end

-- Server 
function GR:JoinGRChannel()
  LeaveChannelByName("gameroom");  
  local delay = 3
  C_Timer.After(delay, function()
    JoinChannelByName("gameroom", "gameroompw");
    local tempChannelNum = 1 
    for i,v in ipairs({GetChannelList()}) do
      if (type(v) == 'number') then
        tempChannelNum = v
      end
      if (type(v) == 'string' and v == 'gameroom') then
        GR.ChannelNumber = tempChannelNum
        break
      end
    end    
    ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, 'gameroom')
  end)
end

function GR:LeaveGRChannel(player)
  for i,v in ipairs(GR.Server) do
    if (v == player) then
      table.remove(GR.Server, i)
    end
  end
  GR:RefreshServerListUI()
end

function GR:RegisterServerInviteReceived(sender)
  local Message = {
    Tag = "Register Server Response",
    Sender = UnitName("Player")
  }

  table.insert(GR.Server, sender)
  GR:RefreshServerListUI()
  GR:SendCommMessage("GameRoom_Reg", GR:Serialize(Message), "WHISPER", sender)
end

function GR:RegisterServerResponseReceived(text)
  local P,V = GR:Deserialize(text)
  
  if P then 
    if (string.match(V.Tag, "Register Server Response") and not string.match(V.Sender, UnitName("Player"))) then
      table.insert(GR.Server, V.Sender)
      GR:RefreshServerListUI()
    end
  end
end

function GR:RefreshServerListUI()
  local Btns = GR_GUI.Main.Tab3.Invite.Server.Btns
  for i = 1, 100, 1 do
    Btns[i]:Hide()
  end

  GR:RemoveDuplicates(GR.Server)
  
  for i,v in ipairs(GR.Server) do
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

-- Comms handler
function GR:RegisterPlayers(...)
  local prefix, text, distribution, target = ...
  local PlayerName, PlayerServer = UnitFullName("player")

  GR:RegisterZone(text, PlayerName)
  GR:ZoneRegistered(text, PlayerName)

  GR:RegisterGuildInviteReceived(text)
  GR:RegisterGuildResponseReceived(text)

  GR:RegisterGroupInviteReceived(text)
  GR:RegisterGroupResponseReceived(text)

  GR:RegisterFriendInviteReceived(text)
  GR:RegisterFriendResponseReceived(text)

  GR:RegisterServerResponseReceived(text)
end
