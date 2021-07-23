XCore.Functions.CreateCallback('x-occasions:server:getVehicles', function(source, cb)
    exports.ghmattimysql:execute('SELECT * FROM occasion_vehicles', function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

XCore.Functions.CreateCallback("x-occasions:server:getSellerInformation", function(source, cb, citizenid)
    local src = source

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE citizenid = @citizenid', {['@citizenid'] = citizenid}, function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('x-occasions:server:ReturnVehicle')
AddEventHandler('x-occasions:server:ReturnVehicle', function(vehicleData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM occasion_vehicles WHERE plate=@plate AND occasionid=@occasionid', {['@plate'] = vehicleData['plate'], ['@occasionid'] = vehicleData["oid"]}, function(result)
        if result[1] ~= nil then 
            if result[1].seller == Player.PlayerData.citizenid then
                exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
                    ['@license'] = Player.PlayerData.license,
                    ['@citizenid'] = Player.PlayerData.citizenid,
                    ['@vehicle'] = vehicleData["model"],
                    ['@hash'] = GetHashKey(vehicleData["model"]),
                    ['@mods'] = vehicleData["mods"],
                    ['@plate'] = vehicleData["plate"],
                    ['@state'] = 0
                })
                exports.ghmattimysql:execute('DELETE FROM occasion_vehicles WHERE occasionid=@occasionid AND plate=@plate', {['@occasionid'] = vehicleData["oid"], ['@plate'] = vehicleData['plate']})
                TriggerClientEvent("x-occasions:client:ReturnOwnedVehicle", src, result[1])
                TriggerClientEvent('x-occasion:client:refreshVehicles', -1)
            else
                TriggerClientEvent('XCore:NotifyNotify', src, 'This is not your vehicle', 'error', 3500)
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', src, 'Vehicle does not exist', 'error', 3500)
        end
    end)
end)

RegisterServerEvent('x-occasions:server:sellVehicle')
AddEventHandler('x-occasions:server:sellVehicle', function(vehiclePrice, vehicleData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    XCore.Functions.ExecuteSql(true, "DELETE FROM `player_vehicles` WHERE `plate` = '"..vehicleData.plate.."' AND `vehicle` = '"..vehicleData.model.."'")
    XCore.Functions.ExecuteSql(true, "INSERT INTO `occasion_vehicles` (`seller`, `price`, `description`, `plate`, `model`, `mods`, `occasionid`) VALUES ('"..Player.PlayerData.citizenid.."', '"..vehiclePrice.."', '"..escapeSqli(vehicleData.desc).."', '"..vehicleData.plate.."', '"..vehicleData.model.."', '"..json.encode(vehicleData.mods).."', '"..generateOID().."')")
    
    TriggerEvent("x-log:server:sendLog", Player.PlayerData.citizenid, "vehiclesold", {model=vehicleData.model, vehiclePrice=vehiclePrice})
    TriggerEvent("x-log:server:CreateLog", "vehicleshop", "Vehicle for Sale", "red", "**"..GetPlayerName(src) .. "** has a " .. vehicleData.model .. " priced at "..vehiclePrice)

    TriggerClientEvent('x-occasion:client:refreshVehicles', -1)
end)

RegisterServerEvent('x-occasions:server:sellVehicleBack')
AddEventHandler('x-occasions:server:sellVehicleBack', function(vData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local price = math.floor(vData.price / 2)
    local plate = vData.plate
   
    Player.Functions.AddMoney('bank', price)
    TriggerClientEvent('XCore:NotifyNotify', src, 'You have sold your car for $'..price, 'success', 5500)
    XCore.Functions.ExecuteSql(true, "DELETE FROM `player_vehicles` WHERE `plate` = '"..plate.."' AND `citizenid` = '"..cid.."'")
end)

RegisterServerEvent('x-occasions:server:buyVehicle')
AddEventHandler('x-occasions:server:buyVehicle', function(vehicleData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM occasion_vehicles WHERE plate=@plate AND occasionid=@occasionid', {['@plate'] = vehicleData['plate'], ['@occasionid'] = vehicleData["oid"]}, function(result)
        if result[1] ~= nil and next(result[1]) ~= nil then
            if Player.PlayerData.money.bank >= result[1].price then
                local SellerCitizenId = result[1].seller
                local SellerData = XCore.Functions.GetPlayerByCitizenId(SellerCitizenId)
                -- New price calculation minus tax
                local NewPrice = math.ceil((result[1].price / 100) * 77)

                Player.Functions.RemoveMoney('bank', result[1].price)

                -- Insert vehicle for buyer
                exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
                    ['@license'] = Player.PlayerData.license,
                    ['@citizenid'] = Player.PlayerData.citizenid,
                    ['@vehicle'] = result[1]["model"],
                    ['@hash'] = GetHashKey(result[1]["model"]),
                    ['@mods'] = result[1]["mods"],
                    ['@plate'] = result[1]["plate"],
                    ['@state'] = 0
                })
                -- Handle money transfer
                if SellerData ~= nil then
                    -- Add money for online
                    SellerData.Functions.AddMoney('bank', NewPrice)
                else
                    -- Add money for offline
                    XCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..SellerCitizenId.."'", function(BuyerData)
                        if BuyerData[1] ~= nil then
                            local BuyerMoney = json.decode(BuyerData[1].money)
                            BuyerMoney.bank = BuyerMoney.bank + NewPrice
                            exports.ghmattimysql:execute('UPDATE players SET money=@money WHERE citizenid=@citizenid', {['@money'] = json.encode(BuyerMoney), ['@citizenid'] = SellerCitizenId})
                        end
                    end)
                end

                TriggerEvent("x-log:server:sendLog", Player.PlayerData.citizenid, "vehiclebought", {model = result[1].model, from = SellerCitizenId, moneyType = "cash", vehiclePrice = result[1].price, plate = result[1].plate})
                TriggerEvent("x-log:server:CreateLog", "vehicleshop", "bought", "green", "**"..GetPlayerName(src) .. "** has bought for "..result[1].price .. " (" .. result[1].plate .. ") from **"..SellerCitizenId.."**")
                TriggerClientEvent("x-occasions:client:BuyFinished", src, result[1])
                TriggerClientEvent('x-occasion:client:refreshVehicles', -1)
            
                -- Delete vehicle from Occasion
                exports.ghmattimysql:execute('DELETE FROM occasion_vehicles WHERE plate=@plate AND occasionid=@occasionid', {['@plate'] = result[1].plate, ['@occasionid'] = result[1].occasionid})
                -- Send selling mail to seller
                TriggerEvent('x-phone:server:sendNewMailToOffline', SellerCitizenId, {
                    sender = "Mosleys Occasions",
                    subject = "You have sold a vehicle!",
                    message = "The "..XCore.Shared.Vehicles[result[1].model].name.." has sold for $"..result[1].price.."!"
                })
            else
                TriggerClientEvent('XCore:NotifyNotify', src, 'You dont have enough money', 'error', 3500)
            end
        end
    end)
end)

function generateOID()
    local num = math.random(1, 10)..math.random(111, 999)

    return "OC"..num
end

function round(number)
    return number - (number % 1)
end

function escapeSqli(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end