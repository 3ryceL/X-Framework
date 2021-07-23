local chicken = vehicleBaseRepairCost

RegisterServerEvent('x-customs:attemptPurchase')
AddEventHandler('x-customs:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local Player = XCore.Functions.GetPlayer(source)
    if type == "repair" then
        if Player.PlayerData.money.cash >= chicken then
            Player.Functions.RemoveMoney('cash', chicken)
            TriggerClientEvent('x-customs:purchaseSuccessful', source)
        else
            TriggerClientEvent('x-customs:purchaseFailed', source)
        end
    elseif type == "performance" then
        if Player.PlayerData.money.cash >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('x-customs:purchaseSuccessful', source)
            Player.Functions.RemoveMoney('cash', vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('x-customs:purchaseFailed', source)
        end
    else
        if Player.PlayerData.money.cash >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('x-customs:purchaseSuccessful', source)
            Player.Functions.RemoveMoney('cash', vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('x-customs:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('x-customs:updateRepairCost')
AddEventHandler('x-customs:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent("updateVehicle")
AddEventHandler("updateVehicle", function(myCar)
	local src = source
    if IsVehicleOwned(myCar.plate) then
        exports.ghmattimysql:execute('UPDATE player_vehicles SET mods=@mods WHERE plate=@plate', {['@mods'] = json.encode(myCar), ['@plate'] = myCar.plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    XCore.Functions.ExecuteSql(true, "SELECT `plate` FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end