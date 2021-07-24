XCore = nil
TriggerEvent('XCore:NotifyGetObject', function(obj) XCore = obj end)

XCore.Functions.CreateCallback("x-gangs:server:FetchConfig", function(source, cb)
    cb(json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json")))
end)

XCore.Commands.Add("creategang", "Create a whitelisted gang job with a stash and car spawn", {{name = "gang", help = "Name of the gang"}, {name = "label", help = "Gang Label"}}, true, function(source, args)
    name = args[1]
    table.remove(args, 1)
    label = table.concat(args, " ")
    
    TriggerClientEvent("x-gangs:client:BeginGangCreation", source, name, label)
end, "admin")

RegisterServerEvent("x-gangs:server:creategang", function(newGang, gangName, gangLabel)
    local permission = XCore.Functions.GetPermission(source)

    if permission == "admin" or permission == "god" then
        local gangConfig = json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json"))
        gangConfig[gangName] = newGang

        local gangs = json.decode(LoadResourceFile(GetCurrentResourceName(), "gangs.json"))
        gangs[gangName] = {
            label = gangLabel
        }

        SaveResourceFile(GetCurrentResourceName(), "config.json", json.encode(gangConfig), -1)
        TriggerClientEvent("x-gangs:client:UpdateGangs", -1, gangConfig)

        SaveResourceFile(GetCurrentResourceName(), "gangs.json", json.encode(gangs), -1)
        TriggerClientEvent("XCore:NotifyClient:UpdateGangs", -1, gangs)
        TriggerEvent("XCore:NotifyServer:UpdateGangs", gangs)

        TriggerClientEvent("XCore:NotifyNotify", source, "Gang: "..gangName.." successfully Created", "success")
    else
        XCore.Functions.Kick(source, "Attempting to place create a gang")
    end
end)

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


XCore.Commands.Add("invitegang", "Invite a player into your gang", {{name = "ID", help = "Player ID"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local gang = Player.PlayerData.gang.name

    if gang == "none" then 
        TriggerClientEvent("XCore:NotifyNotify", source, "You are not in a gang", "error")
        return 
    end
    if Config["GangLeaders"][gang] ~= nil and has_value(Config["GangLeaders"][gang], Player.PlayerData.citizenid) then
        local id = tonumber(args[1])
        if id == source then return end

        local OtherPlayer = XCore.Functions.GetPlayer(id)
        if OtherPlayer ~= nil then
            OtherPlayer.Functions.SetGang(gang)
            TriggerClientEvent("XCore:NotifyNotify", source, string.format("%s has been invited into your gang", GetPlayerName(id)))
            TriggerClientEvent("XCore:NotifyNotify", id, string.format("%s has invited into you to %s", GetPlayerName(source), XCore.Shared.Gangs[gang].label))
        else
            TriggerClientEvent("XCore:NotifyNotify", source, "This player is not online", "error")
        end
    else
        TriggerClientEvent("XCore:NotifyNotify", source, "You are not the leader of this gang", "error")
    end
end)

XCore.Commands.Add("removegang", "Remove a player from your gang", {{name = "ID", help = "Player ID"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    local gang = Player.PlayerData.gang.name

    if gang == "none" then 
        TriggerClientEvent("XCore:NotifyNotify", source, "You are not in a gang", "error")
        return 
    end
    if Config["GangLeaders"][gang] ~= nil and has_value(Config["GangLeaders"][gang], Player.PlayerData.citizenid) then
        local id = tonumber(args[1])
        if id == source then return end

        local OtherPlayer = XCore.Functions.GetPlayer(id)
        if OtherPlayer ~= nil then
            OtherPlayer.Functions.SetGang("none")
            TriggerClientEvent("XCore:NotifyNotify", source, string.format("%s has been removed from your gang", GetPlayerName(id)))
            TriggerClientEvent("XCore:NotifyNotify", id, string.format("%s has removed you from %s", GetPlayerName(source), XCore.Shared.Gangs[gang].label))
        else
            TriggerClientEvent("XCore:NotifyNotify", source, "This player is not online", "error")
        end
    else
        TriggerClientEvent("XCore:NotifyNotify", source, "You are not the leader of this gang", "error")
    end
end)
