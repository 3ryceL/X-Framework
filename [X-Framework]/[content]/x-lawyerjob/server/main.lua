XCore.Commands.Add("setlawyer", "Register someone as a lawyer", {{name="id", help="Id of the player"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = XCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then 
            local lawyerInfo = {
                id = math.random(100000, 999999),
                firstname = OtherPlayer.PlayerData.charinfo.firstname,
                lastname = OtherPlayer.PlayerData.charinfo.lastname,
                citizenid = OtherPlayer.PlayerData.citizenid,
            }
            OtherPlayer.Functions.SetJob("lawyer", 0)
            OtherPlayer.Functions.AddItem("lawyerpass", 1, false, lawyerInfo)
            TriggerClientEvent("XCore:NotifyNotify", source, "You have " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. " hired as a lawyer")
            TriggerClientEvent("XCore:NotifyNotify", OtherPlayer.PlayerData.source, "You are now a lawyer")
            TriggerClientEvent('inventory:client:ItemBox', OtherPlayer.PlayerData.source, XCore.Shared.Items["lawyerpass"], "add")
        else
            TriggerClientEvent("XCore:NotifyNotify", source, "Person is present", "error")
        end
    else
        TriggerClientEvent("XCore:NotifyNotify", source, "You are not a judge.", "error")
    end
end)

XCore.Commands.Add("removelawyer", "Remove someone as a lawyer", {{name="id", help="ID of the player"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = XCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then
	    OtherPlayer.Functions.SetJob("unemployed", 0)
            TriggerClientEvent("XCore:NotifyNotify", OtherPlayer.PlayerData.source, "You are now unemployed")
            TriggerClientEvent("XCore:NotifyNotify", source, "You have " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. "dismiss as a lawyer")
        else
            TriggerClientEvent("XCore:NotifyNotify", source, "Person is not present", "error")
        end
    else
        TriggerClientEvent("XCore:NotifyNotify", source, "Youre not a judge..", "error")
    end
end)

XCore.Functions.CreateUseableItem("lawyerpass", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("x-justice:client:showLawyerLicense", -1, source, item.info)
    end
end)
