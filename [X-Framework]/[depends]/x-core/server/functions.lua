XCore.Functions = {}

XCore.Functions.ExecuteSql = function(wait, query, cb)
	local rtndata = {}
	local waiting = true
	exports['ghmattimysql']:execute(query, {}, function(data)
		if cb ~= nil and wait == false then
			cb(data)
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata)
		end
	end
	return rtndata
end

XCore.Functions.GetEntityCoords = function(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        a = heading
    }
end

XCore.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~=nil and idtype or XConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

XCore.Functions.GetSource = function(identifier)
	for src, player in pairs(XCore.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

XCore.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return XCore.Players[source]
	else
		return XCore.Players[XCore.Functions.GetSource(source)]
	end
end

XCore.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(XCore.Players) do
		local cid = citizenid
		if XCore.Players[src].PlayerData.citizenid == cid then
			return XCore.Players[src]
		end
	end
	return nil
end

XCore.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(XCore.Players) do
		local cid = citizenid
		if XCore.Players[src].PlayerData.charinfo.phone == number then
			return XCore.Players[src]
		end
	end
	return nil
end

XCore.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(XCore.Players) do
		table.insert(sources, k)
	end
	return sources
end

XCore.Functions.CreateCallback = function(name, cb)
	XCore.ServerCallbacks[name] = cb
end

XCore.Functions.TriggerCallback = function(name, source, cb, ...)
	if XCore.ServerCallbacks[name] ~= nil then
		XCore.ServerCallbacks[name](source, cb, ...)
	end
end

XCore.Functions.CreateUseableItem = function(item, cb)
	XCore.UseableItems[item] = cb
end

XCore.Functions.CanUseItem = function(item)
	return XCore.UseableItems[item] ~= nil
end

XCore.Functions.UseItem = function(source, item)
	XCore.UseableItems[item.name](source, item)
end

XCore.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check our Discord for further information: "..XCore.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

XCore.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (XCore.Config.Server.whitelist) then
		exports['ghmattimysql']:execute('SELECT * FROM whitelist WHERE license=@license', {['@license'] = XCore.Functions.GetIdentifier(source, 'license')}, function(result)
			local data = result[1]
			if data ~= nil then
				for _, id in pairs(identifiers) do
					if data.license == id then
						rtn = true
					end
				end
			end
		end)
	else
		rtn = true
	end
	return rtn
end

XCore.Functions.AddPermission = function(source, permission)
	local Player = XCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		XCore.Config.Server.PermissionList[XCore.Functions.GetIdentifier(source, 'license')] = {
			license = XCore.Functions.GetIdentifier(source, 'license'),
			permission = permission:lower(),
		}
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = XCore.Functions.GetIdentifier(source, 'license')})

		exports['ghmattimysql']:execute('INSERT INTO permissions (name, license, permission) VALUES (@name, @license, @permission)', {
			['@name'] = GetPlayerName(source),
			['@license'] = XCore.Functions.GetIdentifier(source, 'license'),
			['@permission'] = permission:lower()
		})

		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('XCore:NotifyClient:OnPermissionUpdate', source, permission)
	end
end

XCore.Functions.RemovePermission = function(source)
	local Player = XCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		XCore.Config.Server.PermissionList[XCore.Functions.GetIdentifier(source, 'license')] = nil	
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = XCore.Functions.GetIdentifier(source, 'license')})
		Player.Functions.UpdatePlayerData()
	end
end

XCore.Functions.HasPermission = function(source, permission)
	local retval = false
	local license = XCore.Functions.GetIdentifier(source, 'license')
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if XCore.Config.Server.PermissionList[license] ~= nil then 
			if XCore.Config.Server.PermissionList[license].license == license then
				if XCore.Config.Server.PermissionList[license].permission == permission or XCore.Config.Server.PermissionList[license].permission == "god" then
					retval = true
				end
			end
		end
	end
	return retval
end

XCore.Functions.GetPermission = function(source)
	local retval = "user"
	Player = XCore.Functions.GetPlayer(source)
	local license = XCore.Functions.GetIdentifier(source, 'license')
	if Player ~= nil then
		if XCore.Config.Server.PermissionList[Player.PlayerData.license] ~= nil then 
			if XCore.Config.Server.PermissionList[Player.PlayerData.license].license == license then
				retval = XCore.Config.Server.PermissionList[Player.PlayerData.license].permission
			end
		end
	end
	return retval
end

XCore.Functions.IsOptin = function(source)
	local retval = false
	local license = XCore.Functions.GetIdentifier(source, 'license')
	if XCore.Functions.HasPermission(source, "admin") then
		retval = XCore.Config.Server.PermissionList[license].optin
	end
	return retval
end

XCore.Functions.ToggleOptin = function(source)
	local license = XCore.Functions.GetIdentifier(source, 'license')
	if XCore.Functions.HasPermission(source, "admin") then
		XCore.Config.Server.PermissionList[license].optin = not XCore.Config.Server.PermissionList[license].optin
	end
end

XCore.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
	exports['ghmattimysql']:execute('SELECT * FROM bans WHERE license=@license', {['@license'] = XCore.Functions.GetIdentifier(source, 'license')}, function(result)
		if result[1] ~= nil then 
			if os.time() < result[1].expire then
				retval = true
				local timeTable = os.date("*t", tonumber(result[1].expire))
				message = "You have been banned from the server:\n"..result[1].reason.."\nYour ban expires "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
			else
				exports['ghmattimysql']:execute('DELETE FROM bans WHERE id=@id', {['@id'] = result[1].id})
			end
		end
	end)
	return retval, message
end