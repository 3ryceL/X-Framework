local VehicleList = {}

XCore.Functions.CreateCallback('vehiclekeys:CheckHasKey', function(source, cb, plate)
    local Player = XCore.Functions.GetPlayer(source)
    cb(CheckOwner(plate, Player.PlayerData.citizenid))
end)

RegisterServerEvent('vehiclekeys:server:SetVehicleOwner')
AddEventHandler('vehiclekeys:server:SetVehicleOwner', function(plate)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    if VehicleList ~= nil then
        if DoesPlateExist(plate) then
            for k, val in pairs(VehicleList) do
                if val.plate == plate then
                    table.insert(VehicleList[k].owners, Player.PlayerData.citizenid)
                end
            end
        else
            local vehicleId = #VehicleList+1
            VehicleList[vehicleId] = {
                plate = plate, 
                owners = {},
            }
            VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
        end
    else
        local vehicleId = #VehicleList+1
        VehicleList[vehicleId] = {
            plate = plate, 
            owners = {},
        }
        VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
    end
end)

RegisterServerEvent('vehiclekeys:server:GiveVehicleKeys')
AddEventHandler('vehiclekeys:server:GiveVehicleKeys', function(plate, target)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    if CheckOwner(plate, Player.PlayerData.citizenid) then
        if XCore.Functions.GetPlayer(target) ~= nil then
            TriggerClientEvent('vehiclekeys:client:SetOwner', target, plate)
            TriggerClientEvent('XCore:NotifyNotify', src, "You gave the keys!")
            TriggerClientEvent('XCore:NotifyNotify', target, "You got the keys!")
        else
            TriggerClientEvent('XCore:NotifyNotify', source,  "Player Not Online", "error")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source,  "You Dont Own This Vehicle", "error")
    end
end)

XCore.Commands.Add("engine", "Toggle Engine", {}, false, function(source, args)
	TriggerClientEvent('vehiclekeys:client:ToggleEngine', source)
end)

XCore.Commands.Add("givecarkeys", "Give Car Keys", {{name = "id", help = "Player id"}}, true, function(source, args)
	local src = source
    local target = tonumber(args[1])
    TriggerClientEvent('vehiclekeys:client:GiveKeys', src, target)
end)

function DoesPlateExist(plate)
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                return true
            end
        end
    end
    return false
end

function CheckOwner(plate, identifier)
    local retval = false
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                for key, owner in pairs(VehicleList[k].owners) do
                    if owner == identifier then
                        retval = true
                    end
                end
            end
        end
    end
    return retval
end

XCore.Functions.CreateUseableItem("lockpick", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, false)
end)

XCore.Functions.CreateUseableItem("advancedlockpick", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, true)
end)
