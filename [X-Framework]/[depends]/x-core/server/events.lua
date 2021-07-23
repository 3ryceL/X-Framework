-- Player joined
RegisterServerEvent("XCore:NotifyPlayerJoined")
AddEventHandler('XCore:NotifyPlayerJoined', function()
	local src = source
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	TriggerEvent("x-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..XCore.Functions.GetIdentifier(src, 'license')..") left..")
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (XCore.Players[src] == nil)) then return false end
	XCore.Players[src].Functions.Save()
	XCore.Players[src] = nil
end)

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local license
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    -- mandatory wait!
    Wait(0)

    deferrals.update(string.format("Hello %s. Validating Your Rockstar License", name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- mandatory wait!
    Wait(2500)

    deferrals.update(string.format("Hello %s. We are checking if you are banned.", name))
	
    local isBanned, Reason = XCore.Functions.IsPlayerBanned(player)
	
    Wait(2500)
	
    deferrals.update(string.format("Welcome %s to {Server Name}.", name))

    if not license then
        deferrals.done('No Valid Rockstar License Found')
    elseif isBanned then
	deferrals.done(Reason)
    else
        deferrals.done()
	Wait(1000)
	TriggerEvent("connectqueue:playerConnect", name, setKickReason, deferrals)
    end
    --Add any additional defferals you may need!
    
end

AddEventHandler("playerConnecting", OnPlayerConnecting)


RegisterServerEvent("XCore:Notifyserver:CloseServer")
AddEventHandler('XCore:Notifyserver:CloseServer', function(reason)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    if XCore.Functions.HasPermission(source, "admin") or XCore.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason specified..."
        XCore.Config.Server.closed = true
        XCore.Config.Server.closedReason = reason
        TriggerClientEvent("qbadmin:client:SetServerStatus", -1, true)
	else
		XCore.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("XCore:Notifyserver:OpenServer")
AddEventHandler('XCore:Notifyserver:OpenServer', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    if XCore.Functions.HasPermission(source, "admin") or XCore.Functions.HasPermission(source, "god") then
        XCore.Config.Server.closed = false
        TriggerClientEvent("qbadmin:client:SetServerStatus", -1, false)
    else
        XCore.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("XCore:NotifyUpdatePlayer")
AddEventHandler('XCore:NotifyUpdatePlayer', function(data)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = data.position
		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)
		Player.Functions.Save()
	end
end)

RegisterServerEvent("XCore:NotifyUpdatePlayerPosition")
AddEventHandler("XCore:NotifyUpdatePlayerPosition", function(position)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = position
	end
end)

RegisterServerEvent("XCore:NotifyServer:TriggerCallback")
AddEventHandler('XCore:NotifyServer:TriggerCallback', function(name, ...)
	local src = source
	XCore.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("XCore:NotifyClient:TriggerCallback", src, name, ...)
	end, ...)
end)

RegisterServerEvent("XCore:NotifyServer:UseItem")
AddEventHandler('XCore:NotifyServer:UseItem', function(item)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if XCore.Functions.CanUseItem(item.name) then
			XCore.Functions.UseItem(src, item)
		end
	end
end)

RegisterServerEvent("XCore:NotifyServer:RemoveItem")
AddEventHandler('XCore:NotifyServer:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterServerEvent("XCore:NotifyServer:AddItem")
AddEventHandler('XCore:NotifyServer:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

RegisterServerEvent('XCore:NotifyServer:SetMetaData')
AddEventHandler('XCore:NotifyServer:SetMetaData', function(meta, data)
    local src = source
	local Player = XCore.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player ~= nil then 
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = XCore.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if XCore.Commands.List[command] ~= nil then
			local Player = XCore.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (XCore.Functions.HasPermission(source, "god") or XCore.Functions.HasPermission(source, XCore.Commands.List[command].permission)) then
					if (XCore.Commands.List[command].argsrequired and #XCore.Commands.List[command].arguments ~= 0 and args[#XCore.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('XCore:NotifyNotify', source, "All arguments must be filled out!", "error")
					    local agus = ""
					    for name, help in pairs(XCore.Commands.List[command].arguments) do
					    	agus = agus .. " ["..help.name.."]"
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						XCore.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('XCore:NotifyNotify', source, "No Access To This Command", "error")
				end
			end
		end
	end
end)

RegisterServerEvent('XCore:NotifyCallCommand')
AddEventHandler('XCore:NotifyCallCommand', function(command, args)
	if XCore.Commands.List[command] ~= nil then
		local Player = XCore.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (XCore.Functions.HasPermission(source, "god")) or (XCore.Functions.HasPermission(source, XCore.Commands.List[command].permission)) or (XCore.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (XCore.Commands.List[command].argsrequired and #XCore.Commands.List[command].arguments ~= 0 and args[#XCore.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('XCore:NotifyNotify', source, "All arguments must be filled out!", "error")
					local agus = ""
					for name, help in pairs(XCore.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					XCore.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('XCore:NotifyNotify', source, "No Access To This Command", "error")
			end
		end
	end
end)

RegisterServerEvent("XCore:NotifyAddCommand")
AddEventHandler('XCore:NotifyAddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	XCore.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("XCore:NotifyToggleDuty")
AddEventHandler('XCore:NotifyToggleDuty', function()
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('XCore:NotifyNotify', src, "You are now off duty!")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('XCore:NotifyNotify', src, "You are now on duty!")
	end
	TriggerClientEvent("XCore:NotifyClient:SetDuty", src, Player.PlayerData.job.onduty)
end)

Citizen.CreateThread(function()
	exports.ghmattimysql:execute('SELECT * FROM permissions', function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				XCore.Config.Server.PermissionList[v.license] = {
					license = v.license,
					permission = v.permission,
					optin = true,
				}
			end
		end
	end)
end)

XCore.Functions.CreateCallback('XCore:NotifyHasItem', function(source, cb, items)
	local retval = false
	local Player = XCore.Functions.GetPlayer(source)
	if type(items) == "table" then
		local count = 0
		for k, v in pairs(items) do
			if Player ~= nil then 
				if Player.Functions.GetItemByName(v) ~= nil then
					count = count + 1
					if count == #items then
						retval = true
					end
				end
			end
		end
	else
		if Player ~= nil then 
			if Player.Functions.GetItemByName(items) ~= nil then
				retval = true
			end
		end
	end
	
	cb(retval)
end)	

RegisterServerEvent('XCore:NotifyCommand:CheckOwnedVehicle')
AddEventHandler('XCore:NotifyCommand:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		exports.ghmattimysql:execute('SELECT * FROM player_vehicles WHERE plate=@plate', {['@plate'] = VehiclePlate}, function(result)
			if result[1] ~= nil then
				exports.ghmattimysql:execute('UPDATE player_vehicles SET state=@state WHERE citizenid=@citizenid', {['@state'] = 1, ['@citizenid'] = result[1].citizenid})
				TriggerEvent('x-garages:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
			end
		end)
	end
end)
