local Bail = {}

XCore.Functions.CreateCallback('x-garbagejob:server:HasMoney', function(source, cb)
    local Player = XCore.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    -- if Player.PlayerData.money.cash >= Config.BailPrice then
    --     Bail[CitizenId] = "cash"
    --     Player.Functions.RemoveMoney('cash', Config.BailPrice)
    --     cb(true)
    -- else
        if Player.PlayerData.money.bank >= Config.BailPrice then
        Bail[CitizenId] = "bank"
        Player.Functions.RemoveMoney('bank', Config.BailPrice)
        cb(true)
    else
        cb(false)
    end
end)

XCore.Functions.CreateCallback('x-garbagejob:server:CheckBail', function(source, cb)
    local Player = XCore.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    if Bail[CitizenId] ~= nil then
        Player.Functions.AddMoney(Bail[CitizenId], Config.BailPrice)
        Bail[CitizenId] = nil
        cb(true)
    else
        cb(false)
    end
end)

local Materials = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterNetEvent('x-garbagejob:server:nano')
AddEventHandler('x-garbagejob:server:nano', function()
    local xPlayer = XCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("cryptostick", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items["cryptostick"], "add")
end)

RegisterServerEvent('x-garbagejob:server:PayShit')
AddEventHandler('x-garbagejob:server:PayShit', function(amount, location)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    if amount > 0 then
        Player.Functions.AddMoney('bank', amount)

        if location == #Config.Locations["trashcan"] then
            for i = 1, math.random(3, 5), 1 do
                local item = Materials[math.random(1, #Materials)]
                Player.Functions.AddItem(item, math.random(4, 7))
                TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[item], 'add')
                Citizen.Wait(500)
            end
        end

        TriggerClientEvent('XCore:NotifyNotify', src, "You have $"..amount..",- got paid to your bank account!", "success")
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You have earned nothing..", "error")
    end
end)