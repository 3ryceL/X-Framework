Accounts = {}

CreateThread(function()
    Wait(500)
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "./database.json"))

    if not result then
        return
    end

    for k,v in pairs(result) do
        local k = tostring(k)
        local v = tonumber(v)

        if k and v then
            Accounts[k] = v
        end
    end
end)

RegisterServerEvent("x-bossmenu:server:withdrawMoney")
AddEventHandler("x-bossmenu:server:withdrawMoney", function(amount)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local job = xPlayer.PlayerData.job.name

    if not Accounts[job] then
        Accounts[job] = 0
    end

    if Accounts[job] >= amount then
        Accounts[job] = Accounts[job] - amount
        xPlayer.Functions.AddMoney("cash", amount)
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "Invaild Amount :/", "error")
        return
    end

    TriggerClientEvent('x-bossmenu:client:refreshSociety', -1, job, Accounts[job])
    SaveResourceFile(GetCurrentResourceName(), "./database.json", json.encode(Accounts), -1)
    TriggerEvent('x-log:server:CreateLog', 'bossmenu', 'Withdraw Money', "Successfully withdrawn $" .. amount .. ' (' .. job .. ')', src)
end)

RegisterServerEvent("x-bossmenu:server:depositMoney")
AddEventHandler("x-bossmenu:server:depositMoney", function(amount)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local job = xPlayer.PlayerData.job.name

    if not Accounts[job] then
        Accounts[job] = 0
    end

    if xPlayer.Functions.RemoveMoney("cash", amount) then
        Accounts[job] = Accounts[job] + amount
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "Invaild Amount :/", "error")
        return
    end

    TriggerClientEvent('x-bossmenu:client:refreshSociety', -1, job, Accounts[job])
    SaveResourceFile(GetCurrentResourceName(), "./database.json", json.encode(Accounts), -1)
    TriggerEvent('x-log:server:CreateLog', 'bossmenu', 'Deposit Money', "Successfully deposited $" .. amount .. ' (' .. job .. ')', src)
end)

