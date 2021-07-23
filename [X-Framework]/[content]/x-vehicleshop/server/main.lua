local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

-- code

RegisterNetEvent('x-vehicleshop:server:buyVehicle')
AddEventHandler('x-vehicleshop:server:buyVehicle', function(vehicleData, garage)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local vData = XCore.Shared.Vehicles[vehicleData["model"]]
    local balance = pData.PlayerData.money["bank"]
    
    if (balance - vData["price"]) >= 0 then
        local plate = GeneratePlate()
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage)', {
            ['@license'] = pData.PlayerData.license,
            ['@citizenid'] = cid,
            ['@vehicle'] = vData["model"],
            ['@hash'] = GetHashKey(vData["model"]),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@garage'] = garage
        })
        TriggerClientEvent("XCore:NotifyNotify", src, "Success! Your vehicle has been delivered to "..X.GarageLabel[garage], "success", 5000)
        pData.Functions.RemoveMoney('bank', vData["price"], "vehicle-bought-in-shop")
        TriggerEvent("x-log:server:sendLog", cid, "vehiclebought", {model=vData["model"], name=vData["name"], from="garage", location=X.GarageLabel[garage], moneyType="bank", price=vData["price"], plate=plate})
        TriggerEvent("x-log:server:CreateLog", "vehicleshop", "Vehicle purchased (garage)", "green", "**"..GetPlayerName(src) .. "** bought a " .. vData["name"] .. " for $" .. vData["price"])
    else
		TriggerClientEvent("XCore:NotifyNotify", src, "You don't have enough money, you're missing $"..format_thousand(vData["price"] - balance), "error", 5000)
    end
end)

RegisterNetEvent('x-vehicleshop:server:buyShowroomVehicle')
AddEventHandler('x-vehicleshop:server:buyShowroomVehicle', function(vehicle, class)
    local src = source
    local pData = XCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local balance = pData.PlayerData.money["bank"]
    local vehiclePrice = XCore.Shared.Vehicles[vehicle]["price"]
    local plate = GeneratePlate()

    if (balance - vehiclePrice) >= 0 then
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = pData.PlayerData.license,
            ['@citizenid'] = cid,
            ['@vehicle'] = vehicle,
            ['@hash'] = GetHashKey(vehicle),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@state'] = 0
        })
        TriggerClientEvent("XCore:NotifyNotify", src, "Success! Your vehicle will be waiting for you outside", "success", 5000)
        TriggerClientEvent('x-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', vehiclePrice, "vehicle-bought-in-showroom")
        TriggerEvent("x-log:server:sendLog", cid, "vehiclebought", {model=vehicle, name=XCore.Shared.Vehicles[vehicle]["name"], from="showroom", moneyType="bank", price=XCore.Shared.Vehicles[vehicle]["price"], plate=plate})
        TriggerEvent("x-log:server:CreateLog", "vehicleshop", "Vehicle purchased (showroom)", "green", "**"..GetPlayerName(src) .. "** bought a " .. XCore.Shared.Vehicles[vehicle]["name"] .. " for $" .. XCore.Shared.Vehicles[vehicle]["price"])
    else
        TriggerClientEvent("XCore:NotifyNotify", src, "You don't have enough money, you're missing $"..format_thousand(vehiclePrice - balance), "error", 5000)
    end
end)

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
            .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end

function GeneratePlate()
    local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    XCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        while (result[1] ~= nil) do
            plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
        end
        return plate
    end)
    return plate:upper()
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

RegisterServerEvent('x-vehicleshop:server:setShowroomCarInUse')
AddEventHandler('x-vehicleshop:server:setShowroomCarInUse', function(showroomVehicle, bool)
    X.ShowroomVehicles[showroomVehicle].inUse = bool
    TriggerClientEvent('x-vehicleshop:client:setShowroomCarInUse', -1, showroomVehicle, bool)
end)

RegisterServerEvent('x-vehicleshop:server:setShowroomVehicle')
AddEventHandler('x-vehicleshop:server:setShowroomVehicle', function(vData, k)
    X.ShowroomVehicles[k].chosenVehicle = vData
    TriggerClientEvent('x-vehicleshop:client:setShowroomVehicle', -1, vData, k)
end)

RegisterServerEvent('x-vehicleshop:server:SetCustomShowroomVeh')
AddEventHandler('x-vehicleshop:server:SetCustomShowroomVeh', function(vData, k)
    X.ShowroomVehicles[k].vehicle = vData
    TriggerClientEvent('x-vehicleshop:client:SetCustomShowroomVeh', -1, vData, k)
end)

XCore.Commands.Add("sell", "Sell Vehicle (Car Dealer Only)", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local TargetId = args[1]

    if Player.PlayerData.job.name == "cardealer" then
        if TargetId ~= nil then
            TriggerClientEvent('x-vehicleshop:client:SellCustomVehicle', source, TargetId)
        else
            TriggerClientEvent('XCore:NotifyNotify', source, 'You must provide a Player ID!', 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'You Are Not A Car Dealer', 'error')
    end
end)

XCore.Commands.Add("testdrive", "Test Drive Vehicle (Car Dealer Only)", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local TargetId = args[1]

    if Player.PlayerData.job.name == "cardealer" then
        TriggerClientEvent('x-vehicleshop:client:DoTestrit', source, GeneratePlate())
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'You Are Not A Car Dealer', 'error')
    end
end)

RegisterServerEvent('x-vehicleshop:server:SellCustomVehicle')
AddEventHandler('x-vehicleshop:server:SellCustomVehicle', function(TargetId, ShowroomSlot)
    TriggerClientEvent('x-vehicleshop:client:SetVehicleBuying', TargetId, ShowroomSlot)
end)

RegisterServerEvent('x-vehicleshop:server:ConfirmVehicle')
AddEventHandler('x-vehicleshop:server:ConfirmVehicle', function(ShowroomVehicle)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local VehPrice = XCore.Shared.Vehicles[ShowroomVehicle.vehicle].price
    local plate = GeneratePlate()

    if Player.PlayerData.money.cash >= VehPrice then
        Player.Functions.RemoveMoney('cash', VehPrice)
        TriggerClientEvent('x-vehicleshop:client:ConfirmVehicle', src, ShowroomVehicle, plate)
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = Player.PlayerData.license,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@vehicle'] = ShowroomVehicle.vehicle,
            ['@hash'] = GetHashKey(ShowroomVehicle.vehicle),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@state'] = 0
        })
    elseif Player.PlayerData.money.bank >= VehPrice then
        Player.Functions.RemoveMoney('bank', VehPrice)
        TriggerClientEvent('x-vehicleshop:client:ConfirmVehicle', src, ShowroomVehicle, plate)
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = Player.PlayerData.license,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@vehicle'] = ShowroomVehicle.vehicle,
            ['@hash'] = GetHashKey(ShowroomVehicle.vehicle),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@state'] = 0
        })
    else
        if Player.PlayerData.money.cash > Player.PlayerData.money.bank then
            TriggerClientEvent('XCore:NotifyNotify', src, 'You don\'t have enough money.. You are missing ('..(Player.PlayerData.money.cash - VehPrice)..',-)')
        else
            TriggerClientEvent('XCore:NotifyNotify', src, 'You don\'t have enough money.. You are missing ('..(Player.PlayerData.money.bank - VehPrice)..',-)')
        end
    end
end)
