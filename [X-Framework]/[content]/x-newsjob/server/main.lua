XCore.Commands.Add("newscam", "Grab a news camera", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Cam:ToggleCam", source)
    end
end)

XCore.Commands.Add("newsmic", "Grab a news microphone", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Mic:ToggleMic", source)
    end
end)

