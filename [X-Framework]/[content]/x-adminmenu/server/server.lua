-- Variables
local frozen = false
local permissions = {
    ["kill"] = "god",
    ["ban"] = "admin",
    ["noclip"] = "admin",
    ["kickall"] = "admin",
    ["kick"] = "admin"
}

-- Get Players

XCore.Functions.CreateCallback('test:getplayers', function(source, cb) -- WORKS
    local players = {}
    for k, v in pairs(XCore.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = XCore.Functions.GetPlayer(v)
        table.insert(players, {
            name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname .. " | (" .. GetPlayerName(v) .. ")",
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer= ped.PlayerData.source

        })
    end
    cb(players)
end)

XCore.Functions.CreateCallback('x-admin:server:getrank', function(source, cb)
    if XCore.Functions.HasPermission(source, "god") then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions

function tablelength(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

-- Events

RegisterNetEvent("x-admin:server:kill")
AddEventHandler("x-admin:server:kill", function(player)
    TriggerClientEvent('hospital:client:KillPlayer', player.id)
end)

RegisterNetEvent("x-admin:server:revive")
AddEventHandler("x-admin:server:revive", function(player)
    TriggerClientEvent('hospital:client:Revive', player.id)
end)

RegisterNetEvent("x-admin:server:kick")
AddEventHandler("x-admin:server:kick", function(player, reason)
    local src = source
    if XCore.Functions.HasPermission(src, permissions["kick"]) then
        DropPlayer(player.id, "You have been kicked from the server:\n" .. reason .. "\n\n🔸 Join the discord server for more information: https://discord.gg/example")
    end
end)

RegisterNetEvent("x-admin:server:ban")
AddEventHandler("x-admin:server:ban", function(player, time, reason)
    local src = source
    if XCore.Functions.HasPermission(src, permissions["ban"]) then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date("*t", banTime)
        exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
            ['@name'] = GetPlayerName(player.id),
            ['@license'] = XCore.Functions.GetIdentifier(player.id, 'license'),
            ['@discord'] = XCore.Functions.GetIdentifier(player.id, 'discord'),
            ['@ip'] = XCore.Functions.GetIdentifier(player.id, 'ip'),
            ['@reason'] = reason,
            ['@expire'] = banTime,
            ['@bannedby'] = GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message server"><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>',
            args = {GetPlayerName(player.id), reason}
        })
        if banTime >= 2147483647 then
            DropPlayer(player.id, "You have been banned:\n" .. reason .. "\n\nYour ban is permanent.\n🔸 Join the discord for more information: https://discord.gg/example")
        else
            DropPlayer(player.id, "You have been banned:\n" .. reason .. "\n\nBan expires: " .. timeTable["day"] .. "/" .. timeTable["month"] .. "/" .. timeTable["year"] .. " " .. timeTable["hour"] .. ":" .. timeTable["min"] .. "\n🔸 Join the discord for more information: https://discord.gg/example")
        end
    end
end)

RegisterNetEvent("x-admin:server:spectate")
AddEventHandler("x-admin:server:spectate", function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('x-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent("x-admin:server:freeze")
AddEventHandler("x-admin:server:freeze", function(player)
    local target = GetPlayerPed(player.id)
    if not frozen then
        frozen = true
        FreezeEntityPosition(target, true)
    else
        frozen = false
        FreezeEntityPosition(target, false)
    end
end)

RegisterNetEvent('x-admin:server:goto')
AddEventHandler('x-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('x-admin:server:bring')
AddEventHandler('x-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent("x-admin:server:inventory")
AddEventHandler("x-admin:server:inventory", function(player)
    local src = source
    TriggerClientEvent('x-admin:client:inventory', src, player.id)
end)

RegisterNetEvent("x-admin:server:cloth")
AddEventHandler("x-admin:server:cloth", function(player)
	TriggerClientEvent("x-clothing:client:openMenu", player.id)
end)

RegisterServerEvent('x-admin:server:setPermissions')
AddEventHandler('x-admin:server:setPermissions', function(targetId, group)
    XCore.Functions.AddPermission(targetId, group[1].rank)
    TriggerClientEvent('XCore:NotifyNotify', targetId, 'Your Permission Level Is Now '..group[1].label)
end)

RegisterServerEvent('x-admin:server:SendReport')
AddEventHandler('x-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    local Players = XCore.Functions.GetPlayers()

    if XCore.Functions.HasPermission(src, "admin") then
        if XCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "REPORT - "..name.." ("..targetSrc..")", "report", msg)
        end
    end
end)

RegisterServerEvent('x-admin:server:StaffChatMessage')
AddEventHandler('x-admin:server:StaffChatMessage', function(name, msg)
    local src = source
    local Players = XCore.Functions.GetPlayers()

    if XCore.Functions.HasPermission(src, "admin") then
        if XCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
        end
    end
end)

RegisterServerEvent('x-admin:server:SaveCar')
AddEventHandler('x-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate}, function(result)
        if result[1] == nil then
            exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
                ['@license'] = Player.PlayerData.license,
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@vehicle'] = vehicle.model,
                ['@hash'] = vehicle.hash,
                ['@mods'] = json.encode(mods),
                ['@plate'] = plate,
                ['@state'] = 0
            })
            TriggerClientEvent('XCore:NotifyNotify', src, 'The vehicle is now yours!', 'success', 5000)
        else
            TriggerClientEvent('XCore:NotifyNotify', src, 'This vehicle is already yours..', 'error', 3000)
        end
    end)
end)

-- Commands

XCore.Commands.Add("admincar", "Save Vehicle To Your Garage (Admin Only)", {}, false, function(source, args)
    local ply = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-admin:client:SaveCar', source)
end, "admin")

XCore.Commands.Add("announce", "Make An Announcement (Admin Only)", {}, false, function(source, args)
    local msg = table.concat(args, " ")
    for i = 1, 3, 1 do
        TriggerClientEvent('chatMessage', -1, "SYSTEM", "error", msg)
    end
end, "admin")

XCore.Commands.Add("admin", "Open Admin Menu (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('x-admin:client:openMenu', source)
end, "admin")

XCore.Commands.Add("report", "Admin Report", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-admin:client:SendReport', -1, GetPlayerName(source), source, msg)
    TriggerClientEvent('chatMessage', source, "REPORT Send", "normal", msg)
    TriggerEvent("x-log:server:CreateLog", "report", "Report", "green", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Report:** " ..msg, false)
end)

XCore.Commands.Add("staffchat", "Send A Message To All Staff (Admin Only)", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    TriggerClientEvent('x-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "admin")

XCore.Commands.Add("givenuifocus", "Give A Player NUI Focus (Admin Only)", {{name="id", help="Player id"}, {name="focus", help="Set focus on/off"}, {name="mouse", help="Set mouse on/off"}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('x-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, "admin")

XCore.Commands.Add("warn", "Warn A Player (Admin Only)", {{name="ID", help="Player"}, {name="Reason", help="Mention a reason"}}, true, function(source, args)
    local targetPlayer = XCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = XCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local myName = senderPlayer.PlayerData.name
    local warnId = "WARN-"..math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chatMessage', targetPlayer.PlayerData.source, "SYSTEM", "error", "You have been warned by: "..GetPlayerName(source)..", Reason: "..msg)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You have warned "..GetPlayerName(targetPlayer.PlayerData.source).." for: "..msg)
        exports.ghmattimysql:execute('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (@senderIdentifier, @targetIdentifier, @reason, @warnId)', {
            ['@senderIdentifier'] = senderPlayer.PlayerData.license,
            ['@targetIdentifier'] = targetPlayer.PlayerData.license,
            ['@reason'] = msg,
            ['@warnId'] = warnId
        })
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'This player is not online', 'error')
    end 
end, "admin")

XCore.Commands.Add("checkwarns", "Check Player Warnings (Admin Only)", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = XCore.Functions.GetPlayer(tonumber(args[1]))
        exports.ghmattimysql:execute('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license}, function(result)
            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has "..tablelength(result).." warnings!")
        end)
    else
        local targetPlayer = XCore.Functions.GetPlayer(tonumber(args[1]))
        exports.ghmattimysql:execute('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license}, function(warnings)
            local selectedWarning = tonumber(args[2])

            if warnings[selectedWarning] ~= nil then
                local sender = XCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)

                TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has been warned by "..sender.PlayerData.name..", Reason: "..warnings[selectedWarning].reason)
            end
        end)
    end
end, "admin")

XCore.Commands.Add("delwarn", "Delete Players Warnings (Admin Only)", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, true, function(source, args)
    local targetPlayer = XCore.Functions.GetPlayer(tonumber(args[1]))
    exports.ghmattimysql:execute('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license}, function(warnings)
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = XCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)

            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "You have deleted warning ("..selectedWarning..") , Reason: "..warnings[selectedWarning].reason)
            exports.ghmattimysql:execute('DELETE FROM player_warns WHERE warnId=@warnId', {['@warnId'] = warnings[selectedWarning].warnId})
        end
    end)
end, "admin")

XCore.Commands.Add("reportr", "Reply To A Report (Admin Only)", {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = XCore.Functions.GetPlayer(playerId)
    local Player = XCore.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', playerId, "ADMIN - "..GetPlayerName(source), "warning", msg)
        TriggerClientEvent('XCore:NotifyNotify', source, "Sent reply")
        for k, v in pairs(XCore.Functions.GetPlayers()) do
            if XCore.Functions.HasPermission(v, "admin") then
                if XCore.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "ReportReply("..source..") - "..GetPlayerName(source), "warning", msg)
                    TriggerEvent("x-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)
                end
            end
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "Player is not online", "error")
    end
end, "admin")

XCore.Commands.Add("setmodel", "Change Ped Model (Admin Only)", {{name="model", help="Name of the model"}, {name="id", help="Id of the Player (empty for yourself)"}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= "" then
        if target == nil then
            TriggerClientEvent('x-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = XCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('x-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('XCore:NotifyNotify', source, "This person is not online..", "error")
            end
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You did not set a model..", "error")
    end
end, "admin")

XCore.Commands.Add("setspeed", "Set Player Foot Speed (Admin Only)", {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('x-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You did not set a speed.. (`fast` for super-run, `normal` for normal)", "error")
    end
end, "admin")

XCore.Commands.Add("reporttoggle", "Toggle Incoming Reports (Admin Only)", {}, false, function(source, args)
    XCore.Functions.ToggleOptin(source)
    if XCore.Functions.IsOptin(source) then
        TriggerClientEvent('XCore:NotifyNotify', source, "You are receiving reports", "success")
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You are not receiving reports", "error")
    end
end, "admin")

RegisterCommand("kickall", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        local Player = XCore.Functions.GetPlayer(src)

        if XCore.Functions.HasPermission(src, "god") then
            if args[1] ~= nil then
                for k, v in pairs(XCore.Functions.GetPlayers()) do
                    local Player = XCore.Functions.GetPlayer(v)
                    if Player ~= nil then 
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'Mention a reason..')
            end
        else
            TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'You can\'t do this..')
        end
    else
        for k, v in pairs(XCore.Functions.GetPlayers()) do
            local Player = XCore.Functions.GetPlayer(v)
            if Player ~= nil then 
                DropPlayer(Player.PlayerData.source, "Server restart, check our Discord for more information! (discord.gg/ChangeInx-adminMainLua)")
            end
        end
    end
end, false)

XCore.Commands.Add("setammo", "Set Your Ammo Amount (Admin Only)", {{name="amount", help="Amount of bullets, for example: 20"}, {name="weapon", help="Name of the weapen, for example: WEAPON_VINTAGEPISTOL"}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('x-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('x-weapons:client:SetWeaponAmmoManual', src, "current", amount)
    end
end, 'admin')
