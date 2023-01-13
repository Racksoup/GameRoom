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

  GR_GUI.Main.Register = CreateFrame("Frame", Register, GR_GUI.Main)
  local Register = GR_GUI.Main.Register

  -- listen for party, guild, who changes
  Register:RegisterEvent("GROUP_ROSTER_UPDATE")
  Register:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
  Register:RegisterEvent("FRIENDLIST_UPDATE")
  Register:RegisterEvent("WHO_LIST_UPDATE")
  Register:RegisterEvent("GUILD_ROSTER_UPDATE")
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
  GR:RemoveFromFriendsListx()
  GR:AddToFriendsListx()
  GR:RefreshFriendsListUI()
end

function GR:RemoveFromFriendsListx()
  -- go through all players in friend list
  for i,v in ipairs(GR.Friends) do
    local IsConnected = false

    -- check target against friendslist
    for j = 1, C_FriendList.GetNumFriends(), 1 do
      local Friend = C_FriendList.GetFriendInfoByIndex(j)
      if (string.match(v, Friend.name) and Friend.connected) then
        IsConnected = True
      end
    end

    -- check target against bnfriendslist
    for j = 1, select(1, BNGetNumFriends()), 1 do
      if (GR.Retail) then 
        local Friend = C_BattleNet.GetFriendAccountInfo(j)

        -- same realm, faction, target matches bnfriend
        if (Friend.gameAccountInfo.characterName ~= nil) then
          if (string.match(v, Friend.gameAccountInfo.characterName) and Friend.gameAccountInfo.realmName == select(2, UnitFullName("Player")) and Friend.gameAccountInfo.factionName == select(1, UnitFactionGroup("Player"))) then
            IsConnected = True
          end
        end
      else
        local Friend = BNGetFriendInfo(j)
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

function GR:AddToFriendsListx()
  -- if target from friendslist is not in friends, add to friends
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
    if (not InFriends) then
      table.insert(GR.Friends, Friend.name)
    end
  end
  
  -- if target from bnfriendslist is not in friends, add to friends
  for i = 1, select(1, BNGetNumFriends()), 1 do
    local InFriends = false
    local Friend = C_BattleNet.GetFriendAccountInfo(i)
    for j,v in ipairs(GR.Friends) do
      if (Friend.gameAccountInfo.characterName ~= nil) then
        if (string.match(v, Friend.gameAccountInfo.characterName)) then
          InFriends = true
          return
        end
      end
    end
    
    -- BNFriendlist target not found in GR.Friends
    if (not InFriends) then
      -- if connected same realm same faction

      if (Friend.gameAccountInfo.clientProgram == "WoW" and Friend.gameAccountInfo.realmName == select(2, UnitFullName("Player")) and Friend.gameAccountInfo.factionName == select(1, UnitFactionGroup("Player"))) then
        table.insert(GR.Friends, Friend.gameAccountInfo.characterName)
      end
    end
  end
  
  -- if target from rivals is not in friends, add to friends
  if (GR.Rivals ~= nil) then
    for i = 1, #GR.Rivals, 1 do
      local InFriends = false
      for j,v in ipairs(GR.Friends) do
        if (GR.Rivals[i] == v) then
          InFriends = true
          return
        end
      end

      -- if rival not found in GR.Friends
      if (not InFriends) then
        table.insert(GR.Friends, GR.Rivals[i])
      end
    end
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
      distribution = "INSTANCE_CHAT"
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
end




-- can get event from friends list login/out, cant get one from bnfriendslist login/out
-- will not run on event
-- will check friends and bnfriends every five seconds to see if add or delete required