local VehicleStatus = {}
local VehicleDrivingDistance = {}

XCore.Functions.CreateCallback('x-vehicletuning:server:GetDrivingDistances', function(source, cb)
    cb(VehicleDrivingDistance)
end)

RegisterServerEvent('x-vehicletuning:server:SaveVehicleProps')
AddEventHandler('x-vehicletuning:server:SaveVehicleProps', function(vehicleProps)
    local src = source
    if IsVehicleOwned(vehicleProps.plate) then
        exports.ghmattimysql:execute('UPDATE player_vehicles SET mods=@mods WHERE plate=@plate', {['@mods'] = json.encode(vehicleProps), ['@plate'] = vehicleProps.plate})
    end
end)

RegisterServerEvent("vehiclemod:server:setupVehicleStatus")
AddEventHandler("vehiclemod:server:setupVehicleStatus", function(plate, engineHealth, bodyHealth)
    local src = source
    local engineHealth = engineHealth ~= nil and engineHealth or 1000.0
    local bodyHealth = bodyHealth ~= nil and bodyHealth or 1000.0
    if VehicleStatus[plate] == nil then 
        if IsVehicleOwned(plate) then
            local statusInfo = GetVehicleStatus(plate)
            if statusInfo == nil then 
                statusInfo =  {
                    ["engine"] = engineHealth,
                    ["body"] = bodyHealth,
                    ["radiator"] = Config.MaxStatusValues["radiator"],
                    ["axle"] = Config.MaxStatusValues["axle"],
                    ["brakes"] = Config.MaxStatusValues["brakes"],
                    ["clutch"] = Config.MaxStatusValues["clutch"],
                    ["fuel"] = Config.MaxStatusValues["fuel"],
                }
            end
            VehicleStatus[plate] = statusInfo
            TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, statusInfo)
        else
            local statusInfo = {
                ["engine"] = engineHealth,
                ["body"] = bodyHealth,
                ["radiator"] = Config.MaxStatusValues["radiator"],
                ["axle"] = Config.MaxStatusValues["axle"],
                ["brakes"] = Config.MaxStatusValues["brakes"],
                ["clutch"] = Config.MaxStatusValues["clutch"],
                ["fuel"] = Config.MaxStatusValues["fuel"],
            }
            VehicleStatus[plate] = statusInfo
            TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, statusInfo)
        end
    else
        TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
    end
end)

RegisterServerEvent('x-vehicletuning:server:UpdateDrivingDistance')
AddEventHandler('x-vehicletuning:server:UpdateDrivingDistance', function(amount, plate)
    VehicleDrivingDistance[plate] = amount
    TriggerClientEvent('x-vehicletuning:client:UpdateDrivingDistance', -1, VehicleDrivingDistance[plate], plate)
    exports.ghmattimysql:execute('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            exports.ghmattimysql:execute('UPDATE player_vehicles SET drivingdistance=@drivingdistance WHERE plate=@plate', {['@drivingdistance'] = amount, ['@plate'] = plate})
        end
    end)
end)

XCore.Functions.CreateCallback('x-vehicletuning:server:IsVehicleOwned', function(source, cb, plate)
    local retval = false
    exports.ghmattimysql:execute('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            retval = true
        end
        cb(retval)
    end)
end)

RegisterServerEvent('x-vehicletuning:server:LoadStatus')
AddEventHandler('x-vehicletuning:server:LoadStatus', function(veh, plate)
    VehicleStatus[plate] = veh
    TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, veh)
end)

RegisterServerEvent("vehiclemod:server:updatePart")
AddEventHandler("vehiclemod:server:updatePart", function(plate, part, level)
    if VehicleStatus[plate] ~= nil then
        if part == "engine" or part == "body" then
            VehicleStatus[plate][part] = level
            if VehicleStatus[plate][part] < 0 then
                VehicleStatus[plate][part] = 0
            elseif VehicleStatus[plate][part] > 1000 then
                VehicleStatus[plate][part] = 1000.0
            end
        else
            VehicleStatus[plate][part] = level
            if VehicleStatus[plate][part] < 0 then
                VehicleStatus[plate][part] = 0
            elseif VehicleStatus[plate][part] > 100 then
                VehicleStatus[plate][part] = 100
            end
        end
        TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
    end
end)

RegisterServerEvent('x-vehicletuning:server:SetPartLevel')
AddEventHandler('x-vehicletuning:server:SetPartLevel', function(plate, part, level)
    if VehicleStatus[plate] ~= nil then
        VehicleStatus[plate][part] = level
        TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
    end
end)

RegisterServerEvent("vehiclemod:server:fixEverything")
AddEventHandler("vehiclemod:server:fixEverything", function(plate)
    if VehicleStatus[plate] ~= nil then 
        for k, v in pairs(Config.MaxStatusValues) do
            VehicleStatus[plate][k] = v
        end
        TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
    end
end)

