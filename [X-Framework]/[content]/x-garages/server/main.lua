local OutsideVehicles = {}

-- code

RegisterServerEvent('x-garages:server:UpdateOutsideVehicles')
AddEventHandler('x-garages:server:UpdateOutsideVehicles', function(Vehicles)
    local src = source
    local Ply = XCore.Functions.GetPlayer(src)
    local CitizenId = Ply.PlayerData.citizenid

    OutsideVehicles[CitizenId] = Vehicles
end)

XCore.Functions.CreateCallback("x-garage:server:checkVehicleOwner", function(source, cb, plate)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate AND citizenid = @citizenid', {['@plate'] = plate, ['@citizenid'] = pData.PlayerData.citizenid}, function(result)
        if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

XCore.Functions.CreateCallback("x-garage:server:GetOutsideVehicles", function(source, cb)
    local Ply = XCore.Functions.GetPlayer(source)
    local CitizenId = Ply.PlayerData.citizenid

    if OutsideVehicles[CitizenId] ~= nil and next(OutsideVehicles[CitizenId]) ~= nil then
        cb(OutsideVehicles[CitizenId])
    else
        cb(nil)
    end
end)

XCore.Functions.CreateCallback("x-garage:server:GetUserVehicles", function(source, cb, garage)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND garage = @garage', {['@citizenid'] = pData.PlayerData.citizenid, ['@garage'] = garage}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

XCore.Functions.CreateCallback("x-garage:server:GetVehicleProperties", function(source, cb, plate)
    local src = source
    local properties = {}
    exports.ghmattimysql:execute('SELECT mods FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            properties = json.decode(result[1].mods)
        end
        cb(properties)
    end)
end)

XCore.Functions.CreateCallback("x-garage:server:GetDepotVehicles", function(source, cb)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND state = @state', {['@citizenid'] = pData.PlayerData.citizenid, ['@state'] = 0}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

XCore.Functions.CreateCallback("x-garage:server:GetHouseVehicles", function(source, cb, house)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE garage = @garage', {['@garage'] = house}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

XCore.Functions.CreateCallback("x-garage:server:checkVehicleHouseOwner", function(source, cb, plate, house)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            local hasHouseKey = exports['x-houses']:hasKey(result[1].license, result[1].citizenid, house)
            if hasHouseKey then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('x-garage:server:PayDepotPrice')
AddEventHandler('x-garage:server:PayDepotPrice', function(vehicle, garage)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate', {['@plate'] = vehicle.plate}, function(result)
        if result[1] ~= nil then
            -- if Player.Functions.RemoveMoney("cash", result[1].depotprice, "paid-depot") then
            --     TriggerClientEvent("x-garages:client:takeOutDepot", src, vehicle, garage)
            -- else
            if bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney("bank", result[1].depotprice, "paid-depot")
                TriggerClientEvent("x-garages:client:takeOutDepot", src, vehicle, garage)
            end
        end
    end)
end)

RegisterServerEvent('x-garage:server:updateVehicleState')
AddEventHandler('x-garage:server:updateVehicleState', function(state, plate, garage)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('UPDATE player_vehicles SET state = @state, garage = @garage, depotprice = @depotprice WHERE plate = @plate', {['@state'] = state, ['@plate'] = plate, ['@depotprice'] = 0, ['@citizenid'] = pData.PlayerData.citizenid, ['@garage'] = garage})
end)

RegisterServerEvent('x-garage:server:updateVehicleStatus')
AddEventHandler('x-garage:server:updateVehicleStatus', function(fuel, engine, body, plate, garage)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)

    if engine > 1000 then
        engine = engine / 1000
    end

    if body > 1000 then
        body = body / 1000
    end

    exports['ghmattimysql']:execute('UPDATE player_vehicles SET fuel = @fuel, engine = @engine, body = @body WHERE plate = @plate AND citizenid = @citizenid AND garage = @garage', {
        ['@fuel'] = fuel, 
        ['@engine'] = engine, 
        ['@body'] = body,
        ['@plate'] = plate,
        ['@garage'] = garage,
        ['@citizenid'] = pData.PlayerData.citizenid
    })
end)