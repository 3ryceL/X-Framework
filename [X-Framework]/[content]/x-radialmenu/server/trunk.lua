local trunkBusy = {}

RegisterServerEvent('x-trunk:server:setTrunkBusy')
AddEventHandler('x-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

XCore.Functions.CreateCallback('x-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('x-trunk:server:KidnapTrunk')
AddEventHandler('x-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('x-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

XCore.Commands.Add("getintrunk", "Get In Trunk", {}, false, function(source, args)
    TriggerClientEvent('x-trunk:client:GetIn', source)
end)

XCore.Commands.Add("putintrunk", "Put Player In Trunk", {}, false, function(source, args)
    TriggerClientEvent('x-trunk:server:KidnapTrunk', source)
end)