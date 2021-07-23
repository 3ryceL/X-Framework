local DrivingSchools = {
    
}

RegisterServerEvent('x-cityhall:server:requestId')
AddEventHandler('x-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    local licenses = {
        ["driver"] = true,
        ["business"] = false
    }

    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "A1-A2-A | AM-B | C1-C-CE"
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)

    TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[identityData.item], 'add')
end)


RegisterServerEvent('x-cityhall:server:getIDs')
AddEventHandler('x-cityhall:server:getIDs', function()
    local src = source
    GiveStarterItems(src)
end)


RegisterServerEvent('x-cityhall:server:sendDriverTest')
AddEventHandler('x-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    for k, v in pairs(DrivingSchools) do 
        local SchoolPlayer = XCore.Functions.GetPlayerByCitizenId(v)
        if SchoolPlayer ~= nil then 
            TriggerClientEvent("x-cityhall:client:sendDriverEmail", SchoolPlayer.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = "Township",
                subject = "Driving lessons request",
                message = "Hello,<br /><br />We have just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact us:<br />Naam: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "<br />Telephone number: <strong>"..Player.PlayerData.charinfo.phone.."</strong><br/><br/>Kind regards,<br />City of Los Santos",
                button = {}
            }
            TriggerEvent("x-phone:server:sendNewEventMail", v, mailData)
        end
    end
    TriggerClientEvent('XCore:NotifyNotify', src, 'An email has been sent to driving schools, and you will be contacted automatically', "success", 5000)
end)

RegisterServerEvent('x-cityhall:server:ApplyJob')
AddEventHandler('x-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local JobInfo = XCore.Shared.Jobs[job]

    Player.Functions.SetJob(job, 0)

    TriggerClientEvent('XCore:NotifyNotify', src, 'Congratulations with your new job! ('..JobInfo.label..')')
end)


-- XCore.Commands.Add("drivinglicense", "Give a driver's license to someone", {{"id", "ID of a person"}}, true, function(source, args)
--     local Player = XCore.Functions.GetPlayer(source)

--         local SearchedPlayer = XCore.Functions.GetPlayer(tonumber(args[1]))
--         if SearchedPlayer ~= nil then
--             local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
--             if not driverLicense then
--                 local licenses = {
--                     ["driver"] = true,
--                     ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
--                 }
--                 SearchedPlayer.Functions.SetMetaData("licences", licenses)
--                 TriggerClientEvent('XCore:NotifyNotify', SearchedPlayer.PlayerData.source, "You have passed! Pick up your driver's license at the town hall", "success", 5000)
--             else
--                 TriggerClientEvent('XCore:NotifyNotify', src, "Can't give driver's license ..", "error")
--             end
--         end

-- end)

function GiveStarterItems(source)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    for k, v in pairs(XCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

function IsWhitelistedSchool(citizenid)
    local retval = false
    for k, v in pairs(DrivingSchools) do 
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('x-cityhall:server:banPlayer')
AddEventHandler('x-cityhall:server:banPlayer', function()
    local src = source
    TriggerClientEvent('chatMessage', -1, "X Anti-Cheat", "error", GetPlayerName(src).." has been banned for sending POST Request's ")
    exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(src),
        ['@license'] = XCore.Functions.GetIdentifier(src, 'license'),
        ['@discord'] = XCore.Functions.GetIdentifier(src, 'discord'),
        ['@ip'] = XCore.Functions.GetIdentifier(src, 'ip'),
        ['@reason'] = 'Abuse localhost:13172 For POST Requests',
        ['@expire'] = 2145913200,
        ['@bannedby'] = GetPlayerName(src)
    })
    DropPlayer(src, 'Attempting To Exploit')
end)