RegisterServerEvent("vehiclemod:server:saveStatus")
AddEventHandler("vehiclemod:server:saveStatus", function(plate)
    if VehicleStatus[plate] ~= nil then
        exports['ghmattimysql']:execute('UPDATE player_vehicles SET status = @status WHERE plate = @plate', {['@status'] = json.encode(VehicleStatus[plate]), ['@plate'] = plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    XCore.Functions.ExecuteSql(true, "SELECT plate FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end

function GetVehicleStatus(plate)
    local retval = nil
    XCore.Functions.ExecuteSql(true, "SELECT `status` FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = result[1].status ~= nil and json.decode(result[1].status) or nil
        end
    end)
    return retval
end

XCore.Commands.Add("setvehiclestatus", "Set Vehicle Status", {{name="part", help="Type The Part You Want To Edit"}, {name="amount", help="The Percentage Fixed"}}, true, function(source, args)
    local part = args[1]:lower()
    local level = tonumber(args[2])
    TriggerClientEvent("vehiclemod:client:setPartLevel", source, part, level)
end, "god")

XCore.Functions.CreateCallback('x-vehicletuning:server:GetAttachedVehicle', function(source, cb)
    cb(Config.Plates)
end)

XCore.Functions.CreateCallback('x-vehicletuning:server:IsMechanicAvailable', function(source, cb)
	local amount = 0
	for k, v in pairs(XCore.Functions.GetPlayers()) do
        local Player = XCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "mechanic" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    cb(amount)
end)

RegisterServerEvent('x-vehicletuning:server:SetAttachedVehicle')
AddEventHandler('x-vehicletuning:server:SetAttachedVehicle', function(veh, k)
    if veh ~= false then
        Config.Plates[k].AttachedVehicle = veh
        TriggerClientEvent('x-vehicletuning:client:SetAttachedVehicle', -1, veh, k)
    else
        Config.Plates[k].AttachedVehicle = nil
        TriggerClientEvent('x-vehicletuning:client:SetAttachedVehicle', -1, false, k)
    end
end)

RegisterServerEvent('x-vehicletuning:server:CheckForItems')
AddEventHandler('x-vehicletuning:server:CheckForItems', function(part)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local RepairPart = Player.Functions.GetItemByName(Config.RepairCostAmount[part].item)

    if RepairPart ~= nil then
        if RepairPart.amount >= Config.RepairCostAmount[part].costs then
            TriggerClientEvent('x-vehicletuning:client:RepaireeePart', src, part)
            Player.Functions.RemoveItem(Config.RepairCostAmount[part].item, Config.RepairCostAmount[part].costs)

            for i = 1, Config.RepairCostAmount[part].costs, 1 do
                TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[Config.RepairCostAmount[part].item], "remove")
                Citizen.Wait(500)
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "You Dont Have Enough "..XCore.Shared.Items[Config.RepairCostAmount[part].item]["label"].." (min. "..Config.RepairCostAmount[part].costs.."x)", "error")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Do Not Have "..XCore.Shared.Items[Config.RepairCostAmount[part].item]["label"].." bij je!", "error")
    end
end)

function IsAuthorized(CitizenId)
    local retval = false
    for _, cid in pairs(Config.AuthorizedIds) do
        if cid == CitizenId then
            retval = true
            break
        end
    end
    return retval
end

XCore.Commands.Add("setmechanic", "Give Someone The Mechanic job", {{name="id", help="ID Of The Player"}}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = XCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                TargetData.Functions.SetJob("mechanic")
                TriggerClientEvent('XCore:NotifyNotify', TargetData.PlayerData.source, "You Were Hired As An Autocare Employee!")
                TriggerClientEvent('XCore:NotifyNotify', source, "You have ("..TargetData.PlayerData.charinfo.firstname..") Hired As An Autocare Employee!")
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', source, "You Must Provide A Player ID!")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You Cannot Do This!", "error") 
    end
end)

XCore.Commands.Add("firemechanic", "Fire A Mechanic", {{name="id", help="ID Of The Player"}}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = XCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                if TargetData.PlayerData.job.name == "mechanic" then
                    TargetData.Functions.SetJob("unemployed")
                    TriggerClientEvent('XCore:NotifyNotify', TargetData.PlayerData.source, "You Were Fired As An Autocare Employee!")
                    TriggerClientEvent('XCore:NotifyNotify', source, "You have ("..TargetData.PlayerData.charinfo.firstname..") Fired As Autocare Employee!")
                else
                    TriggerClientEvent('XCore:NotifyNotify', source, "Youre Not An Employee of Autocare!", "error")
                end
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', source, "You Must Provide A Player ID!", "error")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You Cannot Do This!", "error")
    end
end)

XCore.Functions.CreateCallback('x-vehicletuning:server:GetStatus', function(source, cb, plate)
    if VehicleStatus[plate] ~= nil and next(VehicleStatus[plate]) ~= nil then
        cb(VehicleStatus[plate])
    else
        cb(nil)
    end
end)