RegisterServerEvent("x-bossmenu:server:addAccountMoney")
AddEventHandler("x-bossmenu:server:addAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end
    
    Accounts[account] = Accounts[account] + amount
    TriggerClientEvent('x-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./database.json", json.encode(Accounts), -1)
end)

RegisterServerEvent("x-bossmenu:server:removeAccountMoney")
AddEventHandler("x-bossmenu:server:removeAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end

    if Accounts[account] >= amount then
        Accounts[account] = Accounts[account] - amount
    end

    TriggerClientEvent('x-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./database.json", json.encode(Accounts), -1)
end)

RegisterServerEvent("x-bossmenu:server:openMenu")
AddEventHandler("x-bossmenu:server:openMenu", function()
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local job = xPlayer.PlayerData.job
    local employees = {}
    if job.isboss == true then
        if not Accounts[job.name] then
            Accounts[job.name] = 0
        end

        XCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `job` LIKE '%".. job.name .."%'", function(players)
            if players[1] ~= nil then
                for key, value in pairs(players) do
                    local isOnline = XCore.Functions.GetPlayerByCitizenId(value.citizenid)

                    if isOnline then
                        table.insert(employees, {
                            source = isOnline.PlayerData.citizenid, 
                            grade = isOnline.PlayerData.job.grade,
                            isboss = isOnline.PlayerData.job.isboss,
                            name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                        })
                    else
                        table.insert(employees, {
                            source = value.citizenid, 
                            grade =  json.decode(value.job).grade,
                            isboss = json.decode(value.job).isboss,
                            name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                        })
                    end
                end
            end

            TriggerClientEvent('x-bossmenu:client:openMenu', src, employees, XCore.Shared.Jobs[job.name])
            TriggerClientEvent('x-bossmenu:client:refreshSociety', -1, job.name, Accounts[job.name])
        end)
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Don't Have Access", "error")
    end
end)


RegisterServerEvent('x-bossmenu:server:fireEmployee')
AddEventHandler('x-bossmenu:server:fireEmployee', function(data)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local xEmployee = XCore.Functions.GetPlayerByCitizenId(data.source)

    if xEmployee then
        if xEmployee.Functions.SetJob("unemployed", '0') then
            TriggerEvent('x-log:server:CreateLog', 'bossmenu', 'Job Fire', "Successfully fired " .. GetPlayerName(xEmployee.PlayerData.source) .. ' (' .. xPlayer.PlayerData.job.name .. ')', src)

            TriggerClientEvent('XCore:NotifyNotify', src, "Fired successfully!", "success")
            TriggerClientEvent('XCore:NotifyNotify', xEmployee.PlayerData.source , "You got fired.", "success")

            Wait(500)
            local employees = {}
            exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `job` LIKE '%".. xPlayer.PlayerData.job.name .."%'", function(players)
                if players[1] ~= nil then
                    for key, value in pairs(players) do
                        local isOnline = XCore.Functions.GetPlayerByCitizenId(value.citizenid)
                    
                        if isOnline then
                            table.insert(employees, {
                                source = isOnline.PlayerData.citizenid, 
                                grade = isOnline.PlayerData.job.grade,
                                isboss = isOnline.PlayerData.job.isboss,
                                name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                            })
                        else
                            table.insert(employees, {
                                source = value.citizenid, 
                                grade =  json.decode(value.job).grade,
                                isboss = json.decode(value.job).isboss,
                                name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                            })
                        end
                    end
                    TriggerClientEvent('x-bossmenu:client:refreshPage', src, 'employee', employees)
                end
            end)
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "Error.", "error")
        end
    else
        exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `citizenid` = '" .. data.source .. "' LIMIT 1", function(player)
            if player[1] ~= nil then
                xEmployee = player[1]

                local job = {}
	            job.name = "unemployed"
	            job.label = "Unemployed"
	            job.payment = 10
	            job.onduty = true
	            job.isboss = false
	            job.grade = {}
	            job.grade.name = nil
                job.grade.level = 0

                exports.ghmattimysql:execute("UPDATE `players` SET `job` = '"..json.encode(job).."' WHERE `citizenid` = '".. data.source .."'")
                TriggerClientEvent('XCore:NotifyNotify', src, "Fired successfully!", "success")
                TriggerEvent('x-log:server:CreateLog', 'bossmenu', 'Fire', "Successfully fired " .. data.source .. ' (' .. xPlayer.PlayerData.job.name .. ')', src)
                
                Wait(500)
                local employees = {}
                exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `job` LIKE '%".. xPlayer.PlayerData.job.name .."%'", function(players)
                    if players[1] ~= nil then
                        for key, value in pairs(players) do
                            local isOnline = XCore.Functions.GetPlayerByCitizenId(value.citizenid)
                        
                            if isOnline then
                                table.insert(employees, {
                                    source = isOnline.PlayerData.citizenid, 
                                    grade = isOnline.PlayerData.job.grade,
                                    isboss = isOnline.PlayerData.job.isboss,
                                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                                })
                            else
                                table.insert(employees, {
                                    source = value.citizenid, 
                                    grade =  json.decode(value.job).grade,
                                    isboss = json.decode(value.job).isboss,
                                    name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                                })
                            end
                        end

                        TriggerClientEvent('x-bossmenu:client:refreshPage', src, 'employee', employees)
                    end
                end)
            else
                TriggerClientEvent('XCore:NotifyNotify', src, "Error. Could not find player.", "error")
            end
        end)
    end
end)

RegisterServerEvent('x-bossmenu:server:giveJob')
AddEventHandler('x-bossmenu:server:giveJob', function(data)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local xTarget = XCore.Functions.GetPlayerByCitizenId(data.source)

    if xPlayer.PlayerData.job.isboss == true then
        if xTarget and xTarget.Functions.SetJob(xPlayer.PlayerData.job.name, 0) then
            TriggerClientEvent('XCore:NotifyNotify', src, "You recruit " .. (xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname) .. " to " .. xPlayer.PlayerData.job.label .. ".", "success")
            TriggerClientEvent('XCore:NotifyNotify', xTarget.PlayerData.source , "You've been recruited to " .. xPlayer.PlayerData.job.label .. ".", "success")
            TriggerEvent('x-log:server:CreateLog', 'bossmenu', 'Recruit', "Successfully recruited " .. (xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname) .. ' (' .. xPlayer.PlayerData.job.name .. ')', src)
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You are not the boss, how did you reach here bitch?!", "error")
    end
end)

