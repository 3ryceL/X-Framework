XCore.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
	TriggerClientEvent("x-commandbinding:client:openUI", source)
end)

RegisterServerEvent('x-commandbinding:server:setKeyMeta')
AddEventHandler('x-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = XCore.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)