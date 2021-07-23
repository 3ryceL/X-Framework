RegisterServerEvent('x-carwash:server:washCar')
AddEventHandler('x-carwash:server:washCar', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('x-carwash:client:washCar', src)
    elseif Player.Functions.RemoveMoney('bank', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('x-carwash:client:washCar', src)
    else
        TriggerClientEvent('XCore:NotifyNotify', src, 'You dont have enough money..', 'error')
    end
end)