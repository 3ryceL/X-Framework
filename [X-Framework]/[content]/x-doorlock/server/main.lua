local doorInfo = {}

RegisterServerEvent('x-doorlock:server:setupDoors')
AddEventHandler('x-doorlock:server:setupDoors', function()
	local src = source
	TriggerClientEvent("x-doorlock:client:setDoors", X.Doors)
end)

RegisterServerEvent('x-doorlock:server:updateState')
AddEventHandler('x-doorlock:server:updateState', function(doorID, state)
	local src = source
	local Player = XCore.Functions.GetPlayer(src)
	
	X.Doors[doorID].locked = state

	TriggerClientEvent('x-doorlock:client:setState', -1, doorID, state)
end)
