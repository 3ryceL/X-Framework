RegisterServerEvent('x-radialmenu:server:RemoveBrancard')
AddEventHandler('x-radialmenu:server:RemoveBrancard', function(PlayerPos, BrancardObject)
    TriggerClientEvent('x-radialmenu:client:RemoveBrancardFromArea', -1, PlayerPos, BrancardObject)
end)

RegisterServerEvent('x-radialmenu:Brancard:BusyCheck')
AddEventHandler('x-radialmenu:Brancard:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('x-radialmenu:Brancard:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('x-radialmenu:server:BusyResult')
AddEventHandler('x-radialmenu:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('x-radialmenu:client:Result', OtherId, IsBusy, type)
end)