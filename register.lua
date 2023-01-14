function GR:CreateRegister()
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
  GR.GroupType = nil
  GR.UseGroupChat = false

  Register = CreateFrame("Frame", Register)
  
  -- listen for party, guild, who changes
  Register:RegisterEvent("GROUP_ROSTER_UPDATE")
  Register:RegisterEvent("WHO_LIST_UPDATE")
  Register:RegisterEvent("GUILD_ROSTER_UPDATE")
  Register:RegisterEvent("PLAYER_ENTERING_WORLD")

  Register:SetScript("OnEvent", function(self, event, ...)
    if (event == "GROUP_ROSTER_UPDATE") then
     GR:GroupRosterUpdate()
    end

    if (event == "WHO_LIST_UPDATE" and GR_GUI.Main:IsVisible()) then
      GR:WhoListUpdate()
    end

    if (event == "GUILD_ROSTER_UPDATE") then
      GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Guild, " .. UnitName("player"), "GUILD")
    end

    -- on login/reload
    if (event == "PLAYER_ENTERING_WORLD") then
      -- on load update friends and group multiplayer invites
      GR:UpdateFriendsList() 
      GR:GroupRosterUpdate() 
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
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. PlayerName, "WHISPER", v)
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
        Friend = x.GetFriendAccountInfo.characterName
        RealmName = x.GetFriendAccountInfo.realmName
        FactionName = x.GetFriendAccountInfo.factionName
      else
        Friend = select(5, BNGetFriendInfo(i))
      end

      if (Friend ~= nil) then
        if (GR.Retail) then
          -- same realm, faction, target matches bnfriend
          if (string.match(v, Friend) and RealmName == select(2, UnitFullName("Player")) and FactionName == select(1, UnitFactionGroup("Player"))) then
            IsConnected = true
          end
        else
          -- target match bnfriend
          if (string.match(v, Friend)) then
            IsConnected = true
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
        GR:SendCommMessage("ZUI_GameRoom_Reg", SerialMessage, "WHISPER", Friend.name)
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
        Friend = x.GetFriendAccountInfo.characterName
        ClientProgram = x.GetFriendAccountInfo.x.GetFriendAccountInfo.clientProgram
        RealmName = x.GetFriendAccountInfo.realmName
        FactionName = x.GetFriendAccountInfo.factionName
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
          if (ClientProgram == "WoW" and RealmName == select(2, UnitFullName("Player")) and FactionName == select(1, UnitFactionGroup("Player"))) then
            GR:SendCommMessage("ZUI_GameRoom_Reg", SerialMessage, "WHISPER", Friend)
          end
        else
          if (ClientProgram == "WoW") then
            GR:SendCommMessage("ZUI_GameRoom_Reg", SerialMessage, "WHISPER", Friend)
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
        GR:SendCommMessage("ZUI_GameRoom_Reg", SerialMessage, "WHISPER", GR.db.realm.Rivals[i])
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
    GR:SendCommMessage("ZUI_GameRoom_Reg", SerialMessage, "WHISPER", V.Sender)
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
          GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Zone, " .. UnitName("player"), "WHISPER", v)
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
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Zone Registered, " .. PlayerName, "WHISPER", Value3)
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

function GR:GroupRosterUpdate()
  GR.Party = {}
  GR:RefreshPartyList()
  -- resends Register Party messages
  local NumOfGroupMembers = GetNumGroupMembers()
  local distribution = ""
  for i = 1, NumOfGroupMembers, 1 do
    local PartyMemberIndex
    if (IsInRaid()) then
      PartyMemberIndex = "raid" .. tostring(i)
      distribution = "RAID"
    else
      PartyMemberIndex = "party" .. tostring(i)
      distribution = "PARTY"
    end
    local PartyMember = GetUnitName(PartyMemberIndex, true)
    local PartyMemberName, PartyMemberRealm = UnitName(PartyMemberIndex)
    local PlayerName, PlayerServer = UnitFullName("player")
    C_Timer.After(1, function() 
      if (type(PartyMember) == "string" and UnitIsConnected(PartyMemberIndex)) then
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, distribution)
      end
    end)
  end
end

function GR:RegisterParty(text, PlayerName, PlayerServer, distribution)
  -- Register Party
  local Action = string.sub(text, 0, 14)
  local Value = string.sub(text, 17, 50)
  if (string.match(Action, "Register Party") or string.match(Action, "Register Guild")) then
    local IsInTable = false
    if (string.match(Value, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Party) do
      if (string.match(v, Value)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then

      table.insert(GR.Party, Value)
      -- set party and guild arrays for whilelist option
      if (string.match(Action, "Register Party")) then
        table.insert(GR.OnlyParty, Value)
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Party Registered, " .. PlayerName, distribution)
      end
      if (string.match(Action, "Register Guild")) then
        table.insert(GR.OnlyGuild, Value)
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Guild Registered, " .. PlayerName, "WHISPER", Value)
      end
    end
    GR:RefreshPartyList()
  end
end

function GR:PartyRegistered(text, PlayerName)
  -- Party Registered
  local Action = string.sub(text, 0, 16)
  local Value = string.sub(text, 19, 50)
  if (string.match(Action, "Party Registered") or string.match(Action, "Guild Registered")) then
    local IsInTable = false
    if (string.match(Value, PlayerName)) then
      IsInTable = true
    end

    for i,v in ipairs(GR.Party) do
      if (string.match(v, Value)) then
        IsInTable = true
      end
    end
    if (IsInTable == false) then
      table.insert(GR.Party, Value)
      -- set party and guild arrays for whilelist option
      if (string.match(Action, "Party Registered")) then
        table.insert(GR.OnlyParty, Value)
      end
      if (string.match(Action, "Guild Registered")) then
        table.insert(GR.OnlyGuild, Value)
      end
    end
    GR:RefreshPartyList()
  end 
end

-- Comms handler
function GR:RegisterPlayers(...)
  local prefix, text, distribution, target = ...
  local PlayerName, PlayerServer = UnitFullName("player")

  GR:RegisterZone(text, PlayerName)
  GR:ZoneRegistered(text, PlayerName)

  GR:RegisterParty(text, PlayerName, PlayerServer, distribution)
  GR:PartyRegistered(text, PlayerName)

  GR:RegisterFriendInviteReceived(text)
  GR:RegisterFriendResponseReceived(text)
end
