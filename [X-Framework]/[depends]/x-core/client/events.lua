-- XCore Command Events
RegisterNetEvent('XCore:NotifyCommand:TeleportToPlayer')
AddEventHandler('XCore:NotifyCommand:TeleportToPlayer', function(coords)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('XCore:NotifyCommand:TeleportToCoords')
AddEventHandler('XCore:NotifyCommand:TeleportToCoords', function(x, y, z)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, x, y, z)
end)

RegisterNetEvent('XCore:NotifyCommand:SpawnVehicle')
AddEventHandler('XCore:NotifyCommand:SpawnVehicle', function(model)
	XCore.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
	end)
end)

RegisterNetEvent('XCore:NotifyCommand:DeleteVehicle')
AddEventHandler('XCore:NotifyCommand:DeleteVehicle', function()
	local vehicle = XCore.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(PlayerPedId()) then vehicle = GetVehiclePedIsIn(PlayerPedId(), false) else vehicle = XCore.Functions.GetClosestVehicle() end
	-- TriggerServerEvent('XCore:NotifyCommand:CheckOwnedVehicle', GetVehicleNumberPlateText(vehicle))
	XCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('XCore:NotifyCommand:Revive')
AddEventHandler('XCore:NotifyCommand:Revive', function()
	local coords = XCore.Functions.GetCoords(PlayerPedId())
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())
end)

RegisterNetEvent('XCore:NotifyCommand:GoToMarker')
AddEventHandler('XCore:NotifyCommand:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			DoScreenFadeOut(250)
			while IsScreenFadedOut() do
				Citizen.Wait(250)
			end
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				--groundFound = true
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
			--HideLoadingPromt()
			DoScreenFadeIn(250)
		end
	end)
end)

-- Other stuff
RegisterNetEvent('XCore:NotifyPlayer:SetPlayerData')
AddEventHandler('XCore:NotifyPlayer:SetPlayerData', function(val)
	XCore.PlayerData = val
end)

RegisterNetEvent('XCore:NotifyPlayer:UpdatePlayerData')
AddEventHandler('XCore:NotifyPlayer:UpdatePlayerData', function()
	local data = {}
	data.position = XCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('XCore:NotifyUpdatePlayer', data)
end)

RegisterNetEvent('XCore:NotifyPlayer:UpdatePlayerPosition')
AddEventHandler('XCore:NotifyPlayer:UpdatePlayerPosition', function()
	local position = XCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('XCore:NotifyUpdatePlayerPosition', position)
end)

RegisterNetEvent('XCore:NotifyClient:LocalOutOfCharacter')
AddEventHandler('XCore:NotifyClient:LocalOutOfCharacter', function(playerId, playerName, message)
	local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId)), false)
    local pos = GetEntityCoords(PlayerPedId(), false)
	local dist = #(pos - sourcePos)
    if dist < 20.0 then
		TriggerEvent("chatMessage", "OOC " .. playerName, "normal", message)
    end
end)

RegisterNetEvent('XCore:NotifyNotify')
AddEventHandler('XCore:NotifyNotify', function(text, type, length)
	XCore.Functions.Notify(text, type, length)
end)

RegisterNetEvent('XCore:NotifyClient:TriggerCallback') -- XCore:NotifyClient:TriggerCallback falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('XCore:NotifyClient:TriggerCallback', function(name, ...)
	if XCore.ServerCallbacks[name] ~= nil then
		XCore.ServerCallbacks[name](...)
		XCore.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("XCore:NotifyClient:UseItem") -- XCore:NotifyClient:UseItem falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('XCore:NotifyClient:UseItem', function(item)
	TriggerServerEvent("XCore:NotifyServer:UseItem", item)
end)
