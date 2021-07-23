RegisterServerEvent('x-shops:server:UpdateShopItems')
AddEventHandler('x-shops:server:UpdateShopItems', function(shop, itemData, amount)
    Config.Locations[shop]["products"][itemData.slot].amount =  Config.Locations[shop]["products"][itemData.slot].amount - amount
    if Config.Locations[shop]["products"][itemData.slot].amount <= 0 then 
        Config.Locations[shop]["products"][itemData.slot].amount = 0
    end
    TriggerClientEvent('x-shops:client:SetShopItems', -1, shop, Config.Locations[shop]["products"])
end)

RegisterServerEvent('x-shops:server:RestockShopItems')
AddEventHandler('x-shops:server:RestockShopItems', function(shop)
    if Config.Locations[shop]["products"] ~= nil then 
        local randAmount = math.random(10, 50)
        for k, v in pairs(Config.Locations[shop]["products"]) do 
            Config.Locations[shop]["products"][k].amount = Config.Locations[shop]["products"][k].amount + randAmount
        end
        TriggerClientEvent('x-shops:client:RestockShopItems', -1, shop, randAmount)
    end
end)

XCore.Functions.CreateCallback('x-shops:server:getLicenseStatus', function(source, cb)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local licenseTable = Player.PlayerData.metadata["licences"]

    if licenseTable.weapon then
        cb(true)
    else
        cb(false)
    end
end)