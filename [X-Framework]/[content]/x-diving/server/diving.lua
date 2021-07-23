local CurrentDivingArea = math.random(1, #XDiving.Locations)

XCore.Functions.CreateCallback('x-diving:server:GetDivingConfig', function(source, cb)
    cb(XDiving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('x-diving:server:TakeCoral')
AddEventHandler('x-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local CoralType = math.random(1, #XDiving.CoralTypes)
    local Amount = math.random(1, XDiving.CoralTypes[CoralType].maxAmount)
    local ItemData = XCore.Shared.Items[XDiving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (XDiving.Locations[Area].TotalCoral - 1) == 0 then
        for k, v in pairs(XDiving.Locations[CurrentDivingArea].coords.Coral) do
            v.PickedUp = false
        end
        XDiving.Locations[CurrentDivingArea].TotalCoral = XDiving.Locations[CurrentDivingArea].DefaultCoral

        local newLocation = math.random(1, #XDiving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(3)
            newLocation = math.random(1, #XDiving.Locations)
        end
        CurrentDivingArea = newLocation
        
        TriggerClientEvent('x-diving:client:NewLocations', -1)
    else
        XDiving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
        XDiving.Locations[Area].TotalCoral = XDiving.Locations[Area].TotalCoral - 1
    end

    TriggerClientEvent('x-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('x-diving:server:RemoveGear')
AddEventHandler('x-diving:server:RemoveGear', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["diving_gear"], "remove")
end)

RegisterServerEvent('x-diving:server:GiveBackGear')
AddEventHandler('x-diving:server:GiveBackGear', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    
    Player.Functions.AddItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["diving_gear"], "add")
end)