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

  -- listen for party changes
  Register:RegisterEvent("GROUP_ROSTER_UPDATE")
  Register:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
  Register:RegisterEvent("FRIENDLIST_UPDATE")
  Register:RegisterEvent("WHO_LIST_UPDATE")
  Register:RegisterEvent("GUILD_ROSTER_UPDATE")
  Register:SetScript("OnEvent", function(self, event, ...)
    if (event == "GROUP_ROSTER_UPDATE") then
     GR:GroupRosterUpdate()
    end

    if (event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_LIST_SIZE_CHANGED") then
      GR:FriendslistUpdate()
      
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

function GR:FriendslistUpdate()
  C_Timer.After(.5, function()
    GR:RemoveFromFriendsList()
    GR:RefreshFriendsList()
  end)
end

function GR:RegisterFriend(text, PlayerName)
  -- Register Friend
  local Action = string.sub(text, 0, 15)
  local Value = string.sub(text, 18, 50)
  if (string.match(Action, "Register Friend")) then
    GR:AddToFriendsList(Value)
    GR:RemoveFromFriendsList()
    GR:RefreshFriendsList()
    GR:SendCommMessage("ZUI_GameRoom_Reg", "Friend Registered, " .. PlayerName, "WHISPER", Value)
  end
end

function GR:FriendRegistered(text)
  -- Friend Registered
  local Action = string.sub(text, 0, 17)
  local Value = string.sub(text, 20, 50)
  if (string.match(Action, "Friend Registered")) then
    GR:AddToFriendsList(Value)
    GR:RemoveFromFriendsList()
    GR:RefreshFriendsList()
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
        GR:SendCommMessage("ZUI_GameRoom_Reg", "Register Party, " .. PlayerName, "PARTY")
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
        print(Value)
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

  GR:RegisterFriend(text, PlayerName)
  GR:FriendRegistered(text)

  GR:RegisterZone(text, PlayerName)
  GR:ZoneRegistered(text, PlayerName)

  GR:RegisterParty(text, PlayerName, PlayerServer, distribution)
  GR:PartyRegistered(text, PlayerName)
end


-- guild can send messages with whisper

-- make bnfriends work cross-server (whispers wont work, needs global channel)
-- classic disable cross-server bnfriends (whispers wont work, no global channel)

-- build global channel for retail

-- register need to worry about cross-server (cant whisper) for raid and party