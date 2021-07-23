local ItemTable = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterServerEvent("x-recycle:server:getItem")
AddEventHandler("x-recycle:server:getItem", function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    for i = 1, math.random(1, 5), 1 do
        local randItem = ItemTable[math.random(1, #ItemTable)]
        local amount = math.random(2, 6)
        Player.Functions.AddItem(randItem, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[randItem], 'add')
        Citizen.Wait(500)
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        Player.Functions.AddItem("cryptostick", 1, false)
        TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items["cryptostick"], "add")
    end

    local Luck = math.random(1, 10)
    local Odd = math.random(1, 10)
    if Luck == Odd then
        local random = math.random(1, 3)
        Player.Functions.AddItem("rubber", random)
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["rubber"], 'add')
    end
end)