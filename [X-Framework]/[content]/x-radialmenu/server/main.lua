RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
    -- ??
end)

RegisterServerEvent('x-radialmenu:trunk:server:Door')
AddEventHandler('x-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('x-radialmenu:trunk:client:Door', -1, plate, door, open)
end)