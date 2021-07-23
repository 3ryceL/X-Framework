XCore.Commands.Add("fix", "Repair your vehicle (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('iens:repaira', source)
    TriggerClientEvent('vehiclemod:client:fixEverything', source)
end, "admin")

XCore.Functions.CreateUseableItem("repairkit", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("x-vehiclefailure:client:RepairVehicle", source)
    end
end)

XCore.Functions.CreateUseableItem("cleaningkit", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("x-vehiclefailure:client:CleanVehicle", source)
    end
end)

XCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("x-vehiclefailure:client:RepairVehicleFull", source)
    end
end)

RegisterServerEvent('x-x-vehiclefailure:removeItem')
AddEventHandler('x-x-vehiclefailure:removeItem', function(item)
    local src = source
    local ply = XCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem(item, 1)
end)

RegisterServerEvent('x-vehiclefailure:server:removewashingkit')
AddEventHandler('x-vehiclefailure:server:removewashingkit', function(veh)
    local src = source
    local ply = XCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem("cleaningkit", 1)
    TriggerClientEvent('x-vehiclefailure:client:SyncWash', -1, veh)
end)