RegisterServerEvent('x-bossmenu:server:updateGrade')
AddEventHandler('x-bossmenu:server:updateGrade', function(data)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local xEmployee = XCore.Functions.GetPlayerByCitizenId(data.source)

    if xEmployee then
        if xEmployee.Functions.SetJob(xPlayer.PlayerData.job.name, data.grade) then
            TriggerClientEvent('XCore:NotifyNotify', src, "Promoted successfully!", "success")
            TriggerClientEvent('XCore:NotifyNotify', xEmployee.PlayerData.source , "You just got promoted [" .. data.grade .."].", "success")

            Wait(500)
            local employees = {}
            exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `job` LIKE '%".. xPlayer.PlayerData.job.name .."%'", function(players)
                if players[1] ~= nil then
                    for key, value in pairs(players) do
                        local isOnline = XCore.Functions.GetPlayerByCitizenId(value.citizenid)
                    
                        if isOnline then
                            table.insert(employees, {
                                source = isOnline.PlayerData.citizenid, 
                                grade = isOnline.PlayerData.job.grade,
                                isboss = isOnline.PlayerData.job.isboss,
                                name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                            })
                        else
                            table.insert(employees, {
                                source = value.citizenid, 
                                grade =  json.decode(value.job).grade,
                                isboss = json.decode(value.job).isboss,
                                name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                            })
                        end
                    end

                    TriggerClientEvent('x-bossmenu:client:refreshPage', src, 'employee', employees)
                end
            end)
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "Error.", "error")
        end
    else
        exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `citizenid` = '" .. data.source .. "' LIMIT 1", function(player)
            if player[1] ~= nil then
                xEmployee = player[1]
                local job = XCore.Shared.Jobs[xPlayer.PlayerData.job.name]
                local employeejob = json.decode(xEmployee.job)
                employeejob.grade = job.grades[data.grade]
                exports.ghmattimysql:execute("UPDATE `players` SET `job` = '"..json.encode(employeejob).."' WHERE `citizenid` = '".. data.source .."'")
                TriggerClientEvent('XCore:NotifyNotify', src, "Promoted successfully!", "success")
                
                Wait(500)
                local employees = {}
                exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `job` LIKE '%".. xPlayer.PlayerData.job.name .."%'", function(players)
                    if players[1] ~= nil then
                        for key, value in pairs(players) do
                            local isOnline = XCore.Functions.GetPlayerByCitizenId(value.citizenid)
                        
                            if isOnline then
                                table.insert(employees, {
                                    source = isOnline.PlayerData.citizenid, 
                                    grade = isOnline.PlayerData.job.grade,
                                    isboss = isOnline.PlayerData.job.isboss,
                                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                                })
                            else
                                table.insert(employees, {
                                    source = value.citizenid, 
                                    grade =  json.decode(value.job).grade,
                                    isboss = json.decode(value.job).isboss,
                                    name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                                })
                            end
                        end

                        TriggerClientEvent('x-bossmenu:client:refreshPage', src, 'employee', employees)
                    end
                end)
            else
                TriggerClientEvent('XCore:NotifyNotify', src, "Error. Could not find player.", "error")
            end
        end)
    end
end)

RegisterServerEvent('x-bossmenu:server:updateNearbys')
AddEventHandler('x-bossmenu:server:updateNearbys', function(data)
    local src = source
    local players = {}
    local xPlayer = XCore.Functions.GetPlayer(src)
    for _, player in pairs(data) do
        local xTarget = XCore.Functions.GetPlayer(player)
        if xTarget and xTarget.PlayerData.job.name ~= xPlayer.PlayerData.job.name then
            table.insert(players, {
                source = xTarget.PlayerData.citizenid,
                name = xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname
            })
        end
    end

    TriggerClientEvent('x-bossmenu:client:refreshPage', src, 'recruits', players)
end)

function GetAccount(account)
    return Accounts[account] or 0
end

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end
